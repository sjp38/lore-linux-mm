Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 1A6116B0257
	for <linux-mm@kvack.org>; Mon, 14 Mar 2016 03:32:11 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id tt10so151738058pab.3
        for <linux-mm@kvack.org>; Mon, 14 Mar 2016 00:32:11 -0700 (PDT)
Received: from mail-pa0-x243.google.com (mail-pa0-x243.google.com. [2607:f8b0:400e:c03::243])
        by mx.google.com with ESMTPS id a5si1462915pat.63.2016.03.14.00.32.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Mar 2016 00:32:10 -0700 (PDT)
Received: by mail-pa0-x243.google.com with SMTP id q6so14031985pav.0
        for <linux-mm@kvack.org>; Mon, 14 Mar 2016 00:32:10 -0700 (PDT)
From: js1304@gmail.com
Subject: [PATCH 5/6] mm/page_owner: add zone range overlapping check
Date: Mon, 14 Mar 2016 16:31:36 +0900
Message-Id: <1457940697-2278-6-git-send-email-iamjoonsoo.kim@lge.com>
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

There are one place in page_owner.c that iterates pfn range and
it doesn't consider this overlapping. Add it.

Without this patch, above system could over count early allocated
page number before page_owner is activated.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/page_owner.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/mm/page_owner.c b/mm/page_owner.c
index ac3d8d1..438768c 100644
--- a/mm/page_owner.c
+++ b/mm/page_owner.c
@@ -301,6 +301,9 @@ static void init_pages_in_zone(pg_data_t *pgdat, struct zone *zone)
 
 			page = pfn_to_page(pfn);
 
+			if (page_zone(page) != zone)
+				continue;
+
 			/*
 			 * We are safe to check buddy flag and order, because
 			 * this is init stage and only single thread runs.
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
