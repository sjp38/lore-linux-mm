Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id C840E6B0038
	for <linux-mm@kvack.org>; Wed, 30 Nov 2016 09:06:17 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id bk3so32841317wjc.4
        for <linux-mm@kvack.org>; Wed, 30 Nov 2016 06:06:17 -0800 (PST)
Received: from outbound-smtp02.blacknight.com (outbound-smtp02.blacknight.com. [81.17.249.8])
        by mx.google.com with ESMTPS id s5si7259513wma.130.2016.11.30.06.06.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 30 Nov 2016 06:06:16 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail06.blacknight.ie [81.17.255.152])
	by outbound-smtp02.blacknight.com (Postfix) with ESMTPS id DB0FC992A1
	for <linux-mm@kvack.org>; Wed, 30 Nov 2016 14:06:15 +0000 (UTC)
Date: Wed, 30 Nov 2016 14:06:15 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH] mm: page_alloc: High-order per-cpu page allocator v3
Message-ID: <20161130140615.3bbn7576iwbyc3op@techsingularity.net>
References: <20161127131954.10026-1-mgorman@techsingularity.net>
 <20161130134034.3b60c7f0@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20161130134034.3b60c7f0@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, Linux-Kernel <linux-kernel@vger.kernel.org>, Rick Jones <rick.jones2@hpe.com>, Paolo Abeni <pabeni@redhat.com>

On Wed, Nov 30, 2016 at 01:40:34PM +0100, Jesper Dangaard Brouer wrote:
> 
> On Sun, 27 Nov 2016 13:19:54 +0000 Mel Gorman <mgorman@techsingularity.net> wrote:
> 
> [...]
> > SLUB has been the default small kernel object allocator for quite some time
> > but it is not universally used due to performance concerns and a reliance
> > on high-order pages. The high-order concerns has two major components --
> > high-order pages are not always available and high-order page allocations
> > potentially contend on the zone->lock. This patch addresses some concerns
> > about the zone lock contention by extending the per-cpu page allocator to
> > cache high-order pages. The patch makes the following modifications
> > 
> > o New per-cpu lists are added to cache the high-order pages. This increases
> >   the cache footprint of the per-cpu allocator and overall usage but for
> >   some workloads, this will be offset by reduced contention on zone->lock.
> 
> This will also help performance of NIC driver that allocator
> higher-order pages for their RX-ring queue (and chop it up for MTU).
> I do like this patch, even-though I'm working on moving drivers away
> from allocation these high-order pages.
> 
> Acked-by: Jesper Dangaard Brouer <brouer@redhat.com>
> 

Thanks.

> [...]
> > This is the result from netperf running UDP_STREAM on localhost. It was
> > selected on the basis that it is slab-intensive and has been the subject
> > of previous SLAB vs SLUB comparisons with the caveat that this is not
> > testing between two physical hosts.
> 
> I do like you are using a networking test to benchmark this. Looking at
> the results, my initial response is that the improvements are basically
> too good to be true.
> 

FWIW, LKP independently measured the boost to be 23% so it's expected
there will be different results depending on exact configuration and CPU.

> Can you share how you tested this with netperf and the specific netperf
> parameters? 

The mmtests config file used is
configs/config-global-dhp__network-netperf-unbound so all details can be
extrapolated or reproduced from that.

> e.g.
>  How do you configure the send/recv sizes?

Static range of sizes specified in the config file.

>  Have you pinned netperf and netserver on different CPUs?
> 

No. While it's possible to do a pinned test which helps stability, it
also tends to be less reflective of what happens in a variety of
workloads so I took the "harder" option.

> For localhost testing, when netperf and netserver run on the same CPU,
> you observer half the performance, very intuitively.  When pinning
> netperf and netserver (via e.g. option -T 1,2) you observe the most
> stable results.  When allowing netperf and netserver to migrate between
> CPUs (default setting), the real fun starts and unstable results,
> because now the CPU scheduler is also being tested, and my experience
> is also more "fun" memory situations occurs, as I guess we are hopping
> between more per CPU alloc caches (also affecting the SLUB per CPU usage
> pattern).
> 

Yes which is another reason why I used an unbound configuration. I didn't
want to get an artificial boost from pinned server/client using the same
per-cpu caches. As a side-effect, it may mean that machines with fewer
CPUs get a greater boost as there are fewer per-cpu caches being used.

> > 2-socket modern machine
> >                                 4.9.0-rc5             4.9.0-rc5
> >                                   vanilla             hopcpu-v3
> 
> The kernel from 4.9.0-rc5-vanilla to 4.9.0-rc5-hopcpu-v3 only contains
> this single change right?

Yes.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
