Subject: [PATCH 2/2] install_page pte use-after-free fix
From: Rajesh Venkatasubramanian <vrajesh@eecs.umich.edu>
Content-Type: text/plain
Message-Id: <1062786950.25345.259.camel@eecs-kilkenny.eecs.umich.edu>
Mime-Version: 1.0
Date: 05 Sep 2003 14:35:50 -0400
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org, Ingo Molnar <mingo@elte.hu>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

There seems to be a use-after-free bug in the install_page.
The newly installed pte is unmapped and then used in the
update_mmu_cache function call. This may result in a BUG() 
in PPC highmem.

Please apply if it is not a dubious fix.

Thanks,
Rajesh


 mm/fremap.c |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff -puN mm/fremap.c~fremap-pte_unmap mm/fremap.c
--- dev-2.6.0-test4/mm/fremap.c~fremap-pte_unmap	Fri Sep  5 12:58:44 2003
+++ dev-2.6.0-test4-vrajesh/mm/fremap.c	Fri Sep  5 12:58:44 2003
@@ -61,6 +61,7 @@ int install_page(struct mm_struct *mm, s
 	pte_t *pte;
 	pgd_t *pgd;
 	pmd_t *pmd;
+	pte_t pte_val;
 	struct pte_chain *pte_chain;
 
 	pte_chain = pte_chain_alloc(GFP_KERNEL);
@@ -83,10 +84,11 @@ int install_page(struct mm_struct *mm, s
 	flush_icache_page(vma, page);
 	set_pte(pte, mk_pte(page, prot));
 	pte_chain = page_add_rmap(page, pte, pte_chain);
+	pte_val = *pte;
 	pte_unmap(pte);
 	if (flush)
 		flush_tlb_page(vma, addr);
-	update_mmu_cache(vma, addr, *pte);
+	update_mmu_cache(vma, addr, pte_val);
 	spin_unlock(&mm->page_table_lock);
 	pte_chain_free(pte_chain);
 	return 0;
@@ -111,6 +113,7 @@ int install_file_pte(struct mm_struct *m
 	pte_t *pte;
 	pgd_t *pgd;
 	pmd_t *pmd;
+	pte_t pte_val;
 
 	pgd = pgd_offset(mm, addr);
 	spin_lock(&mm->page_table_lock);
@@ -126,10 +129,11 @@ int install_file_pte(struct mm_struct *m
 	flush = zap_pte(mm, vma, addr, pte);
 
 	set_pte(pte, pgoff_to_pte(pgoff));
+	pte_val = *pte;
 	pte_unmap(pte);
 	if (flush)
 		flush_tlb_page(vma, addr);
-	update_mmu_cache(vma, addr, *pte);
+	update_mmu_cache(vma, addr, pte_val);
 	spin_unlock(&mm->page_table_lock);
 	return 0;
 

_


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
