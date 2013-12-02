Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f169.google.com (mail-lb0-f169.google.com [209.85.217.169])
	by kanga.kvack.org (Postfix) with ESMTP id 63BE86B0081
	for <linux-mm@kvack.org>; Mon,  2 Dec 2013 06:20:15 -0500 (EST)
Received: by mail-lb0-f169.google.com with SMTP id y6so8578501lbh.0
        for <linux-mm@kvack.org>; Mon, 02 Dec 2013 03:20:14 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id y2si26437378lbo.160.2013.12.02.03.20.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 02 Dec 2013 03:20:13 -0800 (PST)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH v12 11/18] memcg,list_lru: add function walking over all lists of a per-memcg LRU
Date: Mon, 2 Dec 2013 15:19:46 +0400
Message-ID: <9c79309f65b4c24bf09a17c588e0ffdf13be15d8.1385974612.git.vdavydov@parallels.com>
In-Reply-To: <cover.1385974612.git.vdavydov@parallels.com>
References: <cover.1385974612.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hannes@cmpxchg.org, mhocko@suse.cz, dchinner@redhat.com, akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, devel@openvz.org, glommer@openvz.org, vdavydov@parallels.com, Al Viro <viro@zeniv.linux.org.uk>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Sometimes it can be necessary to iterate over all memcgs' lists of the
same memcg-aware LRU. For example shrink_dcache_sb() should prune all
dentries no matter what memory cgroup they belong to. Current interface
to struct memcg_list_lru, however, only allows per-memcg LRU walks.
This patch adds the special method memcg_list_lru_walk_all() which
provides the required functionality. Note that this function does not
guarantee that all the elements will be processed in the true
least-recently-used order, in fact it simply enumerates all kmem-active
memcgs and for each of them calls list_lru_walk(), but
shrink_dcache_sb(), which is going to be the only user of this function,
does not need it.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Dave Chinner <dchinner@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>
Cc: Balbir Singh <bsingharora@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 include/linux/list_lru.h |   21 ++++++++++++++++
 mm/memcontrol.c          |   60 +++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 80 insertions(+), 1 deletion(-)

diff --git a/include/linux/list_lru.h b/include/linux/list_lru.h
index 2ad0bc6..a9e078a 100644
--- a/include/linux/list_lru.h
+++ b/include/linux/list_lru.h
@@ -46,6 +46,16 @@ struct memcg_list_lru {
 	struct list_lru **memcg_lrus;	/* rcu-protected array of per-memcg
 					   lrus, indexed by memcg_cache_id() */
 
+	/*
+	 * When a memory cgroup is removed, all pointers to its list_lru
+	 * objects stored in memcg_lrus arrays are first marked as dead by
+	 * setting the lowest bit of the address while the actual data free
+	 * happens only after an rcu grace period. If a memcg_lrus reader,
+	 * which should be rcu-protected, faces a dead pointer, it won't
+	 * dereference it. This ensures there will be no use-after-free.
+	 */
+#define MEMCG_LIST_LRU_DEAD		1
+
 	struct list_head list;		/* list of all memcg-aware lrus */
 
 	/*
@@ -166,6 +176,10 @@ struct list_lru *mem_cgroup_list_lru(struct memcg_list_lru *lru,
 				     struct mem_cgroup *memcg);
 struct list_lru *mem_cgroup_kmem_list_lru(struct memcg_list_lru *lru,
 					  void *ptr);
+
+unsigned long
+memcg_list_lru_walk_all(struct memcg_list_lru *lru, list_lru_walk_cb isolate,
+			void *cb_arg, unsigned long nr_to_walk);
 #else
 static inline int memcg_list_lru_init(struct memcg_list_lru *lru)
 {
@@ -188,6 +202,13 @@ mem_cgroup_kmem_list_lru(struct memcg_list_lru *lru, void *ptr)
 {
 	return &lru->global_lru;
 }
+
+static inline unsigned long
+memcg_list_lru_walk_all(struct memcg_list_lru *lru, list_lru_walk_cb isolate,
+			void *cb_arg, unsigned long nr_to_walk)
+{
+	return list_lru_walk(&lru->global_lru, isolate, cb_arg, nr_to_walk);
+}
 #endif /* CONFIG_MEMCG_KMEM */
 
 #endif /* _LRU_LIST_H */
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 253e01e..da06f91 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3088,6 +3088,7 @@ static int alloc_memcg_lru(struct memcg_list_lru *lru, int memcg_id)
 		return err;
 	}
 
+	smp_wmb();
 	VM_BUG_ON(lru->memcg_lrus[memcg_id]);
 	lru->memcg_lrus[memcg_id] = memcg_lru;
 	return 0;
@@ -3098,7 +3099,8 @@ static void free_memcg_lru(struct memcg_list_lru *lru, int memcg_id)
 {
 	struct list_lru *memcg_lru;
 
-	memcg_lru = lru->memcg_lrus[memcg_id];
+	memcg_lru = (void *)((unsigned long)lru->memcg_lrus[memcg_id] &
+			     ~MEMCG_LIST_LRU_DEAD);
 	if (memcg_lru) {
 		list_lru_destroy(memcg_lru);
 		kfree(memcg_lru);
@@ -3106,6 +3108,16 @@ static void free_memcg_lru(struct memcg_list_lru *lru, int memcg_id)
 	}
 }
 
+static void memcg_lru_mark_dead(struct memcg_list_lru *lru, int memcg_id)
+{
+	struct list_lru *memcg_lru;
+
+	memcg_lru = lru->memcg_lrus[memcg_id];
+	if (memcg_lru)
+		lru->memcg_lrus[memcg_id] = (void *)((unsigned long)memcg_lru |
+						     MEMCG_LIST_LRU_DEAD);
+}
+
 /*
  * Grows a per-memcg lru to acommodate list_lrus for new_num_memcg memory
  * cgroups. Is called for each per-memcg lru whenever a new kmem-enabled memcg
@@ -3141,6 +3153,17 @@ static void __memcg_destroy_all_lrus(int memcg_id)
 {
 	struct memcg_list_lru *lru;
 
+	/*
+	 * Mark all lru lists of this memcg as dead and free them only after a
+	 * grace period. This is to prevent functions iterating over memcg_lrus
+	 * arrays from dereferencing pointers pointing to already freed data
+	 * (see memcg_list_lru_walk_all()).
+	 */
+	list_for_each_entry(lru, &all_per_memcg_lrus, list)
+		memcg_lru_mark_dead(lru, memcg_id);
+
+	synchronize_rcu();
+
 	list_for_each_entry(lru, &all_per_memcg_lrus, list)
 		free_memcg_lru(lru, memcg_id);
 }
@@ -3340,6 +3363,41 @@ struct list_lru *mem_cgroup_kmem_list_lru(struct memcg_list_lru *lru,
 }
 
 /*
+ * This function calls the list_lru_walk() function for each list_lru
+ * comprising a per-memcg lru. It may be useful if one wants to scan all
+ * elements of a per-memcg lru, no matter in which order.
+ */
+unsigned long
+memcg_list_lru_walk_all(struct memcg_list_lru *lru, list_lru_walk_cb isolate,
+			void *cb_arg, unsigned long nr_to_walk)
+{
+	int i;
+	unsigned long isolated;
+	struct list_lru *memcg_lru;
+	struct list_lru **memcg_lrus;
+
+	isolated = list_lru_walk(&lru->global_lru, isolate, cb_arg, nr_to_walk);
+
+	rcu_read_lock();
+	memcg_lrus = rcu_dereference(lru->memcg_lrus);
+	for_each_memcg_cache_index(i) {
+		memcg_lru = memcg_lrus[i];
+		if (!memcg_lru)
+			continue;
+
+		if ((unsigned long)memcg_lru & MEMCG_LIST_LRU_DEAD)
+			continue;
+
+		smp_read_barrier_depends();
+		isolated += list_lru_walk(memcg_lru,
+					  isolate, cb_arg, nr_to_walk);
+	}
+	rcu_read_unlock();
+
+	return isolated;
+}
+
+/*
  * This is a bit cumbersome, but it is rarely used and avoids a backpointer
  * in the memcg_cache_params struct.
  */
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
