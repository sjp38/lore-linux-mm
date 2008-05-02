Date: Fri, 2 May 2008 03:20:07 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [rfc] data race in page table setup/walking?
Message-ID: <20080502012006.GD30768@wotan.suse.de>
References: <20080429050054.GC21795@wotan.suse.de> <Pine.LNX.4.64.0804291333540.22025@blonde.site> <20080430060340.GE27652@wotan.suse.de> <alpine.LFD.1.10.0804300848390.2997@woody.linux-foundation.org> <20080501002955.GA11312@wotan.suse.de> <alpine.LFD.1.10.0804302020050.5994@woody.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LFD.1.10.0804302020050.5994@woody.linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Hugh Dickins <hugh@veritas.com>, linux-arch@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

On Wed, Apr 30, 2008 at 08:24:48PM -0700, Linus Torvalds wrote:
> 
> On Thu, 1 May 2008, Nick Piggin wrote:

> > But I'm surprised that two writes to the same cacheline (different
> > words) can be reordered. Of course write buffers are technically outside
> > the coherency domain, but I would have thought any implementation will
> > actually treat writes to the same line as aliasing. Is there a counter
> > example?
> 
> I don't know if anybody does it, but no, normally I would *not* expect any 
> alias logic to have anything to do with cachelines. Aliasing within a 
> cacheline is so common (spills to the stack, if nothing else) that if the 
> CPU has some write buffer alias logic, I'd expect it to be byte or perhaps 
> word-granular.
> 
> So I think that at least in theory it is quite possible that a later write 
> hits the same cacheline first, just because the write data or address got 
> resolved first and the architecture allows out-of-order memory accesses. 

I guess it is possible. But at least in the case of write address, you'd
have to wait for later stores anyway in order to do the alias detection,
which might be the most common case.

For other dependencies yes, although I would have thought that you'd be
better off to wait for the earlier write and so they can be combined into
a single cache transaction. The easy part of stores is queueing them,
the hard part is moving them out to cache.

Anyway I'm speculating at this point. You do raise a valid issue, so
obviously we can't make any such assumptions without verifying it on a
per-arch basis ;) I'm just interested to know whether this happens on
any CPU we run on.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
