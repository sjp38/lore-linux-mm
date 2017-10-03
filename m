Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 56BF56B0038
	for <linux-mm@kvack.org>; Tue,  3 Oct 2017 12:44:33 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id y192so24131366pgd.0
        for <linux-mm@kvack.org>; Tue, 03 Oct 2017 09:44:33 -0700 (PDT)
Received: from EUR02-VE1-obe.outbound.protection.outlook.com (mail-eopbgr20101.outbound.protection.outlook.com. [40.107.2.101])
        by mx.google.com with ESMTPS id a19si4804159pgn.217.2017.10.03.09.44.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 03 Oct 2017 09:44:31 -0700 (PDT)
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Subject: [PATCH] mm/mempolicy: fix NUMA_INTERLEAVE_HIT counter
Date: Tue,  3 Oct 2017 19:47:20 +0300
Message-Id: <20171003164720.22130-1-aryabinin@virtuozzo.com>
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
 mm/mempolicy.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 006ba625c0b8..3a18f0a091c4 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -1920,8 +1920,13 @@ static struct page *alloc_page_interleave(gfp_t gfp, unsigned order,
 	struct page *page;
 
 	page = __alloc_pages(gfp, order, nid);
-	if (page && page_to_nid(page) == nid)
-		inc_zone_page_state(page, NUMA_INTERLEAVE_HIT);
+	if (page && page_to_nid(page) == nid) {
+		unsigned long flags;
+
+		local_irq_save(flags);
+		__inc_numa_state(page_zone(page), NUMA_INTERLEAVE_HIT);
+		local_irq_restore(flags);
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
