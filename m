Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f43.google.com (mail-la0-f43.google.com [209.85.215.43])
	by kanga.kvack.org (Postfix) with ESMTP id 31A9E6B009C
	for <linux-mm@kvack.org>; Mon, 25 Nov 2013 07:07:54 -0500 (EST)
Received: by mail-la0-f43.google.com with SMTP id n7so3003964lam.30
        for <linux-mm@kvack.org>; Mon, 25 Nov 2013 04:07:53 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id le8si7462753lab.3.2013.11.25.04.07.52
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 25 Nov 2013 04:07:53 -0800 (PST)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH v11 10/15] memcg,list_lru: add function walking over all lists of a per-memcg LRU
Date: Mon, 25 Nov 2013 16:07:43 +0400
Message-ID: <8ee38a2dc85f9e8f4d06d0c747f4ccc4f9a5977f.1385377616.git.vdavydov@parallels.com>
In-Reply-To: <cover.1385377616.git.vdavydov@parallels.com>
References: <cover.1385377616.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mhocko@suse.cz
Cc: glommer@openvz.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, devel@openvz.org

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
Cc: Glauber Costa <glommer@openvz.org>
Cc: Dave Chinner <dchinner@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Rik van Riel <riel@redhat.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Hugh Dickins <hughd@google.com>
Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
---
 include/linux/list_lru.h |   21 ++++++++++++++++++
 mm/memcontrol.c          |   55 ++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 76 insertions(+)

diff --git a/include/linux/list_lru.h b/include/linux/list_lru.h
index b3b3b86..ce815cc 100644
--- a/include/linux/list_lru.h
+++ b/include/linux/list_lru.h
@@ -40,6 +40,16 @@ struct memcg_list_lru {
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
@@ -160,6 +170,10 @@ struct list_lru *
 mem_cgroup_list_lru(struct memcg_list_lru *lru, struct mem_cgroup *memcg);
 struct list_lru *
 mem_cgroup_kmem_list_lru(struct memcg_list_lru *lru, void *ptr);
+
+unsigned long
+memcg_list_lru_walk_all(struct memcg_list_lru *lru, list_lru_walk_cb isolate,
+			void *cb_arg, unsigned long nr_to_walk);
 #else
 static inline int memcg_list_lru_init(struct memcg_list_lru *lru)
 {
@@ -182,6 +196,13 @@ mem_cgroup_kmem_list_lru(struct memcg_list_lru *lru, void *ptr)
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
index 84f1ca3..7b4f420 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3915,16 +3915,30 @@ static int alloc_memcg_lru(struct memcg_list_lru *lru, int memcg_id)
 		return err;
 	}
 
+	smp_wmb();
 	VM_BUG_ON(lru->memcg_lrus[memcg_id]);
 	lru->memcg_lrus[memcg_id] = memcg_lru;
 	return 0;
 }
 
+static void memcg_lru_mark_dead(struct memcg_list_lru *lru, int memcg_id)
+{
+	struct list_lru *memcg_lru;
+	
+	BUG_ON(!lru->memcg_lrus);
+	memcg_lru = lru->memcg_lrus[memcg_id];
+	if (memcg_lru)
+		lru->memcg_lrus[memcg_id] = (void *)((unsigned long)memcg_lru |
+						     MEMCG_LIST_LRU_DEAD);
+}
+
 static void free_memcg_lru(struct memcg_list_lru *lru, int memcg_id)
 {
 	struct list_lru *memcg_lru = NULL;
 
 	swap(lru->memcg_lrus[memcg_id], memcg_lru);
+	memcg_lru = (void *)((unsigned long)memcg_lru &
+			     ~MEMCG_LIST_LRU_DEAD);
 	if (memcg_lru) {
 		list_lru_destroy(memcg_lru);
 		kfree(memcg_lru);
@@ -3958,6 +3972,17 @@ static void __memcg_destroy_all_lrus(int memcg_id)
 {
 	struct memcg_list_lru *lru;
 
+	/*
+	 * Mark all lru lists of this memcg as dead and free them only after a
+	 * grace period. This is to prevent functions iterating over memcg_lrus
+	 * arrays (e.g. memcg_list_lru_walk_all()) from dereferencing pointers
+	 * pointing to already freed data.
+	 */
+	list_for_each_entry(lru, &memcg_lrus_list, list)
+		memcg_lru_mark_dead(lru, memcg_id);
+
+	synchronize_rcu();
+
 	list_for_each_entry(lru, &memcg_lrus_list, list)
 		free_memcg_lru(lru, memcg_id);
 }
@@ -4124,6 +4149,36 @@ mem_cgroup_kmem_list_lru(struct memcg_list_lru *lru, void *ptr)
 	}
 	return mem_cgroup_list_lru(lru, memcg);
 }
+
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
 #else
 static inline void mem_cgroup_destroy_all_caches(struct mem_cgroup *memcg)
 {
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
