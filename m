From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Tue, 07 Aug 2007 17:19:50 +1000
Subject: [RFC/PATCH 7/12] ia64 tracks freed page tables addresses
In-Reply-To: <1186471185.826251.312410898174.qpush@grosgo>
Message-Id: <20070807071957.763E0DDDFA@ozlabs.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Memory Management <linux-mm@kvack.org>
Cc: linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Until now, ia64 pretty much relied on the start/end arguments
passed to tlb_finish_mmu() to flush the virtual page tables.

Not only these tend to provide larger ranges than necessary,
but keeping track in the callers is a pain and I intend to remove
those from my mmu_gather rework.

This patch uses the newly added "address" arguemnt to pte_free_tlb()
to track the actual range covered by freed page tables and uses
that to perform the actual freeing.

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---

 include/asm-ia64/tlb.h |   24 +++++++++++++++++-------
 1 file changed, 17 insertions(+), 7 deletions(-)

Index: linux-work/include/asm-ia64/tlb.h
===================================================================
--- linux-work.orig/include/asm-ia64/tlb.h	2007-08-06 16:15:18.000000000 +1000
+++ linux-work/include/asm-ia64/tlb.h	2007-08-06 16:15:18.000000000 +1000
@@ -61,6 +61,8 @@ struct mmu_gather {
 	unsigned char		need_flush;	/* really unmapped some PTEs? */
 	unsigned long		start_addr;
 	unsigned long		end_addr;
+	unsigned long		start_pgtable;
+	unsigned long		end_pgtable;
 	struct page 		*pages[FREE_PTE_NR];
 };
 
@@ -72,8 +74,10 @@ DECLARE_PER_CPU(struct mmu_gather, mmu_g
  * freed pages that where gathered up to this point.
  */
 static inline void
-ia64_tlb_flush_mmu (struct mmu_gather *tlb, unsigned long start, unsigned long end)
+ia64_tlb_flush_mmu (struct mmu_gather *tlb)
 {
+	unsigned long start = tlb->start_addr;
+	unsigned long end = tlb->end_addr;
 	unsigned int nr;
 
 	if (!tlb->need_flush)
@@ -107,7 +111,10 @@ ia64_tlb_flush_mmu (struct mmu_gather *t
 		/* flush the address range from the tlb: */
 		flush_tlb_range(&vma, start, end);
 		/* now flush the virt. page-table area mapping the address range: */
-		flush_tlb_range(&vma, ia64_thash(start), ia64_thash(end));
+		if (tlb->start_pgtable < tlb->end_pgtable)
+			flush_tlb_range(&vma,
+					ia64_thash(tlb->start_pgtable),
+					ia64_thash(tlb->end_pgtable));
 	}
 
 	/* lastly, release the freed pages */
@@ -115,7 +122,7 @@ ia64_tlb_flush_mmu (struct mmu_gather *t
 	if (!tlb_fast_mode(tlb)) {
 		unsigned long i;
 		tlb->nr = 0;
-		tlb->start_addr = ~0UL;
+		tlb->start_addr = tlb->start_pgtable = ~0UL;
 		for (i = 0; i < nr; ++i)
 			free_page_and_swap_cache(tlb->pages[i]);
 	}
@@ -145,7 +152,7 @@ tlb_gather_mmu (struct mm_struct *mm, un
 	 */
 	tlb->nr = (num_online_cpus() == 1) ? ~0U : 0;
 	tlb->fullmm = full_mm_flush;
-	tlb->start_addr = ~0UL;
+	tlb->start_addr = tlb->start_pgtable = ~0UL;
 	return tlb;
 }
 
@@ -160,7 +167,7 @@ tlb_finish_mmu (struct mmu_gather *tlb, 
 	 * Note: tlb->nr may be 0 at this point, so we can't rely on tlb->start_addr and
 	 * tlb->end_addr.
 	 */
-	ia64_tlb_flush_mmu(tlb, start, end);
+	ia64_tlb_flush_mmu(tlb);
 
 	/* keep the page table cache within bounds */
 	check_pgt_cache();
@@ -184,7 +191,7 @@ tlb_remove_page (struct mmu_gather *tlb,
 	}
 	tlb->pages[tlb->nr++] = page;
 	if (tlb->nr >= FREE_PTE_NR)
-		ia64_tlb_flush_mmu(tlb, tlb->start_addr, tlb->end_addr);
+		ia64_tlb_flush_mmu(tlb);
 }
 
 /*
@@ -194,7 +201,7 @@ tlb_remove_page (struct mmu_gather *tlb,
 static inline void
 __tlb_remove_tlb_entry (struct mmu_gather *tlb, pte_t *ptep, unsigned long address)
 {
-	if (tlb->start_addr == ~0UL)
+	if (tlb->start_addr > address)
 		tlb->start_addr = address;
 	tlb->end_addr = address + PAGE_SIZE;
 }
@@ -213,6 +220,9 @@ do {							\
 #define pte_free_tlb(tlb, ptep, addr)			\
 do {							\
 	tlb->need_flush = 1;				\
+	if (tlb->start_pgtable > addr)			\
+		tlb->start_pgtable = addr;		\
+	tlb->end_pgtable = (addr + PMD_SIZE) & PMD_MASK;\
 	__pte_free_tlb(tlb, ptep, addr);		\
 } while (0)
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
