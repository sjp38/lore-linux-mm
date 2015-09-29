Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f169.google.com (mail-qk0-f169.google.com [209.85.220.169])
	by kanga.kvack.org (Postfix) with ESMTP id 7E8386B0257
	for <linux-mm@kvack.org>; Tue, 29 Sep 2015 11:46:40 -0400 (EDT)
Received: by qkcf65 with SMTP id f65so4858658qkc.3
        for <linux-mm@kvack.org>; Tue, 29 Sep 2015 08:46:40 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c2si15405631qkh.34.2015.09.29.08.46.39
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Sep 2015 08:46:39 -0700 (PDT)
Subject: [MM PATCH V4 0/6] Further optimizing SLAB/SLUB bulking
From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Tue, 29 Sep 2015 17:46:57 +0200
Message-ID: <20150929154605.14465.98995.stgit@canyon>
In-Reply-To: <20150928122444.15409.10498.stgit@canyon>
References: <20150928122444.15409.10498.stgit@canyon>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>
Cc: netdev@vger.kernel.org, Jesper Dangaard Brouer <brouer@redhat.com>, Alexander Duyck <alexander.duyck@gmail.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Most important part of this patchset is the introducing of what I call
detached freelist, for improving SLUB performance of object freeing in
the "slowpath" of kmem_cache_free_bulk.

Tagging patchset with "V4" to avoid confusion with "V2":
 (V2) http://thread.gmane.org/gmane.linux.kernel.mm/137469

Addressing comments from:
 ("V3") http://thread.gmane.org/gmane.linux.kernel.mm/139268

I've added Christoph Lameter's ACKs from prev review.
 * Only patch 5 is changed significantly and needs review.
 * Benchmarked, performance is the same

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

This was joint work with Alexander Duyck while still at Red Hat.

This patchset is part of my network stack use-case.  I'll post the
network side of the patchset as soon as I've cleaned it up, rebased it
on net-next and re-run all the benchmarks.

---

Christoph Lameter (2):
      slub: create new ___slab_alloc function that can be called with irqs disabled
      slub: Avoid irqoff/on in bulk allocation

Jesper Dangaard Brouer (4):
      slub: mark the dangling ifdef #else of CONFIG_SLUB_DEBUG
      slab: implement bulking for SLAB allocator
      slub: support for bulk free with SLUB freelists
      slub: optimize bulk slowpath free by detached freelist


 mm/slab.c |   87 ++++++++++++++------
 mm/slub.c |  263 +++++++++++++++++++++++++++++++++++++++++++------------------
 2 files changed, 249 insertions(+), 101 deletions(-)

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
