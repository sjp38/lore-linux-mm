Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 806FE6B0268
	for <linux-mm@kvack.org>; Mon, 20 Nov 2017 14:40:00 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id z184so10407541pgd.0
        for <linux-mm@kvack.org>; Mon, 20 Nov 2017 11:40:00 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id i8si8657095pgv.239.2017.11.20.11.39.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 Nov 2017 11:39:59 -0800 (PST)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [PATCH 1/1] mm/cma: fix alloc_contig_range ret code/potential leak
Date: Mon, 20 Nov 2017 11:39:30 -0800
Message-Id: <20171120193930.23428-2-mike.kravetz@oracle.com>
In-Reply-To: <20171120193930.23428-1-mike.kravetz@oracle.com>
References: <20171120193930.23428-1-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Vlastimil Babka <vbabka@suse.cz>, Michal Nazarewicz <mina86@mina86.com>, Michal Hocko <mhocko@suse.com>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>, stable@vger.kernel.org

If the call __alloc_contig_migrate_range() in alloc_contig_range
returns -EBUSY, processing continues so that test_pages_isolated()
is called where there is a tracepoint to identify the busy pages.
However, it is possible for busy pages to become available between
the calls to these two routines.  In this case, the range of pages
may be allocated.   Unfortunately, the original return code (ret
== -EBUSY) is still set and returned to the caller.  Therefore,
the caller believes the pages were not allocated and they are leaked.

Update the return code with the value from test_pages_isolated().

Fixes: 8ef5849fa8a2 ("mm/cma: always check which page caused allocation failure")
Cc: <stable@vger.kernel.org>
Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
---
 mm/page_alloc.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 77e4d3c5c57b..3605ca82fd29 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -7632,10 +7632,10 @@ int alloc_contig_range(unsigned long start, unsigned long end,
 	}
 
 	/* Make sure the range is really isolated. */
-	if (test_pages_isolated(outer_start, end, false)) {
+	ret = test_pages_isolated(outer_start, end, false);
+	if (ret) {
 		pr_info_ratelimited("%s: [%lx, %lx) PFNs busy\n",
 			__func__, outer_start, end);
-		ret = -EBUSY;
 		goto done;
 	}
 
-- 
2.13.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
