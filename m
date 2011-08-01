Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 7018290014E
	for <linux-mm@kvack.org>; Mon,  1 Aug 2011 06:02:10 -0400 (EDT)
Received: from wpaz21.hot.corp.google.com (wpaz21.hot.corp.google.com [172.24.198.85])
	by smtp-out.google.com with ESMTP id p71A28l1005826
	for <linux-mm@kvack.org>; Mon, 1 Aug 2011 03:02:08 -0700
Received: from gxk23 (gxk23.prod.google.com [10.202.11.23])
	by wpaz21.hot.corp.google.com with ESMTP id p71A24u4023669
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 1 Aug 2011 03:02:06 -0700
Received: by gxk23 with SMTP id 23so3971287gxk.0
        for <linux-mm@kvack.org>; Mon, 01 Aug 2011 03:02:04 -0700 (PDT)
Date: Mon, 1 Aug 2011 03:02:02 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [GIT PULL] Lockless SLUB slowpaths for v3.1-rc1
In-Reply-To: <1312175306.24862.103.camel@jaguar>
Message-ID: <alpine.DEB.2.00.1108010229150.1062@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1107290145080.3279@tiger> <alpine.DEB.2.00.1107291002570.16178@router.home> <alpine.DEB.2.00.1107311136150.12538@chino.kir.corp.google.com> <alpine.DEB.2.00.1107311253560.12538@chino.kir.corp.google.com> <1312145146.24862.97.camel@jaguar>
 <alpine.DEB.2.00.1107311426001.944@chino.kir.corp.google.com> <1312175306.24862.103.camel@jaguar>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, hughd@google.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, 1 Aug 2011, Pekka Enberg wrote:

> > More interesting than the perf report (which just shows kfree, 
> > kmem_cache_free, kmem_cache_alloc dominating) is the statistics that are 
> > exported by slub itself, it shows the "slab thrashing" issue that I 
> > described several times over the past few years.  It's difficult to 
> > address because it's a result of slub's design.  From the client side of 
> > 160 netperf TCP_RR threads for 60 seconds:
> > 
> > 	cache		alloc_fastpath		alloc_slowpath
> > 	kmalloc-256	10937512 (62.8%)	6490753
> > 	kmalloc-1024	17121172 (98.3%)	303547
> > 	kmalloc-4096	5526281			11910454 (68.3%)
> > 
> > 	cache		free_fastpath		free_slowpath
> > 	kmalloc-256	15469			17412798 (99.9%)
> > 	kmalloc-1024	11604742 (66.6%)	5819973
> > 	kmalloc-4096	14848			17421902 (99.9%)
> > 
> > With those stats, there's no way that slub will even be able to compete 
> > with slab because it's not optimized for the slowpath.
> 
> Is the slowpath being hit more often with 160 vs 16 threads?

Here's the same testing environment with CONFIG_SLUB_STATS for 16 threads 
instead of 160:

	cache		alloc_fastpath		alloc_slowpath
	kmalloc-256	4263275 (91.1%)		417445
	kmalloc-1024	4636360	(99.1%)		42091
	kmalloc-4096	2570312	(54.4%)		2155946

	cache		free_fastpath		free_slowpath
	kmalloc-256	210115			4470604 (95.5%)
	kmalloc-1024	3579699	(76.5%)		1098764
	kmalloc-4096	67616			4658678 (98.6%)

Keep in mind that this is a default slub configuration, so kmalloc-256 has 
order-1 slabs and both kmalloc-1k and kmalloc-4k have order-3 slabs.  If 
those were decreased, the free slowpath would become even worse, and if 
those were increased, the alloc slowpath would become even worse.

I could probably get better numbers for 160 threads here if I let the free 
slowpath fall off the charts for kmalloc-256 and kmalloc-4k (which 
wouldn't be that bad, they're used 99.9% of the time) and make the alloc 
slowpath much easier to allocate order-0 slabs.  It depends on how often 
we free to a partial slab, but it's a pointless exercise since users won't 
tune their slab allocator settings for specific caches or each workload.

With regard to kmalloc-256 and kmalloc-4k on the 16 thread experiment, 
the lionshare of the allocations and free fastpath usage comes on the cpu 
taking the networking irq, whereas kmalloc-1k, the lionshare of free 
slowpath usage comes from that cpu.

> As I said,
> the problem you mentioned looks like a *scaling issue* to me which is
> actually somewhat surprising. I knew that the slowpaths were slow but I
> haven't seen this sort of data before.
> 

Well, shoot, I wrote a patchset for it and presented similar data two 
years ago: https://lkml.org/lkml/2009/3/30/14 (back then, kmalloc-2k was 
part of the culprit and now it's kmalloc-4k).  Although I agree that we 
don't want to rely on the heuristics that I created in that patchset for 
things like partial list ordering and it's probably not great to have an 
increment on a kmem_cache_cpu variable in the allocation fastpath, I still 
strongly advocate for some logic that only picks off a partial slab from 
while holding the per-node list_lock when it has a certain threshold of 
free objects, otherwise we keep pulling a partial slab that may have one 
object free and performance suffers.  That logic is part of the patchset 
that I proposed back then and it helped performance, but that still comes 
at the cost of increased memory because we'd be allocating new slabs (and 
potentially order-3 as seen above) instead of utilizing sufficient partial 
slabs when the number of object allocations are low.

I'm thinking this is part of the reason that Nick really advocated for 
optimizing for frees on remote cpus in slqb as a fundamental principle of 
the allocator's design.

> I snipped the 'SLUB can never compete with SLAB' part because I'm
> frankly more interested in raw data I can analyse myself. I'm hoping to
> the per-CPU partial list patch queued for v3.2 soon and I'd be
> interested to know how much I can expect that to help.
> 

See my comment about having no doubt that you can improve performance of 
slub by throwing more memory in its direction, that is part of what the 
per-cpu partial list patchset does.

Christoph posted it as an RFC and listed a few significant disadvantages 
to that approach, but I'm still happy to review it and see what can come 
of it.

>From what I remember, though, each per-cpu partial list had a min_partial 
of half of what it currently is per-node.  On my testing environment that 
I've been using here, they were stated to be two 16-core, 4 node systems 
for netperf client and server.  kmalloc-256 currently has a min_partial of 
8, and both kmalloc-1k and kmalloc-4k have min_partial of 10 for its 
current design of per-node partial lists, so that means we keep at minimum 
(absent kmem_cache_shrink() or reclaim) 8*4 kmalloc-256, 10*4 kmalloc-1k, 
and 10*4 kmalloc-4k empty slabs on the partial lists for later use on each 
of these systems.  With the per-cpu partial lists the way I remember it, 
that would become 4*16 kmalloc-256, 5*16 kmalloc-1k, and 5*16 kmalloc-4k 
empty slabs on the partial lists.  So now we've doubled the amount of 
memory we've reserved for the partial lists, so yeah, I'd expect better 
performance as a result of using (4*16 - 8*4) more order-1 slabs and 2 * 
(5*16 - 10*4) more order-3 slabs, about 700 pages for just those two 
caches systemwide.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
