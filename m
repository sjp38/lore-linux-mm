Message-ID: <41C3D5B1.3040200@yahoo.com.au>
Date: Sat, 18 Dec 2004 18:01:05 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: [PATCH 10/10] alternate 4-level page tables patches
References: <41C3D453.4040208@yahoo.com.au> <41C3D479.40708@yahoo.com.au> <41C3D48F.8080006@yahoo.com.au> <41C3D4AE.7010502@yahoo.com.au> <41C3D4C8.1000508@yahoo.com.au> <41C3D4F9.9040803@yahoo.com.au> <41C3D516.9060306@yahoo.com.au> <41C3D548.6080209@yahoo.com.au> <41C3D57C.5020005@yahoo.com.au> <41C3D594.4020108@yahoo.com.au>
In-Reply-To: <41C3D594.4020108@yahoo.com.au>
Content-Type: multipart/mixed;
 boundary="------------000607070602040409090209"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Memory Management <linux-mm@kvack.org>
Cc: Andi Kleen <ak@suse.de>, Hugh Dickins <hugh@veritas.com>, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------000607070602040409090209
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

10/10

--------------000607070602040409090209
Content-Type: text/plain;
 name="mm-inline-ptbl-walkers.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="mm-inline-ptbl-walkers.patch"



Convert some pagetable walking functions over to be inline where
they are only used once. This is worth a percent or so on lmbench
fork.

Signed-off-by: Nick Piggin <nickpiggin@yahoo.com.au>


---

 linux-2.6-npiggin/mm/memory.c   |    8 ++++----
 linux-2.6-npiggin/mm/msync.c    |    4 ++--
 linux-2.6-npiggin/mm/swapfile.c |    6 +++---
 linux-2.6-npiggin/mm/vmalloc.c  |   12 ++++++------
 4 files changed, 15 insertions(+), 15 deletions(-)

diff -puN mm/memory.c~mm-inline-ptbl-walkers mm/memory.c
--- linux-2.6/mm/memory.c~mm-inline-ptbl-walkers	2004-12-18 17:47:33.000000000 +1100
+++ linux-2.6-npiggin/mm/memory.c	2004-12-18 17:48:14.000000000 +1100
@@ -462,7 +462,7 @@ int copy_page_range(struct mm_struct *ds
 	return err;
 }
 
-static void zap_pte_range(struct mmu_gather *tlb,
+static inline void zap_pte_range(struct mmu_gather *tlb,
 		pmd_t *pmd, unsigned long address,
 		unsigned long size, struct zap_details *details)
 {
@@ -545,7 +545,7 @@ static void zap_pte_range(struct mmu_gat
 	pte_unmap(ptep-1);
 }
 
-static void zap_pmd_range(struct mmu_gather *tlb,
+static inline void zap_pmd_range(struct mmu_gather *tlb,
 		pud_t *pud, unsigned long address,
 		unsigned long size, struct zap_details *details)
 {
@@ -570,7 +570,7 @@ static void zap_pmd_range(struct mmu_gat
 	} while (address && (address < end));
 }
 
-static void zap_pud_range(struct mmu_gather *tlb,
+static inline void zap_pud_range(struct mmu_gather *tlb,
 		pgd_t * pgd, unsigned long address,
 		unsigned long end, struct zap_details *details)
 {
@@ -973,7 +973,7 @@ out:
 
 EXPORT_SYMBOL(get_user_pages);
 
-static void zeromap_pte_range(pte_t * pte, unsigned long address,
+static inline void zeromap_pte_range(pte_t * pte, unsigned long address,
                                      unsigned long size, pgprot_t prot)
 {
 	unsigned long end;
diff -puN mm/msync.c~mm-inline-ptbl-walkers mm/msync.c
--- linux-2.6/mm/msync.c~mm-inline-ptbl-walkers	2004-12-18 17:47:33.000000000 +1100
+++ linux-2.6-npiggin/mm/msync.c	2004-12-18 17:47:33.000000000 +1100
@@ -21,7 +21,7 @@
  * Called with mm->page_table_lock held to protect against other
  * threads/the swapper from ripping pte's out from under us.
  */
-static int filemap_sync_pte(pte_t *ptep, struct vm_area_struct *vma,
+static inline int filemap_sync_pte(pte_t *ptep, struct vm_area_struct *vma,
 	unsigned long address, unsigned int flags)
 {
 	pte_t pte = *ptep;
@@ -38,7 +38,7 @@ static int filemap_sync_pte(pte_t *ptep,
 	return 0;
 }
 
-static int filemap_sync_pte_range(pmd_t * pmd,
+static inline int filemap_sync_pte_range(pmd_t * pmd,
 	unsigned long address, unsigned long end, 
 	struct vm_area_struct *vma, unsigned int flags)
 {
diff -puN mm/swapfile.c~mm-inline-ptbl-walkers mm/swapfile.c
--- linux-2.6/mm/swapfile.c~mm-inline-ptbl-walkers	2004-12-18 17:47:33.000000000 +1100
+++ linux-2.6-npiggin/mm/swapfile.c	2004-12-18 17:47:33.000000000 +1100
@@ -427,7 +427,7 @@ void free_swap_and_cache(swp_entry_t ent
  * what to do if a write is requested later.
  */
 /* vma->vm_mm->page_table_lock is held */
-static void
+static inline void
 unuse_pte(struct vm_area_struct *vma, unsigned long address, pte_t *dir,
 	swp_entry_t entry, struct page *page)
 {
@@ -439,7 +439,7 @@ unuse_pte(struct vm_area_struct *vma, un
 }
 
 /* vma->vm_mm->page_table_lock is held */
-static unsigned long unuse_pmd(struct vm_area_struct * vma, pmd_t *dir,
+static inline unsigned long unuse_pmd(struct vm_area_struct * vma, pmd_t *dir,
 	unsigned long address, unsigned long size, unsigned long offset,
 	swp_entry_t entry, struct page *page)
 {
@@ -486,7 +486,7 @@ static unsigned long unuse_pmd(struct vm
 }
 
 /* vma->vm_mm->page_table_lock is held */
-static unsigned long unuse_pud(struct vm_area_struct * vma, pud_t *pud,
+static inline unsigned long unuse_pud(struct vm_area_struct * vma, pud_t *pud,
         unsigned long address, unsigned long size, unsigned long offset,
 	swp_entry_t entry, struct page *page)
 {
diff -puN mm/vmalloc.c~mm-inline-ptbl-walkers mm/vmalloc.c
--- linux-2.6/mm/vmalloc.c~mm-inline-ptbl-walkers	2004-12-18 17:47:33.000000000 +1100
+++ linux-2.6-npiggin/mm/vmalloc.c	2004-12-18 17:47:33.000000000 +1100
@@ -23,7 +23,7 @@
 rwlock_t vmlist_lock = RW_LOCK_UNLOCKED;
 struct vm_struct *vmlist;
 
-static void unmap_area_pte(pmd_t *pmd, unsigned long address,
+static inline void unmap_area_pte(pmd_t *pmd, unsigned long address,
 				  unsigned long size)
 {
 	unsigned long end;
@@ -56,7 +56,7 @@ static void unmap_area_pte(pmd_t *pmd, u
 	} while (address < end);
 }
 
-static void unmap_area_pmd(pud_t *pud, unsigned long address,
+static inline void unmap_area_pmd(pud_t *pud, unsigned long address,
 				  unsigned long size)
 {
 	unsigned long end;
@@ -83,7 +83,7 @@ static void unmap_area_pmd(pud_t *pud, u
 	} while (address < end);
 }
 
-static void unmap_area_pud(pgd_t *pgd, unsigned long address,
+static inline void unmap_area_pud(pgd_t *pgd, unsigned long address,
 			   unsigned long size)
 {
 	pud_t *pud;
@@ -110,7 +110,7 @@ static void unmap_area_pud(pgd_t *pgd, u
 	} while (address && (address < end));
 }
 
-static int map_area_pte(pte_t *pte, unsigned long address,
+static inline int map_area_pte(pte_t *pte, unsigned long address,
 			       unsigned long size, pgprot_t prot,
 			       struct page ***pages)
 {
@@ -135,7 +135,7 @@ static int map_area_pte(pte_t *pte, unsi
 	return 0;
 }
 
-static int map_area_pmd(pmd_t *pmd, unsigned long address,
+static inline int map_area_pmd(pmd_t *pmd, unsigned long address,
 			       unsigned long size, pgprot_t prot,
 			       struct page ***pages)
 {
@@ -160,7 +160,7 @@ static int map_area_pmd(pmd_t *pmd, unsi
 	return 0;
 }
 
-static int map_area_pud(pud_t *pud, unsigned long address,
+static inline int map_area_pud(pud_t *pud, unsigned long address,
 			       unsigned long end, pgprot_t prot,
 			       struct page ***pages)
 {

_

--------------000607070602040409090209--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
