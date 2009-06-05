Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id CEE546B004D
	for <linux-mm@kvack.org>; Fri,  5 Jun 2009 14:43:12 -0400 (EDT)
Date: Fri, 5 Jun 2009 19:26:37 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: [RFC] remove page_table_lock in anon_vma_prepare
In-Reply-To: <1244212553-21629-1-git-send-email-minchan.kim@gmail.com>
Message-ID: <Pine.LNX.4.64.0906051906000.14826@sister.anvils>
References: <1244212553-21629-1-git-send-email-minchan.kim@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Fri, 5 Jun 2009, Minchan Kim wrote:

> As I looked over the page_table_lock, it related to page table not anon_vma
> 
> I think anon_vma->lock can protect race against threads.
> Do I miss something ?
> 
> If I am right, we can remove unnecessary page_table_lock holding
> in anon_vma_prepare. We can get performance benefit. 
> 
> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
> Cc: Hugh Dickins <hugh.dickins@tiscali.co.uk>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Nick Piggin <npiggin@suse.de>

No, NAK to this one.  Look above the context shown in the patch:

		anon_vma = find_mergeable_anon_vma(vma);
		allocated = NULL;
		if (!anon_vma) {
			anon_vma = anon_vma_alloc();
			if (unlikely(!anon_vma))
				return -ENOMEM;
			allocated = anon_vma;
		}
		spin_lock(&anon_vma->lock);

So if find_mergeable_anon_vma failed to find a suitable neighbouring
vma to share with, we'll have got the anon_vma from anon_vma_alloc().

Two threads could perfectly well do that concurrently (mmap_sem is
held only for reading), each allocating a separate fresh anon_vma,
then they'd each do spin_lock(&anon_vma->lock), but on _different_
anon_vmas, so wouldn't exclude each other at all: we need a common
lock to exclude that race, and abuse page_table_lock for the purpose.

(As I expect you've noticed, we used not to bother with the spin_lock
on anon_vma->lock when we'd freshly allocated the anon_vma, it looks
as if it's unnecessary.  But in fact Nick and Linus found there's a
subtle reason why it is necessary even then - hopefully the git log
explains it, or I could look up the mails if you want, but at this
moment the details escape me.

And do we need the page_table_lock even when find_mergeable_anon_vma
succeeds?  That also looks as if it's unnecessary, but I've the ghost
of a memory that it's needed even for that case: I seem to remember
that there can be a benign race where find_mergeable_anon_vma called
by concurrent threads could actually return different anon_vmas.
That also is something I don't want to think too deeply into at
this instant, but beg me if you wish!)

Hugh

> ---
>  mm/rmap.c |    3 ---
>  1 files changed, 0 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/rmap.c b/mm/rmap.c
> index b5c6e12..65b4877 100644
> --- a/mm/rmap.c
> +++ b/mm/rmap.c
> @@ -113,14 +113,11 @@ int anon_vma_prepare(struct vm_area_struct *vma)
>  		}
>  		spin_lock(&anon_vma->lock);
>  
> -		/* page_table_lock to protect against threads */
> -		spin_lock(&mm->page_table_lock);
>  		if (likely(!vma->anon_vma)) {
>  			vma->anon_vma = anon_vma;
>  			list_add_tail(&vma->anon_vma_node, &anon_vma->head);
>  			allocated = NULL;
>  		}
> -		spin_unlock(&mm->page_table_lock);
>  
>  		spin_unlock(&anon_vma->lock);
>  		if (unlikely(allocated))
> -- 
> 1.5.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
