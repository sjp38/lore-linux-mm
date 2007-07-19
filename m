Date: Thu, 19 Jul 2007 04:36:45 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [PATCH] Remove unnecessary smp_wmb from clear_user_highpage()
Message-ID: <20070719023645.GD23641@wotan.suse.de>
References: <20070718150514.GA21823@skynet.ie> <Pine.LNX.4.64.0707181645590.26413@blonde.wat.veritas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0707181645590.26413@blonde.wat.veritas.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Mel Gorman <mel@skynet.ie>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 18, 2007 at 05:45:22PM +0100, Hugh Dickins wrote:
> On Wed, 18 Jul 2007, Mel Gorman wrote:
> > 
> > At the nudging of Andrew, I was checking to see if the architecture-specific
> > implementations of alloc_zeroed_user_highpage() can be removed or not.
> 
> Ah, so that was part of the deal for getting MOVABLE in, eh ;-?
> 
> > With the exception of barriers, the differences are negligible and the main
> > memory barrier is in clear_user_highpage(). However, it's unclear why it's
> > needed. Do you mind looking at the following patch and telling me if it's
> > wrong and if so, why?
> > 
> > Thanks a lot.
> 
> I laugh when someone approaches me with a question on barriers ;)
> I usually get confused and have to go ask someone else.
> 
> And I should really to leave this query to Nick: he'll be glad of the
> opportunity to post his PageUptodate memorder patches again (looking
> in my mailbox I see versions from February, but I'm pretty sure he put
> out a more compact, less scary one later on).  He contends that the
> barrier in clear_user_highpage should not be there, but instead
> barriers (usually) needed when setting and testing PageUptodate.

And btw. (I don't think you're confused, but the last sentence could
be mislreading to readers)... I don't contend the barrier should not be
there in that it is _technically_ wrong... but logicaly the condition
we are interested in is whether the page is uptodate or not (the fact
that we only ever have uptodate pages in ptes *cough*, and the causal
dependency on *pte -> page means we don't bother setting or checking
PageUptodate for anonymous faults, but the logical condition we want
is that the page is uptodate).

So when I found that both ordering problems (fault and read(2)) could
be solved with PageUptodate, it just seems like a better place to
put it than in clear_user_highpage.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
