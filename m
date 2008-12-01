Date: Mon, 1 Dec 2008 00:44:49 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: [PATCH 5/8] badpage: zap print_bad_pte on swap and file
In-Reply-To: <Pine.LNX.4.64.0812010032210.10131@blonde.site>
Message-ID: <Pine.LNX.4.64.0812010043450.11401@blonde.site>
References: <Pine.LNX.4.64.0812010032210.10131@blonde.site>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Dave Jones <davej@redhat.com>, Arjan van de Ven <arjan@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Complete zap_pte_range()'s coverage of bad pagetable entries by calling
print_bad_pte() on a pte_file in a linear vma and on a bad swap entry.
That needs free_swap_and_cache() to tell it, which will also have shown
one of those "swap_free" errors (but with much less information).

Similar checks in fork's copy_one_pte()?  No, that would be more noisy
than helpful: we'll see them when parent and child exec or exit.

Where do_nonlinear_fault() calls print_bad_pte(): omit !VM_CAN_NONLINEAR
case, that could only be a bug in sys_remap_file_pages(), not a bad pte.
VM_FAULT_OOM rather than VM_FAULT_SIGBUS?  Well, okay, that is consistent
with what happens if do_swap_page() operates a bad swap entry; but don't
we have patches to be more careful about killing when VM_FAULT_OOM?

Signed-off-by: Hugh Dickins <hugh@veritas.com>
---

 include/linux/swap.h |   12 +++---------
 mm/memory.c          |   11 +++++++----
 mm/swapfile.c        |    7 ++++---

--- badpage4/include/linux/swap.h	2008-11-26 12:19:00.000000000 +0000
+++ badpage5/include/linux/swap.h	2008-11-28 20:40:46.000000000 +0000
@@ -305,7 +305,7 @@ extern swp_entry_t get_swap_page_of_type
 extern int swap_duplicate(swp_entry_t);
 extern int valid_swaphandles(swp_entry_t, unsigned long *);
 extern void swap_free(swp_entry_t);
-extern void free_swap_and_cache(swp_entry_t);
+extern int free_swap_and_cache(swp_entry_t);
 extern int swap_type_of(dev_t, sector_t, struct block_device **);
 extern unsigned int count_swap_pages(int, int);
 extern sector_t map_swap_page(struct swap_info_struct *, pgoff_t);
@@ -355,14 +355,8 @@ static inline void show_swap_cache_info(
 {
 }
 
-static inline void free_swap_and_cache(swp_entry_t swp)
-{
-}
-
-static inline int swap_duplicate(swp_entry_t swp)
-{
-	return 0;
-}
+#define free_swap_and_cache(swp)	is_migration_entry(swp)
+#define swap_duplicate(swp)		is_migration_entry(swp)
 
 static inline void swap_free(swp_entry_t swp)
 {
--- badpage4/mm/memory.c	2008-11-28 20:40:42.000000000 +0000
+++ badpage5/mm/memory.c	2008-11-28 20:40:46.000000000 +0000
@@ -800,8 +800,12 @@ static unsigned long zap_pte_range(struc
 		 */
 		if (unlikely(details))
 			continue;
-		if (!pte_file(ptent))
-			free_swap_and_cache(pte_to_swp_entry(ptent));
+		if (pte_file(ptent)) {
+			if (unlikely(!(vma->vm_flags & VM_NONLINEAR)))
+				print_bad_pte(vma, addr, ptent, NULL);
+		} else if
+		  (unlikely(!free_swap_and_cache(pte_to_swp_entry(ptent))))
+			print_bad_pte(vma, addr, ptent, NULL);
 		pte_clear_not_present_full(mm, addr, pte, tlb->fullmm);
 	} while (pte++, addr += PAGE_SIZE, (addr != end && *zap_work > 0));
 
@@ -2680,8 +2684,7 @@ static int do_nonlinear_fault(struct mm_
 	if (!pte_unmap_same(mm, pmd, page_table, orig_pte))
 		return 0;
 
-	if (unlikely(!(vma->vm_flags & VM_NONLINEAR) ||
-			!(vma->vm_flags & VM_CAN_NONLINEAR))) {
+	if (unlikely(!(vma->vm_flags & VM_NONLINEAR))) {
 		/*
 		 * Page table corrupted: show pte and kill process.
 		 */
--- badpage4/mm/swapfile.c	2008-11-28 20:37:16.000000000 +0000
+++ badpage5/mm/swapfile.c	2008-11-28 20:40:46.000000000 +0000
@@ -571,13 +571,13 @@ int try_to_free_swap(struct page *page)
  * Free the swap entry like above, but also try to
  * free the page cache entry if it is the last user.
  */
-void free_swap_and_cache(swp_entry_t entry)
+int free_swap_and_cache(swp_entry_t entry)
 {
-	struct swap_info_struct * p;
+	struct swap_info_struct *p;
 	struct page *page = NULL;
 
 	if (is_migration_entry(entry))
-		return;
+		return 1;
 
 	p = swap_info_get(entry);
 	if (p) {
@@ -603,6 +603,7 @@ void free_swap_and_cache(swp_entry_t ent
 		unlock_page(page);
 		page_cache_release(page);
 	}
+	return p != NULL;
 }
 
 #ifdef CONFIG_HIBERNATION

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
