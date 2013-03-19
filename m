Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id 9BFDF6B0027
	for <linux-mm@kvack.org>; Tue, 19 Mar 2013 01:15:51 -0400 (EDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH 3/3] mm, nobootmem: do memset() after memblock_reserve()
Date: Tue, 19 Mar 2013 14:16:01 +0900
Message-Id: <1363670161-9214-3-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1363670161-9214-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1363670161-9214-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Yinghai Lu <yinghai@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Jiang Liu <liuj97@gmail.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Currently, we do memset() before reserving the area.
This may not cause any problem, but it is somewhat weird.
So change execution order.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

diff --git a/mm/nobootmem.c b/mm/nobootmem.c
index 589c673..f11ec1c 100644
--- a/mm/nobootmem.c
+++ b/mm/nobootmem.c
@@ -46,8 +46,8 @@ static void * __init __alloc_memory_core_early(int nid, u64 size, u64 align,
 		return NULL;
 
 	ptr = phys_to_virt(addr);
-	memset(ptr, 0, size);
 	memblock_reserve(addr, size);
+	memset(ptr, 0, size);
 	/*
 	 * The min_count is set to 0 so that bootmem allocated blocks
 	 * are never reported as leaks.
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
