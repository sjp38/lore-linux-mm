Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 201416B0005
	for <linux-mm@kvack.org>; Wed, 22 Jun 2016 14:23:01 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id f126so8671439wma.3
        for <linux-mm@kvack.org>; Wed, 22 Jun 2016 11:23:01 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id k135si62435wmg.61.2016.06.22.11.22.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Jun 2016 11:23:00 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH] mm: fix vm-scalability regression in cgroup-aware workingset code
Date: Wed, 22 Jun 2016 14:20:19 -0400
Message-Id: <20160622182019.24064-1-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Ye Xiaolong <xiaolong.ye@intel.com>, Michal Hocko <mhocko@suse.cz>, Vladimir Davydov <vdavydov@virtuozzo.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

23047a96d7cf ("mm: workingset: per-cgroup cache thrash detection")
added a page->mem_cgroup lookup to the cache eviction, refault, and
activation paths, as well as locking to the activation path, and the
vm-scalability tests showed a regression of -23%. While the test in
question is an artificial worst-case scenario that doesn't occur in
real workloads - reading two sparse files in parallel at full CPU
speed just to hammer the LRU paths - there is still some optimizations
that can be done in those paths.

Inline the lookup functions to eliminate calls. Also, page->mem_cgroup
doesn't need to be stabilized when counting an activation; we merely
need to hold the RCU lock to prevent the memcg from being freed.

This cuts down on overhead quite a bit:

23047a96d7cfcfca 063f6715e77a7be5770d6081fe
---------------- --------------------------
         %stddev     %change         %stddev
             \          |                \
  21621405 A+-  0%     +11.3%   24069657 A+-  2%  vm-scalability.throughput

Reported-by: Ye Xiaolong <xiaolong.ye@intel.com>
Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 include/linux/memcontrol.h | 39 ++++++++++++++++++++++++++++++++++++++-
 include/linux/mm.h         |  8 ++++++++
 mm/memcontrol.c            | 39 ---------------------------------------
 mm/workingset.c            | 10 ++++++----
 4 files changed, 52 insertions(+), 44 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index a221663687d5..16609ab1a032 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -310,7 +310,44 @@ void mem_cgroup_uncharge_list(struct list_head *page_list);
 
 void mem_cgroup_migrate(struct page *oldpage, struct page *newpage);
 
-struct lruvec *mem_cgroup_lruvec(struct pglist_data *, struct mem_cgroup *);
+static inline struct mem_cgroup_per_node *
+mem_cgroup_nodeinfo(struct mem_cgroup *memcg, int nid)
+{
+	return memcg->nodeinfo[nid];
+}
+
+/**
+ * mem_cgroup_lruvec - get the lru list vector for a memcg node
+ * @node: node of the wanted lruvec
+ * @memcg: memcg of the wanted lruvec
+ *
+ * Returns the lru list vector holding pages for a given @node and @memcg.
+ * This can be the node lruvec, if the memory controller is disabled.
+ */
+static inline struct lruvec *mem_cgroup_lruvec(struct pglist_data *pgdat,
+					       struct mem_cgroup *memcg)
+{
+	struct mem_cgroup_per_node *mz;
+	struct lruvec *lruvec;
+
+	if (mem_cgroup_disabled()) {
+		lruvec = node_lruvec(pgdat);
+		goto out;
+	}
+
+	mz = mem_cgroup_nodeinfo(memcg, pgdat->node_id);
+	lruvec = &mz->lruvec;
+out:
+	/*
+	 * Since a node can be onlined after the mem_cgroup was created,
+	 * we have to be prepared to initialize lruvec->zone here;
+	 * and if offlined then reonlined, we need to reinitialize it.
+	 */
+	if (unlikely(lruvec->pgdat != pgdat))
+		lruvec->pgdat = pgdat;
+	return lruvec;
+}
+
 struct lruvec *mem_cgroup_page_lruvec(struct page *, struct pglist_data *);
 
 bool task_in_mem_cgroup(struct task_struct *task, struct mem_cgroup *memcg);
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 14de8810d02e..0f7a4d89b52a 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -978,11 +978,19 @@ static inline struct mem_cgroup *page_memcg(struct page *page)
 {
 	return page->mem_cgroup;
 }
+static inline struct mem_cgroup *page_memcg_rcu(struct page *page)
+{
+	return READ_ONCE(page->mem_cgroup);
+}
 #else
 static inline struct mem_cgroup *page_memcg(struct page *page)
 {
 	return NULL;
 }
+static inline struct mem_cgroup *page_memcg_rcu(struct page *page)
+{
+	return NULL;
+}
 #endif
 
 /*
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 2b6574a13d0e..603e9b030e46 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -319,12 +319,6 @@ EXPORT_SYMBOL(memcg_kmem_enabled_key);
 
 #endif /* !CONFIG_SLOB */
 
-static struct mem_cgroup_per_node *
-mem_cgroup_nodeinfo(struct mem_cgroup *memcg, int nid)
-{
-	return memcg->nodeinfo[nid];
-}
-
 /**
  * mem_cgroup_css_from_page - css of the memcg associated with a page
  * @page: page of interest
@@ -927,39 +921,6 @@ static void invalidate_reclaim_iterators(struct mem_cgroup *dead_memcg)
 	     iter = mem_cgroup_iter(NULL, iter, NULL))
 
 /**
- * mem_cgroup_lruvec - get the lru list vector for a node or a memcg zone
- * @node: node of the wanted lruvec
- * @memcg: memcg of the wanted lruvec
- *
- * Returns the lru list vector holding pages for a given @node or a given
- * @memcg and @zone. This can be the node lruvec, if the memory controller
- * is disabled.
- */
-struct lruvec *mem_cgroup_lruvec(struct pglist_data *pgdat,
-				 struct mem_cgroup *memcg)
-{
-	struct mem_cgroup_per_node *mz;
-	struct lruvec *lruvec;
-
-	if (mem_cgroup_disabled()) {
-		lruvec = node_lruvec(pgdat);
-		goto out;
-	}
-
-	mz = mem_cgroup_nodeinfo(memcg, pgdat->node_id);
-	lruvec = &mz->lruvec;
-out:
-	/*
-	 * Since a node can be onlined after the mem_cgroup was created,
-	 * we have to be prepared to initialize lruvec->zone here;
-	 * and if offlined then reonlined, we need to reinitialize it.
-	 */
-	if (unlikely(lruvec->pgdat != pgdat))
-		lruvec->pgdat = pgdat;
-	return lruvec;
-}
-
-/**
  * mem_cgroup_page_lruvec - return lruvec for isolating/putting an LRU page
  * @page: the page
  * @zone: zone of the page
diff --git a/mm/workingset.c b/mm/workingset.c
index 236493eaf480..d4c864066fde 100644
--- a/mm/workingset.c
+++ b/mm/workingset.c
@@ -302,9 +302,10 @@ bool workingset_refault(void *shadow)
  */
 void workingset_activation(struct page *page)
 {
+	struct mem_cgroup *memcg;
 	struct lruvec *lruvec;
 
-	lock_page_memcg(page);
+	rcu_read_lock();
 	/*
 	 * Filter non-memcg pages here, e.g. unmap can call
 	 * mark_page_accessed() on VDSO pages.
@@ -312,12 +313,13 @@ void workingset_activation(struct page *page)
 	 * XXX: See workingset_refault() - this should return
 	 * root_mem_cgroup even for !CONFIG_MEMCG.
 	 */
-	if (!mem_cgroup_disabled() && !page_memcg(page))
+	memcg = page_memcg_rcu(page);
+	if (!mem_cgroup_disabled() && !memcg)
 		goto out;
-	lruvec = mem_cgroup_lruvec(page_pgdat(page), page_memcg(page));
+	lruvec = mem_cgroup_lruvec(page_pgdat(page), memcg);
 	atomic_long_inc(&lruvec->inactive_age);
 out:
-	unlock_page_memcg(page);
+	rcu_read_unlock();
 }
 
 /*
-- 
2.8.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
