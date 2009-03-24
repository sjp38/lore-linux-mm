Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 963336B003D
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 22:27:56 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n2O2S41e000648
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 24 Mar 2009 11:28:04 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 25D4F45DE4F
	for <linux-mm@kvack.org>; Tue, 24 Mar 2009 11:28:04 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id C0FAB45DE52
	for <linux-mm@kvack.org>; Tue, 24 Mar 2009 11:28:03 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 96B281DB805A
	for <linux-mm@kvack.org>; Tue, 24 Mar 2009 11:28:03 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id E8B0F1DB805B
	for <linux-mm@kvack.org>; Tue, 24 Mar 2009 11:28:02 +0900 (JST)
Date: Tue, 24 Mar 2009 11:26:37 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH] fix vmscan to take care of nodemask v3
Message-Id: <20090324112637.2fc23361.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090324103139.07af98f1.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090323100356.e980d266.kamezawa.hiroyu@jp.fujitsu.com>
	<20090323114814.GB6484@csn.ul.ie>
	<20090324103139.07af98f1.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Mel Gorman <mel@csn.ul.ie>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, riel@redhat.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Thank you for all comments :)
-Kame
==
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

try_to_free_pages() is used for the direct reclaim of up to SWAP_CLUSTER_MAX
pages when watermarks are low. The caller to alloc_pages_nodemask() can
specify a nodemask of nodes that are allowed to be used but this is not
passed to try_to_free_pages(). This can lead to unnecessary reclaim of pages
that are unusable by the caller and int the worst case lead to allocation
failure as progress was not been make where it is needed.

This patch passes the nodemask used for alloc_pages_nodemask() to
try_to_free_pages().

Changelog: v2 -> v3
  - rewrote the patch description.
  - enhanced comment text.
  - added .nodemask = NULL for try_to_free_mem_cgroup_pages() to show the
    difference with try_to_free_pages().
Changelog: v1 -> v2
  - removed unnecessary nodemask=NULL initialization.

Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Acked-by: Mel Gorman <mel@csn.ul.ie>
Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 fs/buffer.c          |    2 +-
 include/linux/swap.h |    2 +-
 mm/page_alloc.c      |    3 ++-
 mm/vmscan.c          |   13 +++++++++++--
 4 files changed, 15 insertions(+), 5 deletions(-)

Index: mmotm-2.6.29-Mar21/mm/vmscan.c
===================================================================
--- mmotm-2.6.29-Mar21.orig/mm/vmscan.c
+++ mmotm-2.6.29-Mar21/mm/vmscan.c
@@ -79,6 +79,12 @@ struct scan_control {
 	/* Which cgroup do we reclaim from */
 	struct mem_cgroup *mem_cgroup;
 
+	/*
+	 * Nodemask of nodes allowed by the caller. If NULL, all nodes
+	 * are scanned.
+	 */
+	nodemask_t	*nodemask;
+
 	/* Pluggable isolate pages callback */
 	unsigned long (*isolate_pages)(unsigned long nr, struct list_head *dst,
 			unsigned long *scanned, int order, int mode,
@@ -1544,7 +1550,8 @@ static void shrink_zones(int priority, s
 	struct zone *zone;
 
 	sc->all_unreclaimable = 1;
-	for_each_zone_zonelist(zone, z, zonelist, high_zoneidx) {
+	for_each_zone_zonelist_nodemask(zone, z, zonelist, high_zoneidx,
+					sc->nodemask) {
 		if (!populated_zone(zone))
 			continue;
 		/*
@@ -1689,7 +1696,7 @@ out:
 }
 
 unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
-								gfp_t gfp_mask)
+				gfp_t gfp_mask, nodemask_t *nodemask)
 {
 	struct scan_control sc = {
 		.gfp_mask = gfp_mask,
@@ -1700,6 +1707,7 @@ unsigned long try_to_free_pages(struct z
 		.order = order,
 		.mem_cgroup = NULL,
 		.isolate_pages = isolate_pages_global,
+		.nodemask = nodemask,
 	};
 
 	return do_try_to_free_pages(zonelist, &sc);
@@ -1720,6 +1728,7 @@ unsigned long try_to_free_mem_cgroup_pag
 		.order = 0,
 		.mem_cgroup = mem_cont,
 		.isolate_pages = mem_cgroup_isolate_pages,
+		.nodemask = NULL, /* we don't care the placement */
 	};
 	struct zonelist *zonelist;
 
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
