Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id 83D426B0092
	for <linux-mm@kvack.org>; Thu, 17 May 2012 05:31:08 -0400 (EDT)
Date: Thu, 17 May 2012 10:30:23 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [RFC][PATCH 4/6] arm, mm: Convert arm to generic tlb
Message-ID: <20120517093022.GA14666@arm.com>
References: <20110302175928.022902359@chello.nl>
 <20110302180259.109909335@chello.nl>
 <20120517030551.GA11623@linux-sh.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120517030551.GA11623@linux-sh.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul Mundt <lethal@linux-sh.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@elte.hu>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Russell King <rmk@arm.linux.org.uk>, Chris Metcalf <cmetcalf@tilera.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>

On Thu, May 17, 2012 at 04:05:52AM +0100, Paul Mundt wrote:
> On Wed, Mar 02, 2011 at 06:59:32PM +0100, Peter Zijlstra wrote:
> > Might want to optimize the tlb_flush() function to do a full mm flush
> > when the range is 'large', IA64 does this too.
> > 
> > Cc: Russell King <rmk@arm.linux.org.uk>
> > Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
> 
> The current version in tlb-unify blows up due to a missing
> tlb_add_flush() definition. I can see in this thread tlb_track_range()
> was factored in, but the __pte_free_tlb()/__pmd_free_tlb() semantics have
> changed since then. Adding a dumb tlb_add_flush() that wraps in to
> tlb_track_range() seems to do the right thing, but someone more familiar
> with LPAE and ARM's double PMDs will have to figure out whether the
> tlb_track_range() in asm-generic/tlb.h's pmd/pte_free_tlb() are
> sufficient to remove the tlb_add_flush() calls or not.
> 
> Here's the dumb build fix for now though:
> 
> Signed-off-by: Paul Mundt <lethal@linux-sh.org>
> 
> ---
> 
> diff --git a/arch/arm/include/asm/tlb.h b/arch/arm/include/asm/tlb.h
> index 37dbce9..1de4b21 100644
> --- a/arch/arm/include/asm/tlb.h
> +++ b/arch/arm/include/asm/tlb.h
> @@ -38,6 +38,11 @@ __pmd_free_tlb(struct mmu_gather *tlb, pmd_t *pmdp, unsigned long addr);
>  
>  #include <asm-generic/tlb.h>
>  
> +static inline void tlb_add_flush(struct mmu_gather *tlb, unsigned long addr)
> +{
> +	tlb_track_range(tlb, addr, addr + PAGE_SIZE);
> +}


I think that's still needed in case the range given to pte_free_tlb()
does not cover both pmd entries (1MB each) that the classic ARM MMU
uses. But we could call tlb_track_range() directly rather than adding a
tlb_add_flush() function (untested):


diff --git a/arch/arm/include/asm/tlb.h b/arch/arm/include/asm/tlb.h
index 37dbce9..efe2831 100644
--- a/arch/arm/include/asm/tlb.h
+++ b/arch/arm/include/asm/tlb.h
@@ -42,15 +46,14 @@ static inline void
 __pte_free_tlb(struct mmu_gather *tlb, pgtable_t pte, unsigned long addr)
 {
 	pgtable_page_dtor(pte);
-
+#ifndef CONFIG_ARM_LPAE
 	/*
 	 * With the classic ARM MMU, a pte page has two corresponding pmd
 	 * entries, each covering 1MB.
 	 */
-	addr &= PMD_MASK;
-	tlb_add_flush(tlb, addr + SZ_1M - PAGE_SIZE);
-	tlb_add_flush(tlb, addr + SZ_1M);
-
+	addr = (addr & PMD_MASK) + SZ_1M;
+	tlb_track_range(tlb, addr - PAGE_SIZE, addr + PAGE_SIZE);
+#endif
 	tlb_remove_page(tlb, pte);
 }
 
@@ -58,7 +61,6 @@ static inline void __pmd_free_tlb(struct mmu_gather *tlb, pmd_t *pmdp,
 				  unsigned long addr)
 {
 #ifdef CONFIG_ARM_LPAE
-	tlb_add_flush(tlb, addr);
 	tlb_remove_page(tlb, virt_to_page(pmdp));
 #endif
 }


Another minor thing is that on newer ARM processors (Cortex-A15) we
need the TLB shootdown even on UP systems, so tlb_fast_mode should
always return 0. Something like below (untested):


diff --git a/arch/arm/include/asm/tlb.h b/arch/arm/include/asm/tlb.h
index 37dbce9..8e79689 100644
--- a/arch/arm/include/asm/tlb.h
+++ b/arch/arm/include/asm/tlb.h
@@ -23,6 +23,10 @@
 
 #include <linux/pagemap.h>
 
+#ifdef CONFIG_CPU_32v7
+#define tlb_fast_mode	(0)
+#endif
+
 #include <asm-generic/tlb.h>
 
 #else /* !CONFIG_MMU */
diff --git a/include/asm-generic/tlb.h b/include/asm-generic/tlb.h
index 90a725c..9ddf7ee 100644
--- a/include/asm-generic/tlb.h
+++ b/include/asm-generic/tlb.h
@@ -194,6 +194,7 @@ static inline void tlb_flush(struct mmu_gather *tlb)
 
 #endif /* CONFIG_HAVE_MMU_GATHER_RANGE */
 
+#ifndef tlb_fast_mode
 static inline int tlb_fast_mode(struct mmu_gather *tlb)
 {
 #ifdef CONFIG_SMP
@@ -206,6 +207,7 @@ static inline int tlb_fast_mode(struct mmu_gather *tlb)
 	return 1;
 #endif
 }
+#endif
 
 void tlb_gather_mmu(struct mmu_gather *tlb, struct mm_struct *mm, bool fullmm);
 void tlb_finish_mmu(struct mmu_gather *tlb, unsigned long start, unsigned long end);


-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
