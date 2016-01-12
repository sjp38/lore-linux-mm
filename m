Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f52.google.com (mail-qg0-f52.google.com [209.85.192.52])
	by kanga.kvack.org (Postfix) with ESMTP id 948EA4403D9
	for <linux-mm@kvack.org>; Tue, 12 Jan 2016 10:13:36 -0500 (EST)
Received: by mail-qg0-f52.google.com with SMTP id b35so300556368qge.0
        for <linux-mm@kvack.org>; Tue, 12 Jan 2016 07:13:36 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a198si22823204qkb.68.2016.01.12.07.13.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Jan 2016 07:13:35 -0800 (PST)
Subject: [PATCH V2 00/11] MM: More bulk API work
From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Tue, 12 Jan 2016 16:13:31 +0100
Message-ID: <20160112151257.31725.71327.stgit@firesoul>
In-Reply-To: <20160107140253.28907.5469.stgit@firesoul>
References: <20160107140253.28907.5469.stgit@firesoul>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Christoph Lameter <cl@linux.com>
Cc: Vladimir Davydov <vdavydov@virtuozzo.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Jesper Dangaard Brouer <brouer@redhat.com>

This series contain three aspects:
 1. cleanup and code sharing between SLUB and SLAB
 2. implementing accelerated bulk API for SLAB allocator
 3. new API kfree_bulk()

Reviewers please review the changed order of debug calls in the SLAB
allocator, as they are changed to do the same as the SLUB allocator.

Patchset based on top Linus tree at commit afd2ff9b7e1b ("Linux 4.4").

Test module for exercising the new kfree_bulk() API is avail here:
 https://github.com/netoptimizer/prototype-kernel/blob/master/kernel/mm/slab_bulk_test05_kfree_bulk.c

---

Jesper Dangaard Brouer (11):
      slub: cleanup code for kmem cgroup support to kmem_cache_free_bulk
      mm/slab: move SLUB alloc hooks to common mm/slab.h
      mm: fault-inject take over bootstrap kmem_cache check
      slab: use slab_pre_alloc_hook in SLAB allocator shared with SLUB
      mm: kmemcheck skip object if slab allocation failed
      slab: use slab_post_alloc_hook in SLAB allocator shared with SLUB
      slab: implement bulk alloc in SLAB allocator
      slab: avoid running debug SLAB code with IRQs disabled for alloc_bulk
      slab: implement bulk free in SLAB allocator
      mm: new API kfree_bulk() for SLAB+SLUB allocators
      mm: fix some spelling


 include/linux/fault-inject.h |    5 +-
 include/linux/memcontrol.h   |    2 -
 include/linux/slab.h         |   11 +++-
 mm/failslab.c                |   11 +++-
 mm/kmemcheck.c               |    3 +
 mm/slab.c                    |  121 +++++++++++++++++++++++++++---------------
 mm/slab.h                    |   64 ++++++++++++++++++++++
 mm/slab_common.c             |    8 ++-
 mm/slub.c                    |   93 +++++++++-----------------------
 9 files changed, 198 insertions(+), 120 deletions(-)

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
