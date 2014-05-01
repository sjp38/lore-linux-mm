Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f50.google.com (mail-ee0-f50.google.com [74.125.83.50])
	by kanga.kvack.org (Postfix) with ESMTP id D12656B0038
	for <linux-mm@kvack.org>; Thu,  1 May 2014 04:44:56 -0400 (EDT)
Received: by mail-ee0-f50.google.com with SMTP id c13so2052290eek.23
        for <linux-mm@kvack.org>; Thu, 01 May 2014 01:44:56 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m49si33537845eeo.41.2014.05.01.01.44.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 01 May 2014 01:44:55 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 05/17] mm: page_alloc: Only check the zone id check if pages are buddies
Date: Thu,  1 May 2014 09:44:36 +0100
Message-Id: <1398933888-4940-6-git-send-email-mgorman@suse.de>
In-Reply-To: <1398933888-4940-1-git-send-email-mgorman@suse.de>
References: <1398933888-4940-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Linux Kernel <linux-kernel@vger.kernel.org>

A node/zone index is used to check if pages are compatible for merging
but this happens unconditionally even if the buddy page is not free. Defer
the calculation as long as possible. Ideally we would check the zone boundary
but nodes can overlap.

Signed-off-by: Mel Gorman <mgorman@suse.de>
Acked-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/page_alloc.c | 16 +++++++++++++---
 1 file changed, 13 insertions(+), 3 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 3b6ae9d..8971953 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -508,16 +508,26 @@ static inline int page_is_buddy(struct page *page, struct page *buddy,
 	if (!pfn_valid_within(page_to_pfn(buddy)))
 		return 0;
 
-	if (page_zone_id(page) != page_zone_id(buddy))
-		return 0;
-
 	if (page_is_guard(buddy) && page_order(buddy) == order) {
 		VM_BUG_ON_PAGE(page_count(buddy) != 0, buddy);
+
+		if (page_zone_id(page) != page_zone_id(buddy))
+			return 0;
+
 		return 1;
 	}
 
 	if (PageBuddy(buddy) && page_order(buddy) == order) {
 		VM_BUG_ON_PAGE(page_count(buddy) != 0, buddy);
+
+		/*
+		 * zone check is done late to avoid uselessly
+		 * calculating zone/node ids for pages that could
+		 * never merge.
+		 */
+		if (page_zone_id(page) != page_zone_id(buddy))
+			return 0;
+
 		return 1;
 	}
 	return 0;
-- 
1.8.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
