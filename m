Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id E90B46B00E4
	for <linux-mm@kvack.org>; Mon, 17 Mar 2014 22:30:34 -0400 (EDT)
Received: by mail-pd0-f173.google.com with SMTP id z10so6390242pdj.4
        for <linux-mm@kvack.org>; Mon, 17 Mar 2014 19:30:34 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [119.145.14.64])
        by mx.google.com with ESMTPS id tm9si5944771pab.182.2014.03.17.19.30.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 17 Mar 2014 19:30:33 -0700 (PDT)
Message-ID: <5327AF4B.6000100@huawei.com>
Date: Tue, 18 Mar 2014 10:28:27 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: [PATCH] kmemcheck: move hook into __alloc_pages_nodemask() for the
 page allocator
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Vegard Nossum <vegard.nossum@oracle.com>, Pekka Enberg <penberg@kernel.org>, Peter Zijlstra <peterz@infradead.org>
Cc: Xishi Qiu <qiuxishi@huawei.com>, Li Zefan <lizefan@huawei.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Now kmemcheck_pagealloc_alloc() is only called by __alloc_pages_slowpath().
__alloc_pages_nodemask()
	__alloc_pages_slowpath()
		kmemcheck_pagealloc_alloc()

And the page will not be tracked by kmemcheck in the following path.
__alloc_pages_nodemask()
	get_page_from_freelist()

So move kmemcheck_pagealloc_alloc() into __alloc_pages_nodemask(), 
like this:
__alloc_pages_nodemask()
	...
	get_page_from_freelist()
	if (!page)
		__alloc_pages_slowpath()
	kmemcheck_pagealloc_alloc()
	...

Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
---
 mm/page_alloc.c |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index e3758a0..ce596b4 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2671,11 +2671,7 @@ rebalance:
 
 nopage:
 	warn_alloc_failed(gfp_mask, order, NULL);
-	return page;
 got_pg:
-	if (kmemcheck_enabled)
-		kmemcheck_pagealloc_alloc(page, order, gfp_mask);
-
 	return page;
 }
 
@@ -2748,6 +2744,8 @@ retry_cpuset:
 				preferred_zone, migratetype);
 	}
 
+	if (kmemcheck_enabled && page)
+		kmemcheck_pagealloc_alloc(page, order, gfp_mask);
 	trace_mm_page_alloc(page, order, gfp_mask, migratetype);
 
 out:
-- 
1.7.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
