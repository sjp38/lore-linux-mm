Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 760AB6B0069
	for <linux-mm@kvack.org>; Fri, 18 Nov 2011 11:43:25 -0500 (EST)
Received: from euspt2 (mailout2.w1.samsung.com [210.118.77.12])
 by mailout2.w1.samsung.com
 (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTP id <0LUV009047S9BT@mailout2.w1.samsung.com> for linux-mm@kvack.org;
 Fri, 18 Nov 2011 16:43:21 +0000 (GMT)
Received: from linux.samsung.com ([106.116.38.10])
 by spt2.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LUV009437S8YA@spt2.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 18 Nov 2011 16:43:21 +0000 (GMT)
Date: Fri, 18 Nov 2011 17:43:08 +0100
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: [PATCH 01/11] mm: page_alloc: handle MIGRATE_ISOLATE in
 free_pcppages_bulk()
In-reply-to: <1321634598-16859-1-git-send-email-m.szyprowski@samsung.com>
Message-id: <1321634598-16859-2-git-send-email-m.szyprowski@samsung.com>
MIME-version: 1.0
Content-type: TEXT/PLAIN
Content-transfer-encoding: 7BIT
References: <1321634598-16859-1-git-send-email-m.szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org
Cc: Michal Nazarewicz <mina86@mina86.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Russell King <linux@arm.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Ankita Garg <ankita@in.ibm.com>, Daniel Walker <dwalker@codeaurora.org>, Mel Gorman <mel@csn.ul.ie>, Arnd Bergmann <arnd@arndb.de>, Jesse Barker <jesse.barker@linaro.org>, Jonathan Corbet <corbet@lwn.net>, Shariq Hasnain <shariq.hasnain@linaro.org>, Chunsang Jeong <chunsang.jeong@linaro.org>, Dave Hansen <dave@linux.vnet.ibm.com>

From: Michal Nazarewicz <mina86@mina86.com>

If page is on PCP list while pageblock it belongs to gets isolated,
the page's private still holds the old migrate type.  This means
that free_pcppages_bulk() will put the page on a freelist of the
old migrate type instead of MIGRATE_ISOLATE.

This commit changes that by explicitly checking whether page's
pageblock's migrate type is MIGRATE_ISOLATE and if it is, overwrites
page's private data.

Signed-off-by: Michal Nazarewicz <mina86@mina86.com>
Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
---
 mm/page_alloc.c |   12 ++++++++++++
 1 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 9dd443d..58d1a2e 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -628,6 +628,18 @@ static void free_pcppages_bulk(struct zone *zone, int count,
 			page = list_entry(list->prev, struct page, lru);
 			/* must delete as __free_one_page list manipulates */
 			list_del(&page->lru);
+
+			/*
+			 * When page is isolated in set_migratetype_isolate()
+			 * function it's page_private is not changed since the
+			 * function has no way of knowing if it can touch it.
+			 * This means that when a page is on PCP list, it's
+			 * page_private no longer matches the desired migrate
+			 * type.
+			 */
+			if (get_pageblock_migratetype(page) == MIGRATE_ISOLATE)
+				set_page_private(page, MIGRATE_ISOLATE);
+
 			/* MIGRATE_MOVABLE list may include MIGRATE_RESERVEs */
 			__free_one_page(page, zone, 0, page_private(page));
 			trace_mm_page_pcpu_drain(page, 0, page_private(page));
-- 
1.7.1.569.g6f426

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
