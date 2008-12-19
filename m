Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 6769F6B0044
	for <linux-mm@kvack.org>; Fri, 19 Dec 2008 02:46:32 -0500 (EST)
Subject: Re: [rfc][patch] SLQB slab allocator
From: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
In-Reply-To: <20081212002518.GH8294@wotan.suse.de>
References: <20081212002518.GH8294@wotan.suse.de>
Content-Type: text/plain
Date: Fri, 19 Dec 2008 15:48:40 +0800
Message-Id: <1229672920.3277.49.camel@ymzhang>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 2008-12-12 at 01:25 +0100, Nick Piggin wrote:
> (Re)introducing SLQB allocator. Q for queued, but in reality, SLAB and
> SLUB also have queues of things as well, so "Q" is just a meaningless
> differentiator :)
> 
> I've kept working on SLQB slab allocator because I don't agree with the
> design choices in SLUB, and I'm worried about the push to make it the
> one true allocator.
> 
> My primary goal in SLQB is performance, secondarily are order-0 page
> allocations, and memory consumption.
> 
> I have worked with the Linux guys at Intel to ensure that SLQB is comparable
> to SLAB in their OLTP performance benchmark. Recently that goal has been
> reached -- so SLQB performs comparably well to SLAB on that test (it's
> within the noise).
> 
> I've also been comparing SLQB with SLAB and SLUB in other benchmarks, and
> trying to ensure it is as good or better. I don't know if that's always
> the case, but nothing obvious has gone wrong (it's sometimes hard to find
> meaningful benchmarks that exercise slab in interesting ways).
> 
> Now it isn't exactly complete -- debugging, tracking, stats, etc. code is
> not always in the best shape, however I have been focusing on performance
> of the core allocator. No matter how good the rest is if the core code is
> poor... But it boots, works, is pretty stable.
> 
> SLQB, like SLUB and unlike SLAB, doesn't have greater than linear memory
> consumption growth with the number of CPUs or nodes.
> 
> SLQB tries to be very page-size agnostic. And it tries very hard to use
> order-0 pages. This is good for both page allocator fragmentation, and
> slab fragmentation. I don't like that SLUB performs significantly worse
> with order-0 pages in some workloads.
> 
> SLQB goes to some lengths to optimise remote-freeing cases (allocate on
> one CPU, free on another). It seems to work well, but there are a *lot*
> of possible ways this can be implemented especially when NUMA comes into
> play, so I'd like to know of workloads where remote freeing happens a
> lot, and perhaps look at alternative ways to do it.
> 
> SLQB initialistaion code attempts to be as simple and un-clever as possible.
> There are no multiple phases where different things come up. There is no
> weird self bootstrapping stuff. It just statically allocates the structures
> required to create the slabs that allocate other slab structures.
> 
> I'm going to continue working on this as I get time, and I plan to soon ask
> to have it merged. It would be great if people could comment or test it.
Nick,

I tested your patch on a couple of x86-64 machines with kernel 2.6.28-rc8, mostly comparing
with SLUB. I used many benchmarks, such like specjbb/cpu2k/aim7/hackbench/tbench/netperf
/dbench/volanoMark/kbuild/oltp(mysql+sysbench) and so on. The result has no big
difference from the one of SLUB, except:

1) kbuild: On my 8-core stoakley machine, I see about 20% improvement with SLQB. But on
16-core tigerton,there is about 6% regression. I reran the testing with CONFIG_SLUB=y and
'slabinfo -AD' showed kmalloc4096 is proactive.

2) netperf UDP loopback testing: I bind the server process and client process on different
physical cpu. 
	UDP-U-4k: 20% improvement than the one of SLUB;
	UDP-U-1k: less than 2% improvement;
	UDP-RR-1: 3% improvement;
	UDP-RR-512: 2% improvement;
	The improvement on 8-core stoakley is close to the one on 16-core tigerton.
	TCP testing has no such improvement/regression although there might be about 1%~2%
variation.

3) Real network netperf testing: start 64 client processes on 1 machine and 64 servers on
another machine. UDP-RR-1 has about 5% improvement. Others are not so clear.

4) hackbench: On 16-core tigerton, I see about 5% improvement, for example,
	the result(running time) of 'hackbench 100 process 2000' is 24.6(SLUB) versus 23(SLQB).
	But on 8-core stoakley, SLUB result is better than the one of SLQB, less than 5%.
	
5) volanoMark: The result with the default chatroom number (10) has no big difference, but
if I use CPU_NUM*2 as the chatroom number, there is about 5%~12% improvement with SLQB.

SLUB has a good tool, slabinfo, to show lots of useful information, including alloc/free statistics.
SLQB has no such tool, even no such data.

yanmin


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
