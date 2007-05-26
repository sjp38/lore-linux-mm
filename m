From: Con Kolivas <kernel@kolivas.org>
Subject: [PATCH] mm: swap prefetch increase aggressiveness and tunability
Date: Sat, 26 May 2007 20:08:03 +1000
MIME-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200705262008.03492.kernel@kolivas.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux kernel mailing list <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, ck list <ck@vds.kolivas.org>
List-ID: <linux-mm.kvack.org>

Swap prefetch is currently too lax in prefetching with extended idle periods
unused. Increase its aggressiveness and tunability.

Make it possible for swap_prefetch to be set to a high value ignoring load
and prefetching regardless.

Add tunables to modify the swap prefetch delay and sleep period on the
fly, and decrease both periods to 1 and 5 seconds respectively.
Extended periods did not decrease the impact any further but greatly
diminished the rate ram was prefetched.

Remove the prefetch_watermark that left free ram unused. The impact of using
the free ram with prefetched pages being put on the tail end of the inactive
list would be minimal and potentially very beneficial, yet testing the
pagestate adds unnecessary expense.

Put kprefetchd to sleep if the low watermarks are hit instead of delaying it.

Increase the maxcount as the lazy removal of swapped entries means we can
easily have many stale entries and not enough entries for good swap prefetch.

Do not delay prefetch in cond_resched() returning positive. That was
pointless and frequently put kprefetchd to sleep for no reason.

Update comments and documentation.

Signed-off-by: Con Kolivas <kernel@kolivas.org>

---
 Documentation/sysctl/vm.txt   |   33 +++++++-
 include/linux/swap-prefetch.h |    3 
 kernel/sysctl.c               |   16 ++++
 mm/swap_prefetch.c            |  164 +++++++++++++++++-------------------------
 4 files changed, 117 insertions(+), 99 deletions(-)

Index: linux-2.6.22-rc2-mm1/include/linux/swap-prefetch.h
===================================================================
--- linux-2.6.22-rc2-mm1.orig/include/linux/swap-prefetch.h	2007-05-26 18:52:52.000000000 +1000
+++ linux-2.6.22-rc2-mm1/include/linux/swap-prefetch.h	2007-05-26 18:53:53.000000000 +1000
@@ -4,6 +4,9 @@
 #ifdef CONFIG_SWAP_PREFETCH
 /* mm/swap_prefetch.c */
 extern int swap_prefetch;
+extern int swap_prefetch_delay;
+extern int swap_prefetch_sleep;
+
 struct swapped_entry {
 	swp_entry_t		swp_entry;	/* The actual swap entry */
 	struct list_head	swapped_list;	/* Linked list of entries */
Index: linux-2.6.22-rc2-mm1/kernel/sysctl.c
===================================================================
--- linux-2.6.22-rc2-mm1.orig/kernel/sysctl.c	2007-05-26 18:52:52.000000000 +1000
+++ linux-2.6.22-rc2-mm1/kernel/sysctl.c	2007-05-26 18:53:53.000000000 +1000
@@ -978,6 +978,22 @@ static ctl_table vm_table[] = {
 		.mode		= 0644,
 		.proc_handler	= &proc_dointvec,
 	},
+	{
+		.ctl_name	= CTL_UNNUMBERED,
+		.procname	= "swap_prefetch_delay",
+		.data		= &swap_prefetch_delay,
+		.maxlen		= sizeof(swap_prefetch_delay),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec,
+	},
+	{
+		.ctl_name	= CTL_UNNUMBERED,
+		.procname	= "swap_prefetch_sleep",
+		.data		= &swap_prefetch_sleep,
+		.maxlen		= sizeof(swap_prefetch_sleep),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec,
+	},
 #endif
 	{ .ctl_name = 0 }
 };
Index: linux-2.6.22-rc2-mm1/mm/swap_prefetch.c
===================================================================
--- linux-2.6.22-rc2-mm1.orig/mm/swap_prefetch.c	2007-05-26 18:52:52.000000000 +1000
+++ linux-2.6.22-rc2-mm1/mm/swap_prefetch.c	2007-05-26 18:57:17.000000000 +1000
@@ -1,7 +1,7 @@
 /*
  * linux/mm/swap_prefetch.c
  *
- * Copyright (C) 2005-2006 Con Kolivas
+ * Copyright (C) 2005-2007 Con Kolivas
  *
  * Written by Con Kolivas <kernel@kolivas.org>
  *
@@ -23,15 +23,22 @@
 #include <linux/freezer.h>
 
 /*
- * Time to delay prefetching if vm is busy or prefetching unsuccessful. There
- * needs to be at least this duration of idle time meaning in practice it can
- * be much longer
+ * sysctls:
+ * swap_prefetch:	0. Disable swap prefetching
+ *			1. Prefetch only when idle and not with laptop_mode
+ *			2. Prefetch when idle and with laptop_mode
+ *			3. Prefetch at all times.
+ * swap_prefetch_delay:	Number of seconds to delay prefetching when system
+ *			is not idle.
+ * swap_prefetch_sleep:	Number of seconds to put kprefetchd to sleep when
+ *			unable to prefetch.
  */
-#define PREFETCH_DELAY		(HZ * 5)
-#define DISABLED_PREFETCH_DELAY	(HZ * 60)
-
-/* sysctl - enable/disable swap prefetching */
 int swap_prefetch __read_mostly = 1;
+int swap_prefetch_delay __read_mostly = 1;
+int swap_prefetch_sleep __read_mostly = 5;
+
+#define PREFETCH_DELAY		(HZ * swap_prefetch_delay)
+#define PREFETCH_SLEEP		((HZ * swap_prefetch_sleep) ? : 1)
 
 struct swapped_root {
 	unsigned long		busy;		/* vm busy */
@@ -73,7 +80,7 @@ static inline int prefetch_enabled(void)
 	return 1;
 }
 
-static int wakeup_kprefetchd;
+static int kprefetchd_awake;
 
 /*
  * Drop behind accounting which keeps a list of the most recently used swap
@@ -90,9 +97,8 @@ void add_to_swapped_list(struct page *pa
 	spin_lock_irqsave(&swapped.lock, flags);
 	if (swapped.count >= swapped.maxcount) {
 		/*
-		 * We limit the number of entries to 2/3 of physical ram.
-		 * Once the number of entries exceeds this we start removing
-		 * the least recently used entries.
+		 * Once the number of entries exceeds maxcount we start
+		 * removing the least recently used entries.
 		 */
 		entry = list_entry(swapped.list.next,
 			struct swapped_entry, swapped_list);
@@ -123,7 +129,7 @@ void add_to_swapped_list(struct page *pa
 out_locked:
 	spin_unlock_irqrestore(&swapped.lock, flags);
 out:
-	if (wakeup_kprefetchd)
+	if (!kprefetchd_awake)
 		wake_up_process(kprefetchd_task);
 	return;
 }
@@ -138,9 +144,6 @@ void remove_from_swapped_list(const unsi
 	struct swapped_entry *entry;
 	unsigned long flags;
 
-	if (list_empty(&swapped.list))
-		return;
-
 	spin_lock_irqsave(&swapped.lock, flags);
 	entry = radix_tree_delete(&swapped.swap_tree, index);
 	if (likely(entry)) {
@@ -162,8 +165,6 @@ struct node_stats {
 	unsigned long	last_free;
 	/* Free ram on this cycle of checking prefetch_suitable */
 	unsigned long	current_free;
-	/* Maximum amount we will prefetch to */
-	unsigned long	prefetch_watermark;
 	/* The amount of free ram before we start prefetching */
 	unsigned long	highfree[MAX_NR_ZONES];
 	/* The amount of free ram where we will stop prefetching */
@@ -303,31 +304,35 @@ static void examine_free_limits(void)
 /*
  * We want to be absolutely certain it's ok to start prefetching.
  */
-static int prefetch_suitable(void)
+static enum trickle_return prefetch_suitable(void)
 {
-	unsigned long limit;
+	enum trickle_return ret = TRICKLE_DELAY;
 	struct zone *z;
-	int node, ret = 0, test_pagestate = 0;
-
-	/* Purposefully racy */
-	if (test_bit(0, &swapped.busy)) {
-		__clear_bit(0, &swapped.busy);
-		goto out;
-	}
+	int node;
 
 	/*
-	 * get_page_state and above_background_load are expensive so we only
-	 * perform them every SWAP_CLUSTER_MAX prefetched_pages.
-	 * We test to see if we're above_background_load as disk activity
-	 * even at low priority can cause interrupt induced scheduling
-	 * latencies.
+	 * If swap_prefetch is set to a high value we can ignore load
+	 * and prefetch whenever we can. Otherwise we test for vm and
+	 * cpu activity.
 	 */
-	if (!(sp_stat.prefetched_pages % SWAP_CLUSTER_MAX)) {
-		if (above_background_load())
+	if (swap_prefetch < 3) {
+		/* Purposefully racy, may return false positive */
+		if (test_bit(0, &swapped.busy)) {
+			__clear_bit(0, &swapped.busy);
 			goto out;
-		test_pagestate = 1;
-	}
+		}
 
+		/*
+		 * above_background_load is expensive so we only perform it
+		 * every SWAP_CLUSTER_MAX prefetched_pages.
+		 * We test to see if we're above_background_load as disk
+		 * activity even at low priority can cause interrupt induced
+		 * scheduling latencies.
+		 */
+		if (!(sp_stat.prefetched_pages % SWAP_CLUSTER_MAX) &&
+		    above_background_load())
+			goto out;
+	}
 	clear_current_prefetch_free();
 
 	/*
@@ -383,40 +388,17 @@ static int prefetch_suitable(void)
 		} else
 			ns->last_free = ns->current_free;
 
-		if (!test_pagestate)
-			continue;
-
 		/* We shouldn't prefetch when we are doing writeback */
-		if (node_page_state(node, NR_WRITEBACK)) {
+		if (node_page_state(node, NR_WRITEBACK))
 			node_clear(node, sp_stat.prefetch_nodes);
-			continue;
-		}
-
-		/*
-		 * >2/3 of the ram on this node is mapped, slab, swapcache or
-		 * dirty, we need to leave some free for pagecache.
-		 * Note that currently nr_slab is innacurate on numa because
-		 * nr_slab is incremented on the node doing the accounting
-		 * even if the slab is being allocated on a remote node. This
-		 * would be expensive to fix and not of great significance.
-		 */
-		limit = node_page_state(node, NR_FILE_PAGES);
-		limit += node_page_state(node, NR_SLAB_UNRECLAIMABLE);
-		limit += node_page_state(node, NR_SLAB_RECLAIMABLE);
-		limit += node_page_state(node, NR_FILE_DIRTY);
-		limit += node_page_state(node, NR_UNSTABLE_NFS);
-		limit += total_swapcache_pages;
-		if (limit > ns->prefetch_watermark) {
-			node_clear(node, sp_stat.prefetch_nodes);
-			continue;
-		}
 	}
 
+	/* Nothing suitable, put kprefetchd back to sleep */
 	if (nodes_empty(sp_stat.prefetch_nodes))
-		goto out;
+		return TRICKLE_FAILED;
 
 	/* Survived all that? Hooray we can prefetch! */
-	ret = 1;
+	ret = TRICKLE_SUCCESS;
 out:
 	return ret;
 }
@@ -426,12 +408,12 @@ out:
  * first checks to see if the busy flag is set, and does not prefetch if it
  * is, as the flag implied we are low on memory or swapping in currently.
  * Otherwise it runs until prefetch_suitable fails which occurs when the
- * vm is busy, we prefetch to the watermark, or the list is empty or we have
- * iterated over all entries
+ * vm is busy, we prefetch to the watermark, the list is empty or we have
+ * iterated over all entries once.
  */
 static enum trickle_return trickle_swap(void)
 {
-	enum trickle_return ret = TRICKLE_DELAY;
+	enum trickle_return suitable, ret = TRICKLE_DELAY;
 	struct swapped_entry *pos, *n;
 	unsigned long flags;
 
@@ -439,10 +421,13 @@ static enum trickle_return trickle_swap(
 		return ret;
 
 	examine_free_limits();
-	if (!prefetch_suitable())
-		return ret;
-	if (list_empty(&swapped.list))
+	suitable = prefetch_suitable();
+	if (suitable != TRICKLE_SUCCESS)
+		return suitable;
+	if (list_empty(&swapped.list)) {
+		kprefetchd_awake = 0;
 		return TRICKLE_FAILED;
+	}
 
 	spin_lock_irqsave(&swapped.lock, flags);
 	list_for_each_entry_safe_reverse(pos, n, &swapped.list, swapped_list) {
@@ -450,9 +435,12 @@ static enum trickle_return trickle_swap(
 		int node;
 
 		spin_unlock_irqrestore(&swapped.lock, flags);
-		/* Yield to anything else running */
-		if (cond_resched() || !prefetch_suitable())
+		cond_resched();
+		suitable = prefetch_suitable();
+		if (suitable != TRICKLE_SUCCESS) {
+			ret = suitable;
 			goto out_unlocked;
+		}
 
 		spin_lock_irqsave(&swapped.lock, flags);
 		if (unlikely(!pos))
@@ -491,29 +479,20 @@ static int kprefetchd(void *__unused)
 	/* Set ioprio to lowest if supported by i/o scheduler */
 	sys_ioprio_set(IOPRIO_WHO_PROCESS, IOPRIO_BE_NR - 1, IOPRIO_CLASS_BE);
 
-	/* kprefetchd has nothing to do until it is woken up the first time */
-	wakeup_kprefetchd = 1;
-	set_current_state(TASK_INTERRUPTIBLE);
-	schedule();
-
 	while (!kthread_should_stop()) {
 		try_to_freeze();
 
-		/*
-		 * TRICKLE_FAILED implies no entries left - we do not schedule
-		 * a wakeup, and further delay the next one.
-		 */
-		if (trickle_swap() == TRICKLE_FAILED) {
-			wakeup_kprefetchd = 1;
+		if (!kprefetchd_awake) {
 			set_current_state(TASK_INTERRUPTIBLE);
 			schedule();
-		} else
-			wakeup_kprefetchd = 0;
-		clear_last_prefetch_free();
-		if (!prefetch_enabled())
-			schedule_timeout_interruptible(DISABLED_PREFETCH_DELAY);
+			kprefetchd_awake = 1;
+		}
+
+		if (trickle_swap() == TRICKLE_FAILED)
+			schedule_timeout_interruptible(PREFETCH_SLEEP);
 		else
 			schedule_timeout_interruptible(PREFETCH_DELAY);
+		clear_last_prefetch_free();
 	}
 	return 0;
 }
@@ -529,22 +508,19 @@ void __init prepare_swap_prefetch(void)
 		sizeof(struct swapped_entry), 0, SLAB_PANIC, NULL, NULL);
 
 	/*
-	 * Set max number of entries to 2/3 the size of physical ram  as we
-	 * only ever prefetch to consume 2/3 of the ram.
+	 * We set the limit to more entries than the physical ram.
+	 * We remove entries lazily so we need some headroom.
 	 */
-	swapped.maxcount = nr_free_pagecache_pages() / 3 * 2;
+	swapped.maxcount = nr_free_pagecache_pages() * 2;
 
 	for_each_zone(zone) {
-		unsigned long present;
 		struct node_stats *ns;
 		int idx;
 
-		present = zone->present_pages;
-		if (!present)
+		if (!populated_zone(zone))
 			continue;
 
 		ns = &sp_stat.node[zone_to_nid(zone)];
-		ns->prefetch_watermark += present / 3 * 2;
 		idx = zone_idx(zone);
 		ns->pointfree[idx] = &ns->highfree[idx];
 	}
Index: linux-2.6.22-rc2-mm1/Documentation/sysctl/vm.txt
===================================================================
--- linux-2.6.22-rc2-mm1.orig/Documentation/sysctl/vm.txt	2007-05-26 18:52:50.000000000 +1000
+++ linux-2.6.22-rc2-mm1/Documentation/sysctl/vm.txt	2007-05-26 18:57:38.000000000 +1000
@@ -33,6 +33,8 @@ Currently, these files are in /proc/sys/
 - panic_on_oom
 - numa_zonelist_order
 - swap_prefetch
+- swap_prefetch_delay
+- swap_prefetch_sleep
 
 ==============================================================
 
@@ -270,10 +272,31 @@ this is causing problems for your system
 swap_prefetch
 
 This enables or disables the swap prefetching feature. When the virtual
-memory subsystem has been extremely idle for at least 5 seconds it will start
-copying back pages from swap into the swapcache and keep a copy in swap. In
-practice it can take many minutes before the vm is idle enough. A value of 0
-disables swap prefetching, 1 enables it unless laptop_mode is enabled, and 2
-enables it even in the presence of laptop_mode.
+memory subsystem has been extremely idle for at least swap_prefetch_sleep
+seconds it will start copying back pages from swap into the swapcache and keep
+a copy in swap. Valid values are 0 - 3. A value of 0 disables swap
+prefetching, 1 enables it unless laptop_mode is enabled, 2 enables it in the
+presence of laptop_mode, and 3 enables it unconditionally, ignoring whether
+the system is idle or not. If set to 0, swap prefetch wil not even try to keep
+record of ram swapped out to have the most minimal impact on performance.
 
 The default value is 1.
+
+==============================================================
+
+swap_prefetch_delay
+
+This is the time in seconds that swap prefetching is delayed upon finding
+the system is not idle (ie the vm is busy or non-niced cpu load is present).
+
+The default value is 1.
+
+==============================================================
+
+swap_prefetch_sleep
+
+This is the time in seconds that the swap prefetch kernel thread is put to
+sleep for when the ram is found to be full and it is unable to prefetch
+further.
+
+The default value is 5.

-- 
-ck

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
