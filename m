Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id 9A7C86B0008
	for <linux-mm@kvack.org>; Mon,  4 Feb 2013 09:49:11 -0500 (EST)
Received: by mail-pa0-f49.google.com with SMTP id kp6so1328035pab.36
        for <linux-mm@kvack.org>; Mon, 04 Feb 2013 06:49:10 -0800 (PST)
From: Joonsoo Kim <js1304@gmail.com>
Subject: [PATCH for-next] mm/sl[au]b: correct allocation type check in kmalloc_slab()
Date: Mon,  4 Feb 2013 23:46:46 +0900
Message-Id: <1359989206-16116-1-git-send-email-js1304@gmail.com>
In-Reply-To: <20130202125952.GE16114@localhost>
References: <20130202125952.GE16114@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux.com>, Fengguang Wu <fengguang.wu@intel.com>, Joonsoo Kim <js1304@gmail.com>

commit "slab: Common Kmalloc cache determination" made mistake
in kmalloc_slab(). SLAB_CACHE_DMA is for kmem_cache creation,
not for allocation. For allocation, we should use GFP_XXX to identify
type of allocation. So, change SLAB_CACHE_DMA to GFP_DMA.

Cc: Christoph Lameter <cl@linux.com>
Reported-by: Fengguang Wu <fengguang.wu@intel.com>
Signed-off-by: Joonsoo Kim <js1304@gmail.com>

diff --git a/mm/slab_common.c b/mm/slab_common.c
index 6d73f0b..2f0e7d5 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -382,7 +382,7 @@ struct kmem_cache *kmalloc_slab(size_t size, gfp_t flags)
 		index = fls(size - 1);
 
 #ifdef CONFIG_ZONE_DMA
-	if (unlikely((flags & SLAB_CACHE_DMA)))
+	if (unlikely((flags & GFP_DMA)))
 		return kmalloc_dma_caches[index];
 
 #endif
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
