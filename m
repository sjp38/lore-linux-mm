Date: Fri, 21 Nov 2003 18:48:55 +0100
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: [PATCH] Potential tlb flush race in install_page/install_file_pte.
Message-ID: <20031121174855.GC1341@mschwid3.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-arch@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi,
I think I found a potential race in install_page/install_file_pte. The
inline function zap_pte releases pages by calling page_remove_rmap and
page_cache_release.  If this was the last user of a page it can get
purged from the page cache and then get immediatly reused. But there
might still be a tlb for this page on another cpu. The tlb is removed
in the callers of zap_pte, install_page and install_file_pte, but this
is too late. I admit that its a very unlikely race but never the less..

I fixed this by using the new ptep_clear_flush function that is introduced
with the tlb flush optimization patch for s/390.

blue skies,
  Martin.

diffstat:
 mm/fremap.c |   20 +++++++-------------
 1 files changed, 7 insertions(+), 13 deletions(-)

diff -urN linux-2.6/mm/fremap.c linux-2.6-s390/mm/fremap.c
--- linux-2.6/mm/fremap.c	Sat Oct 25 20:42:47 2003
+++ linux-2.6-s390/mm/fremap.c	Fri Nov 21 16:20:24 2003
@@ -19,18 +19,18 @@
 #include <asm/cacheflush.h>
 #include <asm/tlbflush.h>
 
-static inline int zap_pte(struct mm_struct *mm, struct vm_area_struct *vma,
+static inline void zap_pte(struct mm_struct *mm, struct vm_area_struct *vma,
 			unsigned long addr, pte_t *ptep)
 {
 	pte_t pte = *ptep;
 
 	if (pte_none(pte))
-		return 0;
+		return;
 	if (pte_present(pte)) {
 		unsigned long pfn = pte_pfn(pte);
 
 		flush_cache_page(vma, addr);
-		pte = ptep_get_and_clear(ptep);
+		pte = ptep_clear_flush(vma, addr, ptep);
 		if (pfn_valid(pfn)) {
 			struct page *page = pfn_to_page(pfn);
 			if (!PageReserved(page)) {
@@ -41,12 +41,10 @@
 				mm->rss--;
 			}
 		}
-		return 1;
 	} else {
 		if (!pte_file(pte))
 			free_swap_and_cache(pte_to_swp_entry(pte));
 		pte_clear(ptep);
-		return 0;
 	}
 }
 
@@ -57,7 +55,7 @@
 int install_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		unsigned long addr, struct page *page, pgprot_t prot)
 {
-	int err = -ENOMEM, flush;
+	int err = -ENOMEM;
 	pte_t *pte;
 	pgd_t *pgd;
 	pmd_t *pmd;
@@ -78,7 +76,7 @@
 	if (!pte)
 		goto err_unlock;
 
-	flush = zap_pte(mm, vma, addr, pte);
+	zap_pte(mm, vma, addr, pte);
 
 	mm->rss++;
 	flush_icache_page(vma, page);
@@ -86,8 +84,6 @@
 	pte_chain = page_add_rmap(page, pte, pte_chain);
 	pte_val = *pte;
 	pte_unmap(pte);
-	if (flush)
-		flush_tlb_page(vma, addr);
 	update_mmu_cache(vma, addr, pte_val);
 	spin_unlock(&mm->page_table_lock);
 	pte_chain_free(pte_chain);
@@ -109,7 +105,7 @@
 int install_file_pte(struct mm_struct *mm, struct vm_area_struct *vma,
 		unsigned long addr, unsigned long pgoff, pgprot_t prot)
 {
-	int err = -ENOMEM, flush;
+	int err = -ENOMEM;
 	pte_t *pte;
 	pgd_t *pgd;
 	pmd_t *pmd;
@@ -126,13 +122,11 @@
 	if (!pte)
 		goto err_unlock;
 
-	flush = zap_pte(mm, vma, addr, pte);
+	zap_pte(mm, vma, addr, pte);
 
 	set_pte(pte, pgoff_to_pte(pgoff));
 	pte_val = *pte;
 	pte_unmap(pte);
-	if (flush)
-		flush_tlb_page(vma, addr);
 	update_mmu_cache(vma, addr, pte_val);
 	spin_unlock(&mm->page_table_lock);
 	return 0;
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
