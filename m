Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f176.google.com (mail-ig0-f176.google.com [209.85.213.176])
	by kanga.kvack.org (Postfix) with ESMTP id D1BF86B0258
	for <linux-mm@kvack.org>; Mon,  7 Dec 2015 03:02:59 -0500 (EST)
Received: by igcmv3 with SMTP id mv3so73608788igc.0
        for <linux-mm@kvack.org>; Mon, 07 Dec 2015 00:02:59 -0800 (PST)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTPS id 136si7874503ioz.123.2015.12.07.00.02.58
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 07 Dec 2015 00:02:59 -0800 (PST)
Date: Mon, 7 Dec 2015 17:04:07 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v3 5/7] mm/compaction: respect compaction order when
 updating defer counter
Message-ID: <20151207080407.GD27292@js1304-P5Q-DELUXE>
References: <1449126681-19647-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1449126681-19647-6-git-send-email-iamjoonsoo.kim@lge.com>
 <5661CA16.9010304@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5661CA16.9010304@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, Dec 04, 2015 at 06:15:02PM +0100, Vlastimil Babka wrote:
> On 12/03/2015 08:11 AM, Joonsoo Kim wrote:
> >It doesn't make sense that we reset defer counter
> >in compaction_defer_reset() when compaction request under the order of
> >compact_order_failed succeed. Fix it.
> 
> Right.
> 
> >And, it does make sense that giving enough chance for updated failed
> >order compaction before deferring. Change it.
> 
> Sorry, can't understand the meaning here. From the code it seems
> that you want to reset defer_shift to 0 instead of increasing it,
> when the current order is lower than the failed one? That makes
> sense, yeah.

You correctly understand my intention. :)

> How about this?
> 
> "On the other hand, when deferring compaction for an order lower
> than the current compact_order_failed, we can assume the lower order
> will recover more quickly, so we should reset the progress made
> previously on compact_defer_shift with the higher order."

Will add it.

> 
> >Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> 
> Acked-by: Vlastimil Babka <vbabka@suse.cz>

Thanks.
> 
> >---
> >  mm/compaction.c | 19 +++++++++++--------
> >  1 file changed, 11 insertions(+), 8 deletions(-)
> >
> >diff --git a/mm/compaction.c b/mm/compaction.c
> >index 67b8d90..1a75a6e 100644
> >--- a/mm/compaction.c
> >+++ b/mm/compaction.c
> >@@ -126,11 +126,14 @@ static struct page *pageblock_pfn_to_page(unsigned long start_pfn,
> >   */
> >  static void defer_compaction(struct zone *zone, int order)
> >  {
> >-	zone->compact_considered = 0;
> >-	zone->compact_defer_shift++;
> >-
> >-	if (order < zone->compact_order_failed)
> >+	if (order < zone->compact_order_failed) {
> >+		zone->compact_considered = 0;
> >+		zone->compact_defer_shift = 0;
> >  		zone->compact_order_failed = order;
> >+	} else {
> >+		zone->compact_considered = 0;
> >+		zone->compact_defer_shift++;
> >+	}
> >
> >  	if (zone->compact_defer_shift > COMPACT_MAX_DEFER_SHIFT)
> >  		zone->compact_defer_shift = COMPACT_MAX_DEFER_SHIFT;
> >@@ -161,11 +164,11 @@ bool compaction_deferred(struct zone *zone, int order)
> >  /* Update defer tracking counters after successful compaction of given order */
> >  static void compaction_defer_reset(struct zone *zone, int order)
> >  {
> >-	zone->compact_considered = 0;
> >-	zone->compact_defer_shift = 0;
> >-
> >-	if (order >= zone->compact_order_failed)
> >+	if (order >= zone->compact_order_failed) {
> >+		zone->compact_considered = 0;
> >+		zone->compact_defer_shift = 0;
> >  		zone->compact_order_failed = order + 1;
> >+	}
> >
> >  	trace_mm_compaction_defer_reset(zone, order);
> >  }
> >
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
