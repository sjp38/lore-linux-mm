Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f54.google.com (mail-qg0-f54.google.com [209.85.192.54])
	by kanga.kvack.org (Postfix) with ESMTP id 8BFA66B0038
	for <linux-mm@kvack.org>; Mon, 28 Sep 2015 08:26:08 -0400 (EDT)
Received: by qgez77 with SMTP id z77so118864341qge.1
        for <linux-mm@kvack.org>; Mon, 28 Sep 2015 05:26:08 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 141si15198894qhx.1.2015.09.28.05.26.07
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Sep 2015 05:26:07 -0700 (PDT)
Subject: [PATCH 0/7] Further optimizing SLAB/SLUB bulking
From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Mon, 28 Sep 2015 14:26:04 +0200
Message-ID: <20150928122444.15409.10498.stgit@canyon>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: netdev@vger.kernel.org, Jesper Dangaard Brouer <brouer@redhat.com>, Alexander Duyck <alexander.duyck@gmail.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Most important part of this patchset is the introducing of what I call
detached freelist, for improving SLUB performance of object freeing in
the "slowpath" of kmem_cache_free_bulk.

Previous patchset V2 thread:
  http://thread.gmane.org/gmane.linux.kernel.mm/137469

Not using V3 tag as patch titles have changed and I've merged some
patches. This was joint work with Alexander Duyck while still at Red Hat.

Notes for patches:
 * First two patches (from Christoph) are already in AKPM MMOTS.
 * Patch 3 is trivial
 * Patch 4 is a repost, implements bulking for SLAB.
  - http://thread.gmane.org/gmane.linux.kernel.mm/138220
 * Patch 5 and 6 are the important patches
  - Patch 5 handle "freelists" in slab_free() and __slab_free().
  - Patch 6 intro detached freelists, and significant performance improvement

Patches should be ready for the MM-tree, as I'm now handling kmem
debug support.


Based on top of commit 519f526d39 in net-next, but I've tested it
applies on top of mmotm-2015-09-18-16-08.

The benchmarking tools are avail here:
 https://github.com/netoptimizer/prototype-kernel/tree/master/kernel/mm
 See: slab_bulk_test0{1,2,3}.c


This patchset is part of my network stack use-case.  I'll post the
network side of the patchset as soon as I've cleaned it up, rebased it
on net-next and re-run all the benchmarks.

---

Christoph Lameter (2):
      slub: create new ___slab_alloc function that can be called with irqs disabled
      slub: Avoid irqoff/on in bulk allocation

Jesper Dangaard Brouer (5):
      slub: mark the dangling ifdef #else of CONFIG_SLUB_DEBUG
      slab: implement bulking for SLAB allocator
      slub: support for bulk free with SLUB freelists
      slub: optimize bulk slowpath free by detached freelist
      slub: do prefetching in kmem_cache_alloc_bulk()


 mm/slab.c |   87 ++++++++++++++-----
 mm/slub.c |  276 +++++++++++++++++++++++++++++++++++++++++++++----------------
 2 files changed, 267 insertions(+), 96 deletions(-)

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
