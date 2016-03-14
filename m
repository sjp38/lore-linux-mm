Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id DD5D66B007E
	for <linux-mm@kvack.org>; Mon, 14 Mar 2016 03:31:57 -0400 (EDT)
Received: by mail-pa0-f42.google.com with SMTP id fl4so150583407pad.0
        for <linux-mm@kvack.org>; Mon, 14 Mar 2016 00:31:57 -0700 (PDT)
Received: from mail-pf0-x241.google.com (mail-pf0-x241.google.com. [2607:f8b0:400e:c00::241])
        by mx.google.com with ESMTPS id ta4si7315493pac.193.2016.03.14.00.31.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Mar 2016 00:31:57 -0700 (PDT)
Received: by mail-pf0-x241.google.com with SMTP id u190so9230092pfb.2
        for <linux-mm@kvack.org>; Mon, 14 Mar 2016 00:31:57 -0700 (PDT)
From: js1304@gmail.com
Subject: [PATCH 2/6] mm/hugetlb: add same zone check in pfn_range_valid_gigantic()
Date: Mon, 14 Mar 2016 16:31:33 +0900
Message-Id: <1457940697-2278-3-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1457940697-2278-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1457940697-2278-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

alloc_gigantic_page() uses alloc_contig_range() and this
requires that requested range is in a single zone. To satisfy
that requirement, add this check to pfn_range_valid_gigantic().

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/hugetlb.c | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 06058ea..daceeb5 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1030,8 +1030,8 @@ static int __alloc_gigantic_page(unsigned long start_pfn,
 	return alloc_contig_range(start_pfn, end_pfn, MIGRATE_MOVABLE);
 }
 
-static bool pfn_range_valid_gigantic(unsigned long start_pfn,
-				unsigned long nr_pages)
+static bool pfn_range_valid_gigantic(struct zone *z,
+			unsigned long start_pfn, unsigned long nr_pages)
 {
 	unsigned long i, end_pfn = start_pfn + nr_pages;
 	struct page *page;
@@ -1042,6 +1042,9 @@ static bool pfn_range_valid_gigantic(unsigned long start_pfn,
 
 		page = pfn_to_page(i);
 
+		if (page_zone(page) != z)
+			return false;
+
 		if (PageReserved(page))
 			return false;
 
@@ -1074,7 +1077,7 @@ static struct page *alloc_gigantic_page(int nid, unsigned int order)
 
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
