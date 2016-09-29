Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id C218228024B
	for <linux-mm@kvack.org>; Thu, 29 Sep 2016 18:49:45 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id bv10so165915347pad.2
        for <linux-mm@kvack.org>; Thu, 29 Sep 2016 15:49:45 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id d86si16422436pfe.90.2016.09.29.15.49.44
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 29 Sep 2016 15:49:44 -0700 (PDT)
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: [PATCH v4 10/12] dax: add struct iomap based DAX PMD support
Date: Thu, 29 Sep 2016 16:49:28 -0600
Message-Id: <1475189370-31634-11-git-send-email-ross.zwisler@linux.intel.com>
In-Reply-To: <1475189370-31634-1-git-send-email-ross.zwisler@linux.intel.com>
References: <1475189370-31634-1-git-send-email-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.com>, Matthew Wilcox <mawilcox@microsoft.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-xfs@vger.kernel.org

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
 fs/dax.c            | 334 +++++++++++++++++++++++++++++++++++++++++++++-------
 include/linux/dax.h |  38 +++++-
 mm/filemap.c        |   4 +-
 3 files changed, 327 insertions(+), 49 deletions(-)

diff --git a/fs/dax.c b/fs/dax.c
index 6977e5e..93a818d 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -34,20 +34,6 @@
 #include <linux/iomap.h>
 #include "internal.h"
 
-/*
- * We use lowest available bit in exceptional entry for locking, other two
- * bits to determine entry type. In total 3 special bits.
- */
-#define RADIX_DAX_SHIFT	(RADIX_TREE_EXCEPTIONAL_SHIFT + 3)
-#define RADIX_DAX_PTE (1 << (RADIX_TREE_EXCEPTIONAL_SHIFT + 1))
-#define RADIX_DAX_PMD (1 << (RADIX_TREE_EXCEPTIONAL_SHIFT + 2))
-#define RADIX_DAX_TYPE_MASK (RADIX_DAX_PTE | RADIX_DAX_PMD)
-#define RADIX_DAX_TYPE(entry) ((unsigned long)entry & RADIX_DAX_TYPE_MASK)
-#define RADIX_DAX_SECTOR(entry) (((unsigned long)entry >> RADIX_DAX_SHIFT))
-#define RADIX_DAX_ENTRY(sector, pmd) ((void *)((unsigned long)sector << \
-		RADIX_DAX_SHIFT | (pmd ? RADIX_DAX_PMD : RADIX_DAX_PTE) | \
-		RADIX_TREE_EXCEPTIONAL_ENTRY))
-
 /* We choose 4096 entries - same as per-zone page wait tables */
 #define DAX_WAIT_TABLE_BITS 12
 #define DAX_WAIT_TABLE_ENTRIES (1 << DAX_WAIT_TABLE_BITS)
@@ -400,19 +386,52 @@ static void *get_unlocked_mapping_entry(struct address_space *mapping,
  * radix tree entry locked. If the radix tree doesn't contain given index,
  * create empty exceptional entry for the index and return with it locked.
  *
+ * When requesting an entry with type RADIX_DAX_PMD, grab_mapping_entry() will
+ * either return that locked entry or will return an error.  This error will
+ * happen if there are any 4k entries (either zero pages or DAX entries)
+ * within the 2MiB range that we are requesting.
+ *
+ * We always favor 4k entries over 2MiB entries. There isn't a flow where we
+ * evict 4k entries in order to 'upgrade' them to a 2MiB entry.  Also, a 2MiB
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
+		unsigned long new_type)
 {
+	bool pmd_downgrade = false; /* splitting 2MiB entry into 4k entries? */
 	void *entry, **slot;
 
 restart:
 	spin_lock_irq(&mapping->tree_lock);
 	entry = get_unlocked_mapping_entry(mapping, index, &slot);
+
+	if (entry && new_type == RADIX_DAX_PMD) {
+		if (!radix_tree_exceptional_entry(entry) ||
+				RADIX_DAX_TYPE(entry) == RADIX_DAX_PTE) {
+			spin_unlock_irq(&mapping->tree_lock);
+			return ERR_PTR(-EEXIST);
+		}
+	} else if (entry && new_type == RADIX_DAX_PTE) {
+		if (radix_tree_exceptional_entry(entry) &&
+		    RADIX_DAX_TYPE(entry) == RADIX_DAX_PMD &&
+		    (unsigned long)entry & (RADIX_DAX_HZP|RADIX_DAX_EMPTY)) {
+			pmd_downgrade = true;
+		}
+	}
+
 	/* No entry for given index? Make sure radix tree is big enough. */
-	if (!entry) {
+	if (!entry || pmd_downgrade) {
 		int err;
 
 		spin_unlock_irq(&mapping->tree_lock);
@@ -420,15 +439,39 @@ restart:
 				mapping_gfp_mask(mapping) & ~__GFP_HIGHMEM);
 		if (err)
 			return ERR_PTR(err);
-		entry = (void *)(RADIX_TREE_EXCEPTIONAL_ENTRY |
-			       RADIX_DAX_ENTRY_LOCK);
+
+		/*
+		 * Besides huge zero pages the only other thing that gets
+		 * downgraded are empty entries which don't need to be
+		 * unmapped.
+		 */
+		if (pmd_downgrade && ((unsigned long)entry & RADIX_DAX_HZP))
+			unmap_mapping_range(mapping,
+				(index << PAGE_SHIFT) & PMD_MASK, PMD_SIZE, 0);
+
 		spin_lock_irq(&mapping->tree_lock);
-		err = radix_tree_insert(&mapping->page_tree, index, entry);
+
+		if (pmd_downgrade) {
+			radix_tree_delete(&mapping->page_tree, index);
+			mapping->nrexceptional--;
+			dax_wake_mapping_entry_waiter(entry, mapping, index,
+					false);
+		}
+
+		entry = RADIX_DAX_EMPTY_ENTRY(new_type);
+
+		err = __radix_tree_insert(&mapping->page_tree, index,
+				RADIX_DAX_ORDER(new_type), entry);
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
+			if (err == -EEXIST && new_type == RADIX_DAX_PTE)
 				goto restart;
 			return ERR_PTR(err);
 		}
@@ -596,11 +639,17 @@ static int copy_user_dax(struct block_device *bdev, sector_t sector, size_t size
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
+				      unsigned long new_type, bool hzp)
 {
 	struct radix_tree_root *page_tree = &mapping->page_tree;
 	int error = 0;
@@ -623,22 +672,30 @@ static void *dax_insert_mapping_entry(struct address_space *mapping,
 		error = radix_tree_preload(vmf->gfp_mask & ~__GFP_HIGHMEM);
 		if (error)
 			return ERR_PTR(error);
+	} else if ((unsigned long)entry & RADIX_DAX_HZP && !hzp) {
+		/* replacing huge zero page with PMD block mapping */
+		unmap_mapping_range(mapping,
+			(vmf->pgoff << PAGE_SHIFT) & PMD_MASK, PMD_SIZE, 0);
 	}
 
 	spin_lock_irq(&mapping->tree_lock);
-	new_entry = (void *)((unsigned long)RADIX_DAX_ENTRY(sector, false) |
-		       RADIX_DAX_ENTRY_LOCK);
+	if (hzp)
+		new_entry = RADIX_DAX_HZP_ENTRY();
+	else
+		new_entry = RADIX_DAX_ENTRY(sector, new_type);
+
 	if (hole_fill) {
 		__delete_from_page_cache(entry, NULL);
 		/* Drop pagecache reference */
 		put_page(entry);
-		error = radix_tree_insert(page_tree, index, new_entry);
+		error = __radix_tree_insert(page_tree, index,
+				RADIX_DAX_ORDER(new_type), new_entry);
 		if (error) {
 			new_entry = ERR_PTR(error);
 			goto unlock;
 		}
 		mapping->nrexceptional++;
-	} else {
+	} else if ((unsigned long)entry & (RADIX_DAX_HZP|RADIX_DAX_EMPTY)) {
 		void **slot;
 		void *ret;
 
@@ -694,6 +751,18 @@ static int dax_writeback_one(struct block_device *bdev,
 		goto unlock;
 	}
 
+	if (WARN_ON_ONCE((unsigned long)entry & RADIX_DAX_EMPTY)) {
+		ret = -EIO;
+		goto unlock;
+	}
+
+	/*
+	 * Even if dax_writeback_mapping_range() was given a wbc->range_start
+	 * in the middle of a PMD, the 'index' we are given will be aligned to
+	 * the start index of the PMD, as will the sector we pull from
+	 * 'entry'.  This allows us to flush for PMD_SIZE and not have to
+	 * worry about partial PMD writebacks.
+	 */
 	dax.sector = RADIX_DAX_SECTOR(entry);
 	dax.size = (type == RADIX_DAX_PMD ? PMD_SIZE : PAGE_SIZE);
 	spin_unlock_irq(&mapping->tree_lock);
@@ -734,12 +803,11 @@ int dax_writeback_mapping_range(struct address_space *mapping,
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
@@ -749,15 +817,6 @@ int dax_writeback_mapping_range(struct address_space *mapping,
 
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
 
@@ -802,7 +861,8 @@ static int dax_insert_mapping(struct address_space *mapping,
 		return PTR_ERR(dax.addr);
 	dax_unmap_atomic(bdev, &dax);
 
-	ret = dax_insert_mapping_entry(mapping, vmf, entry, dax.sector);
+	ret = dax_insert_mapping_entry(mapping, vmf, entry, dax.sector,
+			RADIX_DAX_PTE, false);
 	if (IS_ERR(ret))
 		return PTR_ERR(ret);
 	*entryp = ret;
@@ -849,7 +909,7 @@ int dax_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
 	bh.b_bdev = inode->i_sb->s_bdev;
 	bh.b_size = PAGE_SIZE;
 
-	entry = grab_mapping_entry(mapping, vmf->pgoff);
+	entry = grab_mapping_entry(mapping, vmf->pgoff, RADIX_DAX_PTE);
 	if (IS_ERR(entry)) {
 		error = PTR_ERR(entry);
 		goto out;
@@ -1023,6 +1083,11 @@ int dax_truncate_page(struct inode *inode, loff_t from, get_block_t get_block)
 EXPORT_SYMBOL_GPL(dax_truncate_page);
 
 #ifdef CONFIG_FS_IOMAP
+static inline sector_t dax_iomap_sector(struct iomap *iomap, loff_t pos)
+{
+	return iomap->blkno + (((pos & PAGE_MASK) - iomap->offset) >> 9);
+}
+
 static loff_t
 dax_iomap_actor(struct inode *inode, loff_t pos, loff_t length, void *data,
 		struct iomap *iomap)
@@ -1048,8 +1113,7 @@ dax_iomap_actor(struct inode *inode, loff_t pos, loff_t length, void *data,
 		struct blk_dax_ctl dax = { 0 };
 		ssize_t map_len;
 
-		dax.sector = iomap->blkno +
-			(((pos & PAGE_MASK) - iomap->offset) >> 9);
+		dax.sector = dax_iomap_sector(iomap, pos);
 		dax.size = (length + offset + PAGE_SIZE - 1) & PAGE_MASK;
 		map_len = dax_map_atomic(iomap->bdev, &dax);
 		if (map_len < 0) {
@@ -1164,7 +1228,7 @@ int dax_iomap_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
 	if (pos >= i_size_read(inode))
 		return VM_FAULT_SIGBUS;
 
-	entry = grab_mapping_entry(mapping, vmf->pgoff);
+	entry = grab_mapping_entry(mapping, vmf->pgoff, RADIX_DAX_PTE);
 	if (IS_ERR(entry)) {
 		error = PTR_ERR(entry);
 		goto out;
@@ -1186,7 +1250,7 @@ int dax_iomap_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
 		goto unlock_entry;
 	}
 
-	sector = iomap.blkno + (((pos & PAGE_MASK) - iomap.offset) >> 9);
+	sector = dax_iomap_sector(&iomap, pos);
 
 	if (vmf->cow_page) {
 		switch (iomap.type) {
@@ -1246,4 +1310,184 @@ int dax_iomap_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
 	return VM_FAULT_NOPAGE | major;
 }
 EXPORT_SYMBOL_GPL(dax_iomap_fault);
+
+#if defined(CONFIG_FS_DAX_PMD)
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
+	ret = dax_insert_mapping_entry(mapping, vmf, *entryp,
+			dax.sector, RADIX_DAX_PMD, false);
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
+	ret = dax_insert_mapping_entry(mapping, vmf, *entryp,
+			0, RADIX_DAX_PMD, true);
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
+	struct inode *inode = mapping->host;
+	struct iomap iomap = { 0 };
+	int error, result = 0;
+	pgoff_t size, pgoff;
+	struct vm_fault vmf;
+	void *entry;
+	loff_t pos;
+
+	/* Fall back to PTEs if we're going to COW */
+	if (write && !(vma->vm_flags & VM_SHARED)) {
+		split_huge_pmd(vma, pmd, address);
+		return VM_FAULT_FALLBACK;
+	}
+
+	/* If the PMD would extend outside the VMA */
+	if (pmd_addr < vma->vm_start)
+		return VM_FAULT_FALLBACK;
+	if ((pmd_addr + PMD_SIZE) > vma->vm_end)
+		return VM_FAULT_FALLBACK;
+
+	/*
+	 * Check whether offset isn't beyond end of file now. Caller is
+	 * supposed to hold locks serializing us with truncate / punch hole so
+	 * this is a reliable test.
+	 */
+	pgoff = linear_page_index(vma, pmd_addr);
+	size = (i_size_read(inode) + PAGE_SIZE - 1) >> PAGE_SHIFT;
+
+	if (pgoff >= size)
+		return VM_FAULT_SIGBUS;
+
+	/* If the PMD would extend beyond the file size */
+	if ((pgoff | PG_PMD_COLOUR) >= size)
+		return VM_FAULT_FALLBACK;
+
+	/*
+	 * grab_mapping_entry() will make sure we get a 2M empty entry, a DAX
+	 * PMD or a HZP entry.  If it can't (because a 4k page is already in
+	 * the tree, for instance), it will return -EEXIST and we just fall
+	 * back to 4k entries.
+	 */
+	entry = grab_mapping_entry(mapping, pgoff, RADIX_DAX_PMD);
+	if (IS_ERR(entry))
+		return VM_FAULT_FALLBACK;
+
+	/*
+	 * Note that we don't use iomap_apply here.  We aren't doing I/O, only
+	 * setting up a mapping, so really we're using iomap_begin() as a way
+	 * to look up our filesystem block.
+	 */
+	pos = (loff_t)pgoff << PAGE_SHIFT;
+	error = ops->iomap_begin(inode, pos, PMD_SIZE, write ? IOMAP_WRITE : 0,
+			&iomap);
+	if (error)
+		goto fallback;
+	if (iomap.offset + iomap.length < pos + PMD_SIZE)
+		goto fallback;
+
+	vmf.pgoff = pgoff;
+	vmf.flags = flags;
+	vmf.gfp_mask = mapping_gfp_mask(mapping) | __GFP_FS | __GFP_IO;
+
+	switch (iomap.type) {
+	case IOMAP_MAPPED:
+		result = dax_pmd_insert_mapping(vma, pmd, &vmf, address,
+				&iomap, pos, write, &entry);
+		break;
+	case IOMAP_UNWRITTEN:
+	case IOMAP_HOLE:
+		if (WARN_ON_ONCE(write))
+			goto fallback;
+		result = dax_pmd_load_hole(vma, pmd, &vmf, address, &iomap,
+				&entry);
+		break;
+	default:
+		WARN_ON_ONCE(1);
+		result = VM_FAULT_FALLBACK;
+		break;
+	}
+
+	if (result == VM_FAULT_FALLBACK)
+		count_vm_event(THP_FAULT_FALLBACK);
+
+ unlock_entry:
+	put_locked_mapping_entry(mapping, pgoff, entry);
+	return result;
+
+ fallback:
+	count_vm_event(THP_FAULT_FALLBACK);
+	result = VM_FAULT_FALLBACK;
+	goto unlock_entry;
+}
+EXPORT_SYMBOL_GPL(dax_iomap_pmd_fault);
+#endif /* CONFIG_FS_DAX_PMD */
 #endif /* CONFIG_FS_IOMAP */
diff --git a/include/linux/dax.h b/include/linux/dax.h
index c4a51bb..cacff9e 100644
--- a/include/linux/dax.h
+++ b/include/linux/dax.h
@@ -8,8 +8,33 @@
 
 struct iomap_ops;
 
-/* We use lowest available exceptional entry bit for locking */
+/*
+ * We use lowest available bit in exceptional entry for locking, two bits for
+ * the entry type (PMD & PTE), and two more for flags (HZP and empty).  In
+ * total five special bits.
+ */
+#define RADIX_DAX_SHIFT	(RADIX_TREE_EXCEPTIONAL_SHIFT + 5)
 #define RADIX_DAX_ENTRY_LOCK (1 << RADIX_TREE_EXCEPTIONAL_SHIFT)
+/* PTE and PMD types */
+#define RADIX_DAX_PTE (1 << (RADIX_TREE_EXCEPTIONAL_SHIFT + 1))
+#define RADIX_DAX_PMD (1 << (RADIX_TREE_EXCEPTIONAL_SHIFT + 2))
+/* huge zero page and empty entry flags */
+#define RADIX_DAX_HZP (1 << (RADIX_TREE_EXCEPTIONAL_SHIFT + 3))
+#define RADIX_DAX_EMPTY (1 << (RADIX_TREE_EXCEPTIONAL_SHIFT + 4))
+
+#define RADIX_DAX_TYPE_MASK (RADIX_DAX_PTE | RADIX_DAX_PMD)
+#define RADIX_DAX_TYPE(entry) ((unsigned long)entry & RADIX_DAX_TYPE_MASK)
+#define RADIX_DAX_SECTOR(entry) (((unsigned long)entry >> RADIX_DAX_SHIFT))
+
+/* entries begin locked */
+#define RADIX_DAX_ENTRY(sector, type) ((void *)(RADIX_TREE_EXCEPTIONAL_ENTRY |\
+	type | (unsigned long)sector << RADIX_DAX_SHIFT | RADIX_DAX_ENTRY_LOCK))
+#define RADIX_DAX_HZP_ENTRY() ((void *)(RADIX_TREE_EXCEPTIONAL_ENTRY | \
+	RADIX_DAX_PMD | RADIX_DAX_HZP | RADIX_DAX_EMPTY | RADIX_DAX_ENTRY_LOCK))
+#define RADIX_DAX_EMPTY_ENTRY(type) ((void *)(RADIX_TREE_EXCEPTIONAL_ENTRY | \
+		type | RADIX_DAX_EMPTY | RADIX_DAX_ENTRY_LOCK))
+
+#define RADIX_DAX_ORDER(type) (type == RADIX_DAX_PMD ? PMD_SHIFT-PAGE_SHIFT : 0)
 
 ssize_t dax_iomap_rw(struct kiocb *iocb, struct iov_iter *iter,
 		struct iomap_ops *ops);
@@ -54,6 +79,17 @@ static inline int dax_pmd_fault(struct vm_area_struct *vma, unsigned long addr,
 	return VM_FAULT_FALLBACK;
 }
 
+#if defined(CONFIG_FS_DAX_PMD)
+int dax_iomap_pmd_fault(struct vm_area_struct *vma, unsigned long address,
+		pmd_t *pmd, unsigned int flags, struct iomap_ops *ops);
+#else
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
index 35e880d..d9dd97e 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -610,9 +610,7 @@ static int page_cache_tree_insert(struct address_space *mapping,
 				workingset_node_shadows_dec(node);
 		} else {
 			/* DAX can replace empty locked entry with a hole */
-			WARN_ON_ONCE(p !=
-				(void *)(RADIX_TREE_EXCEPTIONAL_ENTRY |
-					 RADIX_DAX_ENTRY_LOCK));
+			WARN_ON_ONCE(p != RADIX_DAX_EMPTY_ENTRY(RADIX_DAX_PTE));
 			/* DAX accounts exceptional entries as normal pages */
 			if (node)
 				workingset_node_pages_dec(node);
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
