Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id AD6246B0170
	for <linux-mm@kvack.org>; Thu,  4 Aug 2011 11:32:31 -0400 (EDT)
Date: Thu, 4 Aug 2011 17:32:05 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] THP: mremap support and TLB optimization #2
Message-ID: <20110804153204.GP9770@redhat.com>
References: <20110728142631.GI3087@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110728142631.GI3087@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>

Hello everyone,

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
> diff --git a/mm/mremap.c b/mm/mremap.c

*snip*

> --- a/mm/mremap.c
> +++ b/mm/mremap.c
> @@ -134,14 +126,17 @@ unsigned long move_page_tables(struct vm
>  	for (; old_addr < old_end; old_addr += extent, new_addr += extent) {
>  		cond_resched();
>  		next = (old_addr + PMD_SIZE) & PMD_MASK;
> -		if (next - 1 > old_end)
> +		if (next > old_end)
>  			next = old_end;
>  		extent = next - old_addr;
>  		old_pmd = get_old_pmd(vma->vm_mm, old_addr);

Could somebody comment on the "- 1" removal, the rest is less
urgent. That above change is indipendent of the mremap optimizations
and could be split off. For whatever reason it makes me uncomfortable
and I'd appreciate at least one positive or negative comment on it
from another two eyes ;). No need to review the rest for now if you're
busy.

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
