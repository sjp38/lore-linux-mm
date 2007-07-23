Date: Mon, 23 Jul 2007 04:02:25 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [PATCH] Remove unnecessary smp_wmb from clear_user_highpage()
Message-ID: <20070723020225.GA18074@wotan.suse.de>
References: <20070718150514.GA21823@skynet.ie> <Pine.LNX.4.64.0707181645590.26413@blonde.wat.veritas.com> <20070719021743.GC23641@wotan.suse.de> <20070720130848.GA15214@skynet.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070720130848.GA15214@skynet.ie>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@skynet.ie>
Cc: Hugh Dickins <hugh@veritas.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jul 20, 2007 at 02:08:49PM +0100, Mel Gorman wrote:
> On (19/07/07 04:17), Nick Piggin didst pronounce:
> > On Wed, Jul 18, 2007 at 05:45:22PM +0100, Hugh Dickins wrote:
> > > 
> > > Andrew and I weren't entirely convinced: I don't think we found
> > > him wrong, just didn't find time to think about it deeply enough,
> > > suspicious of a fix in search of a problem, scared by the extent
> > > of the first patch, put off by the usual host of __..._nolock
> > > variants and micro-optimizations.  It is worth another look.
> > 
> > Well, at least I probably won't have to debug the remaining problem --
> > the IBM guys will :)
> > 
> 
> I weep for joy. I'll go looking for a test case for this. It sounds like
> something that we'll need anyway if this area is to be kicked at all.

Well I'd be happy to fix it right now, but nobody believes me! (I
might be wrong of course, but nobody has told me why).
Yes maybe a test case would help :)


> > > Be careful: as Linus indicates, spinlocks on x86 act as good barriers,
> > > but on some architectures they guarantee no more than is strictly
> > > necessary.  alpha, powerpc and ia64 spring to my mind as particularly
> > > difficult ordering-wise, but I bet there are others too.
> > 
> > The problem cases here are those which don't provide an smp_mb() over
> > locks (eg. ones which only give acquire semantics). I think these only
> > are ia64 and powerpc.
> 
> If IA64 has these sort of semantics, then it's current behaviour is
> buggy unless their call to flush_dcache_page() has a similar effect to
> having a write barrier elsewhere. I'll ask them.
> 
> > Of those, I think only powerpc implementations have
> > a really deep out of order memory system (at least on the store side)...
> > which is probably why they see and have to fix most of our barrier
> > problems :)
> > 
> 
> Yeah, this could be more of the same.
> 
> > I was not so suspicious in the page fault case: there is a causal
> > ordering between loading the valid pte and dereferencing it to load
> > the page data. Potentially I think alpha is the only thing that
> > could have problems here, but a) if any implementations did hardware
> > TLB fills, they would have to do the rmb in microcode; and b) the
> > software path appears to use the regular fault handler, so it would
> > be subject to synchronisatoin via ptl. But maybe they are unsafe...
> > 
> 
> One way to find out. Minimally, I think the cleanup here if it exists at
> all is to replace the arch-specific alloc_zeroed helpers with barrier and
> no-barrier versions and have architectures specify when they do not require
> barrier to exist so the default behaviour is the safer choice. At least the
> issue will be a bit clearer then to the next guy. IA64 will still be the
> different but maybe it can be brought in line with other arches behaviour.

I'd be inclined to unify them and put the barrier in SetPageUptodate
as in my patch. If architectures really can do out of order stores, then
they need it; if not then smp_wmb should be a noop.

We could argue to have a smp_wmb__before_spin_lock, but I'd really rather
do the sane thing first, and then introduce yet another barrier type
after it is proven to have a performance benefit.


> > What I am worried about is exactly the same race at the read(2)/write(2)
> > level where there is _no_ spinlock synchronisation, and no wmb, let
> > alone a rmb :)
> > 
> 
> Where is the race in read/write that is affected by the behaviour of
> clear_user_highpage()? Is it where a sparse file is mmap()ed and being read
> at the same time or what?

No not by the behaviour of clear_user_highpage, but the larger conceptual
problem that pages are being initialised, then made visible to the wider
VM (with SetPageUptodate or set_pte), without an smp_wmb between the stores
to initialise the page and the store to make it visible.

This clear_user_highpage thingy is just a subset of that.

And no, the read/write inconsistency is not just for sparse files: write(2)
writes have the same problem, and even non-sparse reads in some filesystems
(they don't all do DMA: think RAM backed filesystems, ecryptfs, and I think
pktcdvd, possibly NFS, and probably others)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
