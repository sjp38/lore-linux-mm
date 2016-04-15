Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7D25E6B0261
	for <linux-mm@kvack.org>; Fri, 15 Apr 2016 05:01:04 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id k200so63817363lfg.1
        for <linux-mm@kvack.org>; Fri, 15 Apr 2016 02:01:04 -0700 (PDT)
Received: from outbound-smtp12.blacknight.com (outbound-smtp12.blacknight.com. [46.22.139.17])
        by mx.google.com with ESMTPS id b75si17485555wmf.43.2016.04.15.02.01.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Apr 2016 02:01:03 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail06.blacknight.ie [81.17.255.152])
	by outbound-smtp12.blacknight.com (Postfix) with ESMTPS id D7E2B1C19E5
	for <linux-mm@kvack.org>; Fri, 15 Apr 2016 10:01:02 +0100 (IST)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 09/28] mm, page_alloc: Convert nr_fair_skipped to bool
Date: Fri, 15 Apr 2016 09:59:01 +0100
Message-Id: <1460710760-32601-10-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1460710760-32601-1-git-send-email-mgorman@techsingularity.net>
References: <1460710760-32601-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Jesper Dangaard Brouer <brouer@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

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
