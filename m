Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8C7C06B0297
	for <linux-mm@kvack.org>; Sat, 16 Jun 2018 22:01:40 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id y8-v6so6641075pfl.17
        for <linux-mm@kvack.org>; Sat, 16 Jun 2018 19:01:40 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id l63-v6si11542863plb.106.2018.06.16.19.01.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 16 Jun 2018 19:01:38 -0700 (PDT)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v14 69/74] dax: Convert page fault handlers to XArray
Date: Sat, 16 Jun 2018 19:00:47 -0700
Message-Id: <20180617020052.4759-70-willy@infradead.org>
In-Reply-To: <20180617020052.4759-1-willy@infradead.org>
References: <20180617020052.4759-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <willy@infradead.org>, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@redhat.com>, Lukas Czerner <lczerner@redhat.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@lst.de>, Goldwyn Rodrigues <rgoldwyn@suse.com>, Nicholas Piggin <npiggin@gmail.com>, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>, linux-nilfs@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, Chao Yu <yuchao0@huawei.com>, linux-f2fs-devel@lists.sourceforge.net

This is the last part of DAX to be converted to the XArray so
remove all the old helper functions.

Signed-off-by: Matthew Wilcox <willy@infradead.org>
---
 fs/dax.c | 392 ++++++++++++++++---------------------------------------
 1 file changed, 111 insertions(+), 281 deletions(-)

diff --git a/fs/dax.c b/fs/dax.c
index 54a01380527a..91f7bce6ce64 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -93,12 +93,6 @@ static unsigned long dax_to_pfn(void *entry)
 	return xa_to_value(entry) >> DAX_SHIFT;
 }
 
-static void *dax_make_locked(unsigned long pfn, unsigned long flags)
-{
-	return xa_mk_value(flags | ((unsigned long)pfn << DAX_SHIFT) |
-			DAX_LOCKED);
-}
-
 static unsigned long dax_is_pmd_entry(void *entry)
 {
 	return xa_to_value(entry) & DAX_PMD;
@@ -155,10 +149,11 @@ struct wait_exceptional_entry_queue {
 	struct exceptional_entry_key key;
 };
 
-static wait_queue_head_t *dax_entry_waitqueue(struct xarray *xa,
-		pgoff_t index, void *entry, struct exceptional_entry_key *key)
+static wait_queue_head_t *dax_entry_waitqueue(struct xa_state *xas,
+		void *entry, struct exceptional_entry_key *key)
 {
 	unsigned long hash;
+	unsigned long index = xas->xa_index;
 
 	/*
 	 * If 'entry' is a PMD, align the 'index' that we use for the wait
@@ -167,11 +162,10 @@ static wait_queue_head_t *dax_entry_waitqueue(struct xarray *xa,
 	 */
 	if (dax_is_pmd_entry(entry))
 		index &= ~PG_PMD_COLOUR;
-
-	key->xa = xa;
+	key->xa = xas->xa;
 	key->entry_start = index;
 
-	hash = hash_long((unsigned long)xa ^ index, DAX_WAIT_TABLE_BITS);
+	hash = hash_long((unsigned long)xas->xa ^ index, DAX_WAIT_TABLE_BITS);
 	return wait_table + hash;
 }
 
@@ -193,13 +187,12 @@ static int wake_exceptional_entry_func(wait_queue_entry_t *wait,
  * The important information it's conveying is whether the entry at
  * this index used to be a PMD entry.
  */
-static void dax_wake_mapping_entry_waiter(struct xarray *xa,
-		pgoff_t index, void *entry, bool wake_all)
+static void dax_wake_entry(struct xa_state *xas, void *entry, bool wake_all)
 {
 	struct exceptional_entry_key key;
 	wait_queue_head_t *wq;
 
-	wq = dax_entry_waitqueue(xa, index, entry, &key);
+	wq = dax_entry_waitqueue(xas, entry, &key);
 
 	/*
 	 * Checking for locked entry and prepare_to_wait_exclusive() happens
@@ -211,12 +204,6 @@ static void dax_wake_mapping_entry_waiter(struct xarray *xa,
 		__wake_up(wq, TASK_NORMAL, wake_all ? 0 : 1, &key);
 }
 
-static void dax_wake_entry(struct xa_state *xas, void *entry, bool wake_all)
-{
-	return dax_wake_mapping_entry_waiter(xas->xa, xas->xa_index, entry,
-								wake_all);
-}
-
 /*
  * Look up entry in page cache, wait for it to become unlocked if it
  * is a DAX entry and return it.  The caller must subsequently call
@@ -240,8 +227,7 @@ static void *get_unlocked_entry(struct xa_state *xas)
 				!dax_is_locked(entry))
 			return entry;
 
-		wq = dax_entry_waitqueue(xas->xa, xas->xa_index, entry,
-				&ewait.key);
+		wq = dax_entry_waitqueue(xas, entry, &ewait.key);
 		prepare_to_wait_exclusive(wq, &ewait.wait,
 					  TASK_UNINTERRUPTIBLE);
 		xas_unlock_irq(xas);
@@ -282,119 +268,6 @@ static void dax_lock_entry(struct xa_state *xas, void *entry)
 	xas_store(xas, xa_mk_value(v | DAX_LOCKED));
 }
 
-/*
- * Check whether the given slot is locked.  Must be called with the i_pages
- * lock held.
- */
-static inline int slot_locked(struct address_space *mapping, void **slot)
-{
-	unsigned long entry = xa_to_value(
-		radix_tree_deref_slot_protected(slot, &mapping->i_pages.xa_lock));
-	return entry & DAX_LOCKED;
-}
-
-/*
- * Mark the given slot as locked.  Must be called with the i_pages lock held.
- */
-static inline void *lock_slot(struct address_space *mapping, void **slot)
-{
-	unsigned long v = xa_to_value(
-		radix_tree_deref_slot_protected(slot, &mapping->i_pages.xa_lock));
-	void *entry = xa_mk_value(v | DAX_LOCKED);
-	radix_tree_replace_slot(&mapping->i_pages, slot, entry);
-	return entry;
-}
-
-/*
- * Mark the given slot as unlocked.  Must be called with the i_pages lock held.
- */
-static inline void *unlock_slot(struct address_space *mapping, void **slot)
-{
-	unsigned long v = xa_to_value(
-		radix_tree_deref_slot_protected(slot, &mapping->i_pages.xa_lock));
-	void *entry = xa_mk_value(v & ~DAX_LOCKED);
-	radix_tree_replace_slot(&mapping->i_pages, slot, entry);
-	return entry;
-}
-
-/*
- * Lookup entry in page cache, wait for it to become unlocked if it is
- * a DAX entry and return it. The caller must call
- * put_unlocked_mapping_entry() when he decided not to lock the entry or
- * put_locked_mapping_entry() when he locked the entry and now wants to
- * unlock it.
- *
- * Must be called with the i_pages lock held.
- */
-static void *get_unlocked_mapping_entry(struct address_space *mapping,
-					pgoff_t index, void ***slotp)
-{
-	void *entry, **slot;
-	struct wait_exceptional_entry_queue ewait;
-	wait_queue_head_t *wq;
-
-	init_wait(&ewait.wait);
-	ewait.wait.func = wake_exceptional_entry_func;
-
-	for (;;) {
-		entry = __radix_tree_lookup(&mapping->i_pages, index, NULL,
-					  &slot);
-		if (!entry ||
-		    WARN_ON_ONCE(!xa_is_value(entry)) ||
-		    !slot_locked(mapping, slot)) {
-			if (slotp)
-				*slotp = slot;
-			return entry;
-		}
-
-		wq = dax_entry_waitqueue(&mapping->i_pages, index, entry,
-				&ewait.key);
-		prepare_to_wait_exclusive(wq, &ewait.wait,
-					  TASK_UNINTERRUPTIBLE);
-		xa_unlock_irq(&mapping->i_pages);
-		schedule();
-		finish_wait(wq, &ewait.wait);
-		xa_lock_irq(&mapping->i_pages);
-	}
-}
-
-static void dax_unlock_mapping_entry(struct address_space *mapping,
-				     pgoff_t index)
-{
-	void *entry, **slot;
-
-	xa_lock_irq(&mapping->i_pages);
-	entry = __radix_tree_lookup(&mapping->i_pages, index, NULL, &slot);
-	if (WARN_ON_ONCE(!entry || !xa_is_value(entry) ||
-			 !slot_locked(mapping, slot))) {
-		xa_unlock_irq(&mapping->i_pages);
-		return;
-	}
-	unlock_slot(mapping, slot);
-	xa_unlock_irq(&mapping->i_pages);
-	dax_wake_mapping_entry_waiter(&mapping->i_pages, index, entry, false);
-}
-
-static void put_locked_mapping_entry(struct address_space *mapping,
-		pgoff_t index)
-{
-	dax_unlock_mapping_entry(mapping, index);
-}
-
-/*
- * Called when we are done with page cache entry we looked up via
- * get_unlocked_mapping_entry() and which we didn't lock in the end.
- */
-static void put_unlocked_mapping_entry(struct address_space *mapping,
-				       pgoff_t index, void *entry)
-{
-	if (!entry)
-		return;
-
-	/* We have to wake up next waiter for the page cache entry lock */
-	dax_wake_mapping_entry_waiter(&mapping->i_pages, index, entry, false);
-}
-
 static unsigned long dax_entry_size(void *entry)
 {
 	if (dax_is_zero_entry(entry))
@@ -550,9 +423,9 @@ void dax_unlock_page(struct page *page)
  * that index, add a locked empty entry.
  *
  * When requesting an entry with size DAX_PMD, grab_mapping_entry() will
- * either return that locked entry or will return an error.  This error will
- * happen if there are any 4k entries within the 2MiB range that we are
- * requesting.
+ * either return that locked entry or will return VM_FAULT_FALLBACK.
+ * This will happen if there are any 4k entries within the 2MiB range
+ * that we are requesting.
  *
  * We always favor 4k entries over 2MiB entries. There isn't a flow where we
  * evict 4k entries in order to 'upgrade' them to a 2MiB entry.  A 2MiB
@@ -568,29 +441,31 @@ void dax_unlock_page(struct page *page)
  * Note: Unlike filemap_fault() we don't honor FAULT_FLAG_RETRY flags. For
  * persistent memory the benefit is doubtful. We can add that later if we can
  * show it helps.
+ *
+ * On error, this function does not return an ERR_PTR.  Instead it returns
+ * a VM_FAULT code, encoded as an xarray internal entry.  The ERR_PTR values
+ * overlap with xarray value entries.
  */
-static void *grab_mapping_entry(struct address_space *mapping, pgoff_t index,
-		unsigned long size_flag)
+static
+void *grab_mapping_entry(struct xa_state *xas, struct address_space *mapping)
 {
 	bool pmd_downgrade = false; /* splitting 2MiB entry into 4k entries? */
-	void *entry, **slot;
-
-restart:
-	xa_lock_irq(&mapping->i_pages);
-	entry = get_unlocked_mapping_entry(mapping, index, &slot);
-
-	if (WARN_ON_ONCE(entry && !xa_is_value(entry))) {
-		entry = ERR_PTR(-EIO);
-		goto out_unlock;
-	}
+	void *locked = dax_make_entry(pfn_to_pfn_t(0),
+						DAX_EMPTY | DAX_LOCKED);
+	void *unlocked = dax_make_entry(pfn_to_pfn_t(0), DAX_EMPTY);
+	void *entry;
 
-	if (entry) {
-		if (size_flag & DAX_PMD) {
+retry:
+	xas_lock_irq(xas);
+	xas_for_each_conflict(xas, entry) {
+		if (dax_is_locked(entry))
+			entry = get_unlocked_entry(xas);
+		if (!xa_is_value(entry))
+			goto error;
+		if (xas->xa_shift) {
 			if (dax_is_pte_entry(entry)) {
-				put_unlocked_mapping_entry(mapping, index,
-						entry);
-				entry = ERR_PTR(-EEXIST);
-				goto out_unlock;
+				put_unlocked_entry(xas, entry);
+				goto fallback;
 			}
 		} else { /* trying to grab a PTE entry */
 			if (dax_is_pmd_entry(entry) &&
@@ -599,89 +474,56 @@ static void *grab_mapping_entry(struct address_space *mapping, pgoff_t index,
 				pmd_downgrade = true;
 			}
 		}
+		dax_lock_entry(xas, entry);
+		break;	/* We don't want to overwrite an existing entry */
 	}
 
-	/* No entry for given index? Make sure radix tree is big enough. */
-	if (!entry || pmd_downgrade) {
-		int err;
-
-		if (pmd_downgrade) {
-			/*
-			 * Make sure 'entry' remains valid while we drop
-			 * the i_pages lock.
-			 */
-			entry = lock_slot(mapping, slot);
-		}
+	if (!entry) {
+		xas_store(xas, locked);
+		if (xas_error(xas))
+			goto error;
+		entry = unlocked;
+		mapping->nrexceptional++;
+	}
 
-		xa_unlock_irq(&mapping->i_pages);
+	if (pmd_downgrade) {
 		/*
 		 * Besides huge zero pages the only other thing that gets
 		 * downgraded are empty entries which don't need to be
 		 * unmapped.
 		 */
-		if (pmd_downgrade && dax_is_zero_entry(entry))
-			unmap_mapping_pages(mapping, index & ~PG_PMD_COLOUR,
+		if (dax_is_zero_entry(entry)) {
+			xas_unlock_irq(xas);
+			unmap_mapping_pages(mapping, xas->xa_index,
 							PG_PMD_NR, false);
-
-		err = radix_tree_preload(
-				mapping_gfp_mask(mapping) & ~__GFP_HIGHMEM);
-		if (err) {
-			if (pmd_downgrade)
-				put_locked_mapping_entry(mapping, index);
-			return ERR_PTR(err);
-		}
-		xa_lock_irq(&mapping->i_pages);
-
-		if (!entry) {
-			/*
-			 * We needed to drop the i_pages lock while calling
-			 * radix_tree_preload() and we didn't have an entry to
-			 * lock.  See if another thread inserted an entry at
-			 * our index during this time.
-			 */
-			entry = __radix_tree_lookup(&mapping->i_pages, index,
-					NULL, &slot);
-			if (entry) {
-				radix_tree_preload_end();
-				xa_unlock_irq(&mapping->i_pages);
-				goto restart;
-			}
+			xas_reset(xas);
+			xas_lock_irq(xas);
 		}
 
-		if (pmd_downgrade) {
-			dax_disassociate_entry(entry, mapping, false);
-			radix_tree_delete(&mapping->i_pages, index);
+		dax_disassociate_entry(entry, mapping, false);
+		xas_store(xas, NULL);	/* undo the PMD join */
+		xas_store(xas, locked);	/* may fail with ENOMEM */
+		dax_wake_entry(xas, entry, true);
+		if (xas_error(xas)) {
 			mapping->nrexceptional--;
-			dax_wake_mapping_entry_waiter(&mapping->i_pages,
-					index, entry, true);
+			goto error;
 		}
-
-		entry = dax_make_locked(0, size_flag | DAX_EMPTY);
-
-		err = __radix_tree_insert(&mapping->i_pages, index,
-				dax_entry_order(entry), entry);
-		radix_tree_preload_end();
-		if (err) {
-			xa_unlock_irq(&mapping->i_pages);
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
-		xa_unlock_irq(&mapping->i_pages);
-		return entry;
+		entry = unlocked;
 	}
-	entry = lock_slot(mapping, slot);
- out_unlock:
-	xa_unlock_irq(&mapping->i_pages);
+
+	xas_unlock_irq(xas);
 	return entry;
+
+fallback:
+	xas_unlock_irq(xas);
+	return xa_mk_internal(VM_FAULT_FALLBACK);
+error:
+	xas_unlock_irq(xas);
+	if (xas_nomem(xas, GFP_NOIO))
+		goto retry;
+	if (xas->xa_node == XA_ERROR(-ENOMEM))
+		return xa_mk_internal(VM_FAULT_OOM);
+	return xa_mk_internal(VM_FAULT_SIGBUS);
 }
 
 /**
@@ -840,29 +682,25 @@ static int copy_user_dax(struct block_device *bdev, struct dax_device *dax_dev,
  * already in the tree, we will skip the insertion and just dirty the PMD as
  * appropriate.
  */
-static void *dax_insert_entry(struct address_space *mapping,
-		struct vm_fault *vmf,
+static void *dax_insert_entry(struct xa_state *xas,
+		struct address_space *mapping, struct vm_fault *vmf,
 		void *entry, pfn_t pfn_t, unsigned long flags, bool dirty)
 {
-	struct radix_tree_root *pages = &mapping->i_pages;
-	unsigned long pfn = pfn_t_to_pfn(pfn_t);
-	pgoff_t index = vmf->pgoff;
-	void *new_entry;
-
+	void *new_entry = dax_make_entry(pfn_t, flags);
 	if (dirty)
 		__mark_inode_dirty(mapping->host, I_DIRTY_PAGES);
 
 	if (dax_is_zero_entry(entry) && !(flags & DAX_ZERO_PAGE)) {
+		unsigned long index = xas->xa_index;
 		/* we are replacing a zero page with block mapping */
 		if (dax_is_pmd_entry(entry))
-			unmap_mapping_pages(mapping, index & ~PG_PMD_COLOUR,
-							PG_PMD_NR, false);
+			unmap_mapping_pages(mapping, index, PG_PMD_NR, false);
 		else /* pte entry */
-			unmap_mapping_pages(mapping, vmf->pgoff, 1, false);
+			unmap_mapping_pages(mapping, index, 1, false);
 	}
 
-	xa_lock_irq(pages);
-	new_entry = dax_make_locked(pfn, flags);
+	xas_reset(xas);
+	xas_lock_irq(xas);
 	if (dax_entry_size(entry) != dax_entry_size(new_entry)) {
 		dax_disassociate_entry(entry, mapping, false);
 		dax_associate_entry(new_entry, mapping, vmf->vma, vmf->address);
@@ -877,21 +715,16 @@ static void *dax_insert_entry(struct address_space *mapping,
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
+		dax_lock_entry(xas, new_entry);
 		entry = new_entry;
 	}
 
-	if (dirty)
-		radix_tree_tag_set(pages, index, PAGECACHE_TAG_DIRTY);
+	if (dirty) {
+		xas_load(xas);	/* Walk the xa_state */
+		xas_set_tag(xas, PAGECACHE_TAG_DIRTY);
+	}
 
-	xa_unlock_irq(pages);
+	xas_unlock_irq(xas);
 	return entry;
 }
 
@@ -1160,15 +993,16 @@ static int dax_iomap_pfn(struct iomap *iomap, loff_t pos, size_t size,
  * If this page is ever written to we will re-fault and change the mapping to
  * point to real DAX storage instead.
  */
-static vm_fault_t dax_load_hole(struct address_space *mapping, void *entry,
-			 struct vm_fault *vmf)
+static vm_fault_t dax_load_hole(struct xa_state *xas,
+		struct address_space *mapping, void **entry,
+		struct vm_fault *vmf)
 {
 	struct inode *inode = mapping->host;
 	unsigned long vaddr = vmf->address;
 	pfn_t pfn = pfn_to_pfn_t(my_zero_pfn(vaddr));
 	vm_fault_t ret;
 
-	dax_insert_entry(mapping, vmf, entry, pfn,
+	*entry = dax_insert_entry(xas, mapping, vmf, *entry, pfn,
 			DAX_ZERO_PAGE, false);
 
 	ret = vmf_insert_mixed(vmf->vma, vaddr, pfn);
@@ -1381,6 +1215,7 @@ static vm_fault_t dax_iomap_pte_fault(struct vm_fault *vmf, pfn_t *pfnp,
 {
 	struct vm_area_struct *vma = vmf->vma;
 	struct address_space *mapping = vma->vm_file->f_mapping;
+	XA_STATE(xas, &mapping->i_pages, vmf->pgoff);
 	struct inode *inode = mapping->host;
 	unsigned long vaddr = vmf->address;
 	loff_t pos = (loff_t)vmf->pgoff << PAGE_SHIFT;
@@ -1407,9 +1242,9 @@ static vm_fault_t dax_iomap_pte_fault(struct vm_fault *vmf, pfn_t *pfnp,
 	if (write && !vmf->cow_page)
 		flags |= IOMAP_WRITE;
 
-	entry = grab_mapping_entry(mapping, vmf->pgoff, 0);
-	if (IS_ERR(entry)) {
-		ret = dax_fault_return(PTR_ERR(entry));
+	entry = grab_mapping_entry(&xas, mapping);
+	if (xa_is_internal(entry)) {
+		ret = xa_to_internal(entry);
 		goto out;
 	}
 
@@ -1482,7 +1317,7 @@ static vm_fault_t dax_iomap_pte_fault(struct vm_fault *vmf, pfn_t *pfnp,
 		if (error < 0)
 			goto error_finish_iomap;
 
-		entry = dax_insert_entry(mapping, vmf, entry, pfn,
+		entry = dax_insert_entry(&xas, mapping, vmf, entry, pfn,
 						 0, write && !sync);
 
 		/*
@@ -1510,7 +1345,7 @@ static vm_fault_t dax_iomap_pte_fault(struct vm_fault *vmf, pfn_t *pfnp,
 	case IOMAP_UNWRITTEN:
 	case IOMAP_HOLE:
 		if (!write) {
-			ret = dax_load_hole(mapping, entry, vmf);
+			ret = dax_load_hole(&xas, mapping, &entry, vmf);
 			goto finish_iomap;
 		}
 		/*FALLTHRU*/
@@ -1537,21 +1372,20 @@ static vm_fault_t dax_iomap_pte_fault(struct vm_fault *vmf, pfn_t *pfnp,
 		ops->iomap_end(inode, pos, PAGE_SIZE, copied, flags, &iomap);
 	}
  unlock_entry:
-	put_locked_mapping_entry(mapping, vmf->pgoff);
+	put_locked_entry(&xas, entry);
  out:
 	trace_dax_pte_fault_done(inode, vmf, ret);
 	return ret | major;
 }
 
 #ifdef CONFIG_FS_DAX_PMD
-static vm_fault_t dax_pmd_load_hole(struct vm_fault *vmf, struct iomap *iomap,
-		void *entry)
+static vm_fault_t dax_pmd_load_hole(struct xa_state *xas, struct vm_fault *vmf,
+		struct iomap *iomap, void **entry)
 {
 	struct address_space *mapping = vmf->vma->vm_file->f_mapping;
 	unsigned long pmd_addr = vmf->address & PMD_MASK;
 	struct inode *inode = mapping->host;
 	struct page *zero_page;
-	void *ret = NULL;
 	spinlock_t *ptl;
 	pmd_t pmd_entry;
 	pfn_t pfn;
@@ -1562,7 +1396,7 @@ static vm_fault_t dax_pmd_load_hole(struct vm_fault *vmf, struct iomap *iomap,
 		goto fallback;
 
 	pfn = page_to_pfn_t(zero_page);
-	ret = dax_insert_entry(mapping, vmf, entry, pfn,
+	*entry = dax_insert_entry(xas, mapping, vmf, *entry, pfn,
 			DAX_PMD | DAX_ZERO_PAGE, false);
 
 	ptl = pmd_lock(vmf->vma->vm_mm, vmf->pmd);
@@ -1575,11 +1409,11 @@ static vm_fault_t dax_pmd_load_hole(struct vm_fault *vmf, struct iomap *iomap,
 	pmd_entry = pmd_mkhuge(pmd_entry);
 	set_pmd_at(vmf->vma->vm_mm, pmd_addr, vmf->pmd, pmd_entry);
 	spin_unlock(ptl);
-	trace_dax_pmd_load_hole(inode, vmf, zero_page, ret);
+	trace_dax_pmd_load_hole(inode, vmf, zero_page, *entry);
 	return VM_FAULT_NOPAGE;
 
 fallback:
-	trace_dax_pmd_load_hole_fallback(inode, vmf, zero_page, ret);
+	trace_dax_pmd_load_hole_fallback(inode, vmf, zero_page, *entry);
 	return VM_FAULT_FALLBACK;
 }
 
@@ -1588,6 +1422,7 @@ static vm_fault_t dax_iomap_pmd_fault(struct vm_fault *vmf, pfn_t *pfnp,
 {
 	struct vm_area_struct *vma = vmf->vma;
 	struct address_space *mapping = vma->vm_file->f_mapping;
+	XA_STATE_ORDER(xas, &mapping->i_pages, vmf->pgoff, PMD_ORDER);
 	unsigned long pmd_addr = vmf->address & PMD_MASK;
 	bool write = vmf->flags & FAULT_FLAG_WRITE;
 	bool sync;
@@ -1595,7 +1430,7 @@ static vm_fault_t dax_iomap_pmd_fault(struct vm_fault *vmf, pfn_t *pfnp,
 	struct inode *inode = mapping->host;
 	vm_fault_t result = VM_FAULT_FALLBACK;
 	struct iomap iomap = { 0 };
-	pgoff_t max_pgoff, pgoff;
+	pgoff_t max_pgoff;
 	void *entry;
 	loff_t pos;
 	int error;
@@ -1606,7 +1441,6 @@ static vm_fault_t dax_iomap_pmd_fault(struct vm_fault *vmf, pfn_t *pfnp,
 	 * supposed to hold locks serializing us with truncate / punch hole so
 	 * this is a reliable test.
 	 */
-	pgoff = linear_page_index(vma, pmd_addr);
 	max_pgoff = DIV_ROUND_UP(i_size_read(inode), PAGE_SIZE);
 
 	trace_dax_pmd_fault(inode, vmf, max_pgoff, 0);
@@ -1631,24 +1465,21 @@ static vm_fault_t dax_iomap_pmd_fault(struct vm_fault *vmf, pfn_t *pfnp,
 	if ((pmd_addr + PMD_SIZE) > vma->vm_end)
 		goto fallback;
 
-	if (pgoff >= max_pgoff) {
-		result = VM_FAULT_SIGBUS;
-		goto out;
-	}
-
 	/* If the PMD would extend beyond the file size */
-	if ((pgoff | PG_PMD_COLOUR) >= max_pgoff)
+	if ((xas.xa_index | PG_PMD_COLOUR) >= max_pgoff)
 		goto fallback;
 
 	/*
-	 * grab_mapping_entry() will make sure we get a 2MiB empty entry, a
-	 * 2MiB zero page entry or a DAX PMD.  If it can't (because a 4k page
-	 * is already in the tree, for instance), it will return -EEXIST and
-	 * we just fall back to 4k entries.
+	 * grab_mapping_entry() will make sure we get a 2MiB empty entry,
+	 * a 2MiB zero page entry or a DAX PMD.  If it can't (because a 4k
+	 * page is already in the tree, for instance), it will return
+	 * VM_FAULT_FALLBACK.
 	 */
-	entry = grab_mapping_entry(mapping, pgoff, DAX_PMD);
-	if (IS_ERR(entry))
+	entry = grab_mapping_entry(&xas, mapping);
+	if (xa_is_internal(entry)) {
+		result = xa_to_internal(entry);
 		goto fallback;
+	}
 
 	/*
 	 * It is possible, particularly with mixed reads & writes to private
@@ -1667,7 +1498,7 @@ static vm_fault_t dax_iomap_pmd_fault(struct vm_fault *vmf, pfn_t *pfnp,
 	 * setting up a mapping, so really we're using iomap_begin() as a way
 	 * to look up our filesystem block.
 	 */
-	pos = (loff_t)pgoff << PAGE_SHIFT;
+	pos = (loff_t)xas.xa_index << PAGE_SHIFT;
 	error = ops->iomap_begin(inode, pos, PMD_SIZE, iomap_flags, &iomap);
 	if (error)
 		goto unlock_entry;
@@ -1683,7 +1514,7 @@ static vm_fault_t dax_iomap_pmd_fault(struct vm_fault *vmf, pfn_t *pfnp,
 		if (error < 0)
 			goto finish_iomap;
 
-		entry = dax_insert_entry(mapping, vmf, entry, pfn,
+		entry = dax_insert_entry(&xas, mapping, vmf, entry, pfn,
 						DAX_PMD, write && !sync);
 
 		/*
@@ -1708,7 +1539,7 @@ static vm_fault_t dax_iomap_pmd_fault(struct vm_fault *vmf, pfn_t *pfnp,
 	case IOMAP_HOLE:
 		if (WARN_ON_ONCE(write))
 			break;
-		result = dax_pmd_load_hole(vmf, &iomap, entry);
+		result = dax_pmd_load_hole(&xas, vmf, &iomap, &entry);
 		break;
 	default:
 		WARN_ON_ONCE(1);
@@ -1731,13 +1562,12 @@ static vm_fault_t dax_iomap_pmd_fault(struct vm_fault *vmf, pfn_t *pfnp,
 				&iomap);
 	}
  unlock_entry:
-	put_locked_mapping_entry(mapping, pgoff);
+	put_locked_entry(&xas, entry);
  fallback:
 	if (result == VM_FAULT_FALLBACK) {
 		split_huge_pmd(vma, vmf->pmd, vmf->address);
 		count_vm_event(THP_FAULT_FALLBACK);
 	}
-out:
 	trace_dax_pmd_fault_done(inode, vmf, max_pgoff, result);
 	return result;
 }
-- 
2.17.1
