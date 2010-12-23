Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 363126B0089
	for <linux-mm@kvack.org>; Thu, 23 Dec 2010 13:10:19 -0500 (EST)
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by e28smtp07.in.ibm.com (8.14.4/8.13.1) with ESMTP id oBNIAC5g012259
	for <linux-mm@kvack.org>; Thu, 23 Dec 2010 23:40:12 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id oBNIACfx4055064
	for <linux-mm@kvack.org>; Thu, 23 Dec 2010 23:40:12 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id oBNIABaT012323
	for <linux-mm@kvack.org>; Fri, 24 Dec 2010 05:10:12 +1100
Subject: [PATCH 1/3] Move zone_reclaim() outside of CONFIG_NUMA (v3)
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Date: Thu, 23 Dec 2010 23:40:01 +0530
Message-ID: <20101223180936.3278.24403.stgit@localhost6.localdomain6>
In-Reply-To: <20101223180022.3278.51404.stgit@localhost6.localdomain6>
References: <20101223180022.3278.51404.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, akpm@linux-foundation.org
Cc: npiggin@kernel.dk, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, minchan.kim@gmail.com, kosaki.motohiro@jp.fujitsu.com, cl@linux.com, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

This patch moves zone_reclaim and associated helpers
outside CONFIG_NUMA. This infrastructure is reused
in the patches for page cache control that follow.

Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
---
 include/linux/mmzone.h |    4 ++--
 include/linux/swap.h   |    4 ++--
 kernel/sysctl.c        |   18 +++++++++---------
 mm/vmscan.c            |    2 --
 4 files changed, 13 insertions(+), 15 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 4890662..aeede91 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -302,12 +302,12 @@ struct zone {
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
index 84375e4..ac5c06e 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -253,11 +253,11 @@ extern int vm_swappiness;
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
index a00fdef..e40040e 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -1211,15 +1211,6 @@ static struct ctl_table vm_table[] = {
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
@@ -1229,6 +1220,15 @@ static struct ctl_table vm_table[] = {
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
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 42a4859..e841cae 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2740,7 +2740,6 @@ static int __init kswapd_init(void)
 
 module_init(kswapd_init)
 
-#ifdef CONFIG_NUMA
 /*
  * Zone reclaim mode
  *
@@ -2950,7 +2949,6 @@ int zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
 
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
