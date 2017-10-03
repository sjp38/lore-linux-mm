Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6C2326B0033
	for <linux-mm@kvack.org>; Tue,  3 Oct 2017 15:11:45 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id f84so21444621pfj.0
        for <linux-mm@kvack.org>; Tue, 03 Oct 2017 12:11:45 -0700 (PDT)
Received: from EUR02-HE1-obe.outbound.protection.outlook.com (mail-eopbgr10125.outbound.protection.outlook.com. [40.107.1.125])
        by mx.google.com with ESMTPS id v21si2546936pgc.739.2017.10.03.12.11.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 03 Oct 2017 12:11:43 -0700 (PDT)
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Subject: [PATCH v2] mm/mempolicy: fix NUMA_INTERLEAVE_HIT counter
Date: Tue,  3 Oct 2017 22:10:03 +0300
Message-Id: <20171003191003.8573-1-aryabinin@virtuozzo.com>
In-Reply-To: <20171003164720.22130-1-aryabinin@virtuozzo.com>
References: <20171003164720.22130-1-aryabinin@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Kemi Wang <kemi.wang@intel.com>, Mel Gorman <mgorman@techsingularity.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrey Ryabinin <aryabinin@virtuozzo.com>

Commit 3a321d2a3dde separated NUMA counters from zone counters, but
the NUMA_INTERLEAVE_HIT call site wasn't updated to use the new interface.
So alloc_page_interleave() actually increments NR_ZONE_INACTIVE_FILE
instead of NUMA_INTERLEAVE_HIT.

Fix this by using __inc_numa_state() interface to increment
NUMA_INTERLEAVE_HIT.

Fixes: 3a321d2a3dde ("mm: change the call sites of numa statistics items")
Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
---
 mm/mempolicy.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 006ba625c0b8..a2af6d58a68f 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -1920,8 +1920,11 @@ static struct page *alloc_page_interleave(gfp_t gfp, unsigned order,
 	struct page *page;
 
 	page = __alloc_pages(gfp, order, nid);
-	if (page && page_to_nid(page) == nid)
-		inc_zone_page_state(page, NUMA_INTERLEAVE_HIT);
+	if (page && page_to_nid(page) == nid) {
+		preempt_disable();
+		__inc_numa_state(page_zone(page), NUMA_INTERLEAVE_HIT);
+		preempt_enable();
+	}
 	return page;
 }
 
-- 
2.13.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
