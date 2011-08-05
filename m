Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 7E02B6B016A
	for <linux-mm@kvack.org>; Fri,  5 Aug 2011 06:51:17 -0400 (EDT)
Date: Fri, 5 Aug 2011 12:50:47 +0200
From: Johannes Weiner <jweiner@redhat.com>
Subject: Re: [PATCH] THP: mremap support and TLB optimization #2
Message-ID: <20110805105047.GA32064@redhat.com>
References: <20110728142631.GI3087@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110728142631.GI3087@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>

On Thu, Jul 28, 2011 at 04:26:31PM +0200, Andrea Arcangeli wrote:
> Hello,
> 
> this is the latest version of the mremap THP native implementation
> plus optimizations.
> 
> So first question is: am I right, the "- 1" that I am removing below
> was buggy? It's harmless because these old_end/next are page aligned,
> but if PAGE_SIZE would be 1, it'd break, right? It's really confusing
> to read even if it happens to work. Please let me know because that "-
> 1" ironically it's the thing I'm less comfortable about in this patch.

> @@ -134,14 +126,17 @@ unsigned long move_page_tables(struct vm
>  {
>  	unsigned long extent, next, old_end;
>  	pmd_t *old_pmd, *new_pmd;
> +	bool need_flush = false;
>  
>  	old_end = old_addr + len;
>  	flush_cache_range(vma, old_addr, old_end);
>  
> +	mmu_notifier_invalidate_range_start(vma->vm_mm, old_addr, old_end);
> +
>  	for (; old_addr < old_end; old_addr += extent, new_addr += extent) {
>  		cond_resched();
>  		next = (old_addr + PMD_SIZE) & PMD_MASK;
> -		if (next - 1 > old_end)
> +		if (next > old_end)
>  			next = old_end;

If old_addr + PMD_SIZE overflows, next will be zero, thus smaller than
old_end and not fixed up.  This results in a bogus extent length here:

>  		extent = next - old_addr;

which I think can overrun old_addr + len if the extent should have
actually been smaller than the distance between new_addr and the next
PMD as well as that LATENCY_LIMIT to which extent is capped a few
lines below.  I haven't checked all the possibilities, though.

It could probably be

	if (next > old_end || next - 1 > old_end)
		next = old_end

to catch the theoretical next == old_end + 1 case, but PAGE_SIZE > 1
looks like a sensible assumption to me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
