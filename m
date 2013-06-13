Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id 5B913900013
	for <linux-mm@kvack.org>; Thu, 13 Jun 2013 09:28:08 -0400 (EDT)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [Part1 PATCH v5 16/22] x86, mm, numa: Move numa emulation handling down.
Date: Thu, 13 Jun 2013 21:03:03 +0800
Message-Id: <1371128589-8953-17-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1371128589-8953-1-git-send-email-tangchen@cn.fujitsu.com>
References: <1371128589-8953-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, tj@kernel.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com
Cc: x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

From: Yinghai Lu <yinghai@kernel.org>

numa_emulation() needs to allocate buffer for new numa_meminfo
and distance matrix, so execute it later in x86_numa_init().

Also we change the behavoir:
	- before this patch, if user input wrong data in command
	  line, it will fall back to next numa probing or disabling
	  numa.
	- after this patch, if user input wrong data in command line,
	  it will stay with numa info probed from previous probing,
	  like ACPI SRAT or amd_numa.

We need to call numa_check_memblks to reject wrong user inputs early
so that we can keep the original numa_meminfo not changed.

Signed-off-by: Yinghai Lu <yinghai@kernel.org>
Cc: David Rientjes <rientjes@google.com>
Reviewed-by: Tang Chen <tangchen@cn.fujitsu.com>
Tested-by: Tang Chen <tangchen@cn.fujitsu.com>
---
 arch/x86/mm/numa.c           |    6 +++---
 arch/x86/mm/numa_emulation.c |    2 +-
 arch/x86/mm/numa_internal.h  |    2 ++
 3 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/arch/x86/mm/numa.c b/arch/x86/mm/numa.c
index da2ebab..3254f22 100644
--- a/arch/x86/mm/numa.c
+++ b/arch/x86/mm/numa.c
@@ -534,7 +534,7 @@ static unsigned long __init node_map_pfn_alignment(struct numa_meminfo *mi)
 }
 #endif
 
-static int __init numa_check_memblks(struct numa_meminfo *mi)
+int __init numa_check_memblks(struct numa_meminfo *mi)
 {
 	nodemask_t nodes_parsed;
 	unsigned long pfn_align;
@@ -604,8 +604,6 @@ static int __init numa_init(int (*init_func)(void))
 	if (ret < 0)
 		return ret;
 
-	numa_emulation(&numa_meminfo, numa_distance_cnt);
-
 	ret = numa_check_memblks(&numa_meminfo);
 	if (ret < 0)
 		return ret;
@@ -669,6 +667,8 @@ void __init x86_numa_init(void)
 
 	early_x86_numa_init();
 
+	numa_emulation(&numa_meminfo, numa_distance_cnt);
+
 	node_possible_map = numa_nodes_parsed;
 	numa_nodemask_from_meminfo(&node_possible_map, mi);
 
diff --git a/arch/x86/mm/numa_emulation.c b/arch/x86/mm/numa_emulation.c
index dbbbb47..5a0433d 100644
--- a/arch/x86/mm/numa_emulation.c
+++ b/arch/x86/mm/numa_emulation.c
@@ -348,7 +348,7 @@ void __init numa_emulation(struct numa_meminfo *numa_meminfo, int numa_dist_cnt)
 	if (ret < 0)
 		goto no_emu;
 
-	if (numa_cleanup_meminfo(&ei) < 0) {
+	if (numa_cleanup_meminfo(&ei) < 0 || numa_check_memblks(&ei) < 0) {
 		pr_warning("NUMA: Warning: constructed meminfo invalid, disabling emulation\n");
 		goto no_emu;
 	}
diff --git a/arch/x86/mm/numa_internal.h b/arch/x86/mm/numa_internal.h
index ad86ec9..bb2fbcc 100644
--- a/arch/x86/mm/numa_internal.h
+++ b/arch/x86/mm/numa_internal.h
@@ -21,6 +21,8 @@ void __init numa_reset_distance(void);
 
 void __init x86_numa_init(void);
 
+int __init numa_check_memblks(struct numa_meminfo *mi);
+
 #ifdef CONFIG_NUMA_EMU
 void __init numa_emulation(struct numa_meminfo *numa_meminfo,
 			   int numa_dist_cnt);
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
