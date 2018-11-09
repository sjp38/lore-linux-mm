Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 77DEF6B06B5
	for <linux-mm@kvack.org>; Fri,  9 Nov 2018 03:25:04 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id i19-v6so920878pfi.21
        for <linux-mm@kvack.org>; Fri, 09 Nov 2018 00:25:04 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 81-v6sor8177852pfk.64.2018.11.09.00.25.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 09 Nov 2018 00:25:03 -0800 (PST)
From: Nicolas Boichat <drinkcat@chromium.org>
Subject: [PATCH RFC 1/3] mm: When CONFIG_ZONE_DMA32 is set, use DMA32 for SLAB_CACHE_DMA
Date: Fri,  9 Nov 2018 16:24:46 +0800
Message-Id: <20181109082448.150302-2-drinkcat@chromium.org>
In-Reply-To: <20181109082448.150302-1-drinkcat@chromium.org>
References: <20181109082448.150302-1-drinkcat@chromium.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Robin Murphy <robin.murphy@arm.com>
Cc: Will Deacon <will.deacon@arm.com>, Joerg Roedel <joro@8bytes.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>, Mel Gorman <mgorman@techsingularity.net>, Levin Alexander <alexander.levin@verizon.com>, Huaisheng Ye <yehs1@lenovo.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, linux-arm-kernel@lists.infradead.org, iommu@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Yong Wu <yong.wu@mediatek.com>, Matthias Brugger <matthias.bgg@gmail.com>, Tomasz Figa <tfiga@google.com>, yingjoe.chen@mediatek.com

Some callers, namely iommu/io-pgtable-arm-v7s, expect the physical
address returned by kmem_cache_alloc with GFP_DMA parameter to be
a 32-bit address.

Instead of adding a separate SLAB_CACHE_DMA32 (and then audit
all the calls to check if they require memory from DMA or DMA32
zone), we simply allocate SLAB_CACHE_DMA cache in DMA32 region,
if CONFIG_ZONE_DMA32 is set.

Fixes: ad67f5a6545f ("arm64: replace ZONE_DMA with ZONE_DMA32")
Signed-off-by: Nicolas Boichat <drinkcat@chromium.org>
---
 include/linux/slab.h | 13 ++++++++++++-
 mm/slab.c            |  2 +-
 mm/slub.c            |  2 +-
 3 files changed, 14 insertions(+), 3 deletions(-)

diff --git a/include/linux/slab.h b/include/linux/slab.h
index 918f374e7156f4..390afe90c5dec0 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -30,7 +30,7 @@
 #define SLAB_POISON		((slab_flags_t __force)0x00000800U)
 /* Align objs on cache lines */
 #define SLAB_HWCACHE_ALIGN	((slab_flags_t __force)0x00002000U)
-/* Use GFP_DMA memory */
+/* Use GFP_DMA or GFP_DMA32 memory */
 #define SLAB_CACHE_DMA		((slab_flags_t __force)0x00004000U)
 /* DEBUG: Store the last owner for bug hunting */
 #define SLAB_STORE_USER		((slab_flags_t __force)0x00010000U)
@@ -126,6 +126,17 @@
 #define ZERO_OR_NULL_PTR(x) ((unsigned long)(x) <= \
 				(unsigned long)ZERO_SIZE_PTR)
 
+/*
+ * When ZONE_DMA32 is defined, have SLAB_CACHE_DMA allocate memory with
+ * GFP_DMA32 instead of GFP_DMA, as this is what some of the callers
+ * require (instead of duplicating cache for DMA and DMA32 zones).
+ */
+#ifdef CONFIG_ZONE_DMA32
+#define SLAB_CACHE_DMA_GFP GFP_DMA32
+#else
+#define SLAB_CACHE_DMA_GFP GFP_DMA
+#endif
+
 #include <linux/kasan.h>
 
 struct mem_cgroup;
diff --git a/mm/slab.c b/mm/slab.c
index 2a5654bb3b3ff3..8810daa052dcdc 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -2121,7 +2121,7 @@ int __kmem_cache_create(struct kmem_cache *cachep, slab_flags_t flags)
 	cachep->flags = flags;
 	cachep->allocflags = __GFP_COMP;
 	if (flags & SLAB_CACHE_DMA)
-		cachep->allocflags |= GFP_DMA;
+		cachep->allocflags |= SLAB_CACHE_DMA_GFP;
 	if (flags & SLAB_RECLAIM_ACCOUNT)
 		cachep->allocflags |= __GFP_RECLAIMABLE;
 	cachep->size = size;
diff --git a/mm/slub.c b/mm/slub.c
index e3629cd7aff164..fdd05323e54cbd 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -3575,7 +3575,7 @@ static int calculate_sizes(struct kmem_cache *s, int forced_order)
 		s->allocflags |= __GFP_COMP;
 
 	if (s->flags & SLAB_CACHE_DMA)
-		s->allocflags |= GFP_DMA;
+		s->allocflags |= SLAB_CACHE_DMA_GFP;
 
 	if (s->flags & SLAB_RECLAIM_ACCOUNT)
 		s->allocflags |= __GFP_RECLAIMABLE;
-- 
2.19.1.930.g4563a0d9d0-goog
