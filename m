Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id 3B94F6B005D
	for <linux-mm@kvack.org>; Thu, 26 Jan 2012 04:01:05 -0500 (EST)
Received: from euspt1 (mailout1.w1.samsung.com [210.118.77.11])
 by mailout1.w1.samsung.com
 (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTP id <0LYE000OGEDO2M@mailout1.w1.samsung.com> for linux-mm@kvack.org;
 Thu, 26 Jan 2012 09:01:00 +0000 (GMT)
Received: from linux.samsung.com ([106.116.38.10])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LYE002PFEDN0I@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Thu, 26 Jan 2012 09:01:00 +0000 (GMT)
Date: Thu, 26 Jan 2012 10:00:44 +0100
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: [PATCH 02/15] mm: page_alloc: update migrate type of pages on pcp when
 isolating
In-reply-to: <1327568457-27734-1-git-send-email-m.szyprowski@samsung.com>
Message-id: <1327568457-27734-3-git-send-email-m.szyprowski@samsung.com>
MIME-version: 1.0
Content-type: TEXT/PLAIN
Content-transfer-encoding: 7BIT
References: <1327568457-27734-1-git-send-email-m.szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org
Cc: Michal Nazarewicz <mina86@mina86.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Russell King <linux@arm.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daniel Walker <dwalker@codeaurora.org>, Mel Gorman <mel@csn.ul.ie>, Arnd Bergmann <arnd@arndb.de>, Jesse Barker <jesse.barker@linaro.org>, Jonathan Corbet <corbet@lwn.net>, Shariq Hasnain <shariq.hasnain@linaro.org>, Chunsang Jeong <chunsang.jeong@linaro.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Gaignard <benjamin.gaignard@linaro.org>

From: Michal Nazarewicz <mina86@mina86.com>

This commit changes set_migratetype_isolate() so that it updates
migrate type of pages on pcp list which is saved in their
page_private.

Signed-off-by: Michal Nazarewicz <mina86@mina86.com>
Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
---
 include/linux/page-isolation.h |    6 ++++++
 mm/page_alloc.c                |    1 +
 mm/page_isolation.c            |   24 ++++++++++++++++++++++++
 3 files changed, 31 insertions(+), 0 deletions(-)

diff --git a/include/linux/page-isolation.h b/include/linux/page-isolation.h
index 051c1b1..8c02c2b 100644
--- a/include/linux/page-isolation.h
+++ b/include/linux/page-isolation.h
@@ -27,6 +27,12 @@ extern int
 test_pages_isolated(unsigned long start_pfn, unsigned long end_pfn);
 
 /*
+ * Check all pages in pageblock, find the ones on pcp list, and set
+ * their page_private to MIGRATE_ISOLATE.
+ */
+extern void update_pcp_isolate_block(unsigned long pfn);
+
+/*
  * Internal funcs.Changes pageblock's migrate type.
  * Please use make_pagetype_isolated()/make_pagetype_movable().
  */
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index e1c5656..70709e7 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5465,6 +5465,7 @@ out:
 	if (!ret) {
 		set_pageblock_migratetype(page, MIGRATE_ISOLATE);
 		move_freepages_block(zone, page, MIGRATE_ISOLATE);
+		update_pcp_isolate_block(pfn);
 	}
 
 	spin_unlock_irqrestore(&zone->lock, flags);
diff --git a/mm/page_isolation.c b/mm/page_isolation.c
index 4ae42bb..9ea2f6e 100644
--- a/mm/page_isolation.c
+++ b/mm/page_isolation.c
@@ -139,3 +139,27 @@ int test_pages_isolated(unsigned long start_pfn, unsigned long end_pfn)
 	spin_unlock_irqrestore(&zone->lock, flags);
 	return ret ? 0 : -EBUSY;
 }
+
+/* must hold zone->lock */
+void update_pcp_isolate_block(unsigned long pfn)
+{
+	unsigned long end_pfn = pfn + pageblock_nr_pages;
+	struct page *page;
+
+	while (pfn < end_pfn) {
+		if (!pfn_valid_within(pfn)) {
+			++pfn;
+			continue;
+		}
+
+		page = pfn_to_page(pfn);
+		if (PageBuddy(page)) {
+			pfn += 1 << page_order(page);
+		} else if (page_count(page) == 0) {
+			set_page_private(page, MIGRATE_ISOLATE);
+			++pfn;
+		} else {
+			++pfn;
+		}
+	}
+}
-- 
1.7.1.569.g6f426

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
