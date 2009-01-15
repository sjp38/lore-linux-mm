Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id F12056B005C
	for <linux-mm@kvack.org>; Thu, 15 Jan 2009 01:03:36 -0500 (EST)
Date: Thu, 15 Jan 2009 07:03:30 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch] SLQB slab allocator
Message-ID: <20090115060330.GB17810@wotan.suse.de>
References: <20090114090449.GE2942@wotan.suse.de> <84144f020901140253s72995188vb35a79501c38eaa3@mail.gmail.com> <20090114114707.GA24673@wotan.suse.de> <84144f020901140544v56b856a4w80756b90f5b59f26@mail.gmail.com> <20090114142200.GB25401@wotan.suse.de> <84144f020901140645o68328e01ne0e10ace47555e19@mail.gmail.com> <20090114150900.GC25401@wotan.suse.de> <Pine.LNX.4.64.0901141158090.26507@quilx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0901141158090.26507@quilx.com>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>, Lin Ming <ming.m.lin@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, Jan 14, 2009 at 12:01:32PM -0600, Christoph Lameter wrote:
> On Wed, 14 Jan 2009, Nick Piggin wrote:
> 
> > Right, but that regression isn't my only problem with SLUB. I think
> > higher order allocations could be much more damaging for more a wider
> > class of users. It is less common to see higher order allocation failure
> > reports in places other than lkml, where people tend to have systems
> > stay up longer and/or do a wider range of things with them.
> 
> The higher orders can fail and will then result in the allocator doing
> order 0 allocs. It is not a failure condition.

But they increase pressure on the resource and reduce availability to
other higher order allocations. They accelerate the breakdown of the
anti-frag heuristics, and they make slab internal fragmentation worse.
They also simply cost more to allocate and free and reclaim.


> Higher orders are an
> advantage because they localize variables of the same type and therefore
> reduce TLB pressure.

They are also a disadvantage. The disadvantages are very real. The
advantage is a bit theoretical (how much really is it going to help
going from 4K to 32K, if you still have hundreds or thousands of
slabs anyway?). Also, there is no reason why the other allocators
cannot use higher orer allocations, but their big advantage is that
they don't need to.

 
> > The idea of removing queues doesn't seem so good to me. Queues are good.
> > You amortize or avoid all sorts of things with queues. We have them
> > everywhere in the kernel ;)
> 
> Queues require maintenance which introduces variability because queue
> cleaning has to be done periodically and the queues grow in number if NUMA
> scenarios have to be handled effectively. This is a big problem for low
> latency applications (like in HPC). Spending far too much time optimizing
> queue cleaning in SLAB lead to the SLUB idea.

I'd like to see any real numbers showing this is a problem. Queue
trimming in SLQB can easily be scaled or tweaked to change latency
characteristics. The fact is that it isn't a very critical or highly
tuned operation. It happens _very_ infrequently in the large scheme
of things, and could easily be changed if there is a problem.

What you have in SLUB IMO is not obviously better because it effectively
has sizeable queues in higher order partial and free pages and the
active page, which simply never get trimmed, AFAIKS. This can be harmful
for slab internal fragmentation as well in some situations.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
