Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id CD94C6B026F
	for <linux-mm@kvack.org>; Wed,  6 Apr 2016 03:00:50 -0400 (EDT)
Received: by mail-wm0-f50.google.com with SMTP id l6so51406033wml.1
        for <linux-mm@kvack.org>; Wed, 06 Apr 2016 00:00:50 -0700 (PDT)
Received: from mail-wm0-x242.google.com (mail-wm0-x242.google.com. [2a00:1450:400c:c09::242])
        by mx.google.com with ESMTPS id y101si2189777wmh.28.2016.04.06.00.00.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Apr 2016 00:00:49 -0700 (PDT)
Received: by mail-wm0-x242.google.com with SMTP id a140so10407989wma.2
        for <linux-mm@kvack.org>; Wed, 06 Apr 2016 00:00:49 -0700 (PDT)
Date: Wed, 6 Apr 2016 09:00:45 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 12/31] huge tmpfs: extend get_user_pages_fast to shmem pmd
Message-ID: <20160406070044.GD3078@gmail.com>
References: <alpine.LSU.2.11.1604051403210.5965@eggly.anvils>
 <alpine.LSU.2.11.1604051429160.5965@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1604051429160.5965@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andres Lagar-Cavilla <andreslc@google.com>, Yang Shi <yang.shi@linaro.org>, Ning Qu <quning@gmail.com>, Ralf Baechle <ralf@linux-mips.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org


* Hugh Dickins <hughd@google.com> wrote:

> The arch-specific get_user_pages_fast() has a gup_huge_pmd() designed to
> optimize the refcounting on anonymous THP and hugetlbfs pages, with one
> atomic addition to compound head's common refcount.  That optimization
> must be avoided on huge tmpfs team pages, which use normal separate page
> refcounting.  We could combine the PageTeam and PageCompound cases into
> a single simple loop, but would lose the compound optimization that way.
> 
> One cannot go through these functions without wondering why some arches
> (x86, mips) like to SetPageReferenced, while the rest do not: an x86
> optimization that missed being propagated to the other architectures?
> No, see commit 8ee53820edfd ("thp: mmu_notifier_test_young"): it's a
> KVM GRU EPT thing, maybe not useful beyond x86.  I've just followed
> the established practice in each architecture.
> 
> Signed-off-by: Hugh Dickins <hughd@google.com>
> ---
> Cc'ed to arch maintainers as an FYI: this patch is not expected to
> go into the tree in the next few weeks, and depends upon a PageTeam
> definition not yet available outside this huge tmpfs patchset.
> Please refer to linux-mm or linux-kernel for more context.
> 
>  arch/mips/mm/gup.c  |   15 ++++++++++++++-
>  arch/s390/mm/gup.c  |   19 ++++++++++++++++++-
>  arch/sparc/mm/gup.c |   19 ++++++++++++++++++-
>  arch/x86/mm/gup.c   |   15 ++++++++++++++-
>  mm/gup.c            |   19 ++++++++++++++++++-
>  5 files changed, 82 insertions(+), 5 deletions(-)
> 
> --- a/arch/mips/mm/gup.c
> +++ b/arch/mips/mm/gup.c
> @@ -81,9 +81,22 @@ static int gup_huge_pmd(pmd_t pmd, unsig
>  	VM_BUG_ON(pte_special(pte));
>  	VM_BUG_ON(!pfn_valid(pte_pfn(pte)));
>  
> -	refs = 0;
>  	head = pte_page(pte);
>  	page = head + ((addr & ~PMD_MASK) >> PAGE_SHIFT);
> +
> +	if (PageTeam(head)) {
> +		/* Handle a huge tmpfs team with normal refcounting. */
> +		do {
> +			get_page(page);
> +			SetPageReferenced(page);
> +			pages[*nr] = page;
> +			(*nr)++;
> +			page++;
> +		} while (addr += PAGE_SIZE, addr != end);
> +		return 1;
> +	}
> +
> +	refs = 0;
>  	do {
>  		VM_BUG_ON(compound_head(page) != head);
>  		pages[*nr] = page;
> --- a/arch/s390/mm/gup.c
> +++ b/arch/s390/mm/gup.c
> @@ -66,9 +66,26 @@ static inline int gup_huge_pmd(pmd_t *pm
>  		return 0;
>  	VM_BUG_ON(!pfn_valid(pmd_val(pmd) >> PAGE_SHIFT));
>  
> -	refs = 0;
>  	head = pmd_page(pmd);
>  	page = head + ((addr & ~PMD_MASK) >> PAGE_SHIFT);
> +
> +	if (PageTeam(head)) {
> +		/* Handle a huge tmpfs team with normal refcounting. */
> +		do {
> +			if (!page_cache_get_speculative(page))
> +				return 0;
> +			if (unlikely(pmd_val(pmd) != pmd_val(*pmdp))) {
> +				put_page(page);
> +				return 0;
> +			}
> +			pages[*nr] = page;
> +			(*nr)++;
> +			page++;
> +		} while (addr += PAGE_SIZE, addr != end);
> +		return 1;
> +	}
> +
> +	refs = 0;
>  	do {
>  		VM_BUG_ON(compound_head(page) != head);
>  		pages[*nr] = page;
> --- a/arch/sparc/mm/gup.c
> +++ b/arch/sparc/mm/gup.c
> @@ -77,9 +77,26 @@ static int gup_huge_pmd(pmd_t *pmdp, pmd
>  	if (write && !pmd_write(pmd))
>  		return 0;
>  
> -	refs = 0;
>  	head = pmd_page(pmd);
>  	page = head + ((addr & ~PMD_MASK) >> PAGE_SHIFT);
> +
> +	if (PageTeam(head)) {
> +		/* Handle a huge tmpfs team with normal refcounting. */
> +		do {
> +			if (!page_cache_get_speculative(page))
> +				return 0;
> +			if (unlikely(pmd_val(pmd) != pmd_val(*pmdp))) {
> +				put_page(page);
> +				return 0;
> +			}
> +			pages[*nr] = page;
> +			(*nr)++;
> +			page++;
> +		} while (addr += PAGE_SIZE, addr != end);
> +		return 1;
> +	}
> +
> +	refs = 0;
>  	do {
>  		VM_BUG_ON(compound_head(page) != head);
>  		pages[*nr] = page;
> --- a/arch/x86/mm/gup.c
> +++ b/arch/x86/mm/gup.c
> @@ -196,9 +196,22 @@ static noinline int gup_huge_pmd(pmd_t p
>  	/* hugepages are never "special" */
>  	VM_BUG_ON(pmd_flags(pmd) & _PAGE_SPECIAL);
>  
> -	refs = 0;
>  	head = pmd_page(pmd);
>  	page = head + ((addr & ~PMD_MASK) >> PAGE_SHIFT);
> +
> +	if (PageTeam(head)) {
> +		/* Handle a huge tmpfs team with normal refcounting. */
> +		do {
> +			get_page(page);
> +			SetPageReferenced(page);
> +			pages[*nr] = page;
> +			(*nr)++;
> +			page++;
> +		} while (addr += PAGE_SIZE, addr != end);
> +		return 1;
> +	}
> +
> +	refs = 0;
>  	do {
>  		VM_BUG_ON_PAGE(compound_head(page) != head, page);
>  		pages[*nr] = page;
> --- a/mm/gup.c
> +++ b/mm/gup.c
> @@ -1247,9 +1247,26 @@ static int gup_huge_pmd(pmd_t orig, pmd_
>  	if (write && !pmd_write(orig))
>  		return 0;
>  
> -	refs = 0;
>  	head = pmd_page(orig);
>  	page = head + ((addr & ~PMD_MASK) >> PAGE_SHIFT);
> +
> +	if (PageTeam(head)) {
> +		/* Handle a huge tmpfs team with normal refcounting. */
> +		do {
> +			if (!page_cache_get_speculative(page))
> +				return 0;
> +			if (unlikely(pmd_val(orig) != pmd_val(*pmdp))) {
> +				put_page(page);
> +				return 0;
> +			}
> +			pages[*nr] = page;
> +			(*nr)++;
> +			page++;
> +		} while (addr += PAGE_SIZE, addr != end);
> +		return 1;
> +	}
> +
> +	refs = 0;
>  	do {
>  		VM_BUG_ON_PAGE(compound_head(page) != head, page);
>  		pages[*nr] = page;

Ouch!

Looks like there are two main variants - so these kinds of repetitive patterns 
very much call for some sort of factoring out of common code, right?

Then the fix could be applied to the common portion(s) only, which will cut down 
this gigantic diffstat:

  >  5 files changed, 82 insertions(+), 5 deletions(-)

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
