Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 7D51A8D0048
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 05:41:04 -0400 (EDT)
Message-Id: <20110328093957.602747084@suse.cz>
Date: Mon, 28 Mar 2011 11:40:00 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: [RFC 3/3] Do not shrink isolated groups from the global reclaim
References: <20110328093957.089007035@suse.cz>
Content-Disposition: inline; filename=memcg-do_not_reclaim_isolated_groups.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org

Pages charged for isolated mem cgroups are not placed on the global LRU
lists so they are protected from the reclaim in general. This is still not
enough as they still can get reclaimed during the soft hierarchical reclaim

balance_pgdat
	mem_cgroup_soft_limit_reclaim
		mem_cgroup_hierarchical_reclaim
			mem_cgroup_shrink_node_zone

Let's prevent from soft reclaim if the group isolated and let's defer its
balancing to try_to_free_mem_cgroup_pages called from charging paths. This
will make allocations for the group more oom-prone probably but the group
wanted to be isolated so we should give it as much of isolation as it gets
and let the proper memory usage to the group user.

Signed-off-by: Michal Hocko <mhocko@suse.cz>

---
 vmscan.c |   18 ++++++++++--------
 1 file changed, 10 insertions(+), 8 deletions(-)

Index: linux-2.6.38-rc8/mm/vmscan.c
===================================================================
--- linux-2.6.38-rc8.orig/mm/vmscan.c	2011-03-28 11:24:20.000000000 +0200
+++ linux-2.6.38-rc8/mm/vmscan.c	2011-03-28 11:24:38.000000000 +0200
@@ -2170,14 +2170,16 @@ unsigned long mem_cgroup_shrink_node_zon
 						      sc.may_writepage,
 						      sc.gfp_mask);
 
-	/*
-	 * NOTE: Although we can get the priority field, using it
-	 * here is not a good idea, since it limits the pages we can scan.
-	 * if we don't reclaim here, the shrink_zone from balance_pgdat
-	 * will pick up pages from other mem cgroup's as well. We hack
-	 * the priority and make it zero.
-	 */
-	shrink_zone(0, zone, &sc);
+	if (!is_mem_cgroup_isolated(mem)) {
+		/*
+		 * NOTE: Although we can get the priority field, using it
+		 * here is not a good idea, since it limits the pages we can scan.
+		 * if we don't reclaim here, the shrink_zone from balance_pgdat
+		 * will pick up pages from other mem cgroup's as well. We hack
+		 * the priority and make it zero.
+		 */
+		shrink_zone(0, zone, &sc);
+	}
 
 	trace_mm_vmscan_memcg_softlimit_reclaim_end(sc.nr_reclaimed);
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
