Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 8F6B182F6B
	for <linux-mm@kvack.org>; Mon,  5 Oct 2015 16:33:04 -0400 (EDT)
Received: by pacfv12 with SMTP id fv12so190187802pac.2
        for <linux-mm@kvack.org>; Mon, 05 Oct 2015 13:33:04 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id yn6si42788136pab.112.2015.10.05.13.33.03
        for <linux-mm@kvack.org>;
        Mon, 05 Oct 2015 13:33:03 -0700 (PDT)
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: [PATCH v3 1/3] Revert "mm: take i_mmap_lock in unmap_mapping_range() for DAX"
Date: Mon,  5 Oct 2015 14:32:52 -0600
Message-Id: <1444077174-22016-2-git-send-email-ross.zwisler@linux.intel.com>
In-Reply-To: <1444077174-22016-1-git-send-email-ross.zwisler@linux.intel.com>
References: <1444077174-22016-1-git-send-email-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Matthew Wilcox <willy@linux.intel.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-nvdimm@lists.01.org

This reverts commits 46c043ede4711e8d598b9d63c5616c1fedb0605e
and 8346c416d17bf5b4ea1508662959bb62e73fd6a5.

The following two locking commits in the DAX code:

commit 843172978bb9 ("dax: fix race between simultaneous faults")
commit 46c043ede471 ("mm: take i_mmap_lock in unmap_mapping_range() for DAX")

introduced a number of deadlocks and other issues, and need to be
reverted for the v4.3 kernel. The list of issues in DAX after these
commits (some newly introduced by the commits, some preexisting) can be
found here:

https://lkml.org/lkml/2015/9/25/602

This revert keeps the PMEM API changes to the zeroing code in
__dax_pmd_fault(), which were added by this commit:

commit d77e92e270ed ("dax: update PMD fault handler with PMEM API")

Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
---
 fs/dax.c    | 50 ++++++++++++++++++--------------------------------
 mm/memory.c | 11 +++++++++--
 2 files changed, 27 insertions(+), 34 deletions(-)

diff --git a/fs/dax.c b/fs/dax.c
index bcfb14b..de3f53e 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -569,38 +569,6 @@ int __dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
 	if (!buffer_size_valid(&bh) || bh.b_size < PMD_SIZE)
 		goto fallback;
 
-	sector = bh.b_blocknr << (blkbits - 9);
-
-	if (buffer_unwritten(&bh) || buffer_new(&bh)) {
-		int i;
-
-		length = bdev_direct_access(bh.b_bdev, sector, &kaddr, &pfn,
-						bh.b_size);
-		if (length < 0) {
-			result = VM_FAULT_SIGBUS;
-			goto out;
-		}
-		if ((length < PMD_SIZE) || (pfn & PG_PMD_COLOUR))
-			goto fallback;
-
-		for (i = 0; i < PTRS_PER_PMD; i++)
-			clear_pmem(kaddr + i * PAGE_SIZE, PAGE_SIZE);
-		wmb_pmem();
-		count_vm_event(PGMAJFAULT);
-		mem_cgroup_count_vm_event(vma->vm_mm, PGMAJFAULT);
-		result |= VM_FAULT_MAJOR;
-	}
-
-	/*
-	 * If we allocated new storage, make sure no process has any
-	 * zero pages covering this hole
-	 */
-	if (buffer_new(&bh)) {
-		i_mmap_unlock_write(mapping);
-		unmap_mapping_range(mapping, pgoff << PAGE_SHIFT, PMD_SIZE, 0);
-		i_mmap_lock_write(mapping);
-	}
-
 	/*
 	 * If a truncate happened while we were allocating blocks, we may
 	 * leave blocks allocated to the file that are beyond EOF.  We can't
@@ -615,6 +583,13 @@ int __dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
 	if ((pgoff | PG_PMD_COLOUR) >= size)
 		goto fallback;
 
+	/*
+	 * If we allocated new storage, make sure no process has any
+	 * zero pages covering this hole
+	 */
+	if (buffer_new(&bh))
+		unmap_mapping_range(mapping, pgoff << PAGE_SHIFT, PMD_SIZE, 0);
+
 	if (!write && !buffer_mapped(&bh) && buffer_uptodate(&bh)) {
 		spinlock_t *ptl;
 		pmd_t entry;
@@ -635,6 +610,7 @@ int __dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
 		result = VM_FAULT_NOPAGE;
 		spin_unlock(ptl);
 	} else {
+		sector = bh.b_blocknr << (blkbits - 9);
 		length = bdev_direct_access(bh.b_bdev, sector, &kaddr, &pfn,
 						bh.b_size);
 		if (length < 0) {
@@ -644,6 +620,16 @@ int __dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
 		if ((length < PMD_SIZE) || (pfn & PG_PMD_COLOUR))
 			goto fallback;
 
+		if (buffer_unwritten(&bh) || buffer_new(&bh)) {
+			int i;
+			for (i = 0; i < PTRS_PER_PMD; i++)
+				clear_pmem(kaddr + i * PAGE_SIZE, PAGE_SIZE);
+			wmb_pmem();
+			count_vm_event(PGMAJFAULT);
+			mem_cgroup_count_vm_event(vma->vm_mm, PGMAJFAULT);
+			result |= VM_FAULT_MAJOR;
+		}
+
 		result |= vmf_insert_pfn_pmd(vma, address, pmd, pfn, write);
 	}
 
diff --git a/mm/memory.c b/mm/memory.c
index 9cb2747..5ec066f 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2426,10 +2426,17 @@ void unmap_mapping_range(struct address_space *mapping,
 	if (details.last_index < details.first_index)
 		details.last_index = ULONG_MAX;
 
-	i_mmap_lock_write(mapping);
+
+	/*
+	 * DAX already holds i_mmap_lock to serialise file truncate vs
+	 * page fault and page fault vs page fault.
+	 */
+	if (!IS_DAX(mapping->host))
+		i_mmap_lock_write(mapping);
 	if (unlikely(!RB_EMPTY_ROOT(&mapping->i_mmap)))
 		unmap_mapping_range_tree(&mapping->i_mmap, &details);
-	i_mmap_unlock_write(mapping);
+	if (!IS_DAX(mapping->host))
+		i_mmap_unlock_write(mapping);
 }
 EXPORT_SYMBOL(unmap_mapping_range);
 
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
