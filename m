From: KUROSAWA Takahiro <kurosawa@valinux.co.jp>
Message-Id: <20060131023030.7915.57560.sendpatchset@debian>
In-Reply-To: <20060131023000.7915.71955.sendpatchset@debian>
References: <20060131023000.7915.71955.sendpatchset@debian>
Subject: [PATCH 6/8] Add the pzone_destroy() function
Date: Tue, 31 Jan 2006 11:30:30 +0900 (JST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: ckrm-tech@lists.sourceforge.net
Cc: linux-mm@kvack.org, KUROSAWA Takahiro <kurosawa@valinux.co.jp>
List-ID: <linux-mm.kvack.org>

This patch implements destruction of pzones.  Pages in the destroyed 
pzones return into the parent zone (the zone from that the pzone was 
created).

Signed-off-by: KUROSAWA Takahiro <kurosawa@valinux.co.jp>

---
 include/linux/mmzone.h |    1 
 include/linux/swap.h   |    2 
 mm/page_alloc.c        |  287 +++++++++++++++++++++++++++++++++++++++++++++++++
 mm/vmscan.c            |    4 
 4 files changed, 292 insertions(+), 2 deletions(-)

diff -urNp a/include/linux/mmzone.h b/include/linux/mmzone.h
--- a/include/linux/mmzone.h	2006-01-30 14:33:44.000000000 +0900
+++ b/include/linux/mmzone.h	2006-01-30 14:34:39.000000000 +0900
@@ -362,6 +362,7 @@ struct pzone_table {
 extern struct pzone_table pzone_table[];
 
 struct zone *pzone_create(struct zone *z, char *name, int npages);
+void pzone_destroy(struct zone *z);
 
 static inline void zone_init_pzone_link(struct zone *z)
 {
diff -urNp a/include/linux/swap.h b/include/linux/swap.h
--- a/include/linux/swap.h	2006-01-03 12:21:10.000000000 +0900
+++ b/include/linux/swap.h	2006-01-30 11:23:03.000000000 +0900
@@ -171,6 +171,8 @@ extern int rotate_reclaimable_page(struc
 extern void swap_setup(void);
 
 /* linux/mm/vmscan.c */
+extern int isolate_lru_pages(int, struct list_head *, struct list_head *,
+		int *);
 extern int try_to_free_pages(struct zone **, gfp_t);
 extern int zone_reclaim(struct zone *, gfp_t, unsigned int);
 extern int shrink_all_memory(int);
diff -urNp a/mm/page_alloc.c b/mm/page_alloc.c
--- a/mm/page_alloc.c	2006-01-30 14:33:44.000000000 +0900
+++ b/mm/page_alloc.c	2006-01-30 14:34:39.000000000 +0900
@@ -2727,6 +2727,9 @@ EXPORT_SYMBOL(pzone_table);
 
 static struct list_head pzone_freelist = LIST_HEAD_INIT(pzone_freelist);
 
+static struct workqueue_struct *pzone_drain_wq;
+static DEFINE_PER_CPU(struct work_struct, pzone_drain_work);
+
 static int pzone_table_register(struct zone *z)
 {
 	struct pzone_table *t;
@@ -2747,6 +2750,18 @@ static int pzone_table_register(struct z
 	return 0;
 }
 
+static void pzone_table_unregister(struct zone *z)
+{
+	struct pzone_table *t;
+	unsigned long flags;
+
+	write_lock_nr_zones(&flags);
+	t = &pzone_table[z->pzone_idx];
+	t->zone = NULL;
+	list_add(&t->list, &pzone_freelist);
+	write_unlock_nr_zones(&flags);
+}
+
 static void pzone_parent_register(struct zone *z, struct zone *parent)
 {
 	unsigned long flags;
@@ -2756,6 +2771,15 @@ static void pzone_parent_register(struct
 	write_unlock_nr_zones(&flags);
 }
 
+static void pzone_parent_unregister(struct zone *z)
+{
+	unsigned long flags;
+
+	write_lock_nr_zones(&flags);
+	list_del(&z->sibling);
+	write_unlock_nr_zones(&flags);
+}
+
 /*
  * pzone alloc/free routines
  */
@@ -2847,6 +2871,194 @@ static inline void pzone_restore_page_fl
 	page->flags &= ~(1UL << PZONE_BIT_PGSHIFT);
 }
 
+/*
+ * pzone_bad_range(): implemented for debugging instead of bad_range()
+ * in order to distinguish what causes the crash.
+ */
+static int pzone_bad_range(struct zone *zone, struct page *page)
+{
+	if (page_to_pfn(page) >= zone->zone_start_pfn + zone->spanned_pages)
+		BUG();
+	if (page_to_pfn(page) < zone->zone_start_pfn)
+		BUG();
+#ifdef CONFIG_HOLES_IN_ZONE
+	if (!pfn_valid(page_to_pfn(page)))
+		BUG();
+#endif
+	if (zone != page_zone(page))
+		BUG();
+	return 0;
+}
+
+static void pzone_drain(void *arg)
+{
+	lru_add_drain();
+}
+
+static void pzone_punt_drain(void *arg)
+{
+	struct work_struct *wp;
+
+	wp = &get_cpu_var(pzone_drain_work);
+	PREPARE_WORK(wp, pzone_drain, arg);
+	/* queue_work() checks whether the work is used or not. */
+	queue_work(pzone_drain_wq, wp);
+	put_cpu_var(pzone_drain_work);
+}
+
+static void pzone_flush_percpu(void *arg)
+{
+	struct zone *z = arg;
+	unsigned long flags;
+	int cpu;
+
+	/*
+	 * lru_add_drain() must not be called from interrupt context
+	 * (LRU pagevecs are interrupt unsafe).
+	 */
+
+	local_irq_save(flags);
+	cpu = smp_processor_id();
+	pzone_punt_drain(arg);
+	__drain_zone_pages(z, cpu);
+	local_irq_restore(flags);
+}
+
+static int pzone_flush_lru(struct zone *z, struct zone *parent,
+			   struct list_head *clist, unsigned long *cnr,
+			   int block)
+{
+	unsigned long flags;
+	struct page *page;
+	struct list_head list;
+	int n, moved, scan;
+
+	INIT_LIST_HEAD(&list);
+
+	spin_lock_irqsave(&z->lru_lock, flags);
+	n = isolate_lru_pages(*cnr, clist, &list, &scan);
+	*cnr -= n;
+	spin_unlock_irqrestore(&z->lru_lock, flags);
+
+	moved = 0;
+	while (!list_empty(&list) && n-- > 0) {
+		page = list_entry(list.prev, struct page, lru);
+		list_del(&page->lru);
+
+		if (block) {
+			lock_page(page);
+			wait_on_page_writeback(page);
+		} else {
+			if (TestSetPageLocked(page))
+				goto goaround;
+
+			/* Make sure the writeback bit being kept zero. */
+			if (PageWriteback(page))
+				goto goaround_pagelocked;
+		}
+
+		/* Now we can safely modify the flags field. */
+		pzone_restore_page_flags(parent, page);
+		unlock_page(page);
+
+		spin_lock_irqsave(&parent->lru_lock, flags);
+		if (TestSetPageLRU(page))
+			BUG();
+
+		__put_page(page);
+		if (PageActive(page))
+			add_page_to_active_list(parent, page);
+		else
+			add_page_to_inactive_list(parent, page);
+		spin_unlock_irqrestore(&parent->lru_lock, flags);
+
+		moved++;
+		continue;
+
+goaround_pagelocked:
+		unlock_page(page);
+goaround:
+		spin_lock_irqsave(&z->lru_lock, flags);
+		__put_page(page);
+		if (TestSetPageLRU(page))
+			BUG();
+		list_add(&page->lru, clist);
+		++*cnr;
+		spin_unlock_irqrestore(&z->lru_lock, flags);
+	}
+
+	return moved;
+}
+
+static void pzone_flush_free_area(struct zone *z)
+{
+	struct free_area *area;
+	struct page *page;
+	struct list_head list;
+	unsigned long flags;
+	int order;
+
+	INIT_LIST_HEAD(&list);
+
+	spin_lock_irqsave(&z->lock, flags);
+	area = &z->free_area[0];
+	while (!list_empty(&area->free_list)) {
+		page = list_entry(area->free_list.next, struct page, lru);
+		list_del(&page->lru);
+		area->nr_free--;
+		z->free_pages--;
+		z->present_pages--;
+		spin_unlock_irqrestore(&z->lock, flags);
+		pzone_restore_page_flags(z->parent, page);
+		pzone_bad_range(z->parent, page);
+		list_add(&page->lru, &list);
+		free_pages_bulk(z->parent, 1, &list, 0);
+
+		spin_lock_irqsave(&z->lock, flags);
+	}
+
+	BUG_ON(area->nr_free != 0);
+	spin_unlock_irqrestore(&z->lock, flags);
+
+	/* currently pzone only supports order-0 only. do sanity check. */
+	spin_lock_irqsave(&z->lock, flags);
+	for (order = 1; order < MAX_ORDER; order++) {
+		area = &z->free_area[order];
+		BUG_ON(area->nr_free != 0);
+	}
+	spin_unlock_irqrestore(&z->lock, flags);
+}
+
+static int pzone_is_empty(struct zone *z)
+{
+	unsigned long flags;
+	int ret = 0;
+	int i;
+
+	spin_lock_irqsave(&z->lock, flags);
+	ret += z->present_pages;
+	ret += z->free_pages;
+	ret += z->free_area[0].nr_free;
+
+	/* would better use smp_call_function for scanning pcp. */
+	for (i = 0; i < NR_CPUS; i++) {
+#ifdef CONFIG_NUMA
+		if (!zone_pcp(z, i) || (zone_pcp(z, i) == &boot_pageset[i]))
+			continue;
+#endif
+		ret += zone_pcp(z, i)->pcp[0].count;
+		ret += zone_pcp(z, i)->pcp[1].count;
+	}
+	spin_unlock_irqrestore(&z->lock, flags);
+
+	spin_lock_irqsave(&z->lru_lock, flags);
+	ret += z->nr_active;
+	ret += z->nr_inactive;
+	spin_unlock_irqrestore(&z->lru_lock, flags);
+
+	return ret == 0;
+}
+
 struct zone *pzone_create(struct zone *parent, char *name, int npages)
 {
 	struct zonelist zonelist;
@@ -2953,10 +3165,85 @@ bad1:
 	return NULL;
 }
 
+#define PZONE_FLUSH_LOOP_COUNT		8
+
+/*
+ * destroying pseudo zone. the caller should make sure that no one references
+ * this pseudo zone.
+ */
+void pzone_destroy(struct zone *z)
+{
+	struct zone *parent;
+	unsigned long flags;
+	unsigned long present;
+	int freed;
+	int retrycnt = 0;
+
+	parent = z->parent;
+	present = z->present_pages;
+	pzone_parent_unregister(z);
+retry:
+	/* drain pages in per-cpu pageset to free_area */
+	smp_call_function(pzone_flush_percpu, z, 0, 1);
+	pzone_flush_percpu(z);
+	
+	/* drain pages in the LRU list. */
+	freed = pzone_flush_lru(z, parent, &z->active_list, &z->nr_active,
+				retrycnt > 0);
+	spin_lock_irqsave(&z->lock, flags);
+	z->present_pages -= freed;
+	spin_unlock_irqrestore(&z->lock, flags);
+
+	freed = pzone_flush_lru(z, parent, &z->inactive_list, &z->nr_inactive,
+				retrycnt > 0);
+	spin_lock_irqsave(&z->lock, flags);
+	z->present_pages -= freed;
+	spin_unlock_irqrestore(&z->lock, flags);
+
+	pzone_flush_free_area(z);
+
+	if (!pzone_is_empty(z)) {
+		retrycnt++;
+		if (retrycnt > PZONE_FLUSH_LOOP_COUNT) {
+			BUG();
+		} else {
+			flush_workqueue(pzone_drain_wq);
+			set_current_state(TASK_UNINTERRUPTIBLE);
+			schedule_timeout(HZ);
+			goto retry;
+		}
+	}
+
+	spin_lock_irqsave(&parent->lock, flags);
+	parent->present_pages += present;
+	spin_unlock_irqrestore(&parent->lock, flags);
+
+	flush_workqueue(pzone_drain_wq);
+	pzone_table_unregister(z);
+	pzone_free_pagesets(z);
+	kfree(z->name);
+	kfree(z);
+
+	setup_per_zone_pages_min();
+	setup_per_zone_lowmem_reserve();
+}
+
 static int pzone_init(void)
 {
+	struct work_struct *wp;
 	int i;
 
+	pzone_drain_wq = create_workqueue("pzone");
+	if (!pzone_drain_wq) {
+		printk(KERN_ERR "pzone: create_workqueue failed.\n");
+		return -ENOMEM;
+	}
+
+	for (i = 0; i < NR_CPUS; i++) {
+		wp = &per_cpu(pzone_drain_work, i);
+		INIT_WORK(wp, pzone_drain, NULL);
+	}
+
 	for (i = 0; i < MAX_NR_PZONES; i++)
 		list_add_tail(&pzone_table[i].list, &pzone_freelist);
 
diff -urNp a/mm/vmscan.c b/mm/vmscan.c
--- a/mm/vmscan.c	2006-01-30 14:33:44.000000000 +0900
+++ b/mm/vmscan.c	2006-01-30 14:34:39.000000000 +0900
@@ -591,8 +591,8 @@ keep:
  *
  * returns how many pages were moved onto *@dst.
  */
-static int isolate_lru_pages(int nr_to_scan, struct list_head *src,
-			     struct list_head *dst, int *scanned)
+int isolate_lru_pages(int nr_to_scan, struct list_head *src,
+		      struct list_head *dst, int *scanned)
 {
 	int nr_taken = 0;
 	struct page *page;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
