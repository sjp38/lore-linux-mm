Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f180.google.com (mail-yk0-f180.google.com [209.85.160.180])
	by kanga.kvack.org (Postfix) with ESMTP id 682BB6B0038
	for <linux-mm@kvack.org>; Fri, 13 Nov 2015 05:57:24 -0500 (EST)
Received: by ykdv3 with SMTP id v3so139990493ykd.0
        for <linux-mm@kvack.org>; Fri, 13 Nov 2015 02:57:24 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id i129si13623822ywc.15.2015.11.13.02.57.23
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Nov 2015 02:57:23 -0800 (PST)
Subject: [PATCH V4 0/2] SLUB bulk API interactions with kmem cgroup
From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Fri, 13 Nov 2015 11:57:20 +0100
Message-ID: <20151113105558.32536.63240.stgit@firesoul>
In-Reply-To: <20151105161048.GG29259@esperanza>
References: <20151105161048.GG29259@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: vdavydov@virtuozzo.com, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Jesper Dangaard Brouer <brouer@redhat.com>

Added correct support for kmem cgroup interaction with SLUB bulk API.

Kernel tested with CONFIG_MEMCG_KMEM=y, and memcg setup[4] provide by
Vladimir Davydov. And with my network stack use-case patchset applied,
to actually activate the API.

Patch01: I've verified the loop in slab_post_alloc_hook() gets removed
 by the compiler (when no debug options defined). This was actually
 tricky due to kernel gcc compile options, and I wrote a small program
 to figure this out [1].
 Also tested memory exhaustion[3] to verify error: (label) code path.

Patch02: If CONFIG_MEMCG_KMEM is enabled, we no longer handle error
 cases like passing of NULL pointers in the array to free.  The
 "try_crash" mode test of module slab_bulk_test03 [2] have been adjusted.

Kernel config wise, ran with combinations of:
 CONFIG_DEBUG_KMEMLEAK, CONFIG_KASAN and CONFIG_MEMCG_KMEM
 (Explicitly disabled/avoided CONFIG_KMEMCHECK)

[1] https://github.com/netoptimizer/network-testing/blob/master/src/compiler_test01.c
[2] https://github.com/netoptimizer/prototype-kernel/blob/master/kernel/mm/slab_bulk_test03.c
[3] https://github.com/netoptimizer/prototype-kernel/blob/master/kernel/mm/slab_bulk_test04_exhaust_mem.c
[4] http://thread.gmane.org/gmane.linux.kernel.mm/140860/focus=140865

---

Jesper Dangaard Brouer (2):
      slub: fix kmem cgroup bug in kmem_cache_alloc_bulk
      slub: add missing kmem cgroup support to kmem_cache_free_bulk


 mm/slub.c |   46 +++++++++++++++++++++++++++-------------------
 1 file changed, 27 insertions(+), 19 deletions(-)

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
