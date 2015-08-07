Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id AAB3F6B0038
	for <linux-mm@kvack.org>; Fri,  7 Aug 2015 07:54:21 -0400 (EDT)
Received: by pdrg1 with SMTP id g1so44809524pdr.2
        for <linux-mm@kvack.org>; Fri, 07 Aug 2015 04:54:21 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id ve14si17240623pab.20.2015.08.07.04.54.20
        for <linux-mm@kvack.org>;
        Fri, 07 Aug 2015 04:54:20 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH] mm: take i_mmap_lock in unmap_mapping_range() for DAX
Date: Fri,  7 Aug 2015 14:53:43 +0300
Message-Id: <1438948423-128882-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <matthew.r.wilcox@intel.com>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

DAX is not so special: we need i_mmap_lock to protect mapping->i_mmap.

__dax_pmd_fault() uses unmap_mapping_range() shoot out zero page from
all mappings. We need to drop i_mmap_lock there to avoid lock deadlock.

Re-aquiring the lock should be fine since we check i_size after the
point.

Not-yet-signed-off-by: Matthew Wilcox <willy@linux.intel.com>
Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 fs/dax.c    | 35 +++++++++++++++++++----------------
 mm/memory.c | 11 ++---------
 2 files changed, 21 insertions(+), 25 deletions(-)

diff --git a/fs/dax.c b/fs/dax.c
index 9ef9b80cc132..ed54efedade6 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -554,6 +554,25 @@ int __dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
 	if (!buffer_size_valid(&bh) || bh.b_size < PMD_SIZE)
 		goto fallback;
 
+	if (buffer_unwritten(&bh) || buffer_new(&bh)) {
+		int i;
+		for (i = 0; i < PTRS_PER_PMD; i++)
+			clear_page(kaddr + i * PAGE_SIZE);
+		count_vm_event(PGMAJFAULT);
+		mem_cgroup_count_vm_event(vma->vm_mm, PGMAJFAULT);
+		result |= VM_FAULT_MAJOR;
+	}
+
+	/*
+	 * If we allocated new storage, make sure no process has any
+	 * zero pages covering this hole
+	 */
+	if (buffer_new(&bh)) {
+		i_mmap_unlock_write(mapping);
+		unmap_mapping_range(mapping, pgoff << PAGE_SHIFT, PMD_SIZE, 0);
+		i_mmap_lock_write(mapping);
+	}
+
 	/*
 	 * If a truncate happened while we were allocating blocks, we may
 	 * leave blocks allocated to the file that are beyond EOF.  We can't
@@ -568,13 +587,6 @@ int __dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
 	if ((pgoff | PG_PMD_COLOUR) >= size)
 		goto fallback;
 
-	/*
-	 * If we allocated new storage, make sure no process has any
-	 * zero pages covering this hole
-	 */
-	if (buffer_new(&bh))
-		unmap_mapping_range(mapping, pgoff << PAGE_SHIFT, PMD_SIZE, 0);
-
 	if (!write && !buffer_mapped(&bh) && buffer_uptodate(&bh)) {
 		spinlock_t *ptl;
 		pmd_t entry;
@@ -605,15 +617,6 @@ int __dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
 		if ((length < PMD_SIZE) || (pfn & PG_PMD_COLOUR))
 			goto fallback;
 
-		if (buffer_unwritten(&bh) || buffer_new(&bh)) {
-			int i;
-			for (i = 0; i < PTRS_PER_PMD; i++)
-				clear_page(kaddr + i * PAGE_SIZE);
-			count_vm_event(PGMAJFAULT);
-			mem_cgroup_count_vm_event(vma->vm_mm, PGMAJFAULT);
-			result |= VM_FAULT_MAJOR;
-		}
-
 		result |= vmf_insert_pfn_pmd(vma, address, pmd, pfn, write);
 	}
 
diff --git a/mm/memory.c b/mm/memory.c
index 5a3427bb3f32..670cdfa9f33e 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2426,17 +2426,10 @@ void unmap_mapping_range(struct address_space *mapping,
 	if (details.last_index < details.first_index)
 		details.last_index = ULONG_MAX;
 
-
-	/*
-	 * DAX already holds i_mmap_lock to serialise file truncate vs
-	 * page fault and page fault vs page fault.
-	 */
-	if (!IS_DAX(mapping->host))
-		i_mmap_lock_write(mapping);
+	i_mmap_lock_write(mapping);
 	if (unlikely(!RB_EMPTY_ROOT(&mapping->i_mmap)))
 		unmap_mapping_range_tree(&mapping->i_mmap, &details);
-	if (!IS_DAX(mapping->host))
-		i_mmap_unlock_write(mapping);
+	i_mmap_unlock_write(mapping);
 }
 EXPORT_SYMBOL(unmap_mapping_range);
 
-- 
2.4.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
