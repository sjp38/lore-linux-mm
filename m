Date: Fri, 20 Jul 2007 14:08:49 +0100
Subject: Re: [PATCH] Remove unnecessary smp_wmb from clear_user_highpage()
Message-ID: <20070720130848.GA15214@skynet.ie>
References: <20070718150514.GA21823@skynet.ie> <Pine.LNX.4.64.0707181645590.26413@blonde.wat.veritas.com> <20070719021743.GC23641@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20070719021743.GC23641@wotan.suse.de>
From: mel@skynet.ie (Mel Gorman)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Hugh Dickins <hugh@veritas.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On (19/07/07 04:17), Nick Piggin didst pronounce:
> On Wed, Jul 18, 2007 at 05:45:22PM +0100, Hugh Dickins wrote:
> > On Wed, 18 Jul 2007, Mel Gorman wrote:
> > > 
> > > At the nudging of Andrew, I was checking to see if the architecture-specific
> > > implementations of alloc_zeroed_user_highpage() can be removed or not.
> > 
> > Ah, so that was part of the deal for getting MOVABLE in, eh ;-?
> > 
> > > With the exception of barriers, the differences are negligible and the main
> > > memory barrier is in clear_user_highpage(). However, it's unclear why it's
> > > needed. Do you mind looking at the following patch and telling me if it's
> > > wrong and if so, why?
> > > 
> > > Thanks a lot.
> > 
> > I laugh when someone approaches me with a question on barriers ;)
> > I usually get confused and have to go ask someone else.
> > 
> > And I should really to leave this query to Nick: he'll be glad of the
> > opportunity to post his PageUptodate memorder patches again (looking
> > in my mailbox I see versions from February, but I'm pretty sure he put
> > out a more compact, less scary one later on).  He contends that the
> > barrier in clear_user_highpage should not be there, but instead
> > barriers (usually) needed when setting and testing PageUptodate.
> > 
> > Andrew and I weren't entirely convinced: I don't think we found
> > him wrong, just didn't find time to think about it deeply enough,
> > suspicious of a fix in search of a problem, scared by the extent
> > of the first patch, put off by the usual host of __..._nolock
> > variants and micro-optimizations.  It is worth another look.
> 
> Well, at least I probably won't have to debug the remaining problem --
> the IBM guys will :)
> 

I weep for joy. I'll go looking for a test case for this. It sounds like
something that we'll need anyway if this area is to be kicked at all.

> > But setting aside PageUptodate futures...  "git blame" is handy,
> > and took me to the patch from Linus appended.  I think there's
> > as much need for that smp_wmb() now as there was then.  (But
> > am I really _thinking_?  No, just pointing you in directions.)
> > 
> > > ===
> > > 
> > >     This patch removes an unnecessary write barrier from clear_user_highpage().
> > >     
> > >     clear_user_highpage() is called from alloc_zeroed_user_highpage() on a
> > >     number of architectures and from clear_huge_page(). However, these callers
> > >     are already protected by the necessary memory barriers due to spinlocks
> > 
> > Be careful: as Linus indicates, spinlocks on x86 act as good barriers,
> > but on some architectures they guarantee no more than is strictly
> > necessary.  alpha, powerpc and ia64 spring to my mind as particularly
> > difficult ordering-wise, but I bet there are others too.
> 
> The problem cases here are those which don't provide an smp_mb() over
> locks (eg. ones which only give acquire semantics). I think these only
> are ia64 and powerpc.

If IA64 has these sort of semantics, then it's current behaviour is
buggy unless their call to flush_dcache_page() has a similar effect to
having a write barrier elsewhere. I'll ask them.

> Of those, I think only powerpc implementations have
> a really deep out of order memory system (at least on the store side)...
> which is probably why they see and have to fix most of our barrier
> problems :)
> 

Yeah, this could be more of the same.

> 
> > >     in the fault path and the page should not be visible on other CPUs anyway
> > 
> > The page may not be intentionally visible on another CPU yet.  But imagine
> > interesting stale data in the page being cleared, and another thread
> > peeking racily at unfaulted areas, hoping to catch sight of that data.
> > 
> > >     making the barrier unnecessary. A hint of lack of necessity is that there
> > >     does not appear to be a read barrier anywhere for this zeroed page.
> > 
> > Yes, I think Nick was similarly suspicious of a wmb without an rmb; but
> > Linus is _very_ barrier-savvy, so we might want to ask him about it (CC'ed).
> 
> I was not so suspicious in the page fault case: there is a causal
> ordering between loading the valid pte and dereferencing it to load
> the page data. Potentially I think alpha is the only thing that
> could have problems here, but a) if any implementations did hardware
> TLB fills, they would have to do the rmb in microcode; and b) the
> software path appears to use the regular fault handler, so it would
> be subject to synchronisatoin via ptl. But maybe they are unsafe...
> 

One way to find out. Minimally, I think the cleanup here if it exists at
all is to replace the arch-specific alloc_zeroed helpers with barrier and
no-barrier versions and have architectures specify when they do not require
barrier to exist so the default behaviour is the safer choice. At least the
issue will be a bit clearer then to the next guy. IA64 will still be the
different but maybe it can be brought in line with other arches behaviour.

> What I am worried about is exactly the same race at the read(2)/write(2)
> level where there is _no_ spinlock synchronisation, and no wmb, let
> alone a rmb :)
> 

Where is the race in read/write that is affected by the behaviour of
clear_user_highpage()? Is it where a sparse file is mmap()ed and being read
at the same time or what?

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
