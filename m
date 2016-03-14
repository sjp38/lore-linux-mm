Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 6BB0E6B0005
	for <linux-mm@kvack.org>; Mon, 14 Mar 2016 03:31:53 -0400 (EDT)
Received: by mail-pa0-f52.google.com with SMTP id tt10so151732648pab.3
        for <linux-mm@kvack.org>; Mon, 14 Mar 2016 00:31:53 -0700 (PDT)
Received: from mail-pf0-x242.google.com (mail-pf0-x242.google.com. [2607:f8b0:400e:c00::242])
        by mx.google.com with ESMTPS id xe1si9218616pab.53.2016.03.14.00.31.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Mar 2016 00:31:52 -0700 (PDT)
Received: by mail-pf0-x242.google.com with SMTP id q129so12464471pfb.3
        for <linux-mm@kvack.org>; Mon, 14 Mar 2016 00:31:52 -0700 (PDT)
From: js1304@gmail.com
Subject: [PATCH 1/6] mm/page_alloc: fix same zone check in __pageblock_pfn_to_page()
Date: Mon, 14 Mar 2016 16:31:32 +0900
Message-Id: <1457940697-2278-2-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1457940697-2278-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1457940697-2278-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

There is a system that node's pfn are overlapped like as following.

-----pfn-------->
N0 N1 N2 N0 N1 N2

Therefore, we need to care this overlapping when iterating pfn range.

In __pageblock_pfn_to_page(), there is a check for this but it's
not sufficient. This check cannot distinguish the case that zone id
is the same but node id is different. This patch fixes it.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/page_alloc.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 8120f07..93293b4 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1173,8 +1173,7 @@ struct page *__pageblock_pfn_to_page(unsigned long start_pfn,
 
 	end_page = pfn_to_page(end_pfn);
 
-	/* This gives a shorter code than deriving page_zone(end_page) */
-	if (page_zone_id(start_page) != page_zone_id(end_page))
+	if (zone != page_zone(end_page))
 		return NULL;
 
 	return start_page;
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
