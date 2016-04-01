Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f173.google.com (mail-pf0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 5AF7E6B0260
	for <linux-mm@kvack.org>; Thu, 31 Mar 2016 22:07:16 -0400 (EDT)
Received: by mail-pf0-f173.google.com with SMTP id n5so82743475pfn.2
        for <linux-mm@kvack.org>; Thu, 31 Mar 2016 19:07:16 -0700 (PDT)
Received: from mail-pf0-x230.google.com (mail-pf0-x230.google.com. [2607:f8b0:400e:c00::230])
        by mx.google.com with ESMTPS id d5si17767889pas.63.2016.03.31.19.07.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 Mar 2016 19:07:15 -0700 (PDT)
Received: by mail-pf0-x230.google.com with SMTP id e128so61473856pfe.3
        for <linux-mm@kvack.org>; Thu, 31 Mar 2016 19:07:15 -0700 (PDT)
From: js1304@gmail.com
Subject: [PATCH v2 4/5] mm/page_owner: add zone range overlapping check
Date: Fri,  1 Apr 2016 11:06:45 +0900
Message-Id: <1459476406-28418-5-git-send-email-iamjoonsoo.kim@lge.com>
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
