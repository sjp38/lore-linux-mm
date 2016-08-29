Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id E3781830F1
	for <linux-mm@kvack.org>; Mon, 29 Aug 2016 09:09:24 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id 63so304319043pfx.0
        for <linux-mm@kvack.org>; Mon, 29 Aug 2016 06:09:24 -0700 (PDT)
Received: from sender153-mail.zoho.com (sender153-mail.zoho.com. [74.201.84.153])
        by mx.google.com with ESMTPS id c7si39069101pax.281.2016.08.29.06.09.23
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 29 Aug 2016 06:09:23 -0700 (PDT)
From: zijun_hu <zijun_hu@zoho.com>
Subject: [PATCH 1/2] mm/nobootmem.c: remove duplicate macro
 ARCH_LOW_ADDRESS_LIMIT statements
Message-ID: <e046aeaa-e160-6d9e-dc1b-e084c2fd999f@zoho.com>
Date: Mon, 29 Aug 2016 21:09:06 +0800
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, mingo@kernel.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, zijun_hu@htc.com

From: zijun_hu <zijun_hu@htc.com>

this patch fixes the following bugs:

 - the same ARCH_LOW_ADDRESS_LIMIT statements are duplicated between
   header and relevant source

 - don't ensure ARCH_LOW_ADDRESS_LIMIT perhaps defined by ARCH in
   asm/processor.h is preferred over default in linux/bootmem.h
   completely since the former header isn't included by the latter

Signed-off-by: zijun_hu <zijun_hu@htc.com>
---
 include/linux/bootmem.h |  9 +++++----
 mm/nobootmem.c          | 10 +++++-----
 2 files changed, 10 insertions(+), 9 deletions(-)

diff --git a/include/linux/bootmem.h b/include/linux/bootmem.h
index f9be32691718..962164d36506 100644
--- a/include/linux/bootmem.h
+++ b/include/linux/bootmem.h
@@ -7,6 +7,7 @@
 #include <linux/mmzone.h>
 #include <linux/mm_types.h>
 #include <asm/dma.h>
+#include <asm/processor.h>
 
 /*
  *  simple boot-time physical memory area allocator.
@@ -119,6 +120,10 @@ extern void *__alloc_bootmem_low_node(pg_data_t *pgdat,
 #define BOOTMEM_LOW_LIMIT __pa(MAX_DMA_ADDRESS)
 #endif
 
+#ifndef ARCH_LOW_ADDRESS_LIMIT
+#define ARCH_LOW_ADDRESS_LIMIT  0xffffffffUL
+#endif
+
 #define alloc_bootmem(x) \
 	__alloc_bootmem(x, SMP_CACHE_BYTES, BOOTMEM_LOW_LIMIT)
 #define alloc_bootmem_align(x, align) \
@@ -180,10 +185,6 @@ static inline void * __init memblock_virt_alloc_nopanic(
 						    NUMA_NO_NODE);
 }
 
-#ifndef ARCH_LOW_ADDRESS_LIMIT
-#define ARCH_LOW_ADDRESS_LIMIT  0xffffffffUL
-#endif
-
 static inline void * __init memblock_virt_alloc_low(
 					phys_addr_t size, phys_addr_t align)
 {
diff --git a/mm/nobootmem.c b/mm/nobootmem.c
index bd05a70f44b9..490d46abddad 100644
--- a/mm/nobootmem.c
+++ b/mm/nobootmem.c
@@ -11,18 +11,21 @@
 #include <linux/init.h>
 #include <linux/pfn.h>
 #include <linux/slab.h>
-#include <linux/bootmem.h>
 #include <linux/export.h>
 #include <linux/kmemleak.h>
 #include <linux/range.h>
 #include <linux/memblock.h>
+#include <linux/bootmem.h>
 
 #include <asm/bug.h>
 #include <asm/io.h>
-#include <asm/processor.h>
 
 #include "internal.h"
 
+#ifndef CONFIG_HAVE_MEMBLOCK
+#error CONFIG_HAVE_MEMBLOCK not defined
+#endif
+
 #ifndef CONFIG_NEED_MULTIPLE_NODES
 struct pglist_data __refdata contig_page_data;
 EXPORT_SYMBOL(contig_page_data);
@@ -395,9 +398,6 @@ void * __init __alloc_bootmem_node_high(pg_data_t *pgdat, unsigned long size,
 	return __alloc_bootmem_node(pgdat, size, align, goal);
 }
 
-#ifndef ARCH_LOW_ADDRESS_LIMIT
-#define ARCH_LOW_ADDRESS_LIMIT	0xffffffffUL
-#endif
 
 /**
  * __alloc_bootmem_low - allocate low boot memory
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
