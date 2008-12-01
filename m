Date: Mon, 1 Dec 2008 23:50:33 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [PATCH 1/8] badpage: simplify page_alloc flag check+clear
In-Reply-To: <Pine.LNX.4.64.0812010843230.15331@quilx.com>
Message-ID: <Pine.LNX.4.64.0812012349330.18893@blonde.anvils>
References: <Pine.LNX.4.64.0812010032210.10131@blonde.site>
 <Pine.LNX.4.64.0812010038220.11401@blonde.site> <Pine.LNX.4.64.0812010843230.15331@quilx.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Russ Anderson <rja@sgi.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Dave Jones <davej@redhat.com>, Arjan van de Ven <arjan@infradead.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 1 Dec 2008, Christoph Lameter wrote:
> On Mon, 1 Dec 2008, Hugh Dickins wrote:
> >  /*
> >   * Flags checked when a page is freed.  Pages being freed should not have
> >   * these flags set.  It they are, there is a problem.
> >   */
> > -#define PAGE_FLAGS_CHECK_AT_FREE (PAGE_FLAGS | 1 << PG_reserved)
> > +#define PAGE_FLAGS_CHECK_AT_FREE \
> > +	(1 << PG_lru   | 1 << PG_private   | 1 << PG_locked | \
> > +	 1 << PG_buddy | 1 << PG_writeback | 1 << PG_reserved | \
> > +	 1 << PG_slab  | 1 << PG_swapcache | 1 << PG_active | \
> > +	 __PG_UNEVICTABLE | __PG_MLOCKED)
> 
> Rename this to PAGE_FLAGS_CLEAR_WHEN_FREE?

No, that's a list of just the ones it's checking at free;
it then (with this patch) goes on to clear all of them.

> 
> > + * Pages being prepped should not have any flags set.  It they are set,
> > + * there has been a kernel bug or struct page corruption.
> >   */
> > -#define PAGE_FLAGS_CHECK_AT_PREP (PAGE_FLAGS | \
> > -		1 << PG_reserved | 1 << PG_dirty | 1 << PG_swapbacked)
> > +#define PAGE_FLAGS_CHECK_AT_PREP	((1 << NR_PAGEFLAGS) - 1)
> 
> These are all the bits. Can we get rid of this definition?

PAGE_FLAGS_CHECK_AT_PREP may not be the best name for it now;
but I do think we need a definition for it, and I'm not sure
that it will remain "all the page flags".

As it was, I just took the existing name, and then included every
flag in it.  I'd love to include the empty space, if any, up as
far as the mmzone bits - is there a convenient way to do that?

It could as well be called PAGE_FLAGS_CLEAR_AT_FREE.  I'm not
sure that it's necessarily the same as all the flags - in fact,
I was rather surprised that the patch booted first time, I was
expecting to find that I'd overlooked some special cases.

I meant to, but didn't, look at Martin's guest page hinting, might
that be defining page flags set even across the free/alloc gap?
Cc'ed Martin now, no need for him to answer, but let's at least
warn him of this patch, something he might need to change with his.

> >  	/*
> >  	 * For now, we report if PG_reserved was found set, but do not
> >  	 * clear it, and do not free the page.  But we shall soon need
> >  	 * to do more, for when the ZERO_PAGE count wraps negative.
> >  	 */
> > -	return PageReserved(page);
> > +	if (PageReserved(page))
> > +		return 1;
> > +	if (page->flags & PAGE_FLAGS_CHECK_AT_PREP)
> > +		page->flags &= ~PAGE_FLAGS_CHECK_AT_PREP;
> > +	return 0;
> 
> The name PAGE_FLAGS_CHECK_AT_PREP is strange. We clear these flags without
> message.

Would you be happier with PAGE_FLAGS_CLEAR_AT_FREE, then?
That would be fine by me, even if we add the gap to mmzone later.

One of the problems with PREP is that it's not obvious that it
means ALLOC: yes, I'd be happier with PAGE_FLAGS_CLEAR_AT_FREE.

> This is equal to
> 
> page->flags &=~PAGE_FLAGS_CHECK_AT_PREP;
> 
> You can drop the if...

I was intentionally following the existing style of
	if (PageDirty(page))
		__ClearPageDirty(page);
	if (PageSwapBacked(page))
		__ClearPageSwapBacked(page);
which is going out of its way to avoid dirtying a cacheline.

In all the obvious cases, I think the cacheline will already
be dirty; but I guess there's an important case (high order
but not compound?) which has a lot of clean cachelines.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
