Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id CC4586B006E
	for <linux-mm@kvack.org>; Tue,  9 Dec 2014 02:53:02 -0500 (EST)
Received: by mail-pa0-f43.google.com with SMTP id kx10so75873pab.2
        for <linux-mm@kvack.org>; Mon, 08 Dec 2014 23:53:02 -0800 (PST)
Received: from mailout3.samsung.com (mailout3.samsung.com. [203.254.224.33])
        by mx.google.com with ESMTPS id du2si559129pdb.156.2014.12.08.23.52.59
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Mon, 08 Dec 2014 23:53:00 -0800 (PST)
Received: from epcpsbgm1.samsung.com (epcpsbgm1 [203.254.230.26])
 by mailout3.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NGB00GWY1W9Z220@mailout3.samsung.com> for
 linux-mm@kvack.org; Tue, 09 Dec 2014 16:52:58 +0900 (KST)
From: Weijie Yang <weijie.yang@samsung.com>
Subject: [PATCH 2/3] mm: page_isolation: remove unnecessary
 freepage_migratetype check for unused page
Date: Tue, 09 Dec 2014 15:51:49 +0800
Message-id: <000201d01385$25a6c950$70f45bf0$%yang@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=utf-8
Content-transfer-encoding: 7bit
Content-language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: iamjoonsoo.kim@lge.com
Cc: 'Andrew Morton' <akpm@linux-foundation.org>, mgorman@suse.de, 'Rik van Riel' <riel@redhat.com>, vbabka@suse.cz, 'Johannes Weiner' <hannes@cmpxchg.org>, 'Minchan Kim' <minchan@kernel.org>, 'Weijie Yang' <weijie.yang.kh@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

when we test the pages in a range is free or not, there is a little
chance we encounter some page which is not in buddy but page_count is 0.
That means that page could be in the page-freeing path but not in the
buddy freelist, such as in pcplist or wait for the zone->lock which the
tester is holding.

Back to the freepage_migratetype, we use it for a cached value for decide
which free-list the page go when freeing page. If the pageblock is isolated
the page will go to free-list[MIGRATE_ISOLATE] even if the cached type is
not MIGRATE_ISOLATE, the commit ad53f92e(fix incorrect isolation behavior
by rechecking migratetype) patch series have ensure this.

So the freepage_migratetype check for page_count==0 page in
__test_page_isolated_in_pageblock() is meaningless.
This patch removes the unnecessary freepage_migratetype check.

Signed-off-by: Weijie Yang <weijie.yang@samsung.com>
---
 mm/page_isolation.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/mm/page_isolation.c b/mm/page_isolation.c
index 6e5174d..f7c9183 100644
--- a/mm/page_isolation.c
+++ b/mm/page_isolation.c
@@ -223,8 +223,7 @@ __test_page_isolated_in_pageblock(unsigned long pfn, unsigned long end_pfn,
 		page = pfn_to_page(pfn);
 		if (PageBuddy(page))
 			pfn += 1 << page_order(page);
-		else if (page_count(page) == 0 &&
-			get_freepage_migratetype(page) == MIGRATE_ISOLATE)
+		else if (page_count(page) == 0)
 			pfn += 1;
 		else if (skip_hwpoisoned_pages && PageHWPoison(page)) {
 			/*
-- 
1.7.10.4


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
