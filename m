Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 309AF830F1
	for <linux-mm@kvack.org>; Mon, 29 Aug 2016 09:22:09 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id h186so302641667pfg.2
        for <linux-mm@kvack.org>; Mon, 29 Aug 2016 06:22:09 -0700 (PDT)
Received: from sender153-mail.zoho.com (sender153-mail.zoho.com. [74.201.84.153])
        by mx.google.com with ESMTPS id fm1si39209766pad.221.2016.08.29.06.22.07
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 29 Aug 2016 06:22:08 -0700 (PDT)
From: zijun_hu <zijun_hu@zoho.com>
Subject: [PATCH 2/2] mm/bootmem.c: replace kzalloc() by kzalloc_node()
Message-ID: <1f487f12-6af4-5e4f-a28c-1de2361cdcd8@zoho.com>
Date: Mon, 29 Aug 2016 21:21:42 +0800
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, mingo@kernel.org
Cc: linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, zijun_hu@htc.com

From: zijun_hu <zijun_hu@htc.com>

in ___alloc_bootmem_node_nopanic(), replace kzalloc() by
kzalloc_node() in order to allocate memory within given node
preferentially when slab is available

Signed-off-by: zijun_hu <zijun_hu@htc.com>
---
 mm/bootmem.c | 14 ++------------
 1 file changed, 2 insertions(+), 12 deletions(-)

diff --git a/mm/bootmem.c b/mm/bootmem.c
index 0aa7dda52402..a869f84f44d3 100644
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
 
@@ -712,7 +709,7 @@ void * __init ___alloc_bootmem_node_nopanic(pg_data_t *pgdat,
 	void *ptr;
 
 	if (WARN_ON_ONCE(slab_is_available()))
-		return kzalloc(size, GFP_NOWAIT);
+		return kzalloc_node(size, GFP_NOWAIT, pgdat->node_id);
 again:
 
 	/* do not panic in alloc_bootmem_bdata() */
@@ -738,9 +735,6 @@ again:
 void * __init __alloc_bootmem_node_nopanic(pg_data_t *pgdat, unsigned long size,
 				   unsigned long align, unsigned long goal)
 {
-	if (WARN_ON_ONCE(slab_is_available()))
-		return kzalloc_node(size, GFP_NOWAIT, pgdat->node_id);
-
 	return ___alloc_bootmem_node_nopanic(pgdat, size, align, goal, 0);
 }
 
@@ -812,10 +806,6 @@ void * __init __alloc_bootmem_node_high(pg_data_t *pgdat, unsigned long size,
 
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
