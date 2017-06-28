Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id AD81A280301
	for <linux-mm@kvack.org>; Wed, 28 Jun 2017 18:02:57 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id t75so28269420pgb.0
        for <linux-mm@kvack.org>; Wed, 28 Jun 2017 15:02:57 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id y67si2379921pfy.16.2017.06.28.15.02.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Jun 2017 15:02:55 -0700 (PDT)
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: [PATCH v3 3/5] dax: use common 4k zero page for dax mmap reads
Date: Wed, 28 Jun 2017 16:01:50 -0600
Message-Id: <20170628220152.28161-4-ross.zwisler@linux.intel.com>
In-Reply-To: <20170628220152.28161-1-ross.zwisler@linux.intel.com>
References: <20170628220152.28161-1-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, "Darrick J. Wong" <darrick.wong@oracle.com>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Dave Hansen <dave.hansen@intel.com>, Ingo Molnar <mingo@redhat.com>, Jan Kara <jack@suse.cz>, Jonathan Corbet <corbet@lwn.net>, Matthew Wilcox <mawilcox@microsoft.com>, Steven Rostedt <rostedt@goodmis.org>, linux-doc@vger.kernel.org, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-xfs@vger.kernel.org

When servicing mmap() reads from file holes the current DAX code allocates
a page cache page of all zeroes and places the struct page pointer in the
mapping->page_tree radix tree.  This has three major drawbacks:

1) It consumes memory unnecessarily.  For every 4k page that is read via a
DAX mmap() over a hole, we allocate a new page cache page.  This means that
if you read 1GiB worth of pages, you end up using 1GiB of zeroed memory.
This is easily visible by looking at the overall memory consumption of the
system or by looking at /proc/[pid]/smaps:

	7f62e72b3000-7f63272b3000 rw-s 00000000 103:00 12   /root/dax/data
	Size:            1048576 kB
	Rss:             1048576 kB
	Pss:             1048576 kB
	Shared_Clean:          0 kB
	Shared_Dirty:          0 kB
	Private_Clean:   1048576 kB
	Private_Dirty:         0 kB
	Referenced:      1048576 kB
	Anonymous:             0 kB
	LazyFree:              0 kB
	AnonHugePages:         0 kB
	ShmemPmdMapped:        0 kB
	Shared_Hugetlb:        0 kB
	Private_Hugetlb:       0 kB
	Swap:                  0 kB
	SwapPss:               0 kB
	KernelPageSize:        4 kB
	MMUPageSize:           4 kB
	Locked:                0 kB

2) It is slower than using a common zero page because each page fault has
more work to do.  Instead of just inserting a common zero page we have to
allocate a page cache page, zero it, and then insert it.  Here are the
average latencies of dax_load_hole() as measured by ftrace on a random test
box:

Old method, using zeroed page cache pages:	3.4 us
New method, using the common 4k zero page:	0.8 us

This was the average latency over 1 GiB of sequential reads done by this
simple fio script:

  [global]
  size=1G
  filename=/root/dax/data
  fallocate=none
  [io]
  rw=read
  ioengine=mmap

3) The fact that we had to check for both DAX exceptional entries and for
page cache pages in the radix tree made the DAX code more complex.

Solve these issues by following the lead of the DAX PMD code and using a
common 4k zero page instead.  As with the PMD code we will now insert a DAX
exceptional entry into the radix tree instead of a struct page pointer
which allows us to remove all the special casing in the DAX code.

Note that we do still pretty aggressively check for regular pages in the
DAX radix tree, especially where we take action based on the bits set in
the page.  If we ever find a regular page in our radix tree now that most
likely means that someone besides DAX is inserting pages (which has
happened lots of times in the past), and we want to find that out early and
fail loudly.

This solution also removes the extra memory consumption.  Here is that same
/proc/[pid]/smaps after 1GiB of reading from a hole with the new code:

	7f2054a74000-7f2094a74000 rw-s 00000000 103:00 12   /root/dax/data
	Size:            1048576 kB
	Rss:                   0 kB
	Pss:                   0 kB
	Shared_Clean:          0 kB
	Shared_Dirty:          0 kB
	Private_Clean:         0 kB
	Private_Dirty:         0 kB
	Referenced:            0 kB
	Anonymous:             0 kB
	LazyFree:              0 kB
	AnonHugePages:         0 kB
	ShmemPmdMapped:        0 kB
	Shared_Hugetlb:        0 kB
	Private_Hugetlb:       0 kB
	Swap:                  0 kB
	SwapPss:               0 kB
	KernelPageSize:        4 kB
	MMUPageSize:           4 kB
	Locked:                0 kB

Overall system memory consumption is similarly improved.

Another major change is that we remove dax_pfn_mkwrite() from our fault
flow, and instead rely on the page fault itself to make the PTE dirty and
writeable.  The following description from the patch adding the
vm_insert_mixed_mkwrite() call explains this a little more:

***
  To be able to use the common 4k zero page in DAX we need to have our PTE
  fault path look more like our PMD fault path where a PTE entry can be
  marked as dirty and writeable as it is first inserted, rather than
  waiting for a follow-up dax_pfn_mkwrite() => finish_mkwrite_fault() call.

  Right now we can rely on having a dax_pfn_mkwrite() call because we can
  distinguish between these two cases in do_wp_page():

  	case 1: 4k zero page => writable DAX storage
  	case 2: read-only DAX storage => writeable DAX storage

  This distinction is made by via vm_normal_page().  vm_normal_page()
  returns false for the common 4k zero page, though, just as it does for
  DAX ptes.  Instead of special casing the DAX + 4k zero page case, we will
  simplify our DAX PTE page fault sequence so that it matches our DAX PMD
  sequence, and get rid of dax_pfn_mkwrite() completely.

  This means that insert_pfn() needs to follow the lead of insert_pfn_pmd()
  and allow us to pass in a 'mkwrite' flag.  If 'mkwrite' is set
  insert_pfn() will do the work that was previously done by wp_page_reuse()
  as part of the dax_pfn_mkwrite() call path.
***

Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
---
 Documentation/filesystems/dax.txt |   5 +-
 fs/dax.c                          | 243 ++++++++++++--------------------------
 fs/ext2/file.c                    |  25 +---
 fs/ext4/file.c                    |  32 +----
 fs/xfs/xfs_file.c                 |   2 +-
 include/linux/dax.h               |  13 +-
 include/trace/events/fs_dax.h     |   2 -
 7 files changed, 86 insertions(+), 236 deletions(-)

diff --git a/Documentation/filesystems/dax.txt b/Documentation/filesystems/dax.txt
index a7e6e14..3be3b26 100644
--- a/Documentation/filesystems/dax.txt
+++ b/Documentation/filesystems/dax.txt
@@ -63,9 +63,8 @@ Filesystem support consists of
 - implementing an mmap file operation for DAX files which sets the
   VM_MIXEDMAP and VM_HUGEPAGE flags on the VMA, and setting the vm_ops to
   include handlers for fault, pmd_fault, page_mkwrite, pfn_mkwrite. These
-  handlers should probably call dax_iomap_fault() (for fault and page_mkwrite
-  handlers), dax_iomap_pmd_fault(), dax_pfn_mkwrite() passing the appropriate
-  iomap operations.
+  handlers should probably call dax_iomap_fault() passing the appropriate
+  fault size and iomap operations.
 - calling iomap_zero_range() passing appropriate iomap operations instead of
   block_truncate_page() for DAX files
 - ensuring that there is sufficient locking between reads, writes,
diff --git a/fs/dax.c b/fs/dax.c
index e850837..01e81d228 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -67,7 +67,7 @@ static int dax_is_pte_entry(void *entry)
 
 static int dax_is_zero_entry(void *entry)
 {
-	return (unsigned long)entry & RADIX_DAX_HZP;
+	return (unsigned long)entry & RADIX_DAX_ZERO_PAGE;
 }
 
 static int dax_is_empty_entry(void *entry)
@@ -207,7 +207,8 @@ static void *get_unlocked_mapping_entry(struct address_space *mapping,
 	for (;;) {
 		entry = __radix_tree_lookup(&mapping->page_tree, index, NULL,
 					  &slot);
-		if (!entry || !radix_tree_exceptional_entry(entry) ||
+		if (!entry ||
+		    WARN_ON_ONCE(!radix_tree_exceptional_entry(entry)) ||
 		    !slot_locked(mapping, slot)) {
 			if (slotp)
 				*slotp = slot;
@@ -242,14 +243,9 @@ static void dax_unlock_mapping_entry(struct address_space *mapping,
 }
 
 static void put_locked_mapping_entry(struct address_space *mapping,
-				     pgoff_t index, void *entry)
+		pgoff_t index)
 {
-	if (!radix_tree_exceptional_entry(entry)) {
-		unlock_page(entry);
-		put_page(entry);
-	} else {
-		dax_unlock_mapping_entry(mapping, index);
-	}
+	dax_unlock_mapping_entry(mapping, index);
 }
 
 /*
@@ -259,7 +255,7 @@ static void put_locked_mapping_entry(struct address_space *mapping,
 static void put_unlocked_mapping_entry(struct address_space *mapping,
 				       pgoff_t index, void *entry)
 {
-	if (!radix_tree_exceptional_entry(entry))
+	if (!entry)
 		return;
 
 	/* We have to wake up next waiter for the radix tree entry lock */
@@ -267,15 +263,15 @@ static void put_unlocked_mapping_entry(struct address_space *mapping,
 }
 
 /*
- * Find radix tree entry at given index. If it points to a page, return with
- * the page locked. If it points to the exceptional entry, return with the
- * radix tree entry locked. If the radix tree doesn't contain given index,
- * create empty exceptional entry for the index and return with it locked.
+ * Find radix tree entry at given index. If it points to an exceptional entry,
+ * return it with the radix tree entry locked. If the radix tree doesn't
+ * contain given index, create an empty exceptional entry for the index and
+ * return with it locked.
  *
  * When requesting an entry with size RADIX_DAX_PMD, grab_mapping_entry() will
  * either return that locked entry or will return an error.  This error will
- * happen if there are any 4k entries (either zero pages or DAX entries)
- * within the 2MiB range that we are requesting.
+ * happen if there are any 4k entries within the 2MiB range that we are
+ * requesting.
  *
  * We always favor 4k entries over 2MiB entries. There isn't a flow where we
  * evict 4k entries in order to 'upgrade' them to a 2MiB entry.  A 2MiB
@@ -302,18 +298,21 @@ static void *grab_mapping_entry(struct address_space *mapping, pgoff_t index,
 	spin_lock_irq(&mapping->tree_lock);
 	entry = get_unlocked_mapping_entry(mapping, index, &slot);
 
+	if (WARN_ON_ONCE(entry && !radix_tree_exceptional_entry(entry))) {
+		entry = ERR_PTR(-EIO);
+		goto out_unlock;
+	}
+
 	if (entry) {
 		if (size_flag & RADIX_DAX_PMD) {
-			if (!radix_tree_exceptional_entry(entry) ||
-			    dax_is_pte_entry(entry)) {
+			if (dax_is_pte_entry(entry)) {
 				put_unlocked_mapping_entry(mapping, index,
 						entry);
 				entry = ERR_PTR(-EEXIST);
 				goto out_unlock;
 			}
 		} else { /* trying to grab a PTE entry */
-			if (radix_tree_exceptional_entry(entry) &&
-			    dax_is_pmd_entry(entry) &&
+			if (dax_is_pmd_entry(entry) &&
 			    (dax_is_zero_entry(entry) ||
 			     dax_is_empty_entry(entry))) {
 				pmd_downgrade = true;
@@ -347,7 +346,7 @@ static void *grab_mapping_entry(struct address_space *mapping, pgoff_t index,
 				mapping_gfp_mask(mapping) & ~__GFP_HIGHMEM);
 		if (err) {
 			if (pmd_downgrade)
-				put_locked_mapping_entry(mapping, index, entry);
+				put_locked_mapping_entry(mapping, index);
 			return ERR_PTR(err);
 		}
 		spin_lock_irq(&mapping->tree_lock);
@@ -397,21 +396,6 @@ static void *grab_mapping_entry(struct address_space *mapping, pgoff_t index,
 		spin_unlock_irq(&mapping->tree_lock);
 		return entry;
 	}
-	/* Normal page in radix tree? */
-	if (!radix_tree_exceptional_entry(entry)) {
-		struct page *page = entry;
-
-		get_page(page);
-		spin_unlock_irq(&mapping->tree_lock);
-		lock_page(page);
-		/* Page got truncated? Retry... */
-		if (unlikely(page->mapping != mapping)) {
-			unlock_page(page);
-			put_page(page);
-			goto restart;
-		}
-		return page;
-	}
 	entry = lock_slot(mapping, slot);
  out_unlock:
 	spin_unlock_irq(&mapping->tree_lock);
@@ -427,7 +411,7 @@ static int __dax_invalidate_mapping_entry(struct address_space *mapping,
 
 	spin_lock_irq(&mapping->tree_lock);
 	entry = get_unlocked_mapping_entry(mapping, index, NULL);
-	if (!entry || !radix_tree_exceptional_entry(entry))
+	if (!entry || WARN_ON_ONCE(!radix_tree_exceptional_entry(entry)))
 		goto out;
 	if (!trunc &&
 	    (radix_tree_tag_get(page_tree, index, PAGECACHE_TAG_DIRTY) ||
@@ -509,47 +493,27 @@ static void *dax_insert_mapping_entry(struct address_space *mapping,
 				      unsigned long flags)
 {
 	struct radix_tree_root *page_tree = &mapping->page_tree;
-	int error = 0;
-	bool hole_fill = false;
 	void *new_entry;
 	pgoff_t index = vmf->pgoff;
 
 	if (vmf->flags & FAULT_FLAG_WRITE)
 		__mark_inode_dirty(mapping->host, I_DIRTY_PAGES);
 
-	/* Replacing hole page with block mapping? */
-	if (!radix_tree_exceptional_entry(entry)) {
-		hole_fill = true;
-		/*
-		 * Unmap the page now before we remove it from page cache below.
-		 * The page is locked so it cannot be faulted in again.
-		 */
-		unmap_mapping_range(mapping, vmf->pgoff << PAGE_SHIFT,
-				    PAGE_SIZE, 0);
-		error = radix_tree_preload(vmf->gfp_mask & ~__GFP_HIGHMEM);
-		if (error)
-			return ERR_PTR(error);
-	} else if (dax_is_zero_entry(entry) && !(flags & RADIX_DAX_HZP)) {
-		/* replacing huge zero page with PMD block mapping */
-		unmap_mapping_range(mapping,
-			(vmf->pgoff << PAGE_SHIFT) & PMD_MASK, PMD_SIZE, 0);
+	if (dax_is_zero_entry(entry) && !(flags & RADIX_DAX_ZERO_PAGE)) {
+		/* we are replacing a zero page with block mapping */
+		if (dax_is_pmd_entry(entry))
+			unmap_mapping_range(mapping,
+					(vmf->pgoff << PAGE_SHIFT) & PMD_MASK,
+					PMD_SIZE, 0);
+		else /* pte entry */
+			unmap_mapping_range(mapping, vmf->pgoff << PAGE_SHIFT,
+					PAGE_SIZE, 0);
 	}
 
 	spin_lock_irq(&mapping->tree_lock);
 	new_entry = dax_radix_locked_entry(sector, flags);
 
-	if (hole_fill) {
-		__delete_from_page_cache(entry, NULL);
-		/* Drop pagecache reference */
-		put_page(entry);
-		error = __radix_tree_insert(page_tree, index,
-				dax_radix_order(new_entry), new_entry);
-		if (error) {
-			new_entry = ERR_PTR(error);
-			goto unlock;
-		}
-		mapping->nrexceptional++;
-	} else if (dax_is_zero_entry(entry) || dax_is_empty_entry(entry)) {
+	if (dax_is_zero_entry(entry) || dax_is_empty_entry(entry)) {
 		/*
 		 * Only swap our new entry into the radix tree if the current
 		 * entry is a zero page or an empty entry.  If a normal PTE or
@@ -566,23 +530,14 @@ static void *dax_insert_mapping_entry(struct address_space *mapping,
 		WARN_ON_ONCE(ret != entry);
 		__radix_tree_replace(page_tree, node, slot,
 				     new_entry, NULL, NULL);
+		entry = new_entry;
 	}
+
 	if (vmf->flags & FAULT_FLAG_WRITE)
 		radix_tree_tag_set(page_tree, index, PAGECACHE_TAG_DIRTY);
- unlock:
+
 	spin_unlock_irq(&mapping->tree_lock);
-	if (hole_fill) {
-		radix_tree_preload_end();
-		/*
-		 * We don't need hole page anymore, it has been replaced with
-		 * locked radix tree entry now.
-		 */
-		if (mapping->a_ops->freepage)
-			mapping->a_ops->freepage(entry);
-		unlock_page(entry);
-		put_page(entry);
-	}
-	return new_entry;
+	return entry;
 }
 
 static inline unsigned long
@@ -681,7 +636,7 @@ static int dax_writeback_one(struct block_device *bdev,
 	spin_lock_irq(&mapping->tree_lock);
 	entry2 = get_unlocked_mapping_entry(mapping, index, &slot);
 	/* Entry got punched out / reallocated? */
-	if (!entry2 || !radix_tree_exceptional_entry(entry2))
+	if (!entry2 || WARN_ON_ONCE(!radix_tree_exceptional_entry(entry2)))
 		goto put_unlocked;
 	/*
 	 * Entry got reallocated elsewhere? No need to writeback. We have to
@@ -753,7 +708,7 @@ static int dax_writeback_one(struct block_device *bdev,
 	trace_dax_writeback_one(mapping->host, index, size >> PAGE_SHIFT);
  dax_unlock:
 	dax_read_unlock(id);
-	put_locked_mapping_entry(mapping, index, entry);
+	put_locked_mapping_entry(mapping, index);
 	return ret;
 
  put_unlocked:
@@ -826,11 +781,10 @@ EXPORT_SYMBOL_GPL(dax_writeback_mapping_range);
 
 static int dax_insert_mapping(struct address_space *mapping,
 		struct block_device *bdev, struct dax_device *dax_dev,
-		sector_t sector, size_t size, void **entryp,
+		sector_t sector, size_t size, void *entry,
 		struct vm_area_struct *vma, struct vm_fault *vmf)
 {
 	unsigned long vaddr = vmf->address;
-	void *entry = *entryp;
 	void *ret, *kaddr;
 	pgoff_t pgoff;
 	int id, rc;
@@ -851,87 +805,44 @@ static int dax_insert_mapping(struct address_space *mapping,
 	ret = dax_insert_mapping_entry(mapping, vmf, entry, sector, 0);
 	if (IS_ERR(ret))
 		return PTR_ERR(ret);
-	*entryp = ret;
 
 	trace_dax_insert_mapping(mapping->host, vmf, ret);
-	return vm_insert_mixed(vma, vaddr, pfn);
-}
-
-/**
- * dax_pfn_mkwrite - handle first write to DAX page
- * @vmf: The description of the fault
- */
-int dax_pfn_mkwrite(struct vm_fault *vmf)
-{
-	struct file *file = vmf->vma->vm_file;
-	struct address_space *mapping = file->f_mapping;
-	struct inode *inode = mapping->host;
-	void *entry, **slot;
-	pgoff_t index = vmf->pgoff;
-
-	spin_lock_irq(&mapping->tree_lock);
-	entry = get_unlocked_mapping_entry(mapping, index, &slot);
-	if (!entry || !radix_tree_exceptional_entry(entry)) {
-		if (entry)
-			put_unlocked_mapping_entry(mapping, index, entry);
-		spin_unlock_irq(&mapping->tree_lock);
-		trace_dax_pfn_mkwrite_no_entry(inode, vmf, VM_FAULT_NOPAGE);
-		return VM_FAULT_NOPAGE;
-	}
-	radix_tree_tag_set(&mapping->page_tree, index, PAGECACHE_TAG_DIRTY);
-	entry = lock_slot(mapping, slot);
-	spin_unlock_irq(&mapping->tree_lock);
-	/*
-	 * If we race with somebody updating the PTE and finish_mkwrite_fault()
-	 * fails, we don't care. We need to return VM_FAULT_NOPAGE and retry
-	 * the fault in either case.
-	 */
-	finish_mkwrite_fault(vmf);
-	put_locked_mapping_entry(mapping, index, entry);
-	trace_dax_pfn_mkwrite(inode, vmf, VM_FAULT_NOPAGE);
-	return VM_FAULT_NOPAGE;
+	if (vmf->flags & FAULT_FLAG_WRITE)
+		return vm_insert_mixed_mkwrite(vma, vaddr, pfn);
+	else
+		return vm_insert_mixed(vma, vaddr, pfn);
 }
-EXPORT_SYMBOL_GPL(dax_pfn_mkwrite);
 
 /*
- * The user has performed a load from a hole in the file.  Allocating
- * a new page in the file would cause excessive storage usage for
- * workloads with sparse files.  We allocate a page cache page instead.
- * We'll kick it out of the page cache if it's ever written to,
- * otherwise it will simply fall out of the page cache under memory
- * pressure without ever having been dirtied.
+ * The user has performed a load from a hole in the file.  Allocating a new
+ * page in the file would cause excessive storage usage for workloads with
+ * sparse files.  Instead we insert a read-only mapping of the 4k zero page.
+ * If this page is ever written to we will re-fault and change the mapping to
+ * point to real DAX storage instead.
  */
-static int dax_load_hole(struct address_space *mapping, void **entry,
+static int dax_load_hole(struct address_space *mapping, void *entry,
 			 struct vm_fault *vmf)
 {
 	struct inode *inode = mapping->host;
-	struct page *page;
-	int ret;
-
-	/* Hole page already exists? Return it...  */
-	if (!radix_tree_exceptional_entry(*entry)) {
-		page = *entry;
-		goto finish_fault;
-	}
+	unsigned long vaddr = vmf->address;
+	int ret = VM_FAULT_NOPAGE;
+	struct page *zero_page;
+	void *entry2;
 
-	/* This will replace locked radix tree entry with a hole page */
-	page = find_or_create_page(mapping, vmf->pgoff,
-				   vmf->gfp_mask | __GFP_ZERO);
-	if (!page) {
+	zero_page = ZERO_PAGE(0);
+	if (unlikely(!zero_page)) {
 		ret = VM_FAULT_OOM;
 		goto out;
 	}
 
-finish_fault:
-	vmf->page = page;
-	ret = finish_fault(vmf);
-	vmf->page = NULL;
-	*entry = page;
-	if (!ret) {
-		/* Grab reference for PTE that is now referencing the page */
-		get_page(page);
-		ret = VM_FAULT_NOPAGE;
+	entry2 = dax_insert_mapping_entry(mapping, vmf, entry, 0,
+			RADIX_DAX_ZERO_PAGE);
+	if (IS_ERR(entry2)) {
+		ret = VM_FAULT_SIGBUS;
+		goto out;
 	}
+
+	vm_insert_mixed(vmf->vma, vaddr, page_to_pfn_t(zero_page));
 out:
 	trace_dax_load_hole(inode, vmf, ret);
 	return ret;
@@ -1217,7 +1128,7 @@ static int dax_iomap_pte_fault(struct vm_fault *vmf,
 			major = VM_FAULT_MAJOR;
 		}
 		error = dax_insert_mapping(mapping, iomap.bdev, iomap.dax_dev,
-				sector, PAGE_SIZE, &entry, vmf->vma, vmf);
+				sector, PAGE_SIZE, entry, vmf->vma, vmf);
 		/* -EBUSY is fine, somebody else faulted on the same PTE */
 		if (error == -EBUSY)
 			error = 0;
@@ -1225,7 +1136,7 @@ static int dax_iomap_pte_fault(struct vm_fault *vmf,
 	case IOMAP_UNWRITTEN:
 	case IOMAP_HOLE:
 		if (!(vmf->flags & FAULT_FLAG_WRITE)) {
-			vmf_ret = dax_load_hole(mapping, &entry, vmf);
+			vmf_ret = dax_load_hole(mapping, entry, vmf);
 			goto finish_iomap;
 		}
 		/*FALLTHRU*/
@@ -1252,7 +1163,7 @@ static int dax_iomap_pte_fault(struct vm_fault *vmf,
 		ops->iomap_end(inode, pos, PAGE_SIZE, copied, flags, &iomap);
 	}
  unlock_entry:
-	put_locked_mapping_entry(mapping, vmf->pgoff, entry);
+	put_locked_mapping_entry(mapping, vmf->pgoff);
  out:
 	trace_dax_pte_fault_done(inode, vmf, vmf_ret);
 	return vmf_ret;
@@ -1266,7 +1177,7 @@ static int dax_iomap_pte_fault(struct vm_fault *vmf,
 #define PG_PMD_COLOUR	((PMD_SIZE >> PAGE_SHIFT) - 1)
 
 static int dax_pmd_insert_mapping(struct vm_fault *vmf, struct iomap *iomap,
-		loff_t pos, void **entryp)
+		loff_t pos, void *entry)
 {
 	struct address_space *mapping = vmf->vma->vm_file->f_mapping;
 	const sector_t sector = dax_iomap_sector(iomap, pos);
@@ -1297,11 +1208,10 @@ static int dax_pmd_insert_mapping(struct vm_fault *vmf, struct iomap *iomap,
 		goto unlock_fallback;
 	dax_read_unlock(id);
 
-	ret = dax_insert_mapping_entry(mapping, vmf, *entryp, sector,
+	ret = dax_insert_mapping_entry(mapping, vmf, entry, sector,
 			RADIX_DAX_PMD);
 	if (IS_ERR(ret))
 		goto fallback;
-	*entryp = ret;
 
 	trace_dax_pmd_insert_mapping(inode, vmf, length, pfn, ret);
 	return vmf_insert_pfn_pmd(vmf->vma, vmf->address, vmf->pmd,
@@ -1315,7 +1225,7 @@ static int dax_pmd_insert_mapping(struct vm_fault *vmf, struct iomap *iomap,
 }
 
 static int dax_pmd_load_hole(struct vm_fault *vmf, struct iomap *iomap,
-		void **entryp)
+		void *entry)
 {
 	struct address_space *mapping = vmf->vma->vm_file->f_mapping;
 	unsigned long pmd_addr = vmf->address & PMD_MASK;
@@ -1330,11 +1240,10 @@ static int dax_pmd_load_hole(struct vm_fault *vmf, struct iomap *iomap,
 	if (unlikely(!zero_page))
 		goto fallback;
 
-	ret = dax_insert_mapping_entry(mapping, vmf, *entryp, 0,
-			RADIX_DAX_PMD | RADIX_DAX_HZP);
+	ret = dax_insert_mapping_entry(mapping, vmf, entry, 0,
+			RADIX_DAX_PMD | RADIX_DAX_ZERO_PAGE);
 	if (IS_ERR(ret))
 		goto fallback;
-	*entryp = ret;
 
 	ptl = pmd_lock(vmf->vma->vm_mm, vmf->pmd);
 	if (!pmd_none(*(vmf->pmd))) {
@@ -1400,10 +1309,10 @@ static int dax_iomap_pmd_fault(struct vm_fault *vmf,
 		goto fallback;
 
 	/*
-	 * grab_mapping_entry() will make sure we get a 2M empty entry, a DAX
-	 * PMD or a HZP entry.  If it can't (because a 4k page is already in
-	 * the tree, for instance), it will return -EEXIST and we just fall
-	 * back to 4k entries.
+	 * grab_mapping_entry() will make sure we get a 2MiB empty entry, a
+	 * 2MiB zero page entry or a DAX PMD.  If it can't (because a 4k page
+	 * is already in the tree, for instance), it will return -EEXIST and
+	 * we just fall back to 4k entries.
 	 */
 	entry = grab_mapping_entry(mapping, pgoff, RADIX_DAX_PMD);
 	if (IS_ERR(entry))
@@ -1436,13 +1345,13 @@ static int dax_iomap_pmd_fault(struct vm_fault *vmf,
 
 	switch (iomap.type) {
 	case IOMAP_MAPPED:
-		result = dax_pmd_insert_mapping(vmf, &iomap, pos, &entry);
+		result = dax_pmd_insert_mapping(vmf, &iomap, pos, entry);
 		break;
 	case IOMAP_UNWRITTEN:
 	case IOMAP_HOLE:
 		if (WARN_ON_ONCE(write))
 			break;
-		result = dax_pmd_load_hole(vmf, &iomap, &entry);
+		result = dax_pmd_load_hole(vmf, &iomap, entry);
 		break;
 	default:
 		WARN_ON_ONCE(1);
@@ -1465,7 +1374,7 @@ static int dax_iomap_pmd_fault(struct vm_fault *vmf,
 				&iomap);
 	}
  unlock_entry:
-	put_locked_mapping_entry(mapping, pgoff, entry);
+	put_locked_mapping_entry(mapping, pgoff);
  fallback:
 	if (result == VM_FAULT_FALLBACK) {
 		split_huge_pmd(vma, vmf->pmd, vmf->address);
diff --git a/fs/ext2/file.c b/fs/ext2/file.c
index b21891a..96254f0 100644
--- a/fs/ext2/file.c
+++ b/fs/ext2/file.c
@@ -107,29 +107,6 @@ static int ext2_dax_fault(struct vm_fault *vmf)
 	return ret;
 }
 
-static int ext2_dax_pfn_mkwrite(struct vm_fault *vmf)
-{
-	struct inode *inode = file_inode(vmf->vma->vm_file);
-	struct ext2_inode_info *ei = EXT2_I(inode);
-	loff_t size;
-	int ret;
-
-	sb_start_pagefault(inode->i_sb);
-	file_update_time(vmf->vma->vm_file);
-	down_read(&ei->dax_sem);
-
-	/* check that the faulting page hasn't raced with truncate */
-	size = (i_size_read(inode) + PAGE_SIZE - 1) >> PAGE_SHIFT;
-	if (vmf->pgoff >= size)
-		ret = VM_FAULT_SIGBUS;
-	else
-		ret = dax_pfn_mkwrite(vmf);
-
-	up_read(&ei->dax_sem);
-	sb_end_pagefault(inode->i_sb);
-	return ret;
-}
-
 static const struct vm_operations_struct ext2_dax_vm_ops = {
 	.fault		= ext2_dax_fault,
 	/*
@@ -138,7 +115,7 @@ static const struct vm_operations_struct ext2_dax_vm_ops = {
 	 * will always fail and fail back to regular faults.
 	 */
 	.page_mkwrite	= ext2_dax_fault,
-	.pfn_mkwrite	= ext2_dax_pfn_mkwrite,
+	.pfn_mkwrite	= ext2_dax_fault,
 };
 
 static int ext2_file_mmap(struct file *file, struct vm_area_struct *vma)
diff --git a/fs/ext4/file.c b/fs/ext4/file.c
index 02ce7e7..0c5fdcd 100644
--- a/fs/ext4/file.c
+++ b/fs/ext4/file.c
@@ -292,41 +292,11 @@ static int ext4_dax_fault(struct vm_fault *vmf)
 	return ext4_dax_huge_fault(vmf, PE_SIZE_PTE);
 }
 
-/*
- * Handle write fault for VM_MIXEDMAP mappings. Similarly to ext4_dax_fault()
- * handler we check for races agaist truncate. Note that since we cycle through
- * i_mmap_sem, we are sure that also any hole punching that began before we
- * were called is finished by now and so if it included part of the file we
- * are working on, our pte will get unmapped and the check for pte_same() in
- * wp_pfn_shared() fails. Thus fault gets retried and things work out as
- * desired.
- */
-static int ext4_dax_pfn_mkwrite(struct vm_fault *vmf)
-{
-	struct inode *inode = file_inode(vmf->vma->vm_file);
-	struct super_block *sb = inode->i_sb;
-	loff_t size;
-	int ret;
-
-	sb_start_pagefault(sb);
-	file_update_time(vmf->vma->vm_file);
-	down_read(&EXT4_I(inode)->i_mmap_sem);
-	size = (i_size_read(inode) + PAGE_SIZE - 1) >> PAGE_SHIFT;
-	if (vmf->pgoff >= size)
-		ret = VM_FAULT_SIGBUS;
-	else
-		ret = dax_pfn_mkwrite(vmf);
-	up_read(&EXT4_I(inode)->i_mmap_sem);
-	sb_end_pagefault(sb);
-
-	return ret;
-}
-
 static const struct vm_operations_struct ext4_dax_vm_ops = {
 	.fault		= ext4_dax_fault,
 	.huge_fault	= ext4_dax_huge_fault,
 	.page_mkwrite	= ext4_dax_fault,
-	.pfn_mkwrite	= ext4_dax_pfn_mkwrite,
+	.pfn_mkwrite	= ext4_dax_fault,
 };
 #else
 #define ext4_dax_vm_ops	ext4_file_vm_ops
diff --git a/fs/xfs/xfs_file.c b/fs/xfs/xfs_file.c
index 5fb5a09..1b5d771 100644
--- a/fs/xfs/xfs_file.c
+++ b/fs/xfs/xfs_file.c
@@ -1456,7 +1456,7 @@ xfs_filemap_pfn_mkwrite(
 	if (vmf->pgoff >= size)
 		ret = VM_FAULT_SIGBUS;
 	else if (IS_DAX(inode))
-		ret = dax_pfn_mkwrite(vmf);
+		ret = dax_iomap_fault(vmf, PE_SIZE_PTE, &xfs_iomap_ops);
 	xfs_iunlock(ip, XFS_MMAPLOCK_SHARED);
 	sb_end_pagefault(inode->i_sb);
 	return ret;
diff --git a/include/linux/dax.h b/include/linux/dax.h
index 5ec1f6c..8352ce1a 100644
--- a/include/linux/dax.h
+++ b/include/linux/dax.h
@@ -78,18 +78,17 @@ long dax_direct_access(struct dax_device *dax_dev, pgoff_t pgoff, long nr_pages,
 
 /*
  * We use lowest available bit in exceptional entry for locking, one bit for
- * the entry size (PMD) and two more to tell us if the entry is a huge zero
- * page (HZP) or an empty entry that is just used for locking.  In total four
- * special bits.
+ * the entry size (PMD) and two more to tell us if the entry is a zero page or
+ * an empty entry that is just used for locking.  In total four special bits.
  *
- * If the PMD bit isn't set the entry has size PAGE_SIZE, and if the HZP and
- * EMPTY bits aren't set the entry is a normal DAX entry with a filesystem
+ * If the PMD bit isn't set the entry has size PAGE_SIZE, and if the ZERO_PAGE
+ * and EMPTY bits aren't set the entry is a normal DAX entry with a filesystem
  * block allocation.
  */
 #define RADIX_DAX_SHIFT	(RADIX_TREE_EXCEPTIONAL_SHIFT + 4)
 #define RADIX_DAX_ENTRY_LOCK (1 << RADIX_TREE_EXCEPTIONAL_SHIFT)
 #define RADIX_DAX_PMD (1 << (RADIX_TREE_EXCEPTIONAL_SHIFT + 1))
-#define RADIX_DAX_HZP (1 << (RADIX_TREE_EXCEPTIONAL_SHIFT + 2))
+#define RADIX_DAX_ZERO_PAGE (1 << (RADIX_TREE_EXCEPTIONAL_SHIFT + 2))
 #define RADIX_DAX_EMPTY (1 << (RADIX_TREE_EXCEPTIONAL_SHIFT + 3))
 
 static inline unsigned long dax_radix_sector(void *entry)
@@ -140,8 +139,6 @@ static inline unsigned int dax_radix_order(void *entry)
 	return 0;
 }
 #endif
-int dax_pfn_mkwrite(struct vm_fault *vmf);
-
 static inline bool vma_is_dax(struct vm_area_struct *vma)
 {
 	return vma->vm_file && IS_DAX(vma->vm_file->f_mapping->host);
diff --git a/include/trace/events/fs_dax.h b/include/trace/events/fs_dax.h
index 08bb3ed..fbc4a06 100644
--- a/include/trace/events/fs_dax.h
+++ b/include/trace/events/fs_dax.h
@@ -190,8 +190,6 @@ DEFINE_EVENT(dax_pte_fault_class, name, \
 
 DEFINE_PTE_FAULT_EVENT(dax_pte_fault);
 DEFINE_PTE_FAULT_EVENT(dax_pte_fault_done);
-DEFINE_PTE_FAULT_EVENT(dax_pfn_mkwrite_no_entry);
-DEFINE_PTE_FAULT_EVENT(dax_pfn_mkwrite);
 DEFINE_PTE_FAULT_EVENT(dax_load_hole);
 
 TRACE_EVENT(dax_insert_mapping,
-- 
2.9.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
