Date: Sun, 13 May 2007 05:32:10 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [rfc] optimise unlock_page
Message-ID: <20070513033210.GA3667@wotan.suse.de>
References: <20070508113709.GA19294@wotan.suse.de> <20070508114003.GB19294@wotan.suse.de> <1178659827.14928.85.camel@localhost.localdomain> <20070508224124.GD20174@wotan.suse.de> <20070508225012.GF20174@wotan.suse.de> <Pine.LNX.4.64.0705091950080.2909@blonde.wat.veritas.com> <20070510033736.GA19196@wotan.suse.de> <Pine.LNX.4.64.0705101935590.18496@blonde.wat.veritas.com> <20070511085424.GA15352@wotan.suse.de> <Pine.LNX.4.64.0705111357120.3350@blonde.wat.veritas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0705111357120.3350@blonde.wat.veritas.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, linux-arch@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, May 11, 2007 at 02:15:03PM +0100, Hugh Dickins wrote:
> On Fri, 11 May 2007, Nick Piggin wrote:
> > 
> > Don't worry, I'm only just beginning ;) Can we then do something crazy
> > like this?  (working on x86-64 only, so far. It seems to eliminate
> > lat_pagefault and lat_proc regressions here).
> 
> I think Mr __NickPiggin_Lock is squirming ever more desperately.

Really? I thought it was pretty cool to be able to shave several
hundreds of cycles off our page lock :)


> So, in essence, you'd like to expand PG_locked from 1 to 8 bits,
> despite the fact that page flags are known to be in short supply?
> Ah, no, you're keeping it near the static mmzone FLAGS_RESERVED.

Yep, no flags bloating at all.


> Hmm, well, I think that's fairly horrid, and would it even be
> guaranteed to work on all architectures?  Playing with one char
> of an unsigned long in one way, while playing with the whole of
> the unsigned long in another way (bitops) sounds very dodgy to me.

Of course not, but they can just use a regular atomic word sized
bitop. The problem with i386 is that its atomic ops also imply
memory barriers that you obviously don't need on unlock. So I think
getting rid of them is pretty good. A grep of mm/ and fs/ for
lock_page tells me we want this to be as fast as possible even
if it isn't being used in the nopage fastpath.


> I think I'd rather just accept that your changes have slowed some
> microbenchmarks down: it is not always possible to fix a serious
> bug without slowing something down.  That's probably what you're
> trying to push me into saying by this patch ;)

Well I was resigned to that few % regression in the page fault path
until the G5 numbers showed that we needed to improve things. But
now it looks like (at least on my 2*HT P4 Xeon) that we don't have to
have any regression there.


> But again I wonder just what the gain has been, once your double
> unmap_mapping_range is factored in.  When I suggested before that
> perhaps the double (well, treble including the one in truncate.c)
> unmap_mapping_range might solve the problem you set out to solve
> (I've lost sight of that!) without pagelock when faulting, you said:
> 
> > Well aside from being terribly ugly, it means we can still drop
> > the dirty bit where we'd otherwise rather not, so I don't think
> > we can do that.
> 
> but that didn't give me enough information to agree or disagree.

Oh, well invalidate wants to be able to skip dirty pages or have the
filesystem do something special with them first. Once you have taken
the page out of the pagecache but still mapped shared, then blowing
it away doesn't actually solve the data loss problem... only makes
the window of VM inconsistency smaller.


> > What architecture and workloads are you testing with, btw?
> 
> i386 (2*HT P4 Xeons), x86_64 (2*HT P4 Xeons), PowerPC (G5 Quad).
> 
> Workloads mostly lmbench and my usual pair of make -j20 kernel builds,
> one to tmpfs and one to ext2 looped on tmpfs, restricted to 512M RAM
> plus swap.  Which is ever so old but still finds enough to keep me busy.

Thanks,
Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
