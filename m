Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 0082B6B0238
	for <linux-mm@kvack.org>; Fri, 30 Apr 2010 11:21:21 -0400 (EDT)
Date: Fri, 30 Apr 2010 17:19:40 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 00 of 41] Transparent Hugepage Support #17
Message-ID: <20100430151940.GG22108@random.random>
References: <4BC0CFF4.5000207@redhat.com>
 <20100410194751.GA23751@elte.hu>
 <4BC0DE84.3090305@redhat.com>
 <4BC0E2C4.8090101@redhat.com>
 <20100410204756.GR5708@random.random>
 <4BC0E6ED.7040100@redhat.com>
 <20100411010540.GW5708@random.random>
 <20100425192739.GG5789@random.random>
 <20100426180110.GC8860@random.random>
 <20100430095543.GB3423@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100430095543.GB3423@elte.hu>
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: Avi Kivity <avi@redhat.com>, Mike Galbraith <efault@gmx.de>, Jason Garrett-Glaser <darkshikari@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Ulrich Drepper <drepper@gmail.com>, Paolo Bonzini <pbonzini@redhat.com>
List-ID: <linux-mm.kvack.org>

On Fri, Apr 30, 2010 at 11:55:43AM +0200, Ingo Molnar wrote:
> 
> * Andrea Arcangeli <aarcange@redhat.com> wrote:
> 
> > Now tried with a kernel compile with gcc patched as in prev email
> > (stock glibc and no glibc environment parameters). Without rebooting
> > (still plenty of hugepages as usual).
> > 
> > always:
> > 
> > real    4m7.280s
> > real    4m7.520s
> > 
> > never:
> > 
> > real    4m13.754s
> > real    4m14.095s
> > 
> > So the kernel now builds 2.3% faster. As expected nothing huge here
> > because of gcc not using several hundred hundred mbytes of ram (unlike
> > translate.o or other more pathological files), and there's lots of
> > cpu time spent not just in gcc.
> > 
> > Clearly this is not done for gcc (but for JVM and other workloads with
> > larger working sets), but even a kernel build running more than 2%
> > faster I think is worth mentioning as it confirms we're heading
> > towards the right direction.
> 
> Was this done on a native/host kernel?

Correct, no virt, just bare metal.

> I.e. do everyday kernel hackers gain 2.3% of kbuild performance from this?

Yes I already get benefit from this in my work.

> 
> I find that a very large speedup - it's much more than what i'd have expected.
>
> Are you absolutely 100% sure it's real? If yes, it would be nice to underline 

200% sure, at least on the phenom X4 with 1 socket 4 cores and 800mhz
ddr2 ram! Why don't you try yourself? You've just to use aa.git + the
gcc patch I posted applied to gcc and nothing else. This is what I'm
using in all my systems to actively benefit from it already.

I've also seen numbers on JVM benchmarks even on host much bigger than
10% with zero userland modifications (as long as the allocation is
done in big chunks everything works automatic and critical regions are
usually allocated in big chunks, even gcc has the GGC_QUIRE_SIZE but
it had to be tuned from 1m to 2m and aligned).

The only crash I had was the one I fixed in the last release that was
a race between migrate.c and exec.c that would trigger even without
THP or memory compaction, I had zero problems so far.

> that by gathering some sort of 'perf stat --repeat 3 --all' kind of 
> always/never comparison of those kernel builds, so that we can see where the 
> +2.3% comes from.

I can do that. I wasn't sure if perf would deal well with such a macro
benchmark, I didn't try yet.

> I'd expect to see roughly the same instruction count (within noise), but a ~3% 
> reduced cycle count (due to fewer/faster TLB fills).

Also note, before I did the few liner patch to gcc so it always use
transparent hugepages in its garbage collector code, the kernel build
was a little slower with transparent hugepage = always. The reason is
likely that make or cpp or gcc itself, were trashing the cache in
hugepage cows for data accesses that didn't benefit from the hugetlb,
that's my best estimate. Faulting more than 4k at time is not always
beneficial for cows, this is why it's pointless to try to implement
any optimistic prefault logic, because it can backfired on you by just
trashing the cache more. My design ensures every single time we
optimistically fault 2m at once, we also get more than just that
optimistic-fault initial speedup (and unwanted cache trashing and more
latency in the fault because of larger clear-page copy-page) but we
get _much_ more and longstanding: the hugetlb and faster tlb miss. I
never pay the cost of optimistic fault, unless I get a _lot_ more in
return than just entering/exiting the kernel fewer times. In fact the
moment gcc uses hugepages it's not like such cow-cache-trashing cost
goes away, but hugepages TLB effect likely leads to >2.3% gain but
part of it is spent in offseting any minor slowdown in the cows. I
also suspect that with enabled=madvise and madvise called by gcc
ggc-page.c, things may be even faster than 2.3% in fact. But it
entirely depends on the cpu cache sizes, on xeon it may be bigger than
2.3% gain as the cache trashing may not materialize there anywhere, so
I'm sticking to the always option.

Paolo has been very nice sending the gcc extreme tests too, those may
achieve > 10% speedups (considering translate.o of qemu is at 10%
speedup already). I just didn't run those yet because translate.o was
much closer to real life scenario (in fact it is real life for the
better or the worse), but in the future I'll try those gcc tests too
as they're emulating what a real app will have to do in similar
circumstances. They're pathological for gcc, but business as usual for
everything else HPC.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
