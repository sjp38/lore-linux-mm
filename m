Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id 587846B006C
	for <linux-mm@kvack.org>; Tue,  6 Aug 2013 18:44:58 -0400 (EDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 9/9] mm: workingset: keep shadow entries in check
Date: Tue,  6 Aug 2013 18:44:10 -0400
Message-Id: <1375829050-12654-10-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1375829050-12654-1-git-send-email-hannes@cmpxchg.org>
References: <1375829050-12654-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andi Kleen <andi@firstfloor.org>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Christoph Hellwig <hch@infradead.org>, Hugh Dickins <hughd@google.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan.kim@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Roman Gushchin <klamm@yandex-team.ru>, Ozgun Erdogan <ozgun@citusdata.com>, Metin Doslu <metin@citusdata.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

Previously, page cache radix tree nodes were freed after reclaim
emptied out their page pointers.  But now reclaim stores shadow
entries in their place, which are only reclaimed when the inodes
themselves are reclaimed.  This is problematic for bigger files that
are still in use after they have a significant amount of their cache
reclaimed, without any of those pages actually refaulting.  The shadow
entries will just sit there and waste memory.  In the worst case, the
shadow entries will accumulate until the machine runs out of memory.

To get this under control, two mechanisms are used:

1. a refault balance counter is maintained per inode that grows with
   each shadow entry planted and shrinks with each refault.  Once the
   counter grows beyond a certain threshold, planting new shadows in
   that file is throttled.  It's per file so that a single file can
   not disable thrashing detection globally.  However, this still
   allows shadow entries to grow excessively when many files show this
   usage pattern, and so:

2. a list of inodes that contain shadow entries is maintained.  If the
   global number of shadows exceeds a certain threshold, a shrinker is
   activated that reclaims old entries from the mappings.  This is
   heavy-handed but it should not be a common case and is only there
   to protect from accidentally/maliciously induced OOM kills.  The
   global list is also not a problem because the modifications are
   very rare: inodes are added once in their lifetime when the first
   shadow entry is stored (i.e. the first page reclaimed) and lazily
   removed when the inode exits.  Or if the shrinker removes all
   shadow entries.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 fs/inode.c             |   5 +-
 include/linux/fs.h     |   2 +
 include/linux/mmzone.h |   1 +
 include/linux/swap.h   |   5 +
 mm/filemap.c           |   5 +-
 mm/truncate.c          |   2 +-
 mm/vmstat.c            |   1 +
 mm/workingset.c        | 248 +++++++++++++++++++++++++++++++++++++++++++++++++
 8 files changed, 263 insertions(+), 6 deletions(-)

diff --git a/fs/inode.c b/fs/inode.c
index 8862b1b..b23b141 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -169,6 +169,7 @@ int inode_init_always(struct super_block *sb, struct inode *inode)
 	mapping->private_data = NULL;
 	mapping->backing_dev_info = &default_backing_dev_info;
 	mapping->writeback_index = 0;
+	workingset_init_mapping(mapping);
 
 	/*
 	 * If the block_device provides a backing_dev_info for client
@@ -546,9 +547,7 @@ static void evict(struct inode *inode)
 	 */
 	inode_wait_for_writeback(inode);
 
-	spin_lock_irq(&inode->i_data.tree_lock);
-	mapping_set_exiting(&inode->i_data);
-	spin_unlock_irq(&inode->i_data.tree_lock);
+	workingset_exit_mapping(&inode->i_data);
 
 	if (op->evict_inode) {
 		op->evict_inode(inode);
diff --git a/include/linux/fs.h b/include/linux/fs.h
index ac5d84e..ea3c25b 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -417,6 +417,8 @@ struct address_space {
 	/* Protected by tree_lock together with the radix tree */
 	unsigned long		nrpages;	/* number of total pages */
 	unsigned long		nrshadows;	/* number of shadow entries */
+	struct list_head	shadow_list;	/* list of mappings with shadows */
+	unsigned long		shadow_debt;	/* shadow entries with unmatched refaults */
 	pgoff_t			writeback_index;/* writeback starts here */
 	const struct address_space_operations *a_ops;	/* methods */
 	unsigned long		flags;		/* error bits/gfp mask */
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index e75fc92..6e74ac5 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -144,6 +144,7 @@ enum zone_stat_item {
 	WORKINGSET_STALE,
 	WORKINGSET_BALANCE,
 	WORKINGSET_BALANCE_FORCE,
+	WORKINGSET_SHADOWS_RECLAIMED,
 	NR_ANON_TRANSPARENT_HUGEPAGES,
 	NR_FREE_CMA_PAGES,
 	NR_VM_ZONE_STAT_ITEMS };
diff --git a/include/linux/swap.h b/include/linux/swap.h
index 441845d..4816c50 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -261,9 +261,14 @@ struct swap_list_t {
 };
 
 /* linux/mm/workingset.c */
+void workingset_init_mapping(struct address_space *mapping);
+void workingset_exit_mapping(struct address_space *mapping);
 void *workingset_eviction(struct address_space *mapping, struct page *page);
 void workingset_refault(void *shadow);
+void workingset_count_refault(struct address_space *mapping);
 void workingset_activation(struct page *page);
+void workingset_shadows_inc(struct address_space *mapping);
+void workingset_shadows_dec(struct address_space *mapping);
 
 /* linux/mm/page_alloc.c */
 extern unsigned long totalram_pages;
diff --git a/mm/filemap.c b/mm/filemap.c
index ab4351e..bd4121b 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -132,7 +132,7 @@ void __delete_from_page_cache(struct page *page, void *shadow)
 
 		slot = radix_tree_lookup_slot(&mapping->page_tree, page->index);
 		radix_tree_replace_slot(slot, shadow);
-		mapping->nrshadows++;
+		workingset_shadows_inc(mapping);
 	} else
 		radix_tree_delete(&mapping->page_tree, page->index);
 	page->mapping = NULL;
@@ -466,7 +466,8 @@ static int page_cache_insert(struct address_space *mapping, pgoff_t offset,
 		if (!radix_tree_exceptional_entry(p))
 			return -EEXIST;
 		radix_tree_replace_slot(slot, page);
-		mapping->nrshadows--;
+		workingset_count_refault(mapping);
+		workingset_shadows_dec(mapping);
 		return 0;
 	}
 	return radix_tree_insert(&mapping->page_tree, offset, page);
diff --git a/mm/truncate.c b/mm/truncate.c
index 5c85dd4..76064a4 100644
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
index 2b14f7a..2c5bf80 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -741,6 +741,7 @@ const char * const vmstat_text[] = {
 	"workingset_stale",
 	"workingset_balance",
 	"workingset_balance_force",
+	"workingset_shadows_reclaimed",
 	"nr_anon_transparent_hugepages",
 	"nr_free_cma",
 	"nr_dirty_threshold",
diff --git a/mm/workingset.c b/mm/workingset.c
index 65714d2..5c5cf74 100644
--- a/mm/workingset.c
+++ b/mm/workingset.c
@@ -84,6 +84,55 @@
  * challenged without incurring major faults in case of a mistake.
  */
 
+static DEFINE_PER_CPU(unsigned long, nr_shadows);
+static DEFINE_SPINLOCK(shadow_lock);
+static LIST_HEAD(shadow_mappings);
+static int memory_shift;
+
+/**
+ * workingset_init_mapping - prepare address space for page reclaim
+ * @mapping: address space
+ *
+ * Must be called when the inode is instantiated, before any page
+ * cache is populated.
+ */
+void workingset_init_mapping(struct address_space *mapping)
+{
+	INIT_LIST_HEAD(&mapping->shadow_list);
+	/*
+	 * Throttle installation of shadow entries in new inodes from
+	 * the beginning.  Subsequent refaults will decrease this to
+	 * make the inode a more trusted source when evaluating
+	 * workingset changes.  Or not, in which case we put less
+	 * pressure on the shadow shrinker.
+	 */
+	mapping->shadow_debt = global_dirtyable_memory();
+}
+
+/**
+ * workingset_exit_mapping - tell page reclaim address space is exiting
+ * @mapping: address space
+ *
+ * Must be called before the final truncate, to prevent page reclaim
+ * from installing shadow entries behind the back of the inode
+ * teardown process.
+ */
+void workingset_exit_mapping(struct address_space *mapping)
+{
+	spin_lock_irq(&mapping->tree_lock);
+	mapping_set_exiting(mapping);
+	/*
+	 * Take it off the shrinker list, the final truncate is about
+	 * to remove potentially remaining shadow entries.
+	 */
+	if (!list_empty(&mapping->shadow_list)) {
+		spin_lock(&shadow_lock);
+		list_del(&mapping->shadow_list);
+		spin_unlock(&shadow_lock);
+	}
+	spin_unlock_irq(&mapping->tree_lock);
+}
+
 static void *pack_shadow(unsigned long time, struct zone *zone)
 {
 	time = (time << NODES_SHIFT) | zone_to_nid(zone);
@@ -131,6 +180,7 @@ static void unpack_shadow(void *shadow,
 void *workingset_eviction(struct address_space *mapping, struct page *page)
 {
 	struct zone *zone = page_zone(page);
+	unsigned long excess_order;
 	unsigned long time;
 
 	time = atomic_long_inc_return(&zone->workingset_time);
@@ -144,6 +194,25 @@ void *workingset_eviction(struct address_space *mapping, struct page *page)
 	if (mapping_exiting(mapping))
 		return NULL;
 
+	/*
+	 * If the planted shadows exceed the refaults, throttle new
+	 * planting to relieve the shadow shrinker.
+	 */
+	excess_order = mapping->shadow_debt >> memory_shift;
+	if (excess_order &&
+	    (time & ((SWAP_CLUSTER_MAX << (excess_order - 1)) - 1)))
+		return NULL;
+
+	/*
+	 * The counter needs a safety buffer so that we don't
+	 * oscillate, but don't plant shadows too sparsely, either.
+	 * This is a trade-off between shrinker activity during
+	 * streaming IO and speed of adapting when the workload
+	 * actually does start to use this file's pages frequently.
+	 */
+	if (excess_order < 4)
+		mapping->shadow_debt++;
+
 	return pack_shadow(time, zone);
 }
 
@@ -195,6 +264,24 @@ void workingset_refault(void *shadow)
 EXPORT_SYMBOL(workingset_refault);
 
 /**
+ * workingset_count_refault - account for finished refault
+ * @mapping: address space that was repopulated
+ *
+ * Account for a refault after the page has been fully reinstated in
+ * @mapping.
+ */
+void workingset_count_refault(struct address_space *mapping)
+{
+	unsigned int excess_order;
+	unsigned long delta = 1;
+
+	excess_order = mapping->shadow_debt >> memory_shift;
+	if (excess_order)
+		delta = SWAP_CLUSTER_MAX << (excess_order - 1);
+	mapping->shadow_debt -= min(delta, mapping->shadow_debt);
+}
+
+/**
  * workingset_activation - note a page activation
  * @page: page that is being activated
  */
@@ -211,3 +298,164 @@ void workingset_activation(struct page *page)
 	if (zone->shrink_active > 0)
 		zone->shrink_active--;
 }
+
+void workingset_shadows_inc(struct address_space *mapping)
+{
+	might_lock(&shadow_lock);
+	if (mapping->nrshadows++ == 0 && list_empty(&mapping->shadow_list)) {
+		spin_lock(&shadow_lock);
+		list_add(&mapping->shadow_list, &shadow_mappings);
+		spin_unlock(&shadow_lock);
+	}
+	this_cpu_inc(nr_shadows);
+}
+
+void workingset_shadows_dec(struct address_space *mapping)
+{
+	mapping->nrshadows--;
+	this_cpu_dec(nr_shadows);
+	/*
+	 * shadow_mappings operations are costly, so we keep the
+	 * mapping linked here even without any shadows left and
+	 * unlink it lazily in the shadow shrinker or when the inode
+	 * is destroyed.
+	 */
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
+static unsigned long nr_old_shadows(unsigned long nr_shadows,
+				    unsigned long cutoff)
+{
+	if (nr_shadows <= cutoff)
+		return 0;
+	return nr_shadows - cutoff;
+}
+
+static unsigned long scan_mapping(struct address_space *mapping,
+				  unsigned long nr_to_scan)
+{
+	unsigned long nr_scanned = 0;
+	struct radix_tree_iter iter;
+	void **slot;
+
+	rcu_read_lock();
+restart:
+	radix_tree_for_each_slot(slot, &mapping->page_tree, &iter, 0) {
+		unsigned long nrshadows;
+		unsigned long distance;
+		unsigned long nractive;
+		struct zone *zone;
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
+		unpack_shadow(page, &zone, &distance);
+
+		nractive = zone_page_state(zone, NR_ACTIVE_FILE);
+		if (distance <= nractive)
+			continue;
+
+		spin_lock_irq(&mapping->tree_lock);
+		if (radix_tree_delete_item(&mapping->page_tree,
+					   iter.index, page)) {
+			inc_zone_state(zone, WORKINGSET_SHADOWS_RECLAIMED);
+			workingset_shadows_dec(mapping);
+			nr_scanned++;
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
+	return nr_scanned;
+}
+
+static unsigned long count_shadows(struct shrinker *shrink,
+				   struct shrink_control *sc)
+{
+	return nr_old_shadows(get_nr_shadows(), global_dirtyable_memory());
+}
+
+static unsigned long scan_shadows(struct shrinker *shrink,
+				  struct shrink_control *sc)
+{
+	unsigned long nr_scanned = 0;
+	unsigned long nr_to_scan;
+	unsigned long nr_max;
+	unsigned long nr_old;
+
+	nr_to_scan = sc->nr_to_scan;
+	nr_max = global_dirtyable_memory() * 2;
+	nr_old = nr_old_shadows(get_nr_shadows(), nr_max);
+
+	while (nr_to_scan && nr_old) {
+		struct address_space *mapping;
+
+		spin_lock_irq(&shadow_lock);
+		if (list_empty(&shadow_mappings)) {
+			spin_unlock_irq(&shadow_lock);
+			break;
+		}
+		mapping = list_entry(shadow_mappings.prev,
+				     struct address_space,
+				     shadow_list);
+		list_move(&mapping->shadow_list, &shadow_mappings);
+		__iget(mapping->host);
+		spin_unlock_irq(&shadow_lock);
+
+		if (mapping->nrshadows) {
+			unsigned long nr;
+
+			nr = scan_mapping(mapping, nr_to_scan);
+			nr_to_scan -= nr;
+			nr_scanned += nr;
+		}
+
+		spin_lock_irq(&mapping->tree_lock);
+		if (mapping->nrshadows == 0) {
+			spin_lock(&shadow_lock);
+			list_del_init(&mapping->shadow_list);
+			spin_unlock(&shadow_lock);
+		}
+		spin_unlock_irq(&mapping->tree_lock);
+
+		iput(mapping->host);
+
+		nr_old = nr_old_shadows(get_nr_shadows(), nr_max);
+	}
+	return nr_scanned;
+}
+
+static struct shrinker shadow_shrinker = {
+	.count_objects = count_shadows,
+	.scan_objects = scan_shadows,
+	.seeks = 1,
+};
+
+static int __init workingset_init(void)
+{
+	memory_shift = ilog2(global_dirtyable_memory());
+	register_shrinker(&shadow_shrinker);
+	return 0;
+}
+core_initcall(workingset_init);
-- 
1.8.3.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
