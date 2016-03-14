Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f179.google.com (mail-pf0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 846256B0256
	for <linux-mm@kvack.org>; Mon, 14 Mar 2016 03:32:06 -0400 (EDT)
Received: by mail-pf0-f179.google.com with SMTP id u190so100989725pfb.3
        for <linux-mm@kvack.org>; Mon, 14 Mar 2016 00:32:06 -0700 (PDT)
Received: from mail-pa0-x243.google.com (mail-pa0-x243.google.com. [2607:f8b0:400e:c03::243])
        by mx.google.com with ESMTPS id u79si17303824pfa.232.2016.03.14.00.32.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Mar 2016 00:32:05 -0700 (PDT)
Received: by mail-pa0-x243.google.com with SMTP id fl4so14020315pad.2
        for <linux-mm@kvack.org>; Mon, 14 Mar 2016 00:32:05 -0700 (PDT)
From: js1304@gmail.com
Subject: [PATCH 4/6] mm/vmstat: add zone range overlapping check
Date: Mon, 14 Mar 2016 16:31:35 +0900
Message-Id: <1457940697-2278-5-git-send-email-iamjoonsoo.kim@lge.com>
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
