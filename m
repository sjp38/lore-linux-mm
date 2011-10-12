Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 712C66B002C
	for <linux-mm@kvack.org>; Wed, 12 Oct 2011 11:56:54 -0400 (EDT)
Date: Wed, 12 Oct 2011 11:56:46 -0400
From: Johannes Weiner <jweiner@redhat.com>
Subject: Re: [PATCH] mm/huge_memory: Clean up typo when copying user highpage
Message-ID: <20111012155646.GC6478@redhat.com>
References: <CAJd=RBBuwmcV8srUyPGnKUp=RPKvsSd+4BbLrh--aHFGC5s7+g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAJd=RBBuwmcV8srUyPGnKUp=RPKvsSd+4BbLrh--aHFGC5s7+g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On Wed, Oct 12, 2011 at 10:39:36PM +0800, Hillf Danton wrote:
> Hi Andrea
> 
> When copying user highpage, the PAGE_SHIFT in the third parameter is a typo,
> I think, and is replaced with PAGE_SIZE.

This is a pretty nasty data corruption bug, so 'clean up' might be a
bit of an understatement ;-)

Nice catch.

Would you mind extending the changelog to include a problem
description?  Feel free to steal from this:

	The THP copy-on-write handler falls back to regular-sized
	pages for a huge page replacement upon allocation failure or
	if THP has been individually disabled in the target VMA.  The
	loop responsible for copying page-sized chunks accidentally
	uses multiples of PAGE_SHIFT instead of PAGE_SIZE as the byte
	offset into the original huge page, though, and the
	COW-breaking task ends up with a corrupt copy of the data.

> Signed-off-by: Hillf Danton <dhillf@gmail.com>

Acked-by: Johannes Weiner <jweiner@redhat.com>

> --- a/mm/huge_memory.c	Sat Aug 13 11:45:14 2011
> +++ b/mm/huge_memory.c	Wed Oct 12 22:26:15 2011
> @@ -829,7 +829,7 @@ static int do_huge_pmd_wp_page_fallback(
> 
>  	for (i = 0; i < HPAGE_PMD_NR; i++) {
>  		copy_user_highpage(pages[i], page + i,
> -				   haddr + PAGE_SHIFT*i, vma);
> +				   haddr + PAGE_SIZE * i, vma);
>  		__SetPageUptodate(pages[i]);
>  		cond_resched();
>  	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
