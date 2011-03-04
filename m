Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 2A0468D0039
	for <linux-mm@kvack.org>; Fri,  4 Mar 2011 06:57:50 -0500 (EST)
From: "Guan Xuetao" <gxt@mprc.pku.edu.cn>
References: <20110302175004.222724818@chello.nl> <20110302175200.883953013@chello.nl>
In-Reply-To: <20110302175200.883953013@chello.nl>
Subject: RE: [PATCH 09/13] unicore: mmu_gather rework
Date: Fri, 4 Mar 2011 19:56:12 +0800
Message-ID: <03ca01cbda63$31930fd0$94b92f70$@mprc.pku.edu.cn>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Peter Zijlstra' <a.p.zijlstra@chello.nl>
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, 'Benjamin Herrenschmidt' <benh@kernel.crashing.org>, 'David Miller' <davem@davemloft.net>, 'Hugh Dickins' <hugh.dickins@tiscali.co.uk>, 'Mel Gorman' <mel@csn.ul.ie>, 'Nick Piggin' <npiggin@kernel.dk>, 'Paul McKenney' <paulmck@linux.vnet.ibm.com>, 'Yanmin Zhang' <yanmin_zhang@linux.intel.com>, 'Andrea Arcangeli' <aarcange@redhat.com>, 'Avi Kivity' <avi@redhat.com>, 'Thomas Gleixner' <tglx@linutronix.de>, 'Rik van Riel' <riel@redhat.com>, 'Ingo Molnar' <mingo@elte.hu>, akpm@linux-foundation.org, 'Linus Torvalds' <torvalds@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>



> -----Original Message-----
> From: Peter Zijlstra [mailto:a.p.zijlstra@chello.nl]
> Sent: Thursday, March 03, 2011 1:50 AM
> To: Andrea Arcangeli; Avi Kivity; Thomas Gleixner; Rik van Riel; Ingo Molnar; akpm@linux-foundation.org; Linus Torvalds
> Cc: linux-kernel@vger.kernel.org; linux-arch@vger.kernel.org; linux-mm@kvack.org; Benjamin Herrenschmidt; David Miller; Hugh
> Dickins; Mel Gorman; Nick Piggin; Peter Zijlstra; Paul McKenney; Yanmin Zhang; Guan Xuetao
> Subject: [PATCH 09/13] unicore: mmu_gather rework
> 
> Fix up the unicore mmu_gather code to conform to the new API.
> 
> Cc: Guan Xuetao <gxt@mprc.pku.edu.cn>
> Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
> ---
>  arch/unicore32/include/asm/tlb.h |   32 ++++++++++++++++++++------------
>  1 file changed, 20 insertions(+), 12 deletions(-)
> 
> Index: linux-2.6/arch/unicore32/include/asm/tlb.h
> ===================================================================
> --- linux-2.6.orig/arch/unicore32/include/asm/tlb.h
> +++ linux-2.6/arch/unicore32/include/asm/tlb.h
> @@ -27,17 +27,11 @@ struct mmu_gather {
>  	unsigned long		range_end;
>  };
> 
> -DECLARE_PER_CPU(struct mmu_gather, mmu_gathers);
> -
> -static inline struct mmu_gather *
> -tlb_gather_mmu(struct mm_struct *mm, unsigned int full_mm_flush)
> +static inline void
> +tlb_gather_mmu(struct mmu_gather *tlb, struct mm_struct *mm, unsigned int fullmm)
>  {
> -	struct mmu_gather *tlb = &get_cpu_var(mmu_gathers);
> -
>  	tlb->mm = mm;
> -	tlb->fullmm = full_mm_flush;
> -
> -	return tlb;
> +	tlb->fullmm = fullmm;
>  }
> 
>  static inline void
> @@ -48,8 +42,6 @@ tlb_finish_mmu(struct mmu_gather *tlb, u
> 
>  	/* keep the page table cache within bounds */
>  	check_pgt_cache();
> -
> -	put_cpu_var(mmu_gathers);
>  }
> 
>  /*
> @@ -88,7 +80,23 @@ tlb_end_vma(struct mmu_gather *tlb, stru
>  		flush_tlb_range(vma, tlb->range_start, tlb->range_end);
>  }
> 
> -#define tlb_remove_page(tlb, page)	free_page_and_swap_cache(page)
> +static inline void tlb_flush_mmu(struct mmu_gather *tlb)
> +{
> +}
> +
> +static inline int __tlb_remove_page(struct mmu_gather *tlb, struct page *page)
> +{
> +	free_page_and_swap_cache(page);
> +	return 0;
> +}
> +
> +static inline void tlb_remove_page(struct mmu_gather *tlb, struct page *page)
> +{
> +	if (__tlb_remove_page(tlb, page))
> +		tlb_flush_mmu(tlb);
> +}
> +
> +
>  #define pte_free_tlb(tlb, ptep, addr)	pte_free((tlb)->mm, ptep)
>  #define pmd_free_tlb(tlb, pmdp, addr)	pmd_free((tlb)->mm, pmdp)
>  #define pud_free_tlb(tlb, x, addr)      do { } while (0)
Thanks Peter.
It looks good to me, though it is dependent on your patch set "mm: Preemptible mmu_gather"
While I have another look to include/asm-generic/tlb.h, I found it is also suitable for unicore32.
And so, I rewrite the tlb.h to use asm-generic version, and then your patch set will also work for me.

Cc: Arnd Bergmann <arnd@arndb.de>

From: GuanXuetao <gxt@mprc.pku.edu.cn>
Date: Fri, 4 Mar 2011 20:00:11 +0800
Subject: [PATCH] unicore32: rewrite arch-specific tlb.h to use asm-generic version

Signed-off-by: Guan Xuetao <gxt@mprc.pku.edu.cn>
---
 arch/unicore32/include/asm/tlb.h |   94 +++++---------------------------------
 1 files changed, 12 insertions(+), 82 deletions(-)

diff --git a/arch/unicore32/include/asm/tlb.h b/arch/unicore32/include/asm/tlb.h
index 02ee40e..9cca15c 100644
--- a/arch/unicore32/include/asm/tlb.h
+++ b/arch/unicore32/include/asm/tlb.h
@@ -12,87 +12,17 @@
 #ifndef __UNICORE_TLB_H__
 #define __UNICORE_TLB_H__
 
-#include <asm/cacheflush.h>
-#include <asm/tlbflush.h>
-#include <asm/pgalloc.h>
-
-/*
- * TLB handling.  This allows us to remove pages from the page
- * tables, and efficiently handle the TLB issues.
- */
-struct mmu_gather {
-	struct mm_struct	*mm;
-	unsigned int		fullmm;
-	unsigned long		range_start;
-	unsigned long		range_end;
-};
-
-DECLARE_PER_CPU(struct mmu_gather, mmu_gathers);
-
-static inline struct mmu_gather *
-tlb_gather_mmu(struct mm_struct *mm, unsigned int full_mm_flush)
-{
-	struct mmu_gather *tlb = &get_cpu_var(mmu_gathers);
-
-	tlb->mm = mm;
-	tlb->fullmm = full_mm_flush;
-
-	return tlb;
-}
-
-static inline void
-tlb_finish_mmu(struct mmu_gather *tlb, unsigned long start, unsigned long end)
-{
-	if (tlb->fullmm)
-		flush_tlb_mm(tlb->mm);
-
-	/* keep the page table cache within bounds */
-	check_pgt_cache();
-
-	put_cpu_var(mmu_gathers);
-}
-
-/*
- * Memorize the range for the TLB flush.
- */
-static inline void
-tlb_remove_tlb_entry(struct mmu_gather *tlb, pte_t *ptep, unsigned long addr)
-{
-	if (!tlb->fullmm) {
-		if (addr < tlb->range_start)
-			tlb->range_start = addr;
-		if (addr + PAGE_SIZE > tlb->range_end)
-			tlb->range_end = addr + PAGE_SIZE;
-	}
-}
-
-/*
- * In the case of tlb vma handling, we can optimise these away in the
- * case where we're doing a full MM flush.  When we're doing a munmap,
- * the vmas are adjusted to only cover the region to be torn down.
- */
-static inline void
-tlb_start_vma(struct mmu_gather *tlb, struct vm_area_struct *vma)
-{
-	if (!tlb->fullmm) {
-		flush_cache_range(vma, vma->vm_start, vma->vm_end);
-		tlb->range_start = TASK_SIZE;
-		tlb->range_end = 0;
-	}
-}
-
-static inline void
-tlb_end_vma(struct mmu_gather *tlb, struct vm_area_struct *vma)
-{
-	if (!tlb->fullmm && tlb->range_end > 0)
-		flush_tlb_range(vma, tlb->range_start, tlb->range_end);
-}
-
-#define tlb_remove_page(tlb, page)	free_page_and_swap_cache(page)
-#define pte_free_tlb(tlb, ptep, addr)	pte_free((tlb)->mm, ptep)
-#define pmd_free_tlb(tlb, pmdp, addr)	pmd_free((tlb)->mm, pmdp)
-#define pud_free_tlb(tlb, x, addr)      do { } while (0)
-
-#define tlb_migrate_finish(mm)		do { } while (0)
+#define tlb_start_vma(tlb, vma)				do { } while (0)
+#define tlb_end_vma(tlb, vma)				do { } while (0)
+#define __tlb_remove_tlb_entry(tlb, ptep, address)	do { } while (0)
+#define tlb_flush(tlb) flush_tlb_mm((tlb)->mm)
+
+#define __pte_free_tlb(tlb, pte, addr)				\
+	do {							\
+		pgtable_page_dtor(pte);				\
+		tlb_remove_page((tlb), (pte));			\
+	} while (0)
+
+#include <asm-generic/tlb.h>
 
 #endif
-- 
1.6.2.2

Thanks & Regards.

Guan Xuetao



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
