Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 7C3246B00D2
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 06:24:09 -0400 (EDT)
Date: Mon, 23 Mar 2009 11:27:53 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: BUG?: PAGE_FLAGS_CHECK_AT_PREP seems to be cleared too early
	(Was Re: I just got got another Oops
Message-ID: <20090323112752.GA6484@csn.ul.ie>
References: <200903120133.11583.gene.heskett@gmail.com> <49B8C98D.3020309@davidnewall.com> <200903121431.49437.gene.heskett@gmail.com> <20090316115509.40ea13da.kamezawa.hiroyu@jp.fujitsu.com> <20090316170359.858e7a4e.kamezawa.hiroyu@jp.fujitsu.com> <Pine.LNX.4.64.0903162101110.13164@blonde.anvils> <20090320152313.GL24586@csn.ul.ie> <Pine.LNX.4.64.0903221356200.20915@blonde.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0903221356200.20915@blonde.anvils>
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh@veritas.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Gene Heskett <gene.heskett@gmail.com>, David Newall <davidn@davidnewall.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Sun, Mar 22, 2009 at 02:55:08PM +0000, Hugh Dickins wrote:
> On Fri, 20 Mar 2009, Mel Gorman wrote:
> > On Mon, Mar 16, 2009 at 09:44:11PM +0000, Hugh Dickins wrote:
> > > On Mon, 16 Mar 2009, KAMEZAWA Hiroyuki wrote:
> > > > 
> > > > PAGE_FLAGS_CHECK_AT_PREP is cleared by free_pages_check().
> > > > This means PG_head/PG_tail(PG_compound) flags are cleared here
> > > 
> > > Yes, well spotted.  How embarrassing.  I must have got confused
> > > about when the checking occurred when freeing a compound page.
> > 
> > I noticed this actually during the page allocator work and concluded
> > it didn't matter because free_pages_check() cleared out the bits in
> > the same way destroy_compound_page() did. The big difference was that
> > destroy_compound_page() did a lot more sanity checks and was slower.
> > 
> > I accidentally fixed this (because I implemented what I though things
> > should be doing instead of what they were really doing) at one point and
> > the overhead was so high of the debugging check that I just made a note to
> > "deal with this later, it's weird looking but ok".
> 
> I'm surprised the overhead was so high: I'd have imagined that it
> was just treading on the same cachelines as free_pages_check()
> already did, doing rather less work.
> 

My recollection is that it looked heavy because I was running netperf which
was allocating on one CPU and freeing on the other, incurring a cache miss
for every page it wrote to. This showed up heavily in profiles as you might
imagine. However, this penalty would also be hit in free_pages_check() if
destroy_compound_page() had not run so that skewed my perception. Still, we are
running over the same array of pages twice, when we could have done it once.

> > 
> > > > and Compound page will never be freed in sane way.
> > > 
> > > But is that so?  I'll admit I've not tried this out yet, but my
> > > understanding is that the Compound page actually gets freed fine:
> > > free_compound_page() should have passed the right order down, and this
> > > PAGE_FLAGS_CHECK_AT_PREP clearing should remove the Head/Tail/Compound
> > > flags - doesn't it all work out sanely, without any leaking?
> > > 
> > 
> > That's more or less what I thought. It can't leak but it's not what you
> > expect from compound page destructors either.
> > 
> > > What goes missing is all the destroy_compound_page() checks:
> > > that's at present just dead code.
> > > 
> > > There's several things we could do about this.
> > > 
> > > 1.  We could regard destroy_compound_page() as legacy debugging code
> > > from when compound pages were first introduced, and sanctify my error
> > > by removing it.  Obviously that's appealing to me, makes me look like
> > > a prophet rather than idiot!  That's not necessarily the right thing to
> > > do, but might appeal also to those cutting overhead from page_alloc.c.
> > > 
> > 
> > The function is pretty heavy it has to be said. This would be my preferred
> > option rather than making the allocator go slower.
> 
> KAMEZAWA-san has voted for 2, so that was what I was intending to do.
> But if destroy_compound_page() really is costly, I'm happy to throw
> it out if others agree.
> 

I withdraw the objection on the grounds that 2 is the more correct
option of the two. Even though it is heavy, it is also possible to hold
compound pages on the PCP lists for a time and can be avoided in more
ways than one.

> I don't think it actually buys us a great deal: the main thing it checks
> (looking forward to the reuse of the pages, rather than just checking
> that what was set up is still there) is that the order being freed is
> not greater than the order that was allocated; but I think a PG_buddy
> or a page->_count in the excess should catch that in free_pages_check().
> 
> And we don't have any such check for the much(?) more common case of
> freeing a non-compound high-order page.
> 

We have a similar check sortof. It looks like this

        for (i = 0 ; i < (1 << order) ; ++i)
                bad += free_pages_check(page + i);

This is where we are walking over the array twice. One way of fixing this would
be to move the free_pages_check() higher in the call chain for high-order
pages and have destroy_compound_page() first checkec the tail pages know
where their head is and then call free_pages_check(). That should re-enable
just the debugging check without too much cost.

> > > 2.  We could do the destroy_compound_page() stuff in free_compound_page()
> > > before calling __free_pages_ok(), and add the Head/Tail/Compound flags
> > > into PAGE_FLAGS_CHECK_AT_FREE.  hat seems a more natural ordering to
> > > me, and would remove the PageCompound check from a hotter path; but
> > > I've a suspicion there's a good reason why it was not done that way,
> > > that I'm overlooking at this moment.
> > > 
> > 
> > I made this change and dropped it on the grounds it slowed things up so
> > badly. It was part of allowing compound pages to be on the PCP lists.
> > and ended up looking something like
> > 
> > static void free_compound_page(struct page *page)
> > {
> >        unsigned int order = compound_order(page);
> > 
> >        VM_BUG_ON(!PageCompound(page));
> >        if (unlikely(destroy_compound_page(page, order)))
> >                return;
> > 
> >        __free_pages_ok(page, order);
> > }
> 
> Yes, that's how I was imagining it.   But I think we'd also want
> to change hugetlb.c's set_compound_page_dtor(page, NULL) to
> set_compound_page_dtor(page, free_compound_page), wouldn't we?

For full correctness, yes. As it is, it happens to work because the
compound flags get cleared and destroy_compound_page() is little more
than a debug check.

> So far as I can see, that's the case that led the destroy call
> to be sited in __free_one_page(), but I still don't get why it
> was done that way.
> 

I don't recall any reasoning but probably because it just worked. The
first time huge pages had a destructor set to NULL was commit
41d78ba55037468e6c86c53e3076d1a74841de39 and it appears to have been
carried forward ever since.

> > 
> > > 3.  We can define a PAGE_FLAGS_CLEAR_AT_FREE which omits the Head/Tail/
> > > Compound flags, and lets destroy_compound_page() be called as before
> > > where it's currently intended.
> > > 
> > 
> > Also did that, slowed things up. Tried fixing destroy_compound_page()
> > but it was doing the same work as free_pages_check() so it also sucked.
> > 
> > > What do you think?  I suspect I'm going to have to spend tomorrow
> > > worrying about something else entirely, and won't return here until
> > > Wednesday.
> > > 
> > > But as regards the original "I just got got another Oops": my bug
> > > that you point out here doesn't account for that, does it?  It's
> > > still a mystery, isn't it, how the PageTail bit came to be set at
> > > that point?
> > > 
> > > But that Oops does demonstrate that it's a very bad idea to be using
> > > the deceptive page_count() in those bad_page() checks: we need to be
> > > checking page->_count directly.
> 
> I notice your/Nick's 20/25 addresses this issue, good - I'd even be
> happy to see that change go into 2.6.29, though probably too late now
> (and it has been that way forever). 

Agreed, although that change is an accident essentially. It's not super
clear to me it would help but I haven't looked closely enough at the oops
to have a useful opinion.

> But note, it does need one of us
> to replace the page_count in bad_page() in the same way, that's missing.
> 
> I've given up on trying to understand how that PageTail is set in
> Gene's oops.  I was thinking that it got left behind somewhere
> because of my destroy_compound_page sequence error, but I just
> can't see how: I wonder if it's just a corrupt bit in the struct.
> 

I can't see how it can be left behind either as it should have been
getting clobbered. If it was something like inappropriate buddy merging,
a lot more would have broken.

> I don't now feel that we need to rush a fix for my error into 2.6.29:
> it does appear to be working nicely enough with that inadvertent
> change, and we're not yet agreed on which way to go from here.
> 
> > > 
> > > And in looking at this, I notice something else to worry about:
> > > that CONFIG_HUGETLBFS prep_compound_gigantic_page(), which seems
> > > to exist for a more general case than "p = page + i" - what happens
> > > when such a gigantic page is freed, and arrives at the various
> > > "p = page + i" assumptions on the freeing path?
> > > 
> > 
> > That function is a bit confusing I'll give you that. Glancing through,
> > what happens is that the destuctor gets replaced with a free_huge_page()
> > which throws the page onto those free lists instead. It never hits the
> > buddy lists on the grounds they can't handle orders >= MAX_ORDER.
> 
> Ah yes, thanks a lot, I'd forgotten all that.  Yes, there appear to
> be adequate MAX_ORDER checks in hugetlb.c to prevent that danger.
> 
> > 
> > Out of curiousity,
> 
> My curiosity is very limited at the moment, I'm afraid I've not glanced.
> 

No harm. 

> > here is a patch that was intended for a totally different
> > purpose but ended up forcing destroy_compound_page() to be used. It sucked
> > so I ended up unfixing it again. It can't be merged as-is obviously but
> > you'll see I redefined your flags a bit to exclude the compound flags
> > and all that jazz. It could be rebased of course but it'd make more sense
> > to have destroy_compound_page() that only does real work for DEBUG_VM as
> > free_pages_check() already does enough work.
> 
> Yes, putting it under DEBUG_VM could be a compromise; though by now I've
> persuaded myself that it's of little value, and the times it might catch
> something would be out there without DEBUG_VM=y.
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
