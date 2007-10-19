From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: SLUB: Avoid atomic operation for slab_unlock
Date: Fri, 19 Oct 2007 12:12:00 +1000
References: <Pine.LNX.4.64.0710181514310.3584@schroedinger.engr.sgi.com> <200710191156.43049.nickpiggin@yahoo.com.au> <Pine.LNX.4.64.0710181858240.4685@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0710181858240.4685@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200710191212.00653.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Friday 19 October 2007 12:01, Christoph Lameter wrote:
> On Fri, 19 Oct 2007, Nick Piggin wrote:
> > > Yes that is what I attempted to do with the write barrier. To my
> > > knowledge there are no reads that could bleed out and I wanted to avoid
> > > a full fence instruction there.
> >
> > Oh, OK. Bit risky ;) You might be right, but anyway I think it
> > should be just as fast with the optimised bit_unlock on most
> > architectures.
>
> How expensive is the fence? An store with release semantics would be safer
> and okay for IA64.

I'm not sure, I had an idea it was relatively expensive on ia64,
but I didn't really test with a good workload (a microbenchmark
probably isn't that good because it won't generate too much out
of order memory traffic that needs to be fenced).


> > Which reminds me, it would be interesting to test the ia64
> > implementation I did. For the non-atomic unlock, I'm actually
> > doing an atomic operation there so that it can use the release
> > barrier rather than the mf. Maybe it's faster the other way around
> > though? Will be useful to test with something that isn't a trivial
> > loop, so the slub case would be a good benchmark.
>
> Lets avoid mf (too expensive) and just use a store with release semantics.

OK, that's what I've done at the moment.


> Where can I find your patchset? I looked through lkml but did not see it.

Infrastructure in -mm, starting at bitops-introduce-lock-ops.patch.
bit_spin_lock-use-lock-bitops.patch and ia64-lock-bitops.patch are
ones to look at.

The rest of the patches I have queued here, apart from the SLUB patch,
I guess aren't so interesting to you (they don't do anything fancy
like convert to non-atomic unlocks, just switch things like page and
buffer locks to use new bitops).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
