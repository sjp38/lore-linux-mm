Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id EDD1A6B0005
	for <linux-mm@kvack.org>; Tue, 19 Mar 2013 01:15:47 -0400 (EDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH 1/3] mm, nobootmem: fix wrong usage of max_low_pfn
Date: Tue, 19 Mar 2013 14:15:59 +0900
Message-Id: <1363670161-9214-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Yinghai Lu <yinghai@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Jiang Liu <liuj97@gmail.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

max_low_pfn reflect the number of _pages_ in the system,
not the maximum PFN. You can easily find that fact in init_bootmem().
So fix it.

Additionally, if 'start_pfn == end_pfn', we don't need to go futher,
so change range check.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

diff --git a/mm/nobootmem.c b/mm/nobootmem.c
index 5e07d36..4711e91 100644
--- a/mm/nobootmem.c
+++ b/mm/nobootmem.c
@@ -110,9 +110,9 @@ static unsigned long __init __free_memory_core(phys_addr_t start,
 {
 	unsigned long start_pfn = PFN_UP(start);
 	unsigned long end_pfn = min_t(unsigned long,
-				      PFN_DOWN(end), max_low_pfn);
+				      PFN_DOWN(end), min_low_pfn);
 
-	if (start_pfn > end_pfn)
+	if (start_pfn >= end_pfn)
 		return 0;
 
 	__free_pages_memory(start_pfn, end_pfn);
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
