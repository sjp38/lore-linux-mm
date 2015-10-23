Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f177.google.com (mail-io0-f177.google.com [209.85.223.177])
	by kanga.kvack.org (Postfix) with ESMTP id ACA626B0038
	for <linux-mm@kvack.org>; Fri, 23 Oct 2015 08:46:06 -0400 (EDT)
Received: by iodv82 with SMTP id v82so122366344iod.0
        for <linux-mm@kvack.org>; Fri, 23 Oct 2015 05:46:06 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g69si15543645ioe.134.2015.10.23.05.46.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Oct 2015 05:46:06 -0700 (PDT)
Subject: [PATCH 0/4] net: mitigating kmem_cache slowpath for network stack
 in NAPI context
From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Fri, 23 Oct 2015 14:46:01 +0200
Message-ID: <20151023124451.17364.14594.stgit@firesoul>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: netdev@vger.kernel.org
Cc: Alexander Duyck <alexander.duyck@gmail.com>, linux-mm@kvack.org, Jesper Dangaard Brouer <brouer@redhat.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>

It have been a long road. Back in July 2014 I realized that network
stack were hitting the kmem_cache/SLUB slowpath when freeing SKBs, but
had no solution.  In Dec 2014 I had implemented a solution called
qmempool[1], that showed it was possible to improve this, but got
rejected due to being a cache on top of kmem_cache.  In July 2015
improvements to kmem_cache were proposed, and recently Oct 2015 my
kmem_cache (SLAB+SLUB) patches for bulk alloc and free have been
accepted into the AKPM quilt tree.

This patchset is the first real use-case kmem_cache bulk alloc and free.
And is joint work with Alexander Duyck while still at Red Hat.

Using bulk free to avoid the SLUB slowpath shows the full potential.
In this patchset it is realized in NAPI/softirq context.  1. During
DMA TX completion bulk free is optimal and does not introduce any
added latency. 2. bulk free of SKBs delay free'ed due to IRQ context
in net_tx_action softirq completion queue.

Using bulk alloc is showing minor improvements for SLUB(+0.9%), but a
very slight slowdown for SLAB(-0.1%).

[1] http://thread.gmane.org/gmane.linux.network/342347/focus=126138


This patchset is based on net-next (commit 26440c835), BUT I've
applied several patches from AKPMs MM-tree.

Cherrypick some commits from MMOTM tree on branch/tag mmotm-2015-10-06-16-30
from git://git.kernel.org/pub/scm/linux/kernel/git/mhocko/mm.git
(Below commit IDs are obviously not stable)

Pickup my own MM-changes:
 b0aa3e95ce82 ("slub: mark the dangling ifdef #else of CONFIG_SLUB_DEBUG")
 114a2b37847c ("slab: implement bulking for SLAB allocator")
 606397476e8b ("slub: support for bulk free with SLUB freelists")
 ee29cd6a570c ("slub: optimize bulk slowpath free by detached freelist")
 491c6e0ca89d ("slub-optimize-bulk-slowpath-free-by-detached-freelist-fix")

Pickup slab.h changes:
 d9a47e0b776b ("compiler.h: add support for function attribute assume_aligned")
 1c3a5c789b4f ("slab.h: sprinkle __assume_aligned attributes")

Wanted Kirill A. Shutemov's changes as they change virt_to_head_page(),
had to apply patches manually from http://ozlabs.org/~akpm/mmotm/
(stamp-2015-10-20-16-33) as AKPM made several small fixes.

---

Jesper Dangaard Brouer (4):
      net: bulk free infrastructure for NAPI context, use napi_consume_skb
      net: bulk free SKBs that were delay free'ed due to IRQ context
      ixgbe: bulk free SKBs during TX completion cleanup cycle
      net: bulk alloc and reuse of SKBs in NAPI context


 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    6 +
 include/linux/skbuff.h                        |    4 +
 net/core/dev.c                                |    9 ++
 net/core/skbuff.c                             |  122 +++++++++++++++++++++++--
 4 files changed, 127 insertions(+), 14 deletions(-)

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
