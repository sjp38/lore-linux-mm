Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f50.google.com (mail-ee0-f50.google.com [74.125.83.50])
	by kanga.kvack.org (Postfix) with ESMTP id 402756B003A
	for <linux-mm@kvack.org>; Fri, 18 Apr 2014 10:50:49 -0400 (EDT)
Received: by mail-ee0-f50.google.com with SMTP id c13so1724918eek.9
        for <linux-mm@kvack.org>; Fri, 18 Apr 2014 07:50:48 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t3si40600065eeg.91.2014.04.18.07.50.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 18 Apr 2014 07:50:47 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 07/16] mm: page_alloc: Only check the zone id check if pages are buddies
Date: Fri, 18 Apr 2014 15:50:34 +0100
Message-Id: <1397832643-14275-8-git-send-email-mgorman@suse.de>
In-Reply-To: <1397832643-14275-1-git-send-email-mgorman@suse.de>
References: <1397832643-14275-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Linux-FSDevel <linux-fsdevel@vger.kernel.org>

A node/zone index is used to check if pages are compatible for merging
but this happens unconditionally even if the buddy page is not free. Defer
the calculation as long as possible. Ideally we would check the zone boundary
but nodes can overlap.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/page_alloc.c | 16 +++++++++++++---
 1 file changed, 13 insertions(+), 3 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 88a6dac..c5933a5 100644
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
