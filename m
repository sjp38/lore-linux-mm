Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0D1426B02A0
	for <linux-mm@kvack.org>; Sat, 14 Apr 2018 10:15:13 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id b11-v6so7596314pla.19
        for <linux-mm@kvack.org>; Sat, 14 Apr 2018 07:15:13 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id u10si5950258pgp.45.2018.04.14.07.13.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 14 Apr 2018 07:13:31 -0700 (PDT)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v11 53/63] dax: Rename some functions
Date: Sat, 14 Apr 2018 07:13:06 -0700
Message-Id: <20180414141316.7167-54-willy@infradead.org>
In-Reply-To: <20180414141316.7167-1-willy@infradead.org>
References: <20180414141316.7167-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@redhat.com>, Lukas Czerner <lczerner@redhat.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@lst.de>, Goldwyn Rodrigues <rgoldwyn@suse.com>, Nicholas Piggin <npiggin@gmail.com>, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>, linux-nilfs@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, Chao Yu <yuchao0@huawei.com>, linux-f2fs-devel@lists.sourceforge.net, Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Mike Kravetz <mike.kravetz@oracle.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

Remove mentions of 'radix' and 'radix tree'.  Simplify some names by
dropping the word 'mapping'.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 fs/dax.c | 87 +++++++++++++++++++++++++++-----------------------------
 1 file changed, 42 insertions(+), 45 deletions(-)

diff --git a/fs/dax.c b/fs/dax.c
index c6086e7566c3..f2d1ac92466d 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -74,18 +74,18 @@ fs_initcall(init_dax_wait_table);
 #define DAX_ZERO_PAGE	(1UL << 2)
 #define DAX_EMPTY	(1UL << 3)
 
-static unsigned long dax_radix_pfn(void *entry)
+static unsigned long dax_to_pfn(void *entry)
 {
 	return xa_to_value(entry) >> DAX_SHIFT;
 }
 
-static void *dax_radix_locked_entry(unsigned long pfn, unsigned long flags)
+static void *dax_mk_locked(unsigned long pfn, unsigned long flags)
 {
 	return xa_mk_value(flags | ((unsigned long)pfn << DAX_SHIFT) |
 			DAX_ENTRY_LOCK);
 }
 
-static unsigned int dax_radix_order(void *entry)
+static unsigned int dax_entry_order(void *entry)
 {
 	if (xa_to_value(entry) & DAX_PMD)
 		return PMD_SHIFT - PAGE_SHIFT;
@@ -113,7 +113,7 @@ static int dax_is_empty_entry(void *entry)
 }
 
 /*
- * DAX radix tree locking
+ * DAX page cache entry locking
  */
 struct exceptional_entry_key {
 	struct address_space *mapping;
@@ -217,7 +217,7 @@ static inline void *unlock_slot(struct address_space *mapping, void **slot)
 }
 
 /*
- * Lookup entry in radix tree, wait for it to become unlocked if it is
+ * Lookup entry in page cache, wait for it to become unlocked if it is
  * a DAX entry and return it. The caller must call
  * put_unlocked_mapping_entry() when he decided not to lock the entry or
  * put_locked_mapping_entry() when he locked the entry and now wants to
@@ -280,7 +280,7 @@ static void put_locked_mapping_entry(struct address_space *mapping,
 }
 
 /*
- * Called when we are done with radix tree entry we looked up via
+ * Called when we are done with page cache entry we looked up via
  * get_unlocked_mapping_entry() and which we didn't lock in the end.
  */
 static void put_unlocked_mapping_entry(struct address_space *mapping,
@@ -289,7 +289,7 @@ static void put_unlocked_mapping_entry(struct address_space *mapping,
 	if (!entry)
 		return;
 
-	/* We have to wake up next waiter for the radix tree entry lock */
+	/* We have to wake up next waiter for the page cache entry lock */
 	dax_wake_mapping_entry_waiter(mapping, index, entry, false);
 }
 
@@ -305,9 +305,9 @@ static unsigned long dax_entry_size(void *entry)
 		return PAGE_SIZE;
 }
 
-static unsigned long dax_radix_end_pfn(void *entry)
+static unsigned long dax_end_pfn(void *entry)
 {
-	return dax_radix_pfn(entry) + dax_entry_size(entry) / PAGE_SIZE;
+	return dax_to_pfn(entry) + dax_entry_size(entry) / PAGE_SIZE;
 }
 
 /*
@@ -315,8 +315,8 @@ static unsigned long dax_radix_end_pfn(void *entry)
  * 'empty' and 'zero' entries.
  */
 #define for_each_mapped_pfn(entry, pfn) \
-	for (pfn = dax_radix_pfn(entry); \
-			pfn < dax_radix_end_pfn(entry); pfn++)
+	for (pfn = dax_to_pfn(entry); \
+			pfn < dax_end_pfn(entry); pfn++)
 
 static void dax_associate_entry(void *entry, struct address_space *mapping)
 {
@@ -351,9 +351,9 @@ static void dax_disassociate_entry(void *entry, struct address_space *mapping,
 }
 
 /*
- * Find radix tree entry at given index. If it is a DAX entry, return it
- * with the radix tree entry locked. If the radix tree doesn't contain the
- * given index, create an empty entry for the index and return with it locked.
+ * Find page cache entry at given index. If it is a DAX entry, return it
+ * with the entry locked. If the page cache doesn't contain an entry at
+ * that index, add a locked empty entry.
  *
  * When requesting an entry with size DAX_PMD, grab_mapping_entry() will
  * either return that locked entry or will return an error.  This error will
@@ -462,10 +462,10 @@ static void *grab_mapping_entry(struct address_space *mapping, pgoff_t index,
 					true);
 		}
 
-		entry = dax_radix_locked_entry(0, size_flag | DAX_EMPTY);
+		entry = dax_mk_locked(0, size_flag | DAX_EMPTY);
 
 		err = __radix_tree_insert(&mapping->i_pages, index,
-				dax_radix_order(entry), entry);
+				dax_entry_order(entry), entry);
 		radix_tree_preload_end();
 		if (err) {
 			xa_unlock_irq(&mapping->i_pages);
@@ -490,7 +490,7 @@ static void *grab_mapping_entry(struct address_space *mapping, pgoff_t index,
 	return entry;
 }
 
-static int __dax_invalidate_mapping_entry(struct address_space *mapping,
+static int __dax_invalidate_entry(struct address_space *mapping,
 					  pgoff_t index, bool trunc)
 {
 	int ret = 0;
@@ -520,12 +520,12 @@ static int __dax_invalidate_mapping_entry(struct address_space *mapping,
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
@@ -539,7 +539,7 @@ int dax_delete_mapping_entry(struct address_space *mapping, pgoff_t index)
 int dax_invalidate_mapping_entry_sync(struct address_space *mapping,
 				      pgoff_t index)
 {
-	return __dax_invalidate_mapping_entry(mapping, index, false);
+	return __dax_invalidate_entry(mapping, index, false);
 }
 
 static int copy_user_dax(struct block_device *bdev, struct dax_device *dax_dev,
@@ -576,10 +576,9 @@ static int copy_user_dax(struct block_device *bdev, struct dax_device *dax_dev,
  * already in the tree, we will skip the insertion and just dirty the PMD as
  * appropriate.
  */
-static void *dax_insert_mapping_entry(struct address_space *mapping,
-				      struct vm_fault *vmf,
-				      void *entry, pfn_t pfn_t,
-				      unsigned long flags, bool dirty)
+static void *dax_insert_entry(struct address_space *mapping,
+				struct vm_fault *vmf, void *entry, pfn_t pfn_t,
+				unsigned long flags, bool dirty)
 {
 	struct radix_tree_root *pages = &mapping->i_pages;
 	unsigned long pfn = pfn_t_to_pfn(pfn_t);
@@ -599,7 +598,7 @@ static void *dax_insert_mapping_entry(struct address_space *mapping,
 	}
 
 	xa_lock_irq(pages);
-	new_entry = dax_radix_locked_entry(pfn, flags);
+	new_entry = dax_mk_locked(pfn, flags);
 	if (dax_entry_size(entry) != dax_entry_size(new_entry)) {
 		dax_disassociate_entry(entry, mapping, false);
 		dax_associate_entry(new_entry, mapping);
@@ -607,9 +606,9 @@ static void *dax_insert_mapping_entry(struct address_space *mapping,
 
 	if (dax_is_zero_entry(entry) || dax_is_empty_entry(entry)) {
 		/*
-		 * Only swap our new entry into the radix tree if the current
+		 * Only swap our new entry into the page cache if the current
 		 * entry is a zero page or an empty entry.  If a normal PTE or
-		 * PMD entry is already in the tree, we leave it alone.  This
+		 * PMD entry is already in the cache, we leave it alone.  This
 		 * means that if we are trying to insert a PTE and the
 		 * existing entry is a PMD, we will just leave the PMD in the
 		 * tree and dirty it if necessary.
@@ -632,8 +631,8 @@ static void *dax_insert_mapping_entry(struct address_space *mapping,
 	return entry;
 }
 
-static inline unsigned long
-pgoff_address(pgoff_t pgoff, struct vm_area_struct *vma)
+static inline
+unsigned long pgoff_address(pgoff_t pgoff, struct vm_area_struct *vma)
 {
 	unsigned long address;
 
@@ -643,8 +642,8 @@ pgoff_address(pgoff_t pgoff, struct vm_area_struct *vma)
 }
 
 /* Walk all mappings of a given index of a file and writeprotect them */
-static void dax_mapping_entry_mkclean(struct address_space *mapping,
-				      pgoff_t index, unsigned long pfn)
+static void dax_entry_mkclean(struct address_space *mapping, pgoff_t index,
+		unsigned long pfn)
 {
 	struct vm_area_struct *vma;
 	pte_t pte, *ptep = NULL;
@@ -740,7 +739,7 @@ static int dax_writeback_one(struct dax_device *dax_dev,
 	 * compare pfns as we must not bail out due to difference in lockbit
 	 * or entry type.
 	 */
-	if (dax_radix_pfn(entry2) != dax_radix_pfn(entry))
+	if (dax_to_pfn(entry2) != dax_to_pfn(entry))
 		goto put_unlocked;
 	if (WARN_ON_ONCE(dax_is_empty_entry(entry) ||
 				dax_is_zero_entry(entry))) {
@@ -770,10 +769,10 @@ static int dax_writeback_one(struct dax_device *dax_dev,
 	 * This allows us to flush for PMD_SIZE and not have to worry about
 	 * partial PMD writebacks.
 	 */
-	pfn = dax_radix_pfn(entry);
-	size = PAGE_SIZE << dax_radix_order(entry);
+	pfn = dax_to_pfn(entry);
+	size = PAGE_SIZE << dax_entry_order(entry);
 
-	dax_mapping_entry_mkclean(mapping, index, pfn);
+	dax_entry_mkclean(mapping, index, pfn);
 	dax_flush(dax_dev, page_address(pfn_to_page(pfn)), size);
 	/*
 	 * After we have flushed the cache, we can clear the dirty tag. There
@@ -911,8 +910,7 @@ static int dax_load_hole(struct address_space *mapping, void *entry,
 	int ret = VM_FAULT_NOPAGE;
 	pfn_t pfn = pfn_to_pfn_t(my_zero_pfn(vaddr));
 
-	dax_insert_mapping_entry(mapping, vmf, entry, pfn,
-			DAX_ZERO_PAGE, false);
+	dax_insert_entry(mapping, vmf, entry, pfn, DAX_ZERO_PAGE, false);
 
 	vm_insert_mixed(vmf->vma, vaddr, pfn);
 	trace_dax_load_hole(inode, vmf, ret);
@@ -1222,7 +1220,7 @@ static int dax_iomap_pte_fault(struct vm_fault *vmf, pfn_t *pfnp,
 		if (error < 0)
 			goto error_finish_iomap;
 
-		entry = dax_insert_mapping_entry(mapping, vmf, entry, pfn,
+		entry = dax_insert_entry(mapping, vmf, entry, pfn,
 						 0, write && !sync);
 
 		/*
@@ -1305,7 +1303,7 @@ static int dax_pmd_load_hole(struct vm_fault *vmf, struct iomap *iomap,
 		goto fallback;
 
 	pfn = page_to_pfn_t(zero_page);
-	ret = dax_insert_mapping_entry(mapping, vmf, entry, pfn,
+	ret = dax_insert_entry(mapping, vmf, entry, pfn,
 			DAX_PMD | DAX_ZERO_PAGE, false);
 
 	ptl = pmd_lock(vmf->vma->vm_mm, vmf->pmd);
@@ -1358,7 +1356,7 @@ static int dax_iomap_pmd_fault(struct vm_fault *vmf, pfn_t *pfnp,
 	 * Make sure that the faulting address's PMD offset (color) matches
 	 * the PMD offset from the start of the file.  This is necessary so
 	 * that a PMD range in the page table overlaps exactly with a PMD
-	 * range in the radix tree.
+	 * range in the page cache.
 	 */
 	if ((vmf->pgoff & PG_PMD_COLOUR) !=
 	    ((vmf->address >> PAGE_SHIFT) & PG_PMD_COLOUR))
@@ -1426,7 +1424,7 @@ static int dax_iomap_pmd_fault(struct vm_fault *vmf, pfn_t *pfnp,
 		if (error < 0)
 			goto finish_iomap;
 
-		entry = dax_insert_mapping_entry(mapping, vmf, entry, pfn,
+		entry = dax_insert_entry(mapping, vmf, entry, pfn,
 						DAX_PMD, write && !sync);
 
 		/*
@@ -1519,15 +1517,14 @@ int dax_iomap_fault(struct vm_fault *vmf, enum page_entry_size pe_size,
 }
 EXPORT_SYMBOL_GPL(dax_iomap_fault);
 
-/**
+/*
  * dax_insert_pfn_mkwrite - insert PTE or PMD entry into page tables
  * @vmf: The description of the fault
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
-- 
2.17.0
