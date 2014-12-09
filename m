Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 9B3ED6B0032
	for <linux-mm@kvack.org>; Tue,  9 Dec 2014 02:41:38 -0500 (EST)
Received: by mail-pa0-f52.google.com with SMTP id eu11so37912pac.25
        for <linux-mm@kvack.org>; Mon, 08 Dec 2014 23:41:38 -0800 (PST)
Received: from mailout4.samsung.com (mailout4.samsung.com. [203.254.224.34])
        by mx.google.com with ESMTPS id l3si452996pdl.205.2014.12.08.23.41.36
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Mon, 08 Dec 2014 23:41:36 -0800 (PST)
Received: from epcpsbgm2.samsung.com (epcpsbgm2 [203.254.230.27])
 by mailout4.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NGB00JIU1DAFV10@mailout4.samsung.com> for
 linux-mm@kvack.org; Tue, 09 Dec 2014 16:41:34 +0900 (KST)
From: Weijie Yang <weijie.yang@samsung.com>
Subject: [PATCH] mm: page_alloc: place zone id check before VM_BUG_ON_PAGE check
Date: Tue, 09 Dec 2014 15:40:35 +0800
Message-id: <000001d01383$8e0f1120$aa2d3360$%yang@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=utf-8
Content-transfer-encoding: 7bit
Content-language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mgorman@suse.de
Cc: 'Andrew Morton' <akpm@linux-foundation.org>, 'Johannes Weiner' <hannes@cmpxchg.org>, 'Rik van Riel' <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, 'Weijie Yang' <weijie.yang.kh@gmail.com>

If the free page and its buddy has different zone id, the current
zone->lock cann't prevent buddy page getting allocated, this could
trigger VM_BUG_ON_PAGE in a very tiny chance:

cpu 0:						cpu 1:
hold zone_1 lock
check page and it buddy
PageBuddy(buddy) is true			hold zone_2 lock
page_order(buddy) == order is true		alloc buddy
trigger VM_BUG_ON_PAGE(page_count(buddy) != 0)

This patch fixes this issue by placing the zone id check before
the VM_BUG_ON_PAGE check.

Signed-off-by: Weijie Yang <weijie.yang@samsung.com>
---
 mm/page_alloc.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 616a2c9..491d055 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -488,17 +488,15 @@ static inline int page_is_buddy(struct page *page, struct page *buddy,
 		return 0;
 
 	if (page_is_guard(buddy) && page_order(buddy) == order) {
-		VM_BUG_ON_PAGE(page_count(buddy) != 0, buddy);
-
 		if (page_zone_id(page) != page_zone_id(buddy))
 			return 0;
 
+		VM_BUG_ON_PAGE(page_count(buddy) != 0, buddy);
+
 		return 1;
 	}
 
 	if (PageBuddy(buddy) && page_order(buddy) == order) {
-		VM_BUG_ON_PAGE(page_count(buddy) != 0, buddy);
-
 		/*
 		 * zone check is done late to avoid uselessly
 		 * calculating zone/node ids for pages that could
@@ -507,6 +505,8 @@ static inline int page_is_buddy(struct page *page, struct page *buddy,
 		if (page_zone_id(page) != page_zone_id(buddy))
 			return 0;
 
+		VM_BUG_ON_PAGE(page_count(buddy) != 0, buddy);
+
 		return 1;
 	}
 	return 0;
-- 
1.7.10.4


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
