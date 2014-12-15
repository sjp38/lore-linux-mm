Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f179.google.com (mail-ig0-f179.google.com [209.85.213.179])
	by kanga.kvack.org (Postfix) with ESMTP id 2A18C6B0078
	for <linux-mm@kvack.org>; Mon, 15 Dec 2014 18:03:26 -0500 (EST)
Received: by mail-ig0-f179.google.com with SMTP id r2so6017420igi.6
        for <linux-mm@kvack.org>; Mon, 15 Dec 2014 15:03:26 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id b35si7669093iod.72.2014.12.15.15.03.24
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Dec 2014 15:03:25 -0800 (PST)
Date: Mon, 15 Dec 2014 15:03:23 -0800
From: akpm@linux-foundation.org
Subject: [patch 4/6] mm: fix invalid use of pfn_valid_within in
 test_pages_in_a_zone
Message-ID: <548f68bb.wuNDZDL8qk6xEWTm%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, akpm@linux-foundation.org, jcuster@sgi.com, isimatu.yasuaki@jp.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, rja@sgi.com, stable@vger.kernel.org

From: James Custer <jcuster@sgi.com>
Subject: mm: fix invalid use of pfn_valid_within in test_pages_in_a_zone

Offlining memory by 'echo 0 > /sys/devices/system/memory/memory#/online'
or reading valid_zones 'cat
/sys/devices/system/memory/memory#/valid_zones' causes BUG: unable to
handle kernel paging request due to invalid use of pfn_valid_within.  This
is due to a bug in test_pages_in_a_zone.

In order to use pfn_valid_within within a MAX_ORDER_NR_PAGES block of
pages, a valid pfn within the block must first be found.  There only needs
to be one valid pfn found in test_pages_in_a_zone in the first place.  So
the fix is to replace pfn_valid_within with pfn_valid such that the first
valid pfn within the pageblock is found (if it exists).  This works
independently of CONFIG_HOLES_IN_ZONE.

Signed-off-by: James Custer <jcuster@sgi.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Russ Anderson <rja@sgi.com>
Cc: <stable@vger.kernel.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 mm/memory_hotplug.c |   11 ++++++-----
 1 file changed, 6 insertions(+), 5 deletions(-)

diff -puN mm/memory_hotplug.c~mm-fix-invalid-use-of-pfn_valid_within-in-test_pages_in_a_zone mm/memory_hotplug.c
--- a/mm/memory_hotplug.c~mm-fix-invalid-use-of-pfn_valid_within-in-test_pages_in_a_zone
+++ a/mm/memory_hotplug.c
@@ -1331,7 +1331,7 @@ int is_mem_section_removable(unsigned lo
 }
 
 /*
- * Confirm all pages in a range [start, end) is belongs to the same zone.
+ * Confirm all pages in a range [start, end) belong to the same zone.
  */
 int test_pages_in_a_zone(unsigned long start_pfn, unsigned long end_pfn)
 {
@@ -1342,10 +1342,11 @@ int test_pages_in_a_zone(unsigned long s
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
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
