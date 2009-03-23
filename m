Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 3AFD86B0047
	for <linux-mm@kvack.org>; Sun, 22 Mar 2009 20:11:20 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n2N15NAZ004275
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 23 Mar 2009 10:05:23 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id E967E45DE55
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 10:05:22 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id C19FE45DE51
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 10:05:22 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id A417EE38005
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 10:05:22 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 4921A1DB803C
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 10:05:22 +0900 (JST)
Date: Mon, 23 Mar 2009 10:03:56 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH] fix vmscan to take care of nodemask
Message-Id: <20090323100356.e980d266.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, mel@csn.ul.ie, riel@redhat.com"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

try_to_free_pages() scans zonelist but doesn't take care of nodemask which is
passed to alloc_pages_nodemask(). This makes try_to_free_pages() less effective.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 fs/buffer.c          |    2 +-
 include/linux/swap.h |    2 +-
 mm/page_alloc.c      |    3 ++-
 mm/vmscan.c          |   14 ++++++++++++--
 4 files changed, 16 insertions(+), 5 deletions(-)

Index: mmotm-2.6.29-Mar21/mm/vmscan.c
===================================================================
--- mmotm-2.6.29-Mar21.orig/mm/vmscan.c
+++ mmotm-2.6.29-Mar21/mm/vmscan.c
@@ -79,6 +79,9 @@ struct scan_control {
 	/* Which cgroup do we reclaim from */
 	struct mem_cgroup *mem_cgroup;
 
+	/* Nodemask */
+	nodemask_t	*nodemask;
+
 	/* Pluggable isolate pages callback */
 	unsigned long (*isolate_pages)(unsigned long nr, struct list_head *dst,
 			unsigned long *scanned, int order, int mode,
@@ -1544,7 +1547,9 @@ static void shrink_zones(int priority, s
 	struct zone *zone;
 
 	sc->all_unreclaimable = 1;
-	for_each_zone_zonelist(zone, z, zonelist, high_zoneidx) {
+	/* Note: sc->nodemask==NULL means scan all node */
+	for_each_zone_zonelist_nodemask(zone, z, zonelist, high_zoneidx,
+					sc->nodemask) {
 		if (!populated_zone(zone))
 			continue;
 		/*
@@ -1689,7 +1694,7 @@ out:
 }
 
 unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
-								gfp_t gfp_mask)
+				gfp_t gfp_mask, nodemask_t *nodemask)
 {
 	struct scan_control sc = {
 		.gfp_mask = gfp_mask,
@@ -1700,6 +1705,7 @@ unsigned long try_to_free_pages(struct z
 		.order = order,
 		.mem_cgroup = NULL,
 		.isolate_pages = isolate_pages_global,
+		.nodemask = nodemask,
 	};
 
 	return do_try_to_free_pages(zonelist, &sc);
@@ -1720,6 +1726,7 @@ unsigned long try_to_free_mem_cgroup_pag
 		.order = 0,
 		.mem_cgroup = mem_cont,
 		.isolate_pages = mem_cgroup_isolate_pages,
+		.nodemask = NULL,
 	};
 	struct zonelist *zonelist;
 
@@ -1769,6 +1776,7 @@ static unsigned long balance_pgdat(pg_da
 		.order = order,
 		.mem_cgroup = NULL,
 		.isolate_pages = isolate_pages_global,
+		.nodemask = NULL,
 	};
 	/*
 	 * temp_priority is used to remember the scanning priority at which
@@ -2112,6 +2120,7 @@ unsigned long shrink_all_memory(unsigned
 		.may_unmap = 0,
 		.may_writepage = 1,
 		.isolate_pages = isolate_pages_global,
+		.nodemask = NULL,
 	};
 
 	current->reclaim_state = &reclaim_state;
@@ -2298,6 +2307,7 @@ static int __zone_reclaim(struct zone *z
 		.swappiness = vm_swappiness,
 		.order = order,
 		.isolate_pages = isolate_pages_global,
+		.nodemask = NULL,
 	};
 	unsigned long slab_reclaimable;
 
Index: mmotm-2.6.29-Mar21/include/linux/swap.h
===================================================================
--- mmotm-2.6.29-Mar21.orig/include/linux/swap.h
+++ mmotm-2.6.29-Mar21/include/linux/swap.h
@@ -213,7 +213,7 @@ static inline void lru_cache_add_active_
 
 /* linux/mm/vmscan.c */
 extern unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
-					gfp_t gfp_mask);
+					gfp_t gfp_mask, nodemask_t *mask);
 extern unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem,
 						  gfp_t gfp_mask, bool noswap,
 						  unsigned int swappiness);
Index: mmotm-2.6.29-Mar21/mm/page_alloc.c
===================================================================
--- mmotm-2.6.29-Mar21.orig/mm/page_alloc.c
+++ mmotm-2.6.29-Mar21/mm/page_alloc.c
@@ -1598,7 +1598,8 @@ nofail_alloc:
 	reclaim_state.reclaimed_slab = 0;
 	p->reclaim_state = &reclaim_state;
 
-	did_some_progress = try_to_free_pages(zonelist, order, gfp_mask);
+	did_some_progress = try_to_free_pages(zonelist, order,
+						gfp_mask, nodemask);
 
 	p->reclaim_state = NULL;
 	lockdep_clear_current_reclaim_state();
Index: mmotm-2.6.29-Mar21/fs/buffer.c
===================================================================
--- mmotm-2.6.29-Mar21.orig/fs/buffer.c
+++ mmotm-2.6.29-Mar21/fs/buffer.c
@@ -476,7 +476,7 @@ static void free_more_memory(void)
 						&zone);
 		if (zone)
 			try_to_free_pages(node_zonelist(nid, GFP_NOFS), 0,
-						GFP_NOFS);
+						GFP_NOFS, NULL);
 	}
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
