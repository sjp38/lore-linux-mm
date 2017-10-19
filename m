Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id BF0806B0038
	for <linux-mm@kvack.org>; Thu, 19 Oct 2017 16:03:53 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id 76so6755422pfr.3
        for <linux-mm@kvack.org>; Thu, 19 Oct 2017 13:03:53 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id v126sor237935pgb.31.2017.10.19.13.03.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 19 Oct 2017 13:03:52 -0700 (PDT)
From: Neha Agarwal <nehaagarwal@google.com>
Subject: [RFC PATCH] mm, thp: make deferred_split_shrinker memcg-aware
Date: Thu, 19 Oct 2017 13:03:23 -0700
Message-Id: <20171019200323.42491-1-nehaagarwal@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Dan Williams <dan.j.williams@intel.com>, David Rientjes <rientjes@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, Kemi Wang <kemi.wang@intel.com>, Neha Agarwal <nehaagarwal@google.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Shaohua Li <shli@fb.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org

deferred_split_shrinker is NUMA aware. Making it memcg-aware if
CONFIG_MEMCG is enabled to prevent shrinking memory of memcg(s) that are
not under memory pressure. This change isolates memory pressure across
memcgs from deferred_split_shrinker perspective, by not prematurely
splitting huge pages for the memcg that is not under memory pressure.

Note that a pte-mapped compound huge page charge is not moved to the dst
memcg on task migration. Look mem_cgroup_move_charge_pte_range() for
more information. Thus, mem_cgroup_move_account doesn't get called on
pte-mapped compound huge pages, hence we do not need to transfer the
page from source-memcg's split to destinations-memcg's split_queue.

Tested: Ran two copies of a microbenchmark with partially unmapped
thp(s) in two separate memory cgroups. When first memory cgroup is put
under memory pressure, it's own thp(s) split. Other memcg's thp(s)
remain intact.

Current implementation is not NUMA aware if MEMCG is compiled. If it is
important to have this shrinker both NUMA and MEMCG aware, I can work on
that.  Some feedback on this front will be useful.

Signed-off-by: Neha Agarwal <nehaagarwal@google.com>
---
 include/linux/huge_mm.h    |   1 +
 include/linux/memcontrol.h |   5 ++
 include/linux/mmzone.h     |   9 ++--
 include/linux/shrinker.h   |  19 +++++++
 mm/huge_memory.c           | 124 ++++++++++++++++++++++++++++++++++++---------
 mm/memcontrol.c            |  21 ++++++++
 mm/page_alloc.c            |   8 ++-
 7 files changed, 153 insertions(+), 34 deletions(-)

diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index 14bc21c2ee7f..06b26bdb1295 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -130,6 +130,7 @@ extern unsigned long thp_get_unmapped_area(struct file *filp,
 		unsigned long addr, unsigned long len, unsigned long pgoff,
 		unsigned long flags);
 
+extern struct list_head *page_deferred_list(struct page *page);
 extern void prep_transhuge_page(struct page *page);
 extern void free_transhuge_page(struct page *page);
 
diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 69966c461d1c..bbe8d0a3830a 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -30,6 +30,7 @@
 #include <linux/vmstat.h>
 #include <linux/writeback.h>
 #include <linux/page-flags.h>
+#include <linux/shrinker.h>
 
 struct mem_cgroup;
 struct page;
@@ -257,6 +258,10 @@ struct mem_cgroup {
 	struct wb_domain cgwb_domain;
 #endif
 
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+	struct thp_split_shrinker thp_split_shrinker;
+#endif /* CONFIG_TRANSPARENT_HUGEPAGE */
+
 	/* List of events which userspace want to receive */
 	struct list_head event_list;
 	spinlock_t event_list_lock;
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index c8f89417740b..a487fce68c52 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -18,6 +18,7 @@
 #include <linux/page-flags-layout.h>
 #include <linux/atomic.h>
 #include <asm/page.h>
+#include <linux/shrinker.h>
 
 /* Free memory management - zoned buddy allocator.  */
 #ifndef CONFIG_FORCE_MAX_ZONEORDER
@@ -702,11 +703,9 @@ typedef struct pglist_data {
 	unsigned long static_init_size;
 #endif /* CONFIG_DEFERRED_STRUCT_PAGE_INIT */
 
-#ifdef CONFIG_TRANSPARENT_HUGEPAGE
-	spinlock_t split_queue_lock;
-	struct list_head split_queue;
-	unsigned long split_queue_len;
-#endif
+#if defined CONFIG_TRANSPARENT_HUGEPAGE && !defined CONFIG_MEMCG
+	struct thp_split_shrinker thp_split_shrinker;
+#endif /*CONFIG_TRANSPARENT_HUGEPAGE && !CONFIG_MEMCG */
 
 	/* Fields commonly accessed by the page reclaim scanner */
 	struct lruvec		lruvec;
diff --git a/include/linux/shrinker.h b/include/linux/shrinker.h
index 51d189615bda..ceb0909743ee 100644
--- a/include/linux/shrinker.h
+++ b/include/linux/shrinker.h
@@ -76,4 +76,23 @@ struct shrinker {
 
 extern int register_shrinker(struct shrinker *);
 extern void unregister_shrinker(struct shrinker *);
+
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+struct thp_split_shrinker {
+	spinlock_t split_queue_lock;
+	/*
+	 * List of partially mapped THPs, that can be split under memory
+	 * pressure.
+	 */
+	struct list_head split_queue;
+	unsigned long split_queue_len;
+};
+
+static inline void thp_split_shrinker_init(struct thp_split_shrinker *thp_ss)
+{
+	spin_lock_init(&thp_ss->split_queue_lock);
+	INIT_LIST_HEAD(&thp_ss->split_queue);
+	thp_ss->split_queue_len = 0;
+}
+#endif /* CONFIG_TRANSPARENT_HUGEPAGE */
 #endif
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 269b5df58543..22bbe6017019 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -481,7 +481,7 @@ pmd_t maybe_pmd_mkwrite(pmd_t pmd, struct vm_area_struct *vma)
 	return pmd;
 }
 
-static inline struct list_head *page_deferred_list(struct page *page)
+struct list_head *page_deferred_list(struct page *page)
 {
 	/*
 	 * ->lru in the tail pages is occupied by compound_head.
@@ -2533,6 +2533,34 @@ bool can_split_huge_page(struct page *page, int *pextra_pins)
 	return total_mapcount(page) == page_count(page) - extra_pins - 1;
 }
 
+static
+struct thp_split_shrinker *get_thp_split_shrinker(struct page *page,
+						  struct mem_cgroup **memcg)
+{
+	struct thp_split_shrinker *thp_ss = NULL;
+#ifdef CONFIG_MEMCG
+	struct mem_cgroup *page_memcg;
+
+	rcu_read_lock();
+	page_memcg = READ_ONCE(page->mem_cgroup);
+	if (!page_memcg || !css_tryget(&page_memcg->css)) {
+		*memcg = NULL;
+		rcu_read_unlock();
+		goto out;
+	}
+	thp_ss = &page_memcg->thp_split_shrinker;
+	*memcg = page_memcg;
+	rcu_read_unlock();
+#else
+	struct pglist_data *pgdata = NODE_DATA(page_to_nid(page));
+
+	thp_ss = &pgdata->thp_split_shrinker;
+	*memcg = NULL;
+#endif
+out:
+	return thp_ss;
+}
+
 /*
  * This function splits huge page into normal pages. @page can point to any
  * subpage of huge page to split. Split doesn't change the position of @page.
@@ -2555,7 +2583,8 @@ bool can_split_huge_page(struct page *page, int *pextra_pins)
 int split_huge_page_to_list(struct page *page, struct list_head *list)
 {
 	struct page *head = compound_head(page);
-	struct pglist_data *pgdata = NODE_DATA(page_to_nid(head));
+	struct thp_split_shrinker *thp_ss;
+	struct mem_cgroup *memcg;
 	struct anon_vma *anon_vma = NULL;
 	struct address_space *mapping = NULL;
 	int count, mapcount, extra_pins, ret;
@@ -2634,17 +2663,18 @@ int split_huge_page_to_list(struct page *page, struct list_head *list)
 	}
 
 	/* Prevent deferred_split_scan() touching ->_refcount */
-	spin_lock(&pgdata->split_queue_lock);
+	thp_ss = get_thp_split_shrinker(head, &memcg);
+	spin_lock(&thp_ss->split_queue_lock);
 	count = page_count(head);
 	mapcount = total_mapcount(head);
 	if (!mapcount && page_ref_freeze(head, 1 + extra_pins)) {
 		if (!list_empty(page_deferred_list(head))) {
-			pgdata->split_queue_len--;
+			thp_ss->split_queue_len--;
 			list_del(page_deferred_list(head));
 		}
 		if (mapping)
 			__dec_node_page_state(page, NR_SHMEM_THPS);
-		spin_unlock(&pgdata->split_queue_lock);
+		spin_unlock(&thp_ss->split_queue_lock);
 		__split_huge_page(page, list, flags);
 		if (PageSwapCache(head)) {
 			swp_entry_t entry = { .val = page_private(head) };
@@ -2661,7 +2691,7 @@ int split_huge_page_to_list(struct page *page, struct list_head *list)
 			dump_page(page, "total_mapcount(head) > 0");
 			BUG();
 		}
-		spin_unlock(&pgdata->split_queue_lock);
+		spin_unlock(&thp_ss->split_queue_lock);
 fail:		if (mapping)
 			spin_unlock(&mapping->tree_lock);
 		spin_unlock_irqrestore(zone_lru_lock(page_zone(head)), flags);
@@ -2669,6 +2699,11 @@ fail:		if (mapping)
 		ret = -EBUSY;
 	}
 
+#ifdef CONFIG_MEMCG
+	if (memcg)
+		css_put(&memcg->css);
+#endif
+
 out_unlock:
 	if (anon_vma) {
 		anon_vma_unlock_write(anon_vma);
@@ -2683,53 +2718,90 @@ fail:		if (mapping)
 
 void free_transhuge_page(struct page *page)
 {
+#if !defined CONFIG_MEMCG
 	struct pglist_data *pgdata = NODE_DATA(page_to_nid(page));
+	struct thp_split_shrinker *thp_ss = pgdata->thp_split_shrinker;
 	unsigned long flags;
 
-	spin_lock_irqsave(&pgdata->split_queue_lock, flags);
+	spin_lock_irqsave(&thp_split_shrinker->split_queue_lock, flags);
 	if (!list_empty(page_deferred_list(page))) {
-		pgdata->split_queue_len--;
+		thp_split_shrinker->split_queue_len--;
 		list_del(page_deferred_list(page));
 	}
-	spin_unlock_irqrestore(&pgdata->split_queue_lock, flags);
+	spin_unlock_irqrestore(&thp_split_shrinker->split_queue_lock, flags);
+#endif /* !CONFIG_MEMCG */
 	free_compound_page(page);
 }
 
 void deferred_split_huge_page(struct page *page)
 {
-	struct pglist_data *pgdata = NODE_DATA(page_to_nid(page));
+	struct thp_split_shrinker *thp_ss;
+	struct mem_cgroup *memcg;
 	unsigned long flags;
 
 	VM_BUG_ON_PAGE(!PageTransHuge(page), page);
 
-	spin_lock_irqsave(&pgdata->split_queue_lock, flags);
+	thp_ss = get_thp_split_shrinker(page, &memcg);
+	if (!thp_ss)
+		goto out;
+#ifdef CONFIG_MEMCG
+	if (!memcg)
+		goto out;
+#endif
+	spin_lock_irqsave(&thp_ss->split_queue_lock, flags);
 	if (list_empty(page_deferred_list(page))) {
 		count_vm_event(THP_DEFERRED_SPLIT_PAGE);
-		list_add_tail(page_deferred_list(page), &pgdata->split_queue);
-		pgdata->split_queue_len++;
+		list_add_tail(page_deferred_list(page), &thp_ss->split_queue);
+		thp_ss->split_queue_len++;
 	}
-	spin_unlock_irqrestore(&pgdata->split_queue_lock, flags);
+	spin_unlock_irqrestore(&thp_ss->split_queue_lock, flags);
+out:
+#ifdef CONFIG_MEMCG
+	if (memcg)
+		css_put(&memcg->css);
+#endif
+	return;
 }
 
 static unsigned long deferred_split_count(struct shrinker *shrink,
 		struct shrink_control *sc)
 {
+#ifdef CONFIG_MEMCG
+	struct mem_cgroup *memcg = sc->memcg;
+
+	if (!sc->memcg)
+		return 0;
+
+	return ACCESS_ONCE(memcg->thp_split_shrinker.split_queue_len);
+#else
 	struct pglist_data *pgdata = NODE_DATA(sc->nid);
-	return ACCESS_ONCE(pgdata->split_queue_len);
+	return ACCESS_ONCE(pgdata->thp_split_shrinker.split_queue_len);
+#endif
 }
 
 static unsigned long deferred_split_scan(struct shrinker *shrink,
 		struct shrink_control *sc)
 {
-	struct pglist_data *pgdata = NODE_DATA(sc->nid);
+	struct thp_split_shrinker *thp_ss;
 	unsigned long flags;
 	LIST_HEAD(list), *pos, *next;
 	struct page *page;
 	int split = 0;
+#ifdef CONFIG_MEMCG
+	struct mem_cgroup *memcg = sc->memcg;
 
-	spin_lock_irqsave(&pgdata->split_queue_lock, flags);
+	if (!sc->memcg)
+		return SHRINK_STOP;
+	thp_ss = &memcg->thp_split_shrinker;
+#else
+	struct pglist_data *pgdata = NODE_DATA(sc->nid);
+
+	thp_ss = &pgdata->thp_split_shrinker;
+#endif
+
+	spin_lock_irqsave(&thp_ss->split_queue_lock, flags);
 	/* Take pin on all head pages to avoid freeing them under us */
-	list_for_each_safe(pos, next, &pgdata->split_queue) {
+	list_for_each_safe(pos, next, &thp_ss->split_queue) {
 		page = list_entry((void *)pos, struct page, mapping);
 		page = compound_head(page);
 		if (get_page_unless_zero(page)) {
@@ -2737,12 +2809,12 @@ static unsigned long deferred_split_scan(struct shrinker *shrink,
 		} else {
 			/* We lost race with put_compound_page() */
 			list_del_init(page_deferred_list(page));
-			pgdata->split_queue_len--;
+			thp_ss->split_queue_len--;
 		}
 		if (!--sc->nr_to_scan)
 			break;
 	}
-	spin_unlock_irqrestore(&pgdata->split_queue_lock, flags);
+	spin_unlock_irqrestore(&thp_ss->split_queue_lock, flags);
 
 	list_for_each_safe(pos, next, &list) {
 		page = list_entry((void *)pos, struct page, mapping);
@@ -2754,15 +2826,15 @@ static unsigned long deferred_split_scan(struct shrinker *shrink,
 		put_page(page);
 	}
 
-	spin_lock_irqsave(&pgdata->split_queue_lock, flags);
-	list_splice_tail(&list, &pgdata->split_queue);
-	spin_unlock_irqrestore(&pgdata->split_queue_lock, flags);
+	spin_lock_irqsave(&thp_ss->split_queue_lock, flags);
+	list_splice_tail(&list, &thp_ss->split_queue);
+	spin_unlock_irqrestore(&thp_ss->split_queue_lock, flags);
 
 	/*
 	 * Stop shrinker if we didn't split any page, but the queue is empty.
 	 * This can happen if pages were freed under us.
 	 */
-	if (!split && list_empty(&pgdata->split_queue))
+	if (!split && list_empty(&thp_ss->split_queue))
 		return SHRINK_STOP;
 	return split;
 }
@@ -2771,7 +2843,11 @@ static struct shrinker deferred_split_shrinker = {
 	.count_objects = deferred_split_count,
 	.scan_objects = deferred_split_scan,
 	.seeks = DEFAULT_SEEKS,
+#ifdef CONFIG_MEMCG
+	.flags = SHRINKER_MEMCG_AWARE,
+#else
 	.flags = SHRINKER_NUMA_AWARE,
+#endif
 };
 
 #ifdef CONFIG_DEBUG_FS
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index d5f3a62887cf..d118774d5213 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -35,6 +35,7 @@
 #include <linux/memcontrol.h>
 #include <linux/cgroup.h>
 #include <linux/mm.h>
+#include <linux/huge_mm.h>
 #include <linux/sched/mm.h>
 #include <linux/shmem_fs.h>
 #include <linux/hugetlb.h>
@@ -4252,6 +4253,9 @@ static struct mem_cgroup *mem_cgroup_alloc(void)
 #ifdef CONFIG_CGROUP_WRITEBACK
 	INIT_LIST_HEAD(&memcg->cgwb_list);
 #endif
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+	thp_split_shrinker_init(&memcg->thp_split_shrinker);
+#endif /* CONFIG_TRANSPARENT_HUGEPAGE */
 	idr_replace(&mem_cgroup_idr, memcg, memcg->id.id);
 	return memcg;
 fail:
@@ -5682,8 +5686,25 @@ static void uncharge_page(struct page *page, struct uncharge_gather *ug)
 		unsigned int nr_pages = 1;
 
 		if (PageTransHuge(page)) {
+			struct page *head = compound_head(page);
+			unsigned long flags;
+			struct thp_split_shrinker *thp_ss =
+				&ug->memcg->thp_split_shrinker;
+
 			nr_pages <<= compound_order(page);
 			ug->nr_huge += nr_pages;
+
+			/*
+			 * If this transhuge_page is being uncharged from this
+			 * memcg, then remove it from this memcg's split queue.
+			 */
+			spin_lock_irqsave(&thp_ss->split_queue_lock, flags);
+			if (!list_empty(page_deferred_list(head))) {
+				thp_ss->split_queue_len--;
+				list_del(page_deferred_list(head));
+			}
+			spin_unlock_irqrestore(&thp_ss->split_queue_lock,
+					flags);
 		}
 		if (PageAnon(page))
 			ug->nr_anon += nr_pages;
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 77e4d3c5c57b..9822dc3e3e70 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -6045,11 +6045,9 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat)
 	pgdat->numabalancing_migrate_nr_pages = 0;
 	pgdat->numabalancing_migrate_next_window = jiffies;
 #endif
-#ifdef CONFIG_TRANSPARENT_HUGEPAGE
-	spin_lock_init(&pgdat->split_queue_lock);
-	INIT_LIST_HEAD(&pgdat->split_queue);
-	pgdat->split_queue_len = 0;
-#endif
+#if defined CONFIG_TRANSPARENT_HUGEPAGE && !defined CONFIG_MEMCG
+	thp_split_shrinker_init(&pgdata->thp_split_shrinker);
+#endif /* CONFIG_TRANSPARENT_HUGEPAGE && !CONFIG_MEMCG */
 	init_waitqueue_head(&pgdat->kswapd_wait);
 	init_waitqueue_head(&pgdat->pfmemalloc_wait);
 #ifdef CONFIG_COMPACTION
-- 
2.15.0.rc1.287.g2b38de12cc-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
