Received: from there (h164n1fls31o925.telia.com [213.65.254.164])
	by mailg.telia.com (8.11.2/8.11.0) with SMTP id f7L0Mf320610
	for <linux-mm@kvack.org>; Tue, 21 Aug 2001 02:22:41 +0200 (CEST)
Message-Id: <200108210022.f7L0Mf320610@mailg.telia.com>
Content-Type: text/plain;
  charset="iso-8859-1"
From: Roger Larsson <roger.larsson@norran.net>
Subject: [PATCH][RFC] using a memory_clock_interval
Date: Tue, 21 Aug 2001 02:18:20 +0200
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

It runs, lets ship it...

First version of a patch that tries to USE a memory_clock to determine
when to run kswapd...

Limits needs tuning... but it runs with almost identical performace as the
original.
Note: that the rubberband is only for debug use...

I will update it for latest kernel... but it might be a week away...

/RogerL

-- 
Roger Larsson
Skelleftea
Sweden


*******************************************
Patch prepared by: roger.larsson@norran.net

--- linux/mm/vmscan.c.orig	Wed Aug 15 23:28:31 2001
+++ linux/mm/vmscan.c	Sat Aug 18 01:38:09 2001
@@ -70,7 +70,8 @@
 	inactive += zone->inactive_clean_pages;
 	inactive += zone->free_pages;
 
-	return (inactive > (zone->size / 3));
+	return (inactive > zone->pages_high +
+		2*pager_daemon.memory_clock_interval);
 }
 
 static unsigned int zone_free_plenty(zone_t *zone)
@@ -80,7 +81,7 @@
 	free = zone->free_pages;
 	free += zone->inactive_clean_pages;
 
-	return free > zone->pages_high*2;
+	return free > zone->pages_high + pager_daemon.memory_clock_interval;
 }
 
 /* mm->page_table_lock is held. mmap_sem is not held */
@@ -445,19 +446,37 @@
 	goto out;
 
 found_page:
-	memory_pressure++;
 	del_page_from_inactive_clean_list(page);
 	UnlockPage(page);
 	page->age = PAGE_AGE_START;
 	if (page_count(page) != 1)
 		printk("VM: reclaim_page, found page with count %d!\n",
 				page_count(page));
+
+
+
 out:
 	spin_unlock(&pagemap_lru_lock);
 	spin_unlock(&pagecache_lock);
 	return page;
 }
 
+void memory_clock_tick()
+{
+	static int memory_clock_prev;
+
+	memory_clock++;
+	
+	/* prevent dangerous wrap difference due to extremely fast allocs */
+	if (memory_clock - memory_clock_rubberband >= MEMORY_CLOCK_MAX_DIFF)
+		memory_clock_rubberband++;
+ 
+	if (memory_clock - memory_clock_prev >= pager_daemon.memory_clock_interval) 
{
+		memory_clock_prev = memory_clock;
+		wakeup_kswapd();
+	}
+}
+
 /**
  * page_launder - clean dirty inactive pages, move to inactive_clean list
  * @gfp_mask: what operations we are allowed to do
@@ -743,7 +762,7 @@
 {
 	pg_data_t *pgdat;
 	unsigned int global_free = 0;
-	unsigned int global_target = freepages.high;
+	unsigned int global_target = freepages.low;
 
 	/* Are we low on free pages anywhere? */
 	pgdat = pgdat_list;
@@ -778,7 +797,7 @@
 int inactive_shortage(void)
 {
 	pg_data_t *pgdat;
-	unsigned int global_target = freepages.high + inactive_target;
+	unsigned int global_target = freepages.high + 
pager_daemon.memory_clock_interval;
 	unsigned int global_incative = 0;
 
 	pgdat = pgdat_list;
@@ -914,15 +933,8 @@
 	 * Kswapd main loop.
 	 */
 	for (;;) {
-		static long recalc = 0;
-
-		/* Once a second ... */
-		if (time_after(jiffies, recalc + HZ)) {
-			recalc = jiffies;
-
-			/* Recalculate VM statistics. */
-			recalculate_vm_stats();
-		}
+		/* Recalculate VM statistics. Time independent implementation */
+		recalculate_vm_stats();
 
 		if (!do_try_to_free_pages(GFP_KSWAPD, 1)) {
 			if (out_of_memory())
@@ -931,7 +943,7 @@
 		}
 
 		run_task_queue(&tq_disk);
-		interruptible_sleep_on_timeout(&kswapd_wait, HZ);
+		interruptible_sleep_on_timeout(&kswapd_wait, 10*HZ);
 	}
 }
 
--- linux/mm/page_alloc.c.orig	Wed Aug 15 23:55:24 2001
+++ linux/mm/page_alloc.c	Sat Aug 18 01:08:54 2001
@@ -135,14 +135,6 @@
 	memlist_add_head(&(base + page_idx)->list, &area->free_list);
 
 	spin_unlock_irqrestore(&zone->lock, flags);
-
-	/*
-	 * We don't want to protect this variable from race conditions
-	 * since it's nothing important, but we do want to make sure
-	 * it never gets negative.
-	 */
-	if (memory_pressure > NR_CPUS)
-		memory_pressure--;
 }
 
 #define MARK_USED(index, order, area) \
@@ -286,11 +278,6 @@
 	struct page * page;
 
 	/*
-	 * Allocations put pressure on the VM subsystem.
-	 */
-	memory_pressure++;
-
-	/*
 	 * (If anyone calls gfp from interrupts nonatomically then it
 	 * will sooner or later tripped up by a schedule().)
 	 *
@@ -343,6 +330,11 @@
 		return page;
 
 	/*
+	 * Reclaiming a page results in pressure on the VM subsystem.
+	 */
+	memory_clock_tick();
+
+	/*
 	 * Then try to allocate a page from a zone with more
 	 * than zone->pages_low free + inactive_clean pages.
 	 *
@@ -371,8 +363,8 @@
 	 * - if we don't have __GFP_IO set, kswapd may be
 	 *   able to free some memory we can't free ourselves
 	 */
-	wakeup_kswapd();
 	if (gfp_mask & __GFP_WAIT) {
+		wakeup_kswapd(); /* only wakeup if we will sleep */
 		__set_current_state(TASK_RUNNING);
 		current->policy |= SCHED_YIELD;
 		schedule();
@@ -502,7 +494,7 @@
 	}
 
 	/* No luck.. */
-	printk(KERN_ERR "__alloc_pages: %lu-order allocation failed.\n", order);
+	printk(KERN_ERR "__alloc_pages: %lu-order, 0x%lx-flags allocation 
failed.\n", order, current->flags);
 	return NULL;
 }
 
--- linux/mm/swap.c.orig	Wed Aug 15 23:58:30 2001
+++ linux/mm/swap.c	Fri Aug 17 23:20:19 2001
@@ -46,11 +46,11 @@
  * is doing, averaged over a minute. We use this to determine how
  * many inactive pages we should have.
  *
- * In reclaim_page and __alloc_pages: memory_pressure++
- * In __free_pages_ok: memory_pressure--
- * In recalculate_vm_stats the value is decayed (once a second)
+ * In reclaim_page: memory_clock++
+ * In recalculate_vm_stats the memory_clock_rubberband is moved (once a 
second)
  */
-int memory_pressure;
+int memory_clock;
+int memory_clock_rubberband;
 
 /* We track the number of pages currently being asynchronously swapped
    out, so that we don't try to swap TOO many pages out at once */
@@ -72,6 +72,7 @@
 	512,	/* base number for calculating the number of tries */
 	SWAP_CLUSTER_MAX,	/* minimum number of tries */
 	8,	/* do swap I/O in clusters of this size */
+	1000,   /* memory_clock_interval */
 };
 
 /**
@@ -201,13 +202,34 @@
  * some useful statistics the VM subsystem uses to determine
  * its behaviour.
  */
+
 void recalculate_vm_stats(void)
 {
-	/*
-	 * Substract one second worth of memory_pressure from
-	 * memory_pressure.
-	 */
-	memory_pressure -= (memory_pressure >> INACTIVE_SHIFT);
+	static unsigned long jiffies_at_prev_update;
+	unsigned long jiffies_now = jiffies;
+
+	if (jiffies_now != jiffies_at_prev_update)
+	{
+		long elapsed = jiffies_now - jiffies_at_prev_update;
+
+		/*
+		 * Substract one second worth of memory_pressure from
+		 * memory_pressure.
+		 */
+		int old = memory_clock_rubberband;
+
+		/* "exact" formula... can be optimised */
+		int diff = (elapsed * (memory_clock - old) + (MEMORY_CLOCK_WINDOW * HZ + 
elapsed - 1)) / (MEMORY_CLOCK_WINDOW * HZ + elapsed);
+		
+		/* new can NEVER pass memory_clock since this is the only place were it is 
changed if the values
+		 * are close but it will sooner or later catch up with it */
+		int new = old + diff;
+
+		memory_clock_rubberband = new;
+
+		jiffies_at_prev_update = jiffies_now;
+		printk("VM: clock %5d target %5d\n", memory_clock, inactive_target);
+	}
 }
 
 /*
--- linux/include/linux/swap.h.orig	Wed Aug 15 23:36:27 2001
+++ linux/include/linux/swap.h	Fri Aug 17 22:34:57 2001
@@ -99,7 +99,8 @@
 struct zone_t;
 
 /* linux/mm/swap.c */
-extern int memory_pressure;
+extern int memory_clock;
+extern int memory_clock_rubberband;
 extern void deactivate_page(struct page *);
 extern void deactivate_page_nolock(struct page *);
 extern void activate_page(struct page *);
@@ -119,6 +120,7 @@
 extern int inactive_shortage(void);
 extern void wakeup_kswapd(void);
 extern int try_to_free_pages(unsigned int gfp_mask);
+extern void memory_clock_tick(void); /* TODO: move this to swap.c or 
t.o.w.a. */
 
 /* linux/mm/page_io.c */
 extern void rw_swap_page(int, struct page *);
@@ -249,16 +251,27 @@
 	ZERO_PAGE_BUG \
 }
 
+
+/*
+ * The memory_clock_rubberband is calculated to be
+ * approximately where memory_clock were for
+ * MEMORY_CLOCK_WINDOW seconds since.
+ * Note: please use a power of two...
+ */
+#define MEMORY_CLOCK_WINDOW 2
+
+/* to prevent overflow in calculations */
+#define MEMORY_CLOCK_MAX_DIFF ((1 << (8*sizeof(memory_clock) - 2)) / 
(MEMORY_CLOCK_WINDOW*HZ))
+
 /*
- * In mm/swap.c::recalculate_vm_stats(), we substract
- * inactive_target from memory_pressure every second.
- * This means that memory_pressure is smoothed over
- * 64 (1 << INACTIVE_SHIFT) seconds.
+ * The inactive_target is measured in pages/second
+ * In mm/swap.c::recalculate_vm_stats(), we move
+ * the memory_clock_rubberband
+ * Note: difference can never be negative, unsigned wrap is taken care of
+ *
  */
-#define INACTIVE_SHIFT 6
-#define inactive_min(a,b) ((a) < (b) ? (a) : (b))
-#define inactive_target inactive_min((memory_pressure >> INACTIVE_SHIFT), \
-		(num_physpages / 4))
+#define inactive_target ((memory_clock - 
memory_clock_rubberband)/MEMORY_CLOCK_WINDOW)
+
 
 /*
  * Ugly ugly ugly HACK to make sure the inactive lists
--- linux/include/linux/swapctl.h.orig	Fri Aug 17 23:10:34 2001
+++ linux/include/linux/swapctl.h	Fri Aug 17 23:17:00 2001
@@ -23,13 +23,14 @@
 typedef freepages_v1 freepages_t;
 extern freepages_t freepages;
 
-typedef struct pager_daemon_v1
+typedef struct pager_daemon_v2
 {
 	unsigned int	tries_base;
 	unsigned int	tries_min;
 	unsigned int	swap_cluster;
-} pager_daemon_v1;
-typedef pager_daemon_v1 pager_daemon_t;
+	unsigned int    memory_clock_interval;
+} pager_daemon_v2;
+typedef pager_daemon_v2 pager_daemon_t;
 extern pager_daemon_t pager_daemon;
 
 #endif /* _LINUX_SWAPCTL_H */
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
