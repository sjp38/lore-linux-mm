Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2BDBF6B0005
	for <linux-mm@kvack.org>; Fri, 24 Jun 2016 13:53:37 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id a66so25469749wme.1
        for <linux-mm@kvack.org>; Fri, 24 Jun 2016 10:53:37 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id w7si8793778wjf.146.2016.06.24.10.53.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Jun 2016 10:53:35 -0700 (PDT)
Date: Fri, 24 Jun 2016 13:51:01 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH rebase] mm: fix vm-scalability regression in cgroup-aware
 workingset code
Message-ID: <20160624175101.GA3024@cmpxchg.org>
References: <20160622182019.24064-1-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160622182019.24064-1-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Ye Xiaolong <xiaolong.ye@intel.com>, Michal Hocko <mhocko@suse.cz>, Vladimir Davydov <vdavydov@virtuozzo.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

This is a rebased version on top of mmots sans the nodelru stuff.

---

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
  21621405 +- 0%     +11.3%   24069657 +- 2%  vm-scalability.throughput

Reported-by: Ye Xiaolong <xiaolong.ye@intel.com>
Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 include/linux/memcontrol.h | 44 +++++++++++++++++++++++++++++++++++++++++++-
 include/linux/mm.h         |  8 ++++++++
 mm/memcontrol.c            | 42 ------------------------------------------
 mm/workingset.c            | 10 ++++++----
 4 files changed, 57 insertions(+), 47 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 71aff733a497..104efa6874db 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -29,6 +29,7 @@
 #include <linux/mmzone.h>
 #include <linux/writeback.h>
 #include <linux/page-flags.h>
+#include <linux/mm.h>
 
 struct mem_cgroup;
 struct page;
@@ -314,7 +315,48 @@ void mem_cgroup_uncharge_list(struct list_head *page_list);
 
 void mem_cgroup_migrate(struct page *oldpage, struct page *newpage);
 
-struct lruvec *mem_cgroup_zone_lruvec(struct zone *, struct mem_cgroup *);
+static inline struct mem_cgroup_per_zone *
+mem_cgroup_zone_zoneinfo(struct mem_cgroup *memcg, struct zone *zone)
+{
+	int nid = zone_to_nid(zone);
+	int zid = zone_idx(zone);
+
+	return &memcg->nodeinfo[nid]->zoneinfo[zid];
+}
+
+/**
+ * mem_cgroup_zone_lruvec - get the lru list vector for a zone and memcg
+ * @zone: zone of the wanted lruvec
+ * @memcg: memcg of the wanted lruvec
+ *
+ * Returns the lru list vector holding pages for the given @zone and
+ * @mem.  This can be the global zone lruvec, if the memory controller
+ * is disabled.
+ */
+static inline struct lruvec *mem_cgroup_zone_lruvec(struct zone *zone,
+						    struct mem_cgroup *memcg)
+{
+	struct mem_cgroup_per_zone *mz;
+	struct lruvec *lruvec;
+
+	if (mem_cgroup_disabled()) {
+		lruvec = &zone->lruvec;
+		goto out;
+	}
+
+	mz = mem_cgroup_zone_zoneinfo(memcg, zone);
+	lruvec = &mz->lruvec;
+out:
+	/*
+	 * Since a node can be onlined after the mem_cgroup was created,
+	 * we have to be prepared to initialize lruvec->zone here;
+	 * and if offlined then reonlined, we need to reinitialize it.
+	 */
+	if (unlikely(lruvec->zone != zone))
+		lruvec->zone = zone;
+	return lruvec;
+}
+
 struct lruvec *mem_cgroup_page_lruvec(struct page *, struct zone *);
 
 bool task_in_mem_cgroup(struct task_struct *task, struct mem_cgroup *memcg);
diff --git a/include/linux/mm.h b/include/linux/mm.h
index c606fe4f9a7f..b21e5f30378e 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -973,11 +973,19 @@ static inline struct mem_cgroup *page_memcg(struct page *page)
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
index 3e8f9e5e9291..40dfca3ef4bb 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -323,15 +323,6 @@ EXPORT_SYMBOL(memcg_kmem_enabled_key);
 
 #endif /* !CONFIG_SLOB */
 
-static struct mem_cgroup_per_zone *
-mem_cgroup_zone_zoneinfo(struct mem_cgroup *memcg, struct zone *zone)
-{
-	int nid = zone_to_nid(zone);
-	int zid = zone_idx(zone);
-
-	return &memcg->nodeinfo[nid]->zoneinfo[zid];
-}
-
 /**
  * mem_cgroup_css_from_page - css of the memcg associated with a page
  * @page: page of interest
@@ -944,39 +935,6 @@ static void invalidate_reclaim_iterators(struct mem_cgroup *dead_memcg)
 	     iter = mem_cgroup_iter(NULL, iter, NULL))
 
 /**
- * mem_cgroup_zone_lruvec - get the lru list vector for a zone and memcg
- * @zone: zone of the wanted lruvec
- * @memcg: memcg of the wanted lruvec
- *
- * Returns the lru list vector holding pages for the given @zone and
- * @mem.  This can be the global zone lruvec, if the memory controller
- * is disabled.
- */
-struct lruvec *mem_cgroup_zone_lruvec(struct zone *zone,
-				      struct mem_cgroup *memcg)
-{
-	struct mem_cgroup_per_zone *mz;
-	struct lruvec *lruvec;
-
-	if (mem_cgroup_disabled()) {
-		lruvec = &zone->lruvec;
-		goto out;
-	}
-
-	mz = mem_cgroup_zone_zoneinfo(memcg, zone);
-	lruvec = &mz->lruvec;
-out:
-	/*
-	 * Since a node can be onlined after the mem_cgroup was created,
-	 * we have to be prepared to initialize lruvec->zone here;
-	 * and if offlined then reonlined, we need to reinitialize it.
-	 */
-	if (unlikely(lruvec->zone != zone))
-		lruvec->zone = zone;
-	return lruvec;
-}
-
-/**
  * mem_cgroup_page_lruvec - return lruvec for isolating/putting an LRU page
  * @page: the page
  * @zone: zone of the page
diff --git a/mm/workingset.c b/mm/workingset.c
index 8a75f8d2916a..8252de4566e9 100644
--- a/mm/workingset.c
+++ b/mm/workingset.c
@@ -305,9 +305,10 @@ bool workingset_refault(void *shadow)
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
@@ -315,12 +316,13 @@ void workingset_activation(struct page *page)
 	 * XXX: See workingset_refault() - this should return
 	 * root_mem_cgroup even for !CONFIG_MEMCG.
 	 */
-	if (!mem_cgroup_disabled() && !page_memcg(page))
+	memcg = page_memcg_rcu(page);
+	if (!mem_cgroup_disabled() && !memcg)
 		goto out;
-	lruvec = mem_cgroup_zone_lruvec(page_zone(page), page_memcg(page));
+	lruvec = mem_cgroup_zone_lruvec(page_zone(page), memcg);
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
