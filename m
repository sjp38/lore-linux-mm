Date: Thu, 19 Jun 2008 13:34:12 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: Can get_user_pages( ,write=1, force=1, ) result in a read-only
 pte and _count=2?
In-Reply-To: <200806192207.40838.nickpiggin@yahoo.com.au>
Message-ID: <Pine.LNX.4.64.0806191321030.15095@blonde.site>
References: <20080618164158.GC10062@sgi.com> <200806191331.32056.nickpiggin@yahoo.com.au>
 <Pine.LNX.4.64.0806191209370.7324@blonde.site> <200806192207.40838.nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Robin Holt <holt@sgi.com>, Ingo Molnar <mingo@elte.hu>, Christoph Lameter <clameter@sgi.com>, Jack Steiner <steiner@sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 19 Jun 2008, Nick Piggin wrote:
> On Thursday 19 June 2008 21:39, Hugh Dickins wrote:
> 
> > I've had a quick look at my collection of uncompleted/unpublished
> > swap patches, and here's a hunk from one of them which is trying
> > to address that point.  But I'll have to look back and see what
> > else this depends upon.
> >
> > -		if (!TestSetPageLocked(old_page)) {
> > -			reuse = can_share_swap_page(old_page);
> > -			unlock_page(old_page);
> > +		if (page_mapcount(old_page) == 1) {
> > +			extern int page_swapcount(struct page *);
> > +			if (!PageSwapCache(old_page))
> > +				reuse = 1;
> > +			else if (!TestSetPageLocked(old_page)) {
> > +				reuse = !page_is_shared(old_page);
> > +				unlock_page(old_page);
> > +			} else if (!page_swapcount(old_page))
> > +				reuse = 1;
> >
> > I probably won't get back to this today.  And there are also good
> > reasons in -mm for me to check back on all these swapcount issues.
> 
> I don't see how you can get an accurate page_swapcount without
> the page lock.

I doubt it's an accurate swapcount, just a case where one can be
sure of !page_swapcount.  It's certainly not something to take on
trust, patches I need to be sceptical about and refresh my mind on.

> Anyway, if you volunteer to take a look at the problem, great.

I do.

> I expect Robin could just as well fix it for
> their code in the meantime by using force=0...

Sorry, please explain, I don't see that: though their driver happens
to say force=1, I don't think it's needed and I don't think it's
making any difference in this case.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
