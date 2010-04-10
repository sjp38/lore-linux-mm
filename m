Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 2515B6B01E3
	for <linux-mm@kvack.org>; Sat, 10 Apr 2010 16:01:37 -0400 (EDT)
Date: Sat, 10 Apr 2010 22:00:37 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 00 of 41] Transparent Hugepage Support #17
Message-ID: <20100410200037.GO5708@random.random>
References: <20100405232115.GM5825@random.random>
 <alpine.LFD.2.00.1004051636060.21411@i5.linux-foundation.org>
 <20100406011345.GT5825@random.random>
 <alpine.LFD.2.00.1004051836000.5870@i5.linux-foundation.org>
 <alpine.LFD.2.00.1004051917310.3487@i5.linux-foundation.org>
 <20100406090813.GA14098@elte.hu>
 <20100410184750.GJ5708@random.random>
 <20100410190233.GA30882@elte.hu>
 <4BC0CFF4.5000207@redhat.com>
 <20100410194751.GA23751@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100410194751.GA23751@elte.hu>
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: Avi Kivity <avi@redhat.com>, Mike Galbraith <efault@gmx.de>, Jason Garrett-Glaser <darkshikari@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Sat, Apr 10, 2010 at 09:47:51PM +0200, Ingo Molnar wrote:
> 
> * Avi Kivity <avi@redhat.com> wrote:
> 
> > > I think what would be needed is some non-virtualization speedup example of 
> > > a 'non-special' workload, running on the native/host kernel. 'sort' is an 
> > > interesting usecase - could it be patched to use hugepages if it has to 
> > > sort through lots of data?
> > 
> > In fact it works well unpatched, the 6% I measured was with the system sort.
> 
> Yes - but you intentionally sorted something large - the question is, how big 
> is the slowdown with small sizes (if there's a slowdown), where is the 
> break-even point (if any)?

The only chance there is a slowdown is if try_to_compact_pages or
try_to_free_pages takes longer and runs more frequently with order 9
allocations than try_to_free_pages would on a 0 order allocation. That
is only a problem for short-lived frequent allocations in case memory
compaction fails to provide some hugepage (as it'll run multiple times
even if not needed, which is what the future exponential backoff logic
is about).

This is why I recommended to run any "real life DB" benchmark with
both transparent_hugepage/defrag set to both "always" and
"never". "never" will practically make any slowdown impossible to
measure. The only other case where there's a potential for minor
slowdown compared to 4k pages is COW, the 2M copy will trash the cache
and we need it to use non temporal stores, but even that will be
offseted by having a boost in TLB terms saving memory accesses in the
ptes. Which is my reason for avoiding any optimistic prefault and to
only go huge when we get the TLB benefit in return (not just the
pagefault speedup, the pagefault speedup is a double edge sword, it
trashes more caches so you need more than that for it to be worth it).

> Would be nice to try because there's a lot of transformations within Gimp - 
> and Gimp can be scripted. It's also a test for negatives: if there is an 
> across-the-board _lack_ of speedups, it shows that it's not really general 
> purpose but more specialistic.
> 
> If the optimization is specialistic, then that's somewhat of an argument 
> against automatic/transparent handling. (even though even if the beneficiaries 
> turn out to be only special workloads then transparency still has advantages.)
> 
> > I thought ray tracers with large scenes should show a nice speedup, but 
> > setting this up is beyond my capabilities.
> 
> Oh, this tickled some memories: x264 compressed encoding can be very cache and 
> TLB intense. Something like the encoding of a 350 MB video file:
> 
>   wget http://media.xiph.org/video/derf/y4m/soccer_4cif.y4m       # NOTE: 350 MB!
>   x264 --crf 20 --quiet soccer_4cif.y4m -o /dev/null --threads 4
> 
> would be another thing worth trying with transparent-hugetlb enabled.
> 
> (i've Cc:-ed x264 benchmarking experts - in case i missed something)

It definitely worth trying... nice idea. But we need glibc to increase
vm_end in 2M aligned chunk, otherwise we've to workaround it in the
kernel, for short lived allocations like gcc to take advantage of
this. I managed to get 200M of gcc (of ~500M total) of translate.o
into hugepages with two glibc params, but I want it all in transhuge
before I measure it. I'm running it on the workstation that had 1 day
and half of uptime and it's still building more packages as I write
this and running large vfs loads in /usr and maildir.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
