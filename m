Date: Mon, 23 Jun 2008 11:04:31 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [patch] mm: fix race in COW logic
In-Reply-To: <20080623014940.GA29413@wotan.suse.de>
Message-ID: <Pine.LNX.4.64.0806231015140.3513@blonde.site>
References: <20080622153035.GA31114@wotan.suse.de> <Pine.LNX.4.64.0806221742330.31172@blonde.site>
 <alpine.LFD.1.10.0806221033200.2926@woody.linux-foundation.org>
 <Pine.LNX.4.64.0806221854050.5466@blonde.site> <20080623014940.GA29413@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, 23 Jun 2008, Nick Piggin wrote:
> On Sun, Jun 22, 2008 at 07:10:41PM +0100, Hugh Dickins wrote:
> > On Sun, 22 Jun 2008, Linus Torvalds wrote:
> > > On Sun, 22 Jun 2008, Hugh Dickins wrote:
> > > 
> > > > One thing though, in moving the page_remove_rmap in that way, aren't
> > > > you assuming that there's an appropriate wmbarrier between the two
> > > > locations?  If that is necessarily so (there's plenty happening in
> > > > between), it may deserve a comment to say just where that barrier is.
...
> I was initially thinking an smp_wmb might have been in order (excuse the pun),
> but then I rethought it and added the 2d paragraph to my comment.

First off, I've a bewildering and shameful confession and apology
to make: I made that suggestion that you add a comment without even
reading through the comment you had made!  Ugh (at myself)!  Sorry
for that.  I've a suspicion that the longer a comment is, the more
likely my eye will skip over it...

> But I may
> still have been wrong. Let's ignore the barriers implicit in the rmap
> functions for now, and if we find they are required we can add a nice
> /* smp_wmb() for ..., provided by ...! */

Well, okay, but we're discussing a minuscule likelihood on top of the
minuscule likelihood of the race you astutely identified.  So I don't
want to waste anyone's time with an academic exercise; but if any of
us learn something from it, then it may be worth it.

> 
> Now. The critical memory operations AFAIKS are:
> 
> 			dec page->mapcount
> load page->mapcount (== 1)
> store pte (RW)
> store via pte
> 							load via pte
> 			ptep_clear_flush
> 			store new pte
> 
> Note that I don't believe the page_add_new_anon_rmap is part of the critical
> ordering. Unless that is for a different issue?

Agreed, the page_add_new_anon_rmap is irrelevant to this, it only got
mentioned when I was trying to make sense of the mail Linus retracted.

> 
> Now if we move the decrement of page->mapcount to below the ptep_clear_flush,
> then our TLB shootdown protocol *should* guarantee that nothing may load via
> that pte after page->mapcount has been decremented, right?

Via that old pte, yes.  But page->_mapcount is not held at a
virtual address affected by the TLB shootdown, so I don't see how the
ptep_clear_flush would give a guarantee on the visibility of the mapcount
change.  Besides which, the shootdown hits the right hand CPU not the left.

I think it likely that any implementation of ptep_clear_flush would
include instructions which give that guarantee (particularly since
it has to do something inter-CPU to handle the CPU on the right);
but I don't see how ptep_clear_flush gives that guarantee itself.

> 
> Now we only have pairwise barrier semantics, so if the leftmost process is
> not part of the TLB shootdown (which it is not), then it is possible that
> it may see the store to decrement the mapcount before the store to clear the
> pte. Maybe. I was hoping causality would not allow a subsequent store through
> the pte to be seen by the rightmost guy before the TLB flush. But maybe I
> was wrong?

If you're amidst the maybes, imagine the darkness I'm in!
And I'm not adding much to the argument with that remark,
so please don't feel obliged to respond.

> (at any rate, page_remove_rmap gives us smp_wmb if required, so
> the code is not technically wrong)

Originally I came at the question because it seemed to me that if
moving the page_remove_rmap down was to be fully effective, it needed
to move through a suitable barrier; it hadn't occurred to me that it
was carrying the suitable barrier with it.  But if that is indeed
correct, I think it would be better to rely upon that, than resort
to more difficult arguments.

I would love to find a sure-footed way to think about memory barriers,
but I don't think I'll ever get the knack; particularly when even you
and Paul and Linus can sometimes be caught in doubt.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
