Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id 95A9C6B0044
	for <linux-mm@kvack.org>; Tue,  3 Apr 2012 10:10:25 -0400 (EDT)
MIME-version: 1.0
Content-transfer-encoding: 7BIT
Content-type: TEXT/PLAIN
Received: from euspt1 ([210.118.77.14]) by mailout4.w1.samsung.com
 (Sun Java(tm) System Messaging Server 6.3-8.04 (built Jul 29 2009; 32bit))
 with ESMTP id <0M1W00GRPQ1FDB70@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Tue, 03 Apr 2012 15:10:27 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0M1W00KPDQ1A84@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Tue, 03 Apr 2012 15:10:23 +0100 (BST)
Date: Tue, 03 Apr 2012 16:10:08 +0200
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: [PATCHv24 03/16] mm: compaction: introduce map_pages()
In-reply-to: <1333462221-3987-1-git-send-email-m.szyprowski@samsung.com>
Message-id: <1333462221-3987-4-git-send-email-m.szyprowski@samsung.com>
References: <1333462221-3987-1-git-send-email-m.szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org
Cc: Michal Nazarewicz <mina86@mina86.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Russell King <linux@arm.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daniel Walker <dwalker@codeaurora.org>, Mel Gorman <mel@csn.ul.ie>, Arnd Bergmann <arnd@arndb.de>, Jesse Barker <jesse.barker@linaro.org>, Jonathan Corbet <corbet@lwn.net>, Chunsang Jeong <chunsang.jeong@linaro.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Gaignard <benjamin.gaignard@linaro.org>, Rob Clark <rob.clark@linaro.org>, Ohad Ben-Cohen <ohad@wizery.com>, Sandeep Patil <psandeep.s@gmail.com>

From: Michal Nazarewicz <mina86@mina86.com>

This commit creates a map_pages() function which map pages freed
using split_free_pages().  This merely moves some code from
isolate_freepages() so that it can be reused in other places.

Signed-off-by: Michal Nazarewicz <mina86@mina86.com>
Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
Acked-by: Mel Gorman <mel@csn.ul.ie>
Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Tested-by: Robert Nelson <robertcnelson@gmail.com>
Tested-by: Barry Song <Baohua.Song@csr.com>
---
 mm/compaction.c |   15 +++++++++++----
 1 files changed, 11 insertions(+), 4 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index ee20fc0..d9d7b35 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -127,6 +127,16 @@ static bool suitable_migration_target(struct page *page)
 	return false;
 }
 
+static void map_pages(struct list_head *list)
+{
+	struct page *page;
+
+	list_for_each_entry(page, list, lru) {
+		arch_alloc_page(page, 0);
+		kernel_map_pages(page, 1, 1);
+	}
+}
+
 /*
  * Based on information in the current compact_control, find blocks
  * suitable for isolating free pages from and then isolate them.
@@ -206,10 +216,7 @@ static void isolate_freepages(struct zone *zone,
 	}
 
 	/* split_free_page does not map the pages */
-	list_for_each_entry(page, freelist, lru) {
-		arch_alloc_page(page, 0);
-		kernel_map_pages(page, 1, 1);
-	}
+	map_pages(freelist);
 
 	cc->free_pfn = high_pfn;
 	cc->nr_freepages = nr_freepages;
-- 
1.7.1.569.g6f426

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
