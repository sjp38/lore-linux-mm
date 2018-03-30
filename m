Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id AFD5E6B0062
	for <linux-mm@kvack.org>; Thu, 29 Mar 2018 23:43:01 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id u188so6239257pfb.6
        for <linux-mm@kvack.org>; Thu, 29 Mar 2018 20:43:01 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id b59-v6si7329948plb.530.2018.03.29.20.42.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 29 Mar 2018 20:42:59 -0700 (PDT)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v10 60/62] dax: Convert page fault handlers to XArray
Date: Thu, 29 Mar 2018 20:42:43 -0700
Message-Id: <20180330034245.10462-61-willy@infradead.org>
In-Reply-To: <20180330034245.10462-1-willy@infradead.org>
References: <20180330034245.10462-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@redhat.com>, Lukas Czerner <lczerner@redhat.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@lst.de>, Goldwyn Rodrigues <rgoldwyn@suse.com>, Nicholas Piggin <npiggin@gmail.com>, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>, linux-nilfs@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, Chao Yu <yuchao0@huawei.com>, linux-f2fs-devel@lists.sourceforge.net, Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Mike Kravetz <mike.kravetz@oracle.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

This is the last part of DAX to be converted to the XArray so
remove all the old helper functions.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 fs/dax.c | 368 ++++++++++++++++-----------------------------------------------
 1 file changed, 92 insertions(+), 276 deletions(-)

diff --git a/fs/dax.c b/fs/dax.c
index 3de12a065e05..f05e819dd69f 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -93,10 +93,9 @@ static unsigned long dax_to_pfn(void *entry)
 	return xa_to_value(entry) >> DAX_SHIFT;
 }
 
-static void *dax_mk_locked(unsigned long pfn, unsigned long flags)
+static void *dax_mk_entry(pfn_t pfn, unsigned long flags)
 {
-	return xa_mk_value(flags | ((unsigned long)pfn << DAX_SHIFT) |
-			DAX_ENTRY_LOCK);
+	return xa_mk_value(flags | (pfn_t_to_pfn(pfn) << DAX_SHIFT));
 }
 
 static bool dax_is_locked(void *entry)
@@ -144,23 +143,16 @@ struct wait_exceptional_entry_queue {
 	struct exceptional_entry_key key;
 };
 
-static wait_queue_head_t *dax_entry_waitqueue(struct xarray *xa,
-		pgoff_t index, void *entry, struct exceptional_entry_key *key)
+static wait_queue_head_t *dax_entry_waitqueue(struct xa_state *xas,
+		struct exceptional_entry_key *key)
 {
 	unsigned long hash;
+	unsigned long index = xas->xa_index;
 
-	/*
-	 * If 'entry' is a PMD, align the 'index' that we use for the wait
-	 * queue to the start of that PMD.  This ensures that all offsets in
-	 * the range covered by the PMD map to the same bit lock.
-	 */
-	if (dax_is_pmd_entry(entry))
-		index &= ~PG_PMD_COLOUR;
-
-	key->xa = xa;
+	key->xa = xas->xa;
 	key->entry_start = index;
 
-	hash = hash_long((unsigned long)xa ^ index, DAX_WAIT_TABLE_BITS);
+	hash = hash_long((unsigned long)xas->xa ^ index, DAX_WAIT_TABLE_BITS);
 	return wait_table + hash;
 }
 
@@ -182,13 +174,12 @@ static int wake_exceptional_entry_func(wait_queue_entry_t *wait,
  * The important information it's conveying is whether the entry at
  * this index used to be a PMD entry.
  */
-static void dax_wake_mapping_entry_waiter(struct xarray *xa,
-		pgoff_t index, void *entry, bool wake_all)
+static void dax_wake_entry(struct xa_state *xas, bool wake_all)
 {
 	struct exceptional_entry_key key;
 	wait_queue_head_t *wq;
 
-	wq = dax_entry_waitqueue(xa, index, entry, &key);
+	wq = dax_entry_waitqueue(xas, &key);
 
 	/*
 	 * Checking for locked entry and prepare_to_wait_exclusive() happens
@@ -200,12 +191,6 @@ static void dax_wake_mapping_entry_waiter(struct xarray *xa,
 		__wake_up(wq, TASK_NORMAL, wake_all ? 0 : 1, &key);
 }
 
-static void dax_wake_entry(struct xa_state *xas, bool wake_all)
-{
-	return dax_wake_mapping_entry_waiter(xas->xa, xas->xa_index, NULL,
-								wake_all);
-}
-
 /*
  * Look up entry in page cache, wait for it to become unlocked if it
  * is a DAX entry and return it.  The caller must subsequently call
@@ -230,8 +215,7 @@ static void *get_unlocked_entry(struct xa_state *xas)
 				!dax_is_locked(entry))
 			return entry;
 
-		wq = dax_entry_waitqueue(xas->xa, xas->xa_index, entry,
-				&ewait.key);
+		wq = dax_entry_waitqueue(xas, &ewait.key);
 		prepare_to_wait_exclusive(wq, &ewait.wait,
 					  TASK_UNINTERRUPTIBLE);
 		xas_unlock_irq(xas);
@@ -273,119 +257,6 @@ static void dax_lock_entry(struct xa_state *xas, void *entry)
 	xas_store(xas, xa_mk_value(v | DAX_ENTRY_LOCK));
 }
 
-/*
- * Check whether the given slot is locked.  Must be called with the i_pages
- * lock held.
- */
-static inline int slot_locked(struct address_space *mapping, void **slot)
-{
-	unsigned long entry = xa_to_value(
-		radix_tree_deref_slot_protected(slot, &mapping->i_pages.xa_lock));
-	return entry & DAX_ENTRY_LOCK;
-}
-
-/*
- * Mark the given slot as locked.  Must be called with the i_pages lock held.
- */
-static inline void *lock_slot(struct address_space *mapping, void **slot)
-{
-	unsigned long v = xa_to_value(
-		radix_tree_deref_slot_protected(slot, &mapping->i_pages.xa_lock));
-	void *entry = xa_mk_value(v | DAX_ENTRY_LOCK);
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
-	void *entry = xa_mk_value(v & ~DAX_ENTRY_LOCK);
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
@@ -473,28 +344,31 @@ static struct page *dax_busy_page(void *entry)
  * Note: Unlike filemap_fault() we don't honor FAULT_FLAG_RETRY flags. For
  * persistent memory the benefit is doubtful. We can add that later if we can
  * show it helps.
+ *
+ * On error, this function does not return an ERR_PTR.  Instead it returns
+ * a VM_FAULT code, encoded as an xarray internal entry.  The ERR_PTR values
+ * overlap with legitimate entries.
  */
-static void *grab_mapping_entry(struct address_space *mapping, pgoff_t index,
-		unsigned long size_flag)
+static
+void *grab_mapping_entry(struct xa_state *xas, struct address_space *mapping)
 {
 	bool pmd_downgrade = false; /* splitting 2MiB entry into 4k entries? */
-	void *entry, **slot;
+	void *entry;
 
 restart:
-	xa_lock_irq(&mapping->i_pages);
-	entry = get_unlocked_mapping_entry(mapping, index, &slot);
+	xas_lock_irq(xas);
+	entry = get_unlocked_entry(xas);
 
-	if (WARN_ON_ONCE(entry && !xa_is_value(entry))) {
-		entry = ERR_PTR(-EIO);
+	if (WARN_ON_ONCE(entry && xa_is_value(entry))) {
+		entry = xa_mk_internal(VM_FAULT_SIGBUS);
 		goto out_unlock;
 	}
 
 	if (entry) {
-		if (size_flag & DAX_PMD) {
-			if (dax_is_pte_entry(entry)) {
-				put_unlocked_mapping_entry(mapping, index,
-						entry);
-				entry = ERR_PTR(-EEXIST);
+		if (xas->xa_shift) {
+			if (xa_is_internal(entry) || dax_is_pte_entry(entry)) {
+				put_unlocked_entry(xas, entry);
+				entry = xa_mk_internal(VM_FAULT_FALLBACK);
 				goto out_unlock;
 			}
 		} else { /* trying to grab a PTE entry */
@@ -506,87 +380,41 @@ static void *grab_mapping_entry(struct address_space *mapping, pgoff_t index,
 		}
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
-
-		xa_unlock_irq(&mapping->i_pages);
+	if (pmd_downgrade) {
+		dax_lock_entry(xas, entry);
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
-			mapping->nrexceptional--;
-			dax_wake_mapping_entry_waiter(&mapping->i_pages,
-					index, entry, true);
-		}
-
-		entry = dax_mk_locked(0, size_flag | DAX_EMPTY);
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
+		dax_disassociate_entry(entry, mapping, false);
+		xas_store(xas, NULL);
+		mapping->nrexceptional--;
+		dax_wake_entry(xas, true);
+	}
+	if (!entry || pmd_downgrade) {
+		entry = dax_mk_entry(pfn_to_pfn_t(0), DAX_EMPTY);
+		dax_lock_entry(xas, entry);
+		if (!xas_error(xas))
+			mapping->nrexceptional++;
+	} else {
+		dax_lock_entry(xas, entry);
 	}
-	entry = lock_slot(mapping, slot);
  out_unlock:
-	xa_unlock_irq(&mapping->i_pages);
-	return entry;
+	xas_unlock_irq(xas);
+	if (xas_nomem(xas, GFP_NOIO))
+		goto restart;
+	if (!xas_error(xas))
+		return entry;
+	return xa_mk_internal(VM_FAULT_OOM);
 }
 
 /**
@@ -741,29 +569,25 @@ static int copy_user_dax(struct block_device *bdev, struct dax_device *dax_dev,
  * already in the tree, we will skip the insertion and just dirty the PMD as
  * appropriate.
  */
-static void *dax_insert_entry(struct address_space *mapping,
-				struct vm_fault *vmf, void *entry, pfn_t pfn_t,
-				unsigned long flags, bool dirty)
+static void *dax_insert_entry(struct xa_state *xas,
+		struct address_space *mapping, void *entry, pfn_t pfn_t,
+		unsigned long flags, bool dirty)
 {
-	struct radix_tree_root *pages = &mapping->i_pages;
-	unsigned long pfn = pfn_t_to_pfn(pfn_t);
-	pgoff_t index = vmf->pgoff;
-	void *new_entry;
-
+	void *new_entry = dax_mk_entry(pfn_t, flags);
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
-	new_entry = dax_mk_locked(pfn, flags);
+	xas_reset(xas);
+	xas_lock_irq(xas);
 	if (dax_entry_size(entry) != dax_entry_size(new_entry)) {
 		dax_disassociate_entry(entry, mapping, false);
 		dax_associate_entry(new_entry, mapping);
@@ -778,21 +602,16 @@ static void *dax_insert_entry(struct address_space *mapping,
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
 
@@ -1060,15 +879,16 @@ static int dax_iomap_pfn(struct iomap *iomap, loff_t pos, size_t size,
  * If this page is ever written to we will re-fault and change the mapping to
  * point to real DAX storage instead.
  */
-static int dax_load_hole(struct address_space *mapping, void *entry,
-			 struct vm_fault *vmf)
+static int dax_load_hole(struct xa_state *xas, struct address_space *mapping,
+		void **entry, struct vm_fault *vmf)
 {
 	struct inode *inode = mapping->host;
 	unsigned long vaddr = vmf->address;
 	int ret = VM_FAULT_NOPAGE;
 	pfn_t pfn = pfn_to_pfn_t(my_zero_pfn(vaddr));
 
-	dax_insert_entry(mapping, vmf, entry, pfn, DAX_ZERO_PAGE, false);
+	*entry = dax_insert_entry(xas, mapping, *entry, pfn, DAX_ZERO_PAGE,
+			false);
 
 	vm_insert_mixed(vmf->vma, vaddr, pfn);
 	trace_dax_load_hole(inode, vmf, ret);
@@ -1277,6 +1097,7 @@ static int dax_iomap_pte_fault(struct vm_fault *vmf, pfn_t *pfnp,
 {
 	struct vm_area_struct *vma = vmf->vma;
 	struct address_space *mapping = vma->vm_file->f_mapping;
+	XA_STATE(xas, &mapping->i_pages, vmf->pgoff);
 	struct inode *inode = mapping->host;
 	unsigned long vaddr = vmf->address;
 	loff_t pos = (loff_t)vmf->pgoff << PAGE_SHIFT;
@@ -1303,9 +1124,9 @@ static int dax_iomap_pte_fault(struct vm_fault *vmf, pfn_t *pfnp,
 	if (write && !vmf->cow_page)
 		flags |= IOMAP_WRITE;
 
-	entry = grab_mapping_entry(mapping, vmf->pgoff, 0);
-	if (IS_ERR(entry)) {
-		vmf_ret = dax_fault_return(PTR_ERR(entry));
+	entry = grab_mapping_entry(&xas, mapping);
+	if (xa_is_internal(entry)) {
+		vmf_ret = xa_to_internal(entry);
 		goto out;
 	}
 
@@ -1378,7 +1199,7 @@ static int dax_iomap_pte_fault(struct vm_fault *vmf, pfn_t *pfnp,
 		if (error < 0)
 			goto error_finish_iomap;
 
-		entry = dax_insert_entry(mapping, vmf, entry, pfn,
+		entry = dax_insert_entry(&xas, mapping, entry, pfn,
 						 0, write && !sync);
 
 		/*
@@ -1409,7 +1230,7 @@ static int dax_iomap_pte_fault(struct vm_fault *vmf, pfn_t *pfnp,
 	case IOMAP_UNWRITTEN:
 	case IOMAP_HOLE:
 		if (!write) {
-			vmf_ret = dax_load_hole(mapping, entry, vmf);
+			vmf_ret = dax_load_hole(&xas, mapping, &entry, vmf);
 			goto finish_iomap;
 		}
 		/*FALLTHRU*/
@@ -1436,21 +1257,20 @@ static int dax_iomap_pte_fault(struct vm_fault *vmf, pfn_t *pfnp,
 		ops->iomap_end(inode, pos, PAGE_SIZE, copied, flags, &iomap);
 	}
  unlock_entry:
-	put_locked_mapping_entry(mapping, vmf->pgoff);
+	put_locked_entry(&xas, entry);
  out:
 	trace_dax_pte_fault_done(inode, vmf, vmf_ret);
 	return vmf_ret;
 }
 
 #ifdef CONFIG_FS_DAX_PMD
-static int dax_pmd_load_hole(struct vm_fault *vmf, struct iomap *iomap,
-		void *entry)
+static int dax_pmd_load_hole(struct xa_state *xas, struct vm_fault *vmf,
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
@@ -1461,7 +1281,7 @@ static int dax_pmd_load_hole(struct vm_fault *vmf, struct iomap *iomap,
 		goto fallback;
 
 	pfn = page_to_pfn_t(zero_page);
-	ret = dax_insert_entry(mapping, vmf, entry, pfn,
+	*entry = dax_insert_entry(xas, mapping, *entry, pfn,
 			DAX_PMD | DAX_ZERO_PAGE, false);
 
 	ptl = pmd_lock(vmf->vma->vm_mm, vmf->pmd);
@@ -1474,11 +1294,11 @@ static int dax_pmd_load_hole(struct vm_fault *vmf, struct iomap *iomap,
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
 
@@ -1487,6 +1307,7 @@ static int dax_iomap_pmd_fault(struct vm_fault *vmf, pfn_t *pfnp,
 {
 	struct vm_area_struct *vma = vmf->vma;
 	struct address_space *mapping = vma->vm_file->f_mapping;
+	XA_STATE_ORDER(xas, &mapping->i_pages, vmf->pgoff, PMD_ORDER);
 	unsigned long pmd_addr = vmf->address & PMD_MASK;
 	bool write = vmf->flags & FAULT_FLAG_WRITE;
 	bool sync;
@@ -1494,7 +1315,7 @@ static int dax_iomap_pmd_fault(struct vm_fault *vmf, pfn_t *pfnp,
 	struct inode *inode = mapping->host;
 	int result = VM_FAULT_FALLBACK;
 	struct iomap iomap = { 0 };
-	pgoff_t max_pgoff, pgoff;
+	pgoff_t max_pgoff;
 	void *entry;
 	loff_t pos;
 	int error;
@@ -1505,7 +1326,6 @@ static int dax_iomap_pmd_fault(struct vm_fault *vmf, pfn_t *pfnp,
 	 * supposed to hold locks serializing us with truncate / punch hole so
 	 * this is a reliable test.
 	 */
-	pgoff = linear_page_index(vma, pmd_addr);
 	max_pgoff = DIV_ROUND_UP(i_size_read(inode), PAGE_SIZE);
 
 	trace_dax_pmd_fault(inode, vmf, max_pgoff, 0);
@@ -1530,13 +1350,8 @@ static int dax_iomap_pmd_fault(struct vm_fault *vmf, pfn_t *pfnp,
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
@@ -1545,9 +1360,11 @@ static int dax_iomap_pmd_fault(struct vm_fault *vmf, pfn_t *pfnp,
 	 * is already in the tree, for instance), it will return -EEXIST and
 	 * we just fall back to 4k entries.
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
@@ -1566,7 +1383,7 @@ static int dax_iomap_pmd_fault(struct vm_fault *vmf, pfn_t *pfnp,
 	 * setting up a mapping, so really we're using iomap_begin() as a way
 	 * to look up our filesystem block.
 	 */
-	pos = (loff_t)pgoff << PAGE_SHIFT;
+	pos = (loff_t)xas.xa_index << PAGE_SHIFT;
 	error = ops->iomap_begin(inode, pos, PMD_SIZE, iomap_flags, &iomap);
 	if (error)
 		goto unlock_entry;
@@ -1582,7 +1399,7 @@ static int dax_iomap_pmd_fault(struct vm_fault *vmf, pfn_t *pfnp,
 		if (error < 0)
 			goto finish_iomap;
 
-		entry = dax_insert_entry(mapping, vmf, entry, pfn,
+		entry = dax_insert_entry(&xas, mapping, entry, pfn,
 						DAX_PMD, write && !sync);
 
 		/*
@@ -1607,7 +1424,7 @@ static int dax_iomap_pmd_fault(struct vm_fault *vmf, pfn_t *pfnp,
 	case IOMAP_HOLE:
 		if (WARN_ON_ONCE(write))
 			break;
-		result = dax_pmd_load_hole(vmf, &iomap, entry);
+		result = dax_pmd_load_hole(&xas, vmf, &iomap, &entry);
 		break;
 	default:
 		WARN_ON_ONCE(1);
@@ -1630,13 +1447,12 @@ static int dax_iomap_pmd_fault(struct vm_fault *vmf, pfn_t *pfnp,
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
2.16.2
