Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 734576B0039
	for <linux-mm@kvack.org>; Fri,  6 Dec 2013 03:39:17 -0500 (EST)
Received: by mail-pd0-f177.google.com with SMTP id q10so639069pdj.36
        for <linux-mm@kvack.org>; Fri, 06 Dec 2013 00:39:17 -0800 (PST)
Received: from LGEMRELSE6Q.lge.com (LGEMRELSE6Q.lge.com. [156.147.1.121])
        by mx.google.com with ESMTP id gn4si60655790pbc.171.2013.12.06.00.39.14
        for <linux-mm@kvack.org>;
        Fri, 06 Dec 2013 00:39:15 -0800 (PST)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH 4/4] mm/compaction: respect ignore_skip_hint in update_pageblock_skip
Date: Fri,  6 Dec 2013 17:41:50 +0900
Message-Id: <1386319310-28016-4-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1386319310-28016-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1386319310-28016-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Rafael Aquini <aquini@redhat.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <js1304@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

update_pageblock_skip() only fits to compaction which tries to isolate by
pageblock unit. If isolate_migratepages_range() is called by CMA, it try to
isolate regardless of pageblock unit and it don't reference
get_pageblock_skip() by ignore_skip_hint. We should also respect it on
update_pageblock_skip() to prevent from setting the wrong information.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

diff --git a/mm/compaction.c b/mm/compaction.c
index 805165b..f58bcd0 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -134,6 +134,10 @@ static void update_pageblock_skip(struct compact_control *cc,
 			bool migrate_scanner)
 {
 	struct zone *zone = cc->zone;
+
+	if (cc->ignore_skip_hint)
+		return;
+
 	if (!page)
 		return;
 
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
