Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id C852B6B0254
	for <linux-mm@kvack.org>; Fri,  4 Sep 2015 13:00:38 -0400 (EDT)
Received: by padhy16 with SMTP id hy16so27250287pad.1
        for <linux-mm@kvack.org>; Fri, 04 Sep 2015 10:00:38 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id ol6si5238119pab.37.2015.09.04.10.00.37
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Sep 2015 10:00:37 -0700 (PDT)
Subject: [RFC PATCH 0/3] Network stack,
 first user of SLAB/kmem_cache bulk free API.
From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Fri, 04 Sep 2015 19:00:34 +0200
Message-ID: <20150904165944.4312.32435.stgit@devil>
In-Reply-To: <20150824005727.2947.36065.stgit@localhost>
References: <20150824005727.2947.36065.stgit@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: netdev@vger.kernel.org, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, Jesper Dangaard Brouer <brouer@redhat.com>, aravinda@linux.vnet.ibm.com, Christoph Lameter <cl@linux.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, iamjoonsoo.kim@lge.com

During TX DMA completion cleanup there exist an opportunity in the NIC
drivers to perform bulk free, without introducing additional latency.

For an IPv4 forwarding workload the network stack is hitting the
slowpath of the kmem_cache "slub" allocator.  This slowpath can be
mitigated by bulk free via the detached freelists patchset.

Depend on patchset:
 http://thread.gmane.org/gmane.linux.kernel.mm/137469

Kernel based on MMOTM tag 2015-08-24-16-12 from git repo:
 git://git.kernel.org/pub/scm/linux/kernel/git/mhocko/mm.git
 Also contains Christoph's patch "slub: Avoid irqoff/on in bulk allocation"


Benchmarking: Single CPU IPv4 forwarding UDP (generator pktgen):
 * Before: 2043575 pps
 * After : 2090522 pps
 * Improvements: +46947 pps and -10.99 ns

In the before case, perf report shows slub free hits the slowpath:
 1.98%  ksoftirqd/6  [kernel.vmlinux]  [k] __slab_free.isra.72
 1.29%  ksoftirqd/6  [kernel.vmlinux]  [k] cmpxchg_double_slab.isra.71
 0.95%  ksoftirqd/6  [kernel.vmlinux]  [k] kmem_cache_free
 0.95%  ksoftirqd/6  [kernel.vmlinux]  [k] kmem_cache_alloc
 0.20%  ksoftirqd/6  [kernel.vmlinux]  [k] __cmpxchg_double_slab.isra.60
 0.17%  ksoftirqd/6  [kernel.vmlinux]  [k] ___slab_alloc.isra.68
 0.09%  ksoftirqd/6  [kernel.vmlinux]  [k] __slab_alloc.isra.69

After the slowpath calls are almost gone:
 0.22%  ksoftirqd/6  [kernel.vmlinux]  [k] __cmpxchg_double_slab.isra.60
 0.18%  ksoftirqd/6  [kernel.vmlinux]  [k] ___slab_alloc.isra.68
 0.14%  ksoftirqd/6  [kernel.vmlinux]  [k] __slab_free.isra.72
 0.14%  ksoftirqd/6  [kernel.vmlinux]  [k] cmpxchg_double_slab.isra.71
 0.08%  ksoftirqd/6  [kernel.vmlinux]  [k] __slab_alloc.isra.69


Extra info, tuning SLUB per CPU structures gives further improvements:
 * slub-tuned: 2124217 pps
 * patched increase: +33695 pps and  -7.59 ns
 * before  increase: +80642 pps and -18.58 ns

Tuning done:
 echo 256 > /sys/kernel/slab/skbuff_head_cache/cpu_partial
 echo 9   > /sys/kernel/slab/skbuff_head_cache/min_partial

Without SLUB tuning, same performance comes with kernel cmdline "slab_nomerge":
 * slab_nomerge: 2121824 pps

Test notes:
 * Notice very fast CPU i7-4790K CPU @ 4.00GHz
 * gcc version 4.8.3 20140911 (Red Hat 4.8.3-9) (GCC)
 * kernel 4.1.0-mmotm-2015-08-24-16-12+ #271 SMP
 * Generator pktgen UDP single flow (pktgen_sample03_burst_single_flow.sh)
 * Tuned for forwarding:
  - unloaded netfilter modules
  - Sysctl settings:
  - net/ipv4/conf/default/rp_filter = 0
  - net/ipv4/conf/all/rp_filter = 0
  - (Forwarding performance is affected by early demux)
  - net/ipv4/ip_early_demux = 0
  - net.ipv4.ip_forward = 1
  - Disabled GRO on NICs
  - ethtool -K ixgbe3 gro off tso off gso off

---

Jesper Dangaard Brouer (3):
      net: introduce kfree_skb_bulk() user of kmem_cache_free_bulk()
      net: NIC helper API for building array of skbs to free
      ixgbe: bulk free SKBs during TX completion cleanup cycle


 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |   13 +++-
 include/linux/netdevice.h                     |   62 ++++++++++++++++++
 include/linux/skbuff.h                        |    1 
 net/core/skbuff.c                             |   87 ++++++++++++++++++++-----
 4 files changed, 144 insertions(+), 19 deletions(-)

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
