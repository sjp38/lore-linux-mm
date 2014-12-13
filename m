Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 558496B0032
	for <linux-mm@kvack.org>; Sat, 13 Dec 2014 03:22:35 -0500 (EST)
Received: by mail-pd0-f174.google.com with SMTP id fp1so8581940pdb.33
        for <linux-mm@kvack.org>; Sat, 13 Dec 2014 00:22:34 -0800 (PST)
Received: from mailout2.samsung.com (mailout2.samsung.com. [203.254.224.25])
        by mx.google.com with ESMTPS id x5si5336069pdo.45.2014.12.13.00.22.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Sat, 13 Dec 2014 00:22:33 -0800 (PST)
Received: from epcpsbgm1.samsung.com (epcpsbgm1 [203.254.230.26])
 by mailout2.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NGI005DQHXJI090@mailout2.samsung.com> for
 linux-mm@kvack.org; Sat, 13 Dec 2014 17:22:31 +0900 (KST)
From: Weijie Yang <weijie.yang@samsung.com>
Subject: [RESEND PATCH ] mm: page_alloc: place zone_id check before
 VM_BUG_ON_PAGE check
Date: Sat, 13 Dec 2014 16:21:36 +0800
Message-id: <000101d016ad$f0278720$d0769560$%yang@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=UTF-8
Content-transfer-encoding: 7bit
Content-language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Andrew Morton' <akpm@linux-foundation.org>
Cc: mgorman@suse.de, 'Johannes Weiner' <hannes@cmpxchg.org>, 'Rik van Riel' <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

If the freeing page and its buddy page are not at the same zone, the current
holding zone->lock for the freeing page cann't prevent buddy page getting
allocated, this could trigger VM_BUG_ON_PAGE in page_is_buddy() at a
very tiny chance, such as:

cpu 0:						cpu 1:
hold zone_1 lock
check page and it buddy
PageBuddy(buddy) is true			hold zone_2 lock
page_order(buddy) == order is true		alloc buddy
trigger VM_BUG_ON_PAGE(page_count(buddy) != 0)

zone_1->lock prevents the freeing page getting allocated
zone_2->lock prevents the buddy page getting allocated
they are not the same zone->lock.

If we cann't remove the zone_id check statement, it's better handle
this rare race. This patch fixes this by placing the zone_id check
before the VM_BUG_ON_PAGE check.

Signed-off-by: Weijie Yang <weijie.yang@samsung.com>
Acked-by: Mel Gorman <mgorman@suse.de>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Rik van Riel <riel@redhat.com>
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
