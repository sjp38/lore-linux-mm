Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id CDF0D6B7EE5
	for <linux-mm@kvack.org>; Fri,  7 Dec 2018 01:16:49 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id n17so2428727pfk.23
        for <linux-mm@kvack.org>; Thu, 06 Dec 2018 22:16:49 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d82sor4208737pfm.4.2018.12.06.22.16.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 06 Dec 2018 22:16:48 -0800 (PST)
From: Nicolas Boichat <drinkcat@chromium.org>
Subject: [PATCH v5 1/3] mm: Add support for kmem caches in DMA32 zone
Date: Fri,  7 Dec 2018 14:16:18 +0800
Message-Id: <20181207061620.107881-2-drinkcat@chromium.org>
In-Reply-To: <20181207061620.107881-1-drinkcat@chromium.org>
References: <20181207061620.107881-1-drinkcat@chromium.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>
Cc: Robin Murphy <robin.murphy@arm.com>, Joerg Roedel <joro@8bytes.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>, Mel Gorman <mgorman@techsingularity.net>, Levin Alexander <Alexander.Levin@microsoft.com>, Huaisheng Ye <yehs1@lenovo.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, linux-arm-kernel@lists.infradead.org, iommu@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Yong Wu <yong.wu@mediatek.com>, Matthias Brugger <matthias.bgg@gmail.com>, Tomasz Figa <tfiga@google.com>, yingjoe.chen@mediatek.com, hch@infradead.org, Matthew Wilcox <willy@infradead.org>

IOMMUs using ARMv7 short-descriptor format require page tables
to be allocated within the first 4GB of RAM, even on 64-bit systems.
On arm64, this is done by passing GFP_DMA32 flag to memory allocation
functions.

For IOMMU L2 tables that only take 1KB, it would be a waste to allocate
a full page using get_free_pages, so we considered 3 approaches:
 1. This patch, adding support for GFP_DMA32 slab caches.
 2. genalloc, which requires pre-allocating the maximum number of L2
    page tables (4096, so 4MB of memory).
 3. page_frag, which is not very memory-efficient as it is unable
    to reuse freed fragments until the whole page is freed.

This change makes it possible to create a custom cache in DMA32 zone
using kmem_cache_create, then allocate memory using kmem_cache_alloc.

We do not create a DMA32 kmalloc cache array, as there are currently
no users of kmalloc(..., GFP_DMA32). These calls will continue to
trigger a warning, as we keep GFP_DMA32 in GFP_SLAB_BUG_MASK.

This implies that calls to kmem_cache_*alloc on a SLAB_CACHE_DMA32
kmem_cache must _not_ use GFP_DMA32 (it is anyway redundant and
unnecessary).

Signed-off-by: Nicolas Boichat <drinkcat@chromium.org>
---

Changes since v2:
 - Clarified commit message
 - Add entry in sysfs-kernel-slab to document the new sysfs file

(v3 used the page_frag approach)

Changes since v4:
 - Added details to commit message
 - Dropped change that removed GFP_DMA32 from GFP_SLAB_BUG_MASK:
   instead we can just call kmem_cache_*alloc without GFP_DMA32
   parameter. This also means that we can drop PATCH 1/3, as we
   do not make any changes in GFP flag verification.
 - Dropped hunks that added cache_dma32 sysfs file, and moved
   the hunks to PATCH 3/3, so that maintainer can decide whether
   to pick the change independently.

 include/linux/slab.h | 2 ++
 mm/slab.c            | 2 ++
 mm/slab.h            | 3 ++-
 mm/slab_common.c     | 2 +-
 mm/slub.c            | 5 +++++
 5 files changed, 12 insertions(+), 2 deletions(-)

diff --git a/include/linux/slab.h b/include/linux/slab.h
index 11b45f7ae4057c..9449b19c5f107a 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -32,6 +32,8 @@
 #define SLAB_HWCACHE_ALIGN	((slab_flags_t __force)0x00002000U)
 /* Use GFP_DMA memory */
 #define SLAB_CACHE_DMA		((slab_flags_t __force)0x00004000U)
+/* Use GFP_DMA32 memory */
+#define SLAB_CACHE_DMA32	((slab_flags_t __force)0x00008000U)
 /* DEBUG: Store the last owner for bug hunting */
 #define SLAB_STORE_USER		((slab_flags_t __force)0x00010000U)
 /* Panic if kmem_cache_create() fails */
diff --git a/mm/slab.c b/mm/slab.c
index 73fe23e649c91a..124f8c556d27fb 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -2109,6 +2109,8 @@ int __kmem_cache_create(struct kmem_cache *cachep, slab_flags_t flags)
 	cachep->allocflags = __GFP_COMP;
 	if (flags & SLAB_CACHE_DMA)
 		cachep->allocflags |= GFP_DMA;
+	if (flags & SLAB_CACHE_DMA32)
+		cachep->allocflags |= GFP_DMA32;
 	if (flags & SLAB_RECLAIM_ACCOUNT)
 		cachep->allocflags |= __GFP_RECLAIMABLE;
 	cachep->size = size;
diff --git a/mm/slab.h b/mm/slab.h
index 4190c24ef0e9df..fcf717e12f0a86 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -127,7 +127,8 @@ static inline slab_flags_t kmem_cache_flags(unsigned int object_size,
 
 
 /* Legal flag mask for kmem_cache_create(), for various configurations */
-#define SLAB_CORE_FLAGS (SLAB_HWCACHE_ALIGN | SLAB_CACHE_DMA | SLAB_PANIC | \
+#define SLAB_CORE_FLAGS (SLAB_HWCACHE_ALIGN | SLAB_CACHE_DMA | \
+			 SLAB_CACHE_DMA32 | SLAB_PANIC | \
 			 SLAB_TYPESAFE_BY_RCU | SLAB_DEBUG_OBJECTS )
 
 #if defined(CONFIG_DEBUG_SLAB)
diff --git a/mm/slab_common.c b/mm/slab_common.c
index 70b0cc85db67f8..18b7b809c8d064 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -53,7 +53,7 @@ static DECLARE_WORK(slab_caches_to_rcu_destroy_work,
 		SLAB_FAILSLAB | SLAB_KASAN)
 
 #define SLAB_MERGE_SAME (SLAB_RECLAIM_ACCOUNT | SLAB_CACHE_DMA | \
-			 SLAB_ACCOUNT)
+			 SLAB_CACHE_DMA32 | SLAB_ACCOUNT)
 
 /*
  * Merge control. If this is set then no merging of slab caches will occur.
diff --git a/mm/slub.c b/mm/slub.c
index c229a9b7dd5448..4caadb926838ef 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -3583,6 +3583,9 @@ static int calculate_sizes(struct kmem_cache *s, int forced_order)
 	if (s->flags & SLAB_CACHE_DMA)
 		s->allocflags |= GFP_DMA;
 
+	if (s->flags & SLAB_CACHE_DMA32)
+		s->allocflags |= GFP_DMA32;
+
 	if (s->flags & SLAB_RECLAIM_ACCOUNT)
 		s->allocflags |= __GFP_RECLAIMABLE;
 
@@ -5671,6 +5674,8 @@ static char *create_unique_id(struct kmem_cache *s)
 	 */
 	if (s->flags & SLAB_CACHE_DMA)
 		*p++ = 'd';
+	if (s->flags & SLAB_CACHE_DMA32)
+		*p++ = 'D';
 	if (s->flags & SLAB_RECLAIM_ACCOUNT)
 		*p++ = 'a';
 	if (s->flags & SLAB_CONSISTENCY_CHECKS)
-- 
2.20.0.rc2.403.gdbc3b29805-goog
