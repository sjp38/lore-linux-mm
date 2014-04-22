Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f174.google.com (mail-qc0-f174.google.com [209.85.216.174])
	by kanga.kvack.org (Postfix) with ESMTP id D65D16B0062
	for <linux-mm@kvack.org>; Tue, 22 Apr 2014 15:58:32 -0400 (EDT)
Received: by mail-qc0-f174.google.com with SMTP id c9so5811690qcz.5
        for <linux-mm@kvack.org>; Tue, 22 Apr 2014 12:58:32 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id l5si17440676qai.169.2014.04.22.12.58.31
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Apr 2014 12:58:31 -0700 (PDT)
Date: Tue, 22 Apr 2014 09:34:43 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: Dirty/Access bits vs. page content
Message-ID: <20140422073443.GC11182@twins.programming.kicks-ass.net>
References: <1398032742.19682.11.camel@pasglop>
 <CA+55aFz1sK+PF96LYYZY7OB7PBpxZu-uNLWLvPiRz-tJsBqX3w@mail.gmail.com>
 <1398054064.19682.32.camel@pasglop>
 <1398057630.19682.38.camel@pasglop>
 <CA+55aFwWHBtihC3w9E4+j4pz+6w7iTnYhTf4N3ie15BM9thxLQ@mail.gmail.com>
 <53558507.9050703@zytor.com>
 <CA+55aFxGm6J6N=4L7exLUFMr1_siNGHpK=wApd9GPCH1=63PPA@mail.gmail.com>
 <53559F48.8040808@intel.com>
 <CA+55aFwDtjA4Vp0yt0K5x6b6sAMtcn=61SEnOOs_En+3UXNpuA@mail.gmail.com>
 <CA+55aFzFxBDJ2rWo9DggdNsq-qBCr11OVXnm64jx04KMSVCBAw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFzFxBDJ2rWo9DggdNsq-qBCr11OVXnm64jx04KMSVCBAw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@intel.com>, "H. Peter Anvin" <hpa@zytor.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Tony Luck <tony.luck@intel.com>, kirill.shutemov@linux.intel.com

> From 21819f790e3d206ad77cd20d6e7cae86311fc87d Mon Sep 17 00:00:00 2001
> From: Linus Torvalds <torvalds@linux-foundation.org>
> Date: Mon, 21 Apr 2014 15:29:49 -0700
> Subject: [PATCH 1/2] mm: move page table dirty state into TLB gather operation
> 
> When tearing down a memory mapping, we have long delayed the actual
> freeing of the pages until after the (batched) TLB flush, since only
> after the TLB entries have been flushed from all CPU's do we know that
> none of the pages will be accessed any more.
> 
> HOWEVER.
> 
> Ben Herrenschmidt points out that we need to do the same thing for
> marking a shared mapped page dirty.  Because if we mark the underlying
> page dirty before we have flushed the TLB's, other CPU's may happily
> continue to write to the page (using their stale TLB contents) after
> we've marked the page dirty, and they can thus race with any cleaning
> operation.
> 
> Now, in practice, any page cleaning operations will take much longer to
> start the IO on the page than it will have taken us to get to the TLB
> flush, so this is going to be hard to trigger in real life.  In fact, so
> far nobody has even come up with a reasonable test-case for this to show
> it happening.
> 
> But what we do now (set_page_dirty() before flushing the TLB) really is
> wrong.  And this commit does not fix it, but by moving the dirty
> handling into the TLB gather operation at least the internal interfaces
> now support the notion of those TLB gather interfaces doing the rigth
> thing.
> 
> Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> Cc: Peter Anvin <hpa@zytor.com>

Acked-by: Peter Zijlstra <peterz@infradead.org>

> Cc: Dave Hansen <dave.hansen@intel.com>
> Cc: linux-arch@vger.kernel.org
> Cc: linux-mm@kvack.org
> Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
> ---
>  arch/arm/include/asm/tlb.h  |  6 ++++--
>  arch/ia64/include/asm/tlb.h |  6 ++++--
>  arch/s390/include/asm/tlb.h |  4 +++-
>  arch/sh/include/asm/tlb.h   |  6 ++++--
>  arch/um/include/asm/tlb.h   |  6 ++++--
>  include/asm-generic/tlb.h   |  4 ++--
>  mm/hugetlb.c                |  4 +---
>  mm/memory.c                 | 15 +++++++++------
>  8 files changed, 31 insertions(+), 20 deletions(-)
> 
> diff --git a/arch/arm/include/asm/tlb.h b/arch/arm/include/asm/tlb.h
> index 0baf7f0d9394..ac9c16af8e63 100644
> --- a/arch/arm/include/asm/tlb.h
> +++ b/arch/arm/include/asm/tlb.h
> @@ -165,8 +165,10 @@ tlb_end_vma(struct mmu_gather *tlb, struct vm_area_struct *vma)
>  		tlb_flush(tlb);
>  }
>  
> -static inline int __tlb_remove_page(struct mmu_gather *tlb, struct page *page)
> +static inline int __tlb_remove_page(struct mmu_gather *tlb, struct page *page, bool dirty)
>  {
> +	if (dirty)
> +		set_page_dirty(page);
>  	tlb->pages[tlb->nr++] = page;
>  	VM_BUG_ON(tlb->nr > tlb->max);
>  	return tlb->max - tlb->nr;
> @@ -174,7 +176,7 @@ static inline int __tlb_remove_page(struct mmu_gather *tlb, struct page *page)
>  
>  static inline void tlb_remove_page(struct mmu_gather *tlb, struct page *page)
>  {
> -	if (!__tlb_remove_page(tlb, page))
> +	if (!__tlb_remove_page(tlb, page, 0))
>  		tlb_flush_mmu(tlb);
>  }

So I checked this, and currently the only users of tlb_remove_page() are
the archs for freeing the page table pages and THP. The latter is OK
because it is strictly Anon (for now).

Anybody (/me looks at Kiryl) thinking of making THP work for shared
pages should also cure this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
