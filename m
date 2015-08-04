Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id F373A6B0253
	for <linux-mm@kvack.org>; Tue,  4 Aug 2015 06:40:37 -0400 (EDT)
Received: by pacgq8 with SMTP id gq8so5496825pac.3
        for <linux-mm@kvack.org>; Tue, 04 Aug 2015 03:40:37 -0700 (PDT)
Received: from mailout3.samsung.com (mailout3.samsung.com. [203.254.224.33])
        by mx.google.com with ESMTPS id oe10si1205431pbb.101.2015.08.04.03.40.36
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 04 Aug 2015 03:40:37 -0700 (PDT)
Received: from epcpsbgr5.samsung.com
 (u145.gpu120.samsung.co.kr [203.254.230.145])
 by mailout3.samsung.com (Oracle Communications Messaging Server 7.0.5.31.0
 64bit (built May  5 2014))
 with ESMTP id <0NSK02CWL0BMR610@mailout3.samsung.com> for linux-mm@kvack.org;
 Tue, 04 Aug 2015 19:40:34 +0900 (KST)
From: Jaewon Kim <jaewon31.kim@samsung.com>
Subject: [PATCH v2] vmscan: fix increasing nr_isolated incurred by putback
 unevictable pages
Date: Tue, 04 Aug 2015 19:40:08 +0900
Message-id: <1438684808-12707-1-git-send-email-jaewon31.kim@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mgorman@suse.de, minchan@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, jaewon31.kim@gmail.com, Jaewon Kim <jaewon31.kim@samsung.com>

reclaim_clean_pages_from_list() assumes that shrink_page_list() returns
number of pages removed from the candidate list. But shrink_page_list()
puts back mlocked pages without passing it to caller and without
counting as nr_reclaimed. This incurrs increasing nr_isolated.
To fix this, this patch changes shrink_page_list() to pass unevictable
pages back to caller. Caller will take care those pages.

Signed-off-by: Jaewon Kim <jaewon31.kim@samsung.com>
---
Changes since v1

1/ changed subject from vmscan: reclaim_clean_pages_from_list() must count mlocked pages
2/ changed to return unevictable pages rather than returning the number of unevictable pages

 mm/vmscan.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 5e8eadd..a4b2d07 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1157,7 +1157,7 @@ cull_mlocked:
 		if (PageSwapCache(page))
 			try_to_free_swap(page);
 		unlock_page(page);
-		putback_lru_page(page);
+		list_add(&page->lru, &ret_pages);
 		continue;
 
 activate_locked:
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
