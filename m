Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 57C9D6B0032
	for <linux-mm@kvack.org>; Tue,  9 Jun 2015 08:05:40 -0400 (EDT)
Received: by pdjn11 with SMTP id n11so13794928pdj.0
        for <linux-mm@kvack.org>; Tue, 09 Jun 2015 05:05:40 -0700 (PDT)
Received: from mail-pa0-x235.google.com (mail-pa0-x235.google.com. [2607:f8b0:400e:c03::235])
        by mx.google.com with ESMTPS id ue3si8634793pac.233.2015.06.09.05.05.39
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Jun 2015 05:05:39 -0700 (PDT)
Received: by padev16 with SMTP id ev16so12680486pad.0
        for <linux-mm@kvack.org>; Tue, 09 Jun 2015 05:05:39 -0700 (PDT)
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: [RFC][PATCH 0/5] do not dereference NULL pools in pools' destroy() functions
Date: Tue,  9 Jun 2015 21:04:48 +0900
Message-Id: <1433851493-23685-1-git-send-email-sergey.senozhatsky@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Minchan Kim <minchan@kernel.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, sergey.senozhatsky.work@gmail.com, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

Hello,

RFC

Proposed by Andrew Morton: https://lkml.org/lkml/2015/6/8/583

The existing pools' destroy() functions do not allow NULL pool pointers;
instead, every destructor() caller forced to check if pool is not NULL,
which:
 a) requires additional attention from developers/reviewers
 b) may lead to a NULL pointer dereferences if (a) didn't work


First 3 patches tweak
- kmem_cache_destroy()
- mempool_destroy()
- dma_pool_destroy()

to handle NULL pointers.
Basically, this patch set will:

1) Can prevent us from still undiscovered NULL pointer dereferences.
 (like the one that was addressed in https://lkml.org/lkml/2015/6/5/262)

2) Make a cleanup possible. Things like:
 [..]
         if (xhci->segment_pool)
                 dma_pool_destroy(xhci->segment_pool);
 	..
         if (xhci->device_pool)
                 dma_pool_destroy(xhci->device_pool);
 	..
         if (xhci->small_streams_pool)
                 dma_pool_destroy(xhci->small_streams_pool);
 	..
         if (xhci->medium_streams_pool)
                 dma_pool_destroy(xhci->medium_streams_pool);
 [..]
 
 or
 
 [..]
 fail_dma_pool:
         if (IS_QLA82XX(ha) || ql2xenabledif) {
                 dma_pool_destroy(ha->fcp_cmnd_dma_pool);
                 ha->fcp_cmnd_dma_pool = NULL;
         }
 fail_dl_dma_pool:
         if (IS_QLA82XX(ha) || ql2xenabledif) {
                 dma_pool_destroy(ha->dl_dma_pool);
                 ha->dl_dma_pool = NULL;
         }
 fail_s_dma_pool:
         dma_pool_destroy(ha->s_dma_pool);
         ha->s_dma_pool = NULL;
 [..]

 may now be simplified.


0004 and 0005 are not so necessary, simply because there are not
so many users of these two (added for pool's destroy() functions consistency):
-- zpool_destroy_pool()
-- zs_destroy_pool()

So, 0004 and 0005 can be dropped.


- zbud does kfree() in zbud_destroy_pool(), so I didn't touch it.


Sergey Senozhatsky (5):
  mm/slab_common: allow NULL cache pointer in kmem_cache_destroy()
  mm/mempool: allow NULL `pool' pointer in mempool_destroy()
  mm/dmapool: allow NULL `pool' pointer in dma_pool_destroy()
  mm/zpool: allow NULL `zpool' pointer in zpool_destroy_pool()
  mm/zsmalloc: allow NULL `pool' pointer in zs_destroy_pool()

 mm/dmapool.c     | 3 +++
 mm/mempool.c     | 3 +++
 mm/slab_common.c | 3 +++
 mm/zpool.c       | 3 +++
 mm/zsmalloc.c    | 3 +++
 5 files changed, 15 insertions(+)

-- 
2.4.3.368.g7974889

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
