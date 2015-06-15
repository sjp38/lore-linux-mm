Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f43.google.com (mail-qg0-f43.google.com [209.85.192.43])
	by kanga.kvack.org (Postfix) with ESMTP id BD3A36B0032
	for <linux-mm@kvack.org>; Mon, 15 Jun 2015 11:51:53 -0400 (EDT)
Received: by qgal13 with SMTP id l13so6466058qga.3
        for <linux-mm@kvack.org>; Mon, 15 Jun 2015 08:51:53 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d11si5883607qhc.108.2015.06.15.08.51.52
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Jun 2015 08:51:52 -0700 (PDT)
Subject: [PATCH 0/7] slub: bulk alloc and free for slub allocator
From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Mon, 15 Jun 2015 17:51:45 +0200
Message-ID: <20150615155053.18824.617.stgit@devil>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: netdev@vger.kernel.org, Alexander Duyck <alexander.duyck@gmail.com>, Jesper Dangaard Brouer <brouer@redhat.com>

With this patchset SLUB allocator now both have bulk alloc and free
implemented.

(This patchset is based on DaveM's net-next tree on-top of commit
c3eee1fb1d308.  Tested patchset applied on-top of volatile linux-next
commit aa036f86e1bf ("slub bulk alloc: extract objects from the per
cpu slab"))

This mostly optimizes the "fastpath" where objects are available on
the per CPU fastpath page.  This mostly amortize the less-heavy
none-locked cmpxchg_double used on fastpath.

The "fallback bulking" (e.g __kmem_cache_free_bulk) provides a good
basis for comparison, but to avoid counting the overhead of the
function call in benchmarking[1] I've used an inlined versions of
these.

Tested on (very fast) CPU i7-4790K @ 4.00GHz, thus look at cycles
count (as nanosec measurements are very low given the clock rate).

Baseline normal fastpath (alloc+free cost): 43 cycles(tsc) 10.814 ns

Bulk - Fallback bulking           - fastpath-bulking
   1 -  47 cycles(tsc) 11.921 ns  -  45 cycles(tsc) 11.461 ns   improved  4.3%
   2 -  46 cycles(tsc) 11.649 ns  -  28 cycles(tsc)  7.023 ns   improved 39.1%
   3 -  46 cycles(tsc) 11.550 ns  -  22 cycles(tsc)  5.671 ns   improved 52.2%
   4 -  45 cycles(tsc) 11.398 ns  -  19 cycles(tsc)  4.967 ns   improved 57.8%
   8 -  45 cycles(tsc) 11.303 ns  -  17 cycles(tsc)  4.298 ns   improved 62.2%
  16 -  44 cycles(tsc) 11.221 ns  -  17 cycles(tsc)  4.423 ns   improved 61.4%
  30 -  75 cycles(tsc) 18.894 ns  -  57 cycles(tsc) 14.497 ns   improved 24.0%
  32 -  73 cycles(tsc) 18.491 ns  -  56 cycles(tsc) 14.227 ns   improved 23.3%
  34 -  75 cycles(tsc) 18.962 ns  -  58 cycles(tsc) 14.638 ns   improved 22.7%
  48 -  80 cycles(tsc) 20.049 ns  -  64 cycles(tsc) 16.247 ns   improved 20.0%
  64 -  87 cycles(tsc) 21.929 ns  -  74 cycles(tsc) 18.598 ns   improved 14.9%
 128 -  98 cycles(tsc) 24.511 ns  -  89 cycles(tsc) 22.295 ns   improved  9.2%
 158 - 101 cycles(tsc) 25.389 ns  -  93 cycles(tsc) 23.390 ns   improved  7.9%
 250 - 104 cycles(tsc) 26.170 ns  - 100 cycles(tsc) 25.112 ns   improved  3.8%

Benchmarking shows impressive improvements in the "fastpath" with a
small number of objects in the working set.  Once the working set
increases, resulting in activating the "slowpath" (that contains the
heavier locked cmpxchg_double) the improvement decreases.

I'm currently working on also optimizing the "slowpath" (as network
stack use-case hits this), but this patchset should provide a good
foundation for further improvements.

Rest of my patch queue in this area needs some more work, but
preliminary results are good.  I'm attending Netfilter Workshop[2]
next week, and I'll hopefully return working on further improvements
in this area.

[1] https://github.com/netoptimizer/prototype-kernel/blob/master/kernel/mm/slab_bulk_test01.c
[2] http://workshop.netfilter.org/2015/
---

Christoph Lameter (2):
      slab: infrastructure for bulk object allocation and freeing
      slub bulk alloc: extract objects from the per cpu slab

Jesper Dangaard Brouer (5):
      slub: reduce indention level in kmem_cache_alloc_bulk()
      slub: fix error path bug in kmem_cache_alloc_bulk
      slub: kmem_cache_alloc_bulk() move clearing outside IRQ disabled section
      slub: improve bulk alloc strategy
      slub: initial bulk free implementation


 include/linux/slab.h |   10 +++++
 mm/slab.c            |   13 +++++++
 mm/slab.h            |    9 +++++
 mm/slab_common.c     |   23 ++++++++++++
 mm/slob.c            |   13 +++++++
 mm/slub.c            |   93 ++++++++++++++++++++++++++++++++++++++++++++++++++
 6 files changed, 161 insertions(+)

--
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
