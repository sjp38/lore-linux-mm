Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 32CCC6B0038
	for <linux-mm@kvack.org>; Thu, 28 Sep 2017 17:29:54 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id 188so6536561pgb.3
        for <linux-mm@kvack.org>; Thu, 28 Sep 2017 14:29:54 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id i90si1971908pli.615.2017.09.28.14.29.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Sep 2017 14:29:52 -0700 (PDT)
Date: Thu, 28 Sep 2017 14:29:50 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v3] mm, sysctl: make NUMA stats configurable
Message-Id: <20170928142950.1a09090fe4baf4acdc1bbc35@linux-foundation.org>
In-Reply-To: <1506579101-5457-1-git-send-email-kemi.wang@intel.com>
References: <1506579101-5457-1-git-send-email-kemi.wang@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kemi Wang <kemi.wang@intel.com>
Cc: "Luis R . Rodriguez" <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>, Jonathan Corbet <corbet@lwn.net>, Michal Hocko <mhocko@suse.com>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Christopher Lameter <cl@linux.com>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Vlastimil Babka <vbabka@suse.cz>, Dave <dave.hansen@linux.intel.com>, Tim Chen <tim.c.chen@intel.com>, Andi Kleen <andi.kleen@intel.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Ying Huang <ying.huang@intel.com>, Aaron Lu <aaron.lu@intel.com>, Proc sysctl <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>

On Thu, 28 Sep 2017 14:11:41 +0800 Kemi Wang <kemi.wang@intel.com> wrote:

> This is the second step which introduces a tunable interface that allow
> numa stats configurable for optimizing zone_statistics(), as suggested by
> Dave Hansen and Ying Huang.

Looks OK I guess.

I fiddled with it a lot.  Please consider:

From: Andrew Morton <akpm@linux-foundation.org>
Subject: mm-sysctl-make-numa-stats-configurable-fix

- tweak documentation

- move advisory message from start_kernel() into mm_init() (I'm not sure
  we really need this message)

- use strcasecmp() in __parse_vm_numa_stats_mode()

- clean up coding style amd nessages in sysctl_vm_numa_stats_mode_handler()

Cc: Aaron Lu <aaron.lu@intel.com>
Cc: Andi Kleen <andi.kleen@intel.com>
Cc: Christopher Lameter <cl@linux.com>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Jonathan Corbet <corbet@lwn.net>
Cc: Kees Cook <keescook@chromium.org>
Cc: Kemi Wang <kemi.wang@intel.com>
Cc: "Luis R . Rodriguez" <mcgrof@kernel.org>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Cc: Tim Chen <tim.c.chen@intel.com>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Ying Huang <ying.huang@intel.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 Documentation/sysctl/vm.txt |   15 ++++++-------
 init/main.c                 |    6 ++---
 mm/vmstat.c                 |   39 +++++++++++++++-------------------
 3 files changed, 29 insertions(+), 31 deletions(-)

diff -puN Documentation/sysctl/vm.txt~mm-sysctl-make-numa-stats-configurable-fix Documentation/sysctl/vm.txt
--- a/Documentation/sysctl/vm.txt~mm-sysctl-make-numa-stats-configurable-fix
+++ a/Documentation/sysctl/vm.txt
@@ -853,7 +853,7 @@ ten times more freeable objects than the
 
 numa_stats_mode
 
-This interface allows numa statistics configurable.
+This interface allows runtime configuration or numa statistics.
 
 When page allocation performance becomes a bottleneck and you can tolerate
 some possible tool breakage and decreased numa counter precision, you can
@@ -864,13 +864,14 @@ When page allocation performance is not
 tooling to work, you can do:
 	echo [S|s]trict > /proc/sys/vm/numa_stat_mode
 
-We recommend automatic detection of numa statistics by system, because numa
-statistics does not affect system's decision and it is very rarely
-consumed. you can do:
+We recommend automatic detection of numa statistics by system, because
+numa statistics do not affect system decisions and it is very rarely
+consumed.  In this case you can do:
 	echo [A|a]uto > /proc/sys/vm/numa_stats_mode
-This is also system default configuration, with this default setting, numa
-counters update is skipped unless the counter is *read* by users at least
-once.
+
+This is the system default configuration.  With this default setting, numa
+counter updates are skipped until the counter is *read* by userspace at
+least once.
 
 ==============================================================
 
diff -puN drivers/base/node.c~mm-sysctl-make-numa-stats-configurable-fix drivers/base/node.c
diff -puN include/linux/vmstat.h~mm-sysctl-make-numa-stats-configurable-fix include/linux/vmstat.h
diff -puN init/main.c~mm-sysctl-make-numa-stats-configurable-fix init/main.c
--- a/init/main.c~mm-sysctl-make-numa-stats-configurable-fix
+++ a/init/main.c
@@ -504,6 +504,9 @@ static void __init mm_init(void)
 	pgtable_init();
 	vmalloc_init();
 	ioremap_huge_init();
+#ifdef CONFIG_NUMA
+	pr_info("vmstat: NUMA stat updates are skipped unless they have been used\n");
+#endif
 }
 
 asmlinkage __visible void __init start_kernel(void)
@@ -567,9 +570,6 @@ asmlinkage __visible void __init start_k
 	sort_main_extable();
 	trap_init();
 	mm_init();
-#ifdef CONFIG_NUMA
-	pr_info("vmstat: NUMA stats is skipped unless it has been consumed\n");
-#endif
 
 	ftrace_init();
 
diff -puN kernel/sysctl.c~mm-sysctl-make-numa-stats-configurable-fix kernel/sysctl.c
diff -puN mm/page_alloc.c~mm-sysctl-make-numa-stats-configurable-fix mm/page_alloc.c
diff -puN mm/vmstat.c~mm-sysctl-make-numa-stats-configurable-fix mm/vmstat.c
--- a/mm/vmstat.c~mm-sysctl-make-numa-stats-configurable-fix
+++ a/mm/vmstat.c
@@ -40,13 +40,11 @@ static DEFINE_MUTEX(vm_numa_stats_mode_l
 
 static int __parse_vm_numa_stats_mode(char *s)
 {
-	const char *str = s;
-
-	if (strcmp(str, "auto") == 0 || strcmp(str, "Auto") == 0)
+	if (strcasecmp(s, "auto"))
 		vm_numa_stats_mode = VM_NUMA_STAT_AUTO_MODE;
-	else if (strcmp(str, "strict") == 0 || strcmp(str, "Strict") == 0)
+	else if (strcasecmp(s, "strict") == 0)
 		vm_numa_stats_mode = VM_NUMA_STAT_STRICT_MODE;
-	else if (strcmp(str, "coarse") == 0 || strcmp(str, "Coarse") == 0)
+	else if (strcasecmp(s, "coarse"))
 		vm_numa_stats_mode = VM_NUMA_STAT_COARSE_MODE;
 	else {
 		pr_warn("Ignoring invalid vm_numa_stats_mode value: %s\n", s);
@@ -86,30 +84,29 @@ int sysctl_vm_numa_stats_mode_handler(st
 			/* no change */
 			mutex_unlock(&vm_numa_stats_mode_lock);
 			return 0;
-		} else if (vm_numa_stats_mode == VM_NUMA_STAT_AUTO_MODE)
+		} else if (vm_numa_stats_mode == VM_NUMA_STAT_AUTO_MODE) {
 			/*
-			 * Keep the branch selection in last time when numa stats
-			 * is changed to auto mode.
+			 * Keep the branch selection in last time when numa
+			 * stats is changed to auto mode.
 			 */
-			pr_info("numa stats changes from %s mode to auto mode\n",
-					vm_numa_stats_mode_name[oldval]);
-		else if (vm_numa_stats_mode == VM_NUMA_STAT_STRICT_MODE) {
+			pr_info("numa stats changed from %s to auto mode\n",
+				 vm_numa_stats_mode_name[oldval]);
+		} else if (vm_numa_stats_mode == VM_NUMA_STAT_STRICT_MODE) {
 			static_branch_enable(&vm_numa_stats_mode_key);
-			pr_info("numa stats changes from %s mode to strict mode\n",
-					vm_numa_stats_mode_name[oldval]);
+			pr_info("numa stats changes from %s to strict mode\n",
+				 vm_numa_stats_mode_name[oldval]);
 		} else if (vm_numa_stats_mode == VM_NUMA_STAT_COARSE_MODE) {
 			static_branch_disable(&vm_numa_stats_mode_key);
 			/*
-			 * Invalidate numa counters when vmstat mode is set to coarse
-			 * mode, because users can't tell the difference between the
-			 * dead state and when allocator activity is quiet once
-			 * zone_statistics() is turned off.
+			 * Invalidate numa counters when vmstat mode is set to
+			 * coarse mode, because users can't tell the difference
+			 * between the dead state and when allocator activity is
+			 * quiet once zone_statistics() is turned off.
 			 */
 			invalid_numa_statistics();
-			pr_info("numa stats changes from %s mode to coarse mode\n",
-					vm_numa_stats_mode_name[oldval]);
-		} else
-			pr_warn("invalid vm_numa_stats_mode:%d\n", vm_numa_stats_mode);
+			pr_info("numa stats changes from %s to coarse mode\n",
+				 vm_numa_stats_mode_name[oldval]);
+		}
 	}
 
 	mutex_unlock(&vm_numa_stats_mode_lock);
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
