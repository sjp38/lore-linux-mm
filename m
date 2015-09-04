Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 3AEBC6B0038
	for <linux-mm@kvack.org>; Fri,  4 Sep 2015 14:09:24 -0400 (EDT)
Received: by pacex6 with SMTP id ex6so31063313pac.0
        for <linux-mm@kvack.org>; Fri, 04 Sep 2015 11:09:23 -0700 (PDT)
Received: from mail-pa0-x233.google.com (mail-pa0-x233.google.com. [2607:f8b0:400e:c03::233])
        by mx.google.com with ESMTPS id ko10si5405926pbc.208.2015.09.04.11.09.23
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Sep 2015 11:09:23 -0700 (PDT)
Received: by pacfv12 with SMTP id fv12so31577283pac.2
        for <linux-mm@kvack.org>; Fri, 04 Sep 2015 11:09:23 -0700 (PDT)
Subject: Re: [RFC PATCH 0/3] Network stack, first user of SLAB/kmem_cache bulk
 free API.
References: <20150824005727.2947.36065.stgit@localhost>
 <20150904165944.4312.32435.stgit@devil>
From: Alexander Duyck <alexander.duyck@gmail.com>
Message-ID: <55E9DE51.7090109@gmail.com>
Date: Fri, 4 Sep 2015 11:09:21 -0700
MIME-Version: 1.0
In-Reply-To: <20150904165944.4312.32435.stgit@devil>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>, netdev@vger.kernel.org, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, aravinda@linux.vnet.ibm.com, Christoph Lameter <cl@linux.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, iamjoonsoo.kim@lge.com

On 09/04/2015 10:00 AM, Jesper Dangaard Brouer wrote:
> During TX DMA completion cleanup there exist an opportunity in the NIC
> drivers to perform bulk free, without introducing additional latency.
>
> For an IPv4 forwarding workload the network stack is hitting the
> slowpath of the kmem_cache "slub" allocator.  This slowpath can be
> mitigated by bulk free via the detached freelists patchset.
>
> Depend on patchset:
>   http://thread.gmane.org/gmane.linux.kernel.mm/137469
>
> Kernel based on MMOTM tag 2015-08-24-16-12 from git repo:
>   git://git.kernel.org/pub/scm/linux/kernel/git/mhocko/mm.git
>   Also contains Christoph's patch "slub: Avoid irqoff/on in bulk allocation"
>
>
> Benchmarking: Single CPU IPv4 forwarding UDP (generator pktgen):
>   * Before: 2043575 pps
>   * After : 2090522 pps
>   * Improvements: +46947 pps and -10.99 ns
>
> In the before case, perf report shows slub free hits the slowpath:
>   1.98%  ksoftirqd/6  [kernel.vmlinux]  [k] __slab_free.isra.72
>   1.29%  ksoftirqd/6  [kernel.vmlinux]  [k] cmpxchg_double_slab.isra.71
>   0.95%  ksoftirqd/6  [kernel.vmlinux]  [k] kmem_cache_free
>   0.95%  ksoftirqd/6  [kernel.vmlinux]  [k] kmem_cache_alloc
>   0.20%  ksoftirqd/6  [kernel.vmlinux]  [k] __cmpxchg_double_slab.isra.60
>   0.17%  ksoftirqd/6  [kernel.vmlinux]  [k] ___slab_alloc.isra.68
>   0.09%  ksoftirqd/6  [kernel.vmlinux]  [k] __slab_alloc.isra.69
>
> After the slowpath calls are almost gone:
>   0.22%  ksoftirqd/6  [kernel.vmlinux]  [k] __cmpxchg_double_slab.isra.60
>   0.18%  ksoftirqd/6  [kernel.vmlinux]  [k] ___slab_alloc.isra.68
>   0.14%  ksoftirqd/6  [kernel.vmlinux]  [k] __slab_free.isra.72
>   0.14%  ksoftirqd/6  [kernel.vmlinux]  [k] cmpxchg_double_slab.isra.71
>   0.08%  ksoftirqd/6  [kernel.vmlinux]  [k] __slab_alloc.isra.69
>
>
> Extra info, tuning SLUB per CPU structures gives further improvements:
>   * slub-tuned: 2124217 pps
>   * patched increase: +33695 pps and  -7.59 ns
>   * before  increase: +80642 pps and -18.58 ns
>
> Tuning done:
>   echo 256 > /sys/kernel/slab/skbuff_head_cache/cpu_partial
>   echo 9   > /sys/kernel/slab/skbuff_head_cache/min_partial
>
> Without SLUB tuning, same performance comes with kernel cmdline "slab_nomerge":
>   * slab_nomerge: 2121824 pps
>
> Test notes:
>   * Notice very fast CPU i7-4790K CPU @ 4.00GHz
>   * gcc version 4.8.3 20140911 (Red Hat 4.8.3-9) (GCC)
>   * kernel 4.1.0-mmotm-2015-08-24-16-12+ #271 SMP
>   * Generator pktgen UDP single flow (pktgen_sample03_burst_single_flow.sh)
>   * Tuned for forwarding:
>    - unloaded netfilter modules
>    - Sysctl settings:
>    - net/ipv4/conf/default/rp_filter = 0
>    - net/ipv4/conf/all/rp_filter = 0
>    - (Forwarding performance is affected by early demux)
>    - net/ipv4/ip_early_demux = 0
>    - net.ipv4.ip_forward = 1
>    - Disabled GRO on NICs
>    - ethtool -K ixgbe3 gro off tso off gso off
>
> ---

This is an interesting start.  However I feel like it might work better 
if you were to create a per-cpu pool for skbs that could be freed and 
allocated in NAPI context.  So for example we already have 
napi_alloc_skb, why not just add a napi_free_skb and then make the array 
of objects to be freed part of a pool that could be used for either 
allocation or freeing?  If the pool runs empty you just allocate 
something like 8 or 16 new skb heads, and if you fill it you just free 
half of the list?

- Alex

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
