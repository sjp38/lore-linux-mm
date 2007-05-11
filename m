Date: Fri, 11 May 2007 14:15:03 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [rfc] optimise unlock_page
In-Reply-To: <20070511085424.GA15352@wotan.suse.de>
Message-ID: <Pine.LNX.4.64.0705111357120.3350@blonde.wat.veritas.com>
References: <20070508113709.GA19294@wotan.suse.de> <20070508114003.GB19294@wotan.suse.de>
 <1178659827.14928.85.camel@localhost.localdomain> <20070508224124.GD20174@wotan.suse.de>
 <20070508225012.GF20174@wotan.suse.de> <Pine.LNX.4.64.0705091950080.2909@blonde.wat.veritas.com>
 <20070510033736.GA19196@wotan.suse.de> <Pine.LNX.4.64.0705101935590.18496@blonde.wat.veritas.com>
 <20070511085424.GA15352@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, linux-arch@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 11 May 2007, Nick Piggin wrote:
> On Thu, May 10, 2007 at 08:14:52PM +0100, Hugh Dickins wrote:
> > 
> > Well, on the x86_64 I have seen a few of your io_schedule_timeout
> > printks under load; but suspect those are no fault of your changes,
> 
> Hmm, I see... well I forgot to remove those from the page I sent,
> the timeouts will kick things off again if they get stalled, so
> maybe it just hides a problem? (OTOH, I *think* the logic is pretty
> sound).

As I said in what you snipped, I believe your debug there is showing
up an existing problem on my machine, not a problem in your changes.

> > So here it looks like a good change; but not enough to atone ;)
> 
> Don't worry, I'm only just beginning ;) Can we then do something crazy
> like this?  (working on x86-64 only, so far. It seems to eliminate
> lat_pagefault and lat_proc regressions here).

I think Mr __NickPiggin_Lock is squirming ever more desperately.

So, in essence, you'd like to expand PG_locked from 1 to 8 bits,
despite the fact that page flags are known to be in short supply?
Ah, no, you're keeping it near the static mmzone FLAGS_RESERVED.

Hmm, well, I think that's fairly horrid, and would it even be
guaranteed to work on all architectures?  Playing with one char
of an unsigned long in one way, while playing with the whole of
the unsigned long in another way (bitops) sounds very dodgy to me.

I think I'd rather just accept that your changes have slowed some
microbenchmarks down: it is not always possible to fix a serious
bug without slowing something down.  That's probably what you're
trying to push me into saying by this patch ;)

But again I wonder just what the gain has been, once your double
unmap_mapping_range is factored in.  When I suggested before that
perhaps the double (well, treble including the one in truncate.c)
unmap_mapping_range might solve the problem you set out to solve
(I've lost sight of that!) without pagelock when faulting, you said:

> Well aside from being terribly ugly, it means we can still drop
> the dirty bit where we'd otherwise rather not, so I don't think
> we can do that.

but that didn't give me enough information to agree or disagree.

> 
> What architecture and workloads are you testing with, btw?

i386 (2*HT P4 Xeons), x86_64 (2*HT P4 Xeons), PowerPC (G5 Quad).

Workloads mostly lmbench and my usual pair of make -j20 kernel builds,
one to tmpfs and one to ext2 looped on tmpfs, restricted to 512M RAM
plus swap.  Which is ever so old but still finds enough to keep me busy.

Hugh

> --
> 
> Put PG_locked in its own byte from other PG_bits, so we can use non-atomic
> stores to unlock it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
