Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id 9B3DE6B0083
	for <linux-mm@kvack.org>; Fri, 29 May 2015 07:57:40 -0400 (EDT)
Received: by wicmx19 with SMTP id mx19so13943130wic.0
        for <linux-mm@kvack.org>; Fri, 29 May 2015 04:57:40 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id cq9si9245090wjc.42.2015.05.29.04.57.37
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 29 May 2015 04:57:37 -0700 (PDT)
From: Michal Hocko <mhocko@suse.cz>
Subject: [RFC -v2 3/7] memcg, mm: move mem_cgroup_select_victim_node into vmscan
Date: Fri, 29 May 2015 13:57:21 +0200
Message-Id: <1432900645-8856-4-git-send-email-mhocko@suse.cz>
In-Reply-To: <1432900645-8856-1-git-send-email-mhocko@suse.cz>
References: <1432900645-8856-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Oleg Nesterov <oleg@redhat.com>, Vladimir Davydov <vdavydov@parallels.com>, Greg Thelen <gthelen@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

We currently have only one caller of mem_cgroup_select_victim_node which
is sitting in mm/vmscan.c and which is already wrapped by CONFIG_MEMCG
ifdef. Now that we have struct mem_cgroup visible outside of
mm/memcontrol.c we can move the function and its dependencies there.
This even shrinks the code size by few bytes:

   text    data     bss     dec     hex filename
 478509   65806   26384  570699   8b54b mm/built-in.o.before
 478445   65806   26384  570635   8b50b mm/built-in.o.after

Signed-off-by: Michal Hocko <mhocko@suse.cz>
---
 include/linux/memcontrol.h |  6 ++-
 mm/memcontrol.c            | 99 +---------------------------------------------
 mm/vmscan.c                | 96 ++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 101 insertions(+), 100 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index c3993b1728f7..820067ae462e 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -349,11 +349,13 @@ static inline bool mem_cgroup_disabled(void)
 /*
  * For memory reclaim.
  */
-int mem_cgroup_select_victim_node(struct mem_cgroup *memcg);
-
 void mem_cgroup_update_lru_size(struct lruvec *lruvec, enum lru_list lru,
 		int nr_pages);
 
+unsigned long mem_cgroup_node_nr_lru_pages(struct mem_cgroup *memcg,
+						  int nid,
+						  unsigned int lru_mask);
+
 static inline bool mem_cgroup_lruvec_online(struct lruvec *lruvec)
 {
 	struct mem_cgroup_per_zone *mz;
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 198ce919911d..54600a6d23bc 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -673,7 +673,7 @@ static void mem_cgroup_charge_statistics(struct mem_cgroup *memcg,
 	__this_cpu_add(memcg->stat->nr_page_events, nr_pages);
 }
 
-static unsigned long mem_cgroup_node_nr_lru_pages(struct mem_cgroup *memcg,
+unsigned long mem_cgroup_node_nr_lru_pages(struct mem_cgroup *memcg,
 						  int nid,
 						  unsigned int lru_mask)
 {
@@ -1331,103 +1331,6 @@ static void mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
 	mutex_unlock(&oom_lock);
 }
 
-#if MAX_NUMNODES > 1
-
-/**
- * test_mem_cgroup_node_reclaimable
- * @memcg: the target memcg
- * @nid: the node ID to be checked.
- * @noswap : specify true here if the user wants flle only information.
- *
- * This function returns whether the specified memcg contains any
- * reclaimable pages on a node. Returns true if there are any reclaimable
- * pages in the node.
- */
-static bool test_mem_cgroup_node_reclaimable(struct mem_cgroup *memcg,
-		int nid, bool noswap)
-{
-	if (mem_cgroup_node_nr_lru_pages(memcg, nid, LRU_ALL_FILE))
-		return true;
-	if (noswap || !total_swap_pages)
-		return false;
-	if (mem_cgroup_node_nr_lru_pages(memcg, nid, LRU_ALL_ANON))
-		return true;
-	return false;
-
-}
-
-/*
- * Always updating the nodemask is not very good - even if we have an empty
- * list or the wrong list here, we can start from some node and traverse all
- * nodes based on the zonelist. So update the list loosely once per 10 secs.
- *
- */
-static void mem_cgroup_may_update_nodemask(struct mem_cgroup *memcg)
-{
-	int nid;
-	/*
-	 * numainfo_events > 0 means there was at least NUMAINFO_EVENTS_TARGET
-	 * pagein/pageout changes since the last update.
-	 */
-	if (!atomic_read(&memcg->numainfo_events))
-		return;
-	if (atomic_inc_return(&memcg->numainfo_updating) > 1)
-		return;
-
-	/* make a nodemask where this memcg uses memory from */
-	memcg->scan_nodes = node_states[N_MEMORY];
-
-	for_each_node_mask(nid, node_states[N_MEMORY]) {
-
-		if (!test_mem_cgroup_node_reclaimable(memcg, nid, false))
-			node_clear(nid, memcg->scan_nodes);
-	}
-
-	atomic_set(&memcg->numainfo_events, 0);
-	atomic_set(&memcg->numainfo_updating, 0);
-}
-
-/*
- * Selecting a node where we start reclaim from. Because what we need is just
- * reducing usage counter, start from anywhere is O,K. Considering
- * memory reclaim from current node, there are pros. and cons.
- *
- * Freeing memory from current node means freeing memory from a node which
- * we'll use or we've used. So, it may make LRU bad. And if several threads
- * hit limits, it will see a contention on a node. But freeing from remote
- * node means more costs for memory reclaim because of memory latency.
- *
- * Now, we use round-robin. Better algorithm is welcomed.
- */
-int mem_cgroup_select_victim_node(struct mem_cgroup *memcg)
-{
-	int node;
-
-	mem_cgroup_may_update_nodemask(memcg);
-	node = memcg->last_scanned_node;
-
-	node = next_node(node, memcg->scan_nodes);
-	if (node == MAX_NUMNODES)
-		node = first_node(memcg->scan_nodes);
-	/*
-	 * We call this when we hit limit, not when pages are added to LRU.
-	 * No LRU may hold pages because all pages are UNEVICTABLE or
-	 * memcg is too small and all pages are not on LRU. In that case,
-	 * we use curret node.
-	 */
-	if (unlikely(node == MAX_NUMNODES))
-		node = numa_node_id();
-
-	memcg->last_scanned_node = node;
-	return node;
-}
-#else
-int mem_cgroup_select_victim_node(struct mem_cgroup *memcg)
-{
-	return 0;
-}
-#endif
-
 static int mem_cgroup_soft_reclaim(struct mem_cgroup *root_memcg,
 				   struct zone *zone,
 				   gfp_t gfp_mask,
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 37e90db1520b..3b6e61ef5183 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2886,6 +2886,102 @@ unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *memcg,
 	return sc.nr_reclaimed;
 }
 
+#if MAX_NUMNODES > 1
+
+/**
+ * test_mem_cgroup_node_reclaimable
+ * @memcg: the target memcg
+ * @nid: the node ID to be checked.
+ * @noswap : specify true here if the user wants flle only information.
+ *
+ * This function returns whether the specified memcg contains any
+ * reclaimable pages on a node. Returns true if there are any reclaimable
+ * pages in the node.
+ */
+static bool test_mem_cgroup_node_reclaimable(struct mem_cgroup *memcg,
+		int nid, bool noswap)
+{
+	if (mem_cgroup_node_nr_lru_pages(memcg, nid, LRU_ALL_FILE))
+		return true;
+	if (noswap || !total_swap_pages)
+		return false;
+	if (mem_cgroup_node_nr_lru_pages(memcg, nid, LRU_ALL_ANON))
+		return true;
+	return false;
+
+}
+/*
+ * Always updating the nodemask is not very good - even if we have an empty
+ * list or the wrong list here, we can start from some node and traverse all
+ * nodes based on the zonelist. So update the list loosely once per 10 secs.
+ *
+ */
+static void mem_cgroup_may_update_nodemask(struct mem_cgroup *memcg)
+{
+	int nid;
+	/*
+	 * numainfo_events > 0 means there was at least NUMAINFO_EVENTS_TARGET
+	 * pagein/pageout changes since the last update.
+	 */
+	if (!atomic_read(&memcg->numainfo_events))
+		return;
+	if (atomic_inc_return(&memcg->numainfo_updating) > 1)
+		return;
+
+	/* make a nodemask where this memcg uses memory from */
+	memcg->scan_nodes = node_states[N_MEMORY];
+
+	for_each_node_mask(nid, node_states[N_MEMORY]) {
+
+		if (!test_mem_cgroup_node_reclaimable(memcg, nid, false))
+			node_clear(nid, memcg->scan_nodes);
+	}
+
+	atomic_set(&memcg->numainfo_events, 0);
+	atomic_set(&memcg->numainfo_updating, 0);
+}
+
+/*
+ * Selecting a node where we start reclaim from. Because what we need is just
+ * reducing usage counter, start from anywhere is O,K. Considering
+ * memory reclaim from current node, there are pros. and cons.
+ *
+ * Freeing memory from current node means freeing memory from a node which
+ * we'll use or we've used. So, it may make LRU bad. And if several threads
+ * hit limits, it will see a contention on a node. But freeing from remote
+ * node means more costs for memory reclaim because of memory latency.
+ *
+ * Now, we use round-robin. Better algorithm is welcomed.
+ */
+static int mem_cgroup_select_victim_node(struct mem_cgroup *memcg)
+{
+	int node;
+
+	mem_cgroup_may_update_nodemask(memcg);
+	node = memcg->last_scanned_node;
+
+	node = next_node(node, memcg->scan_nodes);
+	if (node == MAX_NUMNODES)
+		node = first_node(memcg->scan_nodes);
+	/*
+	 * We call this when we hit limit, not when pages are added to LRU.
+	 * No LRU may hold pages because all pages are UNEVICTABLE or
+	 * memcg is too small and all pages are not on LRU. In that case,
+	 * we use curret node.
+	 */
+	if (unlikely(node == MAX_NUMNODES))
+		node = numa_node_id();
+
+	memcg->last_scanned_node = node;
+	return node;
+}
+#else
+static int mem_cgroup_select_victim_node(struct mem_cgroup *memcg)
+{
+	return 0;
+}
+#endif
+
 unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *memcg,
 					   unsigned long nr_pages,
 					   gfp_t gfp_mask,
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
