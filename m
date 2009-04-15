Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id C64995F0001
	for <linux-mm@kvack.org>; Wed, 15 Apr 2009 06:45:38 -0400 (EDT)
Date: Wed, 15 Apr 2009 12:46:15 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [RFC][PATCH v3 1/6] mm: Don't unmap gup()ed page
Message-ID: <20090415104615.GG9809@random.random>
References: <20090414143252.GE28265@random.random> <200904150042.15653.nickpiggin@yahoo.com.au> <20090415165431.AC4C.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090415165431.AC4C.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>, Jeff Moyer <jmoyer@redhat.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Wed, Apr 15, 2009 at 05:05:54PM +0900, KOSAKI Motohiro wrote:
> -	/*
> -	 * If the page is mlock()d, we cannot swap it out.
> -	 * If it's recently referenced (perhaps page_referenced
> -	 * skipped over this mm) then we should reactivate it.
> -	 */
>  	if (!migration) {
> +		if (PageSwapCache(page) &&
> +		    page_count(page) != page_mapcount(page) + 2) {
> +			ret = SWAP_FAIL;
> +			goto out_unmap;
> +		}
> +
> +		/*
> +		 * If the page is mlock()d, we cannot swap it out.
> +		 * If it's recently referenced (perhaps page_referenced
> +		 * skipped over this mm) then we should reactivate it.
> +		 */
>  		if (vma->vm_flags & VM_LOCKED) {
>  			ret = SWAP_MLOCK;
>  			goto out_unmap;
> @@ -790,7 +796,19 @@ static int try_to_unmap_one(struct page 
>  
>  	/* Nuke the page table entry. */
>  	flush_cache_page(vma, address, page_to_pfn(page));
> -	pteval = ptep_clear_flush_notify(vma, address, pte);
> +	pteval = ptep_clear_flush(vma, address, pte);
> +
> +	if (!migration) {
> +		/* re-check */
> +		if (PageSwapCache(page) &&
> +		    page_count(page) != page_mapcount(page) + 2) {
> +			/* We lose race against get_user_pages_fast() */
> +			set_pte_at(mm, address, pte, pteval);
> +			ret = SWAP_FAIL;
> +			goto out_unmap;
> +		}
> +	}
> +	mmu_notifier_invalidate_page(vma->vm_mm, address);

With regard to mmu notifier, this is the opposite of the right
ordering. One mmu_notifier_invalidate_page must run _before_ the first
check. The ptep_clear_flush_notify will then stay and there's no need
of a further mmu_notifier_invalidate_page after the second check.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
