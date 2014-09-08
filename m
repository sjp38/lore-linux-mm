Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 89CBF6B0036
	for <linux-mm@kvack.org>; Mon,  8 Sep 2014 19:38:26 -0400 (EDT)
Received: by mail-pd0-f179.google.com with SMTP id g10so8843161pdj.10
        for <linux-mm@kvack.org>; Mon, 08 Sep 2014 16:38:26 -0700 (PDT)
Received: from mail-pd0-x233.google.com (mail-pd0-x233.google.com [2607:f8b0:400e:c02::233])
        by mx.google.com with ESMTPS id c8si20023811pat.184.2014.09.08.16.38.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 08 Sep 2014 16:38:25 -0700 (PDT)
Received: by mail-pd0-f179.google.com with SMTP id g10so8789721pdj.24
        for <linux-mm@kvack.org>; Mon, 08 Sep 2014 16:38:25 -0700 (PDT)
From: Akinobu Mita <akinobu.mita@gmail.com>
Subject: [PATCH v2 1/3] mm: use memblock_alloc_range_nid() and memblock_alloc_range()
Date: Tue,  9 Sep 2014 08:38:02 +0900
Message-Id: <1410219484-8038-1-git-send-email-akinobu.mita@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Akinobu Mita <akinobu.mita@gmail.com>, Sabrina Dubroca <sd@queasysnail.net>, linux-mm@kvack.org

memblock_alloc_range_nid() is equivalent to memblock_find_in_range_node()
followed by memblock_reserve().  memblock_alloc_range() is equivalent to
memblock_alloc_range_nid() with NUMA_NO_NODE for any node.

Convert to use these functions and remove subsequent kmemleak_alloc()
call as it is already called in memblock_alloc() and its variants.

This is just a cleanup.

Signed-off-by: Akinobu Mita <akinobu.mita@gmail.com>
Cc: Sabrina Dubroca <sd@queasysnail.net>
Cc: linux-mm@kvack.org
---
* v2: fix overlapping kmemleak_alloc() calls, reported by Sabrina Dubroca.

 mm/memblock.c | 18 ++----------------
 1 file changed, 2 insertions(+), 16 deletions(-)

diff --git a/mm/memblock.c b/mm/memblock.c
index 70fad0c..a942f6e 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -1150,21 +1150,16 @@ static void * __init memblock_virt_alloc_internal(
 	if (WARN_ON_ONCE(slab_is_available()))
 		return kzalloc_node(size, GFP_NOWAIT, nid);
 
-	if (!align)
-		align = SMP_CACHE_BYTES;
-
 	if (max_addr > memblock.current_limit)
 		max_addr = memblock.current_limit;
 
 again:
-	alloc = memblock_find_in_range_node(size, align, min_addr, max_addr,
-					    nid);
+	alloc = memblock_alloc_range_nid(size, align, min_addr, max_addr, nid);
 	if (alloc)
 		goto done;
 
 	if (nid != NUMA_NO_NODE) {
-		alloc = memblock_find_in_range_node(size, align, min_addr,
-						    max_addr,  NUMA_NO_NODE);
+		alloc = memblock_alloc_range(size, align, min_addr, max_addr);
 		if (alloc)
 			goto done;
 	}
@@ -1177,18 +1172,9 @@ again:
 	}
 
 done:
-	memblock_reserve(alloc, size);
 	ptr = phys_to_virt(alloc);
 	memset(ptr, 0, size);
 
-	/*
-	 * The min_count is set to 0 so that bootmem allocated blocks
-	 * are never reported as leaks. This is because many of these blocks
-	 * are only referred via the physical address which is not
-	 * looked up by kmemleak.
-	 */
-	kmemleak_alloc(ptr, size, 0, 0);
-
 	return ptr;
 
 error:
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
