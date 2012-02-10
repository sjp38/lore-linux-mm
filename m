Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id F27786B13FF
	for <linux-mm@kvack.org>; Fri, 10 Feb 2012 12:32:44 -0500 (EST)
Received: from euspt2 (mailout2.w1.samsung.com [210.118.77.12])
 by mailout2.w1.samsung.com
 (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTP id <0LZ6005W6U2AB8@mailout2.w1.samsung.com> for linux-mm@kvack.org;
 Fri, 10 Feb 2012 17:32:34 +0000 (GMT)
Received: from linux.samsung.com ([106.116.38.10])
 by spt2.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LZ6000VFU29TZ@spt2.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 10 Feb 2012 17:32:34 +0000 (GMT)
Date: Fri, 10 Feb 2012 18:32:18 +0100
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: [PATCHv21 03/16] mm: compaction: introduce map_pages()
In-reply-to: <1328895151-5196-1-git-send-email-m.szyprowski@samsung.com>
Message-id: <1328895151-5196-4-git-send-email-m.szyprowski@samsung.com>
MIME-version: 1.0
Content-type: TEXT/PLAIN
Content-transfer-encoding: 7BIT
References: <1328895151-5196-1-git-send-email-m.szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org
Cc: Michal Nazarewicz <mina86@mina86.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Russell King <linux@arm.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daniel Walker <dwalker@codeaurora.org>, Mel Gorman <mel@csn.ul.ie>, Arnd Bergmann <arnd@arndb.de>, Jesse Barker <jesse.barker@linaro.org>, Jonathan Corbet <corbet@lwn.net>, Shariq Hasnain <shariq.hasnain@linaro.org>, Chunsang Jeong <chunsang.jeong@linaro.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Gaignard <benjamin.gaignard@linaro.org>, Rob Clark <rob.clark@linaro.org>, Ohad Ben-Cohen <ohad@wizery.com>

From: Michal Nazarewicz <mina86@mina86.com>

This commit creates a map_pages() function which map pages freed
using split_free_pages().  This merely moves some code from
isolate_freepages() so that it can be reused in other places.

Signed-off-by: Michal Nazarewicz <mina86@mina86.com>
Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
Acked-by: Mel Gorman <mel@csn.ul.ie>
---
 mm/compaction.c |   15 +++++++++++----
 1 files changed, 11 insertions(+), 4 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 62902b6..9bbcc53 100644
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
