Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id D008E6B0031
	for <linux-mm@kvack.org>; Sat,  5 Oct 2013 13:31:46 -0400 (EDT)
Received: by mail-pa0-f48.google.com with SMTP id bj1so5520412pad.21
        for <linux-mm@kvack.org>; Sat, 05 Oct 2013 10:31:46 -0700 (PDT)
Received: by mail-pd0-f171.google.com with SMTP id g10so5331945pdj.30
        for <linux-mm@kvack.org>; Sat, 05 Oct 2013 10:31:44 -0700 (PDT)
Message-ID: <52504CF8.6000708@gmail.com>
Date: Sun, 06 Oct 2013 01:31:36 +0800
From: Zhang Yanfei <zhangyanfei.yes@gmail.com>
MIME-Version: 1.0
Subject: [PATCH 1/2] mm/page_alloc.c: Implement an empty get_pfn_range_for_nid
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

From: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

Implement an empty get_pfn_range_for_nid for !CONFIG_HAVE_MEMBLOCK_NODE_MAP,
so that we could remove the #ifdef in free_area_init_node.

Signed-off-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
---
 mm/page_alloc.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index dd886fa..1fb13b6 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4566,6 +4566,11 @@ static unsigned long __meminit zone_absent_pages_in_node(int nid,
 }
 
 #else /* CONFIG_HAVE_MEMBLOCK_NODE_MAP */
+void __meminit get_pfn_range_for_nid(unsigned int nid,
+			unsigned long *ignored, unsigned long *ignored)
+{
+}
+
 static inline unsigned long __meminit zone_spanned_pages_in_node(int nid,
 					unsigned long zone_type,
 					unsigned long node_start_pfn,
@@ -4871,9 +4876,7 @@ void __paginginit free_area_init_node(int nid, unsigned long *zones_size,
 	pgdat->node_id = nid;
 	pgdat->node_start_pfn = node_start_pfn;
 	init_zone_allows_reclaim(nid);
-#ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
 	get_pfn_range_for_nid(nid, &start_pfn, &end_pfn);
-#endif
 	calculate_node_totalpages(pgdat, start_pfn, end_pfn,
 				  zones_size, zholes_size);
 
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
