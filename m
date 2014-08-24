Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 7BCF16B003A
	for <linux-mm@kvack.org>; Sun, 24 Aug 2014 10:56:37 -0400 (EDT)
Received: by mail-pa0-f48.google.com with SMTP id et14so19129296pad.7
        for <linux-mm@kvack.org>; Sun, 24 Aug 2014 07:56:33 -0700 (PDT)
Received: from mail-pa0-x231.google.com (mail-pa0-x231.google.com [2607:f8b0:400e:c03::231])
        by mx.google.com with ESMTPS id xf10si49042911pab.70.2014.08.24.07.56.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 24 Aug 2014 07:56:32 -0700 (PDT)
Received: by mail-pa0-f49.google.com with SMTP id hz1so19244191pad.22
        for <linux-mm@kvack.org>; Sun, 24 Aug 2014 07:56:32 -0700 (PDT)
From: Akinobu Mita <akinobu.mita@gmail.com>
Subject: [PATCH 2/2] mm: use memblock_alloc_range()
Date: Sun, 24 Aug 2014 23:56:03 +0900
Message-Id: <1408892163-8073-2-git-send-email-akinobu.mita@gmail.com>
In-Reply-To: <1408892163-8073-1-git-send-email-akinobu.mita@gmail.com>
References: <1408892163-8073-1-git-send-email-akinobu.mita@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, akpm@linux-foundation.org
Cc: Akinobu Mita <akinobu.mita@gmail.com>, linux-mm@kvack.org

Replace memblock_find_in_range() and memblock_reserve() with
memblock_alloc_range().

Signed-off-by: Akinobu Mita <akinobu.mita@gmail.com>
Cc: linux-mm@kvack.org
---
 mm/memblock.c | 10 ++--------
 1 file changed, 2 insertions(+), 8 deletions(-)

diff --git a/mm/memblock.c b/mm/memblock.c
index 6d2f219..4d98d93 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -1151,21 +1151,16 @@ static void * __init memblock_virt_alloc_internal(
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
@@ -1178,7 +1173,6 @@ again:
 	}
 
 done:
-	memblock_reserve(alloc, size);
 	ptr = phys_to_virt(alloc);
 	memset(ptr, 0, size);
 
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
