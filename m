Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f50.google.com (mail-qg0-f50.google.com [209.85.192.50])
	by kanga.kvack.org (Postfix) with ESMTP id C46926B0070
	for <linux-mm@kvack.org>; Wed, 17 Jun 2015 10:27:57 -0400 (EDT)
Received: by qgf75 with SMTP id 75so15766256qgf.1
        for <linux-mm@kvack.org>; Wed, 17 Jun 2015 07:27:57 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k199si4489260qhc.57.2015.06.17.07.27.56
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Jun 2015 07:27:56 -0700 (PDT)
Subject: [PATCH V2 0/6] slub: bulk alloc and free for slub allocator
From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Wed, 17 Jun 2015 16:26:54 +0200
Message-ID: <20150617142613.11791.76008.stgit@devil>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Jesper Dangaard Brouer <brouer@redhat.com>

With this patchset SLUB allocator now both have bulk alloc and free
implemented.

(This patchset is based on DaveM's net-next tree on-top of commit
89d256bb69f)

This patchset mostly optimizes the "fastpath" where objects are
available on the per CPU fastpath page.  This mostly amortize the
less-heavy none-locked cmpxchg_double used on fastpath.

The "fallback" bulking (e.g __kmem_cache_free_bulk) provides a good
basis for comparison. Measurements[1] of the fallback functions
__kmem_cache_{free,alloc}_bulk have been copied from slab_common.c and
forced "noinline" to force a function call like slab_common.c.

Measurements on CPU CPU i7-4790K @ 4.00GHz
Baseline normal fastpath (alloc+free cost): 42 cycles(tsc) 10.601 ns

Measurements last-patch with disabled debugging:

Bulk- fallback                   - this-patch
  1 -  57 cycles(tsc) 14.448 ns  -  44 cycles(tsc) 11.236 ns  improved 22.8%
  2 -  51 cycles(tsc) 12.768 ns  -  28 cycles(tsc)  7.019 ns  improved 45.1%
  3 -  48 cycles(tsc) 12.232 ns  -  22 cycles(tsc)  5.526 ns  improved 54.2%
  4 -  48 cycles(tsc) 12.025 ns  -  19 cycles(tsc)  4.786 ns  improved 60.4%
  8 -  46 cycles(tsc) 11.558 ns  -  18 cycles(tsc)  4.572 ns  improved 60.9%
 16 -  45 cycles(tsc) 11.458 ns  -  18 cycles(tsc)  4.658 ns  improved 60.0%
 30 -  45 cycles(tsc) 11.499 ns  -  18 cycles(tsc)  4.568 ns  improved 60.0%
 32 -  79 cycles(tsc) 19.917 ns  -  65 cycles(tsc) 16.454 ns  improved 17.7%
 34 -  78 cycles(tsc) 19.655 ns  -  63 cycles(tsc) 15.932 ns  improved 19.2%
 48 -  68 cycles(tsc) 17.049 ns  -  50 cycles(tsc) 12.506 ns  improved 26.5%
 64 -  80 cycles(tsc) 20.009 ns  -  63 cycles(tsc) 15.929 ns  improved 21.3%
128 -  94 cycles(tsc) 23.749 ns  -  86 cycles(tsc) 21.583 ns  improved  8.5%
158 -  97 cycles(tsc) 24.299 ns  -  90 cycles(tsc) 22.552 ns  improved  7.2%
250 - 102 cycles(tsc) 25.681 ns  -  98 cycles(tsc) 24.589 ns  improved  3.9%

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

[1] https://github.com/netoptimizer/prototype-kernel/blob/b4688559b/kernel/mm/slab_bulk_test01.c#L80
[2] http://workshop.netfilter.org/2015/
---

Christoph Lameter (1):
      slab: infrastructure for bulk object allocation and freeing

Jesper Dangaard Brouer (5):
      slub: fix spelling succedd to succeed
      slub bulk alloc: extract objects from the per cpu slab
      slub: improve bulk alloc strategy
      slub: initial bulk free implementation
      slub: add support for kmem_cache_debug in bulk calls


 include/linux/slab.h |   10 +++++
 mm/slab.c            |   13 ++++++
 mm/slab.h            |    9 ++++
 mm/slab_common.c     |   23 +++++++++++
 mm/slob.c            |   13 ++++++
 mm/slub.c            |  109 ++++++++++++++++++++++++++++++++++++++++++++++++++
 6 files changed, 176 insertions(+), 1 deletion(-)

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
