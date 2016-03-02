Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 4B373828E1
	for <linux-mm@kvack.org>; Wed,  2 Mar 2016 07:25:41 -0500 (EST)
Received: by mail-wm0-f42.google.com with SMTP id l68so77713003wml.0
        for <linux-mm@kvack.org>; Wed, 02 Mar 2016 04:25:41 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z5si4598663wmg.38.2016.03.02.04.25.39
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 02 Mar 2016 04:25:40 -0800 (PST)
Subject: Re: [PATCH v2 2/5] mm, compaction: introduce kcompactd
References: <1454938691-2197-1-git-send-email-vbabka@suse.cz>
 <1454938691-2197-3-git-send-email-vbabka@suse.cz>
 <20160302060906.GA32695@js1304-P5Q-DELUXE>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <56D6DBC1.2030701@suse.cz>
Date: Wed, 2 Mar 2016 13:25:37 +0100
MIME-Version: 1.0
In-Reply-To: <20160302060906.GA32695@js1304-P5Q-DELUXE>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, David Rientjes <rientjes@google.com>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>

>> +		if (zone_watermark_ok(zone, cc.order, low_wmark_pages(zone),
>> +						cc.classzone_idx, 0)) {
>> +			success = true;
>> +			compaction_defer_reset(zone, cc.order, false);
>> +		} else if (cc.mode != MIGRATE_ASYNC &&
>> +						status == COMPACT_COMPLETE) {
>> +			defer_compaction(zone, cc.order);
>> +		}
> 
> We alerady set mode to MIGRATE_SYNC_LIGHT so this cc.mode check looks weird.
> It would be better to change it and add some comment that we can
> safely call defer_compaction() here.

Right.
 
>> +
>> +		VM_BUG_ON(!list_empty(&cc.freepages));
>> +		VM_BUG_ON(!list_empty(&cc.migratepages));
>> +	}
>> +
>> +	/*
>> +	 * Regardless of success, we are done until woken up next. But remember
>> +	 * the requested order/classzone_idx in case it was higher/tighter than
>> +	 * our current ones
>> +	 */
>> +	if (pgdat->kcompactd_max_order <= cc.order)
>> +		pgdat->kcompactd_max_order = 0;
>> +	if (pgdat->classzone_idx >= cc.classzone_idx)
>> +		pgdat->classzone_idx = pgdat->nr_zones - 1;
>> +}
> 
> Maybe, you intend to update kcompactd_classzone_idx.

Oops, true. Thanks for the review!

Here's a fixlet.

----8<----
From: Vlastimil Babka <vbabka@suse.cz>
Date: Wed, 2 Mar 2016 10:15:22 +0100
Subject: mm-compaction-introduce-kcompactd-fix-3

Remove extraneous check for sync compaction before deferring.
Correctly adjust kcompactd's classzone_idx instead of kswapd's.

Reported-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/compaction.c | 11 +++++++----
 1 file changed, 7 insertions(+), 4 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index c03715ba65c7..9a605c3d4177 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1811,8 +1811,11 @@ static void kcompactd_do_work(pg_data_t *pgdat)
 						cc.classzone_idx, 0)) {
 			success = true;
 			compaction_defer_reset(zone, cc.order, false);
-		} else if (cc.mode != MIGRATE_ASYNC &&
-						status == COMPACT_COMPLETE) {
+		} else if (status == COMPACT_COMPLETE) {
+			/*
+			 * We use sync migration mode here, so we defer like
+			 * sync direct compaction does.
+			 */
 			defer_compaction(zone, cc.order);
 		}
 
@@ -1827,8 +1830,8 @@ static void kcompactd_do_work(pg_data_t *pgdat)
 	 */
 	if (pgdat->kcompactd_max_order <= cc.order)
 		pgdat->kcompactd_max_order = 0;
-	if (pgdat->classzone_idx >= cc.classzone_idx)
-		pgdat->classzone_idx = pgdat->nr_zones - 1;
+	if (pgdat->kcompactd_classzone_idx >= cc.classzone_idx)
+		pgdat->kcompactd_classzone_idx = pgdat->nr_zones - 1;
 }
 
 void wakeup_kcompactd(pg_data_t *pgdat, int order, int classzone_idx)
-- 
2.7.2


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
