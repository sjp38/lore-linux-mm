Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1F98D828F3
	for <linux-mm@kvack.org>; Mon, 15 Aug 2016 15:10:06 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id le9so116545297pab.0
        for <linux-mm@kvack.org>; Mon, 15 Aug 2016 12:10:06 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id p4si19115744paz.202.2016.08.15.12.09.55
        for <linux-mm@kvack.org>;
        Mon, 15 Aug 2016 12:09:55 -0700 (PDT)
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: [PATCH 6/7] dax: re-enable DAX PMD support
Date: Mon, 15 Aug 2016 13:09:17 -0600
Message-Id: <20160815190918.20672-7-ross.zwisler@linux.intel.com>
In-Reply-To: <20160815190918.20672-1-ross.zwisler@linux.intel.com>
References: <20160815190918.20672-1-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org

DAX PMDs have been disabled since Jan Kara introduced DAX radix tree based
locking.  This patch allows DAX PMDs to participate in the DAX radix tree
based locking scheme so that they can be re-enabled.

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
 fs/dax.c            | 206 +++++++++++++++++++++++++++++++---------------------
 include/linux/dax.h |  27 ++++++-
 mm/filemap.c        |   4 +-
 3 files changed, 149 insertions(+), 88 deletions(-)

diff --git a/fs/dax.c b/fs/dax.c
index 0f1d053..482e616 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -32,20 +32,6 @@
 #include <linux/pfn_t.h>
 #include <linux/sizes.h>
 
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
@@ -386,15 +372,32 @@ static void *get_unlocked_mapping_entry(struct address_space *mapping,
  * persistent memory the benefit is doubtful. We can add that later if we can
  * show it helps.
  */
-static void *grab_mapping_entry(struct address_space *mapping, pgoff_t index)
+static void *grab_mapping_entry(struct address_space *mapping, pgoff_t index,
+		unsigned long new_type)
 {
+	bool pmd_downgrade = false;
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
@@ -402,15 +405,27 @@ restart:
 				mapping_gfp_mask(mapping) & ~__GFP_HIGHMEM);
 		if (err)
 			return ERR_PTR(err);
-		entry = (void *)(RADIX_TREE_EXCEPTIONAL_ENTRY |
-			       RADIX_DAX_ENTRY_LOCK);
+
+		if (pmd_downgrade && ((unsigned long)entry & RADIX_DAX_HZP))
+			unmap_mapping_range(mapping,
+				(index << PAGE_SHIFT) & PMD_MASK, PMD_SIZE, 0);
+
+		entry = RADIX_DAX_EMPTY_ENTRY(new_type);
 		spin_lock_irq(&mapping->tree_lock);
-		err = radix_tree_insert(&mapping->page_tree, index, entry);
+
+		if (pmd_downgrade) {
+			radix_tree_delete(&mapping->page_tree, index);
+			mapping->nrexceptional--;
+			dax_wake_mapping_entry_waiter(slot, false);
+		}
+
+		err = __radix_tree_insert(&mapping->page_tree, index,
+				RADIX_DAX_ORDER(new_type), entry);
 		radix_tree_preload_end();
 		if (err) {
 			spin_unlock_irq(&mapping->tree_lock);
 			/* Someone already created the entry? */
-			if (err == -EEXIST)
+			if (err == -EEXIST && new_type == RADIX_DAX_PTE)
 				goto restart;
 			return ERR_PTR(err);
 		}
@@ -571,15 +586,15 @@ static int copy_user_bh(struct page *to, struct inode *inode,
 	return 0;
 }
 
-#define DAX_PMD_INDEX(page_index) (page_index & (PMD_MASK >> PAGE_SHIFT))
-
 static void *dax_insert_mapping_entry(struct address_space *mapping,
 				      struct vm_fault *vmf,
-				      void *entry, sector_t sector)
+				      void *entry, sector_t sector,
+				      unsigned long new_type, bool hzp)
 {
 	struct radix_tree_root *page_tree = &mapping->page_tree;
 	int error = 0;
 	bool hole_fill = false;
+	bool hzp_fill = false;
 	void *new_entry;
 	pgoff_t index = vmf->pgoff;
 
@@ -598,22 +613,30 @@ static void *dax_insert_mapping_entry(struct address_space *mapping,
 		error = radix_tree_preload(vmf->gfp_mask & ~__GFP_HIGHMEM);
 		if (error)
 			return ERR_PTR(error);
+	} else if ((unsigned long)entry & RADIX_DAX_HZP && !hzp) {
+		hzp_fill = true;
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
 
@@ -669,6 +692,18 @@ static int dax_writeback_one(struct block_device *bdev,
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
@@ -709,12 +744,11 @@ int dax_writeback_mapping_range(struct address_space *mapping,
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
@@ -724,15 +758,6 @@ int dax_writeback_mapping_range(struct address_space *mapping,
 
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
 
@@ -778,7 +803,8 @@ static int dax_insert_mapping(struct address_space *mapping,
 		return PTR_ERR(dax.addr);
 	dax_unmap_atomic(bdev, &dax);
 
-	ret = dax_insert_mapping_entry(mapping, vmf, entry, dax.sector);
+	ret = dax_insert_mapping_entry(mapping, vmf, entry, dax.sector,
+			RADIX_DAX_PTE, false);
 	if (IS_ERR(ret))
 		return PTR_ERR(ret);
 	*entryp = ret;
@@ -825,7 +851,7 @@ int dax_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
 	bh.b_bdev = inode->i_sb->s_bdev;
 	bh.b_size = PAGE_SIZE;
 
-	entry = grab_mapping_entry(mapping, vmf->pgoff);
+	entry = grab_mapping_entry(mapping, vmf->pgoff, RADIX_DAX_PTE);
 	if (IS_ERR(entry)) {
 		error = PTR_ERR(entry);
 		goto out;
@@ -929,9 +955,11 @@ int dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
 	bool write = flags & FAULT_FLAG_WRITE;
 	struct block_device *bdev;
 	pgoff_t size, pgoff;
+	struct vm_fault vmf;
 	sector_t block;
 	int result = 0;
-	bool alloc = false;
+	void *entry, *ret;
+
 
 	/* dax pmd mappings require pfn_t_devmap() */
 	if (!IS_ENABLED(CONFIG_FS_DAX_PMD))
@@ -953,6 +981,11 @@ int dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
 		return VM_FAULT_FALLBACK;
 	}
 
+	/*
+	 * Check whether offset isn't beyond end of file now. Caller is supposed
+	 * to hold locks serializing us with truncate / punch hole so this is
+	 * a reliable test.
+	 */
 	pgoff = linear_page_index(vma, pmd_addr);
 	size = (i_size_read(inode) + PAGE_SIZE - 1) >> PAGE_SHIFT;
 	if (pgoff >= size)
@@ -970,37 +1003,45 @@ int dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
 
 	bh.b_size = PMD_SIZE;
 
-	if (get_block(inode, block, &bh, 0) != 0)
-		return VM_FAULT_SIGBUS;
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
+	if (get_block(inode, block, &bh, 0) != 0) {
+		result = VM_FAULT_SIGBUS;
+		goto unlock_entry;
+	}
 
 	if (!buffer_mapped(&bh) && write) {
-		if (get_block(inode, block, &bh, 1) != 0)
-			return VM_FAULT_SIGBUS;
-		alloc = true;
-		WARN_ON_ONCE(buffer_unwritten(&bh) || buffer_new(&bh));
+		if (get_block(inode, block, &bh, 1) != 0) {
+			result = VM_FAULT_SIGBUS;
+			goto unlock_entry;
+		}
 	}
 
+	/* Filesystem should not return unwritten buffers to us! */
+	WARN_ON_ONCE(buffer_unwritten(&bh) || buffer_new(&bh));
+
 	bdev = bh.b_bdev;
 
 	if (bh.b_size < PMD_SIZE) {
 		dax_pmd_dbg(&bh, address, "allocated block too small");
-		return VM_FAULT_FALLBACK;
+		goto fallback;
 	}
 
-	/*
-	 * If we allocated new storage, make sure no process has any
-	 * zero pages covering this hole
-	 */
-	if (alloc) {
-		loff_t lstart = pgoff << PAGE_SHIFT;
-		loff_t lend = lstart + PMD_SIZE - 1; /* inclusive */
-
-		truncate_pagecache_range(inode, lstart, lend);
-	}
+	vmf.pgoff = pgoff;
+	vmf.flags = flags;
+	vmf.gfp_mask = mapping_gfp_mask(mapping) | __GFP_FS | __GFP_IO;
 
 	if (!write && !buffer_mapped(&bh)) {
 		spinlock_t *ptl;
-		pmd_t entry;
+		pmd_t pmd_entry;
 		struct page *zero_page = get_huge_zero_page();
 
 		if (unlikely(!zero_page)) {
@@ -1008,6 +1049,15 @@ int dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
 			goto fallback;
 		}
 
+		ret = dax_insert_mapping_entry(mapping, &vmf, entry,
+				0, RADIX_DAX_PMD, true);
+		if (IS_ERR(ret)) {
+			dax_pmd_dbg(&bh, address,
+					"PMD radix insertion failed");
+			goto fallback;
+		}
+		entry = ret;
+
 		ptl = pmd_lock(vma->vm_mm, pmd);
 		if (!pmd_none(*pmd)) {
 			spin_unlock(ptl);
@@ -1020,9 +1070,9 @@ int dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
 				__func__, current->comm, address,
 				(unsigned long long) to_sector(&bh, inode));
 
-		entry = mk_pmd(zero_page, vma->vm_page_prot);
-		entry = pmd_mkhuge(entry);
-		set_pmd_at(vma->vm_mm, pmd_addr, pmd, entry);
+		pmd_entry = mk_pmd(zero_page, vma->vm_page_prot);
+		pmd_entry = pmd_mkhuge(pmd_entry);
+		set_pmd_at(vma->vm_mm, pmd_addr, pmd, pmd_entry);
 		result = VM_FAULT_NOPAGE;
 		spin_unlock(ptl);
 	} else {
@@ -1054,27 +1104,14 @@ int dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
 		}
 		dax_unmap_atomic(bdev, &dax);
 
-		/*
-		 * For PTE faults we insert a radix tree entry for reads, and
-		 * leave it clean.  Then on the first write we dirty the radix
-		 * tree entry via the dax_pfn_mkwrite() path.  This sequence
-		 * allows the dax_pfn_mkwrite() call to be simpler and avoid a
-		 * call into get_block() to translate the pgoff to a sector in
-		 * order to be able to create a new radix tree entry.
-		 *
-		 * The PMD path doesn't have an equivalent to
-		 * dax_pfn_mkwrite(), though, so for a read followed by a
-		 * write we traverse all the way through dax_pmd_fault()
-		 * twice.  This means we can just skip inserting a radix tree
-		 * entry completely on the initial read and just wait until
-		 * the write to insert a dirty entry.
-		 */
-		if (write) {
-			/*
-			 * We should insert radix-tree entry and dirty it here.
-			 * For now this is broken...
-			 */
+		ret = dax_insert_mapping_entry(mapping, &vmf, entry,
+				dax.sector, RADIX_DAX_PMD, false);
+		if (IS_ERR(ret)) {
+			dax_pmd_dbg(&bh, address,
+					"PMD radix insertion failed");
+			goto fallback;
 		}
+		entry = ret;
 
 		dev_dbg(part_to_dev(bdev->bd_part),
 				"%s: %s addr: %lx pfn: %lx sect: %llx\n",
@@ -1085,13 +1122,14 @@ int dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
 				dax.pfn, write);
 	}
 
- out:
+ unlock_entry:
+	put_locked_mapping_entry(mapping, pgoff, entry);
 	return result;
 
  fallback:
 	count_vm_event(THP_FAULT_FALLBACK);
 	result = VM_FAULT_FALLBACK;
-	goto out;
+	goto unlock_entry;
 }
 EXPORT_SYMBOL_GPL(dax_pmd_fault);
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
diff --git a/include/linux/dax.h b/include/linux/dax.h
index 8bcb852..7151147 100644
--- a/include/linux/dax.h
+++ b/include/linux/dax.h
@@ -6,8 +6,33 @@
 #include <linux/radix-tree.h>
 #include <asm/pgtable.h>
 
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
 
 ssize_t dax_do_io(struct kiocb *, struct inode *, struct iov_iter *,
 		  get_block_t, dio_iodone_t, int flags);
diff --git a/mm/filemap.c b/mm/filemap.c
index 56c4ac7..1994a2a 100644
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
2.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
