Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5C50C6B03DD
	for <linux-mm@kvack.org>; Wed, 21 Dec 2016 18:31:08 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id a190so319913072pgc.0
        for <linux-mm@kvack.org>; Wed, 21 Dec 2016 15:31:08 -0800 (PST)
Received: from mail-pg0-x243.google.com (mail-pg0-x243.google.com. [2607:f8b0:400e:c05::243])
        by mx.google.com with ESMTPS id y3si28295483pgo.229.2016.12.21.15.31.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Dec 2016 15:31:07 -0800 (PST)
Received: by mail-pg0-x243.google.com with SMTP id i5so8277549pgh.2
        for <linux-mm@kvack.org>; Wed, 21 Dec 2016 15:31:07 -0800 (PST)
From: Wei Yang <richard.weiyang@gmail.com>
Subject: [PATCH 2/2] mm/memblock.c: check return value of memblock_reserve() in memblock_virt_alloc_internal()
Date: Wed, 21 Dec 2016 23:30:33 +0000
Message-Id: <1482363033-24754-3-git-send-email-richard.weiyang@gmail.com>
In-Reply-To: <1482363033-24754-1-git-send-email-richard.weiyang@gmail.com>
References: <1482363033-24754-1-git-send-email-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: trivial@kernel.org, akpm@linux-foundation.org, mhocko@kernel.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wei Yang <richard.weiyang@gmail.com>

memblock_reserve() would add a new range to memblock.reserved in case the
new range is not totally covered by any of the current memblock.reserved
range. If the memblock.reserved is full and can't resize,
memblock_reserve() would fail.

This doesn't happen in real world now, I observed this during code review.
While theoretically, it has the chance to happen. And if it happens, others
would think this range of memory is still available and may corrupt the
memory.

This patch checks the return value and goto "done" after it succeeds.

Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
---
 mm/memblock.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/mm/memblock.c b/mm/memblock.c
index 4929e06..d0f2c96 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -1274,18 +1274,17 @@ static void * __init memblock_virt_alloc_internal(
 
 	if (max_addr > memblock.current_limit)
 		max_addr = memblock.current_limit;
-
 again:
 	alloc = memblock_find_in_range_node(size, align, min_addr, max_addr,
 					    nid, flags);
-	if (alloc)
+	if (alloc && !memblock_reserve(alloc, size))
 		goto done;
 
 	if (nid != NUMA_NO_NODE) {
 		alloc = memblock_find_in_range_node(size, align, min_addr,
 						    max_addr, NUMA_NO_NODE,
 						    flags);
-		if (alloc)
+		if (alloc && !memblock_reserve(alloc, size))
 			goto done;
 	}
 
@@ -1303,7 +1302,6 @@ static void * __init memblock_virt_alloc_internal(
 
 	return NULL;
 done:
-	memblock_reserve(alloc, size);
 	ptr = phys_to_virt(alloc);
 	memset(ptr, 0, size);
 
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
