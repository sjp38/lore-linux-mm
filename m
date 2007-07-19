Date: Thu, 19 Jul 2007 04:17:43 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [PATCH] Remove unnecessary smp_wmb from clear_user_highpage()
Message-ID: <20070719021743.GC23641@wotan.suse.de>
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
> 
> Andrew and I weren't entirely convinced: I don't think we found
> him wrong, just didn't find time to think about it deeply enough,
> suspicious of a fix in search of a problem, scared by the extent
> of the first patch, put off by the usual host of __..._nolock
> variants and micro-optimizations.  It is worth another look.

Well, at least I probably won't have to debug the remaining problem --
the IBM guys will :)

 
> But setting aside PageUptodate futures...  "git blame" is handy,
> and took me to the patch from Linus appended.  I think there's
> as much need for that smp_wmb() now as there was then.  (But
> am I really _thinking_?  No, just pointing you in directions.)
> 
> > ===
> > 
> >     This patch removes an unnecessary write barrier from clear_user_highpage().
> >     
> >     clear_user_highpage() is called from alloc_zeroed_user_highpage() on a
> >     number of architectures and from clear_huge_page(). However, these callers
> >     are already protected by the necessary memory barriers due to spinlocks
> 
> Be careful: as Linus indicates, spinlocks on x86 act as good barriers,
> but on some architectures they guarantee no more than is strictly
> necessary.  alpha, powerpc and ia64 spring to my mind as particularly
> difficult ordering-wise, but I bet there are others too.

The problem cases here are those which don't provide an smp_mb() over
locks (eg. ones which only give acquire semantics). I think these only
are ia64 and powerpc. Of those, I think only powerpc implementations have
a really deep out of order memory system (at least on the store side)...
which is probably why they see and have to fix most of our barrier
problems :)


> >     in the fault path and the page should not be visible on other CPUs anyway
> 
> The page may not be intentionally visible on another CPU yet.  But imagine
> interesting stale data in the page being cleared, and another thread
> peeking racily at unfaulted areas, hoping to catch sight of that data.
> 
> >     making the barrier unnecessary. A hint of lack of necessity is that there
> >     does not appear to be a read barrier anywhere for this zeroed page.
> 
> Yes, I think Nick was similarly suspicious of a wmb without an rmb; but
> Linus is _very_ barrier-savvy, so we might want to ask him about it (CC'ed).

I was not so suspicious in the page fault case: there is a causal
ordering between loading the valid pte and dereferencing it to load
the page data. Potentially I think alpha is the only thing that
could have problems here, but a) if any implementations did hardware
TLB fills, they would have to do the rmb in microcode; and b) the
software path appears to use the regular fault handler, so it would
be subject to synchronisatoin via ptl. But maybe they are unsafe...

What I am worried about is exactly the same race at the read(2)/write(2)
level where there is _no_ spinlock synchronisation, and no wmb, let
alone a rmb :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
