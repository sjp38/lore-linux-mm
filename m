Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id A812E8D003A
	for <linux-mm@kvack.org>; Mon, 28 Feb 2011 07:09:32 -0500 (EST)
Date: Mon, 28 Feb 2011 12:06:51 +0000
From: Russell King <rmk@arm.linux.org.uk>
Subject: Re: [PATCH 06/17] arm: mmu_gather rework
Message-ID: <20110228120651.GA25657@flint.arm.linux.org.uk>
References: <20110217162327.434629380@chello.nl> <20110217163235.106239192@chello.nl> <1298565253.2428.288.camel@twins> <1298657083.2428.2483.camel@twins> <20110225215123.GA10026@flint.arm.linux.org.uk> <1298893487.2428.10537.camel@twins> <20110228115907.GB492@flint.arm.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110228115907.GB492@flint.arm.linux.org.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Avi Kivity <avi@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Yanmin Zhang <yanmin_zhang@linux.intel.com>, "Luck,Tony" <tony.luck@intel.com>, PaulMundt <lethal@linux-sh.org>, Chris Metcalf <cmetcalf@tilera.com>

On Mon, Feb 28, 2011 at 11:59:07AM +0000, Russell King wrote:
> It may be hacky but then the TLB shootdown interface is hacky too.  We
> don't keep the vma around to re-use after tlb_end_vma() - if you think
> that then you misunderstand what's going on.  The vma pointer is kept
> around as a cheap way of allowing tlb_finish_mmu() to distinguish
> between the unmap_region() mode and the shift_arg_pages() mode.

As I think I mentioned, the TLB shootdown interface either needs rewriting
from scratch as its currently a broken design, or it needs tlb_gather_mmu()
to take a proper mode argument, rather than this useless 'fullmm' argument
which only gives half the story.

The fact is that the interface has three modes, and distinguishing between
them requires a certain amount of black magic.  Explicitly, the !fullmm
case has two modes, and it requires implementations to remember whether
tlb_start_vma() has been called before tlb_finish_mm() or not.

Maybe this will help you understand the ARM implementation - this doesn't
change the functionality, but may make things clearer.

diff --git a/arch/arm/include/asm/tlb.h b/arch/arm/include/asm/tlb.h
index 82dfe5d..73fb813 100644
--- a/arch/arm/include/asm/tlb.h
+++ b/arch/arm/include/asm/tlb.h
@@ -54,7 +54,7 @@
 struct mmu_gather {
 	struct mm_struct	*mm;
 	unsigned int		fullmm;
-	struct vm_area_struct	*vma;
+	unsigned int		byvma;
 	unsigned long		range_start;
 	unsigned long		range_end;
 	unsigned int		nr;
@@ -68,23 +68,18 @@ DECLARE_PER_CPU(struct mmu_gather, mmu_gathers);
  * code is used:
  *  1. Unmapping a range of vmas.  See zap_page_range(), unmap_region().
  *     tlb->fullmm = 0, and tlb_start_vma/tlb_end_vma will be called.
- *     tlb->vma will be non-NULL.
+ *     tlb->byvma will be true.
  *  2. Unmapping all vmas.  See exit_mmap().
  *     tlb->fullmm = 1, and tlb_start_vma/tlb_end_vma will be called.
- *     tlb->vma will be non-NULL.  Additionally, page tables will be freed.
+ *     tlb->byvma will be true.  Additionally, page tables will be freed.
  *  3. Unmapping argument pages.  See shift_arg_pages().
  *     tlb->fullmm = 0, but tlb_start_vma/tlb_end_vma will not be called.
- *     tlb->vma will be NULL.
+ *     tlb->byvma will be false.
  */
 static inline void tlb_flush(struct mmu_gather *tlb)
 {
-	if (tlb->fullmm || !tlb->vma)
+	if (tlb->fullmm || !tlb->byvma)
 		flush_tlb_mm(tlb->mm);
-	else if (tlb->range_end > 0) {
-		flush_tlb_range(tlb->vma, tlb->range_start, tlb->range_end);
-		tlb->range_start = TASK_SIZE;
-		tlb->range_end = 0;
-	}
 }
 
 static inline void tlb_add_flush(struct mmu_gather *tlb, unsigned long addr)
@@ -113,7 +108,7 @@ tlb_gather_mmu(struct mm_struct *mm, unsigned int full_mm_flush)
 
 	tlb->mm = mm;
 	tlb->fullmm = full_mm_flush;
-	tlb->vma = NULL;
+	tlb->byvma = 0;
 	tlb->nr = 0;
 
 	return tlb;
@@ -149,7 +144,7 @@ tlb_start_vma(struct mmu_gather *tlb, struct vm_area_struct *vma)
 {
 	if (!tlb->fullmm) {
 		flush_cache_range(vma, vma->vm_start, vma->vm_end);
-		tlb->vma = vma;
+		tlb->byvma = 1;
 		tlb->range_start = TASK_SIZE;
 		tlb->range_end = 0;
 	}
@@ -158,8 +153,11 @@ tlb_start_vma(struct mmu_gather *tlb, struct vm_area_struct *vma)
 static inline void
 tlb_end_vma(struct mmu_gather *tlb, struct vm_area_struct *vma)
 {
-	if (!tlb->fullmm)
-		tlb_flush(tlb);
+	if (!tlb->fullmm && tlb->range_end > 0) {
+		flush_tlb_range(vma, tlb->range_start, tlb->range_end);
+		tlb->range_start = TASK_SIZE;
+		tlb->range_end = 0;
+	}
 }
 
 static inline void tlb_remove_page(struct mmu_gather *tlb, struct page *page)

-- 
Russell King
 Linux kernel    2.6 ARM Linux   - http://www.arm.linux.org.uk/
 maintainer of:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
