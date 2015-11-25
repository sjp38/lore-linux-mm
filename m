Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 731016B0038
	for <linux-mm@kvack.org>; Wed, 25 Nov 2015 00:32:55 -0500 (EST)
Received: by pacej9 with SMTP id ej9so45842372pac.2
        for <linux-mm@kvack.org>; Tue, 24 Nov 2015 21:32:55 -0800 (PST)
Received: from mail-pa0-x231.google.com (mail-pa0-x231.google.com. [2607:f8b0:400e:c03::231])
        by mx.google.com with ESMTPS id l77si31836555pfi.91.2015.11.24.21.32.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Nov 2015 21:32:54 -0800 (PST)
Received: by padhx2 with SMTP id hx2so45922148pad.1
        for <linux-mm@kvack.org>; Tue, 24 Nov 2015 21:32:54 -0800 (PST)
From: Joonsoo Kim <js1304@gmail.com>
Subject: [PATCH v2] mm/cma: always check which page cause allocation failure
Date: Wed, 25 Nov 2015 14:32:45 +0900
Message-Id: <1448429565-29748-1-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <20151125023913.GA9563@js1304-P5Q-DELUXE>
References: <20151125023913.GA9563@js1304-P5Q-DELUXE>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Nazarewicz <mina86@mina86.com>, Minchan Kim <minchan@kernel.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

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

There was a bogus outer_start problem due to unchecked buddy order
and this patch also fix it. Before this patch, it didn't matter,
because end result is same thing. But, after this patch,
tracepoint will report failed pfn so it should be accurate.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/page_alloc.c | 23 ++++++++++++++++++++---
 1 file changed, 20 insertions(+), 3 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index d0499ff..21e9172 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -6748,8 +6748,12 @@ int alloc_contig_range(unsigned long start, unsigned long end,
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
@@ -6776,12 +6780,25 @@ int alloc_contig_range(unsigned long start, unsigned long end,
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
 
+	if (outer_start != start) {
+		order = page_order(pfn_to_page(outer_start));
+
+		/*
+		 * outer_start page could be small order buddy page and
+		 * it doesn't include start page. Adjust outer_start
+		 * in this case to report failed page properly
+		 * on tracepoint in test_pages_isolated()
+		 */
+		if (outer_start + (1UL << order) <= start)
+			outer_start = start;
+	}
+
 	/* Make sure the range is really isolated. */
 	if (test_pages_isolated(outer_start, end, false)) {
 		pr_info("%s: [%lx, %lx) PFNs busy\n",
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
