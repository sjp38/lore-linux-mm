Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f171.google.com (mail-ig0-f171.google.com [209.85.213.171])
	by kanga.kvack.org (Postfix) with ESMTP id 6D1826B0031
	for <linux-mm@kvack.org>; Tue,  3 Jun 2014 21:22:44 -0400 (EDT)
Received: by mail-ig0-f171.google.com with SMTP id c1so5717117igq.10
        for <linux-mm@kvack.org>; Tue, 03 Jun 2014 18:22:44 -0700 (PDT)
Received: from mail-ie0-x229.google.com (mail-ie0-x229.google.com [2607:f8b0:4001:c03::229])
        by mx.google.com with ESMTPS id ug2si31249350igc.6.2014.06.03.18.22.43
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 03 Jun 2014 18:22:43 -0700 (PDT)
Received: by mail-ie0-f169.google.com with SMTP id rp18so5444398iec.0
        for <linux-mm@kvack.org>; Tue, 03 Jun 2014 18:22:43 -0700 (PDT)
Date: Tue, 3 Jun 2014 18:22:41 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch] mm, pcp: allow restoring percpu_pagelist_fraction default
In-Reply-To: <2C763027-307F-4BC0-8C0A-7E3D5957A4DA@linuxhacker.ru>
Message-ID: <alpine.DEB.2.02.1406031819580.8682@chino.kir.corp.google.com>
References: <1399166883-514-1-git-send-email-green@linuxhacker.ru> <alpine.DEB.2.02.1406021837490.13072@chino.kir.corp.google.com> <B549468A-10FC-4897-8720-7C9FEC6FD03A@linuxhacker.ru> <alpine.DEB.2.02.1406022056300.20536@chino.kir.corp.google.com>
 <2C763027-307F-4BC0-8C0A-7E3D5957A4DA@linuxhacker.ru>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Oleg Drokin <green@linuxhacker.ru>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Cody P Schafer <cody@linux.vnet.ibm.com>, Randy Dunlap <rdunlap@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org, devel@driverdev.osuosl.org

If the percpu_pagelist_fraction sysctl is set by the user, it is 
impossible to restore it to the kernel default since the user cannot 
write 0 to the sysctl.

This patch allows the user to write 0 to restore the default behavior.  
It still requires a fraction equal to or larger than 8, however, as stated 
by the documentation for sanity.  If a value in the range [1, 7] is 
written, the sysctl will return EINVAL.

This also fixes a division by zero identified by Oleg that occurs if a 
write() occurs with zero length and the value hasn't been changed before 
(so that percpu_pagelist_fraction is still 0).

Reported-by: Oleg Drokin <green@linuxhacker.ru>
Cc: stable@vger.kernel.org
Signed-off-by: David Rientjes <rientjes@google.com>
---
 Documentation/sysctl/vm.txt |  3 ++-
 kernel/sysctl.c             |  3 +--
 mm/page_alloc.c             | 30 +++++++++++++++++++++---------
 3 files changed, 24 insertions(+), 12 deletions(-)

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
@@ -1305,7 +1304,7 @@ static struct ctl_table vm_table[] = {
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
@@ -4107,7 +4108,7 @@ static void __meminit zone_init_free_lists(struct zone *zone)
 	memmap_init_zone((size), (nid), (zone), (start_pfn), MEMMAP_EARLY)
 #endif
 
-static int __meminit zone_batchsize(struct zone *zone)
+static int zone_batchsize(struct zone *zone)
 {
 #ifdef CONFIG_MMU
 	int batch;
@@ -4223,8 +4224,8 @@ static void pageset_set_high(struct per_cpu_pageset *p,
 	pageset_update(&p->pcp, high, batch);
 }
 
-static void __meminit pageset_set_high_and_batch(struct zone *zone,
-		struct per_cpu_pageset *pcp)
+static void pageset_set_high_and_batch(struct zone *zone,
+				       struct per_cpu_pageset *pcp)
 {
 	if (percpu_pagelist_fraction)
 		pageset_set_high(pcp,
@@ -5849,21 +5850,32 @@ int lowmem_reserve_ratio_sysctl_handler(ctl_table *table, int write,
 int percpu_pagelist_fraction_sysctl_handler(ctl_table *table, int write,
 	void __user *buffer, size_t *length, loff_t *ppos)
 {
+	const int old_percpu_pagelist_fraction = percpu_pagelist_fraction;
 	struct zone *zone;
-	unsigned int cpu;
 	int ret;
 
 	ret = proc_dointvec_minmax(table, write, buffer, length, ppos);
-	if (!write || (ret < 0))
+	if (!write || ret < 0)
 		return ret;
 
+	/* Sanity checking to avoid pcp imbalance */
+	if (percpu_pagelist_fraction &&
+	    percpu_pagelist_fraction < MIN_PERCPU_PAGELIST_FRACTION) {
+		percpu_pagelist_fraction = old_percpu_pagelist_fraction;
+		return -EINVAL;
+	}
+
+	/* No change? */
+	if (percpu_pagelist_fraction == old_percpu_pagelist_fraction)
+		return 0;
+
 	mutex_lock(&pcp_batch_high_lock);
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
 	mutex_unlock(&pcp_batch_high_lock);
 	return 0;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
