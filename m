From: Davidlohr Bueso <dave@stgolabs.net>
Subject: [PATCH 10/10] mm/hugetlb: share the i_mmap_rwsem
Date: Thu, 30 Oct 2014 12:34:17 -0700
Message-ID: <1414697657-1678-11-git-send-email-dave@stgolabs.net>
References: <1414697657-1678-1-git-send-email-dave@stgolabs.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1414697657-1678-1-git-send-email-dave@stgolabs.net>
Sender: linux-kernel-owner@vger.kernel.org
To: akpm@linux-foundation.org
Cc: hughd@google.com, riel@redhat.com, mgorman@suse.de, peterz@infradead.org, mingo@kernel.org, linux-kernel@vger.kernel.org, dbueso@suse.de, linux-mm@kvack.org, Davidlohr Bueso <dave@stgolabs.net>
List-Id: linux-mm.kvack.org

The i_mmap_rwsem protects shared pages against races
when doing the sharing and unsharing, ultimately
calling huge_pmd_share/unshare() for PMD pages --
it also needs it to avoid races when populating the pud
for pmd allocation when looking for a shareable pmd page
for hugetlb. Ultimately the interval tree remains intact.

Signed-off-by: Davidlohr Bueso <dbueso@suse.de>
Acked-by: Kirill A. Shutemov <kirill.shutemov@intel.linux.com>
---
 fs/hugetlbfs/inode.c |  4 ++--
 mm/hugetlb.c         | 12 ++++++------
 mm/memory.c          |  4 ++--
 3 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index 5eba47f..0dca54d 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -412,10 +412,10 @@ static int hugetlb_vmtruncate(struct inode *inode, loff_t offset)
 	pgoff = offset >> PAGE_SHIFT;
 
 	i_size_write(inode, offset);
-	i_mmap_lock_write(mapping);
+	i_mmap_lock_read(mapping);
 	if (!RB_EMPTY_ROOT(&mapping->i_mmap))
 		hugetlb_vmtruncate_list(&mapping->i_mmap, pgoff);
-	i_mmap_unlock_write(mapping);
+	i_mmap_unlock_read(mapping);
 	truncate_hugepages(inode, offset);
 	return 0;
 }
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 2071cf4..80349f2 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -2775,7 +2775,7 @@ static void unmap_ref_private(struct mm_struct *mm, struct vm_area_struct *vma,
 	 * this mapping should be shared between all the VMAs,
 	 * __unmap_hugepage_range() is called as the lock is already held
 	 */
-	i_mmap_lock_write(mapping);
+	i_mmap_lock_read(mapping);
 	vma_interval_tree_foreach(iter_vma, &mapping->i_mmap, pgoff, pgoff) {
 		/* Do not unmap the current VMA */
 		if (iter_vma == vma)
@@ -2792,7 +2792,7 @@ static void unmap_ref_private(struct mm_struct *mm, struct vm_area_struct *vma,
 			unmap_hugepage_range(iter_vma, address,
 					     address + huge_page_size(h), page);
 	}
-	i_mmap_unlock_write(mapping);
+	i_mmap_unlock_read(mapping);
 }
 
 /*
@@ -3350,7 +3350,7 @@ unsigned long hugetlb_change_protection(struct vm_area_struct *vma,
 	flush_cache_range(vma, address, end);
 
 	mmu_notifier_invalidate_range_start(mm, start, end);
-	i_mmap_lock_write(vma->vm_file->f_mapping);
+	i_mmap_lock_read(vma->vm_file->f_mapping);
 	for (; address < end; address += huge_page_size(h)) {
 		spinlock_t *ptl;
 		ptep = huge_pte_offset(mm, address);
@@ -3379,7 +3379,7 @@ unsigned long hugetlb_change_protection(struct vm_area_struct *vma,
 	 */
 	flush_tlb_range(vma, start, end);
 	mmu_notifier_invalidate_range(mm, start, end);
-	i_mmap_unlock_write(vma->vm_file->f_mapping);
+	i_mmap_unlock_read(vma->vm_file->f_mapping);
 	mmu_notifier_invalidate_range_end(mm, start, end);
 
 	return pages << h->order;
@@ -3547,7 +3547,7 @@ pte_t *huge_pmd_share(struct mm_struct *mm, unsigned long addr, pud_t *pud)
 	if (!vma_shareable(vma, addr))
 		return (pte_t *)pmd_alloc(mm, pud, addr);
 
-	i_mmap_lock_write(mapping);
+	i_mmap_lock_read(mapping);
 	vma_interval_tree_foreach(svma, &mapping->i_mmap, idx, idx) {
 		if (svma == vma)
 			continue;
@@ -3575,7 +3575,7 @@ pte_t *huge_pmd_share(struct mm_struct *mm, unsigned long addr, pud_t *pud)
 	spin_unlock(ptl);
 out:
 	pte = (pte_t *)pmd_alloc(mm, pud, addr);
-	i_mmap_unlock_write(mapping);
+	i_mmap_unlock_read(mapping);
 	return pte;
 }
 
diff --git a/mm/memory.c b/mm/memory.c
index 22c3089..2ca3105 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1345,9 +1345,9 @@ static void unmap_single_vma(struct mmu_gather *tlb,
 			 * safe to do nothing in this case.
 			 */
 			if (vma->vm_file) {
-				i_mmap_lock_write(vma->vm_file->f_mapping);
+				i_mmap_lock_read(vma->vm_file->f_mapping);
 				__unmap_hugepage_range_final(tlb, vma, start, end, NULL);
-				i_mmap_unlock_write(vma->vm_file->f_mapping);
+				i_mmap_unlock_read(vma->vm_file->f_mapping);
 			}
 		} else
 			unmap_page_range(tlb, vma, start, end, details);
-- 
1.8.4.5
