Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 1BD4A6B00DE
	for <linux-mm@kvack.org>; Mon, 10 Nov 2014 03:39:09 -0500 (EST)
Received: by mail-wi0-f180.google.com with SMTP id hi2so9600727wib.13
        for <linux-mm@kvack.org>; Mon, 10 Nov 2014 00:39:08 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id qq9si28065657wjc.105.2014.11.10.00.39.07
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 10 Nov 2014 00:39:07 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH] mm, compaction: prevent infinite loop in compact_zone
Date: Mon, 10 Nov 2014 09:38:30 +0100
Message-Id: <1415608710-8326-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Norbert Preining <preining@logic.at>, Pavel Machek <pavel@ucw.cz>, "P. Christeas" <xrg@linux.gr>

Several people have reported occasionally seeing processes stuck in
compact_zone(), even triggering soft lockups, in 3.18-rc2+. Testing revert of
e14c720efdd7 ("mm, compaction: remember position within pageblock in free
pages scanner") fixed the issue, although the stuck processes do not appear
to involve the free scanner. Finally, by code inspection, the bug was found
in isolate_migratepages() which uses a slightly different condition to detect
if the migration and free scanners have met, than compact_finished(). That has
not been a problem until commit e14c720efdd7 allowed the free scanner position
between individual invocations to be in the middle of a pageblock. In an
relatively rare case, the migration scanner position can end up at the
beginning of a pageblock, with the free scanner position in the middle of the
same pageblock. If it's the migration scanner's turn, isolate_migratepages()
exits immediately (without updating the position), while compact_finished()
decides to continue compaction, resulting in a potentially infinite loop. The
system can recover only if another process creates enough high-order pages to
make the watermark checks in compact_finished() pass.

This patch fixes the immediate problem by bumping the migration scanner's
position to meet the free scanner in isolate_migratepages(), when both are
within the same pageblock. This causes compact_finished() to terminate
properly. A more robust check in compact_finished() is planned as a cleanup
for better future maintainability.

Fixes: e14c720efdd73c6d69cd8d07fa894bcd11fe1973
Reported-and-tested-by: P. Christeas <xrg@linux.gr>
Link: http://marc.info/?l=linux-mm&m=141508604232522&w=2
Reported-and-tested-by: Norbert Preining <preining@logic.at>
Link: https://lkml.org/lkml/2014/11/4/904
Reported-by: Pavel Machek <pavel@ucw.cz>
Link: https://lkml.org/lkml/2014/11/7/164
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: David Rientjes <rientjes@google.com>
Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/compaction.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index ec74cf0..1b7a1be 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1029,8 +1029,12 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
 	}
 
 	acct_isolated(zone, cc);
-	/* Record where migration scanner will be restarted */
-	cc->migrate_pfn = low_pfn;
+	/* 
+	 * Record where migration scanner will be restarted. If we end up in
+	 * the same pageblock as the free scanner, make the scanners fully
+	 * meet so that compact_finished() terminates compaction.
+	 */
+	cc->migrate_pfn = (end_pfn <= cc->free_pfn) ? low_pfn : cc->free_pfn;
 
 	return cc->nr_migratepages ? ISOLATE_SUCCESS : ISOLATE_NONE;
 }
-- 
2.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
