Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f171.google.com (mail-pf0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 277946B0253
	for <linux-mm@kvack.org>; Thu, 31 Mar 2016 22:07:02 -0400 (EDT)
Received: by mail-pf0-f171.google.com with SMTP id e128so61469663pfe.3
        for <linux-mm@kvack.org>; Thu, 31 Mar 2016 19:07:02 -0700 (PDT)
Received: from mail-pf0-x234.google.com (mail-pf0-x234.google.com. [2607:f8b0:400e:c00::234])
        by mx.google.com with ESMTPS id ez9si17796570pab.20.2016.03.31.19.07.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 Mar 2016 19:07:01 -0700 (PDT)
Received: by mail-pf0-x234.google.com with SMTP id e128so61469470pfe.3
        for <linux-mm@kvack.org>; Thu, 31 Mar 2016 19:07:01 -0700 (PDT)
From: js1304@gmail.com
Subject: [PATCH v2 1/5] mm/hugetlb: add same zone check in pfn_range_valid_gigantic()
Date: Fri,  1 Apr 2016 11:06:42 +0900
Message-Id: <1459476406-28418-2-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1459476406-28418-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1459476406-28418-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

alloc_gigantic_page() uses alloc_contig_range() and this
requires that requested range is in a single zone. To satisfy
that requirement, add this check to pfn_range_valid_gigantic().

Acked-by: Vlastimil Babka <vbabka@suse.cz>
Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/hugetlb.c | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 2c7f304..6bc7e9e 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1031,8 +1031,8 @@ static int __alloc_gigantic_page(unsigned long start_pfn,
 	return alloc_contig_range(start_pfn, end_pfn, MIGRATE_MOVABLE);
 }
 
-static bool pfn_range_valid_gigantic(unsigned long start_pfn,
-				unsigned long nr_pages)
+static bool pfn_range_valid_gigantic(struct zone *z,
+			unsigned long start_pfn, unsigned long nr_pages)
 {
 	unsigned long i, end_pfn = start_pfn + nr_pages;
 	struct page *page;
@@ -1043,6 +1043,9 @@ static bool pfn_range_valid_gigantic(unsigned long start_pfn,
 
 		page = pfn_to_page(i);
 
+		if (page_zone(page) != z)
+			return false;
+
 		if (PageReserved(page))
 			return false;
 
@@ -1075,7 +1078,7 @@ static struct page *alloc_gigantic_page(int nid, unsigned int order)
 
 		pfn = ALIGN(z->zone_start_pfn, nr_pages);
 		while (zone_spans_last_pfn(z, pfn, nr_pages)) {
-			if (pfn_range_valid_gigantic(pfn, nr_pages)) {
+			if (pfn_range_valid_gigantic(z, pfn, nr_pages)) {
 				/*
 				 * We release the zone lock here because
 				 * alloc_contig_range() will also lock the zone
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
