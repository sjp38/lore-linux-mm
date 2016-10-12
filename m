Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 53D24280258
	for <linux-mm@kvack.org>; Wed, 12 Oct 2016 18:50:43 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id rz1so58395885pab.0
        for <linux-mm@kvack.org>; Wed, 12 Oct 2016 15:50:43 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id m6si9442179pab.331.2016.10.12.15.50.42
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 12 Oct 2016 15:50:42 -0700 (PDT)
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: [PATCH v6 15/17] dax: add struct iomap based DAX PMD support
Date: Wed, 12 Oct 2016 16:50:20 -0600
Message-Id: <20161012225022.15507-16-ross.zwisler@linux.intel.com>
In-Reply-To: <20161012225022.15507-1-ross.zwisler@linux.intel.com>
References: <20161012225022.15507-1-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Matthew Wilcox <mawilcox@microsoft.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-xfs@vger.kernel.org

DAX PMDs have been disabled since Jan Kara introduced DAX radix tree based
locking.  This patch allows DAX PMDs to participate in the DAX radix tree
based locking scheme so that they can be re-enabled using the new struct
iomap based fault handlers.

There are currently three types of DAX 4k entries: 4k zero pages, 4k DAX
mappings that have an associated block allocation, and 4k DAX empty
entries.  The empty entries exist to provide locking for the duration of a
given page fault.

This patch adds three equivalent 2MiB DAX entries: Huge Zero Page (HZP)
entries, PMD DAX entries that have associated block allocations, and 2 MiB
DAX empty entries.

Unlike the 4k case where we insert a struct page* into the radix tree for
4k zero pages, for HZP we insert a DAX exceptional entry with the new
RADIX_DAX_HZP flag set.  This is because we use a single 2 MiB zero page in
every 2MiB hole mapping, and it doesn't make sense to have that same struct
page* with multiple entries in multiple trees.  This would cause contention
on the single page lock for the one Huge Zero Page, and it would break the
page->index and page->mapping associations that are assumed to be valid in
many other places in the kernel.

One difficult use case is when one thread is trying to use 4k entries in
radix tree for a given offset, and another thread is using 2 MiB entries
for that same offset.  The current code handles this by making the 2 MiB
user fall back to 4k entries for most cases.  This was done because it is
the simplest solution, and because the use of 2MiB pages is already
opportunistic.

If we were to try to upgrade from 4k pages to 2MiB pages for a given range,
we run into the problem of how we lock out 4k page faults for the entire
2MiB range while we clean out the radix tree so we can insert the 2MiB
entry.  We can solve this problem if we need to, but I think that the cases
where both 2MiB entries and 4K entries are being used for the same range
will be rare enough and the gain small enough that it probably won't be
worth the complexity.

Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
---
 fs/dax.c            | 377 ++++++++++++++++++++++++++++++++++++++++++++++------
 include/linux/dax.h |  55 ++++++--
 mm/filemap.c        |   3 +-
 3 files changed, 385 insertions(+), 50 deletions(-)

diff --git a/fs/dax.c b/fs/dax.c
index 0582c7c..39b41ea 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -76,6 +76,26 @@ static void dax_unmap_atomic(struct block_device *bdev,
 	blk_queue_exit(bdev->bd_queue);
 }
 
+static int dax_is_pmd_entry(void *entry)
+{
+	return (unsigned long)entry & RADIX_DAX_PMD;
+}
+
+static int dax_is_pte_entry(void *entry)
+{
+	return !((unsigned long)entry & RADIX_DAX_PMD);
+}
+
+static int dax_is_zero_entry(void *entry)
+{
+	return (unsigned long)entry & RADIX_DAX_HZP;
+}
+
+static int dax_is_empty_entry(void *entry)
+{
+	return (unsigned long)entry & RADIX_DAX_EMPTY;
+}
+
 struct page *read_dax_sector(struct block_device *bdev, sector_t n)
 {
 	struct page *page = alloc_pages(GFP_KERNEL, 0);
@@ -281,7 +301,7 @@ static wait_queue_head_t *dax_entry_waitqueue(struct address_space *mapping,
 	 * queue to the start of that PMD.  This ensures that all offsets in
 	 * the range covered by the PMD map to the same bit lock.
 	 */
-	if (RADIX_DAX_TYPE(entry) == RADIX_DAX_PMD)
+	if (dax_is_pmd_entry(entry))
 		index &= ~((1UL << (PMD_SHIFT - PAGE_SHIFT)) - 1);
 
 	key->mapping = mapping;
@@ -413,36 +433,115 @@ static void put_unlocked_mapping_entry(struct address_space *mapping,
  * radix tree entry locked. If the radix tree doesn't contain given index,
  * create empty exceptional entry for the index and return with it locked.
  *
+ * When requesting an entry with size RADIX_DAX_PMD, grab_mapping_entry() will
+ * either return that locked entry or will return an error.  This error will
+ * happen if there are any 4k entries (either zero pages or DAX entries)
+ * within the 2MiB range that we are requesting.
+ *
+ * We always favor 4k entries over 2MiB entries. There isn't a flow where we
+ * evict 4k entries in order to 'upgrade' them to a 2MiB entry.  A 2MiB
+ * insertion will fail if it finds any 4k entries already in the tree, and a
+ * 4k insertion will cause an existing 2MiB entry to be unmapped and
+ * downgraded to 4k entries.  This happens for both 2MiB huge zero pages as
+ * well as 2MiB empty entries.
+ *
+ * The exception to this downgrade path is for 2MiB DAX PMD entries that have
+ * real storage backing them.  We will leave these real 2MiB DAX entries in
+ * the tree, and PTE writes will simply dirty the entire 2MiB DAX entry.
+ *
  * Note: Unlike filemap_fault() we don't honor FAULT_FLAG_RETRY flags. For
  * persistent memory the benefit is doubtful. We can add that later if we can
  * show it helps.
  */
-static void *grab_mapping_entry(struct address_space *mapping, pgoff_t index)
+static void *grab_mapping_entry(struct address_space *mapping, pgoff_t index,
+		unsigned long size_flag)
 {
+	bool pmd_downgrade = false; /* splitting 2MiB entry into 4k entries? */
 	void *entry, **slot;
 
 restart:
 	spin_lock_irq(&mapping->tree_lock);
 	entry = get_unlocked_mapping_entry(mapping, index, &slot);
+
+	if (entry) {
+		if (size_flag & RADIX_DAX_PMD) {
+			if (!radix_tree_exceptional_entry(entry) ||
+			    dax_is_pte_entry(entry)) {
+				put_unlocked_mapping_entry(mapping, index,
+						entry);
+				entry = ERR_PTR(-EEXIST);
+				goto out_unlock;
+			}
+		} else { /* trying to grab a PTE entry */
+			if (radix_tree_exceptional_entry(entry) &&
+			    dax_is_pmd_entry(entry) &&
+			    (dax_is_zero_entry(entry) ||
+			     dax_is_empty_entry(entry))) {
+				pmd_downgrade = true;
+			}
+		}
+	}
+
 	/* No entry for given index? Make sure radix tree is big enough. */
-	if (!entry) {
+	if (!entry || pmd_downgrade) {
 		int err;
 
+		if (pmd_downgrade) {
+			/*
+			 * Make sure 'entry' remains valid while we drop
+			 * mapping->tree_lock.
+			 */
+			entry = lock_slot(mapping, slot);
+		}
+
 		spin_unlock_irq(&mapping->tree_lock);
 		err = radix_tree_preload(
 				mapping_gfp_mask(mapping) & ~__GFP_HIGHMEM);
-		if (err)
+		if (err) {
+			put_locked_mapping_entry(mapping, index, entry);
 			return ERR_PTR(err);
-		entry = (void *)(RADIX_TREE_EXCEPTIONAL_ENTRY |
-			       RADIX_DAX_ENTRY_LOCK);
+		}
+
+		/*
+		 * Besides huge zero pages the only other thing that gets
+		 * downgraded are empty entries which don't need to be
+		 * unmapped.
+		 */
+		if (pmd_downgrade && dax_is_zero_entry(entry))
+			unmap_mapping_range(mapping,
+				(index << PAGE_SHIFT) & PMD_MASK, PMD_SIZE, 0);
+
 		spin_lock_irq(&mapping->tree_lock);
-		err = radix_tree_insert(&mapping->page_tree, index, entry);
+
+		if (pmd_downgrade) {
+			radix_tree_delete(&mapping->page_tree, index);
+			mapping->nrexceptional--;
+			dax_wake_mapping_entry_waiter(mapping, index, entry,
+					true);
+		}
+
+		entry = dax_radix_locked_entry(0, size_flag | RADIX_DAX_EMPTY);
+
+		err = __radix_tree_insert(&mapping->page_tree, index,
+				dax_radix_order(entry), entry);
 		radix_tree_preload_end();
 		if (err) {
 			spin_unlock_irq(&mapping->tree_lock);
-			/* Someone already created the entry? */
-			if (err == -EEXIST)
+			/*
+			 * Someone already created the entry?  This is a
+			 * normal failure when inserting PMDs in a range
+			 * that already contains PTEs.  In that case we want
+			 * to return -EEXIST immediately.
+			 */
+			if (err == -EEXIST && !(size_flag & RADIX_DAX_PMD))
 				goto restart;
+			/*
+			 * Our insertion of a DAX PMD entry failed, most
+			 * likely because it collided with a PTE sized entry
+			 * at a different index in the PMD range.  We haven't
+			 * inserted anything into the radix tree and have no
+			 * waiters to wake.
+			 */
 			return ERR_PTR(err);
 		}
 		/* Good, we have inserted empty locked entry into the tree. */
@@ -466,6 +565,7 @@ restart:
 		return page;
 	}
 	entry = lock_slot(mapping, slot);
+ out_unlock:
 	spin_unlock_irq(&mapping->tree_lock);
 	return entry;
 }
@@ -473,9 +573,9 @@ restart:
 /*
  * We do not necessarily hold the mapping->tree_lock when we call this
  * function so it is possible that 'entry' is no longer a valid item in the
- * radix tree.  This is okay, though, because all we really need to do is to
- * find the correct waitqueue where tasks might be sleeping waiting for that
- * old 'entry' and wake them.
+ * radix tree.  This is okay because all we really need to do is to find the
+ * correct waitqueue where tasks might be waiting for that old 'entry' and
+ * wake them.
  */
 void dax_wake_mapping_entry_waiter(struct address_space *mapping,
 		pgoff_t index, void *entry, bool wake_all)
@@ -588,11 +688,17 @@ static int copy_user_dax(struct block_device *bdev, sector_t sector, size_t size
 	return 0;
 }
 
-#define DAX_PMD_INDEX(page_index) (page_index & (PMD_MASK >> PAGE_SHIFT))
-
+/*
+ * By this point grab_mapping_entry() has ensured that we have a locked entry
+ * of the appropriate size so we don't have to worry about downgrading PMDs to
+ * PTEs.  If we happen to be trying to insert a PTE and there is a PMD
+ * already in the tree, we will skip the insertion and just dirty the PMD as
+ * appropriate.
+ */
 static void *dax_insert_mapping_entry(struct address_space *mapping,
 				      struct vm_fault *vmf,
-				      void *entry, sector_t sector)
+				      void *entry, sector_t sector,
+				      unsigned long flags)
 {
 	struct radix_tree_root *page_tree = &mapping->page_tree;
 	int error = 0;
@@ -615,22 +721,35 @@ static void *dax_insert_mapping_entry(struct address_space *mapping,
 		error = radix_tree_preload(vmf->gfp_mask & ~__GFP_HIGHMEM);
 		if (error)
 			return ERR_PTR(error);
+	} else if (dax_is_zero_entry(entry) && !(flags & RADIX_DAX_HZP)) {
+		/* replacing huge zero page with PMD block mapping */
+		unmap_mapping_range(mapping,
+			(vmf->pgoff << PAGE_SHIFT) & PMD_MASK, PMD_SIZE, 0);
 	}
 
 	spin_lock_irq(&mapping->tree_lock);
-	new_entry = (void *)((unsigned long)RADIX_DAX_ENTRY(sector, false) |
-		       RADIX_DAX_ENTRY_LOCK);
+	new_entry = dax_radix_locked_entry(sector, flags);
+
 	if (hole_fill) {
 		__delete_from_page_cache(entry, NULL);
 		/* Drop pagecache reference */
 		put_page(entry);
-		error = radix_tree_insert(page_tree, index, new_entry);
+		error = __radix_tree_insert(page_tree, index,
+				dax_radix_order(new_entry), new_entry);
 		if (error) {
 			new_entry = ERR_PTR(error);
 			goto unlock;
 		}
 		mapping->nrexceptional++;
-	} else {
+	} else if (dax_is_zero_entry(entry) || dax_is_empty_entry(entry)) {
+		/*
+		 * Only swap our new entry into the radix tree if the current
+		 * entry is a zero page or an empty entry.  If a normal PTE or
+		 * PMD entry is already in the tree, we leave it alone.  This
+		 * means that if we are trying to insert a PTE and the
+		 * existing entry is a PMD, we will just leave the PMD in the
+		 * tree and dirty it if necessary.
+		 */
 		void **slot;
 		void *ret;
 
@@ -660,7 +779,6 @@ static int dax_writeback_one(struct block_device *bdev,
 		struct address_space *mapping, pgoff_t index, void *entry)
 {
 	struct radix_tree_root *page_tree = &mapping->page_tree;
-	int type = RADIX_DAX_TYPE(entry);
 	struct radix_tree_node *node;
 	struct blk_dax_ctl dax;
 	void **slot;
@@ -681,13 +799,21 @@ static int dax_writeback_one(struct block_device *bdev,
 	if (!radix_tree_tag_get(page_tree, index, PAGECACHE_TAG_TOWRITE))
 		goto unlock;
 
-	if (WARN_ON_ONCE(type != RADIX_DAX_PTE && type != RADIX_DAX_PMD)) {
+	if (WARN_ON_ONCE(dax_is_empty_entry(entry) ||
+				dax_is_zero_entry(entry))) {
 		ret = -EIO;
 		goto unlock;
 	}
 
-	dax.sector = RADIX_DAX_SECTOR(entry);
-	dax.size = (type == RADIX_DAX_PMD ? PMD_SIZE : PAGE_SIZE);
+	/*
+	 * Even if dax_writeback_mapping_range() was given a wbc->range_start
+	 * in the middle of a PMD, the 'index' we are given will be aligned to
+	 * the start index of the PMD, as will the sector we pull from
+	 * 'entry'.  This allows us to flush for PMD_SIZE and not have to
+	 * worry about partial PMD writebacks.
+	 */
+	dax.sector = dax_radix_sector(entry);
+	dax.size = PAGE_SIZE << dax_radix_order(entry);
 	spin_unlock_irq(&mapping->tree_lock);
 
 	/*
@@ -726,12 +852,11 @@ int dax_writeback_mapping_range(struct address_space *mapping,
 		struct block_device *bdev, struct writeback_control *wbc)
 {
 	struct inode *inode = mapping->host;
-	pgoff_t start_index, end_index, pmd_index;
+	pgoff_t start_index, end_index;
 	pgoff_t indices[PAGEVEC_SIZE];
 	struct pagevec pvec;
 	bool done = false;
 	int i, ret = 0;
-	void *entry;
 
 	if (WARN_ON_ONCE(inode->i_blkbits != PAGE_SHIFT))
 		return -EIO;
@@ -741,15 +866,6 @@ int dax_writeback_mapping_range(struct address_space *mapping,
 
 	start_index = wbc->range_start >> PAGE_SHIFT;
 	end_index = wbc->range_end >> PAGE_SHIFT;
-	pmd_index = DAX_PMD_INDEX(start_index);
-
-	rcu_read_lock();
-	entry = radix_tree_lookup(&mapping->page_tree, pmd_index);
-	rcu_read_unlock();
-
-	/* see if the start of our range is covered by a PMD entry */
-	if (entry && RADIX_DAX_TYPE(entry) == RADIX_DAX_PMD)
-		start_index = pmd_index;
 
 	tag_pages_for_writeback(mapping, start_index, end_index);
 
@@ -794,7 +910,7 @@ static int dax_insert_mapping(struct address_space *mapping,
 		return PTR_ERR(dax.addr);
 	dax_unmap_atomic(bdev, &dax);
 
-	ret = dax_insert_mapping_entry(mapping, vmf, entry, dax.sector);
+	ret = dax_insert_mapping_entry(mapping, vmf, entry, dax.sector, 0);
 	if (IS_ERR(ret))
 		return PTR_ERR(ret);
 	*entryp = ret;
@@ -841,7 +957,7 @@ int dax_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
 	bh.b_bdev = inode->i_sb->s_bdev;
 	bh.b_size = PAGE_SIZE;
 
-	entry = grab_mapping_entry(mapping, vmf->pgoff);
+	entry = grab_mapping_entry(mapping, vmf->pgoff, 0);
 	if (IS_ERR(entry)) {
 		error = PTR_ERR(entry);
 		goto out;
@@ -1162,7 +1278,7 @@ int dax_iomap_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
 	if (pos >= i_size_read(inode))
 		return VM_FAULT_SIGBUS;
 
-	entry = grab_mapping_entry(mapping, vmf->pgoff);
+	entry = grab_mapping_entry(mapping, vmf->pgoff, 0);
 	if (IS_ERR(entry)) {
 		error = PTR_ERR(entry);
 		goto out;
@@ -1264,4 +1380,191 @@ int dax_iomap_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
 	return VM_FAULT_NOPAGE | major;
 }
 EXPORT_SYMBOL_GPL(dax_iomap_fault);
+
+#ifdef CONFIG_FS_DAX_PMD
+/*
+ * The 'colour' (ie low bits) within a PMD of a page offset.  This comes up
+ * more often than one might expect in the below functions.
+ */
+#define PG_PMD_COLOUR	((PMD_SIZE >> PAGE_SHIFT) - 1)
+
+static int dax_pmd_insert_mapping(struct vm_area_struct *vma, pmd_t *pmd,
+		struct vm_fault *vmf, unsigned long address,
+		struct iomap *iomap, loff_t pos, bool write, void **entryp)
+{
+	struct address_space *mapping = vma->vm_file->f_mapping;
+	struct block_device *bdev = iomap->bdev;
+	struct blk_dax_ctl dax = {
+		.sector = dax_iomap_sector(iomap, pos),
+		.size = PMD_SIZE,
+	};
+	long length = dax_map_atomic(bdev, &dax);
+	void *ret;
+
+	if (length < 0) /* dax_map_atomic() failed */
+		return VM_FAULT_FALLBACK;
+	if (length < PMD_SIZE)
+		goto unmap_fallback;
+	if (pfn_t_to_pfn(dax.pfn) & PG_PMD_COLOUR)
+		goto unmap_fallback;
+	if (!pfn_t_devmap(dax.pfn))
+		goto unmap_fallback;
+
+	dax_unmap_atomic(bdev, &dax);
+
+	ret = dax_insert_mapping_entry(mapping, vmf, *entryp, dax.sector,
+			RADIX_DAX_PMD);
+	if (IS_ERR(ret))
+		return VM_FAULT_FALLBACK;
+	*entryp = ret;
+
+	return vmf_insert_pfn_pmd(vma, address, pmd, dax.pfn, write);
+
+ unmap_fallback:
+	dax_unmap_atomic(bdev, &dax);
+	return VM_FAULT_FALLBACK;
+}
+
+static int dax_pmd_load_hole(struct vm_area_struct *vma, pmd_t *pmd,
+		struct vm_fault *vmf, unsigned long address,
+		struct iomap *iomap, void **entryp)
+{
+	struct address_space *mapping = vma->vm_file->f_mapping;
+	unsigned long pmd_addr = address & PMD_MASK;
+	struct page *zero_page;
+	spinlock_t *ptl;
+	pmd_t pmd_entry;
+	void *ret;
+
+	zero_page = get_huge_zero_page();
+
+	if (unlikely(!zero_page))
+		return VM_FAULT_FALLBACK;
+
+	ret = dax_insert_mapping_entry(mapping, vmf, *entryp, 0,
+			RADIX_DAX_PMD | RADIX_DAX_HZP);
+	if (IS_ERR(ret))
+		return VM_FAULT_FALLBACK;
+	*entryp = ret;
+
+	ptl = pmd_lock(vma->vm_mm, pmd);
+	if (!pmd_none(*pmd)) {
+		spin_unlock(ptl);
+		return VM_FAULT_FALLBACK;
+	}
+
+	pmd_entry = mk_pmd(zero_page, vma->vm_page_prot);
+	pmd_entry = pmd_mkhuge(pmd_entry);
+	set_pmd_at(vma->vm_mm, pmd_addr, pmd, pmd_entry);
+	spin_unlock(ptl);
+	return VM_FAULT_NOPAGE;
+}
+
+int dax_iomap_pmd_fault(struct vm_area_struct *vma, unsigned long address,
+		pmd_t *pmd, unsigned int flags, struct iomap_ops *ops)
+{
+	struct address_space *mapping = vma->vm_file->f_mapping;
+	unsigned long pmd_addr = address & PMD_MASK;
+	bool write = flags & FAULT_FLAG_WRITE;
+	unsigned int iomap_flags = write ? IOMAP_WRITE : 0;
+	struct inode *inode = mapping->host;
+	int result = VM_FAULT_FALLBACK;
+	struct iomap iomap = { 0 };
+	pgoff_t max_pgoff, pgoff;
+	struct vm_fault vmf;
+	void *entry;
+	loff_t pos;
+	int error;
+
+	/* Fall back to PTEs if we're going to COW */
+	if (write && !(vma->vm_flags & VM_SHARED)) {
+		split_huge_pmd(vma, pmd, address);
+		goto fallback;
+	}
+
+	/* If the PMD would extend outside the VMA */
+	if (pmd_addr < vma->vm_start)
+		goto fallback;
+	if ((pmd_addr + PMD_SIZE) > vma->vm_end)
+		goto fallback;
+
+	/*
+	 * Check whether offset isn't beyond end of file now. Caller is
+	 * supposed to hold locks serializing us with truncate / punch hole so
+	 * this is a reliable test.
+	 */
+	pgoff = linear_page_index(vma, pmd_addr);
+	max_pgoff = (i_size_read(inode) - 1) >> PAGE_SHIFT;
+
+	if (pgoff > max_pgoff)
+		return VM_FAULT_SIGBUS;
+
+	/* If the PMD would extend beyond the file size */
+	if ((pgoff | PG_PMD_COLOUR) > max_pgoff)
+		goto fallback;
+
+	/*
+	 * grab_mapping_entry() will make sure we get a 2M empty entry, a DAX
+	 * PMD or a HZP entry.  If it can't (because a 4k page is already in
+	 * the tree, for instance), it will return -EEXIST and we just fall
+	 * back to 4k entries.
+	 */
+	entry = grab_mapping_entry(mapping, pgoff, RADIX_DAX_PMD);
+	if (IS_ERR(entry))
+		goto fallback;
+
+	/*
+	 * Note that we don't use iomap_apply here.  We aren't doing I/O, only
+	 * setting up a mapping, so really we're using iomap_begin() as a way
+	 * to look up our filesystem block.
+	 */
+	pos = (loff_t)pgoff << PAGE_SHIFT;
+	error = ops->iomap_begin(inode, pos, PMD_SIZE, iomap_flags, &iomap);
+	if (error)
+		goto unlock_entry;
+	if (iomap.offset + iomap.length < pos + PMD_SIZE)
+		goto finish_iomap;
+
+	vmf.pgoff = pgoff;
+	vmf.flags = flags;
+	vmf.gfp_mask = mapping_gfp_mask(mapping) | __GFP_IO;
+
+	switch (iomap.type) {
+	case IOMAP_MAPPED:
+		result = dax_pmd_insert_mapping(vma, pmd, &vmf, address,
+				&iomap, pos, write, &entry);
+		break;
+	case IOMAP_UNWRITTEN:
+	case IOMAP_HOLE:
+		if (WARN_ON_ONCE(write))
+			goto finish_iomap;
+		result = dax_pmd_load_hole(vma, pmd, &vmf, address, &iomap,
+				&entry);
+		break;
+	default:
+		WARN_ON_ONCE(1);
+		break;
+	}
+
+ finish_iomap:
+	if (ops->iomap_end) {
+		if (result == VM_FAULT_FALLBACK) {
+			ops->iomap_end(inode, pos, PMD_SIZE, 0, iomap_flags,
+					&iomap);
+		} else {
+			error = ops->iomap_end(inode, pos, PMD_SIZE, PMD_SIZE,
+					iomap_flags, &iomap);
+			if (error)
+				result = VM_FAULT_FALLBACK;
+		}
+	}
+ unlock_entry:
+	put_locked_mapping_entry(mapping, pgoff, entry);
+ fallback:
+	if (result == VM_FAULT_FALLBACK)
+		count_vm_event(THP_FAULT_FALLBACK);
+	return result;
+}
+EXPORT_SYMBOL_GPL(dax_iomap_pmd_fault);
+#endif /* CONFIG_FS_DAX_PMD */
 #endif /* CONFIG_FS_IOMAP */
diff --git a/include/linux/dax.h b/include/linux/dax.h
index e9ea78c..8d1a5c4 100644
--- a/include/linux/dax.h
+++ b/include/linux/dax.h
@@ -9,20 +9,32 @@
 struct iomap_ops;
 
 /*
- * We use lowest available bit in exceptional entry for locking, other two
- * bits to determine entry type. In total 3 special bits.
+ * We use lowest available bit in exceptional entry for locking, one bit for
+ * the entry size (PMD) and two more to tell us if the entry is a huge zero
+ * page (HZP) or an empty entry that is just used for locking.  In total four
+ * special bits.
+ *
+ * If the PMD bit isn't set the entry has size PAGE_SIZE, and if the HZP and
+ * EMPTY bits aren't set the entry is a normal DAX entry with a filesystem
+ * block allocation.
  */
-#define RADIX_DAX_SHIFT	(RADIX_TREE_EXCEPTIONAL_SHIFT + 3)
+#define RADIX_DAX_SHIFT	(RADIX_TREE_EXCEPTIONAL_SHIFT + 4)
 #define RADIX_DAX_ENTRY_LOCK (1 << RADIX_TREE_EXCEPTIONAL_SHIFT)
-#define RADIX_DAX_PTE (1 << (RADIX_TREE_EXCEPTIONAL_SHIFT + 1))
-#define RADIX_DAX_PMD (1 << (RADIX_TREE_EXCEPTIONAL_SHIFT + 2))
-#define RADIX_DAX_TYPE_MASK (RADIX_DAX_PTE | RADIX_DAX_PMD)
-#define RADIX_DAX_TYPE(entry) ((unsigned long)entry & RADIX_DAX_TYPE_MASK)
-#define RADIX_DAX_SECTOR(entry) (((unsigned long)entry >> RADIX_DAX_SHIFT))
-#define RADIX_DAX_ENTRY(sector, pmd) ((void *)((unsigned long)sector << \
-		RADIX_DAX_SHIFT | (pmd ? RADIX_DAX_PMD : RADIX_DAX_PTE) | \
-		RADIX_TREE_EXCEPTIONAL_ENTRY))
+#define RADIX_DAX_PMD (1 << (RADIX_TREE_EXCEPTIONAL_SHIFT + 1))
+#define RADIX_DAX_HZP (1 << (RADIX_TREE_EXCEPTIONAL_SHIFT + 2))
+#define RADIX_DAX_EMPTY (1 << (RADIX_TREE_EXCEPTIONAL_SHIFT + 3))
 
+static inline unsigned long dax_radix_sector(void *entry)
+{
+	return (unsigned long)entry >> RADIX_DAX_SHIFT;
+}
+
+static inline void *dax_radix_locked_entry(sector_t sector, unsigned long flags)
+{
+	return (void *)(RADIX_TREE_EXCEPTIONAL_ENTRY | flags |
+			((unsigned long)sector << RADIX_DAX_SHIFT) |
+			RADIX_DAX_ENTRY_LOCK);
+}
 
 ssize_t dax_iomap_rw(struct kiocb *iocb, struct iov_iter *iter,
 		struct iomap_ops *ops);
@@ -67,6 +79,27 @@ static inline int dax_pmd_fault(struct vm_area_struct *vma, unsigned long addr,
 	return VM_FAULT_FALLBACK;
 }
 
+#ifdef CONFIG_FS_DAX_PMD
+static inline unsigned int dax_radix_order(void *entry)
+{
+	if ((unsigned long)entry & RADIX_DAX_PMD)
+		return PMD_SHIFT - PAGE_SHIFT;
+	return 0;
+}
+int dax_iomap_pmd_fault(struct vm_area_struct *vma, unsigned long address,
+		pmd_t *pmd, unsigned int flags, struct iomap_ops *ops);
+#else
+static inline unsigned int dax_radix_order(void *entry)
+{
+	return 0;
+}
+static inline int dax_iomap_pmd_fault(struct vm_area_struct *vma,
+		unsigned long address, pmd_t *pmd, unsigned int flags,
+		struct iomap_ops *ops)
+{
+	return VM_FAULT_FALLBACK;
+}
+#endif
 int dax_pfn_mkwrite(struct vm_area_struct *, struct vm_fault *);
 #define dax_mkwrite(vma, vmf, gb)	dax_fault(vma, vmf, gb)
 
diff --git a/mm/filemap.c b/mm/filemap.c
index a596462..592e6e9 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -611,8 +611,7 @@ static int page_cache_tree_insert(struct address_space *mapping,
 		} else {
 			/* DAX can replace empty locked entry with a hole */
 			WARN_ON_ONCE(p !=
-				(void *)(RADIX_TREE_EXCEPTIONAL_ENTRY |
-					 RADIX_DAX_ENTRY_LOCK));
+				dax_radix_locked_entry(0, RADIX_DAX_EMPTY));
 			/* DAX accounts exceptional entries as normal pages */
 			if (node)
 				workingset_node_pages_dec(node);
-- 
2.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
