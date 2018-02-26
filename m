Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 46C726B0003
	for <linux-mm@kvack.org>; Mon, 26 Feb 2018 15:35:24 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id e74so6768896wmg.0
        for <linux-mm@kvack.org>; Mon, 26 Feb 2018 12:35:24 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id r18sor2210359wmd.46.2018.02.26.12.35.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 26 Feb 2018 12:35:22 -0800 (PST)
Date: Mon, 26 Feb 2018 23:35:19 +0300
From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] slab: mark kmalloc machinery as __ro_after_init
Message-ID: <20180226203519.GA6886@avx2>
References: <20180226203011.GA6510@avx2>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180226203011.GA6510@avx2>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org

kmalloc caches aren't relocated after being set up neither does
"size_index" array.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 mm/slab_common.c |    7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -10,6 +10,7 @@
 #include <linux/poison.h>
 #include <linux/interrupt.h>
 #include <linux/memory.h>
+#include <linux/cache.h>
 #include <linux/compiler.h>
 #include <linux/module.h>
 #include <linux/cpu.h>
@@ -954,11 +955,11 @@ struct kmem_cache *__init create_kmalloc_cache(const char *name, size_t size,
 	return s;
 }
 
-struct kmem_cache *kmalloc_caches[KMALLOC_SHIFT_HIGH + 1];
+struct kmem_cache *kmalloc_caches[KMALLOC_SHIFT_HIGH + 1] __ro_after_init;
 EXPORT_SYMBOL(kmalloc_caches);
 
 #ifdef CONFIG_ZONE_DMA
-struct kmem_cache *kmalloc_dma_caches[KMALLOC_SHIFT_HIGH + 1];
+struct kmem_cache *kmalloc_dma_caches[KMALLOC_SHIFT_HIGH + 1] __ro_after_init;
 EXPORT_SYMBOL(kmalloc_dma_caches);
 #endif
 
@@ -968,7 +969,7 @@ EXPORT_SYMBOL(kmalloc_dma_caches);
  * of two cache sizes there. The size of larger slabs can be determined using
  * fls.
  */
-static s8 size_index[24] = {
+static s8 size_index[24] __ro_after_init = {
 	3,	/* 8 */
 	4,	/* 16 */
 	5,	/* 24 */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
