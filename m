Subject: [PATCH] Recent VM fiasco - fixed
Reply-To: zlatko@iskon.hr
From: Zlatko Calusic <zlatko@iskon.hr>
Date: 08 May 2000 19:21:20 +0200
Message-ID: <dnzoq1x8j3.fsf@magla.iskon.hr>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="=-=-="
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
Cc: Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

--=-=-=

Hi to all!

After I _finally_ got tired of the constant worse and worse VM
behaviour in the recent kernels, I thought I could spare few hours
this weekend just to see what's going on. I was quite surprised to see
that VM subsystem, while at its worst condition (at least in 2.3.x),
is quite easily repairable even to unskilled ones... I compiled and
checked few kernels back to 2.3.51, and found that new code was
constantly added just to make things go worse. Short history:

2.3.51 - mostly OK, but reading from disk takes too much CPU (kswapd)
2.3.99-pre1, 2 - as .51 + aggressive swap out during writing
2.3.99-pre3, 4, 5 - reading better
2.3.99-pre5, 6 - both reading and writing take 100% CPU!!!

I also tried some pre7-x (forgot which one) but that one was f****d up
beyond a recognition (read: was killing my processes including X11
like mad, every time I started writing to disk). Thus patch that
follows, and fixes all above mentioned problems, was made against
pre6, sorry. I'll made another patch when pre7 gets out, if things are
still not properly fixed.

BTW, this patch mostly *removes* cruft recently added, and returns to
the known state of operation. After that is achieved it is then easy
to selectively add good things I might have removed, and change
behaviour as wanted, but I would like to urge people to test things
thoroughly before releasing patches this close to 2.4.

Then again, I might have introduced bugs in this patch, too. :)
But, I *tried* to break it (spent some time doing that), and testing
didn't reveal any bad behaviour.

Enjoy!


--=-=-=
Content-Disposition: attachment; filename=patch

Index: 9906.2/include/linux/swap.h
--- 9906.2/include/linux/swap.h Thu, 27 Apr 2000 22:11:43 +0200 zcalusic (linux/C/b/20_swap.h 1.4.1.15.1.1 644)
+++ 9906.5/include/linux/swap.h Sun, 07 May 2000 20:39:35 +0200 zcalusic (linux/C/b/20_swap.h 1.4.1.15.1.1.1.1 644)
@@ -87,7 +87,6 @@
 
 /* linux/mm/vmscan.c */
 extern int try_to_free_pages(unsigned int gfp_mask, zone_t *zone);
-extern int swap_out(unsigned int gfp_mask, int priority);
 
 /* linux/mm/page_io.c */
 extern void rw_swap_page(int, struct page *, int);
Index: 9906.2/mm/vmscan.c
--- 9906.2/mm/vmscan.c Thu, 27 Apr 2000 22:11:43 +0200 zcalusic (linux/F/b/13_vmscan.c 1.5.1.22 644)
+++ 9906.5/mm/vmscan.c Sun, 07 May 2000 20:39:35 +0200 zcalusic (linux/F/b/13_vmscan.c 1.5.1.22.2.1 644)
@@ -48,7 +48,6 @@
 	if ((page-mem_map >= max_mapnr) || PageReserved(page))
 		goto out_failed;
 
-	mm->swap_cnt--;
 	/* Don't look at this pte if it's been accessed recently. */
 	if (pte_young(pte)) {
 		/*
@@ -220,8 +219,6 @@
 		result = try_to_swap_out(mm, vma, address, pte, gfp_mask);
 		if (result)
 			return result;
-		if (!mm->swap_cnt)
-			return 0;
 		address += PAGE_SIZE;
 		pte++;
 	} while (address && (address < end));
@@ -251,8 +248,6 @@
 		int result = swap_out_pmd(mm, vma, pmd, address, end, gfp_mask);
 		if (result)
 			return result;
-		if (!mm->swap_cnt)
-			return 0;
 		address = (address + PMD_SIZE) & PMD_MASK;
 		pmd++;
 	} while (address && (address < end));
@@ -277,8 +272,6 @@
 		int result = swap_out_pgd(mm, vma, pgdir, address, end, gfp_mask);
 		if (result)
 			return result;
-		if (!mm->swap_cnt)
-			return 0;
 		address = (address + PGDIR_SIZE) & PGDIR_MASK;
 		pgdir++;
 	} while (address && (address < end));
@@ -328,7 +321,7 @@
  * N.B. This function returns only 0 or 1.  Return values != 1 from
  * the lower level routines result in continued processing.
  */
-int swap_out(unsigned int priority, int gfp_mask)
+static int swap_out(unsigned int priority, int gfp_mask)
 {
 	struct task_struct * p;
 	int counter;
@@ -363,7 +356,6 @@
 		p = init_task.next_task;
 		for (; p != &init_task; p = p->next_task) {
 			struct mm_struct *mm = p->mm;
-			p->hog = 0;
 			if (!p->swappable || !mm)
 				continue;
 	 		if (mm->rss <= 0)
@@ -377,26 +369,9 @@
 				pid = p->pid;
 			}
 		}
-		if (assign == 1) {
-			/* we just assigned swap_cnt, normalise values */
-			assign = 2;
-			p = init_task.next_task;
-			for (; p != &init_task; p = p->next_task) {
-				int i = 0;
-				struct mm_struct *mm = p->mm;
-				if (!p->swappable || !mm || mm->rss <= 0)
-					continue;
-				/* small processes are swapped out less */
-				while ((mm->swap_cnt << 2 * (i + 1) < max_cnt))
-					i++;
-				mm->swap_cnt >>= i;
-				mm->swap_cnt += i; /* if swap_cnt reaches 0 */
-				/* we're big -> hog treatment */
-				if (!i)
-					p->hog = 1;
-			}
-		}
 		read_unlock(&tasklist_lock);
+		if (assign == 1)
+			assign = 2;
 		if (!best) {
 			if (!assign) {
 				assign = 1;
@@ -437,14 +412,13 @@
 {
 	int priority;
 	int count = SWAP_CLUSTER_MAX;
-	int ret;
 
 	/* Always trim SLAB caches when memory gets low. */
 	kmem_cache_reap(gfp_mask);
 
 	priority = 6;
 	do {
-		while ((ret = shrink_mmap(priority, gfp_mask, zone))) {
+		while (shrink_mmap(priority, gfp_mask, zone)) {
 			if (!--count)
 				goto done;
 		}
@@ -467,9 +441,7 @@
 			}
 		}
 
-		/* Then, try to page stuff out..
-		 * We use swapcount here because this doesn't actually
-		 * free pages */
+		/* Then, try to page stuff out.. */
 		while (swap_out(priority, gfp_mask)) {
 			if (!--count)
 				goto done;
@@ -497,10 +469,7 @@
  */
 int kswapd(void *unused)
 {
-	int i;
 	struct task_struct *tsk = current;
-	pg_data_t *pgdat;
-	zone_t *zone;
 
 	tsk->session = 1;
 	tsk->pgrp = 1;
@@ -521,25 +490,38 @@
 	 */
 	tsk->flags |= PF_MEMALLOC;
 
-	while (1) {
+	for (;;) {
+		int work_to_do = 0;
+
 		/*
 		 * If we actually get into a low-memory situation,
 		 * the processes needing more memory will wake us
 		 * up on a more timely basis.
 		 */
-		pgdat = pgdat_list;
-		while (pgdat) {
-			for (i = 0; i < MAX_NR_ZONES; i++) {
-				zone = pgdat->node_zones + i;
-				if (tsk->need_resched)
-					schedule();
-				if ((!zone->size) || (!zone->zone_wake_kswapd))
-					continue;
-				do_try_to_free_pages(GFP_KSWAPD, zone);
+		do {
+			pg_data_t *pgdat = pgdat_list;
+
+			while (pgdat) {
+				int i;
+
+				for (i = 0; i < MAX_NR_ZONES; i++) {
+					zone_t *zone = pgdat->node_zones + i;
+
+					if (!zone->size)
+						continue;
+					if (!zone->low_on_memory)
+						continue;
+					work_to_do = 1;
+					do_try_to_free_pages(GFP_KSWAPD, zone);
+				}
+				pgdat = pgdat->node_next;
 			}
-			pgdat = pgdat->node_next;
-		}
-		run_task_queue(&tq_disk);
+			run_task_queue(&tq_disk);
+			if (tsk->need_resched)
+				break;
+			if (nr_free_pages() > freepages.high)
+				break;
+		} while (work_to_do);
 		tsk->state = TASK_INTERRUPTIBLE;
 		interruptible_sleep_on(&kswapd_wait);
 	}
Index: 9906.2/mm/filemap.c
--- 9906.2/mm/filemap.c Thu, 27 Apr 2000 22:11:43 +0200 zcalusic (linux/F/b/16_filemap.c 1.6.1.3.2.4.1.1.2.2.2.1.1.21.1.1 644)
+++ 9906.5/mm/filemap.c Sun, 07 May 2000 20:39:35 +0200 zcalusic (linux/F/b/16_filemap.c 1.6.1.3.2.4.1.1.2.2.2.1.1.21.1.1.2.1 644)
@@ -238,55 +238,41 @@
 
 int shrink_mmap(int priority, int gfp_mask, zone_t *zone)
 {
-	int ret = 0, loop = 0, count;
+	int ret = 0, count;
 	LIST_HEAD(young);
 	LIST_HEAD(old);
 	LIST_HEAD(forget);
 	struct list_head * page_lru, * dispose;
-	struct page * page = NULL;
-	struct zone_struct * p_zone;
-	int maxloop = 256 >> priority;
+	struct page * page;
 	
 	if (!zone)
 		BUG();
 
-	count = nr_lru_pages >> priority;
-	if (!count)
-		return ret;
+	count = nr_lru_pages / (priority+1);
 
 	spin_lock(&pagemap_lru_lock);
-again:
-	/* we need pagemap_lru_lock for list_del() ... subtle code below */
+
 	while (count > 0 && (page_lru = lru_cache.prev) != &lru_cache) {
 		page = list_entry(page_lru, struct page, lru);
 		list_del(page_lru);
-		p_zone = page->zone;
 
-		/*
-		 * These two tests are there to make sure we don't free too
-		 * many pages from the "wrong" zone. We free some anyway,
-		 * they are the least recently used pages in the system.
-		 * When we don't free them, leave them in &old.
-		 */
-		dispose = &old;
-		if (p_zone != zone && (loop > (maxloop / 4) ||
-				p_zone->free_pages > p_zone->pages_high))
+		dispose = &lru_cache;
+		if (test_and_clear_bit(PG_referenced, &page->flags))
+			/* Roll the page at the top of the lru list,
+			 * we could also be more aggressive putting
+			 * the page in the young-dispose-list, so
+			 * avoiding to free young pages in each pass.
+			 */
 			goto dispose_continue;
 
-		/* The page is in use, or was used very recently, put it in
-		 * &young to make sure that we won't try to free it the next
-		 * time */
-		dispose = &young;
-
-		if (test_and_clear_bit(PG_referenced, &page->flags))
+		dispose = &old;
+		/* don't account passes over not DMA pages */
+		if (zone && (!memclass(page->zone, zone)))
 			goto dispose_continue;
 
 		count--;
-		if (!page->buffers && page_count(page) > 1)
-			goto dispose_continue;
 
-		/* Page not used -> free it; if that fails -> &old */
-		dispose = &old;
+		dispose = &young;
 		if (TryLockPage(page))
 			goto dispose_continue;
 
@@ -297,11 +283,22 @@
 		   page locked down ;). */
 		spin_unlock(&pagemap_lru_lock);
 
+		/* avoid unscalable SMP locking */
+		if (!page->buffers && page_count(page) > 1)
+			goto unlock_noput_continue;
+
+		/* Take the pagecache_lock spinlock held to avoid
+		   other tasks to notice the page while we are looking at its
+		   page count. If it's a pagecache-page we'll free it
+		   in one atomic transaction after checking its page count. */
+		spin_lock(&pagecache_lock);
+
 		/* avoid freeing the page while it's locked */
 		get_page(page);
 
 		/* Is it a buffer page? */
 		if (page->buffers) {
+			spin_unlock(&pagecache_lock);
 			if (!try_to_free_buffers(page))
 				goto unlock_continue;
 			/* page was locked, inode can't go away under us */
@@ -309,14 +306,9 @@
 				atomic_dec(&buffermem_pages);
 				goto made_buffer_progress;
 			}
+			spin_lock(&pagecache_lock);
 		}
 
-		/* Take the pagecache_lock spinlock held to avoid
-		   other tasks to notice the page while we are looking at its
-		   page count. If it's a pagecache-page we'll free it
-		   in one atomic transaction after checking its page count. */
-		spin_lock(&pagecache_lock);
-
 		/*
 		 * We can't free pages unless there's just one user
 		 * (count == 2 because we added one ourselves above).
@@ -325,6 +317,12 @@
 			goto cache_unlock_continue;
 
 		/*
+		 * We did the page aging part.
+		 */
+		if (nr_lru_pages < freepages.min * priority)
+			goto cache_unlock_continue;
+
+		/*
 		 * Is it a page swap page? If so, we want to
 		 * drop it if it is no longer used, even if it
 		 * were to be marked referenced..
@@ -353,13 +351,21 @@
 cache_unlock_continue:
 		spin_unlock(&pagecache_lock);
 unlock_continue:
-		spin_lock(&pagemap_lru_lock);
 		UnlockPage(page);
 		put_page(page);
+dispose_relock_continue:
+		/* even if the dispose list is local, a truncate_inode_page()
+		   may remove a page from its queue so always
+		   synchronize with the lru lock while accesing the
+		   page->lru field */
+		spin_lock(&pagemap_lru_lock);
 		list_add(page_lru, dispose);
 		continue;
 
-		/* we're holding pagemap_lru_lock, so we can just loop again */
+unlock_noput_continue:
+		UnlockPage(page);
+		goto dispose_relock_continue;
+
 dispose_continue:
 		list_add(page_lru, dispose);
 	}
@@ -374,11 +380,6 @@
 	spin_lock(&pagemap_lru_lock);
 	/* nr_lru_pages needs the spinlock */
 	nr_lru_pages--;
-
-	loop++;
-	/* wrong zone?  not looped too often?    roll again... */
-	if (page->zone != zone && loop < maxloop)
-		goto again;
 
 out:
 	list_splice(&young, &lru_cache);
Index: 9906.2/mm/page_alloc.c
--- 9906.2/mm/page_alloc.c Thu, 27 Apr 2000 22:11:43 +0200 zcalusic (linux/F/b/18_page_alloc 1.5.2.21 644)
+++ 9906.5/mm/page_alloc.c Sun, 07 May 2000 20:39:35 +0200 zcalusic (linux/F/b/18_page_alloc 1.5.2.21.2.1 644)
@@ -58,8 +58,6 @@
  */
 #define BAD_RANGE(zone,x) (((zone) != (x)->zone) || (((x)-mem_map) < (zone)->offset) || (((x)-mem_map) >= (zone)->offset+(zone)->size))
 
-#if 0
-
 static inline unsigned long classfree(zone_t *zone)
 {
 	unsigned long free = 0;
@@ -73,8 +71,6 @@
 	return(free);
 }
 
-#endif
-
 /*
  * Buddy system. Hairy. You really aren't expected to understand this
  *
@@ -156,10 +152,8 @@
 
 	spin_unlock_irqrestore(&zone->lock, flags);
 
-	if (zone->free_pages > zone->pages_high) {
-		zone->zone_wake_kswapd = 0;
+	if (zone->free_pages > zone->pages_high)
 		zone->low_on_memory = 0;
-	}
 }
 
 #define MARK_USED(index, order, area) \
@@ -186,8 +180,7 @@
 	return page;
 }
 
-static FASTCALL(struct page * rmqueue(zone_t *zone, unsigned long order));
-static struct page * rmqueue(zone_t *zone, unsigned long order)
+static inline struct page * rmqueue(zone_t *zone, unsigned long order)
 {
 	free_area_t * area = zone->free_area + order;
 	unsigned long curr_order = order;
@@ -227,115 +220,72 @@
 	return NULL;
 }
 
-static int zone_balance_memory(zonelist_t *zonelist)
-{
-	int tried = 0, freed = 0;
-	zone_t **zone;
-	int gfp_mask = zonelist->gfp_mask;
-	extern wait_queue_head_t kswapd_wait;
-
-	zone = zonelist->zones;
-	for (;;) {
-		zone_t *z = *(zone++);
-		if (!z)
-			break;
-		if (z->free_pages > z->pages_low)
-			continue;
-
-		z->zone_wake_kswapd = 1;
-		wake_up_interruptible(&kswapd_wait);
-
-		/* Are we reaching the critical stage? */
-		if (!z->low_on_memory) {
-			/* Not yet critical, so let kswapd handle it.. */
-			if (z->free_pages > z->pages_min)
-				continue;
-			z->low_on_memory = 1;
-		}
-		/*
-		 * In the atomic allocation case we only 'kick' the
-		 * state machine, but do not try to free pages
-		 * ourselves.
-		 */
-		tried = 1;
-		freed |= try_to_free_pages(gfp_mask, z);
-	}
-	if (tried && !freed) {
-		if (!(gfp_mask & __GFP_HIGH))
-			return 0;
-	}
-	return 1;
-}
-
 /*
  * This is the 'heart' of the zoned buddy allocator:
  */
 struct page * __alloc_pages(zonelist_t *zonelist, unsigned long order)
 {
 	zone_t **zone = zonelist->zones;
-	int gfp_mask = zonelist->gfp_mask;
-	static int low_on_memory;
-
-	/*
-	 * If this is a recursive call, we'd better
-	 * do our best to just allocate things without
-	 * further thought.
-	 */
-	if (current->flags & PF_MEMALLOC)
-		goto allocate_ok;
-
-	/* If we're a memory hog, unmap some pages */
-	if (current->hog && low_on_memory &&
-			(gfp_mask & __GFP_WAIT))
-		swap_out(4, gfp_mask);
 
 	/*
 	 * (If anyone calls gfp from interrupts nonatomically then it
-	 * will sooner or later tripped up by a schedule().)
+	 * will be sooner or later tripped up by a schedule().)
 	 *
 	 * We are falling back to lower-level zones if allocation
 	 * in a higher zone fails.
 	 */
 	for (;;) {
 		zone_t *z = *(zone++);
+
 		if (!z)
 			break;
+
 		if (!z->size)
 			BUG();
 
-		/* Are we supposed to free memory? Don't make it worse.. */
-		if (!z->zone_wake_kswapd && z->free_pages > z->pages_low) {
+		/*
+		 * If this is a recursive call, we'd better
+		 * do our best to just allocate things without
+		 * further thought.
+		 */
+		if (!(current->flags & PF_MEMALLOC)) {
+			if (z->free_pages <= z->pages_high) {
+				unsigned long free = classfree(z);
+
+				if (free <= z->pages_low) {
+					extern wait_queue_head_t kswapd_wait;
+
+					z->low_on_memory = 1;
+					wake_up_interruptible(&kswapd_wait);
+				}
+
+				if (free <= z->pages_min) {
+					int gfp_mask = zonelist->gfp_mask;
+
+					if (!try_to_free_pages(gfp_mask, z)) {
+						if (!(gfp_mask & __GFP_HIGH))
+							return NULL;
+					}
+				}
+			}
+		}
+
+		/*
+		 * This is an optimization for the 'higher order zone
+		 * is empty' case - it can happen even in well-behaved
+		 * systems, think the page-cache filling up all RAM.
+		 * We skip over empty zones. (this is not exact because
+		 * we do not take the spinlock and it's not exact for
+		 * the higher order case, but will do it for most things.)
+		 */
+		if (z->free_pages) {
 			struct page *page = rmqueue(z, order);
-			low_on_memory = 0;
+
 			if (page)
 				return page;
 		}
 	}
-
-	low_on_memory = 1;
-	/*
-	 * Ok, no obvious zones were available, start
-	 * balancing things a bit..
-	 */
-	if (zone_balance_memory(zonelist)) {
-		zone = zonelist->zones;
-allocate_ok:
-		for (;;) {
-			zone_t *z = *(zone++);
-			if (!z)
-				break;
-			if (z->free_pages) {
-				struct page *page = rmqueue(z, order);
-				if (page)
-					return page;
-			}
-		}
-	}
 	return NULL;
-
-/*
- * The main chunk of the balancing code is in this offline branch:
- */
 }
 
 /*
@@ -599,7 +549,6 @@
 		zone->pages_low = mask*2;
 		zone->pages_high = mask*3;
 		zone->low_on_memory = 0;
-		zone->zone_wake_kswapd = 0;
 		zone->zone_mem_map = mem_map + offset;
 		zone->zone_start_mapnr = offset;
 		zone->zone_start_paddr = zone_start_paddr;
@@ -642,7 +591,8 @@
 
 	while (get_option(&str, &zone_balance_ratio[j++]) == 2);
 	printk("setup_mem_frac: ");
-	for (j = 0; j < MAX_NR_ZONES; j++) printk("%d  ", zone_balance_ratio[j]);
+	for (j = 0; j < MAX_NR_ZONES; j++)
+		printk("%d  ", zone_balance_ratio[j]);
 	printk("\n");
 	return 1;
 }
Index: 9906.2/include/linux/mmzone.h
--- 9906.2/include/linux/mmzone.h Thu, 27 Apr 2000 22:11:43 +0200 zcalusic (linux/u/c/2_mmzone.h 1.9 644)
+++ 9906.5/include/linux/mmzone.h Sun, 07 May 2000 20:39:35 +0200 zcalusic (linux/u/c/2_mmzone.h 1.10 644)
@@ -29,7 +29,6 @@
 	unsigned long		offset;
 	unsigned long		free_pages;
 	char			low_on_memory;
-	char			zone_wake_kswapd;
 	unsigned long		pages_min, pages_low, pages_high;
 
 	/*

--=-=-=


-- 
Zlatko

--=-=-=--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
