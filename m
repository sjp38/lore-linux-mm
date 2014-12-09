Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f179.google.com (mail-ig0-f179.google.com [209.85.213.179])
	by kanga.kvack.org (Postfix) with ESMTP id DFA0F6B006E
	for <linux-mm@kvack.org>; Tue,  9 Dec 2014 14:35:01 -0500 (EST)
Received: by mail-ig0-f179.google.com with SMTP id r2so1568084igi.6
        for <linux-mm@kvack.org>; Tue, 09 Dec 2014 11:35:01 -0800 (PST)
Received: from relay.sgi.com (relay2.sgi.com. [192.48.180.65])
        by mx.google.com with ESMTP id z1si1387008ioi.28.2014.12.09.11.34.59
        for <linux-mm@kvack.org>;
        Tue, 09 Dec 2014 11:34:59 -0800 (PST)
From: James Custer <jcuster@sgi.com>
Subject: [PATCH] mm: fix invalid use of pfn_valid_within in test_pages_in_a_zone
Date: Tue,  9 Dec 2014 13:34:56 -0600
Message-Id: <1418153696-167580-1-git-send-email-jcuster@sgi.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, kamezawa.hiroyu@jp.fujitsu.com
Cc: rja@sgi.com, dfults@sgi.com, James Custer <jcuster@sgi.com>

Offlining memory by 'echo 0 > /sys/devices/system/memory/memory#/online'
or reading valid_zones 'cat /sys/devices/system/memory/memory#/valid_zones'
causes BUG: unable to handle kernel paging request due to invalid use of
pfn_valid_within. This is due to a bug in test_pages_in_a_zone.

In order to use pfn_valid_within within a MAX_ORDER_NR_PAGES block of pages,
a valid pfn within the block must first be found. There only needs to be
one valid pfn found in test_pages_in_a_zone in the first place. So the
fix is to replace pfn_valid_within with pfn_valid such that the first
valid pfn within the pageblock is found (if it exists). This works
independently of CONFIG_HOLES_IN_ZONE.

Signed-off-by: James Custer <jcuster@sgi.com>
---
 mm/memory_hotplug.c | 11 ++++++-----
 1 file changed, 6 insertions(+), 5 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 1bf4807..304c187 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1331,7 +1331,7 @@ int is_mem_section_removable(unsigned long start_pfn, unsigned long nr_pages)
 }
 
 /*
- * Confirm all pages in a range [start, end) is belongs to the same zone.
+ * Confirm all pages in a range [start, end) belong to the same zone.
  */
 int test_pages_in_a_zone(unsigned long start_pfn, unsigned long end_pfn)
 {
@@ -1342,10 +1342,11 @@ int test_pages_in_a_zone(unsigned long start_pfn, unsigned long end_pfn)
 	for (pfn = start_pfn;
 	     pfn < end_pfn;
 	     pfn += MAX_ORDER_NR_PAGES) {
-		i = 0;
-		/* This is just a CONFIG_HOLES_IN_ZONE check.*/
-		while ((i < MAX_ORDER_NR_PAGES) && !pfn_valid_within(pfn + i))
-			i++;
+		/* Find the first valid pfn in this pageblock */
+		for (i = 0; i < MAX_ORDER_NR_PAGES; i++) {
+			if (pfn_valid(pfn + i))
+				break;
+		}
 		if (i == MAX_ORDER_NR_PAGES)
 			continue;
 		page = pfn_to_page(pfn + i);
-- 
1.8.2.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
