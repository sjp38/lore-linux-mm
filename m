Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 4EFA86B0258
	for <linux-mm@kvack.org>; Mon, 14 Mar 2016 03:32:15 -0400 (EDT)
Received: by mail-pa0-f51.google.com with SMTP id td3so123990360pab.2
        for <linux-mm@kvack.org>; Mon, 14 Mar 2016 00:32:15 -0700 (PDT)
Received: from mail-pf0-x243.google.com (mail-pf0-x243.google.com. [2607:f8b0:400e:c00::243])
        by mx.google.com with ESMTPS id y8si11143194pas.240.2016.03.14.00.32.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Mar 2016 00:32:14 -0700 (PDT)
Received: by mail-pf0-x243.google.com with SMTP id q129so12464953pfb.3
        for <linux-mm@kvack.org>; Mon, 14 Mar 2016 00:32:14 -0700 (PDT)
From: js1304@gmail.com
Subject: [PATCH 6/6] power: add zone range overlapping check
Date: Mon, 14 Mar 2016 16:31:37 +0900
Message-Id: <1457940697-2278-7-git-send-email-iamjoonsoo.kim@lge.com>
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
index 08d5536..998f636 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2136,6 +2136,10 @@ void mark_free_pages(struct zone *zone)
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
