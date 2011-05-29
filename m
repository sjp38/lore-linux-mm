Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id CCDA46B0023
	for <linux-mm@kvack.org>; Sun, 29 May 2011 16:53:10 -0400 (EDT)
Received: from wpaz17.hot.corp.google.com (wpaz17.hot.corp.google.com [172.24.198.81])
	by smtp-out.google.com with ESMTP id p4TKr3TN005355
	for <linux-mm@kvack.org>; Sun, 29 May 2011 13:53:04 -0700
Received: from pxi16 (pxi16.prod.google.com [10.243.27.16])
	by wpaz17.hot.corp.google.com with ESMTP id p4TKr1KP020721
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 29 May 2011 13:53:02 -0700
Received: by pxi16 with SMTP id 16so1960498pxi.4
        for <linux-mm@kvack.org>; Sun, 29 May 2011 13:53:01 -0700 (PDT)
Date: Sun, 29 May 2011 13:53:01 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] mm: fix page_lock_anon_vma leaving mutex locked
In-Reply-To: <1306658024.1200.1222.camel@twins>
Message-ID: <alpine.LSU.2.00.1105291331570.2409@sister.anvils>
References: <alpine.LSU.2.00.1105281317090.13319@sister.anvils> <1306617270.2497.516.camel@laptop> <alpine.LSU.2.00.1105281437320.13942@sister.anvils> <BANLkTinsq-XJGvRVmBa6kRp0RTj9NqGWtA@mail.gmail.com> <alpine.LSU.2.00.1105281634440.14257@sister.anvils>
 <1306658024.1200.1222.camel@twins>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sun, 29 May 2011, Peter Zijlstra wrote:
> On Sat, 2011-05-28 at 17:12 -0700, Hugh Dickins wrote:
> > I believe that although it may no longer be the anon_vma that the page
> > is pointing to, it remains stable.  Because even if page->anon_vma is
> > updated, it will certainly have the same anon_vma->root as before
> > (see the first BUG_ON in __page_check_anon_rmap() for reassurance),
> > so the mutex locking holds good.
> > 
> > And the structure itself won't be freed: although the page is now
> > pointing to a less inclusive, more optimal anon_vma for reclaim to use,
> > the anon_vma which was originally pointed to remains on the same vma's
> > chains as it ever was, and only gets freed up when they're all gone.
> > 
> > So, when there's this race with moving anon_vma, page_lock_anon_vma()
> > may end up returning a less than optimal anon_vma, but it's still valid
> > as a good though longer list of vmas to look through.
> 
> Yes, and I think I see what you mean, if a page's anon_vma is changed
> while it remains mapped it will only ever be moved to a child of the
> original anon_vma. And because of the anon_vma ref-counting, the
> original anon_vma will stick around until that too is dead, which won't
> happen for as long as the page remains mapped.

Child or grandchild or more remote descendent, I think, yes.

Actually, it's not the anon_vma ref-counting that keeps them around
generally: I think it's the way we keep all those anon_vmas linked
to their vmas - the anon_vma will be freed only when all its possible
vmas have been unmapped.  Just like when we didn't have ref-counting,
and just like before the anon_vma_chains.

For a while I thought that, if we were careful about the ordering of
the lists, always freeing root last, we could have a naughty patch
which even removes the additional counting on anon_vma->root.

But no, precisely because there is some ref-counting, which may hold
any anon_vma for a while, we cannot enforce such ordering and do need
additional holds on the root.

> 
> Therefore, for as long as we observe page_mapped(), any anon_vma
> obtained from it remains valid.
> 
> Talk about tricky.. shees. I bet that wants a comment or so.

I don't think anybody understood how this was working, until you
forced us to think about it yesterday: thanks a lot for doing so.

> 
> > The previous code would have broken horribly, wouldn't it, were that
> > not the case?
> 
> It would have, yes.
> 
> ---
> Subject: mm, rmap: Add yet more comments to page_get_anon_vma/page_lock_anon_vma
> 
> Inspired by an analysis from Hugh on why again all this doesn't explode
> in our face.
> 
> Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>

Acked-by: Hugh Dickins <hughd@google.com>

> ---
>  mm/rmap.c |    9 +++++++--
>  1 files changed, 7 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/rmap.c b/mm/rmap.c
> index 6bada99..487d5cc 100644
> --- a/mm/rmap.c
> +++ b/mm/rmap.c
> @@ -350,7 +350,12 @@ void __init anon_vma_init(void)
>   * have been relevant to this page.
>   *
>   * The page might have been remapped to a different anon_vma or the anon_vma
> - * returned may already be freed (and even reused).
> + * returned may already be freed (and even reused). 
> + *
> + * In case it was remapped to a different anon_vma, the new anon_vma will be a
> + * child of the old anon_vma, and the anon_vma lifetime rules will therefore
> + * ensure that any anon_vma obtained from the page will still be valid for as
> + * long as we observe page_mapped() [ hence all those page_mapped() tests ].
>   *
>   * All users of this function must be very careful when walking the anon_vma
>   * chain and verify that the page in question is indeed mapped in it
> @@ -421,7 +426,7 @@ struct anon_vma *page_lock_anon_vma(struct page *page)
>  		/*
>  		 * If the page is still mapped, then this anon_vma is still
>  		 * its anon_vma, and holding the mutex ensures that it will
> -		 * not go away, see __put_anon_vma().
> +		 * not go away, see anon_vma_free().
>  		 */
>  		if (!page_mapped(page)) {
>  			mutex_unlock(&root_anon_vma->mutex);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
