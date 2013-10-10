From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 8/8] mm: workingset: keep shadow entries in check
Date: Thu, 10 Oct 2013 17:47:02 -0400
Message-ID: <1381441622-26215-9-git-send-email-hannes@cmpxchg.org>
References: <1381441622-26215-1-git-send-email-hannes@cmpxchg.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1381441622-26215-1-git-send-email-hannes@cmpxchg.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andi Kleen <andi@firstfloor.org>, Andrea Arcangeli <aarcange@redhat.com>, Greg Thelen <gthelen@google.com>, Christoph Hellwig <hch@infradead.org>, Hugh Dickins <hughd@google.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan.kim@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Roman Gushchin <klamm@yandex-team.ru>, Ozgun Erdogan <ozgun@citusdata.com>, Metin Doslu <metin@citusdata.com>, Vlastimil Babka <vbabka@suse.cz>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
List-Id: linux-mm.kvack.org

Previously, page cache radix tree nodes were freed after reclaim
emptied out their page pointers.  But now reclaim stores shadow
entries in their place, which are only reclaimed when the inodes
themselves are reclaimed.  This is problematic for bigger files that
are still in use after they have a significant amount of their cache
reclaimed, without any of those pages actually refaulting.  The shadow
entries will just sit there and waste memory.  In the worst case, the
shadow entries will accumulate until the machine runs out of memory.

To get this under control, a list of inodes that contain shadow
entries is maintained.  If the global number of shadows exceeds a
certain threshold, a shrinker is activated that reclaims old entries
from the mappings.  This is heavy-handed but it should not be a hot
path and is mainly there to protect from accidentally/maliciously
induced OOM kills.  The global list is also not a problem because the
modifications are very rare: inodes are added once in their lifetime
when the first shadow entry is stored (i.e. the first page reclaimed)
and lazily removed when the inode exits.  Or if the shrinker removes
all shadow entries.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 fs/inode.c                |  17 +---
 include/linux/fs.h        |   1 +
 include/linux/mmzone.h    |   1 +
 include/linux/swap.h      |   4 +
 include/linux/writeback.h |   1 +
 mm/filemap.c              |   4 +-
 mm/page-writeback.c       |   2 +-
 mm/truncate.c             |   2 +-
 mm/vmstat.c               |   1 +
 mm/workingset.c           | 252 ++++++++++++++++++++++++++++++++++++++++++++++
 10 files changed, 269 insertions(+), 16 deletions(-)

diff --git a/fs/inode.c b/fs/inode.c
index 56712ac..040210f 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -169,6 +169,7 @@ int inode_init_always(struct super_block *sb, struct inode *inode)
 	mapping->private_data = NULL;
 	mapping->backing_dev_info = &default_backing_dev_info;
 	mapping->writeback_index = 0;
+	workingset_init_mapping(mapping);
 
 	/*
 	 * If the block_device provides a backing_dev_info for client
@@ -547,19 +548,11 @@ static void evict(struct inode *inode)
 	inode_wait_for_writeback(inode);
 
 	/*
-	 * Page reclaim may happen concurrently against pages in this
-	 * address space (pinned by the page lock).  Make sure that it
-	 * does not plant shadow pages behind the final truncate's
-	 * back, or they will be lost forever.
-	 *
-	 * As truncation uses a lockless tree lookup, acquire the
-	 * spinlock to make sure any ongoing tree modification that
-	 * does not see AS_EXITING is completed before starting the
-	 * final truncate.
+	 * Tell page reclaim that the address space is going away,
+	 * before starting the final truncate, to prevent it from
+	 * installing shadow entries that might get lost otherwise.
 	 */
-	spin_lock_irq(&inode->i_data.tree_lock);
-	mapping_set_exiting(&inode->i_data);
-	spin_unlock_irq(&inode->i_data.tree_lock);
+	workingset_exit_mapping(&inode->i_data);
 
 	if (op->evict_inode) {
 		op->evict_inode(inode);
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 9bfa5a5..442aa9a 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -417,6 +417,7 @@ struct address_space {
 	/* Protected by tree_lock together with the radix tree */
 	unsigned long		nrpages;	/* number of total pages */
 	unsigned long		nrshadows;	/* number of shadow entries */
+	struct list_head	shadow_list;	/* list of mappings with shadows */
 	pgoff_t			writeback_index;/* writeback starts here */
 	const struct address_space_operations *a_ops;	/* methods */
 	unsigned long		flags;		/* error bits/gfp mask */
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 118ba9f..1424aa1 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -144,6 +144,7 @@ enum zone_stat_item {
 #endif
 	WORKINGSET_REFAULT,
 	WORKINGSET_ACTIVATE,
+	WORKINGSET_SHADOWS_RECLAIMED,
 	NR_ANON_TRANSPARENT_HUGEPAGES,
 	NR_FREE_CMA_PAGES,
 	NR_VM_ZONE_STAT_ITEMS };
diff --git a/include/linux/swap.h b/include/linux/swap.h
index b83cf61..891809b 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -261,9 +261,13 @@ struct swap_list_t {
 };
 
 /* linux/mm/workingset.c */
+void workingset_init_mapping(struct address_space *mapping);
+void workingset_exit_mapping(struct address_space *mapping);
 void *workingset_eviction(struct address_space *mapping, struct page *page);
 bool workingset_refault(void *shadow);
 void workingset_activation(struct page *page);
+void workingset_shadows_inc(struct address_space *mapping);
+void workingset_shadows_dec(struct address_space *mapping);
 
 /* linux/mm/page_alloc.c */
 extern unsigned long totalram_pages;
diff --git a/include/linux/writeback.h b/include/linux/writeback.h
index 021b8a3..557cc4b 100644
--- a/include/linux/writeback.h
+++ b/include/linux/writeback.h
@@ -152,6 +152,7 @@ struct ctl_table;
 int dirty_writeback_centisecs_handler(struct ctl_table *, int,
 				      void __user *, size_t *, loff_t *);
 
+unsigned long global_dirtyable_memory(void);
 void global_dirty_limits(unsigned long *pbackground, unsigned long *pdirty);
 unsigned long bdi_dirty_limit(struct backing_dev_info *bdi,
 			       unsigned long dirty);
diff --git a/mm/filemap.c b/mm/filemap.c
index 8ef41b7..3e8d3a1 100644
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
@@ -466,7 +466,7 @@ static int page_cache_insert(struct address_space *mapping, pgoff_t offset,
 		if (!radix_tree_exceptional_entry(p))
 			return -EEXIST;
 		radix_tree_replace_slot(slot, page);
-		mapping->nrshadows--;
+		workingset_shadows_dec(mapping);
 		if (shadowp)
 			*shadowp = p;
 		return 0;
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index f5236f8..05812b8 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -234,7 +234,7 @@ static unsigned long highmem_dirtyable_memory(unsigned long total)
  * Returns the global number of pages potentially available for dirty
  * page cache.  This is the base value for the global dirty limits.
  */
-static unsigned long global_dirtyable_memory(void)
+unsigned long global_dirtyable_memory(void)
 {
 	unsigned long x;
 
diff --git a/mm/truncate.c b/mm/truncate.c
index 86866f1..847aa16 100644
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
index 3ac830d..ea5993f 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -772,6 +772,7 @@ const char * const vmstat_text[] = {
 #endif
 	"workingset_refault",
 	"workingset_activate",
+	"workingset_shadows_reclaimed",
 	"nr_anon_transparent_hugepages",
 	"nr_free_cma",
 	"nr_dirty_threshold",
diff --git a/mm/workingset.c b/mm/workingset.c
index 1c114cd..31174bb 100644
--- a/mm/workingset.c
+++ b/mm/workingset.c
@@ -152,6 +152,62 @@
  * refault distance will immediately activate the refaulting page.
  */
 
+struct percpu_counter nr_shadows;
+
+static DEFINE_SPINLOCK(shadow_lock);
+static LIST_HEAD(shadow_mappings);
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
+	/*
+	 * Page reclaim may happen concurrently against pages in this
+	 * address space (pinned by the page lock).  Make sure that it
+	 * does not plant shadow pages behind the final truncate's
+	 * back, or they will be lost forever.
+	 *
+	 * As truncation uses a lockless tree lookup, acquire the
+	 * spinlock to make sure any ongoing tree modification that
+	 * does not see AS_EXITING is completed before starting the
+	 * final truncate.
+	 */
+	spin_lock_irq(&mapping->tree_lock);
+	mapping_set_exiting(mapping);
+	/*
+	 * Take the mapping off the shrinker list, the final truncate
+	 * is about to remove potentially remaining shadow entries.
+	 */
+	if (!list_empty(&mapping->shadow_list)) {
+		/*
+		 * shadow_lock is irq-safe but nests inside the
+		 * irq-safe mapping->tree_lock, so don't bother.
+		 */
+		spin_lock(&shadow_lock);
+		list_del(&mapping->shadow_list);
+		spin_unlock(&shadow_lock);
+	}
+	spin_unlock_irq(&mapping->tree_lock);
+}
+
 static void *pack_shadow(unsigned long eviction, struct zone *zone)
 {
 	eviction = (eviction << NODES_SHIFT) | zone_to_nid(zone);
@@ -252,3 +308,199 @@ void workingset_activation(struct page *page)
 {
 	atomic_long_inc(&page_zone(page)->inactive_age);
 }
+
+/*
+ * Explicit shadow shrinking
+ *
+ * In most cases, shadow entries are refaulted or truncated along with
+ * inode reclaim before their radix tree node consumption becomes a
+ * problem.  However, to protect against the odd/malicious workload,
+ * the following code pushes them back should they grow out of bounds.
+ *
+ * A global list of page cache objects (struct address_space) that
+ * host shadow entries is maintained lazily.  This means that the
+ * first shadow entry links the object to the list, but it is only
+ * removed when the inode is destroyed or the shrinker reclaimed the
+ * last shadow entry in the object, making list modifications a very
+ * rare event.
+ *
+ * Should the shadow entries exceed a certain number under memory
+ * pressure, the shrinker will walk the list and scan each object's
+ * radix tree to delete shadows that would no longer have a refault
+ * effect anyway, i.e. whose refault distance is already bigger than
+ * the zone's active list.
+ */
+
+/**
+ * workingset_shadows_inc - count a shadow entry insertion
+ * @mapping: page cache object
+ *
+ * Counts a new shadow entry in @mapping, caller must hold
+ * @mapping->tree_lock.
+ */
+void workingset_shadows_inc(struct address_space *mapping)
+{
+	VM_BUG_ON(!spin_is_locked(&mapping->tree_lock));
+
+	might_lock(&shadow_lock);
+
+	if (mapping->nrshadows == 0 && list_empty(&mapping->shadow_list)) {
+		/*
+		 * shadow_lock is irq-safe but nests inside the
+		 * irq-safe mapping->tree_lock, so don't bother.
+		 */
+		spin_lock(&shadow_lock);
+		list_add(&mapping->shadow_list, &shadow_mappings);
+		spin_unlock(&shadow_lock);
+	}
+
+	mapping->nrshadows++;
+	percpu_counter_add(&nr_shadows, 1);
+}
+
+/**
+ * workingset_shadows_dec - count a shadow entry removal
+ * @mapping: page cache object
+ *
+ * Counts the removal of a shadow entry from @mapping, caller must
+ * hold @mapping->tree_lock.
+ */
+void workingset_shadows_dec(struct address_space *mapping)
+{
+	VM_BUG_ON(!spin_is_locked(&mapping->tree_lock));
+
+	mapping->nrshadows--;
+	percpu_counter_add(&nr_shadows, -1);
+	/*
+	 * shadow_mappings operations are costly, so we keep the
+	 * mapping linked here even without any shadows left and
+	 * unlink it lazily in the shadow shrinker or when the inode
+	 * is destroyed.
+	 */
+}
+
+static unsigned long get_nr_old_shadows(void)
+{
+	unsigned long nr_max;
+	unsigned long nr;
+
+	nr = percpu_counter_read_positive(&nr_shadows);
+	/*
+	 * Every shadow entry with a refault distance bigger than the
+	 * active list is ignored and so NR_ACTIVE_FILE would be a
+	 * reasonable ceiling.  But scanning and shrinking shadow
+	 * entries is quite expensive, so be generous.
+	 */
+	nr_max = global_dirtyable_memory() * 4;
+
+	if (nr <= nr_max)
+		return 0;
+	return nr - nr_max;
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
+		if (distance <= zone_page_state(zone, NR_ACTIVE_FILE))
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
+
+	return nr_scanned;
+}
+
+static unsigned long count_shadows(struct shrinker *shrink,
+				   struct shrink_control *sc)
+{
+	return get_nr_old_shadows();
+}
+
+static unsigned long scan_shadows(struct shrinker *shrink,
+				  struct shrink_control *sc)
+{
+	unsigned long nr_to_scan = sc->nr_to_scan;
+
+	do {
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
+		if (mapping->nrshadows)
+			nr_to_scan -= scan_mapping(mapping, nr_to_scan);
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
+	} while (nr_to_scan && get_nr_old_shadows());
+
+	return sc->nr_to_scan - nr_to_scan;
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
+	percpu_counter_init(&nr_shadows, 0);
+	register_shrinker(&shadow_shrinker);
+	return 0;
+}
+core_initcall(workingset_init);
-- 
1.8.4
