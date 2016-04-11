Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f41.google.com (mail-qg0-f41.google.com [209.85.192.41])
	by kanga.kvack.org (Postfix) with ESMTP id 376DA6B025E
	for <linux-mm@kvack.org>; Mon, 11 Apr 2016 08:26:46 -0400 (EDT)
Received: by mail-qg0-f41.google.com with SMTP id c6so142142198qga.1
        for <linux-mm@kvack.org>; Mon, 11 Apr 2016 05:26:46 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id y7si20059338qgd.97.2016.04.11.05.26.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Apr 2016 05:26:45 -0700 (PDT)
Date: Mon, 11 Apr 2016 14:26:39 +0200
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] Generic page-pool recycle facility?
Message-ID: <20160411142639.1c5e520b@redhat.com>
In-Reply-To: <20160411085819.GE21128@suse.de>
References: <1460034425.20949.7.camel@HansenPartnership.com>
	<20160407161715.52635cac@redhat.com>
	<20160411085819.GE21128@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: lsf@lists.linux-foundation.org, linux-mm <linux-mm@kvack.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, Brenden Blanco <bblanco@plumgrid.com>, James Bottomley <James.Bottomley@HansenPartnership.com>, Tom Herbert <tom@herbertland.com>, lsf-pc@lists.linux-foundation.org, Alexei Starovoitov <alexei.starovoitov@gmail.com>, brouer@redhat.com

 
On Mon, 11 Apr 2016 09:58:19 +0100 Mel Gorman <mgorman@suse.de> wrote:

> On Thu, Apr 07, 2016 at 04:17:15PM +0200, Jesper Dangaard Brouer wrote:
> > (Topic proposal for MM-summit)
> > 
> > Network Interface Cards (NIC) drivers, and increasing speeds stress
> > the page-allocator (and DMA APIs).  A number of driver specific
> > open-coded approaches exists that work-around these bottlenecks in the
> > page allocator and DMA APIs. E.g. open-coded recycle mechanisms, and
> > allocating larger pages and handing-out page "fragments".
> > 
> > I'm proposing a generic page-pool recycle facility, that can cover the
> > driver use-cases, increase performance and open up for zero-copy RX.
> >   
> 
> Which bottleneck dominates -- the page allocator or the DMA API when
> setting up coherent pages?
>

It is actually both, but mostly DMA on non-x86 archs.  The need to
support multiple archs, then also cause a slowdown on x86, due to a
side-effect.

On arch's like PowerPC, the DMA API is the bottleneck.  To workaround
the cost of DMA calls, NIC driver alloc large order (compound) pages.
(dma_map compound page, handout page-fragments for RX ring, and later
dma_unmap when last RX page-fragments is seen).

The unfortunate side-effect is that these RX page-fragments (which
contain packet data) need to be considered 'read-only', because a
dma_unmap call can be destructive.  Network packets need to be
modified (minimum time-to-live).  Thus, netstack alloc new writable
memory, copy-over IP-headers, and adjust offset pointer into RX-page.
Avoiding the dma_unmap (AFAIK) will allow to make RX-pages writable.

Idea by page-pool is to recycling pages back to the originating
device, then we can avoid the need to call dma_unmap().  And only call
dma_map() when setting up pages.


> I'm wary of another page allocator API being introduced if it's for
> performance reasons. In response to this thread, I spent two days on
> a series that boosts performance of the allocator in the fast paths by
> 11-18% to illustrate that there was low-hanging fruit for optimising. If
> the one-LRU-per-node series was applied on top, there would be a further
> boost to performance on the allocation side. It could be further boosted
> if debugging checks and statistic updates were conditionally disabled by
> the caller.

It is always great if you can optimized the page allocator.  IMHO the
page allocator is too slow.  At least for my performance needs (67ns
per packet, approx 201 cycles at 3GHz).  I've measured[1]
alloc_pages(order=0) + __free_pages() to cost 277 cycles(tsc).

The trick described above, of allocating a higher order page and
handing out page-fragments, also workaround this page allocator
bottleneck (on x86).

I've measured order 3 (32KB) alloc_pages(order=3) + __free_pages() to
cost approx 500 cycles(tsc).  That was more expensive, BUT an order=3
page 32Kb correspond to 8 pages (32768/4096), thus 500/8 = 62.5
cycles.  Usually a network RX-frame only need to be 2048 bytes, thus
the "bulk" effect speed up is x16 (32768/2048), thus 31.25 cycles.

I view this as a bulking trick... maybe the page allocator can just
give us a bulking API? ;-)


> The main reason another allocator concerns me is that those pages
> are effectively pinned and cannot be reclaimed by the VM in low memory
> situations. It ends up needing its own API for tuning the size and hoping
> all the drivers get it right without causing OOM situations. It becomes
> a slippery slope of introducing shrinkers, locking and complexity. Then
> callers start getting concerned about NUMA locality and having to deal
> with multiple lists to maintain performance. Ultimately, it ends up being
> as slow as the page allocator and back to square 1 except now with more code.

The pages assigned to the RX ring queue are pinned like today.  The
pages avail in the pool could easily be reclaimed.

I actually think we are better off providing a generic page pool
interface the drivers can use.  Instead of the situation where drivers
and subsystems invent their own, which does not cooperate in OOM
situations.

For the networking fast forwarding use-case (NOT localhost delivery),
then the page pool size would actually be limited at a fairly small
fixed size.  Packets will be hard dropped if exceeding this limit.
The idea is, you want to limit the maximum latency the system can
introduce then forwarding a packet, even in high overload situations.
There is a good argumentation in section 3.2. of Google's paper[2].
They limit the pool size to 3000 and calculate this can max introduce
300 micro-sec latency.


> If it's the DMA API that dominates then something may be required but it
> should rely on the existing page allocator to alloc/free from. It would
> also need something like drain_all_pages to force free everything in there
> in low memory situations. Remember that multiple instances private to
> drivers or tasks will require shrinker implementations and the complexity
> may get unwieldly.

I'll read up on the shrinker interface.


[1] https://github.com/netoptimizer/prototype-kernel/tree/master/kernel/mm/bench

[2] http://static.googleusercontent.com/media/research.google.com/en//pubs/archive/44824.pdf

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
