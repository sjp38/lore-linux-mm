Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 2BF4B6B0261
	for <linux-mm@kvack.org>; Thu, 31 Mar 2016 22:07:21 -0400 (EDT)
Received: by mail-pa0-f50.google.com with SMTP id tt10so79032920pab.3
        for <linux-mm@kvack.org>; Thu, 31 Mar 2016 19:07:21 -0700 (PDT)
Received: from mail-pa0-x232.google.com (mail-pa0-x232.google.com. [2607:f8b0:400e:c03::232])
        by mx.google.com with ESMTPS id 83si17757717pfl.78.2016.03.31.19.07.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 Mar 2016 19:07:20 -0700 (PDT)
Received: by mail-pa0-x232.google.com with SMTP id fe3so79136791pab.1
        for <linux-mm@kvack.org>; Thu, 31 Mar 2016 19:07:20 -0700 (PDT)
From: js1304@gmail.com
Subject: [PATCH v2 5/5] power: add zone range overlapping check
Date: Fri,  1 Apr 2016 11:06:46 +0900
Message-Id: <1459476406-28418-6-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1459476406-28418-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1459476406-28418-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

There is a system that node's pfn are overlapped like as following.

-----pfn-------->
N0 N1 N2 N0 N1 N2

Therefore, we need to care this overlapping when iterating pfn range.

mark_free_pages() iterates requested zone's pfn range and unset
all range's bitmap first. And then it marks freepages in a zone
to the bitmap. If there is an overlapping zone, above unset could
clear previous marked bit and reference to this bitmap in the future
will cause the problem. To prevent it, this patch adds a zone check
in mark_free_pages().

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/page_alloc.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 0cfee62..437a934 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2156,6 +2156,10 @@ void mark_free_pages(struct zone *zone)
 	for (pfn = zone->zone_start_pfn; pfn < max_zone_pfn; pfn++)
 		if (pfn_valid(pfn)) {
 			page = pfn_to_page(pfn);
+
+			if (page_zone(page) != zone)
+				continue;
+
 			if (!swsusp_page_is_forbidden(page))
 				swsusp_unset_page_free(page);
 		}
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
