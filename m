Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 67A1C6B0038
	for <linux-mm@kvack.org>; Wed, 30 Nov 2016 07:40:42 -0500 (EST)
Received: by mail-qk0-f197.google.com with SMTP id k201so155124649qke.6
        for <linux-mm@kvack.org>; Wed, 30 Nov 2016 04:40:42 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id v88si30140027qte.71.2016.11.30.04.40.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Nov 2016 04:40:41 -0800 (PST)
Date: Wed, 30 Nov 2016 13:40:34 +0100
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH] mm: page_alloc: High-order per-cpu page allocator v3
Message-ID: <20161130134034.3b60c7f0@redhat.com>
In-Reply-To: <20161127131954.10026-1-mgorman@techsingularity.net>
References: <20161127131954.10026-1-mgorman@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: brouer@redhat.com, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, Linux-Kernel <linux-kernel@vger.kernel.org>, Rick Jones <rick.jones2@hpe.com>, Paolo Abeni <pabeni@redhat.com>


On Sun, 27 Nov 2016 13:19:54 +0000 Mel Gorman <mgorman@techsingularity.net> wrote:

[...]
> SLUB has been the default small kernel object allocator for quite some time
> but it is not universally used due to performance concerns and a reliance
> on high-order pages. The high-order concerns has two major components --
> high-order pages are not always available and high-order page allocations
> potentially contend on the zone->lock. This patch addresses some concerns
> about the zone lock contention by extending the per-cpu page allocator to
> cache high-order pages. The patch makes the following modifications
> 
> o New per-cpu lists are added to cache the high-order pages. This increases
>   the cache footprint of the per-cpu allocator and overall usage but for
>   some workloads, this will be offset by reduced contention on zone->lock.

This will also help performance of NIC driver that allocator
higher-order pages for their RX-ring queue (and chop it up for MTU).
I do like this patch, even-though I'm working on moving drivers away
from allocation these high-order pages.

Acked-by: Jesper Dangaard Brouer <brouer@redhat.com>

[...]
> This is the result from netperf running UDP_STREAM on localhost. It was
> selected on the basis that it is slab-intensive and has been the subject
> of previous SLAB vs SLUB comparisons with the caveat that this is not
> testing between two physical hosts.

I do like you are using a networking test to benchmark this. Looking at
the results, my initial response is that the improvements are basically
too good to be true.

Can you share how you tested this with netperf and the specific netperf
parameters? 
e.g.
 How do you configure the send/recv sizes?
 Have you pinned netperf and netserver on different CPUs?

For localhost testing, when netperf and netserver run on the same CPU,
you observer half the performance, very intuitively.  When pinning
netperf and netserver (via e.g. option -T 1,2) you observe the most
stable results.  When allowing netperf and netserver to migrate between
CPUs (default setting), the real fun starts and unstable results,
because now the CPU scheduler is also being tested, and my experience
is also more "fun" memory situations occurs, as I guess we are hopping
between more per CPU alloc caches (also affecting the SLUB per CPU usage
pattern).

> 2-socket modern machine
>                                 4.9.0-rc5             4.9.0-rc5
>                                   vanilla             hopcpu-v3

The kernel from 4.9.0-rc5-vanilla to 4.9.0-rc5-hopcpu-v3 only contains
this single change right?
Netdev/Paolo recently (in net-next) optimized the UDP code path
significantly, and I just want to make sure your results are not
affected by these changes.


> Hmean    send-64         178.38 (  0.00%)      256.74 ( 43.93%)
> Hmean    send-128        351.49 (  0.00%)      507.52 ( 44.39%)
> Hmean    send-256        671.23 (  0.00%)     1004.19 ( 49.60%)
> Hmean    send-1024      2663.60 (  0.00%)     3910.42 ( 46.81%)
> Hmean    send-2048      5126.53 (  0.00%)     7562.13 ( 47.51%)
> Hmean    send-3312      7949.99 (  0.00%)    11565.98 ( 45.48%)
> Hmean    send-4096      9433.56 (  0.00%)    12929.67 ( 37.06%)
> Hmean    send-8192     15940.64 (  0.00%)    21587.63 ( 35.43%)
> Hmean    send-16384    26699.54 (  0.00%)    32013.79 ( 19.90%)
> Hmean    recv-64         178.38 (  0.00%)      256.72 ( 43.92%)
> Hmean    recv-128        351.49 (  0.00%)      507.47 ( 44.38%)
> Hmean    recv-256        671.20 (  0.00%)     1003.95 ( 49.57%)
> Hmean    recv-1024      2663.45 (  0.00%)     3909.70 ( 46.79%)
> Hmean    recv-2048      5126.26 (  0.00%)     7560.67 ( 47.49%)
> Hmean    recv-3312      7949.50 (  0.00%)    11564.63 ( 45.48%)
> Hmean    recv-4096      9433.04 (  0.00%)    12927.48 ( 37.04%)
> Hmean    recv-8192     15939.64 (  0.00%)    21584.59 ( 35.41%)
> Hmean    recv-16384    26698.44 (  0.00%)    32009.77 ( 19.89%)
> 
> 1-socket 6 year old machine
>                                 4.9.0-rc5             4.9.0-rc5
>                                   vanilla             hopcpu-v3
> Hmean    send-64          87.47 (  0.00%)      127.14 ( 45.36%)
> Hmean    send-128        174.36 (  0.00%)      256.42 ( 47.06%)
> Hmean    send-256        347.52 (  0.00%)      509.41 ( 46.59%)
> Hmean    send-1024      1363.03 (  0.00%)     1991.54 ( 46.11%)
> Hmean    send-2048      2632.68 (  0.00%)     3759.51 ( 42.80%)
> Hmean    send-3312      4123.19 (  0.00%)     5873.28 ( 42.45%)
> Hmean    send-4096      5056.48 (  0.00%)     7072.81 ( 39.88%)
> Hmean    send-8192      8784.22 (  0.00%)    12143.92 ( 38.25%)
> Hmean    send-16384    15081.60 (  0.00%)    19812.71 ( 31.37%)
> Hmean    recv-64          86.19 (  0.00%)      126.59 ( 46.87%)
> Hmean    recv-128        173.93 (  0.00%)      255.21 ( 46.73%)
> Hmean    recv-256        346.19 (  0.00%)      506.72 ( 46.37%)
> Hmean    recv-1024      1358.28 (  0.00%)     1980.03 ( 45.77%)
> Hmean    recv-2048      2623.45 (  0.00%)     3729.35 ( 42.15%)
> Hmean    recv-3312      4108.63 (  0.00%)     5831.47 ( 41.93%)
> Hmean    recv-4096      5037.25 (  0.00%)     7021.59 ( 39.39%)
> Hmean    recv-8192      8762.32 (  0.00%)    12072.44 ( 37.78%)
> Hmean    recv-16384    15042.36 (  0.00%)    19690.14 ( 30.90%)
> 
> This is somewhat dramatic but it's also not universal. For example, it was
> observed on an older HP machine using pcc-cpufreq that there was almost
> no difference but pcc-cpufreq is also a known performance hazard.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
