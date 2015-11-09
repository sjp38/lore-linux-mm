Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 460956B0257
	for <linux-mm@kvack.org>; Mon,  9 Nov 2015 02:24:38 -0500 (EST)
Received: by padhx2 with SMTP id hx2so182021103pad.1
        for <linux-mm@kvack.org>; Sun, 08 Nov 2015 23:24:38 -0800 (PST)
Received: from mail-pa0-x234.google.com (mail-pa0-x234.google.com. [2607:f8b0:400e:c03::234])
        by mx.google.com with ESMTPS id zx6si20598072pbc.51.2015.11.08.23.24.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 08 Nov 2015 23:24:37 -0800 (PST)
Received: by pabfh17 with SMTP id fh17so190541929pab.0
        for <linux-mm@kvack.org>; Sun, 08 Nov 2015 23:24:37 -0800 (PST)
From: Joonsoo Kim <js1304@gmail.com>
Subject: [PATCH 3/3] mm/cma: always check which page cause allocation failure
Date: Mon,  9 Nov 2015 16:24:21 +0900
Message-Id: <1447053861-28824-3-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1447053861-28824-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1447053861-28824-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Nazarewicz <mina86@mina86.com>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Now, we have tracepoint in test_pages_isolated() to notify
pfn which cannot be isolated. But, in alloc_contig_range(),
some error path doesn't call test_pages_isolated() so it's still
hard to know exact pfn that causes allocation failure.

This patch change this situation by calling test_pages_isolated()
in almost error path. In allocation failure case, some overhead
is added by this change, but, allocation failure is really rare
event so it would not matter.

In fatal signal pending case, we don't call test_pages_isolated()
because this failure is intentional one.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/page_alloc.c | 10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index d89960d..e78d78f 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -6756,8 +6756,12 @@ int alloc_contig_range(unsigned long start, unsigned long end,
 	if (ret)
 		return ret;
 
+	/*
+	 * In case of -EBUSY, we'd like to know which page causes problem.
+	 * So, just fall through. We will check it in test_pages_isolated().
+	 */
 	ret = __alloc_contig_migrate_range(&cc, start, end);
-	if (ret)
+	if (ret && ret != -EBUSY)
 		goto done;
 
 	/*
@@ -6784,8 +6788,8 @@ int alloc_contig_range(unsigned long start, unsigned long end,
 	outer_start = start;
 	while (!PageBuddy(pfn_to_page(outer_start))) {
 		if (++order >= MAX_ORDER) {
-			ret = -EBUSY;
-			goto done;
+			outer_start = start;
+			break;
 		}
 		outer_start &= ~0UL << order;
 	}
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
