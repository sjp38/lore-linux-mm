Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f172.google.com (mail-pf0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id C2CC36B025F
	for <linux-mm@kvack.org>; Thu, 31 Mar 2016 22:07:11 -0400 (EDT)
Received: by mail-pf0-f172.google.com with SMTP id x3so82755017pfb.1
        for <linux-mm@kvack.org>; Thu, 31 Mar 2016 19:07:11 -0700 (PDT)
Received: from mail-pf0-x231.google.com (mail-pf0-x231.google.com. [2607:f8b0:400e:c00::231])
        by mx.google.com with ESMTPS id a3si17745312pfj.107.2016.03.31.19.07.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 Mar 2016 19:07:11 -0700 (PDT)
Received: by mail-pf0-x231.google.com with SMTP id n5so82741915pfn.2
        for <linux-mm@kvack.org>; Thu, 31 Mar 2016 19:07:11 -0700 (PDT)
From: js1304@gmail.com
Subject: [PATCH v2 3/5] mm/vmstat: add zone range overlapping check
Date: Fri,  1 Apr 2016 11:06:44 +0900
Message-Id: <1459476406-28418-4-git-send-email-iamjoonsoo.kim@lge.com>
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

There are two places in vmstat.c that iterates pfn range and
they don't consider this overlapping. Add it.

Without this patch, above system could over count pageblock number
on a zone.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/vmstat.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/mm/vmstat.c b/mm/vmstat.c
index 5e43004..0a726e3 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -1010,6 +1010,9 @@ static void pagetypeinfo_showblockcount_print(struct seq_file *m,
 		if (!memmap_valid_within(pfn, page, zone))
 			continue;
 
+		if (page_zone(page) != zone)
+			continue;
+
 		mtype = get_pageblock_migratetype(page);
 
 		if (mtype < MIGRATE_TYPES)
@@ -1076,6 +1079,10 @@ static void pagetypeinfo_showmixedcount_print(struct seq_file *m,
 				continue;
 
 			page = pfn_to_page(pfn);
+
+			if (page_zone(page) != zone)
+				continue;
+
 			if (PageBuddy(page)) {
 				pfn += (1UL << page_order(page)) - 1;
 				continue;
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
