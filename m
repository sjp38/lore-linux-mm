Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 9D7876B01EE
	for <linux-mm@kvack.org>; Mon, 12 Apr 2010 04:47:32 -0400 (EDT)
Date: Mon, 12 Apr 2010 10:45:39 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: hugepages will matter more in the future
Message-ID: <20100412084539.GJ5656@random.random>
References: <4BC19916.20100@redhat.com>
 <20100411110015.GA10149@elte.hu>
 <4BC1B034.4050302@redhat.com>
 <20100411115229.GB10952@elte.hu>
 <alpine.LFD.2.00.1004110814080.3576@i5.linux-foundation.org>
 <4BC1EE13.7080702@redhat.com>
 <alpine.LFD.2.00.1004110844420.3576@i5.linux-foundation.org>
 <4BC1F31E.2050009@redhat.com>
 <20100412074557.GA18485@elte.hu>
 <20100412081431.GT5683@laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100412081431.GT5683@laptop>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Ingo Molnar <mingo@elte.hu>, Avi Kivity <avi@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Jason Garrett-Glaser <darkshikari@gmail.com>, Mike Galbraith <efault@gmx.de>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Arjan van de Ven <arjan@infradead.org>
List-ID: <linux-mm.kvack.org>

On Mon, Apr 12, 2010 at 06:14:31PM +1000, Nick Piggin wrote:
> I don't see how these are the logical choices. I don't really see how
> they are even logical in some ways. Let's say that Andrea's patches
> offer 5% improvement in best-cases (that are not stupid microbenchmarks)
> and 0% in worst cases, and X% "on average" (whatever that means). Then
> it is simply a set of things to weigh against the added complexity (both
> in terms of code and performance characteristics of the system) that it
> is introduced.

gcc 8% boost with translate.o has been ruled out as useless benchmark,
but note that definitely it isn't. Yeah maybe one can write that .c
file so it won't take 22 seconds to build, but that's not the point. I
wanted to demonstrates there will be lots of other apps taking
advantage of this. Linux isn't used only to run gcc, people runs
simulations that grows up to unknown amounts of memory on a daily
basis on Linux, it's just I used gcc as example as to show even a gcc
file that we build maybe 2 times a day gets a 8% boost and because gcc
is the most commonly run compute intensive program purely CPU bound
that we're familiar with. If I was building chips instead of writing
kernel, I would have run one of those simulations instead of gcc to
build qemu-kvm translate.

And once I won't have to run khugepaged to move all gcc memory into
hugepages maybe even the kernel build will get a boost ("maybe"
because I'm not convinced, it sounds too good to be true, but it will
try it out later for curiosity ;).

So I think so far what we can be very relaxed to claim is that in real
life "_best_ case" on host without virt the improvement is really ~8%
(and much bigger boost already measured with virt >15%, the best case
of virt I don't know yet).

> I don't really see how it is fundamentally different to any other patch
> that speeds things up.

This is exactly true, the speedup has to be balanced against the
complexity introduced.

I'll add a few more points that can help the evaluation.

You can be 100% sure this can't destabilize *anything* if you echo
never >enabled or boot with transparent_hugepage=0. Furthermore if you
enable embedded and set CONFIG_TRANSPARENT_HUGEPAGE=n 99% of the
new code won't even be built.

The 8% best case speedup should be reproducible on all hardware from
my $150 workstation (maybe even on UP x86 32bit) and even atom UP to
the 4096 cpus numa system (there hopefully it'll be more than 8%
because of the much bigger skew between l2 cache in core and remote
numa memory).

The 8% boost surely will be possible to reproduce with really optimal
written apps and it's not only AIM.

It's not like anon-vma design change that will microslowdown the fast
paths, make head hurts, cannot be disabled at runtime, and it allows
to see a boost only in badly designed apps (Avi once told me fork is
useless, well I don't entirely agree but surely it's not something
good apps should be heavy user of, it's more about going simpler for
something not really enterprise or performance critical, the fact
certain DB uses fork is I think caused by proprietary source designs
and not technical issues).

It's not like speculative pagecache that not only boosts only certain
workloads, and only if you have so many CPUs on the large SMP and
cannot be opted out or disabled if it's unstable.

So it's more complex maybe, but it's zero risk if disabled at runtime
or compile time and it provides at constant speedup to optimally
written apps (huge speedup in case of EPT/NPT). And yeah it'd be cool
if there was a better CPU than the ones with EPT/NPT, surely if
somebody can invent something better than that, tons of people would
be interested, considering little stuff (Google being one of the
exceptions) runs on bare metal these days.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
