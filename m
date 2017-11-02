Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id CC3FB6B0069
	for <linux-mm@kvack.org>; Thu,  2 Nov 2017 08:17:27 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id q196so2847436wmg.15
        for <linux-mm@kvack.org>; Thu, 02 Nov 2017 05:17:27 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g92si511009ede.406.2017.11.02.05.17.25
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 02 Nov 2017 05:17:26 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH 3/3] mm, compaction: remove unneeded pageblock_skip_persistent() checks
Date: Thu,  2 Nov 2017 13:17:06 +0100
Message-Id: <20171102121706.21504-3-vbabka@suse.cz>
In-Reply-To: <20171102121706.21504-1-vbabka@suse.cz>
References: <20171102121706.21504-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@techsingularity.net>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Vlastimil Babka <vbabka@suse.cz>

Commit f3c931633a59 ("mm, compaction: persistently skip hugetlbfs pageblocks")
has introduced pageblock_skip_persistent() checks into migration and free
scanners, to make sure pageblocks that should be persistently skipped are
marked as such, regardless of the ignore_skip_hint flag.

Since the previous patch introduced a new no_set_skip_hint flag, the ignore flag
no longer prevents marking pageblocks as skipped. Therefore we can remove the
special cases. The relevant pageblocks will be marked as skipped by the common
logic which marks each pageblock where no page could be isolated. This makes the
code simpler.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/compaction.c | 18 +++---------------
 1 file changed, 3 insertions(+), 15 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index a92860d89679..b557aac09e92 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -475,10 +475,7 @@ static unsigned long isolate_freepages_block(struct compact_control *cc,
 		if (PageCompound(page)) {
 			const unsigned int order = compound_order(page);
 
-			if (pageblock_skip_persistent(page, order)) {
-				set_pageblock_skip(page);
-				blockpfn = end_pfn;
-			} else if (likely(order < MAX_ORDER)) {
+			if (likely(order < MAX_ORDER)) {
 				blockpfn += (1UL << order) - 1;
 				cursor += (1UL << order) - 1;
 			}
@@ -800,10 +797,7 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 		if (PageCompound(page)) {
 			const unsigned int order = compound_order(page);
 
-			if (pageblock_skip_persistent(page, order)) {
-				set_pageblock_skip(page);
-				low_pfn = end_pfn;
-			} else if (likely(order < MAX_ORDER))
+			if (likely(order < MAX_ORDER))
 				low_pfn += (1UL << order) - 1;
 			goto isolate_fail;
 		}
@@ -866,13 +860,7 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 			 * is safe to read and it's 0 for tail pages.
 			 */
 			if (unlikely(PageCompound(page))) {
-				const unsigned int order = compound_order(page);
-
-				if (pageblock_skip_persistent(page, order)) {
-					set_pageblock_skip(page);
-					low_pfn = end_pfn;
-				} else
-					low_pfn += (1UL << order) - 1;
+				low_pfn += (1UL << compound_order(page)) - 1;
 				goto isolate_fail;
 			}
 		}
-- 
2.14.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
