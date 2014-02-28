Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f47.google.com (mail-wg0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 1BE7D6B0074
	for <linux-mm@kvack.org>; Fri, 28 Feb 2014 09:15:37 -0500 (EST)
Received: by mail-wg0-f47.google.com with SMTP id n12so593629wgh.18
        for <linux-mm@kvack.org>; Fri, 28 Feb 2014 06:15:36 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ek2si1782247wid.85.2014.02.28.06.15.33
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 28 Feb 2014 06:15:34 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH 5/6] mm: compaction: do not set pageblock skip bit when already set
Date: Fri, 28 Feb 2014 15:15:03 +0100
Message-Id: <1393596904-16537-6-git-send-email-vbabka@suse.cz>
In-Reply-To: <1393596904-16537-1-git-send-email-vbabka@suse.cz>
References: <1393596904-16537-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>

Compaction migratepages scanner calls update_pageblock_skip() for blocks where
isolation failed. It currently does that also for blocks where no isolation
was attempted because the skip bit was already set. This is wasteful, so this
patch reuses the existing skipped_async_unsuitable flag to avoid setting the
skip bit again.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/compaction.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index f0db73b..20a75ee 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -529,8 +529,10 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
 			int mt;
 
 			last_pageblock_nr = pageblock_nr;
-			if (!isolation_suitable(cc, page))
+			if (!isolation_suitable(cc, page)) {
+				skipped_async_unsuitable = true;
 				goto next_pageblock;
+			}
 
 			/*
 			 * For async migration, also only scan in MOVABLE
-- 
1.8.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
