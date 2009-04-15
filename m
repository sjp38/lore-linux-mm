Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 8B5535F0001
	for <linux-mm@kvack.org>; Wed, 15 Apr 2009 04:22:21 -0400 (EDT)
From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [RFC][PATCH v3 1/6] mm: Don't unmap gup()ed page
Date: Wed, 15 Apr 2009 18:22:32 +1000
References: <20090414143252.GE28265@random.random> <200904150042.15653.nickpiggin@yahoo.com.au> <20090415165431.AC4C.A69D9226@jp.fujitsu.com>
In-Reply-To: <20090415165431.AC4C.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200904151822.33478.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>, Jeff Moyer <jmoyer@redhat.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Wednesday 15 April 2009 18:05:54 KOSAKI Motohiro wrote:
> Hi
> 
> > On Wednesday 15 April 2009 00:32:52 Andrea Arcangeli wrote:
> > > On Wed, Apr 15, 2009 at 12:26:34AM +1000, Nick Piggin wrote:
> > > > Andrea: I didn't veto that set_bit change of yours as such. I just
> > > 
> > > I know you didn't ;)
> > > 
> > > > noted there could be more atomic operations. Actually I would
> > > > welcome more comparison between our two approaches, but they seem
> > > 
> > > Agree about the welcome of comparison, it'd be nice to measure it the
> > > enterprise workloads that showed the gup_fast gain in the first place.
> > 
> > I think we should be able to ask IBM to run some tests, provided
> > they still have machines available to do so. Although I don't want
> > to waste their time so we need to have something that has got past
> > initial code review and has a chance of being merged.
> > 
> > If we get that far, then I can ask them to run tests definitely.
> 
> Oh, it seem very charming idea.
> Nick, I hope to help your patch's rollup. It makes good comparision, I think.
> Is there my doable thing?

Well, I guess review and testing. There are few possibilities for
reducing the cases where we have to de-cow (or increasing the
cases where we can WP-on-fork), which I'd like to experiment with,
but I don't know how much it will help...


> And, I changed my patch.
> How about this? I added simple twice check.
> 
> because, both do_wp_page and try_to_unmap_one grab ptl. then,
> page-fault routine can't change pte while try_to_unmap nuke pte.

Hmm,

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

Hmm, in the case of powerpc-style gup_fast where the arch
does not send IPIs to flush TLBs, either the speculative
reference there should find the pte cleared, or the page_count
check here should find the speculative reference.

In the case of CPUs that do send IPIs and have x86-style
gup_fast, the TLB flush should ensure all gup_fast()s that
could have seen the pte will complete before we check
page_count.

Yes I think it might work.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
