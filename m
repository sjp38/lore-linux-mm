Message-Id: <200405222205.i4MM5Dr12667@mail.osdl.org>
Subject: [patch 16/57] rmap 14: i_shared_lock fixes
From: akpm@osdl.org
Date: Sat, 22 May 2004 15:04:42 -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: torvalds@osdl.org
Cc: linux-mm@kvack.org, akpm@osdl.org, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

From: Hugh Dickins <hugh@veritas.com>

First of batch of six patches which introduce Rajesh Venkatasubramanian's
implementation of a radix priority search tree of vmas, to handle object-based
reverse mapping corner cases well.

rmap 14 i_shared_lock fixes

Start the sequence with a couple of outstanding i_shared_lock fixes.

Since i_shared_sem became i_shared_lock, we've had to shift and then
temporarily remove mremap move's protection of concurrent truncation - if
mremap moves ptes while unmap_mapping_range_list is making its way through the
vmas, there's a danger we'd move a pte from an area yet to be cleaned back
into an area already cleared.

Now site the i_shared_lock with the page_table_lock in move_one_page.  Replace
page_table_present by get_one_pte_map, so we know when it's necessary to
allocate a new page table: in which case have to drop i_shared_lock, trylock
and perhaps reorder locks on the way back.  Yet another fix: must check for
NULL dst before pte_unmap(dst).

And over in rmap.c, try_to_unmap_file's cond_resched amidst its lengthy
nonlinear swapping was now causing might_sleep warnings: moved to a rather
unsatisfactory and less frequent cond_resched_lock on i_shared_lock when we
reach the end of the list; and one before starting on the nonlinears too: the
"cursor" may become out-of-date if we do schedule, but I doubt it's worth
bothering about.


---

 25-akpm/mm/mremap.c |   38 ++++++++++++++++++++++++++++++--------
 25-akpm/mm/rmap.c   |    3 ++-
 2 files changed, 32 insertions(+), 9 deletions(-)

diff -puN mm/mremap.c~rmap-14-i_shared_lock-fixes mm/mremap.c
--- 25/mm/mremap.c~rmap-14-i_shared_lock-fixes	2004-05-22 14:56:24.115425424 -0700
+++ 25-akpm/mm/mremap.c	2004-05-22 14:59:39.780679784 -0700
@@ -56,16 +56,18 @@ end:
 	return pte;
 }
 
-static inline int page_table_present(struct mm_struct *mm, unsigned long addr)
+static pte_t *get_one_pte_map(struct mm_struct *mm, unsigned long addr)
 {
 	pgd_t *pgd;
 	pmd_t *pmd;
 
 	pgd = pgd_offset(mm, addr);
 	if (pgd_none(*pgd))
-		return 0;
+		return NULL;
 	pmd = pmd_offset(pgd, addr);
-	return pmd_present(*pmd);
+	if (!pmd_present(*pmd))
+		return NULL;
+	return pte_offset_map(pmd, addr);
 }
 
 static inline pte_t *alloc_one_pte_map(struct mm_struct *mm, unsigned long addr)
@@ -98,11 +100,23 @@ static int
 move_one_page(struct vm_area_struct *vma, unsigned long old_addr,
 		unsigned long new_addr)
 {
+	struct address_space *mapping = NULL;
 	struct mm_struct *mm = vma->vm_mm;
 	int error = 0;
 	pte_t *src, *dst;
 
+	if (vma->vm_file) {
+		/*
+		 * Subtle point from Rajesh Venkatasubramanian: before
+		 * moving file-based ptes, we must lock vmtruncate out,
+		 * since it might clean the dst vma before the src vma,
+		 * and we propagate stale pages into the dst afterward.
+		 */
+		mapping = vma->vm_file->f_mapping;
+		spin_lock(&mapping->i_mmap_lock);
+	}
 	spin_lock(&mm->page_table_lock);
+
 	src = get_one_pte_map_nested(mm, old_addr);
 	if (src) {
 		/*
@@ -110,13 +124,19 @@ move_one_page(struct vm_area_struct *vma
 		 * memory allocation.  If it does then we need to drop the
 		 * atomic kmap
 		 */
-		if (!page_table_present(mm, new_addr)) {
+		dst = get_one_pte_map(mm, new_addr);
+		if (unlikely(!dst)) {
 			pte_unmap_nested(src);
-			src = NULL;
-		}
-		dst = alloc_one_pte_map(mm, new_addr);
-		if (src == NULL)
+			if (mapping)
+				spin_unlock(&mapping->i_mmap_lock);
+			dst = alloc_one_pte_map(mm, new_addr);
+			if (mapping && !spin_trylock(&mapping->i_mmap_lock)) {
+				spin_unlock(&mm->page_table_lock);
+				spin_lock(&mapping->i_mmap_lock);
+				spin_lock(&mm->page_table_lock);
+			}
 			src = get_one_pte_map_nested(mm, old_addr);
+		}
 		/*
 		 * Since alloc_one_pte_map can drop and re-acquire
 		 * page_table_lock, we should re-check the src entry...
@@ -137,6 +157,8 @@ move_one_page(struct vm_area_struct *vma
 			pte_unmap(dst);
 	}
 	spin_unlock(&mm->page_table_lock);
+	if (mapping)
+		spin_unlock(&mapping->i_mmap_lock);
 	return error;
 }
 
diff -puN mm/rmap.c~rmap-14-i_shared_lock-fixes mm/rmap.c
--- 25/mm/rmap.c~rmap-14-i_shared_lock-fixes	2004-05-22 14:56:24.116425272 -0700
+++ 25-akpm/mm/rmap.c	2004-05-22 14:59:39.627703040 -0700
@@ -794,6 +794,7 @@ static inline int try_to_unmap_file(stru
 	 * but even so use it as a guide to how hard we should try?
 	 */
 	page_map_unlock(page);
+	cond_resched_lock(&mapping->i_mmap_lock);
 
 	max_nl_size = (max_nl_size + CLUSTER_SIZE - 1) & CLUSTER_MASK;
 	if (max_nl_cursor == 0)
@@ -816,13 +817,13 @@ static inline int try_to_unmap_file(stru
 				vma->vm_private_data = (void *) cursor;
 				if ((int)mapcount <= 0)
 					goto relock;
-				cond_resched();
 			}
 			if (ret != SWAP_FAIL)
 				vma->vm_private_data =
 					(void *) max_nl_cursor;
 			ret = SWAP_AGAIN;
 		}
+		cond_resched_lock(&mapping->i_mmap_lock);
 		max_nl_cursor += CLUSTER_SIZE;
 	} while (max_nl_cursor <= max_nl_size);
 

_
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
