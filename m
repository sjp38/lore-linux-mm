Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id AD5836B0103
	for <linux-mm@kvack.org>; Thu, 23 Feb 2012 08:53:18 -0500 (EST)
Received: by mail-bk0-f41.google.com with SMTP id y12so1365307bkt.14
        for <linux-mm@kvack.org>; Thu, 23 Feb 2012 05:53:18 -0800 (PST)
Subject: [PATCH v3 18/21] mm: add to lruvec isolated pages counters
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Thu, 23 Feb 2012 17:53:14 +0400
Message-ID: <20120223135314.12988.97364.stgit@zurg>
In-Reply-To: <20120223133728.12988.5432.stgit@zurg>
References: <20120223133728.12988.5432.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andi Kleen <andi@firstfloor.org>

This patch adds into struct lruvec counter of isolated pages.
It is required for keeping lruvec alive till the isolated page putback.
We cannot rely on resource counter in memory controller, because it
does not account uncharged memory. And it much better to have common engine
for dynamical lruvec management, than to tie all logic with memory cgroup magic.
Plus this is useful information for memory reclaimer balancing.

There also appears per-cpu page-vectors for putting isolated pages back,
and function add_page_to_evictable_list(). It is similar to lru_cache_add_lru()
but it reuse page reference from caller and can adjust isolated pages counters.
There also new function free_isolated_page_list() which is used at the end of
shrink_page_list() for freeing pages and adjusting counters of isolated pages.

Memory cgroups code can shuffle pages between lruvecs without isolation
if page is already isolated with someone else. Thus page lruvec reference is
unstable even if page is isolated. It is stable only under lru_lock or if page
reference count is zero. That's why we must always recheck page_lruvec() even
on non-lumpy 0-order reclaim, where all pages are isolated from one lruvec.

Memory controller at moving pege between cgroups now adjust isolated pages
counter for old lruvec before inserting page to new lruvec.
Locking lruvec->lru_lock in mem_cgroup_adjust_isolated() also effectively
stabilizes PageLRU() sign, so nobody will see PageLRU() under old lru_lock
while page is already moved into other lruvec.

[ BTW, all lru-id arithmetic can be simplified if we devide unevictable list
  into file and anon parts. After that we can swap bits in page->flags and
  calculate lru-id with single instruction ]

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
---
 include/linux/mmzone.h |   11 ++++-
 include/linux/swap.h   |    4 +-
 mm/compaction.c        |    1 
 mm/huge_memory.c       |    4 ++
 mm/internal.h          |    6 ++
 mm/ksm.c               |    2 -
 mm/memcontrol.c        |   39 ++++++++++++++--
 mm/migrate.c           |    2 -
 mm/rmap.c              |    2 -
 mm/swap.c              |   76 +++++++++++++++++++++++++++++++
 mm/vmscan.c            |  116 +++++++++++++++++++++++++++++++++++-------------
 11 files changed, 218 insertions(+), 45 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 82d5ff3..2e3a298 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -137,13 +137,20 @@ enum lru_list {
 	LRU_INACTIVE_FILE = LRU_BASE + LRU_FILE,
 	LRU_ACTIVE_FILE = LRU_BASE + LRU_FILE + LRU_ACTIVE,
 	LRU_UNEVICTABLE,
-	NR_LRU_LISTS
+	NR_EVICTABLE_LRU_LISTS = LRU_UNEVICTABLE,
+	NR_LRU_LISTS,
+	LRU_ISOLATED = NR_LRU_LISTS,
+	LRU_ISOLATED_ANON = LRU_ISOLATED,
+	LRU_ISOLATED_FILE,
+	NR_LRU_COUNTERS,
 };
 
 #define for_each_lru(lru) for (lru = 0; lru < NR_LRU_LISTS; lru++)
 
 #define for_each_evictable_lru(lru) for (lru = 0; lru <= LRU_ACTIVE_FILE; lru++)
 
+#define for_each_lru_counter(cnt) for (cnt = 0; cnt < NR_LRU_COUNTERS; cnt++)
+
 static inline int is_file_lru(enum lru_list lru)
 {
 	return (lru == LRU_INACTIVE_FILE || lru == LRU_ACTIVE_FILE);
@@ -298,7 +305,7 @@ struct zone_reclaim_stat {
 
 struct lruvec {
 	struct list_head	pages_lru[NR_LRU_LISTS];
-	unsigned long		pages_count[NR_LRU_LISTS];
+	unsigned long		pages_count[NR_LRU_COUNTERS];
 
 	struct zone_reclaim_stat	reclaim_stat;
 
diff --git a/include/linux/swap.h b/include/linux/swap.h
index 8630354..3a3ff2c 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -234,7 +234,9 @@ extern void rotate_reclaimable_page(struct page *page);
 extern void deactivate_page(struct page *page);
 extern void swap_setup(void);
 
-extern void add_page_to_unevictable_list(struct page *page);
+extern void add_page_to_unevictable_list(struct page *page, bool isolated);
+extern void add_page_to_evictable_list(struct page *page,
+					enum lru_list lru, bool isolated);
 
 /**
  * lru_cache_add: add a page to the page lists
diff --git a/mm/compaction.c b/mm/compaction.c
index 54340e4..fa74cbe 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -384,6 +384,7 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
 
 		/* Successfully isolated */
 		del_page_from_lru_list(lruvec, page, page_lru(page));
+		lruvec->pages_count[LRU_ISOLATED + page_is_file_cache(page)]++;
 		list_add(&page->lru, migratelist);
 		cc->nr_migratepages++;
 		nr_isolated++;
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 74996b8..46d9f44 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1316,6 +1316,10 @@ static void __split_huge_page_refcount(struct page *page)
 	__dec_zone_page_state(page, NR_ANON_TRANSPARENT_HUGEPAGES);
 	__mod_zone_page_state(lruvec_zone(lruvec), NR_ANON_PAGES, HPAGE_PMD_NR);
 
+	/* Fixup isolated pages counter if head page currently isolated */
+	if (!PageLRU(page))
+		lruvec->pages_count[LRU_ISOLATED_ANON] -= HPAGE_PMD_NR-1;
+
 	ClearPageCompound(page);
 	compound_unlock(page);
 	unlock_lruvec_irq(lruvec);
diff --git a/mm/internal.h b/mm/internal.h
index 9454752..6dd2e70 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -265,7 +265,11 @@ extern unsigned long highest_memmap_pfn;
  * in mm/vmscan.c:
  */
 extern int isolate_lru_page(struct page *page);
-extern void putback_lru_page(struct page *page);
+extern void __putback_lru_page(struct page *page, bool isolated);
+static inline void putback_lru_page(struct page *page)
+{
+	__putback_lru_page(page, true);
+}
 
 /*
  * in mm/page_alloc.c
diff --git a/mm/ksm.c b/mm/ksm.c
index e20de58..109e6ec 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -1592,7 +1592,7 @@ struct page *ksm_does_need_to_copy(struct page *page,
 		if (page_evictable(new_page, vma))
 			lru_cache_add_lru(new_page, LRU_ACTIVE_ANON);
 		else
-			add_page_to_unevictable_list(new_page);
+			add_page_to_unevictable_list(new_page, false);
 	}
 
 	return new_page;
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 230f434..4de8044 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -697,7 +697,7 @@ mem_cgroup_zone_nr_lru_pages(struct mem_cgroup *memcg, int nid, int zid,
 
 	mz = mem_cgroup_zoneinfo(memcg, nid, zid);
 
-	for_each_lru(lru) {
+	for_each_lru_counter(lru) {
 		if (BIT(lru) & lru_mask)
 			ret += mz->lruvec.pages_count[lru];
 	}
@@ -2354,6 +2354,17 @@ void mem_cgroup_split_huge_fixup(struct page *head)
 }
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
 
+static void mem_cgroup_adjust_isolated(struct lruvec *lruvec,
+				       struct page *page, int delta)
+{
+	int file = page_is_file_cache(page);
+	unsigned long flags;
+
+	lock_lruvec(lruvec, &flags);
+	lruvec->pages_count[LRU_ISOLATED + file] += delta;
+	unlock_lruvec(lruvec, &flags);
+}
+
 /**
  * mem_cgroup_move_account - move account of the page
  * @page: the page
@@ -2452,6 +2463,7 @@ static int mem_cgroup_move_parent(struct page *page,
 	struct mem_cgroup *parent;
 	unsigned int nr_pages;
 	unsigned long uninitialized_var(flags);
+	struct lruvec *lruvec;
 	int ret;
 
 	/* Is ROOT ? */
@@ -2471,6 +2483,8 @@ static int mem_cgroup_move_parent(struct page *page,
 	if (ret)
 		goto put_back;
 
+	lruvec = page_lruvec(page);
+
 	if (nr_pages > 1)
 		flags = compound_lock_irqsave(page);
 
@@ -2480,8 +2494,11 @@ static int mem_cgroup_move_parent(struct page *page,
 
 	if (nr_pages > 1)
 		compound_unlock_irqrestore(page, flags);
+	if (!ret)
+		/* This also stabilize PageLRU() sign for lruvec lock holder. */
+		mem_cgroup_adjust_isolated(lruvec, page, -nr_pages);
 put_back:
-	putback_lru_page(page);
+	__putback_lru_page(page, !ret);
 put:
 	put_page(page);
 out:
@@ -3879,6 +3896,8 @@ enum {
 	MCS_INACTIVE_FILE,
 	MCS_ACTIVE_FILE,
 	MCS_UNEVICTABLE,
+	MCS_ISOLATED_ANON,
+	MCS_ISOLATED_FILE,
 	NR_MCS_STAT,
 };
 
@@ -3902,7 +3921,9 @@ struct {
 	{"active_anon", "total_active_anon"},
 	{"inactive_file", "total_inactive_file"},
 	{"active_file", "total_active_file"},
-	{"unevictable", "total_unevictable"}
+	{"unevictable", "total_unevictable"},
+	{"isolated_anon", "total_isolated_anon"},
+	{"isolated_file", "total_isolated_file"},
 };
 
 
@@ -3942,6 +3963,10 @@ mem_cgroup_get_local_stat(struct mem_cgroup *memcg, struct mcs_total_stat *s)
 	s->stat[MCS_ACTIVE_FILE] += val * PAGE_SIZE;
 	val = mem_cgroup_nr_lru_pages(memcg, BIT(LRU_UNEVICTABLE));
 	s->stat[MCS_UNEVICTABLE] += val * PAGE_SIZE;
+	val = mem_cgroup_nr_lru_pages(memcg, BIT(LRU_ISOLATED_ANON));
+	s->stat[MCS_ISOLATED_ANON] += val * PAGE_SIZE;
+	val = mem_cgroup_nr_lru_pages(memcg, BIT(LRU_ISOLATED_FILE));
+	s->stat[MCS_ISOLATED_FILE] += val * PAGE_SIZE;
 }
 
 static void
@@ -5243,6 +5268,7 @@ retry:
 		struct page *page;
 		struct page_cgroup *pc;
 		swp_entry_t ent;
+		struct lruvec *lruvec;
 
 		if (!mc.precharge)
 			break;
@@ -5253,14 +5279,17 @@ retry:
 			page = target.page;
 			if (isolate_lru_page(page))
 				goto put;
+			lruvec = page_lruvec(page);
 			pc = lookup_page_cgroup(page);
 			if (!mem_cgroup_move_account(page, 1, pc,
 						     mc.from, mc.to, false)) {
 				mc.precharge--;
 				/* we uncharge from mc.from later. */
 				mc.moved_charge++;
-			}
-			putback_lru_page(page);
+				mem_cgroup_adjust_isolated(lruvec, page, -1);
+				__putback_lru_page(page, false);
+			} else
+				__putback_lru_page(page, true);
 put:			/* is_target_pte_for_mc() gets the page */
 			put_page(page);
 			break;
diff --git a/mm/migrate.c b/mm/migrate.c
index df141f6..de13a0e 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -868,7 +868,7 @@ out:
 	 * Move the new page to the LRU. If migration was not successful
 	 * then this will free the page.
 	 */
-	putback_lru_page(newpage);
+	__putback_lru_page(newpage, false);
 	if (result) {
 		if (rc)
 			*result = rc;
diff --git a/mm/rmap.c b/mm/rmap.c
index aa547d4..06b5def9 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1139,7 +1139,7 @@ void page_add_new_anon_rmap(struct page *page,
 	if (page_evictable(page, vma))
 		lru_cache_add_lru(page, LRU_ACTIVE_ANON);
 	else
-		add_page_to_unevictable_list(page);
+		add_page_to_unevictable_list(page, false);
 }
 
 /**
diff --git a/mm/swap.c b/mm/swap.c
index 3689e3d..998c71c 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -37,6 +37,8 @@
 int page_cluster;
 
 static DEFINE_PER_CPU(struct pagevec[NR_LRU_LISTS], lru_add_pvecs);
+static DEFINE_PER_CPU(struct pagevec[NR_EVICTABLE_LRU_LISTS],
+					   lru_add_isolated_pvecs);
 static DEFINE_PER_CPU(struct pagevec, lru_rotate_pvecs);
 static DEFINE_PER_CPU(struct pagevec, lru_deactivate_pvecs);
 
@@ -381,6 +383,67 @@ void lru_cache_add_lru(struct page *page, enum lru_list lru)
 	__lru_cache_add(page, lru);
 }
 
+static void __lru_add_isolated_fn(struct lruvec *lruvec,
+				  struct page *page, void *arg)
+{
+	enum lru_list lru = (enum lru_list)arg;
+
+	VM_BUG_ON(PageActive(page));
+	VM_BUG_ON(PageUnevictable(page));
+	VM_BUG_ON(PageLRU(page));
+
+	SetPageLRU(page);
+	if (is_active_lru(lru))
+		SetPageActive(page);
+	update_page_reclaim_stat(lruvec, lru);
+	add_page_to_lru_list(lruvec, page, lru);
+	lruvec->pages_count[LRU_ISOLATED + is_file_lru(lru)] -=
+						hpage_nr_pages(page);
+}
+
+static void __lru_add_isolated(struct pagevec *pvec, enum lru_list lru)
+{
+	VM_BUG_ON(is_unevictable_lru(lru));
+	pagevec_lru_move_fn(pvec, __lru_add_isolated_fn, (void *)lru);
+}
+
+/**
+ * add_page_to_evictable_list - add page to lru list
+ * @page	the page to be added into the lru list
+ * @lru		lru list id
+ * @isolated	need to adjust isolated pages counter
+ *
+ * Like lru_cache_add_lru() but reuses caller's reference to page and
+ * taking care about isolated pages counter on lruvec if isolated = true.
+ */
+void add_page_to_evictable_list(struct page *page,
+				enum lru_list lru, bool isolated)
+{
+	struct pagevec *pvec;
+
+	if (PageActive(page)) {
+		VM_BUG_ON(PageUnevictable(page));
+		ClearPageActive(page);
+	} else if (PageUnevictable(page)) {
+		VM_BUG_ON(PageActive(page));
+		ClearPageUnevictable(page);
+	}
+
+	VM_BUG_ON(PageLRU(page) || PageActive(page) || PageUnevictable(page));
+
+	preempt_disable();
+	if (isolated) {
+		pvec = __this_cpu_ptr(lru_add_isolated_pvecs + lru);
+		if (!pagevec_add(pvec, page))
+			__lru_add_isolated(pvec, lru);
+	} else {
+		pvec = __this_cpu_ptr(lru_add_pvecs + lru);
+		if (!pagevec_add(pvec, page))
+			__pagevec_lru_add(pvec, lru);
+	}
+	preempt_enable();
+}
+
 /**
  * add_page_to_unevictable_list - add a page to the unevictable list
  * @page:  the page to be added to the unevictable list
@@ -391,7 +454,7 @@ void lru_cache_add_lru(struct page *page, enum lru_list lru)
  * while it's locked or otherwise "invisible" to other tasks.  This is
  * difficult to do when using the pagevec cache, so bypass that.
  */
-void add_page_to_unevictable_list(struct page *page)
+void add_page_to_unevictable_list(struct page *page, bool isolated)
 {
 	struct lruvec *lruvec;
 
@@ -399,6 +462,10 @@ void add_page_to_unevictable_list(struct page *page)
 	SetPageUnevictable(page);
 	SetPageLRU(page);
 	add_page_to_lru_list(lruvec, page, LRU_UNEVICTABLE);
+	if (isolated) {
+		int type = LRU_ISOLATED + page_is_file_cache(page);
+		lruvec->pages_count[type] -= hpage_nr_pages(page);
+	}
 	unlock_lruvec_irq(lruvec);
 }
 
@@ -485,6 +552,13 @@ static void drain_cpu_pagevecs(int cpu)
 			__pagevec_lru_add(pvec, lru);
 	}
 
+	pvecs = per_cpu(lru_add_isolated_pvecs, cpu);
+	for_each_evictable_lru(lru) {
+		pvec = &pvecs[lru];
+		if (pagevec_count(pvec))
+			__lru_add_isolated(pvec, lru);
+	}
+
 	pvec = &per_cpu(lru_rotate_pvecs, cpu);
 	if (pagevec_count(pvec)) {
 		unsigned long flags;
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 6eeeb4b..a1ff010 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -42,6 +42,7 @@
 #include <linux/sysctl.h>
 #include <linux/oom.h>
 #include <linux/prefetch.h>
+#include <trace/events/kmem.h>
 
 #include <asm/tlbflush.h>
 #include <asm/div64.h>
@@ -585,15 +586,16 @@ int remove_mapping(struct address_space *mapping, struct page *page)
 }
 
 /**
- * putback_lru_page - put previously isolated page onto appropriate LRU list
+ * __putback_lru_page - put previously isolated page onto appropriate LRU list
  * @page: page to be put back to appropriate lru list
+ * @isolated: isolated pages counter update required
  *
  * Add previously isolated @page to appropriate LRU list.
  * Page may still be unevictable for other reasons.
  *
  * lru_lock must not be held, interrupts must be enabled.
  */
-void putback_lru_page(struct page *page)
+void __putback_lru_page(struct page *page, bool isolated)
 {
 	int lru;
 	int active = !!TestClearPageActive(page);
@@ -612,14 +614,16 @@ redo:
 		 * We know how to handle that.
 		 */
 		lru = active + page_lru_base_type(page);
-		lru_cache_add_lru(page, lru);
+		add_page_to_evictable_list(page, lru, isolated);
+		if (was_unevictable)
+			count_vm_event(UNEVICTABLE_PGRESCUED);
 	} else {
 		/*
 		 * Put unevictable pages directly on zone's unevictable
 		 * list.
 		 */
 		lru = LRU_UNEVICTABLE;
-		add_page_to_unevictable_list(page);
+		add_page_to_unevictable_list(page, isolated);
 		/*
 		 * When racing with an mlock or AS_UNEVICTABLE clearing
 		 * (page is unlocked) make sure that if the other thread
@@ -631,30 +635,26 @@ redo:
 		 * The other side is TestClearPageMlocked() or shmem_lock().
 		 */
 		smp_mb();
-	}
-
-	/*
-	 * page's status can change while we move it among lru. If an evictable
-	 * page is on unevictable list, it never be freed. To avoid that,
-	 * check after we added it to the list, again.
-	 */
-	if (lru == LRU_UNEVICTABLE && page_evictable(page, NULL)) {
-		if (!isolate_lru_page(page)) {
-			put_page(page);
-			goto redo;
-		}
-		/* This means someone else dropped this page from LRU
-		 * So, it will be freed or putback to LRU again. There is
-		 * nothing to do here.
+		/*
+		 * page's status can change while we move it among lru.
+		 * If an evictable page is on unevictable list, it never be freed.
+		 * To avoid that, check after we added it to the list, again.
 		 */
+		if (page_evictable(page, NULL)) {
+			if (!isolate_lru_page(page)) {
+				isolated = true;
+				put_page(page);
+				goto redo;
+			}
+			/* This means someone else dropped this page from LRU
+			 * So, it will be freed or putback to LRU again. There is
+			 * nothing to do here.
+			 */
+		}
+		put_page(page);		/* drop ref from isolate */
+		if (!was_unevictable)
+			count_vm_event(UNEVICTABLE_PGCULLED);
 	}
-
-	if (was_unevictable && lru != LRU_UNEVICTABLE)
-		count_vm_event(UNEVICTABLE_PGRESCUED);
-	else if (!was_unevictable && lru == LRU_UNEVICTABLE)
-		count_vm_event(UNEVICTABLE_PGCULLED);
-
-	put_page(page);		/* drop ref from isolate */
 }
 
 enum page_references {
@@ -724,6 +724,48 @@ static enum page_references page_check_references(struct page *page,
 }
 
 /*
+ * Free a list of isolated 0-order pages
+ */
+static void free_isolated_page_list(struct lruvec *lruvec,
+				    struct list_head *list, int cold)
+{
+	struct page *page, *next;
+	unsigned long nr_pages[2];
+	struct list_head queue;
+
+again:
+	INIT_LIST_HEAD(&queue);
+	nr_pages[0] = nr_pages[1] = 0;
+
+	list_for_each_entry_safe(page, next, list, lru) {
+		if (unlikely(lruvec != page_lruvec(page))) {
+			list_add_tail(&page->lru, &queue);
+			continue;
+		}
+		nr_pages[page_is_file_cache(page)]++;
+		trace_mm_page_free_batched(page, cold);
+		free_hot_cold_page(page, cold);
+	}
+
+	lock_lruvec_irq(lruvec);
+	lruvec->pages_count[LRU_ISOLATED_ANON] -= nr_pages[0];
+	lruvec->pages_count[LRU_ISOLATED_FILE] -= nr_pages[1];
+	unlock_lruvec_irq(lruvec);
+
+	/*
+	 * Usually there will be only one iteration, because
+	 * at 0-order reclaim all pages are from one lruvec
+	 * if we didn't raced with memory cgroup shuffling.
+	 */
+	if (unlikely(!list_empty(&queue))) {
+		list_replace(&queue, list);
+		lruvec = page_lruvec(list_first_entry(list,
+					struct page, lru));
+		goto again;
+	}
+}
+
+/*
  * shrink_page_list() returns the number of reclaimed pages
  */
 static unsigned long shrink_page_list(struct list_head *page_list,
@@ -986,7 +1028,7 @@ keep_lumpy:
 	if (nr_dirty && nr_dirty == nr_congested && global_reclaim(sc))
 		zone_set_flag(lruvec_zone(lruvec), ZONE_CONGESTED);
 
-	free_hot_cold_page_list(&free_pages, 1);
+	free_isolated_page_list(lruvec, &free_pages, 1);
 
 	list_splice(&ret_pages, page_list);
 	count_vm_events(PGACTIVATE, pgactivate);
@@ -1206,11 +1248,14 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 			if (__isolate_lru_page(cursor_page, mode, file) == 0) {
 				unsigned int isolated_pages;
 				int cursor_lru = page_lru(cursor_page);
+				int cur_file = page_is_file_cache(cursor_page);
 
 				list_move(&cursor_page->lru, dst);
 				isolated_pages = hpage_nr_pages(cursor_page);
 				cursor_lruvec->pages_count[cursor_lru] -=
 								isolated_pages;
+				cursor_lruvec->pages_count[LRU_ISOLATED +
+						cur_file] += isolated_pages;
 				VM_BUG_ON((long)cursor_lruvec->
 						pages_count[cursor_lru] < 0);
 				nr_taken += isolated_pages;
@@ -1248,6 +1293,7 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 	}
 
 	lruvec->pages_count[lru] -= nr_taken - nr_lumpy_taken;
+	lruvec->pages_count[LRU_ISOLATED + file] += nr_taken - nr_lumpy_taken;
 	VM_BUG_ON((long)lruvec->pages_count[lru] < 0);
 
 	*nr_scanned = scan;
@@ -1296,11 +1342,14 @@ int isolate_lru_page(struct page *page)
 
 		lruvec = lock_page_lruvec_irq(page);
 		if (PageLRU(page)) {
+			int file = page_is_file_cache(page);
 			int lru = page_lru(page);
 			ret = 0;
 			get_page(page);
 			ClearPageLRU(page);
 			del_page_from_lru_list(lruvec, page, lru);
+			lruvec->pages_count[LRU_ISOLATED + file] +=
+							hpage_nr_pages(page);
 		}
 		unlock_lruvec_irq(lruvec);
 	}
@@ -1347,7 +1396,7 @@ putback_inactive_pages(struct lruvec *lruvec,
 	 */
 	while (!list_empty(page_list)) {
 		struct page *page = lru_to_page(page_list);
-		int lru;
+		int numpages, lru, file;
 
 		VM_BUG_ON(PageLRU(page));
 		list_del(&page->lru);
@@ -1363,13 +1412,13 @@ putback_inactive_pages(struct lruvec *lruvec,
 
 		SetPageLRU(page);
 		lru = page_lru(page);
+		file = is_file_lru(lru);
+		numpages = hpage_nr_pages(page);
 
 		add_page_to_lru_list(lruvec, page, lru);
-		if (is_active_lru(lru)) {
-			int file = is_file_lru(lru);
-			int numpages = hpage_nr_pages(page);
+		lruvec->pages_count[LRU_ISOLATED + file] -= numpages;
+		if (is_active_lru(lru))
 			reclaim_stat->recent_rotated[file] += numpages;
-		}
 		if (put_page_testzero(page)) {
 			__ClearPageLRU(page);
 			__ClearPageActive(page);
@@ -1656,6 +1705,9 @@ move_active_pages_to_lru(struct lruvec *lruvec,
 		list_move(&page->lru, &lruvec->pages_lru[lru]);
 		numpages = hpage_nr_pages(page);
 		lruvec->pages_count[lru] += numpages;
+		/* There should be no mess between file and anon pages */
+		lruvec->pages_count[LRU_ISOLATED +
+				    is_file_lru(lru)] -= numpages;
 		pgmoved += numpages;
 
 		if (put_page_testzero(page)) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
