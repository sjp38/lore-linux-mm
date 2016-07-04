Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id A73FB828E1
	for <linux-mm@kvack.org>; Mon,  4 Jul 2016 00:34:11 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id f126so57548474wma.3
        for <linux-mm@kvack.org>; Sun, 03 Jul 2016 21:34:11 -0700 (PDT)
Received: from outbound-smtp11.blacknight.com (outbound-smtp11.blacknight.com. [46.22.139.16])
        by mx.google.com with ESMTPS id h4si1056083wjg.171.2016.07.03.21.34.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 03 Jul 2016 21:34:10 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp11.blacknight.com (Postfix) with ESMTPS id EAEA51C1B8B
	for <linux-mm@kvack.org>; Mon,  4 Jul 2016 05:34:09 +0100 (IST)
Date: Mon, 4 Jul 2016 05:34:05 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 00/31] Move LRU page reclaim from zones to nodes v8
Message-ID: <20160704043405.GB11498@techsingularity.net>
References: <1467403299-25786-1-git-send-email-mgorman@techsingularity.net>
 <20160704013703.GA19943@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20160704013703.GA19943@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Jul 04, 2016 at 10:37:03AM +0900, Minchan Kim wrote:
> > The reason we have zone-based reclaim is that we used to have
> > large highmem zones in common configurations and it was necessary
> > to quickly find ZONE_NORMAL pages for reclaim. Today, this is much
> > less of a concern as machines with lots of memory will (or should) use
> > 64-bit kernels. Combinations of 32-bit hardware and 64-bit hardware are
> > rare. Machines that do use highmem should have relatively low highmem:lowmem
> > ratios than we worried about in the past.
> 
> Hello Mel,
> 
> I agree the direction absolutely. However, I have a concern on highmem
> system as you already mentioned.
> 
> Embedded products still use 2 ~ 3 ratio (highmem:lowmem).
> In such system, LRU churning by skipping other zone pages frequently
> might be significant for the performance.
> 
> How big ratio between highmem:lowmem do you think a problem?
> 

That's a "how long is a piece of string" type question.  The ratio does
not matter as much as whether the workload is both under memory pressure
and requires large amounts of lowmem pages. Even on systems with very high
ratios, it may not be a problem if HIGHPTE is enabled.

> > 
> > Conceptually, moving to node LRUs should be easier to understand. The
> > page allocator plays fewer tricks to game reclaim and reclaim behaves
> > similarly on all nodes. 
> > 
> > The series has been tested on a 16 core UMA machine and a 2-socket 48
> > core NUMA machine. The UMA results are presented in most cases as the NUMA
> > machine behaved similarly.
> 
> I guess you would already test below with various highmem system(e.g.,
> 2:1, 3:1, 4:1 and so on). If you have, could you mind sharing it?
> 

I haven't that data, the baseline distribution used doesn't even have
32-bit support. Even if it was, the results may not be that interesting.
The workloads used were not necessarily going to trigger lowmem pressure
as HIGHPTE was set on the 32-bit configs.

The skip logic has been checked and it does work. This was done during 
development, by forcing the "wrong" reclaim index to use. It was
noticable in system CPU usage and in the "skip" stats. I didn't preserve
this data.

> >                              4.7.0-rc4   4.7.0-rc4
> >                           mmotm-20160623nodelru-v8
> > Minor Faults                    645838      644036
> > Major Faults                       573         593
> > Swap Ins                             0           0
> > Swap Outs                            0           0
> > Allocation stalls                   24           0
> > DMA allocs                           0           0
> > DMA32 allocs                  46041453    44154171
> > Normal allocs                 78053072    79865782
> > Movable allocs                       0           0
> > Direct pages scanned             10969       54504
> > Kswapd pages scanned          93375144    93250583
> > Kswapd pages reclaimed        93372243    93247714
> > Direct pages reclaimed           10969       54504
> > Kswapd efficiency                  99%         99%
> > Kswapd velocity              13741.015   13711.950
> > Direct efficiency                 100%        100%
> > Direct velocity                  1.614       8.014
> > Percentage direct scans             0%          0%
> > Zone normal velocity          8641.875   13719.964
> > Zone dma32 velocity           5100.754       0.000
> > Zone dma velocity                0.000       0.000
> > Page writes by reclaim           0.000       0.000
> > Page writes file                     0           0
> > Page writes anon                     0           0
> > Page reclaim immediate              37          54
> > 
> > kswapd activity was roughly comparable. There were differences in direct
> > reclaim activity but negligible in the context of the overall workload
> > (velocity of 8 pages per second with the patches applied, 1.6 pages per
> > second in the baseline kernel).
> 
> Hmm, nodelru's allocation stall is zero above but how does direct page
> scanning/reclaimed happens?
> 

Good spot, it's because I used the wrong comparison script -- one that
doesn't understand the different skip and allocation stats and I was
looking primarily at the scanning activity. This is a correct version

                             4.7.0-rc4   4.7.0-rc4
                          mmotm-20160623nodelru-v8r26
Minor Faults                    645838      643815
Major Faults                       573         493
Swap Ins                             0           0
Swap Outs                            0           0
DMA allocs                           0           0
DMA32 allocs                  46041453    44174923
Normal allocs                 78053072    79816443
Movable allocs                       0           0
Allocation stalls                   24          31
Stall zone DMA                       0           0
Stall zone DMA32                     0           0
Stall zone Normal                    0           1
Stall zone HighMem                   0           0
Stall zone Movable                   0          30
Direct pages scanned             10969       14198
Kswapd pages scanned          93375144    93252534
Kswapd pages reclaimed        93372243    93249856
Direct pages reclaimed           10969       14198
Kswapd efficiency                  99%         99%
Kswapd velocity              13741.015   13742.771
Direct efficiency                 100%        100%
Direct velocity                  1.614       2.092
Percentage direct scans             0%          0%
Page writes by reclaim               0           0
Page writes file                     0           0
Page writes anon                     0           0
Page reclaim immediate              37          29

The points about kswapd and direct reclaim activity still hold.

> Above, DMA32 allocs in nodelru is almost same but zone dma32 velocity
> is zero. What does it means?
> 

It's a consequence of using the wrong script when cutting and pasting
the final data. With node-lru, "zone dma32 velocity" is meaningless and
the reporting script no longer includes it.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
