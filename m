Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id 888996B005C
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 17:41:14 -0400 (EDT)
Message-Id: <20120627212830.621401338@chello.nl>
Date: Wed, 27 Jun 2012 23:15:41 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 01/20] mm, x86: Add HAVE_RCU_TABLE_FREE support
References: <20120627211540.459910855@chello.nl>
Content-Disposition: inline; filename=mmu-generic-rcu.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org, Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Alex Shi <alex.shi@intel.com>, "Nikunj A. Dadhania" <nikunj@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Russell King <rmk@arm.linux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Chris Metcalf <cmetcalf@tilera.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Tony Luck <tony.luck@intel.com>, Paul Mundt <lethal@linux-sh.org>, Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>, Hans-Christian Egtvedt <hans-christian.egtvedt@atmel.com>, Ralf Baechle <ralf@linux-mips.org>, Kyle McMartin <kyle@mcmartin.ca>, James Bottomley <jejb@parisc-linux.org>, Chris Zankel <chris@zankel.net>, Jeremy Fitzhardinge <jeremy@goop.org>, Avi Kivity <avi@redhat.com>

Implements optional HAVE_RCU_TABLE_FREE support for x86.

This is useful for things like Xen and KVM where paravirt tlb flush
means the software page table walkers like GUP-fast cannot rely on
IRQs disabling like regular x86 can.

Cc: Nikunj A Dadhania <nikunj@linux.vnet.ibm.com>
Cc: Jeremy Fitzhardinge <jeremy@goop.org>
Cc: Avi Kivity <avi@redhat.com>
Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 arch/x86/include/asm/tlb.h |    1 +
 arch/x86/mm/pgtable.c      |    6 +++---
 include/asm-generic/tlb.h  |    9 +++++++++
 3 files changed, 13 insertions(+), 3 deletions(-)
--- a/arch/x86/include/asm/tlb.h
+++ b/arch/x86/include/asm/tlb.h
@@ -1,6 +1,7 @@
 #ifndef _ASM_X86_TLB_H
 #define _ASM_X86_TLB_H
 
+#define __tlb_remove_table(table) free_page_and_swap_cache(table)
 #define tlb_start_vma(tlb, vma) do { } while (0)
 #define tlb_end_vma(tlb, vma) do { } while (0)
 #define __tlb_remove_tlb_entry(tlb, ptep, address) do { } while (0)
--- a/arch/x86/mm/pgtable.c
+++ b/arch/x86/mm/pgtable.c
@@ -51,21 +51,21 @@ void ___pte_free_tlb(struct mmu_gather *
 {
 	pgtable_page_dtor(pte);
 	paravirt_release_pte(page_to_pfn(pte));
-	tlb_remove_page(tlb, pte);
+	tlb_remove_table(tlb, pte);
 }
 
 #if PAGETABLE_LEVELS > 2
 void ___pmd_free_tlb(struct mmu_gather *tlb, pmd_t *pmd)
 {
 	paravirt_release_pmd(__pa(pmd) >> PAGE_SHIFT);
-	tlb_remove_page(tlb, virt_to_page(pmd));
+	tlb_remove_table(tlb, virt_to_page(pmd));
 }
 
 #if PAGETABLE_LEVELS > 3
 void ___pud_free_tlb(struct mmu_gather *tlb, pud_t *pud)
 {
 	paravirt_release_pud(__pa(pud) >> PAGE_SHIFT);
-	tlb_remove_page(tlb, virt_to_page(pud));
+	tlb_remove_table(tlb, virt_to_page(pud));
 }
 #endif	/* PAGETABLE_LEVELS > 3 */
 #endif	/* PAGETABLE_LEVELS > 2 */
--- a/include/asm-generic/tlb.h
+++ b/include/asm-generic/tlb.h
@@ -19,6 +19,8 @@
 #include <asm/pgalloc.h>
 #include <asm/tlbflush.h>
 
+static inline void tlb_remove_page(struct mmu_gather *tlb, struct page *page);
+
 #ifdef CONFIG_HAVE_RCU_TABLE_FREE
 /*
  * Semi RCU freeing of the page directories.
@@ -60,6 +62,13 @@ struct mmu_table_batch {
 extern void tlb_table_flush(struct mmu_gather *tlb);
 extern void tlb_remove_table(struct mmu_gather *tlb, void *table);
 
+#else
+
+static inline void tlb_remove_table(struct mmu_gather *tlb, void *table)
+{
+	tlb_remove_page(tlb, table);
+}
+
 #endif
 
 /*


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
