From: Con Kolivas <kernel@kolivas.org>
Subject: [PATCH respin] mm: swap prefetch improvements
Date: Sat, 12 May 2007 18:57:58 +1000
References: <20070430162007.ad46e153.akpm@linux-foundation.org> <200705121821.48515.kernel@kolivas.org> <20070512013755.603cfcc3.pj@sgi.com>
In-Reply-To: <20070512013755.603cfcc3.pj@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200705121857.58415.kernel@kolivas.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: nickpiggin@yahoo.com.au, ray-lk@madrabbit.org, mingo@elte.hu, ck@vds.kolivas.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Saturday 12 May 2007 18:37, Paul Jackson wrote:
> Con wrote:
> > Ok so change the default value for swap_prefetch to 0 when CPUSETS is
> > enabled?
>
> I don't see why that special case for cpusets is needed.
>
> I'm suggesting making no special cases for CPUSETS at all, until and
> unless we find reason to.
>
> In other words, I'm suggesting simply removing the patch lines:
>
> -	depends on SWAP
> +	depends on SWAP && !CPUSETS
>
> I see no other mention of cpusets in your patch.  That's fine by me.

Excellent, I prefer that as well. Thanks very much for your comments!

Here's a respin without that hunk.

---
Numerous improvements to swap prefetch.

It was possible for kprefetchd to go to sleep indefinitely before/after
changing the /proc value of swap prefetch. Fix that.

The cost of remove_from_swapped_list() can be removed from every page swapin
by moving it to be done entirely by kprefetchd lazily.

The call site for add_to_swapped_list need only be at one place.

Wakeups can occur much less frequently if swap prefetch is disabled.

Make it possible to enable swap prefetch explicitly via /proc when laptop_mode
is enabled by changing the value of the sysctl to 2.

The complicated iteration over every entry can be consolidated by using
list_for_each_safe.

Fix potential irq problem by converting read_lock_irq to irqsave etc.

Code style fixes.

Change the ioprio from IOPRIO_CLASS_IDLE to normal lower priority to ensure
that bio requests are not starved if other I/O begins during prefetching.

Signed-off-by: Con Kolivas <kernel@kolivas.org>

---
 Documentation/sysctl/vm.txt |    4 -
 mm/page_io.c                |    2 
 mm/swap_prefetch.c          |  158 +++++++++++++++++++-------------------------
 mm/swap_state.c             |    2 
 mm/vmscan.c                 |    1 
 5 files changed, 74 insertions(+), 93 deletions(-)

Index: linux-2.6.21-mm1/mm/page_io.c
===================================================================
--- linux-2.6.21-mm1.orig/mm/page_io.c	2007-02-05 22:52:04.000000000 +1100
+++ linux-2.6.21-mm1/mm/page_io.c	2007-05-12 14:30:52.000000000 +1000
@@ -17,6 +17,7 @@
 #include <linux/bio.h>
 #include <linux/swapops.h>
 #include <linux/writeback.h>
+#include <linux/swap-prefetch.h>
 #include <asm/pgtable.h>
 
 static struct bio *get_swap_bio(gfp_t gfp_flags, pgoff_t index,
@@ -118,6 +119,7 @@ int swap_writepage(struct page *page, st
 		ret = -ENOMEM;
 		goto out;
 	}
+	add_to_swapped_list(page);
 	if (wbc->sync_mode == WB_SYNC_ALL)
 		rw |= (1 << BIO_RW_SYNC);
 	count_vm_event(PSWPOUT);
Index: linux-2.6.21-mm1/mm/swap_state.c
===================================================================
--- linux-2.6.21-mm1.orig/mm/swap_state.c	2007-05-07 21:53:51.000000000 +1000
+++ linux-2.6.21-mm1/mm/swap_state.c	2007-05-12 14:30:52.000000000 +1000
@@ -83,7 +83,6 @@ static int __add_to_swap_cache(struct pa
 		error = radix_tree_insert(&swapper_space.page_tree,
 						entry.val, page);
 		if (!error) {
-			remove_from_swapped_list(entry.val);
 			page_cache_get(page);
 			SetPageLocked(page);
 			SetPageSwapCache(page);
@@ -102,7 +101,6 @@ int add_to_swap_cache(struct page *page,
 	int error;
 
 	if (!swap_duplicate(entry)) {
-		remove_from_swapped_list(entry.val);
 		INC_CACHE_INFO(noent_race);
 		return -ENOENT;
 	}
Index: linux-2.6.21-mm1/mm/vmscan.c
===================================================================
--- linux-2.6.21-mm1.orig/mm/vmscan.c	2007-05-07 21:53:51.000000000 +1000
+++ linux-2.6.21-mm1/mm/vmscan.c	2007-05-12 14:30:52.000000000 +1000
@@ -410,7 +410,6 @@ int remove_mapping(struct address_space 
 
 	if (PageSwapCache(page)) {
 		swp_entry_t swap = { .val = page_private(page) };
-		add_to_swapped_list(page);
 		__delete_from_swap_cache(page);
 		write_unlock_irq(&mapping->tree_lock);
 		swap_free(swap);
Index: linux-2.6.21-mm1/mm/swap_prefetch.c
===================================================================
--- linux-2.6.21-mm1.orig/mm/swap_prefetch.c	2007-05-07 21:53:51.000000000 +1000
+++ linux-2.6.21-mm1/mm/swap_prefetch.c	2007-05-12 14:30:52.000000000 +1000
@@ -27,7 +27,8 @@
  * needs to be at least this duration of idle time meaning in practice it can
  * be much longer
  */
-#define PREFETCH_DELAY	(HZ * 5)
+#define PREFETCH_DELAY		(HZ * 5)
+#define DISABLED_PREFETCH_DELAY	(HZ * 60)
 
 /* sysctl - enable/disable swap prefetching */
 int swap_prefetch __read_mostly = 1;
@@ -61,19 +62,30 @@ inline void delay_swap_prefetch(void)
 }
 
 /*
+ * If laptop_mode is enabled don't prefetch to avoid hard drives
+ * doing unnecessary spin-ups unless swap_prefetch is explicitly
+ * set to a higher value.
+ */
+static inline int prefetch_enabled(void)
+{
+	if (swap_prefetch <= laptop_mode)
+		return 0;
+	return 1;
+}
+
+static int wakeup_kprefetchd;
+
+/*
  * Drop behind accounting which keeps a list of the most recently used swap
- * entries.
+ * entries. Entries are removed lazily by kprefetchd.
  */
 void add_to_swapped_list(struct page *page)
 {
 	struct swapped_entry *entry;
 	unsigned long index, flags;
-	int wakeup;
-
-	if (!swap_prefetch)
-		return;
 
-	wakeup = 0;
+	if (!prefetch_enabled())
+		goto out;
 
 	spin_lock_irqsave(&swapped.lock, flags);
 	if (swapped.count >= swapped.maxcount) {
@@ -103,23 +115,15 @@ void add_to_swapped_list(struct page *pa
 	store_swap_entry_node(entry, page);
 
 	if (likely(!radix_tree_insert(&swapped.swap_tree, index, entry))) {
-		/*
-		 * If this is the first entry, kprefetchd needs to be
-		 * (re)started.
-		 */
-		if (!swapped.count)
-			wakeup = 1;
 		list_add(&entry->swapped_list, &swapped.list);
 		swapped.count++;
 	}
 
 out_locked:
 	spin_unlock_irqrestore(&swapped.lock, flags);
-
-	/* Do the wakeup outside the lock to shorten lock hold time. */
-	if (wakeup)
+out:
+	if (wakeup_kprefetchd)
 		wake_up_process(kprefetchd_task);
-
 	return;
 }
 
@@ -139,7 +143,7 @@ void remove_from_swapped_list(const unsi
 	spin_lock_irqsave(&swapped.lock, flags);
 	entry = radix_tree_delete(&swapped.swap_tree, index);
 	if (likely(entry)) {
-		list_del_init(&entry->swapped_list);
+		list_del(&entry->swapped_list);
 		swapped.count--;
 		kmem_cache_free(swapped.cache, entry);
 	}
@@ -153,18 +157,18 @@ enum trickle_return {
 };
 
 struct node_stats {
-	unsigned long	last_free;
 	/* Free ram after a cycle of prefetching */
-	unsigned long	current_free;
+	unsigned long	last_free;
 	/* Free ram on this cycle of checking prefetch_suitable */
-	unsigned long	prefetch_watermark;
+	unsigned long	current_free;
 	/* Maximum amount we will prefetch to */
-	unsigned long	highfree[MAX_NR_ZONES];
+	unsigned long	prefetch_watermark;
 	/* The amount of free ram before we start prefetching */
-	unsigned long	lowfree[MAX_NR_ZONES];
+	unsigned long	highfree[MAX_NR_ZONES];
 	/* The amount of free ram where we will stop prefetching */
-	unsigned long	*pointfree[MAX_NR_ZONES];
+	unsigned long	lowfree[MAX_NR_ZONES];
 	/* highfree or lowfree depending on whether we've hit a watermark */
+	unsigned long	*pointfree[MAX_NR_ZONES];
 };
 
 /*
@@ -172,10 +176,10 @@ struct node_stats {
  * determine if a node is suitable for prefetching into.
  */
 struct prefetch_stats {
-	nodemask_t	prefetch_nodes;
 	/* Which nodes are currently suited to prefetching */
-	unsigned long	prefetched_pages;
+	nodemask_t	prefetch_nodes;
 	/* Total pages we've prefetched on this wakeup of kprefetchd */
+	unsigned long	prefetched_pages;
 	struct node_stats node[MAX_NUMNODES];
 };
 
@@ -189,16 +193,15 @@ static enum trickle_return trickle_swap_
 	const int node)
 {
 	enum trickle_return ret = TRICKLE_FAILED;
+	unsigned long flags;
 	struct page *page;
 
-	read_lock_irq(&swapper_space.tree_lock);
+	read_lock_irqsave(&swapper_space.tree_lock, flags);
 	/* Entry may already exist */
 	page = radix_tree_lookup(&swapper_space.page_tree, entry.val);
-	read_unlock_irq(&swapper_space.tree_lock);
-	if (page) {
-		remove_from_swapped_list(entry.val);
+	read_unlock_irqrestore(&swapper_space.tree_lock, flags);
+	if (page)
 		goto out;
-	}
 
 	/*
 	 * Get a new page to read from swap. We have already checked the
@@ -217,10 +220,8 @@ static enum trickle_return trickle_swap_
 
 	/* Add them to the tail of the inactive list to preserve LRU order */
 	lru_cache_add_tail(page);
-	if (unlikely(swap_readpage(NULL, page))) {
-		ret = TRICKLE_DELAY;
+	if (unlikely(swap_readpage(NULL, page)))
 		goto out_release;
-	}
 
 	sp_stat.prefetched_pages++;
 	sp_stat.node[node].last_free--;
@@ -229,6 +230,12 @@ static enum trickle_return trickle_swap_
 out_release:
 	page_cache_release(page);
 out:
+	/*
+	 * All entries are removed here lazily. This avoids the cost of
+	 * remove_from_swapped_list during normal swapin. Thus there are
+	 * usually many stale entries.
+	 */
+	remove_from_swapped_list(entry.val);
 	return ret;
 }
 
@@ -414,17 +421,6 @@ out:
 }
 
 /*
- * Get previous swapped entry when iterating over all entries. swapped.lock
- * should be held and we should already ensure that entry exists.
- */
-static inline struct swapped_entry *prev_swapped_entry
-	(struct swapped_entry *entry)
-{
-	return list_entry(entry->swapped_list.prev->prev,
-		struct swapped_entry, swapped_list);
-}
-
-/*
  * trickle_swap is the main function that initiates the swap prefetching. It
  * first checks to see if the busy flag is set, and does not prefetch if it
  * is, as the flag implied we are low on memory or swapping in currently.
@@ -435,70 +431,49 @@ static inline struct swapped_entry *prev
 static enum trickle_return trickle_swap(void)
 {
 	enum trickle_return ret = TRICKLE_DELAY;
-	struct swapped_entry *entry;
+	struct list_head *p, *next;
 	unsigned long flags;
 
-	/*
-	 * If laptop_mode is enabled don't prefetch to avoid hard drives
-	 * doing unnecessary spin-ups
-	 */
-	if (!swap_prefetch || laptop_mode)
+	if (!prefetch_enabled())
 		return ret;
 
 	examine_free_limits();
-	entry = NULL;
+	if (!prefetch_suitable())
+		return ret;
+	if (list_empty(&swapped.list))
+		return TRICKLE_FAILED;
 
-	for ( ; ; ) {
+	spin_lock_irqsave(&swapped.lock, flags);
+	list_for_each_safe(p, next, &swapped.list) {
+		struct swapped_entry *entry;
 		swp_entry_t swp_entry;
 		int node;
 
+		spin_unlock_irqrestore(&swapped.lock, flags);
+		might_sleep();
 		if (!prefetch_suitable())
-			break;
+			goto out_unlocked;
 
 		spin_lock_irqsave(&swapped.lock, flags);
-		if (list_empty(&swapped.list)) {
-			ret = TRICKLE_FAILED;
-			spin_unlock_irqrestore(&swapped.lock, flags);
-			break;
-		}
-
-		if (!entry) {
-			/*
-			 * This sets the entry for the first iteration. It
-			 * also is a safeguard against the entry disappearing
-			 * while the lock is not held.
-			 */
-			entry = list_entry(swapped.list.prev,
-				struct swapped_entry, swapped_list);
-		} else if (entry->swapped_list.prev == swapped.list.next) {
-			/*
-			 * If we have iterated over all entries and there are
-			 * still entries that weren't swapped out there may
-			 * be a reason we could not swap them back in so
-			 * delay attempting further prefetching.
-			 */
-			spin_unlock_irqrestore(&swapped.lock, flags);
-			break;
-		}
-
+		entry = list_entry(p, struct swapped_entry, swapped_list);
 		node = get_swap_entry_node(entry);
 		if (!node_isset(node, sp_stat.prefetch_nodes)) {
 			/*
 			 * We found an entry that belongs to a node that is
 			 * not suitable for prefetching so skip it.
 			 */
-			entry = prev_swapped_entry(entry);
-			spin_unlock_irqrestore(&swapped.lock, flags);
 			continue;
 		}
 		swp_entry = entry->swp_entry;
-		entry = prev_swapped_entry(entry);
 		spin_unlock_irqrestore(&swapped.lock, flags);
 
 		if (trickle_swap_cache_async(swp_entry, node) == TRICKLE_DELAY)
-			break;
+			goto out_unlocked;
+		spin_lock_irqsave(&swapped.lock, flags);
 	}
+	spin_unlock_irqrestore(&swapped.lock, flags);
 
+out_unlocked:
 	if (sp_stat.prefetched_pages) {
 		lru_add_drain();
 		sp_stat.prefetched_pages = 0;
@@ -513,13 +488,14 @@ static int kprefetchd(void *__unused)
 	sched_setscheduler(current, SCHED_BATCH, &param);
 	set_user_nice(current, 19);
 	/* Set ioprio to lowest if supported by i/o scheduler */
-	sys_ioprio_set(IOPRIO_WHO_PROCESS, 0, IOPRIO_CLASS_IDLE);
+	sys_ioprio_set(IOPRIO_WHO_PROCESS, IOPRIO_BE_NR - 1, IOPRIO_CLASS_BE);
 
 	/* kprefetchd has nothing to do until it is woken up the first time */
+	wakeup_kprefetchd = 1;
 	set_current_state(TASK_INTERRUPTIBLE);
 	schedule();
 
-	do {
+	while (!kthread_should_stop()) {
 		try_to_freeze();
 
 		/*
@@ -527,13 +503,17 @@ static int kprefetchd(void *__unused)
 		 * a wakeup, and further delay the next one.
 		 */
 		if (trickle_swap() == TRICKLE_FAILED) {
+			wakeup_kprefetchd = 1;
 			set_current_state(TASK_INTERRUPTIBLE);
 			schedule();
-		}
+		} else
+			wakeup_kprefetchd = 0;
 		clear_last_prefetch_free();
-		schedule_timeout_interruptible(PREFETCH_DELAY);
-	} while (!kthread_should_stop());
-
+		if (!prefetch_enabled())
+			schedule_timeout_interruptible(DISABLED_PREFETCH_DELAY);
+		else
+			schedule_timeout_interruptible(PREFETCH_DELAY);
+	}
 	return 0;
 }
 
Index: linux-2.6.21-mm1/Documentation/sysctl/vm.txt
===================================================================
--- linux-2.6.21-mm1.orig/Documentation/sysctl/vm.txt	2007-05-07 21:53:00.000000000 +1000
+++ linux-2.6.21-mm1/Documentation/sysctl/vm.txt	2007-05-12 14:31:26.000000000 +1000
@@ -229,7 +229,9 @@ swap_prefetch
 This enables or disables the swap prefetching feature. When the virtual
 memory subsystem has been extremely idle for at least 5 seconds it will start
 copying back pages from swap into the swapcache and keep a copy in swap. In
-practice it can take many minutes before the vm is idle enough.
+practice it can take many minutes before the vm is idle enough. A value of 0
+disables swap prefetching, 1 enables it unless laptop_mode is enabled, and 2
+enables it even in the presence of laptop_mode.
 
 The default value is 1.
 

-- 
-ck

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
