Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9EED06B0260
	for <linux-mm@kvack.org>; Sun, 11 Dec 2016 08:01:57 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id a8so85773838pfg.0
        for <linux-mm@kvack.org>; Sun, 11 Dec 2016 05:01:57 -0800 (PST)
Received: from mail-pg0-x241.google.com (mail-pg0-x241.google.com. [2607:f8b0:400e:c05::241])
        by mx.google.com with ESMTPS id m61si40380005plb.71.2016.12.11.05.01.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 11 Dec 2016 05:01:56 -0800 (PST)
Received: by mail-pg0-x241.google.com with SMTP id e9so7830000pgc.1
        for <linux-mm@kvack.org>; Sun, 11 Dec 2016 05:01:56 -0800 (PST)
From: Wei Yang <richard.weiyang@gmail.com>
Subject: [PATCH 2/2] mm/memblock.c: check return value of memblock_reserve() in memblock_virt_alloc_internal()
Date: Sun, 11 Dec 2016 12:59:50 +0000
Message-Id: <1481461190-11780-3-git-send-email-richard.weiyang@gmail.com>
In-Reply-To: <1481461190-11780-1-git-send-email-richard.weiyang@gmail.com>
References: <1481461190-11780-1-git-send-email-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: trivial@kernel.org, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wei Yang <richard.weiyang@gmail.com>

memblock_reserve() may fail in case there is not enough regions.

This patch checks the return value.

Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
---
 mm/memblock.c |    6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/mm/memblock.c b/mm/memblock.c
index 9d402d05..83ad703 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -1268,18 +1268,17 @@ static void * __init memblock_virt_alloc_internal(
 
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
 
@@ -1297,7 +1296,6 @@ again:
 
 	return NULL;
 done:
-	memblock_reserve(alloc, size);
 	ptr = phys_to_virt(alloc);
 	memset(ptr, 0, size);
 
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
