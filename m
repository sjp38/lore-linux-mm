Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id C42266B0082
	for <linux-mm@kvack.org>; Fri, 29 Mar 2013 05:15:18 -0400 (EDT)
From: Glauber Costa <glommer@parallels.com>
Subject: [PATCH v2 27/28] list_lru: reclaim proportionaly between memcgs and nodes
Date: Fri, 29 Mar 2013 13:14:09 +0400
Message-Id: <1364548450-28254-28-git-send-email-glommer@parallels.com>
In-Reply-To: <1364548450-28254-1-git-send-email-glommer@parallels.com>
References: <1364548450-28254-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-fsdevel@vger.kernel.org, containers@lists.linux-foundation.org, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, kamezawa.hiroyu@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Dave Shrinnker <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, hughd@google.com, yinghan@google.com, Glauber Costa <glommer@parallels.com>, Dave Chinner <dchinner@redhat.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>

The current list_lru code will try to scan objects until nr_to_walk is
reached, and then stop. This number can be different from the total
number of objects we have as returned by our count function. This is
because the main shrinker driver is the one ultimately responsible for
determining how many objects to shrink from each shrinker.

Specially if this number is lower than the number of objects, and
because we transverse the list always in the same order, we can have
the last node and/or the last memcg always being less penalized than
the others.

My proposed solution is to introduce some metric of proportionality
based on the total number of objects per node and then scan all nodes
and memcgs up until their share is reached.

Signed-off-by: Glauber Costa <glommer@parallels.com>
Cc: Dave Chinner <dchinner@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Rik van Riel <riel@redhat.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Hugh Dickins <hughd@google.com>
Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
---
 lib/list_lru.c | 96 ++++++++++++++++++++++++++++++++++++++++++++++++++--------
 1 file changed, 83 insertions(+), 13 deletions(-)

diff --git a/lib/list_lru.c b/lib/list_lru.c
index a49a9b5..af67725 100644
--- a/lib/list_lru.c
+++ b/lib/list_lru.c
@@ -177,6 +177,43 @@ restart:
 	return isolated;
 }
 
+static long
+memcg_isolate_lru(
+	struct list_lru	*lru,
+	list_lru_walk_cb isolate,
+	void		*cb_arg,
+	long		nr_to_walk,
+	struct mem_cgroup *memcg,
+	int nid, unsigned long total_node)
+{
+	int memcg_id = memcg_cache_id(memcg);
+	unsigned long nr_to_walk_this;
+	long isolated = 0;
+	int idx;
+	struct list_lru_node *nlru;
+
+	for_each_memcg_lru_index(idx, memcg_id) {
+		nlru = lru_node_of_index(lru, idx, nid);
+		if (!nlru || !nlru->nr_items)
+			continue;
+
+		/*
+		 * no memcg: walk every memcg proportionally.
+		 * memcg case: scan everything (total_node)
+		 */
+		if (!memcg)
+			nr_to_walk_this = mult_frac(nlru->nr_items, nr_to_walk,
+						    total_node);
+		else
+			nr_to_walk_this = total_node;
+
+		isolated += list_lru_walk_node(lru, nlru, nid, isolate,
+				       cb_arg, &nr_to_walk_this);
+	}
+
+	return isolated;
+}
+
 long
 list_lru_walk_nodemask_memcg(
 	struct list_lru	*lru,
@@ -189,9 +226,7 @@ list_lru_walk_nodemask_memcg(
 	long isolated = 0;
 	int nid;
 	nodemask_t nodes;
-	int memcg_id = memcg_cache_id(memcg);
-	int idx;
-	struct list_lru_node *nlru;
+	unsigned long n_node, total_node, total = 0;
 
 	/*
 	 * Conservative code can call this setting nodes with node_setall.
@@ -199,17 +234,52 @@ list_lru_walk_nodemask_memcg(
 	 */
 	nodes_and(nodes, *nodes_to_walk, node_online_map);
 
+	/*
+	 * We will first find out how many objects there are in the LRU, in
+	 * total. We could store that in a per-LRU counter as well, the same
+	 * way we store it in a per-NLRU. But lru_add and lru_del are way more
+	 * frequent operations, so it is better to pay the price here.
+	 *
+	 * Once we have that number, we will try to scan the nodes
+	 * proportionally to the amount of objects they have. The main shrinker
+	 * driver in vmscan.c will often ask us to shrink a quantity different
+	 * from the total quantity we reported in the count function (usually
+	 * less). This means that not scanning proportionally may leave nodes
+	 * (usually the last), unfairly charged.
+	 *
+	 * The final number we want is
+	 *
+	 * n_node = nr_to_scan * total_node / total
+	 */
+	for_each_node_mask(nid, nodes)
+		total += atomic_long_read(&lru->node_totals[nid]);
+
 	for_each_node_mask(nid, nodes) {
-		for_each_memcg_lru_index(idx, memcg_id) {
-			nlru = lru_node_of_index(lru, idx, nid);
-			if (!nlru)
-				continue;
-
-			isolated += list_lru_walk_node(lru, nlru, nid, isolate,
-						       cb_arg, &nr_to_walk);
-			if (nr_to_walk <= 0)
-				break;
-		}
+		total_node = atomic_long_read(&lru->node_totals[nid]);
+		if (!total_node)
+			continue;
+
+		 /*
+		  * There are items, but in less proportion. Because we have no
+		  * information about where exactly the pressure originates
+		  * from, it is better to try shrinking the few we have than to
+		  * skip it.  It might very well be that this node is under
+		  * pressure and any help would be welcome.
+		  */
+		n_node = mult_frac(total_node, nr_to_walk, total);
+		if (!n_node)
+			n_node = total_node;
+
+		/*
+		 * We will now scan all memcg-like entities (which includes the
+		 * global LRU, of index -1, and also try to mantain
+		 * proportionality among them.
+		 *
+		 * We will try to isolate:
+		 *	nr_memcg = n_node * nr_memcg_lru / total_node
+		 */
+		isolated += memcg_isolate_lru(lru, isolate, cb_arg,
+				      n_node, memcg, nid, total_node);
 	}
 	return isolated;
 }
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
