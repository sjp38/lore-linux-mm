Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id D52456B0032
	for <linux-mm@kvack.org>; Sun,  4 Jan 2015 20:37:38 -0500 (EST)
Received: by mail-pd0-f182.google.com with SMTP id p10so26962848pdj.41
        for <linux-mm@kvack.org>; Sun, 04 Jan 2015 17:37:38 -0800 (PST)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id ib3si80807874pbb.224.2015.01.04.17.37.35
        for <linux-mm@kvack.org>;
        Sun, 04 Jan 2015 17:37:37 -0800 (PST)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH 0/6] mm/slab: optimize allocation fastpath
Date: Mon,  5 Jan 2015 10:37:25 +0900
Message-Id: <1420421851-3281-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jesper Dangaard Brouer <brouer@redhat.com>

SLAB always disable irq before executing any object alloc/free operation.
This is really painful in terms of performance. Benchmark result that does
alloc/free repeatedly shows that each alloc/free is rougly 2 times slower
than SLUB's one (27 ns : 14 ns). To improve performance, this patchset
try to implement allocation fastpath without disabling irq.

This is a similar way to implement allocation fastpath in SLUB.
Transaction id is introduced and updated on every operation. In allocation
fastpath, object in array cache is read speculartively. And then, pointer
pointing object position in array cache and transaction id are updated
simultaneously through this_cpu_cmpxchg_double(). If tid is unchanged
until this updating, it ensures that there is no concurrent clients
allocating/freeing object to this slab. So allocation could succeed
without disabling irq.

Above mentioned benchmark shows that alloc/free fastpath performance
is improved roughly 22%. (27 ns -> 21 ns).

Unfortunately, I cannot optimize free fastpath, because speculartively
writing freeing object pointer into array cache cannot be possible.
If anyone have a good idea to optimize free fastpath, please let me know.

Thanks.

Joonsoo Kim (6):
  mm/slab: fix gfp flags of percpu allocation at boot phase
  mm/slab: remove kmemleak_erase() call
  mm/slab: clean-up __ac_get_obj() to prepare future changes
  mm/slab: rearrange irq management
  mm/slab: cleanup ____cache_alloc()
  mm/slab: allocation fastpath without disabling irq

 include/linux/kmemleak.h |    8 --
 mm/slab.c                |  257 +++++++++++++++++++++++++++++++---------------
 2 files changed, 176 insertions(+), 89 deletions(-)

-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
