Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id 352BD6B003D
	for <linux-mm@kvack.org>; Thu, 30 May 2013 14:04:58 -0400 (EDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 10/10] mm: workingset: keep shadow entries in check
Date: Thu, 30 May 2013 14:04:06 -0400
Message-Id: <1369937046-27666-11-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1369937046-27666-1-git-send-email-hannes@cmpxchg.org>
References: <1369937046-27666-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andi Kleen <andi@firstfloor.org>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Christoph Hellwig <hch@infradead.org>, Hugh Dickins <hughd@google.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan.kim@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Roman Gushchin <klamm@yandex-team.ru>, metin d <metdos@yahoo.com>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org

Previously, page cache radix tree nodes were freed after reclaim
emptied out their page pointers.  But now reclaim stores shadow
entries in their place, which are only reclaimed when the inodes
themselves are reclaimed.  This is problematic for bigger files that
are still in use after they have a significant amount of their cache
reclaimed, without any of those pages actually refaulting.  The shadow
entries will just sit there and waste memory.  In the worst case, the
shadow entries will accumulate until the machine runs out of memory.

To get this under control, two mechanisms are used:

1. A refault balance counter is maintained per file that grows with
   each shadow entry planted and shrinks with each refault.  Once the
   counter grows beyond a certain threshold, planting new shadows in
   that file is throttled.  It's per file so that a single file can
   not disable thrashing detection globally.  However, this still
   allows shadow entries to grow excessively when many files show this
   usage pattern, and so:

2. a list of files that contain shadow entries is maintained.  If the
   global number of shadows exceeds a certain threshold, a shrinker is
   activated that reclaims old entries from the mappings.  This is
   heavy-handed but it should not be a common case and is only there
   to protect from accidentally/maliciously induced OOM kills.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 fs/inode.c                    |   1 +
 include/linux/fs.h            |   2 +
 include/linux/swap.h          |   3 +
 include/linux/vm_event_item.h |   1 +
 mm/filemap.c                  |   5 +-
 mm/truncate.c                 |   2 +-
 mm/vmstat.c                   |   1 +
 mm/workingset.c               | 198 +++++++++++++++++++++++++++++++++++++++++-
 8 files changed, 206 insertions(+), 7 deletions(-)

diff --git a/fs/inode.c b/fs/inode.c
index 3bd7916..f48ce73 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -168,6 +168,7 @@ int inode_init_always(struct super_block *sb, struct inode *inode)
 	mapping->private_data = NULL;
 	mapping->backing_dev_info = &default_backing_dev_info;
 	mapping->writeback_index = 0;
+	mapping->shadow_debt = global_dirtyable_memory();
 
 	/*
 	 * If the block_device provides a backing_dev_info for client
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 5bf1d99..7fc3f3a 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -414,6 +414,8 @@ struct address_space {
 	/* Protected by tree_lock together with the radix tree */
 	unsigned long		nrpages;	/* number of total pages */
 	unsigned long		nrshadows;	/* number of shadow entries */
+	struct list_head	shadow_list;
+	unsigned long		shadow_debt;
 	pgoff_t			writeback_index;/* writeback starts here */
 	const struct address_space_operations *a_ops;	/* methods */
 	unsigned long		flags;		/* error bits/gfp mask */
diff --git a/include/linux/swap.h b/include/linux/swap.h
index c3d5237..ad153b0 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -225,7 +225,10 @@ struct swap_list_t {
 void *workingset_eviction(struct address_space *mapping, struct page *page);
 unsigned long workingset_refault_distance(struct page *page);
 void workingset_zone_balance(struct zone *zone, unsigned long refault_distance);
+void workingset_refault(struct address_space *mapping);
 void workingset_activation(struct page *page);
+void workingset_shadows_inc(struct address_space *mapping);
+void workingset_shadows_dec(struct address_space *mapping);
 
 /* linux/mm/page_alloc.c */
 extern unsigned long totalram_pages;
diff --git a/include/linux/vm_event_item.h b/include/linux/vm_event_item.h
index bd6cf61..cbbc323 100644
--- a/include/linux/vm_event_item.h
+++ b/include/linux/vm_event_item.h
@@ -70,6 +70,7 @@ enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
 		THP_ZERO_PAGE_ALLOC,
 		THP_ZERO_PAGE_ALLOC_FAILED,
 #endif
+		WORKINGSET_SHADOWS_RECLAIMED,
 		NR_VM_EVENT_ITEMS
 };
 
diff --git a/mm/filemap.c b/mm/filemap.c
index 10f8a62..3900bea 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -128,7 +128,7 @@ void __delete_from_page_cache(struct page *page, void *shadow)
 
 		slot = radix_tree_lookup_slot(&mapping->page_tree, page->index);
 		radix_tree_replace_slot(slot, shadow);
-		mapping->nrshadows++;
+		workingset_shadows_inc(mapping);
 	} else
 		radix_tree_delete(&mapping->page_tree, page->index);
 	page->mapping = NULL;
@@ -449,7 +449,8 @@ static int page_cache_insert(struct address_space *mapping, pgoff_t offset,
 		if (!radix_tree_exceptional_entry(p))
 			return -EEXIST;
 		radix_tree_replace_slot(slot, page);
-		mapping->nrshadows--;
+		workingset_shadows_dec(mapping);
+		workingset_refault(mapping);
 		return 0;
 	}
 	return radix_tree_insert(&mapping->page_tree, offset, page);
diff --git a/mm/truncate.c b/mm/truncate.c
index c1a5147..621c581 100644
--- a/mm/truncate.c
+++ b/mm/truncate.c
@@ -36,7 +36,7 @@ static void clear_exceptional_entry(struct address_space *mapping,
 	 * need verification under the tree lock.
 	 */
 	if (radix_tree_delete_item(&mapping->page_tree, index, page) == page)
-		mapping->nrshadows--;
+		workingset_shadows_dec(mapping);
 	spin_unlock_irq(&mapping->tree_lock);
 }
 
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 17c19b0..9fef546 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -818,6 +818,7 @@ const char * const vmstat_text[] = {
 	"thp_zero_page_alloc",
 	"thp_zero_page_alloc_failed",
 #endif
+	"workingset_shadows_reclaimed",
 
 #endif /* CONFIG_VM_EVENTS_COUNTERS */
 };
diff --git a/mm/workingset.c b/mm/workingset.c
index 7986aa4..e6294cb 100644
--- a/mm/workingset.c
+++ b/mm/workingset.c
@@ -84,6 +84,8 @@
  * challenged without incurring major faults in case of a mistake.
  */
 
+static int memory_shift;
+
 /*
  * Monotonic workingset clock for non-resident pages.
  *
@@ -115,6 +117,7 @@ static struct prop_descriptor global_evictions;
 
 void *workingset_eviction(struct address_space *mapping, struct page *page)
 {
+	unsigned int excess_order;
 	struct lruvec *lruvec;
 	unsigned long time;
 
@@ -132,6 +135,26 @@ void *workingset_eviction(struct address_space *mapping, struct page *page)
 	if (mapping_exiting(mapping))
 		return NULL;
 
+	/*
+ 	 * If the planted shadows exceed the refaults, throttle the
+ 	 * planting to relieve the shadow shrinker.
+ 	 */
+	excess_order = mapping->shadow_debt >> memory_shift;
+	if (excess_order &&
+	    (time & ((SWAP_CLUSTER_MAX << (excess_order - 1)) - 1)))
+		return NULL;
+
+	/*
+ 	 * The counter needs a safety buffer above the excess
+ 	 * threshold to not oscillate, but don't plant shadows too
+ 	 * sparsely, either.  This is a trade-off between shrinker
+ 	 * activity during streaming IO and adaptiveness when the
+ 	 * workload actually does start using this file's pages
+ 	 * frequently.
+ 	 */
+	if (excess_order < 4)
+		mapping->shadow_debt++;
+
 	return (void *)((time << EV_SHIFT) | RADIX_TREE_EXCEPTIONAL_ENTRY);
 }
 
@@ -204,6 +227,20 @@ void workingset_zone_balance(struct zone *zone, unsigned long refault_distance)
 	lruvec->shrink_active++;
 }
 
+void workingset_refault(struct address_space *mapping)
+{
+	unsigned int excess_order;
+	unsigned long delta = 1;
+
+	excess_order = mapping->shadow_debt >> memory_shift;
+	if (excess_order)
+		delta = SWAP_CLUSTER_MAX << (excess_order - 1);
+	if (mapping->shadow_debt > delta)
+		mapping->shadow_debt -= delta;
+	else
+		mapping->shadow_debt = 0;
+}
+
 void workingset_activation(struct page *page)
 {
 	struct lruvec *lruvec;
@@ -221,13 +258,166 @@ void workingset_activation(struct page *page)
 		lruvec->shrink_active--;
 }
 
-static int __init workingset_init(void)
+static DEFINE_PER_CPU(unsigned long, nr_shadows);
+static DEFINE_SPINLOCK(shadow_lock);
+static LIST_HEAD(shadow_list);
+
+void workingset_shadows_inc(struct address_space *mapping)
+{
+	might_lock(&shadow_lock);
+	if (mapping->nrshadows == 0) {
+		spin_lock(&shadow_lock);
+		list_add(&mapping->shadow_list, &shadow_list);
+		spin_unlock(&shadow_lock);
+	}
+	mapping->nrshadows++;
+	this_cpu_inc(nr_shadows);
+}
+
+void workingset_shadows_dec(struct address_space *mapping)
+{
+	might_lock(&shadow_lock);
+	if (mapping->nrshadows == 1) {
+		spin_lock(&shadow_lock);
+		list_del(&mapping->shadow_list);
+		spin_unlock(&shadow_lock);
+	}
+	mapping->nrshadows--;
+	this_cpu_dec(nr_shadows);
+}
+
+static unsigned long get_nr_shadows(void)
+{
+	long sum = 0;
+	int cpu;
+
+	for_each_possible_cpu(cpu)
+		sum += per_cpu(nr_shadows, cpu);
+	return max(sum, 0L);
+}
+
+static unsigned long nr_old_shadows(unsigned long cutoff,
+				    unsigned long nr_shadows)
+{
+	if (nr_shadows <= cutoff)
+		return 0;
+	return nr_shadows - cutoff;
+}
+
+static unsigned long prune_mapping(struct address_space *mapping,
+				   unsigned long nr_to_scan,
+				   unsigned long cutoff)
 {
-	int shift;
+	struct radix_tree_iter iter;
+	unsigned long nr_pruned = 0;
+	void **slot;
 
+	rcu_read_lock();
+restart:
+	radix_tree_for_each_slot(slot, &mapping->page_tree, &iter, 0) {
+		unsigned long time_of_eviction;
+		unsigned long nrshadows;
+		unsigned long diff;
+		struct page *page;
+
+		page = radix_tree_deref_slot(slot);
+		if (unlikely(!page))
+			continue;
+		if (!radix_tree_exception(page))
+			continue;
+		if (radix_tree_deref_retry(page))
+			goto restart;
+
+		time_of_eviction = (unsigned long)page >> EV_SHIFT;
+		/*
+		 * Throw out entries older than the cutoff.  But watch
+		 * out for time wrap and pages that were installed
+		 * after the collection cycle started.
+		 */
+		diff = (cutoff - time_of_eviction) & EV_MASK;
+		if (diff & ~(EV_MASK >> 1))
+			continue;
+
+		spin_lock_irq(&mapping->tree_lock);
+		if (radix_tree_delete_item(&mapping->page_tree,
+					   iter.index, page)) {
+			workingset_shadows_dec(mapping);
+			nr_pruned++;
+		}
+		nrshadows = mapping->nrshadows;
+		spin_unlock_irq(&mapping->tree_lock);
+
+		if (nrshadows == 0)
+			break;
+
+		if (--nr_to_scan == 0)
+			break;
+	}
+	rcu_read_unlock();
+	return nr_pruned;
+}
+
+static int prune_shadows(struct shrinker *shrink, struct shrink_control *sc)
+{
+	unsigned long nr_shadows;
+	unsigned long nr_to_scan;
+	unsigned long nr_max;
+	unsigned long nr_old;
+	unsigned long cutoff;
+	unsigned long now;
+
+	nr_shadows = get_nr_shadows();
+	if (!nr_shadows)
+		return 0;
+
+	nr_max = 2UL << memory_shift;
+	nr_old = nr_old_shadows(nr_max, nr_shadows);
+
+	if (!sc->nr_to_scan)
+		return nr_old;
+
+	nr_to_scan = sc->nr_to_scan;
+	now = atomic_long_read(&workingset_time);
+	cutoff = (now - nr_max) & EV_MASK;
+
+	while (nr_to_scan && nr_old) {
+		struct address_space *mapping;
+		unsigned long nr_pruned;
+
+		spin_lock(&shadow_lock);
+		if (list_empty(&shadow_list)) {
+			spin_unlock(&shadow_lock);
+			return 0;
+		}
+		mapping = list_entry(shadow_list.prev,
+				     struct address_space,
+				     shadow_list);
+		__iget(mapping->host);
+		list_move(&mapping->shadow_list, &shadow_list);
+		spin_unlock(&shadow_lock);
+
+		nr_pruned = prune_mapping(mapping, nr_to_scan, cutoff);
+		nr_to_scan -= nr_pruned;
+		iput(mapping->host);
+
+		count_vm_events(WORKINGSET_SHADOWS_RECLAIMED, nr_pruned);
+
+		nr_old = nr_old_shadows(nr_max, get_nr_shadows());
+	}
+	return nr_old;
+}
+
+static struct shrinker shadow_shrinker = {
+	.shrink = prune_shadows,
+	.seeks = 1,
+};
+
+static int __init workingset_init(void)
+{
 	/* XXX: adapt shift during memory hotplug */
-	shift = ilog2(global_dirtyable_memory() - 1);
-	prop_descriptor_init(&global_evictions, shift);
+	memory_shift = ilog2(global_dirtyable_memory() - 1);
+	prop_descriptor_init(&global_evictions, memory_shift);
+	register_shrinker(&shadow_shrinker);
 	return 0;
 }
 module_init(workingset_init);
-- 
1.8.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
