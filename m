Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 57A09830CD
	for <linux-mm@kvack.org>; Sat, 27 Aug 2016 11:36:17 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id h186so205708734pfg.2
        for <linux-mm@kvack.org>; Sat, 27 Aug 2016 08:36:17 -0700 (PDT)
Received: from sender153-mail.zoho.com (sender153-mail.zoho.com. [74.201.84.153])
        by mx.google.com with ESMTPS id r11si27859352pag.260.2016.08.27.08.36.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sat, 27 Aug 2016 08:36:16 -0700 (PDT)
From: zijun_hu <zijun_hu@zoho.com>
Subject: [PATCH 2/2] mm/bootmem.c: substitute kzalloc_node() for kzalloc()
Message-ID: <632abd5b-1680-1c35-56f2-bba43c534a6a@zoho.com>
Date: Sat, 27 Aug 2016 23:35:11 +0800
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mingo@kernel.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, zijun_hu@htc.com

From: zijun_hu <zijun_hu@htc.com>

in ___alloc_bootmem_node_nopanic(), substitute kzalloc_node()
for kzalloc() in order to allocate memory within given node
preferentially when slab is available

free_all_bootmem_core() is optimized to make the first two parameters
of __free_pages_bootmem() looks consistent with each other apparently
when freeing bdata->node_bootmem_map

Signed-off-by: zijun_hu <zijun_hu@htc.com>
---
 mm/bootmem.c | 21 ++++++---------------
 1 file changed, 6 insertions(+), 15 deletions(-)

diff --git a/mm/bootmem.c b/mm/bootmem.c
index 0aa7dda52402..615acca2e0cb 100644
--- a/mm/bootmem.c
+++ b/mm/bootmem.c
@@ -11,15 +11,12 @@
 #include <linux/init.h>
 #include <linux/pfn.h>
 #include <linux/slab.h>
-#include <linux/bootmem.h>
 #include <linux/export.h>
 #include <linux/kmemleak.h>
 #include <linux/range.h>
-#include <linux/memblock.h>
 #include <linux/bug.h>
 #include <linux/io.h>
-
-#include <asm/processor.h>
+#include <linux/bootmem.h>
 
 #include "internal.h"
 
@@ -229,13 +226,14 @@ static unsigned long __init free_all_bootmem_core(bootmem_data_t *bdata)
 		}
 	}
 
-	cur = bdata->node_min_pfn;
 	page = virt_to_page(bdata->node_bootmem_map);
 	pages = bdata->node_low_pfn - bdata->node_min_pfn;
 	pages = bootmem_bootmap_pages(pages);
 	count += pages;
-	while (pages--)
-		__free_pages_bootmem(page++, cur++, 0);
+	while (pages--) {
+		__free_pages_bootmem(page, page_to_pfn(page), 0);
+		page++;
+	}
 	bdata->node_bootmem_map = NULL;
 
 	bdebug("nid=%td released=%lx\n", bdata - bootmem_node_data, count);
@@ -712,7 +710,7 @@ void * __init ___alloc_bootmem_node_nopanic(pg_data_t *pgdat,
 	void *ptr;
 
 	if (WARN_ON_ONCE(slab_is_available()))
-		return kzalloc(size, GFP_NOWAIT);
+		return kzalloc_node(size, GFP_NOWAIT, pgdat->node_id);
 again:
 
 	/* do not panic in alloc_bootmem_bdata() */
@@ -738,9 +736,6 @@ again:
 void * __init __alloc_bootmem_node_nopanic(pg_data_t *pgdat, unsigned long size,
 				   unsigned long align, unsigned long goal)
 {
-	if (WARN_ON_ONCE(slab_is_available()))
-		return kzalloc_node(size, GFP_NOWAIT, pgdat->node_id);
-
 	return ___alloc_bootmem_node_nopanic(pgdat, size, align, goal, 0);
 }
 
@@ -812,10 +807,6 @@ void * __init __alloc_bootmem_node_high(pg_data_t *pgdat, unsigned long size,
 
 }
 
-#ifndef ARCH_LOW_ADDRESS_LIMIT
-#define ARCH_LOW_ADDRESS_LIMIT	0xffffffffUL
-#endif
-
 /**
  * __alloc_bootmem_low - allocate low boot memory
  * @size: size of the request in bytes
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
