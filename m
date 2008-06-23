Date: Mon, 23 Jun 2008 03:49:40 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch] mm: fix race in COW logic
Message-ID: <20080623014940.GA29413@wotan.suse.de>
References: <20080622153035.GA31114@wotan.suse.de> <Pine.LNX.4.64.0806221742330.31172@blonde.site> <alpine.LFD.1.10.0806221033200.2926@woody.linux-foundation.org> <Pine.LNX.4.64.0806221854050.5466@blonde.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0806221854050.5466@blonde.site>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Sun, Jun 22, 2008 at 07:10:41PM +0100, Hugh Dickins wrote:
> On Sun, 22 Jun 2008, Linus Torvalds wrote:
> > On Sun, 22 Jun 2008, Hugh Dickins wrote:
> > 
> > > One thing though, in moving the page_remove_rmap in that way, aren't
> > > you assuming that there's an appropriate wmbarrier between the two
> > > locations?  If that is necessarily so (there's plenty happening in
> > > between), it may deserve a comment to say just where that barrier is.
> > 
> > In this case, I don't think memory ordering matters.
> > 
> > What matters is that the map count never goes down to one - and by 
> > re-ordering the inc/dec accesses, that simply won't happen. IOW, memory 
> > ordering is immaterial, only the ordering of count updates (from the 
> > standpoint of the faulting CPU - so that's not even an SMP issue) matters.
> 
> I'm puzzled.  The page_remove_rmap has moved to the other side of the
> page_add_new_anon_rmap, but they are operating on different pages.
> It's true that the total of their mapcounts doesn't go down to one
> in the critical area, but that total isn't computed anywhere.
> 
> After asking, I thought the answer was going to be that page_remove_rmap
> uses atomic_add_negative, and atomic ops which return a value do
> themselves provide sufficient barrier.  I'm wondering if that's so
> obvious that you've generously sought out a different meaning to my query.

I was initially thinking an smp_wmb might have been in order (excuse the pun),
but then I rethought it and added the 2d paragraph to my comment. But I may
still have been wrong. Let's ignore the barriers implicit in the rmap
functions for now, and if we find they are required we can add a nice
/* smp_wmb() for ..., provided by ...! */

Now. The critical memory operations AFAIKS are:

			dec page->mapcount
load page->mapcount (== 1)
store pte (RW)
store via pte
							load via pte
			ptep_clear_flush
			store new pte

Note that I don't believe the page_add_new_anon_rmap is part of the critical
ordering. Unless that is for a different issue?

Now if we move the decrement of page->mapcount to below the ptep_clear_flush,
then our TLB shootdown protocol *should* guarantee that nothing may load via
that pte after page->mapcount has been decremented, right?

Now we only have pairwise barrier semantics, so if the leftmost process is
not part of the TLB shootdown (which it is not), then it is possible that
it may see the store to decrement the mapcount before the store to clear the
pte. Maybe. I was hoping causality would not allow a subsequent store through
the pte to be seen by the rightmost guy before the TLB flush. But maybe I
was wrong? (at any rate, page_remove_rmap gives us smp_wmb if required, so
the code is not technically wrong)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
