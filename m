Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id AE1866B02AE
	for <linux-mm@kvack.org>; Mon, 19 Feb 2018 14:46:36 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id w19so5828329pgv.4
        for <linux-mm@kvack.org>; Mon, 19 Feb 2018 11:46:36 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id e3si5231254pgr.135.2018.02.19.11.46.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 19 Feb 2018 11:46:34 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v7 60/61] dax: Convert to XArray
Date: Mon, 19 Feb 2018 11:45:55 -0800
Message-Id: <20180219194556.6575-61-willy@infradead.org>
In-Reply-To: <20180219194556.6575-1-willy@infradead.org>
References: <20180219194556.6575-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <mawilcox@microsoft.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

From: Matthew Wilcox <mawilcox@microsoft.com>

The DAX code (by its nature) is deeply interwoven with the radix tree
infrastructure, doing operations directly on the radix tree slots.
Convert the whole file to use XArray concepts; mostly passing around
xa_state instead of address_space, index or slot.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 fs/dax.c | 366 +++++++++++++++++++++++++--------------------------------------
 1 file changed, 142 insertions(+), 224 deletions(-)

diff --git a/fs/dax.c b/fs/dax.c
index 61cb25c8b9fd..1967d7d6b907 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -45,6 +45,7 @@
 /* The 'colour' (ie low bits) within a PMD of a page offset.  */
 #define PG_PMD_COLOUR	((PMD_SIZE >> PAGE_SHIFT) - 1)
 #define PG_PMD_NR	(PMD_SIZE >> PAGE_SHIFT)
+#define PMD_ORDER	(PMD_SHIFT - PAGE_SHIFT)
 
 static wait_queue_head_t wait_table[DAX_WAIT_TABLE_ENTRIES];
 
@@ -74,21 +75,26 @@ fs_initcall(init_dax_wait_table);
 #define DAX_ZERO_PAGE	(1UL << 2)
 #define DAX_EMPTY	(1UL << 3)
 
-static unsigned long dax_radix_sector(void *entry)
+static bool xa_is_dax_locked(void *entry)
+{
+	return xa_to_value(entry) & DAX_ENTRY_LOCK;
+}
+
+static unsigned long xa_to_dax_sector(void *entry)
 {
 	return xa_to_value(entry) >> DAX_SHIFT;
 }
 
-static void *dax_radix_locked_entry(sector_t sector, unsigned long flags)
+static void *xa_mk_dax_locked(sector_t sector, unsigned long flags)
 {
 	return xa_mk_value(flags | ((unsigned long)sector << DAX_SHIFT) |
 			DAX_ENTRY_LOCK);
 }
 
-static unsigned int dax_radix_order(void *entry)
+static unsigned int dax_entry_order(void *entry)
 {
 	if (xa_to_value(entry) & DAX_PMD)
-		return PMD_SHIFT - PAGE_SHIFT;
+		return PMD_ORDER;
 	return 0;
 }
 
@@ -113,10 +119,10 @@ static int dax_is_empty_entry(void *entry)
 }
 
 /*
- * DAX radix tree locking
+ * DAX page cache entry locking
  */
 struct exceptional_entry_key {
-	struct address_space *mapping;
+	struct xarray *xa;
 	pgoff_t entry_start;
 };
 
@@ -125,9 +131,10 @@ struct wait_exceptional_entry_queue {
 	struct exceptional_entry_key key;
 };
 
-static wait_queue_head_t *dax_entry_waitqueue(struct address_space *mapping,
-		pgoff_t index, void *entry, struct exceptional_entry_key *key)
+static wait_queue_head_t *dax_entry_waitqueue(struct xa_state *xas,
+		void *entry, struct exceptional_entry_key *key)
 {
+	unsigned long index = xas->xa_index;
 	unsigned long hash;
 
 	/*
@@ -138,10 +145,10 @@ static wait_queue_head_t *dax_entry_waitqueue(struct address_space *mapping,
 	if (dax_is_pmd_entry(entry))
 		index &= ~PG_PMD_COLOUR;
 
-	key->mapping = mapping;
+	key->xa = xas->xa;
 	key->entry_start = index;
 
-	hash = hash_long((unsigned long)mapping ^ index, DAX_WAIT_TABLE_BITS);
+	hash = hash_long((unsigned long)xas->xa ^ index, DAX_WAIT_TABLE_BITS);
 	return wait_table + hash;
 }
 
@@ -152,7 +159,7 @@ static int wake_exceptional_entry_func(wait_queue_entry_t *wait, unsigned int mo
 	struct wait_exceptional_entry_queue *ewait =
 		container_of(wait, struct wait_exceptional_entry_queue, wait);
 
-	if (key->mapping != ewait->key.mapping ||
+	if (key->xa != ewait->key.xa ||
 	    key->entry_start != ewait->key.entry_start)
 		return 0;
 	return autoremove_wake_function(wait, mode, sync, NULL);
@@ -163,13 +170,12 @@ static int wake_exceptional_entry_func(wait_queue_entry_t *wait, unsigned int mo
  * The important information it's conveying is whether the entry at
  * this index used to be a PMD entry.
  */
-static void dax_wake_mapping_entry_waiter(struct address_space *mapping,
-		pgoff_t index, void *entry, bool wake_all)
+static void dax_wake_entry(struct xa_state *xas, void *entry, bool wake_all)
 {
 	struct exceptional_entry_key key;
 	wait_queue_head_t *wq;
 
-	wq = dax_entry_waitqueue(mapping, index, entry, &key);
+	wq = dax_entry_waitqueue(xas, entry, &key);
 
 	/*
 	 * Checking for locked entry and prepare_to_wait_exclusive() happens
@@ -182,52 +188,27 @@ static void dax_wake_mapping_entry_waiter(struct address_space *mapping,
 }
 
 /*
- * Check whether the given slot is locked.  Must be called with xa_lock held.
+ * Mark the given entry as locked.  Must be called with xa_lock held.
  */
-static inline int slot_locked(struct address_space *mapping, void **slot)
+static inline void *lock_entry(struct xa_state *xas)
 {
-	unsigned long entry = xa_to_value(
-		radix_tree_deref_slot_protected(slot, &mapping->pages.xa_lock));
-	return entry & DAX_ENTRY_LOCK;
-}
-
-/*
- * Mark the given slot as locked.  Must be called with xa_lock held.
- */
-static inline void *lock_slot(struct address_space *mapping, void **slot)
-{
-	unsigned long v = xa_to_value(
-		radix_tree_deref_slot_protected(slot, &mapping->pages.xa_lock));
+	unsigned long v = xa_to_value(xas_load(xas));
 	void *entry = xa_mk_value(v | DAX_ENTRY_LOCK);
-	radix_tree_replace_slot(&mapping->pages, slot, entry);
-	return entry;
-}
-
-/*
- * Mark the given slot as unlocked.  Must be called with xa_lock held.
- */
-static inline void *unlock_slot(struct address_space *mapping, void **slot)
-{
-	unsigned long v = xa_to_value(
-		radix_tree_deref_slot_protected(slot, &mapping->pages.xa_lock));
-	void *entry = xa_mk_value(v & ~DAX_ENTRY_LOCK);
-	radix_tree_replace_slot(&mapping->pages, slot, entry);
+	xas_store(xas, entry);
 	return entry;
 }
 
 /*
- * Lookup entry in radix tree, wait for it to become unlocked if it is
- * a DAX entry and return it. The caller must call
- * put_unlocked_mapping_entry() when he decided not to lock the entry or
- * put_locked_mapping_entry() when he locked the entry and now wants to
- * unlock it.
+ * Lookup entry in page cache, wait for it to become unlocked if it
+ * is a DAX entry and return it.  The caller must subsequently call
+ * put_unlocked_entry() if it did not lock the entry or
+ * put_locked_entry() if it did lock the entry.
  *
  * Must be called with xa_lock held.
  */
-static void *get_unlocked_mapping_entry(struct address_space *mapping,
-					pgoff_t index, void ***slotp)
+static void *get_unlocked_entry(struct xa_state *xas)
 {
-	void *entry, **slot;
+	void *entry;
 	struct wait_exceptional_entry_queue ewait;
 	wait_queue_head_t *wq;
 
@@ -235,67 +216,59 @@ static void *get_unlocked_mapping_entry(struct address_space *mapping,
 	ewait.wait.func = wake_exceptional_entry_func;
 
 	for (;;) {
-		entry = __radix_tree_lookup(&mapping->pages, index, NULL,
-					  &slot);
-		if (!entry ||
-		    WARN_ON_ONCE(!xa_is_value(entry)) ||
-		    !slot_locked(mapping, slot)) {
-			if (slotp)
-				*slotp = slot;
+		entry = xas_load(xas);
+		if (!entry || WARN_ON_ONCE(!xa_is_value(entry)) ||
+		    !xa_is_dax_locked(entry))
 			return entry;
-		}
 
-		wq = dax_entry_waitqueue(mapping, index, entry, &ewait.key);
+		wq = dax_entry_waitqueue(xas, entry, &ewait.key);
 		prepare_to_wait_exclusive(wq, &ewait.wait,
 					  TASK_UNINTERRUPTIBLE);
-		xa_unlock_irq(&mapping->pages);
+		xas_unlock_irq(xas);
 		schedule();
 		finish_wait(wq, &ewait.wait);
-		xa_lock_irq(&mapping->pages);
+		xas_reset(xas);
+		xas_lock_irq(xas);
 	}
 }
 
-static void dax_unlock_mapping_entry(struct address_space *mapping,
-				     pgoff_t index)
+static void put_locked_entry(struct xa_state *xas, void *entry)
 {
-	void *entry, **slot;
-
-	xa_lock_irq(&mapping->pages);
-	entry = __radix_tree_lookup(&mapping->pages, index, NULL, &slot);
-	if (WARN_ON_ONCE(!entry || !xa_is_value(entry) ||
-			 !slot_locked(mapping, slot))) {
-		xa_unlock_irq(&mapping->pages);
-		return;
-	}
-	unlock_slot(mapping, slot);
-	xa_unlock_irq(&mapping->pages);
-	dax_wake_mapping_entry_waiter(mapping, index, entry, false);
+	entry = xa_mk_value(xa_to_value(entry) & ~DAX_ENTRY_LOCK);
+	xas_reset(xas);
+	xas_lock_irq(xas);
+	xas_store(xas, entry);
+	xas_unlock_irq(xas);
+	dax_wake_entry(xas, entry, false);
 }
 
-static void put_locked_mapping_entry(struct address_space *mapping,
-		pgoff_t index)
+static void dax_unlock_entry(struct address_space *mapping, pgoff_t index)
 {
-	dax_unlock_mapping_entry(mapping, index);
+	XA_STATE(xas, &mapping->pages, index);
+	void *entry = xas_load(&xas);
+
+	if (WARN_ON_ONCE(!xa_is_value(entry) || !xa_is_dax_locked(entry)))
+		return;
+	put_locked_entry(&xas, entry);
 }
 
 /*
- * Called when we are done with radix tree entry we looked up via
- * get_unlocked_mapping_entry() and which we didn't lock in the end.
+ * Called when we are done with page cache entry we looked up via
+ * get_unlocked_entry() and which we didn't lock in the end.
  */
-static void put_unlocked_mapping_entry(struct address_space *mapping,
-				       pgoff_t index, void *entry)
+static void put_unlocked_entry(struct xa_state *xas, void *entry)
 {
 	if (!entry)
 		return;
 
-	/* We have to wake up next waiter for the radix tree entry lock */
-	dax_wake_mapping_entry_waiter(mapping, index, entry, false);
+	/* We have to wake up next waiter for the page cache entry lock */
+	dax_wake_entry(xas, entry, false);
 }
 
 /*
- * Find radix tree entry at given index. If it is a DAX entry, return it
- * with the radix tree entry locked. If the radix tree doesn't contain the
- * given index, create an empty entry for the index and return with it locked.
+ * Find page cache entry at given index. If it is a DAX entry, return it
+ * with the entry locked.  If the page cache doesn't contain the given
+ * index, create an empty entry for the index and return with it locked.
  *
  * When requesting an entry with size DAX_PMD, grab_mapping_entry() will
  * either return that locked entry or will return an error.  This error will
@@ -320,12 +293,14 @@ static void put_unlocked_mapping_entry(struct address_space *mapping,
 static void *grab_mapping_entry(struct address_space *mapping, pgoff_t index,
 		unsigned long size_flag)
 {
+	XA_STATE(xas, &mapping->pages, index);
 	bool pmd_downgrade = false; /* splitting 2MiB entry into 4k entries? */
-	void *entry, **slot;
+	void *entry;
 
+	xas_set_order(&xas, index, size_flag ? PMD_ORDER : 0);
 restart:
-	xa_lock_irq(&mapping->pages);
-	entry = get_unlocked_mapping_entry(mapping, index, &slot);
+	xas_lock_irq(&xas);
+	entry = get_unlocked_entry(&xas);
 
 	if (WARN_ON_ONCE(entry && !xa_is_value(entry))) {
 		entry = ERR_PTR(-EIO);
@@ -335,8 +310,7 @@ static void *grab_mapping_entry(struct address_space *mapping, pgoff_t index,
 	if (entry) {
 		if (size_flag & DAX_PMD) {
 			if (dax_is_pte_entry(entry)) {
-				put_unlocked_mapping_entry(mapping, index,
-						entry);
+				put_unlocked_entry(&xas, entry);
 				entry = ERR_PTR(-EEXIST);
 				goto out_unlock;
 			}
@@ -349,123 +323,75 @@ static void *grab_mapping_entry(struct address_space *mapping, pgoff_t index,
 		}
 	}
 
-	/* No entry for given index? Make sure radix tree is big enough. */
-	if (!entry || pmd_downgrade) {
-		int err;
-
-		if (pmd_downgrade) {
-			/*
-			 * Make sure 'entry' remains valid while we drop
-			 * xa_lock.
-			 */
-			entry = lock_slot(mapping, slot);
-		}
-
-		xa_unlock_irq(&mapping->pages);
+	if (pmd_downgrade) {
+		entry = lock_entry(&xas);
 		/*
 		 * Besides huge zero pages the only other thing that gets
 		 * downgraded are empty entries which don't need to be
 		 * unmapped.
 		 */
-		if (pmd_downgrade && dax_is_zero_entry(entry))
+		if (dax_is_zero_entry(entry)) {
+			xas_unlock_irq(&xas);
 			unmap_mapping_pages(mapping, index & ~PG_PMD_COLOUR,
 							PG_PMD_NR, false);
-
-		err = radix_tree_preload(
-				mapping_gfp_mask(mapping) & ~__GFP_HIGHMEM);
-		if (err) {
-			if (pmd_downgrade)
-				put_locked_mapping_entry(mapping, index);
-			return ERR_PTR(err);
+			xas_reset(&xas);
+			xas_lock_irq(&xas);
 		}
-		xa_lock_irq(&mapping->pages);
-
-		if (!entry) {
-			/*
-			 * We needed to drop the pages lock while calling
-			 * radix_tree_preload() and we didn't have an entry to
-			 * lock.  See if another thread inserted an entry at
-			 * our index during this time.
-			 */
-			entry = __radix_tree_lookup(&mapping->pages, index,
-					NULL, &slot);
-			if (entry) {
-				radix_tree_preload_end();
-				xa_unlock_irq(&mapping->pages);
-				goto restart;
-			}
-		}
-
-		if (pmd_downgrade) {
-			radix_tree_delete(&mapping->pages, index);
-			mapping->nrexceptional--;
-			dax_wake_mapping_entry_waiter(mapping, index, entry,
-					true);
-		}
-
-		entry = dax_radix_locked_entry(0, size_flag | DAX_EMPTY);
-
-		err = __radix_tree_insert(&mapping->pages, index,
-				dax_radix_order(entry), entry);
-		radix_tree_preload_end();
-		if (err) {
-			xa_unlock_irq(&mapping->pages);
-			/*
-			 * Our insertion of a DAX entry failed, most likely
-			 * because we were inserting a PMD entry and it
-			 * collided with a PTE sized entry at a different
-			 * index in the PMD range.  We haven't inserted
-			 * anything into the radix tree and have no waiters to
-			 * wake.
-			 */
-			return ERR_PTR(err);
-		}
-		/* Good, we have inserted empty locked entry into the tree. */
-		mapping->nrexceptional++;
-		xa_unlock_irq(&mapping->pages);
-		return entry;
+		xas_store(&xas, NULL);
+		mapping->nrexceptional--;
+		dax_wake_entry(&xas, entry, true);
+	}
+	if (!entry || pmd_downgrade) {
+		entry = xa_mk_dax_locked(0, size_flag | DAX_EMPTY);
+		xas_store(&xas, entry);
+		if (!xas_error(&xas))
+			mapping->nrexceptional++;
+	} else {
+		entry = lock_entry(&xas);
 	}
-	entry = lock_slot(mapping, slot);
  out_unlock:
-	xa_unlock_irq(&mapping->pages);
+	xas_unlock_irq(&xas);
+	if (xas_nomem(&xas, GFP_NOIO))
+		goto restart;
 	return entry;
 }
 
-static int __dax_invalidate_mapping_entry(struct address_space *mapping,
+static int __dax_invalidate_entry(struct address_space *mapping,
 					  pgoff_t index, bool trunc)
 {
+	XA_STATE(xas, &mapping->pages, index);
 	int ret = 0;
 	void *entry;
-	struct radix_tree_root *pages = &mapping->pages;
 
 	xa_lock_irq(&mapping->pages);
-	entry = get_unlocked_mapping_entry(mapping, index, NULL);
+	entry = get_unlocked_entry(&xas);
 	if (!entry || WARN_ON_ONCE(!xa_is_value(entry)))
 		goto out;
 	if (!trunc &&
-	    (radix_tree_tag_get(pages, index, PAGECACHE_TAG_DIRTY) ||
-	     radix_tree_tag_get(pages, index, PAGECACHE_TAG_TOWRITE)))
+	    (xas_get_tag(&xas, PAGECACHE_TAG_DIRTY) ||
+	     xas_get_tag(&xas, PAGECACHE_TAG_TOWRITE)))
 		goto out;
-	radix_tree_delete(pages, index);
+	xas_store(&xas, NULL);
 	mapping->nrexceptional--;
 	ret = 1;
 out:
-	put_unlocked_mapping_entry(mapping, index, entry);
-	xa_unlock_irq(&mapping->pages);
+	put_unlocked_entry(&xas, entry);
+	xas_unlock_irq(&xas);
 	return ret;
 }
+
 /*
  * Delete DAX entry at @index from @mapping.  Wait for it
  * to be unlocked before deleting it.
  */
 int dax_delete_mapping_entry(struct address_space *mapping, pgoff_t index)
 {
-	int ret = __dax_invalidate_mapping_entry(mapping, index, true);
+	int ret = __dax_invalidate_entry(mapping, index, true);
 
 	/*
 	 * This gets called from truncate / punch_hole path. As such, the caller
 	 * must hold locks protecting against concurrent modifications of the
-	 * radix tree (usually fs-private i_mmap_sem for writing). Since the
+	 * page cache (usually fs-private i_mmap_sem for writing). Since the
 	 * caller has seen a DAX entry for this index, we better find it
 	 * at that index as well...
 	 */
@@ -479,7 +405,7 @@ int dax_delete_mapping_entry(struct address_space *mapping, pgoff_t index)
 int dax_invalidate_mapping_entry_sync(struct address_space *mapping,
 				      pgoff_t index)
 {
-	return __dax_invalidate_mapping_entry(mapping, index, false);
+	return __dax_invalidate_entry(mapping, index, false);
 }
 
 static int copy_user_dax(struct block_device *bdev, struct dax_device *dax_dev,
@@ -516,14 +442,14 @@ static int copy_user_dax(struct block_device *bdev, struct dax_device *dax_dev,
  * already in the tree, we will skip the insertion and just dirty the PMD as
  * appropriate.
  */
-static void *dax_insert_mapping_entry(struct address_space *mapping,
+static void *dax_insert_entry(struct address_space *mapping,
 				      struct vm_fault *vmf,
 				      void *entry, sector_t sector,
 				      unsigned long flags, bool dirty)
 {
-	struct radix_tree_root *pages = &mapping->pages;
 	void *new_entry;
 	pgoff_t index = vmf->pgoff;
+	XA_STATE(xas, &mapping->pages, index);
 
 	if (dirty)
 		__mark_inode_dirty(mapping->host, I_DIRTY_PAGES);
@@ -537,33 +463,27 @@ static void *dax_insert_mapping_entry(struct address_space *mapping,
 			unmap_mapping_pages(mapping, vmf->pgoff, 1, false);
 	}
 
-	xa_lock_irq(&mapping->pages);
-	new_entry = dax_radix_locked_entry(sector, flags);
+	xas_lock_irq(&xas);
+	new_entry = xa_mk_dax_locked(sector, flags);
 
 	if (dax_is_zero_entry(entry) || dax_is_empty_entry(entry)) {
 		/*
-		 * Only swap our new entry into the radix tree if the current
+		 * Only swap our new entry into the page cache if the current
 		 * entry is a zero page or an empty entry.  If a normal PTE or
 		 * PMD entry is already in the tree, we leave it alone.  This
 		 * means that if we are trying to insert a PTE and the
 		 * existing entry is a PMD, we will just leave the PMD in the
 		 * tree and dirty it if necessary.
 		 */
-		struct radix_tree_node *node;
-		void **slot;
-		void *ret;
-
-		ret = __radix_tree_lookup(pages, index, &node, &slot);
-		WARN_ON_ONCE(ret != entry);
-		__radix_tree_replace(pages, node, slot,
-				     new_entry, NULL);
+		void *prev = xas_store(&xas, new_entry);
+		WARN_ON_ONCE(prev != entry);
 		entry = new_entry;
 	}
 
 	if (dirty)
-		radix_tree_tag_set(pages, index, PAGECACHE_TAG_DIRTY);
+		xas_set_tag(&xas, PAGECACHE_TAG_DIRTY);
 
-	xa_unlock_irq(&mapping->pages);
+	xas_unlock_irq(&xas);
 	return entry;
 }
 
@@ -578,7 +498,7 @@ pgoff_address(pgoff_t pgoff, struct vm_area_struct *vma)
 }
 
 /* Walk all mappings of a given index of a file and writeprotect them */
-static void dax_mapping_entry_mkclean(struct address_space *mapping,
+static void dax_entry_mkclean(struct address_space *mapping,
 				      pgoff_t index, unsigned long pfn)
 {
 	struct vm_area_struct *vma;
@@ -653,8 +573,8 @@ static int dax_writeback_one(struct block_device *bdev,
 		struct dax_device *dax_dev, struct address_space *mapping,
 		pgoff_t index, void *entry)
 {
-	struct radix_tree_root *pages = &mapping->pages;
-	void *entry2, **slot, *kaddr;
+	XA_STATE(xas, &mapping->pages, index);
+	void *entry2, *kaddr;
 	long ret = 0, id;
 	sector_t sector;
 	pgoff_t pgoff;
@@ -668,8 +588,8 @@ static int dax_writeback_one(struct block_device *bdev,
 	if (WARN_ON(!xa_is_value(entry)))
 		return -EIO;
 
-	xa_lock_irq(&mapping->pages);
-	entry2 = get_unlocked_mapping_entry(mapping, index, &slot);
+	xas_lock_irq(&xas);
+	entry2 = get_unlocked_entry(&xas);
 	/* Entry got punched out / reallocated? */
 	if (!entry2 || WARN_ON_ONCE(!xa_is_value(entry2)))
 		goto put_unlocked;
@@ -678,7 +598,7 @@ static int dax_writeback_one(struct block_device *bdev,
 	 * compare sectors as we must not bail out due to difference in lockbit
 	 * or entry type.
 	 */
-	if (dax_radix_sector(entry2) != dax_radix_sector(entry))
+	if (xa_to_dax_sector(entry2) != xa_to_dax_sector(entry))
 		goto put_unlocked;
 	if (WARN_ON_ONCE(dax_is_empty_entry(entry) ||
 				dax_is_zero_entry(entry))) {
@@ -687,10 +607,10 @@ static int dax_writeback_one(struct block_device *bdev,
 	}
 
 	/* Another fsync thread may have already written back this entry */
-	if (!radix_tree_tag_get(pages, index, PAGECACHE_TAG_TOWRITE))
+	if (!xas_get_tag(&xas, PAGECACHE_TAG_TOWRITE))
 		goto put_unlocked;
 	/* Lock the entry to serialize with page faults */
-	entry = lock_slot(mapping, slot);
+	entry = lock_entry(&xas);
 	/*
 	 * We can clear the tag now but we have to be careful so that concurrent
 	 * dax_writeback_one() calls for the same index cannot finish before we
@@ -698,8 +618,8 @@ static int dax_writeback_one(struct block_device *bdev,
 	 * at the entry only under xa_lock and once they do that they will
 	 * see the entry locked and wait for it to unlock.
 	 */
-	radix_tree_tag_clear(pages, index, PAGECACHE_TAG_TOWRITE);
-	xa_unlock_irq(&mapping->pages);
+	xas_clear_tag(&xas, PAGECACHE_TAG_TOWRITE);
+	xas_unlock_irq(&xas);
 
 	/*
 	 * Even if dax_writeback_mapping_range() was given a wbc->range_start
@@ -708,8 +628,8 @@ static int dax_writeback_one(struct block_device *bdev,
 	 * 'entry'.  This allows us to flush for PMD_SIZE and not have to
 	 * worry about partial PMD writebacks.
 	 */
-	sector = dax_radix_sector(entry);
-	size = PAGE_SIZE << dax_radix_order(entry);
+	sector = xa_to_dax_sector(entry);
+	size = PAGE_SIZE << dax_entry_order(entry);
 
 	id = dax_read_lock();
 	ret = bdev_dax_pgoff(bdev, sector, size, &pgoff);
@@ -729,7 +649,7 @@ static int dax_writeback_one(struct block_device *bdev,
 		goto dax_unlock;
 	}
 
-	dax_mapping_entry_mkclean(mapping, index, pfn_t_to_pfn(pfn));
+	dax_entry_mkclean(mapping, index, pfn_t_to_pfn(pfn));
 	dax_flush(dax_dev, kaddr, size);
 	/*
 	 * After we have flushed the cache, we can clear the dirty tag. There
@@ -737,18 +657,16 @@ static int dax_writeback_one(struct block_device *bdev,
 	 * the pfn mappings are writeprotected and fault waits for mapping
 	 * entry lock.
 	 */
-	xa_lock_irq(&mapping->pages);
-	radix_tree_tag_clear(pages, index, PAGECACHE_TAG_DIRTY);
-	xa_unlock_irq(&mapping->pages);
+	xa_clear_tag(&mapping->pages, index, PAGECACHE_TAG_DIRTY);
 	trace_dax_writeback_one(mapping->host, index, size >> PAGE_SHIFT);
  dax_unlock:
 	dax_read_unlock(id);
-	put_locked_mapping_entry(mapping, index);
+	put_locked_entry(&xas, entry2);
 	return ret;
 
  put_unlocked:
-	put_unlocked_mapping_entry(mapping, index, entry2);
-	xa_unlock_irq(&mapping->pages);
+	put_unlocked_entry(&xas, entry2);
+	xas_unlock_irq(&xas);
 	return ret;
 }
 
@@ -876,7 +794,7 @@ static int dax_load_hole(struct address_space *mapping, void *entry,
 		goto out;
 	}
 
-	entry2 = dax_insert_mapping_entry(mapping, vmf, entry, 0,
+	entry2 = dax_insert_entry(mapping, vmf, entry, 0,
 			DAX_ZERO_PAGE, false);
 	if (IS_ERR(entry2)) {
 		ret = VM_FAULT_SIGBUS;
@@ -1192,7 +1110,7 @@ static int dax_iomap_pte_fault(struct vm_fault *vmf, pfn_t *pfnp,
 		if (error < 0)
 			goto error_finish_iomap;
 
-		entry = dax_insert_mapping_entry(mapping, vmf, entry,
+		entry = dax_insert_entry(mapping, vmf, entry,
 						 dax_iomap_sector(&iomap, pos),
 						 0, write && !sync);
 		if (IS_ERR(entry)) {
@@ -1255,7 +1173,7 @@ static int dax_iomap_pte_fault(struct vm_fault *vmf, pfn_t *pfnp,
 		ops->iomap_end(inode, pos, PAGE_SIZE, copied, flags, &iomap);
 	}
  unlock_entry:
-	put_locked_mapping_entry(mapping, vmf->pgoff);
+	dax_unlock_entry(mapping, vmf->pgoff);
  out:
 	trace_dax_pte_fault_done(inode, vmf, vmf_ret);
 	return vmf_ret;
@@ -1278,7 +1196,7 @@ static int dax_pmd_load_hole(struct vm_fault *vmf, struct iomap *iomap,
 	if (unlikely(!zero_page))
 		goto fallback;
 
-	ret = dax_insert_mapping_entry(mapping, vmf, entry, 0,
+	ret = dax_insert_entry(mapping, vmf, entry, 0,
 			DAX_PMD | DAX_ZERO_PAGE, false);
 	if (IS_ERR(ret))
 		goto fallback;
@@ -1333,7 +1251,7 @@ static int dax_iomap_pmd_fault(struct vm_fault *vmf, pfn_t *pfnp,
 	 * Make sure that the faulting address's PMD offset (color) matches
 	 * the PMD offset from the start of the file.  This is necessary so
 	 * that a PMD range in the page table overlaps exactly with a PMD
-	 * range in the radix tree.
+	 * range in the page cache.
 	 */
 	if ((vmf->pgoff & PG_PMD_COLOUR) !=
 	    ((vmf->address >> PAGE_SHIFT) & PG_PMD_COLOUR))
@@ -1401,7 +1319,7 @@ static int dax_iomap_pmd_fault(struct vm_fault *vmf, pfn_t *pfnp,
 		if (error < 0)
 			goto finish_iomap;
 
-		entry = dax_insert_mapping_entry(mapping, vmf, entry,
+		entry = dax_insert_entry(mapping, vmf, entry,
 						dax_iomap_sector(&iomap, pos),
 						DAX_PMD, write && !sync);
 		if (IS_ERR(entry))
@@ -1452,7 +1370,7 @@ static int dax_iomap_pmd_fault(struct vm_fault *vmf, pfn_t *pfnp,
 				&iomap);
 	}
  unlock_entry:
-	put_locked_mapping_entry(mapping, pgoff);
+	dax_unlock_entry(mapping, pgoff);
  fallback:
 	if (result == VM_FAULT_FALLBACK) {
 		split_huge_pmd(vma, vmf->pmd, vmf->address);
@@ -1503,34 +1421,34 @@ EXPORT_SYMBOL_GPL(dax_iomap_fault);
  * @pe_size: Size of entry to be inserted
  * @pfn: PFN to insert
  *
- * This function inserts writeable PTE or PMD entry into page tables for mmaped
- * DAX file.  It takes care of marking corresponding radix tree entry as dirty
- * as well.
+ * This function inserts a writeable PTE or PMD entry into the page tables
+ * for an mmaped DAX file.  It also marks the page cache entry as dirty.
  */
 static int dax_insert_pfn_mkwrite(struct vm_fault *vmf,
 				  enum page_entry_size pe_size,
 				  pfn_t pfn)
 {
 	struct address_space *mapping = vmf->vma->vm_file->f_mapping;
-	void *entry, **slot;
 	pgoff_t index = vmf->pgoff;
+	XA_STATE(xas, &mapping->pages, index);
+	void *entry;
 	int vmf_ret, error;
 
-	xa_lock_irq(&mapping->pages);
-	entry = get_unlocked_mapping_entry(mapping, index, &slot);
+	xas_lock_irq(&xas);
+	entry = get_unlocked_entry(&xas);
 	/* Did we race with someone splitting entry or so? */
 	if (!entry ||
 	    (pe_size == PE_SIZE_PTE && !dax_is_pte_entry(entry)) ||
 	    (pe_size == PE_SIZE_PMD && !dax_is_pmd_entry(entry))) {
-		put_unlocked_mapping_entry(mapping, index, entry);
-		xa_unlock_irq(&mapping->pages);
+		put_unlocked_entry(&xas, entry);
+		xas_unlock_irq(&xas);
 		trace_dax_insert_pfn_mkwrite_no_entry(mapping->host, vmf,
 						      VM_FAULT_NOPAGE);
 		return VM_FAULT_NOPAGE;
 	}
-	radix_tree_tag_set(&mapping->pages, index, PAGECACHE_TAG_DIRTY);
-	entry = lock_slot(mapping, slot);
-	xa_unlock_irq(&mapping->pages);
+	xas_set_tag(&xas, PAGECACHE_TAG_DIRTY);
+	entry = lock_entry(&xas);
+	xas_unlock_irq(&xas);
 	switch (pe_size) {
 	case PE_SIZE_PTE:
 		error = vm_insert_mixed_mkwrite(vmf->vma, vmf->address, pfn);
@@ -1545,7 +1463,7 @@ static int dax_insert_pfn_mkwrite(struct vm_fault *vmf,
 	default:
 		vmf_ret = VM_FAULT_FALLBACK;
 	}
-	put_locked_mapping_entry(mapping, index);
+	put_locked_entry(&xas, entry);
 	trace_dax_insert_pfn_mkwrite(mapping->host, vmf, vmf_ret);
 	return vmf_ret;
 }
-- 
2.16.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
