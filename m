Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id E35046B0253
	for <linux-mm@kvack.org>; Sun, 18 Dec 2016 09:48:42 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id f188so333382146pgc.1
        for <linux-mm@kvack.org>; Sun, 18 Dec 2016 06:48:42 -0800 (PST)
Received: from mail-pg0-x242.google.com (mail-pg0-x242.google.com. [2607:f8b0:400e:c05::242])
        by mx.google.com with ESMTPS id 88si15332186plb.324.2016.12.18.06.48.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 18 Dec 2016 06:48:42 -0800 (PST)
Received: by mail-pg0-x242.google.com with SMTP id p66so15553721pga.2
        for <linux-mm@kvack.org>; Sun, 18 Dec 2016 06:48:42 -0800 (PST)
From: Wei Yang <richard.weiyang@gmail.com>
Subject: [PATCH V2 2/2] mm/memblock.c: check return value of memblock_reserve() in memblock_virt_alloc_internal()
Date: Sun, 18 Dec 2016 14:47:50 +0000
Message-Id: <1482072470-26151-3-git-send-email-richard.weiyang@gmail.com>
In-Reply-To: <1482072470-26151-1-git-send-email-richard.weiyang@gmail.com>
References: <1482072470-26151-1-git-send-email-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: trivial@kernel.org, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wei Yang <richard.weiyang@gmail.com>

memblock_reserve() may fail in case there is not enough regions.

This patch checks the return value.

Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
---
 mm/memblock.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/mm/memblock.c b/mm/memblock.c
index cd85303..93fa687 100644
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
