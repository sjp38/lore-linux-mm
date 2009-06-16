Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 843126B0055
	for <linux-mm@kvack.org>; Tue, 16 Jun 2009 05:19:02 -0400 (EDT)
Date: Tue, 16 Jun 2009 10:19:32 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: QUESTION: can netdev_alloc_skb() errors be reduced by tuning?
Message-ID: <20090616091932.GB14241@csn.ul.ie>
References: <1243422749-6256-1-git-send-email-mel@csn.ul.ie> <20090527131437.5870e342.akpm@linux-foundation.org> <20090527231949.GB30002@elte.hu> <6.2.5.6.2.20090615201713.05b5d408@binnacle.cx>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <6.2.5.6.2.20090615201713.05b5d408@binnacle.cx>
Sender: owner-linux-mm@kvack.org
To: starlight@binnacle.cx
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, hugh.dickins@tiscali.co.uk, Lee.Schermerhorn@hp.com, kosaki.motohiro@jp.fujitsu.com, ebmunson@us.ibm.com, agl@us.ibm.com, apw@canonical.com, wli@movementarian.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 15, 2009 at 08:19:33PM -0400, starlight@binnacle.cx wrote:
> Hello,
> 
> I submitted testcase for a hugepages bug that has been 
> successfully resolved.  Have an apparently obscure question 
> related to MM, and so I am asking anyone who might have some idea 
> on this.  Nothing much turned up via Google and digging into
> the KMEM code looks daunting.
> 
> Running Intel 82598/ixgbe 10 gig Ethernet under heavy stress. 
> Generally is working well after tuning IRQ affinities, but a 
> fair number of buffer allocation failures are occurring in the 
> 'ixgbe' device driver and are reported via 'ethtool' statistics. 
>  This may be causing data loss.
> 

Can you give an example of an allocation failure? Specifically, I want to
see what sort of allocation it was and what order.

For reliable protocols, an allocation failure should recover and the
data get through but obviously there is a drop in network performance
when this happens.

> The kernel primitive returning the error is netdev_alloc_skb().
> 
> Are any tuneable parameters available that can reduce or 
> eliminate these allocation failures?  Have about eleven 
> gigabytes of free memory, though most of that is consumed 
> by non-dirty file cache data.  Total system memory is 16GB with 
> 4GB allocated to hugepages.  Zero swap usage and activity though
> swap is enabled.  Most application memory is hugepage or is
> 'mlock()'ed.
> 

If the allocations are high-order and atomic, increasing min_free_kbytes
can help, particularly in situations where there is a burst of network
traffic. I won't know if they are atomic until I see an error message
though.

> Thank you.
> 
> 
> 
> 
> 
> System rebooted before test run.
> 
> Dual Xeon E5430, 16GB FB-DIMM RAM.
> 
> 
> $ cat /proc/meminfo
> MemTotal:     16443828 kB
> MemFree:        281176 kB
> Buffers:         53896 kB
> Cached:       11331924 kB
> SwapCached:          0 kB
> Active:         200740 kB
> Inactive:     11284312 kB
> HighTotal:           0 kB
> HighFree:            0 kB
> LowTotal:     16443828 kB
> LowFree:        281176 kB
> SwapTotal:     2031608 kB
> SwapFree:      2031400 kB
> Dirty:               4 kB
> Writeback:           0 kB
> AnonPages:      104464 kB
> Mapped:          14644 kB
> Slab:           440452 kB
> PageTables:       4032 kB
> NFS_Unstable:        0 kB
> Bounce:              0 kB
> CommitLimit:   8156368 kB
> Committed_AS:   122452 kB
> VmallocTotal: 34359738367 kB
> VmallocUsed:    266872 kB
> VmallocChunk: 34359471043 kB
> HugePages_Total:  2048
> HugePages_Free:    735
> HugePages_Rsvd:      0
> Hugepagesize:     2048 kB
> 
> 
> # ethtool -S eth2 | egrep -v ': 0$'
> NIC statistics:
>      rx_packets: 724246449
>      tx_packets: 229847
>      rx_bytes: 152691992335
>      tx_bytes: 10573426
>      multicast: 725997241
>      broadcast: 6
>      rx_csum_offload_good: 723051776
>      alloc_rx_buff_failed: 7119
>      tx_queue_0_packets: 229847
>      tx_queue_0_bytes: 10573426
>      rx_queue_0_packets: 340698332
>      rx_queue_0_bytes: 70844299683
>      rx_queue_1_packets: 385298923
>      rx_queue_1_bytes: 82276167594
> 
> 
> ixgbe driver fragment
> =====================
>     struct sk_buff *skb = netdev_alloc_skb(adapter->netdev, bufsz);
> 
>     if (!skb) {
>         adapter->alloc_rx_buff_failed++;
>         goto no_buffers;
>     }
> 

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
