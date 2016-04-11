Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 0A9346B0267
	for <linux-mm@kvack.org>; Mon, 11 Apr 2016 04:14:25 -0400 (EDT)
Received: by mail-wm0-f44.google.com with SMTP id f198so134583052wme.0
        for <linux-mm@kvack.org>; Mon, 11 Apr 2016 01:14:24 -0700 (PDT)
Received: from outbound-smtp01.blacknight.com (outbound-smtp01.blacknight.com. [81.17.249.7])
        by mx.google.com with ESMTPS id h11si17057034wmd.116.2016.04.11.01.14.23
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 11 Apr 2016 01:14:23 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp01.blacknight.com (Postfix) with ESMTPS id 8A63C98B7B
	for <linux-mm@kvack.org>; Mon, 11 Apr 2016 08:14:23 +0000 (UTC)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 09/22] mm, page_alloc: Convert nr_fair_skipped to bool
Date: Mon, 11 Apr 2016 09:13:32 +0100
Message-Id: <1460362424-26369-10-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1460362424-26369-1-git-send-email-mgorman@techsingularity.net>
References: <1460362424-26369-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

The number of zones skipped to a zone expiring its fair zone allocation quota
is irrelevant. Convert to bool.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 mm/page_alloc.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 4bce6298dd07..e778485a64c1 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2677,7 +2677,7 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
 	struct zoneref *z;
 	struct page *page = NULL;
 	struct zone *zone;
-	int nr_fair_skipped = 0;
+	bool fair_skipped;
 	bool zonelist_rescan;
 
 zonelist_scan:
@@ -2705,7 +2705,7 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
 			if (!zone_local(ac->preferred_zone, zone))
 				break;
 			if (test_bit(ZONE_FAIR_DEPLETED, &zone->flags)) {
-				nr_fair_skipped++;
+				fair_skipped = true;
 				continue;
 			}
 		}
@@ -2798,7 +2798,7 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
 	 */
 	if (alloc_flags & ALLOC_FAIR) {
 		alloc_flags &= ~ALLOC_FAIR;
-		if (nr_fair_skipped) {
+		if (fair_skipped) {
 			zonelist_rescan = true;
 			reset_alloc_batches(ac->preferred_zone);
 		}
-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
