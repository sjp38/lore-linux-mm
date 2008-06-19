Date: Thu, 19 Jun 2008 12:09:15 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: Can get_user_pages( ,write=1, force=1, ) result in a read-only
 pte and _count=2?
In-Reply-To: <200806191307.04499.nickpiggin@yahoo.com.au>
Message-ID: <Pine.LNX.4.64.0806191154270.7324@blonde.site>
References: <20080618164158.GC10062@sgi.com> <200806190329.30622.nickpiggin@yahoo.com.au>
 <Pine.LNX.4.64.0806181944080.4968@blonde.site> <200806191307.04499.nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Robin Holt <holt@sgi.com>, Ingo Molnar <mingo@elte.hu>, Christoph Lameter <clameter@sgi.com>, Jack Steiner <steiner@sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 19 Jun 2008, Nick Piggin wrote:
> On Thursday 19 June 2008 05:01, Hugh Dickins wrote:
> > On Thu, 19 Jun 2008, Nick Piggin wrote:
> 
> > > But although that feels a bit unclean, I don't think it would cause
> > > a problem because the previous VM_FAULT_WRITE (while under mmap_sem)
> > > ensures our swap page should still be valid to write into via get
> > > user pages (and a subsequent write access should cause do_wp_page to
> > > go through the proper reuse logic and now COW).
> >
> > I think perhaps Robin is wanting to write into the page both from the
> > kernel (hence the get_user_pages) and from userspace: but finding that
> > the attempt to write from userspace breaks COW again (because gup
> > raised the page count and it's a readonly pte), so they end up
> > writing into different pages.  We know that COW didn't need to
> > be broken a second time, but do_wp_page doesn't know that.
> 
> I'm having trouble seeing the path that leads to this situation. I
> can't see what the significance of the elevated page count is?

The trouble is, you're looking at what can_share_swap_page actually
does, instead of letting your mind regress a few years to what it
used to do before we had page_mapcount ;)

Yes, sorry, my page count "explanation" is nonsense.

> 
> We're talking about swap pages, as in do_swap_page? Then AFAIKS it
> is only the mapcount that is taken into account, and get_user_pages
> will first break COW, but that should set mapcount back to 1, in
> which case the userspace access should notice that in do_swap_page
> and prevent the 2nd COW from happening.

(I assume Robin is not forking, we do know that causes this kind
of problem, but he didn't mention any forking so I assume not.)

> 
> Unless, hmm no it can also be called directly via handle_pte_fault,
> and if it happens to fail the trylock_page, I think I do see how it
> can be COWed. But it doesn't seem to have anything to do with page
> count so I don't know if I'm on the right track or maybe missing the
> obvious...

The !TestSetPageLocked (there, now I'm looking at the source!).
Yes, I suppose if it goes the wrong way on that, it would account
for it; though it'd be nice to have some confirmation that's what's
happening.

Over to your next mail...

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
