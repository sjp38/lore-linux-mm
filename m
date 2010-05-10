Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 51A3D6B0269
	for <linux-mm@kvack.org>; Mon, 10 May 2010 09:49:38 -0400 (EDT)
Date: Mon, 10 May 2010 14:49:17 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 2/2] mm,migration: Fix race between shift_arg_pages and
	rmap_walk by guaranteeing rmap_walk finds PTEs created within the
	temporary stack
Message-ID: <20100510134916.GG26611@csn.ul.ie>
References: <1273188053-26029-1-git-send-email-mel@csn.ul.ie> <1273188053-26029-3-git-send-email-mel@csn.ul.ie> <alpine.LFD.2.00.1005061836110.901@i5.linux-foundation.org> <20100507105712.18fc90c4.kamezawa.hiroyu@jp.fujitsu.com> <alpine.LFD.2.00.1005061905230.901@i5.linux-foundation.org> <20100509192145.GI4859@csn.ul.ie> <alpine.LFD.2.00.1005091245000.3711@i5.linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.1005091245000.3711@i5.linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>, Christoph Lameter <cl@linux.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

On Sun, May 09, 2010 at 12:56:49PM -0700, Linus Torvalds wrote:
> 
> 
> On Sun, 9 May 2010, Mel Gorman wrote:
> > 
> > It turns out not to be easy to the preallocating of PUDs, PMDs and PTEs
> > move_page_tables() needs.  To avoid overallocating, it has to follow the same
> > logic as move_page_tables duplicating some code in the process. The ugliest
> > aspect of all is passing those pre-allocated pages back into move_page_tables
> > where they need to be passed down to such functions as __pte_alloc. It turns
> > extremely messy.
> 
> Umm. What?
> 
> That's crazy talk. I'm not talking about preallocating stuff in order to 
> pass it in to move_page_tables(). I'm talking about just _creating_ the 
> dang page tables early - preallocating them IN THE PROCESS VM SPACE.
> 

Ok, I took the totally wrong approach by pre-allocating the pages and passing
them in to move_page_tables. Pages from the list were then taken in preference
to calling the page allocator. At the time, I thought the cleanup for ENOMEM
would be easier as well as avoiding complications with overlapping temporary
stack and new stack location. It was a bad choice, wrong and damn fugly.

> IOW, a patch like this (this is a pseudo-patch, totally untested, won't 
> compile, yadda yadda - you need to actually make the people who call 
> "move_page_tables()" call that prepare function first etc etc)
> 

Sounds reasonable as a general approach. I'll tinker with it for a bit to
see if exec can be made any faster when combined with your other suggestion
to avoid mprotect_fixup. In the meantime though, can the patch that avoids
migrating within the temporary stack be picked up? It closes the worst of
the migrate vs exec race without impacting performance. At least, I'm
no longer able to cause an oops with it applied.

> Yeah, if we care about holes in the page tables, we can certainly copy 
> more of the move_page_tables() logic, but it certainly doesn't matter for 
> execve(). This just makes sure that the destination page tables exist 
> first.
> 
> 		Linus
> 
> ---
>  mm/mremap.c |   22 +++++++++++++++++++++-
>  1 files changed, 21 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/mremap.c b/mm/mremap.c
> index cde56ee..c14505c 100644
> --- a/mm/mremap.c
> +++ b/mm/mremap.c
> @@ -128,6 +128,26 @@ static void move_ptes(struct vm_area_struct *vma, pmd_t *old_pmd,
>  
>  #define LATENCY_LIMIT	(64 * PAGE_SIZE)
>  
> +/*
> + * Preallocate the page tables, so that we can do the actual move
> + * without any allocations, and thus no error handling etc.
> + */
> +int prepare_move_page_tables(struct vm_area_struct *vma,
> +	unsigned long old_addr, struct vm_area_struct *new_vma,
> +	unsigned long new_addr, unsigned long len)
> +{
> +	unsigned long end_addr = new_addr + len;
> +
> +	while (new_addr < end_addr) {
> +		pmd_t *new_pmd;
> +		new_pmd = alloc_new_pmd(vma->vm_mm, new_addr);
> +		if (!new_pmd)
> +			return -ENOMEM;
> +		new_addr = (new_addr + PMD_SIZE) & PMD_MASK;
> +	}
> +	return 0;
> +}
> +
>  unsigned long move_page_tables(struct vm_area_struct *vma,
>  		unsigned long old_addr, struct vm_area_struct *new_vma,
>  		unsigned long new_addr, unsigned long len)
> @@ -147,7 +167,7 @@ unsigned long move_page_tables(struct vm_area_struct *vma,
>  		old_pmd = get_old_pmd(vma->vm_mm, old_addr);
>  		if (!old_pmd)
>  			continue;
> -		new_pmd = alloc_new_pmd(vma->vm_mm, new_addr);
> +		new_pmd = get_old_pmd(vma->vm_mm, new_addr);
>  		if (!new_pmd)
>  			break;
>  		next = (new_addr + PMD_SIZE) & PMD_MASK;
> 

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
