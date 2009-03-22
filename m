Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id DE7F06B003D
	for <linux-mm@kvack.org>; Sun, 22 Mar 2009 10:11:26 -0400 (EDT)
Date: Sun, 22 Mar 2009 14:55:08 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: BUG?: PAGE_FLAGS_CHECK_AT_PREP seems to be cleared too early
 (Was Re: I just got got another Oops
In-Reply-To: <20090320152313.GL24586@csn.ul.ie>
Message-ID: <Pine.LNX.4.64.0903221356200.20915@blonde.anvils>
References: <200903120133.11583.gene.heskett@gmail.com> <49B8C98D.3020309@davidnewall.com>
 <200903121431.49437.gene.heskett@gmail.com> <20090316115509.40ea13da.kamezawa.hiroyu@jp.fujitsu.com>
 <20090316170359.858e7a4e.kamezawa.hiroyu@jp.fujitsu.com>
 <Pine.LNX.4.64.0903162101110.13164@blonde.anvils> <20090320152313.GL24586@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Gene Heskett <gene.heskett@gmail.com>, David Newall <davidn@davidnewall.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, 20 Mar 2009, Mel Gorman wrote:
> On Mon, Mar 16, 2009 at 09:44:11PM +0000, Hugh Dickins wrote:
> > On Mon, 16 Mar 2009, KAMEZAWA Hiroyuki wrote:
> > > 
> > > PAGE_FLAGS_CHECK_AT_PREP is cleared by free_pages_check().
> > > This means PG_head/PG_tail(PG_compound) flags are cleared here
> > 
> > Yes, well spotted.  How embarrassing.  I must have got confused
> > about when the checking occurred when freeing a compound page.
> 
> I noticed this actually during the page allocator work and concluded
> it didn't matter because free_pages_check() cleared out the bits in
> the same way destroy_compound_page() did. The big difference was that
> destroy_compound_page() did a lot more sanity checks and was slower.
> 
> I accidentally fixed this (because I implemented what I though things
> should be doing instead of what they were really doing) at one point and
> the overhead was so high of the debugging check that I just made a note to
> "deal with this later, it's weird looking but ok".

I'm surprised the overhead was so high: I'd have imagined that it
was just treading on the same cachelines as free_pages_check()
already did, doing rather less work.

> 
> > > and Compound page will never be freed in sane way.
> > 
> > But is that so?  I'll admit I've not tried this out yet, but my
> > understanding is that the Compound page actually gets freed fine:
> > free_compound_page() should have passed the right order down, and this
> > PAGE_FLAGS_CHECK_AT_PREP clearing should remove the Head/Tail/Compound
> > flags - doesn't it all work out sanely, without any leaking?
> > 
> 
> That's more or less what I thought. It can't leak but it's not what you
> expect from compound page destructors either.
> 
> > What goes missing is all the destroy_compound_page() checks:
> > that's at present just dead code.
> > 
> > There's several things we could do about this.
> > 
> > 1.  We could regard destroy_compound_page() as legacy debugging code
> > from when compound pages were first introduced, and sanctify my error
> > by removing it.  Obviously that's appealing to me, makes me look like
> > a prophet rather than idiot!  That's not necessarily the right thing to
> > do, but might appeal also to those cutting overhead from page_alloc.c.
> > 
> 
> The function is pretty heavy it has to be said. This would be my preferred
> option rather than making the allocator go slower.

KAMEZAWA-san has voted for 2, so that was what I was intending to do.
But if destroy_compound_page() really is costly, I'm happy to throw
it out if others agree.

I don't think it actually buys us a great deal: the main thing it checks
(looking forward to the reuse of the pages, rather than just checking
that what was set up is still there) is that the order being freed is
not greater than the order that was allocated; but I think a PG_buddy
or a page->_count in the excess should catch that in free_pages_check().

And we don't have any such check for the much(?) more common case of
freeing a non-compound high-order page.

> 
> > 2.  We could do the destroy_compound_page() stuff in free_compound_page()
> > before calling __free_pages_ok(), and add the Head/Tail/Compound flags
> > into PAGE_FLAGS_CHECK_AT_FREE.  hat seems a more natural ordering to
> > me, and would remove the PageCompound check from a hotter path; but
> > I've a suspicion there's a good reason why it was not done that way,
> > that I'm overlooking at this moment.
> > 
> 
> I made this change and dropped it on the grounds it slowed things up so
> badly. It was part of allowing compound pages to be on the PCP lists.
> and ended up looking something like
> 
> static void free_compound_page(struct page *page)
> {
>        unsigned int order = compound_order(page);
> 
>        VM_BUG_ON(!PageCompound(page));
>        if (unlikely(destroy_compound_page(page, order)))
>                return;
> 
>        __free_pages_ok(page, order);
> }

Yes, that's how I was imagining it.   But I think we'd also want
to change hugetlb.c's set_compound_page_dtor(page, NULL) to
set_compound_page_dtor(page, free_compound_page), wouldn't we?
So far as I can see, that's the case that led the destroy call
to be sited in __free_one_page(), but I still don't get why it
was done that way.

> 
> > 3.  We can define a PAGE_FLAGS_CLEAR_AT_FREE which omits the Head/Tail/
> > Compound flags, and lets destroy_compound_page() be called as before
> > where it's currently intended.
> > 
> 
> Also did that, slowed things up. Tried fixing destroy_compound_page()
> but it was doing the same work as free_pages_check() so it also sucked.
> 
> > What do you think?  I suspect I'm going to have to spend tomorrow
> > worrying about something else entirely, and won't return here until
> > Wednesday.
> > 
> > But as regards the original "I just got got another Oops": my bug
> > that you point out here doesn't account for that, does it?  It's
> > still a mystery, isn't it, how the PageTail bit came to be set at
> > that point?
> > 
> > But that Oops does demonstrate that it's a very bad idea to be using
> > the deceptive page_count() in those bad_page() checks: we need to be
> > checking page->_count directly.

I notice your/Nick's 20/25 addresses this issue, good - I'd even be
happy to see that change go into 2.6.29, though probably too late now
(and it has been that way forever).  But note, it does need one of us
to replace the page_count in bad_page() in the same way, that's missing.

I've given up on trying to understand how that PageTail is set in
Gene's oops.  I was thinking that it got left behind somewhere
because of my destroy_compound_page sequence error, but I just
can't see how: I wonder if it's just a corrupt bit in the struct.

I don't now feel that we need to rush a fix for my error into 2.6.29:
it does appear to be working nicely enough with that inadvertent
change, and we're not yet agreed on which way to go from here.

> > 
> > And in looking at this, I notice something else to worry about:
> > that CONFIG_HUGETLBFS prep_compound_gigantic_page(), which seems
> > to exist for a more general case than "p = page + i" - what happens
> > when such a gigantic page is freed, and arrives at the various
> > "p = page + i" assumptions on the freeing path?
> > 
> 
> That function is a bit confusing I'll give you that. Glancing through,
> what happens is that the destuctor gets replaced with a free_huge_page()
> which throws the page onto those free lists instead. It never hits the
> buddy lists on the grounds they can't handle orders >= MAX_ORDER.

Ah yes, thanks a lot, I'd forgotten all that.  Yes, there appear to
be adequate MAX_ORDER checks in hugetlb.c to prevent that danger.

> 
> Out of curiousity,

My curiosity is very limited at the moment, I'm afraid I've not glanced.

> here is a patch that was intended for a totally different
> purpose but ended up forcing destroy_compound_page() to be used. It sucked
> so I ended up unfixing it again. It can't be merged as-is obviously but
> you'll see I redefined your flags a bit to exclude the compound flags
> and all that jazz. It could be rebased of course but it'd make more sense
> to have destroy_compound_page() that only does real work for DEBUG_VM as
> free_pages_check() already does enough work.

Yes, putting it under DEBUG_VM could be a compromise; though by now I've
persuaded myself that it's of little value, and the times it might catch
something would be out there without DEBUG_VM=y.

Hugh

> 
> ====
> 
> >From 93f9b5ebae0000ae3e7985c98680226f4bdd90a8 Mon Sep 17 00:00:00 2001
> From: Mel Gorman <mel@csn.ul.ie>
> Date: Mon, 9 Mar 2009 11:56:56 +0000
> Subject: [PATCH 32/34] Allow compound pages to be stored on the PCP lists
> 
> The SLUB allocator frees and allocates compound pages. The setup costs
> for compound pages are noticeable in profiles and incur cache misses as
> every struct page has to be checked and written. This patch allows
> compound pages to be stored on the PCP list to save on teardown and
> setup time.
> 
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> ---
>  include/linux/page-flags.h |    4 ++-
>  mm/page_alloc.c            |   56 ++++++++++++++++++++++++++++++-------------
>  2 files changed, 42 insertions(+), 18 deletions(-)
> 
> diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
> index 219a523..4177ec1 100644
> --- a/include/linux/page-flags.h
> +++ b/include/linux/page-flags.h
> @@ -388,7 +388,9 @@ static inline void __ClearPageTail(struct page *page)
>   * Pages being prepped should not have any flags set.  It they are set,
>   * there has been a kernel bug or struct page corruption.
>   */
> -#define PAGE_FLAGS_CHECK_AT_PREP	((1 << NR_PAGEFLAGS) - 1)
> +#define PAGE_FLAGS_CHECK_AT_PREP_BUDDY	((1 << NR_PAGEFLAGS) - 1)
> +#define PAGE_FLAGS_CHECK_AT_PREP	(((1 << NR_PAGEFLAGS) - 1) & \
> +					~(1 << PG_head | 1 << PG_tail))
>  
>  #endif /* !__GENERATING_BOUNDS_H */
>  #endif	/* PAGE_FLAGS_H */
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 253fd98..2941638 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -280,11 +280,7 @@ out:
>   * put_page() function.  Its ->lru.prev holds the order of allocation.
>   * This usage means that zero-order pages may not be compound.
>   */
> -
> -static void free_compound_page(struct page *page)
> -{
> -	__free_pages_ok(page, compound_order(page));
> -}
> +static void free_compound_page(struct page *page);
>  
>  void prep_compound_page(struct page *page, unsigned long order)
>  {
> @@ -553,7 +549,9 @@ static inline void __free_one_page(struct page *page,
>  	zone->free_area[page_order(page)].nr_free++;
>  }
>  
> -static inline int free_pages_check(struct page *page)
> +/* Sanity check a free pages flags */
> +static inline int check_freepage_flags(struct page *page,
> +						unsigned long prepflags)
>  {
>  	if (unlikely(page_mapcount(page) |
>  		(page->mapping != NULL)  |
> @@ -562,8 +560,8 @@ static inline int free_pages_check(struct page *page)
>  		bad_page(page);
>  		return 1;
>  	}
> -	if (page->flags & PAGE_FLAGS_CHECK_AT_PREP)
> -		page->flags &= ~PAGE_FLAGS_CHECK_AT_PREP;
> +	if (page->flags & prepflags)
> +		page->flags &= ~prepflags;
>  	return 0;
>  }
>  
> @@ -602,6 +600,12 @@ static int free_pcppages_bulk(struct zone *zone, int count,
>  		page = list_entry(list->prev, struct page, lru);
>  		freed += 1 << page->index;
>  		list_del(&page->lru);
> +
> +		/* SLUB can have compound pages to the free lists */
> +		if (unlikely(PageCompound(page)))
> +			if (unlikely(destroy_compound_page(page, page->index)))
> +				continue;
> +
>  		__free_one_page(page, zone, page->index, migratetype);
>  	}
>  	spin_unlock(&zone->lock);
> @@ -633,8 +637,10 @@ static void __free_pages_ok(struct page *page, unsigned int order)
>  	int bad = 0;
>  	int clearMlocked = PageMlocked(page);
>  
> +	VM_BUG_ON(PageCompound(page));
>  	for (i = 0 ; i < (1 << order) ; ++i)
> -		bad += free_pages_check(page + i);
> +		bad += check_freepage_flags(page + i,
> +					PAGE_FLAGS_CHECK_AT_PREP_BUDDY);
>  	if (bad)
>  		return;
>  
> @@ -738,8 +744,20 @@ static int prep_new_page(struct page *page, int order, gfp_t gfp_flags)
>  	if (gfp_flags & __GFP_ZERO)
>  		prep_zero_page(page, order, gfp_flags);
>  
> -	if (order && (gfp_flags & __GFP_COMP))
> -		prep_compound_page(page, order);
> +	/*
> +	 * If a compound page is requested, we have to check the page being
> +	 * prepped. If it's already compound, we leave it alone. If a
> +	 * compound page is not requested but the page being prepped is
> +	 * compound, then it must be destroyed
> +	 */
> +	if (order) {
> +		if ((gfp_flags & __GFP_COMP) && !PageCompound(page))
> +			prep_compound_page(page, order);
> +
> +		if (!(gfp_flags & __GFP_COMP) && PageCompound(page))
> +			if (unlikely(destroy_compound_page(page, order)))
> +				return 1;
> +	}
>  
>  	return 0;
>  }
> @@ -1105,14 +1123,9 @@ static void free_hot_cold_page(struct page *page, int order, int cold)
>  	int migratetype;
>  	int clearMlocked = PageMlocked(page);
>  
> -	/* SLUB can return lowish-order compound pages that need handling */
> -	if (order > 0 && unlikely(PageCompound(page)))
> -		if (unlikely(destroy_compound_page(page, order)))
> -			return;
> -
>  	if (PageAnon(page))
>  		page->mapping = NULL;
> -	if (free_pages_check(page))
> +	if (check_freepage_flags(page, PAGE_FLAGS_CHECK_AT_PREP))
>  		return;
>  
>  	if (!PageHighMem(page)) {
> @@ -1160,6 +1173,15 @@ out:
>  	put_cpu();
>  }
>  
> +static void free_compound_page(struct page *page)
> +{
> +	unsigned int order = compound_order(page);
> +	if (order <= PAGE_ALLOC_COSTLY_ORDER)
> +		free_hot_cold_page(page, order, 0);
> +	else
> +		__free_pages_ok(page, order);
> +}
> +
>  void free_hot_page(struct page *page)
>  {
>  	free_hot_cold_page(page, 0, 0);
> -- 
> 1.5.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
