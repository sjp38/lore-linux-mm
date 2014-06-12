Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f179.google.com (mail-ie0-f179.google.com [209.85.223.179])
	by kanga.kvack.org (Postfix) with ESMTP id 84FAE6B0180
	for <linux-mm@kvack.org>; Wed, 11 Jun 2014 20:47:59 -0400 (EDT)
Received: by mail-ie0-f179.google.com with SMTP id tr6so495982ieb.24
        for <linux-mm@kvack.org>; Wed, 11 Jun 2014 17:47:59 -0700 (PDT)
Received: from mail-ie0-x22b.google.com (mail-ie0-x22b.google.com [2607:f8b0:4001:c03::22b])
        by mx.google.com with ESMTPS id cz7si10716667icc.103.2014.06.11.17.47.58
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 11 Jun 2014 17:47:58 -0700 (PDT)
Received: by mail-ie0-f171.google.com with SMTP id x19so511891ier.30
        for <linux-mm@kvack.org>; Wed, 11 Jun 2014 17:47:58 -0700 (PDT)
Date: Wed, 11 Jun 2014 17:47:56 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch v3] mm, pcp: allow restoring percpu_pagelist_fraction
 default
In-Reply-To: <alpine.DEB.2.02.1406041734150.17045@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.02.1406111747370.11536@chino.kir.corp.google.com>
References: <1399166883-514-1-git-send-email-green@linuxhacker.ru> <alpine.DEB.2.02.1406021837490.13072@chino.kir.corp.google.com> <B549468A-10FC-4897-8720-7C9FEC6FD03A@linuxhacker.ru> <alpine.DEB.2.02.1406022056300.20536@chino.kir.corp.google.com>
 <2C763027-307F-4BC0-8C0A-7E3D5957A4DA@linuxhacker.ru> <alpine.DEB.2.02.1406031819580.8682@chino.kir.corp.google.com> <85AFB547-D3A1-4818-AD82-FF90909775D2@linuxhacker.ru> <alpine.DEB.2.02.1406041734150.17045@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Oleg Drokin <green@linuxhacker.ru>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Cody P Schafer <cody@linux.vnet.ibm.com>, Randy Dunlap <rdunlap@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org, devel@driverdev.osuosl.org

Oleg reports a division by zero error on zero-length write() to the
percpu_pagelist_fraction sysctl:

	divide error: 0000 [#1] SMP DEBUG_PAGEALLOC
	CPU: 1 PID: 9142 Comm: badarea_io Not tainted 3.15.0-rc2-vm-nfs+ #19
	Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
	task: ffff8800d5aeb6e0 ti: ffff8800d87a2000 task.ti: ffff8800d87a2000
	RIP: 0010:[<ffffffff81152664>]  [<ffffffff81152664>] percpu_pagelist_fraction_sysctl_handler+0x84/0x120
	RSP: 0018:ffff8800d87a3e78  EFLAGS: 00010246
	RAX: 0000000000000f89 RBX: ffff88011f7fd000 RCX: 0000000000000000
	RDX: 0000000000000000 RSI: 0000000000000001 RDI: 0000000000000010
	RBP: ffff8800d87a3e98 R08: ffffffff81d002c8 R09: ffff8800d87a3f50
	R10: 000000000000000b R11: 0000000000000246 R12: 0000000000000060
	R13: ffffffff81c3c3e0 R14: ffffffff81cfddf8 R15: ffff8801193b0800
	FS:  00007f614f1e9740(0000) GS:ffff88011f440000(0000) knlGS:0000000000000000
	CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
	CR2: 00007f614f1fa000 CR3: 00000000d9291000 CR4: 00000000000006e0
	Stack:
	 0000000000000001 ffffffffffffffea ffffffff81c3c3e0 0000000000000000
	 ffff8800d87a3ee8 ffffffff8122b163 ffff8800d87a3f50 00007fff1564969c
	 0000000000000000 ffff8800d8098f00 00007fff1564969c ffff8800d87a3f50
	Call Trace:
	 [<ffffffff8122b163>] proc_sys_call_handler+0xb3/0xc0
	 [<ffffffff8122b184>] proc_sys_write+0x14/0x20
	 [<ffffffff811ba93a>] vfs_write+0xba/0x1e0
	 [<ffffffff811bb486>] SyS_write+0x46/0xb0
	 [<ffffffff816db7ff>] tracesys+0xe1/0xe6

However, if the percpu_pagelist_fraction sysctl is set by the user, it is also
impossible to restore it to the kernel default since the user cannot write 0 to 
the sysctl.

This patch allows the user to write 0 to restore the default behavior.  It
still requires a fraction equal to or larger than 8, however, as stated by the 
documentation for sanity.  If a value in the range [1, 7] is written, the sysctl 
will return EINVAL.

This successfully solves the divide by zero issue at the same time.

Reported-by: Oleg Drokin <green@linuxhacker.ru>
Cc: stable@vger.kernel.org
Signed-off-by: David Rientjes <rientjes@google.com>
---
 v3: remove needless ret = 0 assignment per Oleg
     rewrote changelog
     added stable@vger.kernel.org

 Documentation/sysctl/vm.txt |  3 ++-
 kernel/sysctl.c             |  3 +--
 mm/page_alloc.c             | 40 ++++++++++++++++++++++++++++------------
 3 files changed, 31 insertions(+), 15 deletions(-)

diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
--- a/Documentation/sysctl/vm.txt
+++ b/Documentation/sysctl/vm.txt
@@ -702,7 +702,8 @@ The batch value of each per cpu pagelist is also updated as a result.  It is
 set to pcp->high/4.  The upper limit of batch is (PAGE_SHIFT * 8)
 
 The initial value is zero.  Kernel does not use this value at boot time to set
-the high water marks for each per cpu page list.
+the high water marks for each per cpu page list.  If the user writes '0' to this
+sysctl, it will revert to this default behavior.
 
 ==============================================================
 
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -136,7 +136,6 @@ static unsigned long dirty_bytes_min = 2 * PAGE_SIZE;
 /* this is needed for the proc_dointvec_minmax for [fs_]overflow UID and GID */
 static int maxolduid = 65535;
 static int minolduid;
-static int min_percpu_pagelist_fract = 8;
 
 static int ngroups_max = NGROUPS_MAX;
 static const int cap_last_cap = CAP_LAST_CAP;
@@ -1328,7 +1327,7 @@ static struct ctl_table vm_table[] = {
 		.maxlen		= sizeof(percpu_pagelist_fraction),
 		.mode		= 0644,
 		.proc_handler	= percpu_pagelist_fraction_sysctl_handler,
-		.extra1		= &min_percpu_pagelist_fract,
+		.extra1		= &zero,
 	},
 #ifdef CONFIG_MMU
 	{
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -69,6 +69,7 @@
 
 /* prevent >1 _updater_ of zone percpu pageset ->high and ->batch fields */
 static DEFINE_MUTEX(pcp_batch_high_lock);
+#define MIN_PERCPU_PAGELIST_FRACTION	(8)
 
 #ifdef CONFIG_USE_PERCPU_NUMA_NODE_ID
 DEFINE_PER_CPU(int, numa_node);
@@ -4145,7 +4146,7 @@ static void __meminit zone_init_free_lists(struct zone *zone)
 	memmap_init_zone((size), (nid), (zone), (start_pfn), MEMMAP_EARLY)
 #endif
 
-static int __meminit zone_batchsize(struct zone *zone)
+static int zone_batchsize(struct zone *zone)
 {
 #ifdef CONFIG_MMU
 	int batch;
@@ -4261,8 +4262,8 @@ static void pageset_set_high(struct per_cpu_pageset *p,
 	pageset_update(&p->pcp, high, batch);
 }
 
-static void __meminit pageset_set_high_and_batch(struct zone *zone,
-		struct per_cpu_pageset *pcp)
+static void pageset_set_high_and_batch(struct zone *zone,
+				       struct per_cpu_pageset *pcp)
 {
 	if (percpu_pagelist_fraction)
 		pageset_set_high(pcp,
@@ -5881,23 +5882,38 @@ int percpu_pagelist_fraction_sysctl_handler(struct ctl_table *table, int write,
 	void __user *buffer, size_t *length, loff_t *ppos)
 {
 	struct zone *zone;
-	unsigned int cpu;
+	int old_percpu_pagelist_fraction;
 	int ret;
 
+	mutex_lock(&pcp_batch_high_lock);
+	old_percpu_pagelist_fraction = percpu_pagelist_fraction;
+
 	ret = proc_dointvec_minmax(table, write, buffer, length, ppos);
-	if (!write || (ret < 0))
-		return ret;
+	if (!write || ret < 0)
+		goto out;
+
+	/* Sanity checking to avoid pcp imbalance */
+	if (percpu_pagelist_fraction &&
+	    percpu_pagelist_fraction < MIN_PERCPU_PAGELIST_FRACTION) {
+		percpu_pagelist_fraction = old_percpu_pagelist_fraction;
+		ret = -EINVAL;
+		goto out;
+	}
+
+	/* No change? */
+	if (percpu_pagelist_fraction == old_percpu_pagelist_fraction)
+		goto out;
 
-	mutex_lock(&pcp_batch_high_lock);
 	for_each_populated_zone(zone) {
-		unsigned long  high;
-		high = zone->managed_pages / percpu_pagelist_fraction;
+		unsigned int cpu;
+
 		for_each_possible_cpu(cpu)
-			pageset_set_high(per_cpu_ptr(zone->pageset, cpu),
-					 high);
+			pageset_set_high_and_batch(zone,
+					per_cpu_ptr(zone->pageset, cpu));
 	}
+out:
 	mutex_unlock(&pcp_batch_high_lock);
-	return 0;
+	return ret;
 }
 
 int hashdist = HASHDIST_DEFAULT;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
