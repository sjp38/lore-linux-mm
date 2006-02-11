Date: Fri, 10 Feb 2006 23:49:22 -0600
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: [PATCH] extend usage of lightweight mm counter operations
Message-ID: <20060211054922.GA3484@dmt.cnet>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <piggin@cyberone.com.au>, Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Extend usage of Nick's lightweight mm counter operations to:

- nr_dirty: in __set_page_dirty_nobuffers and __set_page_dirty_buffers,
where interrupts are disabled due to acquision of mapping->tree_lock.

- nr_page_table_pages: which is never accessed from interrupt context.

- pgfault/pgmajfault: which are never accessed from interrupt context.

There are still a few more to go...

Signed-off-by: Marcelo Tosatti <marcelo@kvack.org>

diff --git a/fs/buffer.c b/fs/buffer.c
index 62cfd17..b7769d5 100644
--- a/fs/buffer.c
+++ b/fs/buffer.c
@@ -858,7 +858,7 @@ int __set_page_dirty_buffers(struct page
 		write_lock_irq(&mapping->tree_lock);
 		if (page->mapping) {	/* Race with truncate? */
 			if (mapping_cap_account_dirty(mapping))
-				inc_page_state(nr_dirty);
+				__inc_page_state(nr_dirty);
 			radix_tree_tag_set(&mapping->page_tree,
 						page_index(page),
 						PAGECACHE_TAG_DIRTY);
diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index d52999c..03fb427 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -93,7 +93,8 @@ struct page_state {
 	unsigned long nr_dirty;		/* Dirty writeable pages */
 	unsigned long nr_writeback;	/* Pages under writeback */
 	unsigned long nr_unstable;	/* NFS unstable pages */
-	unsigned long nr_page_table_pages;/* Pages used for pagetables */
+	unsigned long nr_page_table_pages;/* Pages used for pagetables.
+					   * only modified from process ctx. */
 	unsigned long nr_mapped;	/* mapped into pagetables.
 					 * only modified from process context */
 	unsigned long nr_slab;		/* In slab */
@@ -119,6 +120,7 @@ struct page_state {
 
 	unsigned long pgfault;		/* faults (major+minor) */
 	unsigned long pgmajfault;	/* faults (major only) */
+					/* both modified from proc. ctx. only */
 
 	unsigned long pgrefill_high;	/* inspected in refill_inactive_zone */
 	unsigned long pgrefill_normal;
diff --git a/mm/filemap.c b/mm/filemap.c
index 44da3d4..c5746a8 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1263,7 +1263,7 @@ retry_find:
 		 */
 		if (!did_readaround) {
 			majmin = VM_FAULT_MAJOR;
-			inc_page_state(pgmajfault);
+			__inc_page_state(pgmajfault);
 		}
 		did_readaround = 1;
 		ra_pages = max_sane_readahead(file->f_ra.ra_pages);
@@ -1334,7 +1334,7 @@ no_cached_page:
 page_not_uptodate:
 	if (!did_readaround) {
 		majmin = VM_FAULT_MAJOR;
-		inc_page_state(pgmajfault);
+		__inc_page_state(pgmajfault);
 	}
 	lock_page(page);
 
diff --git a/mm/memory.c b/mm/memory.c
index 2bee1f2..929808a 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -116,7 +116,7 @@ static void free_pte_range(struct mmu_ga
 	pmd_clear(pmd);
 	pte_lock_deinit(page);
 	pte_free_tlb(tlb, page);
-	dec_page_state(nr_page_table_pages);
+	__dec_page_state(nr_page_table_pages);
 	tlb->mm->nr_ptes--;
 }
 
@@ -302,7 +302,7 @@ int __pte_alloc(struct mm_struct *mm, pm
 		pte_free(new);
 	} else {
 		mm->nr_ptes++;
-		inc_page_state(nr_page_table_pages);
+		__inc_page_state(nr_page_table_pages);
 		pmd_populate(mm, pmd, new);
 	}
 	spin_unlock(&mm->page_table_lock);
@@ -1889,7 +1889,7 @@ again:
 
 		/* Had to read the page from swap area: Major fault */
 		ret = VM_FAULT_MAJOR;
-		inc_page_state(pgmajfault);
+		__inc_page_state(pgmajfault);
 		grab_swap_token();
 	}
 
@@ -2255,7 +2255,7 @@ int __handle_mm_fault(struct mm_struct *
 
 	__set_current_state(TASK_RUNNING);
 
-	inc_page_state(pgfault);
+	__inc_page_state(pgfault);
 
 	if (unlikely(is_vm_hugetlb_page(vma)))
 		return hugetlb_fault(mm, vma, address, write_access);
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 945559f..633d0fc 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -633,7 +633,7 @@ int __set_page_dirty_nobuffers(struct pa
 			if (mapping2) { /* Race with truncate? */
 				BUG_ON(mapping2 != mapping);
 				if (mapping_cap_account_dirty(mapping))
-					inc_page_state(nr_dirty);
+					__inc_page_state(nr_dirty);
 				radix_tree_tag_set(&mapping->page_tree,
 					page_index(page), PAGECACHE_TAG_DIRTY);
 			}
diff --git a/mm/shmem.c b/mm/shmem.c
index f7ac7b8..fb4e387 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -996,7 +996,7 @@ repeat:
 			spin_unlock(&info->lock);
 			/* here we actually do the io */
 			if (type && *type == VM_FAULT_MINOR) {
-				inc_page_state(pgmajfault);
+				__inc_page_state(pgmajfault);
 				*type = VM_FAULT_MAJOR;
 			}
 			swappage = shmem_swapin(info, swap, idx);





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
