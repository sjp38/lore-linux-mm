Received: from wli by holomorphy with local (Exim 3.34 #1 (Debian))
	id 17uWRA-0006Yi-00
	for <linux-mm@kvack.org>; Thu, 26 Sep 2002 04:04:04 -0700
Date: Thu, 26 Sep 2002 04:04:03 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: lazy_buddy-2.5.38-2
Message-ID: <20020926110403.GD22942@holomorphy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Description: brief message
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This includes some steal_deferred_page() fixes not posted in the
2.5.25-4 release. i.e. the unposted 2.5.25-5.

This hasn't been booted (or even compiled) in centuries (a.k.a. 13
minor releases). Basically I let bk merge in the background while doing
the things I'm actually supposed to etc. Nothing has really happened
except for brute-force merging.  The TODO for this (and the patch too)
is essentially unchanged from lazy_buddy-2.5.25-4 aside from having
taken an unpublished stab at the fork() failure issue a month or so ago
(included here).

At some point if and when I can get some bandwidth to deal with this
I'll make more stuff happen. NFI, 2.7? Maybe never? Bitrot is a very
powerful force, not to be underestimated. Thus all unmerged patches die.
Very little or nothing will happen here until large pages are dealt with,
and probably not until several other things thereafter are also done.
When the music stops come October 31 I have NFI where this will be.

Someone made noises they wanted to look at this, hence the rediff. Be
prepared to fix as-of-yet-unresolved merging errors and/or new bugs.

Against current 2.5.38 bk.


Cheers,
Bill


diff -Nur --exclude=SCCS --exclude=BitKeeper --exclude=ChangeSet linux-2.5/fs/proc/proc_misc.c lazy_buddy-2.5.39/fs/proc/proc_misc.c
--- linux-2.5/fs/proc/proc_misc.c	Thu Sep 26 01:44:11 2002
+++ lazy_buddy-2.5.39/fs/proc/proc_misc.c	Thu Sep 26 02:13:29 2002
@@ -133,6 +133,7 @@
 static int meminfo_read_proc(char *page, char **start, off_t off,
 				 int count, int *eof, void *data)
 {
+	extern unsigned long nr_deferred_pages(void);
 	struct sysinfo i;
 	int len, committed;
 	struct page_state ps;
@@ -170,6 +171,7 @@
 		"SwapFree:     %8lu kB\n"
 		"Dirty:        %8lu kB\n"
 		"Writeback:    %8lu kB\n"
+		"Deferred:     %8lu kB\n"
 		"Mapped:       %8lu kB\n"
 		"Slab:         %8lu kB\n"
 		"Committed_AS: %8u kB\n"
@@ -191,6 +193,7 @@
 		K(i.freeswap),
 		K(ps.nr_dirty),
 		K(ps.nr_writeback),
+		K(nr_deferred_pages()),
 		K(ps.nr_mapped),
 		K(ps.nr_slab),
 		K(committed),
@@ -215,6 +218,21 @@
 #undef K
 }
 
+extern struct seq_operations fragmentation_op;
+static int fragmentation_open(struct inode *inode, struct file *file)
+{
+	(void)inode;
+	return seq_open(file, &fragmentation_op);
+}
+
+static struct file_operations fragmentation_file_operations = {
+	open:		fragmentation_open,
+	read:		seq_read,
+	llseek:		seq_lseek,
+	release:	seq_release,
+};
+
+
 static int version_read_proc(char *page, char **start, off_t off,
 				 int count, int *eof, void *data)
 {
@@ -631,6 +649,7 @@
 	create_seq_entry("partitions", 0, &proc_partitions_operations);
 	create_seq_entry("interrupts", 0, &proc_interrupts_operations);
 	create_seq_entry("slabinfo",S_IWUSR|S_IRUGO,&proc_slabinfo_operations);
+	create_seq_entry("fraginfo",S_IRUGO, &fragmentation_file_operations);
 #ifdef CONFIG_MODULES
 	create_seq_entry("modules", 0, &proc_modules_operations);
 	create_seq_entry("ksyms", 0, &proc_ksyms_operations);
diff -Nur --exclude=SCCS --exclude=BitKeeper --exclude=ChangeSet linux-2.5/include/linux/mmzone.h lazy_buddy-2.5.39/include/linux/mmzone.h
--- linux-2.5/include/linux/mmzone.h	Thu Sep 26 01:44:25 2002
+++ lazy_buddy-2.5.39/include/linux/mmzone.h	Thu Sep 26 02:13:37 2002
@@ -25,8 +25,9 @@
 #endif
 
 typedef struct free_area_struct {
-	struct list_head	free_list;
-	unsigned long		*map;
+	unsigned long		globally_free, active, locally_free;
+	struct list_head	free_list, deferred_pages;
+	unsigned long	*map;
 } free_area_t;
 
 struct pglist_data;
diff -Nur --exclude=SCCS --exclude=BitKeeper --exclude=ChangeSet linux-2.5/mm/page_alloc.c lazy_buddy-2.5.39/mm/page_alloc.c
--- linux-2.5/mm/page_alloc.c	Thu Sep 26 01:44:29 2002
+++ lazy_buddy-2.5.39/mm/page_alloc.c	Thu Sep 26 02:13:38 2002
@@ -10,6 +10,7 @@
  *  Reshaped it to be a zoned allocator, Ingo Molnar, Red Hat, 1999
  *  Discontiguous memory support, Kanoj Sarcar, SGI, Nov 1999
  *  Zone balancing, Kanoj Sarcar, SGI, Jan 2000
+ *  Lazy buddy allocation, William Irwin, IBM, May 2002
  */
 
 #include <linux/config.h>
@@ -79,13 +80,9 @@
  * -- wli
  */
 
+static void FASTCALL(low_level_free(struct page *page, unsigned int order));
 void __free_pages_ok (struct page *page, unsigned int order)
 {
-	unsigned long index, page_idx, mask, flags;
-	free_area_t *area;
-	struct page *base;
-	struct zone *zone;
-
 	KERNEL_STAT_ADD(pgfree, 1<<order);
 
 	BUG_ON(PageLRU(page));
@@ -104,12 +101,22 @@
 			list_add(&page->list, &current->local_pages);
 			page->index = order;
 			current->nr_local_pages++;
-			goto out;
+			return;
 		}
 	}
 
-	zone = page_zone(page);
+	low_level_free(page, order);
+}
+
+static void FASTCALL(buddy_free(struct page *, int order));
+static void buddy_free(struct page *page, int order)
+{
+	unsigned long index, page_idx, mask;
+	free_area_t *area;
+	struct page *base;
+	struct zone *zone;
 
+	zone = page_zone(page);
 	mask = (~0UL) << order;
 	base = zone->zone_mem_map;
 	page_idx = page - base;
@@ -118,8 +125,6 @@
 	index = page_idx >> (1 + order);
 	area = zone->free_area + order;
 
-	spin_lock_irqsave(&zone->lock, flags);
-	zone->free_pages -= mask;
 	while (mask + (1 << (MAX_ORDER-1))) {
 		struct page *buddy1, *buddy2;
 
@@ -139,15 +144,74 @@
 		BUG_ON(bad_range(zone, buddy1));
 		BUG_ON(bad_range(zone, buddy2));
 		list_del(&buddy1->list);
+		area->globally_free--;
 		mask <<= 1;
 		area++;
 		index >>= 1;
 		page_idx &= mask;
 	}
 	list_add(&(base + page_idx)->list, &area->free_list);
+	area->globally_free++;
+}
+
+/*
+ * Deferred coalescing for the page-level allocator. Each size of memory
+ * block has 3 different variables associated with it:
+ * (1) active			-- granted to a caller
+ * (2) locally free		-- on the deferred coalescing queues
+ * (3) globally free		-- marked on the buddy bitmap
+ *
+ * The algorithm must enforce the invariant that active >= locally_free.
+ * There are three distinct regimes (states) identified by the allocator:
+ *
+ * (1) lazy regime		-- area->active > area->locally_free + 1
+ *	allocate and free from deferred queues
+ * (2) reclaiming regime	-- area->active == area->locally_free + 1
+ *	allocate and free from buddy queues
+ * (3) accelerated regime	-- area->active == area->locally_free
+ *	allocate and free from buddy queues, plus free extra deferred pages
+ */
+static void low_level_free(struct page *page, unsigned int order)
+{
+	struct zone *zone = page_zone(page);
+	unsigned long offset;
+	unsigned long flags;
+	free_area_t *area;
+	struct page *deferred_page;
+
+	spin_lock_irqsave(&zone->lock, flags);
+
+	offset = page - zone->zone_mem_map;
+	area = &zone->free_area[order];
+
+	switch (area->active - area->locally_free) {
+		case 0:
+			/*
+			 * Free a deferred page; this is the accelerated
+			 * regime for page coalescing.
+			 */
+			if (likely(!list_empty(&area->deferred_pages))) {
+				deferred_page = list_entry(area->deferred_pages.next, struct page, list);
+				list_del(&deferred_page->list);
+				area->locally_free--;
+				buddy_free(deferred_page, order);
+			}
+			/*
+			 * Fall through and also free the page we were
+			 * originally asked to free.
+			 */
+		case 1:
+			buddy_free(page, order);
+			break;
+		default:
+			list_add(&page->list, &area->deferred_pages);
+			area->locally_free++;
+			break;
+	}
+
+	area->active -= min(area->active, 1UL);
+	zone->free_pages += 1UL << order;
 	spin_unlock_irqrestore(&zone->lock, flags);
-out:
-	return;
 }
 
 #define MARK_USED(index, order, area) \
@@ -164,6 +228,7 @@
 		area--;
 		high--;
 		size >>= 1;
+		area->globally_free++;
 		list_add(&page->list, &area->free_list);
 		MARK_USED(index, high, area);
 		index += size;
@@ -192,15 +257,20 @@
 	set_page_count(page, 1);
 }
 
-static struct page *rmqueue(struct zone *zone, unsigned int order)
+/*
+ * Mark the bitmap checking our buddy, and descend levels breaking off
+ * free fragments in the bitmap along the way. When done, wrap up with
+ * the single pass of expand() to break off the various fragments from
+ * the free lists.
+ */
+static FASTCALL(struct page *buddy_alloc(struct zone *, unsigned int));
+static struct page *buddy_alloc(struct zone *zone, unsigned int order)
 {
 	free_area_t * area = zone->free_area + order;
 	unsigned int curr_order = order;
 	struct list_head *head, *curr;
-	unsigned long flags;
 	struct page *page;
 
-	spin_lock_irqsave(&zone->lock, flags);
 	do {
 		head = &area->free_list;
 		curr = head->next;
@@ -214,25 +284,140 @@
 			index = page - zone->zone_mem_map;
 			if (curr_order != MAX_ORDER-1)
 				MARK_USED(index, curr_order, area);
-			zone->free_pages -= 1UL << order;
+			area->globally_free--;
 
 			page = expand(zone, page, index, order, curr_order, area);
-			spin_unlock_irqrestore(&zone->lock, flags);
 
 			if (bad_range(zone, page))
 				BUG();
-			prep_new_page(page);
 			return page;	
 		}
 		curr_order++;
 		area++;
 	} while (curr_order < MAX_ORDER);
-	spin_unlock_irqrestore(&zone->lock, flags);
 
 	return NULL;
 }
 
+/*
+ * split_pages() is much like expand, but operates only on the queues
+ * of deferred coalesced pages.
+ */
+static void FASTCALL(split_pages(struct zone *, struct page *, int, int));
+static void split_pages(struct zone *zone, struct page *page,
+			int page_order, int deferred_order)
+{
+	int split_order;
+	unsigned long split_offset;
+	struct page *split_page;
+
+	split_order = deferred_order - 1;
+	split_offset = 1UL << split_order;
+	while (split_order >= page_order) {
+		split_page = &page[split_offset];
+		list_add(&split_page->list, &zone->free_area[split_order].deferred_pages);
+		zone->free_area[split_order].locally_free++;
+		--split_order;
+		split_offset >>= 1;
+	}
+}
+
+#define COALESCE_BATCH 256
+
+/*
+ * Support for on-demand splitting and coalescing from deferred queues.
+ */
+static struct page *FASTCALL(steal_deferred_page(struct zone *, int));
+static struct page *steal_deferred_page(struct zone *zone, int order)
+{
+	struct page *page;
+	struct list_head *elem;
+	free_area_t *area = zone->free_area;
+	int found_order, k;
+
+	/*
+	 * There aren't enough pages to satisfy the allocation.
+	 * Don't bother trying.
+	 */
+	if (zone->free_pages < (1 << order))
+		return NULL;
+
+	/*
+	 * Steal a page off of a higher-order deferred queue if possible.
+	 */
+	for (found_order = order+1; found_order < MAX_ORDER; ++found_order)
+		if (!list_empty(&area[found_order].deferred_pages))
+			goto found_page;
+
+	/*
+	 * Now enter the method of last resort. The contiguous block of
+	 * memory may be split into tiny pieces. To detect contiguity,
+	 * walk the deferred queues and insert pages into the buddy
+	 * bitmaps until enough adjacencies have hopefully been created
+	 * to satisfy the allocation. About the only reason to do
+	 * something this slow is that it is still faster than I/O.
+	 */
+	for (found_order = order - 1; found_order >= 0; --found_order) {
+		for (k = 0; k < COALESCE_BATCH; ++k) {
+			if (list_empty(&area[found_order].deferred_pages))
+				break;
+
+			elem = area[found_order].deferred_pages.next;
+			page = list_entry(elem, struct page, list);
+
+			list_del(&page->list);
+			area[found_order].locally_free--;
+			buddy_free(page, found_order);
+		}
+
+		page = buddy_alloc(zone, order);
+		if (page)
+			return page;
+	}
+
+	/*
+	 * One last attempt to extract a sufficiently contiguous block
+	 * from the buddy bitmaps.
+	 */
+	return buddy_alloc(zone, order);
+
+found_page:
+	elem = area[found_order].deferred_pages.next;
+	page = list_entry(elem, struct page, list);
+	list_del(&page->list);
+	area[found_order].locally_free--;
+	split_pages(zone, page, order, found_order);
+	return page;
+}
+
 #ifdef CONFIG_SOFTWARE_SUSPEND
+/*
+ * In order satisfy high-order boottime allocations a further pass is
+ * made at boot-time to fully coalesce all pages. Furthermore, swsusp
+ * also seems to want to be able to detect free regions by making use
+ * of full coalescing, and so the functionality is provided here.
+ */
+static void forced_coalesce(struct zone *zone)
+{
+	int order;
+	struct page *page;
+	free_area_t *area;
+	list_t *save, *elem;
+
+	if (!zone->size)
+		return;
+
+	for (order = MAX_ORDER - 1; order >= 0; --order) {
+		area = &zone->free_area[order];
+		list_for_each_safe(elem, save, &area->deferred_pages) {
+			page = list_entry(elem, struct page, list);
+			list_del(&page->list);
+			area->locally_free--;
+			buddy_free(page, order);
+		}
+	}
+}
+
 int is_head_of_free_region(struct page *page)
 {
         struct zone *zone = page_zone(page);
@@ -245,6 +430,7 @@
 	 * suspend anyway, but...
 	 */
 	spin_lock_irqsave(&zone->lock, flags);
+	forced_coalesce(zone);
 	for (order = MAX_ORDER - 1; order >= 0; --order)
 		list_for_each(curr, &zone->free_area[order].free_list)
 			if (page == list_entry(curr, struct page, list)) {
@@ -256,6 +442,42 @@
 }
 #endif /* CONFIG_SOFTWARE_SUSPEND */
 
+/*
+ * low_level_alloc() exports free page search functionality to the
+ * internal VM allocator. It uses the strategy outlined above
+ * low_level_free() in order to decide where to obtain its pages.
+ */
+static FASTCALL(struct page *low_level_alloc(struct zone *, unsigned int));
+static struct page *low_level_alloc(struct zone *zone, unsigned int order)
+{
+	struct page *page;
+	unsigned long flags;
+	free_area_t *area;
+
+	spin_lock_irqsave(&zone->lock, flags);
+
+	area = &zone->free_area[order];
+
+	if (likely(!list_empty(&area->deferred_pages))) {
+		page = list_entry(area->deferred_pages.next, struct page, list);
+		list_del(&page->list);
+		area->locally_free--;
+	} else
+		page = buddy_alloc(zone, order);
+	if (unlikely(!page)) {
+		page = steal_deferred_page(zone, order);
+		if (likely(!page))
+		goto out;
+	}
+
+	prep_new_page(page);
+	area->active++;
+	zone->free_pages -= 1UL << order;
+out:
+	spin_unlock_irqrestore(&zone->lock, flags);
+	return page;
+}
+
 static /* inline */ struct page *
 balance_classzone(struct zone* classzone, unsigned int gfp_mask,
 			unsigned int order, int * freed)
@@ -339,7 +561,7 @@
 		/* the incremental min is allegedly to discourage fallback */
 		min += z->pages_low;
 		if (z->free_pages > min || z->free_pages >= z->pages_high) {
-			page = rmqueue(z, order);
+			page = low_level_alloc(z, order);
 			if (page)
 				return page;
 		}
@@ -362,7 +584,7 @@
 			local_min >>= 2;
 		min += local_min;
 		if (z->free_pages > min || z->free_pages >= z->pages_high) {
-			page = rmqueue(z, order);
+			page = low_level_alloc(z, order);
 			if (page)
 				return page;
 		}
@@ -376,7 +598,7 @@
 		for (i = 0; zones[i] != NULL; i++) {
 			struct zone *z = zones[i];
 
-			page = rmqueue(z, order);
+			page = low_level_alloc(z, order);
 			if (page)
 				return page;
 		}
@@ -405,7 +627,7 @@
 
 		min += z->pages_min;
 		if (z->free_pages > min || z->free_pages >= z->pages_high) {
-			page = rmqueue(z, order);
+			page = low_level_alloc(z, order);
 			if (page)
 				return page;
 		}
@@ -538,11 +760,21 @@
 
 	for_each_pgdat(pgdat)
 		pages += pgdat->node_zones[ZONE_HIGHMEM].free_pages;
-
 	return pages;
 }
 #endif
 
+unsigned long nr_deferred_pages(void)
+{
+	struct zone *zone;
+	unsigned long order, pages = 0;
+
+	for_each_zone(zone)
+		for (order = 0; order < MAX_ORDER; ++order)
+			pages += zone->free_area[order].locally_free << order;
+	return pages;
+}
+
 /*
  * Accumulate the page_state information across all CPUs.
  * The result is unavoidably approximate - it can change
@@ -917,6 +1149,7 @@
 		local_offset += size;
 		for (i = 0; ; i++) {
 			unsigned long bitmap_size;
+			INIT_LIST_HEAD(&zone->free_area[i].deferred_pages);
 
 			INIT_LIST_HEAD(&zone->free_area[i].free_list);
 			if (i == MAX_ORDER-1) {
@@ -975,3 +1208,72 @@
 }
 
 __setup("memfrac=", setup_mem_frac);
+
+#ifdef CONFIG_PROC_FS
+
+#include <linux/seq_file.h>
+
+static void *frag_start(struct seq_file *m, loff_t *pos)
+{
+	pg_data_t *pgdat;
+	loff_t node = *pos;
+
+	(void)m;
+
+	for (pgdat = pgdat_list; pgdat && node; pgdat = pgdat->pgdat_next)
+		--node;
+
+	return pgdat;
+}
+
+static void *frag_next(struct seq_file *m, void *arg, loff_t *pos)
+{
+	pg_data_t *pgdat = (pg_data_t *)arg;
+
+	(void)m;
+	(*pos)++;
+	return pgdat->pgdat_next;
+}
+
+static void frag_stop(struct seq_file *m, void *arg)
+{
+}
+
+/*
+ * Render fragmentation statistics for /proc/ reporting.
+ * It simply formats the counters maintained by the queueing
+ * discipline in the buffer passed to it.
+ */
+static int frag_show(struct seq_file *m, void *arg)
+{
+	pg_data_t *pgdat = (pg_data_t *)arg;
+	struct zone *zone, *node_zones = pgdat->node_zones;
+	unsigned long flags;
+	int order;
+
+	for (zone = node_zones; zone - node_zones < MAX_NR_ZONES; ++zone) {
+		spin_lock_irqsave(&zone->lock, flags);
+		seq_printf(m, "Node %d, zone %8s\n", pgdat->node_id, zone->name);
+		seq_puts(m, "buddy:  ");
+		for (order = 0; order < MAX_ORDER; ++order)
+			seq_printf(m, "%6lu ", zone->free_area[order].globally_free);
+		seq_puts(m, "\ndefer:  ");
+		for (order = 0; order < MAX_ORDER; ++order)
+			seq_printf(m, "%6lu ", zone->free_area[order].locally_free);
+		seq_puts(m, "\nactive: ");
+		for (order = 0; order < MAX_ORDER; ++order)
+			seq_printf(m, "%6lu ", zone->free_area[order].active);
+		spin_unlock_irqrestore(&zone->lock, flags);
+		seq_putc(m, '\n');
+	}
+	return 0;
+}
+
+struct seq_operations fragmentation_op = {
+	start:	frag_start,
+	next:	frag_next,
+	stop:	frag_stop,
+	show:	frag_show,
+};
+
+#endif /* CONFIG_PROC_FS */
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
