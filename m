Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f51.google.com (mail-ee0-f51.google.com [74.125.83.51])
	by kanga.kvack.org (Postfix) with ESMTP id C24106B0035
	for <linux-mm@kvack.org>; Tue, 15 Apr 2014 05:18:56 -0400 (EDT)
Received: by mail-ee0-f51.google.com with SMTP id c13so7500478eek.38
        for <linux-mm@kvack.org>; Tue, 15 Apr 2014 02:18:56 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y6si24665900eep.47.2014.04.15.02.18.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 15 Apr 2014 02:18:53 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH 2/2] mm/compaction: cleanup isolate_freepages()
Date: Tue, 15 Apr 2014 11:18:27 +0200
Message-Id: <1397553507-15330-2-git-send-email-vbabka@suse.cz>
In-Reply-To: <1397553507-15330-1-git-send-email-vbabka@suse.cz>
References: <5342BA34.8050006@suse.cz>
 <1397553507-15330-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Heesub Shin <heesub.shin@samsung.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dongjun Shin <d.j.shin@samsung.com>, Sunghwan Yun <sunghwan.yun@samsung.com>, Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>

isolate_freepages() is currently somewhat hard to follow thanks to many
different pfn variables. Especially misleading is the name 'high_pfn' which
looks like it is related to the 'low_pfn' variable, but in fact it is not.

This patch renames the 'high_pfn' variable to a hopefully less confusing name,
and slightly changes its handling without a functional change. A comment made
obsolete by recent changes is also updated.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Cc: Michal Nazarewicz <mina86@mina86.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Christoph Lameter <cl@linux.com>
Cc: Rik van Riel <riel@redhat.com>
---
 mm/compaction.c | 17 ++++++++---------
 1 file changed, 8 insertions(+), 9 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 627dc2e..169c7b2 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -671,7 +671,7 @@ static void isolate_freepages(struct zone *zone,
 				struct compact_control *cc)
 {
 	struct page *page;
-	unsigned long high_pfn, low_pfn, pfn, z_end_pfn;
+	unsigned long pfn, low_pfn, next_free_pfn, z_end_pfn;
 	int nr_freepages = cc->nr_freepages;
 	struct list_head *freelist = &cc->freepages;
 
@@ -688,11 +688,10 @@ static void isolate_freepages(struct zone *zone,
 	low_pfn = ALIGN(cc->migrate_pfn + 1, pageblock_nr_pages);
 
 	/*
-	 * Take care that if the migration scanner is at the end of the zone
-	 * that the free scanner does not accidentally move to the next zone
-	 * in the next isolation cycle.
+	 * Seed the value for max(next_free_pfn, pfn) updates. If there are
+	 * none, the pfn < low_pfn check will kick in.
 	 */
-	high_pfn = min(low_pfn, pfn);
+	next_free_pfn = 0;
 
 	z_end_pfn = zone_end_pfn(zone);
 
@@ -754,7 +753,7 @@ static void isolate_freepages(struct zone *zone,
 		 */
 		if (isolated) {
 			cc->finished_update_free = true;
-			high_pfn = max(high_pfn, pfn);
+			next_free_pfn = max(next_free_pfn, pfn);
 		}
 	}
 
@@ -766,9 +765,9 @@ static void isolate_freepages(struct zone *zone,
 	 * so that compact_finished() may detect this
 	 */
 	if (pfn < low_pfn)
-		cc->free_pfn = max(pfn, zone->zone_start_pfn);
-	else
-		cc->free_pfn = high_pfn;
+		next_free_pfn = max(pfn, zone->zone_start_pfn);
+
+	cc->free_pfn = next_free_pfn;
 	cc->nr_freepages = nr_freepages;
 }
 
-- 
1.8.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
