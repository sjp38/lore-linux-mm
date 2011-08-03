Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 226336B0169
	for <linux-mm@kvack.org>; Wed,  3 Aug 2011 03:55:09 -0400 (EDT)
Subject: Re: questions about memory hotplug
From: Shaohua Li <shaohua.li@intel.com>
In-Reply-To: <1312247376.15392.454.camel@sli10-conroe>
References: <20110729221230.GA3466@labbmf-linux.qualcomm.com>
	 <20110730093055.GA10672@sli10-conroe.sh.intel.com>
	 <20110801170850.GB3466@labbmf-linux.qualcomm.com>
	 <1312247376.15392.454.camel@sli10-conroe>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 03 Aug 2011 15:55:06 +0800
Message-ID: <1312358106.15392.466.camel@sli10-conroe>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Larry Bassel <lbassel@codeaurora.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Tue, 2011-08-02 at 09:09 +0800, Shaohua Li wrote:
> On Tue, 2011-08-02 at 01:08 +0800, Larry Bassel wrote:
> > 
> > In use case #1 yes, maybe not in #2 (we can arrange it to be
> > at the end of memory, but then might waste memory as it may
> > not be aligned on a SPARSEMEM section boundary and so would
> > need to be padded).
> then maybe the new migrate type I suggested can help here for the
> non-aligned memory. Anyway, let me do an experiment.
so your problem is to offline memory in arbitrary address and size (eg,
might not be at the end, and maybe smaller than a section)

I had a hack. In my machine, I have DMA, DMA32, and NORMAL zone.
At boot time, I mark 500M~600M ranges as MOVABLE_NOFB. the range is in
DMA32 and not section size aligned. MOVABLE_NOFB is a new migrate type I
added. That range memory is movable, but other type of allocation can't
fallback into such ranges. so such range memory can only be used by
userspace.
I then run a memory stress test and do memory online/offline for the
range at runtime, the offline always success.
Does this meet your usage? If yes, I'll cook it up a little bit.


---
 include/linux/gfp.h    |    5 +-
 include/linux/mmzone.h |    7 +-
 mm/memory_hotplug.c    |  117 ++++++++++++++++++++++++++++++++++---------------
 mm/page_alloc.c        |   94 +++++++++++++++++++++++++++++++++------
 mm/vmstat.c            |    1 
 5 files changed, 171 insertions(+), 53 deletions(-)

Index: linux/include/linux/gfp.h
===================================================================
--- linux.orig/include/linux/gfp.h	2011-08-03 14:59:47.000000000 +0800
+++ linux/include/linux/gfp.h	2011-08-03 15:24:52.000000000 +0800
@@ -155,8 +155,9 @@ static inline int allocflags_to_migratet
 		return MIGRATE_UNMOVABLE;
 
 	/* Group based on mobility */
-	return (((gfp_flags & __GFP_MOVABLE) != 0) << 1) |
-		((gfp_flags & __GFP_RECLAIMABLE) != 0);
+	if ((gfp_flags & __GFP_MOVABLE) != 0)
+		return MIGRATE_MOVABLE_NOFB;
+	return (gfp_flags & __GFP_RECLAIMABLE) != 0;
 }
 
 #ifdef CONFIG_HIGHMEM
Index: linux/include/linux/mmzone.h
===================================================================
--- linux.orig/include/linux/mmzone.h	2011-08-03 14:59:47.000000000 +0800
+++ linux/include/linux/mmzone.h	2011-08-03 15:24:52.000000000 +0800
@@ -39,9 +39,10 @@
 #define MIGRATE_RECLAIMABLE   1
 #define MIGRATE_MOVABLE       2
 #define MIGRATE_PCPTYPES      3 /* the number of types on the pcp lists */
-#define MIGRATE_RESERVE       3
-#define MIGRATE_ISOLATE       4 /* can't allocate from here */
-#define MIGRATE_TYPES         5
+#define MIGRATE_MOVABLE_NOFB  3
+#define MIGRATE_RESERVE       4
+#define MIGRATE_ISOLATE       5 /* can't allocate from here */
+#define MIGRATE_TYPES         6
 
 #define for_each_migratetype_order(order, type) \
 	for (order = 0; order < MAX_ORDER; order++) \
Index: linux/mm/page_alloc.c
===================================================================
--- linux.orig/mm/page_alloc.c	2011-08-03 14:59:47.000000000 +0800
+++ linux/mm/page_alloc.c	2011-08-03 15:25:29.000000000 +0800
@@ -627,7 +627,7 @@ static void free_pcppages_bulk(struct zo
 			page = list_entry(list->prev, struct page, lru);
 			/* must delete as __free_one_page list manipulates */
 			list_del(&page->lru);
-			/* MIGRATE_MOVABLE list may include MIGRATE_RESERVEs */
+			/* MIGRATE_MOVABLE list may include MIGRATE_RESERVE and MIGRATE_MOVABLE_NOFBs */
 			__free_one_page(page, zone, 0, page_private(page));
 			trace_mm_page_pcpu_drain(page, 0, page_private(page));
 		} while (--to_free && --batch_free && !list_empty(list));
@@ -828,10 +828,11 @@ struct page *__rmqueue_smallest(struct z
  * the free lists for the desirable migrate type are depleted
  */
 static int fallbacks[MIGRATE_TYPES][MIGRATE_TYPES-1] = {
-	[MIGRATE_UNMOVABLE]   = { MIGRATE_RECLAIMABLE, MIGRATE_MOVABLE,   MIGRATE_RESERVE },
-	[MIGRATE_RECLAIMABLE] = { MIGRATE_UNMOVABLE,   MIGRATE_MOVABLE,   MIGRATE_RESERVE },
-	[MIGRATE_MOVABLE]     = { MIGRATE_RECLAIMABLE, MIGRATE_UNMOVABLE, MIGRATE_RESERVE },
-	[MIGRATE_RESERVE]     = { MIGRATE_RESERVE,     MIGRATE_RESERVE,   MIGRATE_RESERVE }, /* Never used */
+	[MIGRATE_UNMOVABLE]   = { MIGRATE_RECLAIMABLE, MIGRATE_MOVABLE,   MIGRATE_RESERVE, MIGRATE_RESERVE },
+	[MIGRATE_RECLAIMABLE] = { MIGRATE_UNMOVABLE,   MIGRATE_MOVABLE,   MIGRATE_RESERVE, MIGRATE_RESERVE},
+	[MIGRATE_MOVABLE]     = { MIGRATE_RECLAIMABLE, MIGRATE_UNMOVABLE, MIGRATE_RESERVE, MIGRATE_RESERVE},
+	[MIGRATE_MOVABLE_NOFB] = { MIGRATE_MOVABLE, MIGRATE_RECLAIMABLE, MIGRATE_UNMOVABLE, MIGRATE_RESERVE}, /* Never used */
+	[MIGRATE_RESERVE]     = { MIGRATE_RESERVE,     MIGRATE_RESERVE,   MIGRATE_RESERVE, MIGRATE_RESERVE}, /* Never used */
 };
 
 /*
@@ -923,6 +924,7 @@ __rmqueue_fallback(struct zone *zone, in
 	struct page *page;
 	int migratetype, i;
 
+	BUG_ON(start_migratetype == MIGRATE_MOVABLE_NOFB);
 	/* Find the largest possible block of pages in the other list */
 	for (current_order = MAX_ORDER-1; current_order >= order;
 						--current_order) {
@@ -994,8 +996,16 @@ static struct page *__rmqueue(struct zon
 	struct page *page;
 
 retry_reserve:
+	/* FIXME: Speed up a little bit */
 	page = __rmqueue_smallest(zone, order, migratetype);
 
+	if (!page && migratetype == MIGRATE_MOVABLE_NOFB) {
+		/* Don't change other migrate type to MIGRATE_MOVABLE_NOFB, so
+		 * we shortcut here */
+		migratetype = MIGRATE_MOVABLE;
+		goto retry_reserve;
+	}
+
 	if (unlikely(!page) && migratetype != MIGRATE_RESERVE) {
 		page = __rmqueue_fallback(zone, order, migratetype);
 
@@ -1044,7 +1054,8 @@ static int rmqueue_bulk(struct zone *zon
 			list_add(&page->lru, list);
 		else
 			list_add_tail(&page->lru, list);
-		set_page_private(page, migratetype);
+		/* __rmqueue might do fallback, so reread the migrate type */
+		set_page_private(page, get_pageblock_migratetype(page));
 		list = &page->lru;
 	}
 	__mod_zone_page_state(zone, NR_FREE_PAGES, -(i << order));
@@ -1300,10 +1311,11 @@ again:
 	if (likely(order == 0)) {
 		struct per_cpu_pages *pcp;
 		struct list_head *list;
+		int migratetype_pcp = migratetype == MIGRATE_MOVABLE_NOFB? MIGRATE_MOVABLE : migratetype;
 
 		local_irq_save(flags);
 		pcp = &this_cpu_ptr(zone->pageset)->pcp;
-		list = &pcp->lists[migratetype];
+		list = &pcp->lists[migratetype_pcp];
 		if (list_empty(list)) {
 			pcp->count += rmqueue_bulk(zone, 0,
 					pcp->batch, list,
@@ -5558,7 +5570,8 @@ __count_immobile_pages(struct zone *zone
 	if (zone_idx(zone) == ZONE_MOVABLE)
 		return true;
 
-	if (get_pageblock_migratetype(page) == MIGRATE_MOVABLE)
+	if (get_pageblock_migratetype(page) == MIGRATE_MOVABLE ||
+	    get_pageblock_migratetype(page) == MIGRATE_MOVABLE_NOFB )
 		return true;
 
 	pfn = page_to_pfn(page);
@@ -5601,7 +5614,7 @@ bool is_pageblock_removable_nolock(struc
 	return __count_immobile_pages(zone, page, 0);
 }
 
-int set_migratetype_isolate(struct page *page)
+static int __set_migratetype(struct page *page, int migratetype)
 {
 	struct zone *zone;
 	unsigned long flags, pfn;
@@ -5647,8 +5660,8 @@ int set_migratetype_isolate(struct page
 
 out:
 	if (!ret) {
-		set_pageblock_migratetype(page, MIGRATE_ISOLATE);
-		move_freepages_block(zone, page, MIGRATE_ISOLATE);
+		set_pageblock_migratetype(page, migratetype);
+		move_freepages_block(zone, page, migratetype);
 	}
 
 	spin_unlock_irqrestore(&zone->lock, flags);
@@ -5657,6 +5670,11 @@ out:
 	return ret;
 }
 
+int set_migratetype_isolate(struct page *page)
+{
+	return __set_migratetype(page, MIGRATE_ISOLATE);
+}
+
 void unset_migratetype_isolate(struct page *page)
 {
 	struct zone *zone;
@@ -5665,12 +5683,18 @@ void unset_migratetype_isolate(struct pa
 	spin_lock_irqsave(&zone->lock, flags);
 	if (get_pageblock_migratetype(page) != MIGRATE_ISOLATE)
 		goto out;
-	set_pageblock_migratetype(page, MIGRATE_MOVABLE);
-	move_freepages_block(zone, page, MIGRATE_MOVABLE);
+	/* Fixme: should restore previous type */
+	set_pageblock_migratetype(page, MIGRATE_MOVABLE_NOFB);
+	move_freepages_block(zone, page, MIGRATE_MOVABLE_NOFB);
 out:
 	spin_unlock_irqrestore(&zone->lock, flags);
 }
 
+int set_migratetype_movable_nofb(struct page *page)
+{
+	return __set_migratetype(page, MIGRATE_MOVABLE_NOFB);
+}
+
 #ifdef CONFIG_MEMORY_HOTREMOVE
 /*
  * All pages in the range must be isolated before calling this.
@@ -5815,3 +5839,47 @@ void dump_page(struct page *page)
 	dump_page_flags(page->flags);
 	mem_cgroup_print_bad_page(page);
 }
+
+/* -------------- test ----------------------------------- */
+static int test_init(void)
+{
+	unsigned long start = 500*1024*1024L;
+	unsigned long end = 600*1024*1024L;
+	struct page *page;
+
+	/* both start and size must be pageblock and max buddy aligned */
+	while (start < end) {
+		int pfn = start >> PAGE_SHIFT;
+
+		page = pfn_to_page(pfn);
+		set_migratetype_movable_nofb(page);
+		start += pageblock_nr_pages * PAGE_SIZE;
+	}
+	return 0;
+}
+late_initcall(test_init);
+
+extern int isolate_memory(u64 start, u64 size);
+#define MODULE_PARAM_PREFIX "test."
+static int isolate_mm_set(const char *val, struct kernel_param *kp)
+{
+	if (!strncmp(val, "isolate", strlen("isolate") - 1))
+		isolate_memory(500*1024*1024L, 100*1024*1024L);
+	if (!strncmp(val, "use", strlen("use") - 1)) {
+		unsigned long start = 500*1024*1024L;
+		unsigned long end = 600*1024*1024L;
+		struct page *page;
+
+		/* both start and size must be pageblock and max buddy aligned */
+		while (start < end) {
+			int pfn = start >> PAGE_SHIFT;
+
+			page = pfn_to_page(pfn);
+			unset_migratetype_isolate(page);
+			start += pageblock_nr_pages * PAGE_SIZE;
+		}
+	}
+	return 0;
+}
+module_param_call(isolate_mm, isolate_mm_set, NULL, NULL, 0200);
+#undef MODULE_PARAM_PREFIX
Index: linux/mm/vmstat.c
===================================================================
--- linux.orig/mm/vmstat.c	2011-08-03 14:59:47.000000000 +0800
+++ linux/mm/vmstat.c	2011-08-03 15:24:52.000000000 +0800
@@ -612,6 +612,7 @@ static char * const migratetype_names[MI
 	"Unmovable",
 	"Reclaimable",
 	"Movable",
+	"Movable-nofb",
 	"Reserve",
 	"Isolate",
 };
Index: linux/mm/memory_hotplug.c
===================================================================
--- linux.orig/mm/memory_hotplug.c	2011-08-03 14:59:47.000000000 +0800
+++ linux/mm/memory_hotplug.c	2011-08-03 15:24:52.000000000 +0800
@@ -864,15 +864,9 @@ check_pages_isolated(unsigned long start
 	return offlined;
 }
 
-static int __ref offline_pages(unsigned long start_pfn,
-		  unsigned long end_pfn, unsigned long timeout)
+static int __ref offline_pages_check(unsigned long start_pfn,
+	unsigned long end_pfn)
 {
-	unsigned long pfn, nr_pages, expire;
-	long offlined_pages;
-	int ret, drain, retry_max, node;
-	struct zone *zone;
-	struct memory_notify arg;
-
 	BUG_ON(start_pfn >= end_pfn);
 	/* at least, alignment against pageblock is necessary */
 	if (!IS_ALIGNED(start_pfn, pageblock_nr_pages))
@@ -883,28 +877,14 @@ static int __ref offline_pages(unsigned
 	   we assume this for now. .*/
 	if (!test_pages_in_a_zone(start_pfn, end_pfn))
 		return -EINVAL;
+	return 0;
+}
 
-	lock_memory_hotplug();
-
-	zone = page_zone(pfn_to_page(start_pfn));
-	node = zone_to_nid(zone);
-	nr_pages = end_pfn - start_pfn;
-
-	/* set above range as isolated */
-	ret = start_isolate_page_range(start_pfn, end_pfn);
-	if (ret)
-		goto out;
-
-	arg.start_pfn = start_pfn;
-	arg.nr_pages = nr_pages;
-	arg.status_change_nid = -1;
-	if (nr_pages >= node_present_pages(node))
-		arg.status_change_nid = node;
-
-	ret = memory_notify(MEM_GOING_OFFLINE, &arg);
-	ret = notifier_to_errno(ret);
-	if (ret)
-		goto failed_removal;
+static int __ref offline_pages_migrate(unsigned long start_pfn,
+	unsigned long end_pfn, unsigned long timeout, long *offlined_pages)
+{
+	unsigned long pfn, expire;
+	int ret, drain, retry_max;
 
 	pfn = start_pfn;
 	expire = jiffies + timeout;
@@ -914,10 +894,10 @@ repeat:
 	/* start memory hot removal */
 	ret = -EAGAIN;
 	if (time_after(jiffies, expire))
-		goto failed_removal;
+		goto out;
 	ret = -EINTR;
 	if (signal_pending(current))
-		goto failed_removal;
+		goto out;
 	ret = 0;
 	if (drain) {
 		lru_add_drain_all();
@@ -934,7 +914,7 @@ repeat:
 		} else {
 			if (ret < 0)
 				if (--retry_max == 0)
-					goto failed_removal;
+					goto out;
 			yield();
 			drain = 1;
 			goto repeat;
@@ -946,11 +926,52 @@ repeat:
 	/* drain pcp pages , this is synchrouns. */
 	drain_all_pages();
 	/* check again */
-	offlined_pages = check_pages_isolated(start_pfn, end_pfn);
-	if (offlined_pages < 0) {
+	*offlined_pages = check_pages_isolated(start_pfn, end_pfn);
+	if (*offlined_pages < 0) {
 		ret = -EBUSY;
-		goto failed_removal;
+		goto out;
 	}
+out:
+	return ret;
+}
+
+static int __ref offline_pages(unsigned long start_pfn,
+		  unsigned long end_pfn, unsigned long timeout)
+{
+	unsigned long nr_pages;
+	long offlined_pages;
+	int ret, node;
+	struct zone *zone;
+	struct memory_notify arg;
+
+	if (offline_pages_check(start_pfn, end_pfn))
+		return -EINVAL;
+
+	lock_memory_hotplug();
+
+	zone = page_zone(pfn_to_page(start_pfn));
+	node = zone_to_nid(zone);
+	nr_pages = end_pfn - start_pfn;
+
+	/* set above range as isolated */
+	ret = start_isolate_page_range(start_pfn, end_pfn);
+	if (ret)
+		goto out;
+
+	arg.start_pfn = start_pfn;
+	arg.nr_pages = nr_pages;
+	arg.status_change_nid = -1;
+	if (nr_pages >= node_present_pages(node))
+		arg.status_change_nid = node;
+
+	ret = memory_notify(MEM_GOING_OFFLINE, &arg);
+	ret = notifier_to_errno(ret);
+	if (ret)
+		goto failed_removal;
+
+	ret = offline_pages_migrate(start_pfn, end_pfn, timeout, &offlined_pages);
+	if (ret)
+		goto failed_removal;
 	printk(KERN_INFO "Offlined Pages %ld\n", offlined_pages);
 	/* Ok, all of our target is islaoted.
 	   We cannot do rollback at this point. */
@@ -996,6 +1017,32 @@ int remove_memory(u64 start, u64 size)
 	end_pfn = start_pfn + PFN_DOWN(size);
 	return offline_pages(start_pfn, end_pfn, 120 * HZ);
 }
+
+int isolate_memory(u64 start, u64 size)
+{
+	unsigned long start_pfn, end_pfn;
+	long offlined_pages;
+	int ret;
+
+	start_pfn = PFN_DOWN(start);
+	end_pfn = start_pfn + PFN_DOWN(size);
+
+	if (offline_pages_check(start_pfn, end_pfn))
+		return -EINVAL;
+	lock_memory_hotplug();
+
+	/* set above range as isolated */
+	ret = start_isolate_page_range(start_pfn, end_pfn);
+	if (ret)
+		goto out;
+	ret = offline_pages_migrate(start_pfn, end_pfn,
+		120 * HZ, &offlined_pages);
+	if (ret)
+		undo_isolate_page_range(start_pfn, end_pfn);
+out:
+	unlock_memory_hotplug();
+	return ret;
+}
 #else
 int remove_memory(u64 start, u64 size)
 {


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
