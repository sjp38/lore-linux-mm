Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 6A5638D0048
	for <linux-mm@kvack.org>; Tue,  1 Feb 2011 11:55:32 -0500 (EST)
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by e28smtp04.in.ibm.com (8.14.4/8.13.1) with ESMTP id p11GtCOi004915
	for <linux-mm@kvack.org>; Tue, 1 Feb 2011 22:25:12 +0530
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p11GtCk54063264
	for <linux-mm@kvack.org>; Tue, 1 Feb 2011 22:25:12 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p11GtBZq007949
	for <linux-mm@kvack.org>; Wed, 2 Feb 2011 03:55:11 +1100
Subject: [PATCH 1/3][RESEND] Move zone_reclaim() outside of CONFIG_NUMA (v4)
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Date: Tue, 01 Feb 2011 22:25:02 +0530
Message-ID: <20110201165447.12377.96481.stgit@localhost6.localdomain6>
In-Reply-To: <20110201165329.12377.13683.stgit@localhost6.localdomain6>
References: <20110201165329.12377.13683.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, akpm@linux-foundation.org
Cc: npiggin@kernel.dk, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, kosaki.motohiro@jp.fujitsu.com, cl@linux.com, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

This patch moves zone_reclaim and associated helpers
outside CONFIG_NUMA. This infrastructure is reused
in the patches for page cache control that follow.

Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
Reviewed-by: Christoph Lameter <cl@linux.com>
---
 include/linux/mmzone.h |    4 ++--
 include/linux/swap.h   |    4 ++--
 kernel/sysctl.c        |   18 +++++++++---------
 mm/page_alloc.c        |    6 +++---
 mm/vmscan.c            |    2 --
 5 files changed, 16 insertions(+), 18 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 02ecb01..2485acc 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -303,12 +303,12 @@ struct zone {
 	 */
 	unsigned long		lowmem_reserve[MAX_NR_ZONES];
 
-#ifdef CONFIG_NUMA
-	int node;
 	/*
 	 * zone reclaim becomes active if more unmapped pages exist.
 	 */
 	unsigned long		min_unmapped_pages;
+#ifdef CONFIG_NUMA
+	int node;
 	unsigned long		min_slab_pages;
 #endif
 	struct per_cpu_pageset __percpu *pageset;
diff --git a/include/linux/swap.h b/include/linux/swap.h
index 5e3355a..7b75626 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -255,11 +255,11 @@ extern int vm_swappiness;
 extern int remove_mapping(struct address_space *mapping, struct page *page);
 extern long vm_total_pages;
 
+extern int sysctl_min_unmapped_ratio;
+extern int zone_reclaim(struct zone *, gfp_t, unsigned int);
 #ifdef CONFIG_NUMA
 extern int zone_reclaim_mode;
-extern int sysctl_min_unmapped_ratio;
 extern int sysctl_min_slab_ratio;
-extern int zone_reclaim(struct zone *, gfp_t, unsigned int);
 #else
 #define zone_reclaim_mode 0
 static inline int zone_reclaim(struct zone *z, gfp_t mask, unsigned int order)
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index bc86bb3..12e8f26 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -1224,15 +1224,6 @@ static struct ctl_table vm_table[] = {
 		.extra1		= &zero,
 	},
 #endif
-#ifdef CONFIG_NUMA
-	{
-		.procname	= "zone_reclaim_mode",
-		.data		= &zone_reclaim_mode,
-		.maxlen		= sizeof(zone_reclaim_mode),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec,
-		.extra1		= &zero,
-	},
 	{
 		.procname	= "min_unmapped_ratio",
 		.data		= &sysctl_min_unmapped_ratio,
@@ -1242,6 +1233,15 @@ static struct ctl_table vm_table[] = {
 		.extra1		= &zero,
 		.extra2		= &one_hundred,
 	},
+#ifdef CONFIG_NUMA
+	{
+		.procname	= "zone_reclaim_mode",
+		.data		= &zone_reclaim_mode,
+		.maxlen		= sizeof(zone_reclaim_mode),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+		.extra1		= &zero,
+	},
 	{
 		.procname	= "min_slab_ratio",
 		.data		= &sysctl_min_slab_ratio,
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index aede3a4..7b56473 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4167,10 +4167,10 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat,
 
 		zone->spanned_pages = size;
 		zone->present_pages = realsize;
-#ifdef CONFIG_NUMA
-		zone->node = nid;
 		zone->min_unmapped_pages = (realsize*sysctl_min_unmapped_ratio)
 						/ 100;
+#ifdef CONFIG_NUMA
+		zone->node = nid;
 		zone->min_slab_pages = (realsize * sysctl_min_slab_ratio) / 100;
 #endif
 		zone->name = zone_names[j];
@@ -5084,7 +5084,6 @@ int min_free_kbytes_sysctl_handler(ctl_table *table, int write,
 	return 0;
 }
 
-#ifdef CONFIG_NUMA
 int sysctl_min_unmapped_ratio_sysctl_handler(ctl_table *table, int write,
 	void __user *buffer, size_t *length, loff_t *ppos)
 {
@@ -5101,6 +5100,7 @@ int sysctl_min_unmapped_ratio_sysctl_handler(ctl_table *table, int write,
 	return 0;
 }
 
+#ifdef CONFIG_NUMA
 int sysctl_min_slab_ratio_sysctl_handler(ctl_table *table, int write,
 	void __user *buffer, size_t *length, loff_t *ppos)
 {
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 47a5096..5899f2f 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2868,7 +2868,6 @@ static int __init kswapd_init(void)
 
 module_init(kswapd_init)
 
-#ifdef CONFIG_NUMA
 /*
  * Zone reclaim mode
  *
@@ -3078,7 +3077,6 @@ int zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
 
 	return ret;
 }
-#endif
 
 /*
  * page_evictable - test whether a page is evictable

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
