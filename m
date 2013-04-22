Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id D0AAB6B0033
	for <linux-mm@kvack.org>; Mon, 22 Apr 2013 04:23:59 -0400 (EDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH 2/2] mm, nobootmem: do memset() after memblock_reserve()
Date: Mon, 22 Apr 2013 17:25:13 +0900
Message-Id: <1366619113-28017-2-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1366619113-28017-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1366619113-28017-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Yinghai Lu <yinghai@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Jiang Liu <liuj97@gmail.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Currently, we do memset() before reserving the area.
This may not cause any problem, but it is somewhat weird.
So change execution order.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

diff --git a/mm/nobootmem.c b/mm/nobootmem.c
index a31be7a..bdd3fa2 100644
--- a/mm/nobootmem.c
+++ b/mm/nobootmem.c
@@ -45,9 +45,9 @@ static void * __init __alloc_memory_core_early(int nid, u64 size, u64 align,
 	if (!addr)
 		return NULL;
 
+	memblock_reserve(addr, size);
 	ptr = phys_to_virt(addr);
 	memset(ptr, 0, size);
-	memblock_reserve(addr, size);
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
