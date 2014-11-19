Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f50.google.com (mail-wg0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id D69BD6B0075
	for <linux-mm@kvack.org>; Wed, 19 Nov 2014 17:53:40 -0500 (EST)
Received: by mail-wg0-f50.google.com with SMTP id k14so2140805wgh.23
        for <linux-mm@kvack.org>; Wed, 19 Nov 2014 14:53:40 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id am9si775704wjc.71.2014.11.19.14.53.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 19 Nov 2014 14:53:39 -0800 (PST)
Message-ID: <546D1F71.6030304@suse.cz>
Date: Wed, 19 Nov 2014 23:53:37 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH 5/5] mm, compaction: more focused lru and pcplists draining
References: <1412696019-21761-1-git-send-email-vbabka@suse.cz> <1412696019-21761-6-git-send-email-vbabka@suse.cz> <20141027074112.GC23379@js1304-P5Q-DELUXE> <545738F1.4010307@suse.cz> <20141104003733.GB8412@js1304-P5Q-DELUXE> <5464A84C.1040903@suse.cz> <20141114070501.GA24817@js1304-P5Q-DELUXE>
In-Reply-To: <20141114070501.GA24817@js1304-P5Q-DELUXE>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>

On 11/14/2014 08:05 AM, Joonsoo Kim wrote:
>> What about this scenario, with pageblock order:
>> 
>> - record cc->migrate_pfn pointing to pageblock X
>> - isolate_migratepages() skips the pageblock due to e.g. skip bit,
>> or the pageblock being a THP already...
>> - loop to pageblock X+1, last_migrated_pfn is still set to pfn of
>> pageblock X (more precisely the pfn is (X << pageblock_order) - 1
>> per your code, but doesn't matter)
>> - isolate_migratepages isolates something, but ends up somewhere in
>> the middle of pageblock due to COMPACT_CLUSTER_MAX
>> - cc->migrate_pfn points to pageblock X+1 (plus some pages it scanned)
>> - so it will decide that it has fully migrated pageblock X and it's
>> time to drain. But the drain is most likely useless - we didn't
>> migrate anything in pageblock X, we skipped it. And in X+1 we didn't
>> migrate everything yet, so we should drain only after finishing the
>> other part of the pageblock.
> 
> Yes, but, it can be easily fixed.
> 
>   while (compact_finished()) {
>           unsigned long prev_migrate_pfn = cc->migrate_pfn;
> 
>           isolate_migratepages()
>           switch case {
>                   NONE:
>                   goto check_drain;
>                   SUCCESS:
>                   if (!last_migrated_pfn)
>                           last_migrated_pfn = prev_migrate_pfn;
>           }
> 
>           ...
> 
>           check_drain: (at the end of loop)
>                 ...
> }

Good suggestion, also gets rid of the awkward subtraction of 1 in the
current patch. Thanks.
 
>> In short, "last_migrated_pfn" is not "last position of migrate
>> scanner" but "last block where we *actually* migrated".
> 
> Okay. Now I get it.
> Nevertheless, I'd like to change logic like above.
> 
> One problem of your approach is that it can't detect some cases.
> 
> Let's think about following case.
> '|' denotes aligned block boundary.
> '^' denotes migrate_pfn at certain time.
> 
> Assume that last_migrated_pfn = 0;
> 
> |--------------|-------------|--------------|
>    ^                ^
>   before isolate   after isolate
> 
> In this case, your code just records position of second '^' to
> last_migrated_pfn and skip to flush. But, flush is needed if we
> migrate some pages because we move away from previous aligned block.
> 
> Thanks.
> 

Right, so the patch below implements your suggestion, and the last_migrated_pfn
initialization fix. I named the variable "isolate_start_pfn" instead of
prev_migrate_pfn, as it's where the migrate scanner isolation starts, and having
both prev_migrate_pfn and last_migrated_pfn would be more confusing I think.

------8<------
From: Vlastimil Babka <vbabka@suse.cz>
Date: Mon, 3 Nov 2014 15:28:01 +0100
Subject: [PATCH] mm-compaction-more-focused-lru-and-pcplists-draining-fix

As Joonsoo Kim pointed out, last_migrate_pfn was reset to 0 by mistake at each
iteration in compact_zone(). This mistake could result in fail to recognize
immediately draining points for orders smaller than pageblock.
Joonsoo has also suggested an improvement to detecting cc->order aligned
block where migration might have occured - before this fix, some of the drain
opportunities might have been missed.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Michal Nazarewicz <mina86@mina86.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Christoph Lameter <cl@linux.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: David Rientjes <rientjes@google.com>
---
 mm/compaction.c | 24 +++++++++++++-----------
 1 file changed, 13 insertions(+), 11 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index fe43e60..100e6e8 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1144,6 +1144,7 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
 	unsigned long end_pfn = zone_end_pfn(zone);
 	const int migratetype = gfpflags_to_migratetype(cc->gfp_mask);
 	const bool sync = cc->mode != MIGRATE_ASYNC;
+	unsigned long last_migrated_pfn = 0;
 
 	ret = compaction_suitable(zone, cc->order, cc->alloc_flags,
 							cc->classzone_idx);
@@ -1189,7 +1190,7 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
 	while ((ret = compact_finished(zone, cc, migratetype)) ==
 						COMPACT_CONTINUE) {
 		int err;
-		unsigned long last_migrated_pfn = 0;
+		unsigned long isolate_start_pfn = cc->migrate_pfn;
 
 		switch (isolate_migratepages(zone, cc)) {
 		case ISOLATE_ABORT:
@@ -1230,21 +1231,22 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
 		}
 
 		/*
-		 * Record where we have freed pages by migration and not yet
-		 * flushed them to buddy allocator. Subtract 1, because often
-		 * we finish a pageblock and migrate_pfn points to the first
-		 * page* of the next one. In that case we want the drain below
-		 * to happen immediately.
+		 * Record where we could have freed pages by migration and not
+		 * yet flushed them to buddy allocator. We use the pfn that
+		 * isolate_migratepages() started from in this loop iteration
+		 * - this is the lowest page that could have been isolated and
+		 * then freed by migration.
 		 */
 		if (!last_migrated_pfn)
-			last_migrated_pfn = cc->migrate_pfn - 1;
+			last_migrated_pfn = isolate_start_pfn;
 
 check_drain:
 		/* 
-		 * Have we moved away from the previous cc->order aligned block
-		 * where we migrated from? If yes, flush the pages that were
-		 * freed, so that they can merge and compact_finished() can
-		 * detect immediately if allocation should succeed.
+		 * Has the migration scanner moved away from the previous
+		 * cc->order aligned block where we migrated from? If yes,
+		 * flush the pages that were freed, so that they can merge and
+		 * compact_finished() can detect immediately if allocation
+		 * would succeed.
 		 */
 		if (cc->order > 0 && last_migrated_pfn) {
 			int cpu;
-- 
2.1.2



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
