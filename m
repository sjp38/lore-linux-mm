From: Rik van Riel <riel@conectiva.com.br>
Subject: [PATCH] 8/4  -ac to newer rmap
Message-Id: <20021113145002Z80339-18062+20@imladris.surriel.com>
Date: Wed, 13 Nov 2002 12:50:02 -0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Arjan van de Ven <arjanv@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Patch by Paul Mackarras to make sure that remap_pmd_range calls
pte_alloc with the full address, so we don't have pagetables with
wrong pte->mm and pte->index

(ObWork: my patches are sponsored by Conectiva, Inc)
--- linux-2.4.19/mm/memory.c	2002-11-13 08:48:31.000000000 -0200
+++ linux-2.4-rmap/mm/memory.c	2002-11-13 12:10:45.000000000 -0200
@@ -164,6 +164,7 @@ int check_pgt_cache(void)
 void clear_page_tables(struct mm_struct *mm, unsigned long first, int nr)
 {
 	pgd_t * page_dir = mm->pgd;
+	unsigned long	last = first + nr;
 
 	spin_lock(&mm->page_table_lock);
 	page_dir += first;
@@ -173,6 +175,8 @@ void clear_page_tables(struct mm_struct 
 	} while (--nr);
 	spin_unlock(&mm->page_table_lock);
 
+	flush_tlb_pgtables(mm, first * PGDIR_SIZE, last * PGDIR_SIZE);
+	
 	/* keep the page table cache within bounds */
 	check_pgt_cache();
 }
@@ -886,18 +889,19 @@ static inline void remap_pte_range(pte_t
 static inline int remap_pmd_range(struct mm_struct *mm, pmd_t * pmd, unsigned long address, unsigned long size,
 	unsigned long phys_addr, pgprot_t prot)
 {
-	unsigned long end;
+	unsigned long base, end;
 
+	base = address & PGDIR_MASK;
 	address &= ~PGDIR_MASK;
 	end = address + size;
 	if (end > PGDIR_SIZE)
 		end = PGDIR_SIZE;
 	phys_addr -= address;
 	do {
-		pte_t * pte = pte_alloc(mm, pmd, address);
+		pte_t * pte = pte_alloc(mm, pmd, address + base);
 		if (!pte)
 			return -ENOMEM;
-		remap_pte_range(pte, address, end - address, address + phys_addr, prot);
+		remap_pte_range(pte, base + address, end - address, address + phys_addr, prot);
 		address = (address + PMD_SIZE) & PMD_MASK;
 		pmd++;
 	} while (address && (address < end));
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
