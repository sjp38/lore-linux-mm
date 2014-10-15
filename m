Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f170.google.com (mail-qc0-f170.google.com [209.85.216.170])
	by kanga.kvack.org (Postfix) with ESMTP id 2263C6B0069
	for <linux-mm@kvack.org>; Wed, 15 Oct 2014 15:59:21 -0400 (EDT)
Received: by mail-qc0-f170.google.com with SMTP id m20so1646717qcx.15
        for <linux-mm@kvack.org>; Wed, 15 Oct 2014 12:59:20 -0700 (PDT)
Received: from mail-qg0-x249.google.com (mail-qg0-x249.google.com [2607:f8b0:400d:c04::249])
        by mx.google.com with ESMTPS id s4si471882qcq.11.2014.10.15.12.59.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 15 Oct 2014 12:59:20 -0700 (PDT)
Received: by mail-qg0-f73.google.com with SMTP id i50so151640qgf.4
        for <linux-mm@kvack.org>; Wed, 15 Oct 2014 12:59:20 -0700 (PDT)
From: Jamie Liu <jamieliu@google.com>
Subject: [PATCH] mm: vmscan: count only dirty pages as congested
Date: Wed, 15 Oct 2014 12:58:35 -0700
Message-Id: <1413403115-1551-1-git-send-email-jamieliu@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>
Cc: Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jamie Liu <jamieliu@google.com>

shrink_page_list() counts all pages with a mapping, including clean
pages, toward nr_congested if they're on a write-congested BDI.
shrink_inactive_list() then sets ZONE_CONGESTED if nr_dirty ==
nr_congested. Fix this apples-to-oranges comparison by only counting
pages for nr_congested if they count for nr_dirty.

Signed-off-by: Jamie Liu <jamieliu@google.com>
---
 mm/vmscan.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index dcb4707..ad9cd9f 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -875,7 +875,8 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		 * end of the LRU a second time.
 		 */
 		mapping = page_mapping(page);
-		if ((mapping && bdi_write_congested(mapping->backing_dev_info)) ||
+		if (((dirty || writeback) && mapping &&
+		     bdi_write_congested(mapping->backing_dev_info)) ||
 		    (writeback && PageReclaim(page)))
 			nr_congested++;
 
-- 
2.1.0.rc2.206.gedb03e5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
