Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id A20356B0039
	for <linux-mm@kvack.org>; Thu,  9 Jan 2014 02:04:37 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id lf10so616253pab.35
        for <linux-mm@kvack.org>; Wed, 08 Jan 2014 23:04:37 -0800 (PST)
Received: from LGEMRELSE7Q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id eb3si2955614pbd.257.2014.01.08.23.04.34
        for <linux-mm@kvack.org>;
        Wed, 08 Jan 2014 23:04:36 -0800 (PST)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH 4/7] mm/isolation: remove invalid check condition
Date: Thu,  9 Jan 2014 16:04:44 +0900
Message-Id: <1389251087-10224-5-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1389251087-10224-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1389251087-10224-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Jiang Liu <jiang.liu@huawei.com>, Mel Gorman <mgorman@suse.de>, Cody P Schafer <cody@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Minchan Kim <minchan@kernel.org>, Michal Nazarewicz <mina86@mina86.com>, Andi Kleen <ak@linux.intel.com>, Wei Yongjun <yongjun_wei@trendmicro.com.cn>, Tang Chen <tangchen@cn.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

test_page_isolated() checks stability of pages. It checks two conditions,
one is that the page is on isolate migratetype and the other is that
the page is on the buddy and the isolate freelist. With satisfying
these two conditions, we can determine that the page is stable and then
go forward.

__test_page_isolated_in_pageblock() is one of the main functions for this
test. In that function, if it meets the page with page_count 0 and
isolate migratetype, it decides that this page is stable. But this is not
true, because there is possiblity that this kind of page is on the pcp
and then it can be allocated by other users even though we hold the zone
lock. So removing this check.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

diff --git a/mm/page_isolation.c b/mm/page_isolation.c
index d1473b2..534fb3a 100644
--- a/mm/page_isolation.c
+++ b/mm/page_isolation.c
@@ -199,9 +199,6 @@ __test_page_isolated_in_pageblock(unsigned long pfn, unsigned long end_pfn,
 			}
 			pfn += 1 << page_order(page);
 		}
-		else if (page_count(page) == 0 &&
-			get_freepage_migratetype(page) == MIGRATE_ISOLATE)
-			pfn += 1;
 		else if (skip_hwpoisoned_pages && PageHWPoison(page)) {
 			/*
 			 * The HWPoisoned page may be not in buddy
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
