Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f179.google.com (mail-io0-f179.google.com [209.85.223.179])
	by kanga.kvack.org (Postfix) with ESMTP id ECA5B6B0257
	for <linux-mm@kvack.org>; Mon,  7 Dec 2015 03:02:00 -0500 (EST)
Received: by ioir85 with SMTP id r85so173287678ioi.1
        for <linux-mm@kvack.org>; Mon, 07 Dec 2015 00:02:00 -0800 (PST)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTPS id x62si30591267ioi.119.2015.12.07.00.01.59
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 07 Dec 2015 00:02:00 -0800 (PST)
Date: Mon, 7 Dec 2015 17:03:07 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v3 4/7] mm/compaction: update defer counter when
 allocation is expected to succeed
Message-ID: <20151207080307.GC27292@js1304-P5Q-DELUXE>
References: <1449126681-19647-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1449126681-19647-5-git-send-email-iamjoonsoo.kim@lge.com>
 <5661C4C5.2020901@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5661C4C5.2020901@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, Dec 04, 2015 at 05:52:21PM +0100, Vlastimil Babka wrote:
> On 12/03/2015 08:11 AM, Joonsoo Kim wrote:
> >It's rather strange that compact_considered and compact_defer_shift aren't
> >updated but compact_order_failed is updated when allocation is expected
> >to succeed. Regardless actual allocation success, deferring for current
> >order will be disabled so it doesn't result in much difference to
> >compaction behaviour.
> 
> The difference is that if the defer reset was wrong, the next
> compaction attempt that fails would resume the deferred counters?

Right. But, perhaps, if we wrongly reset order_failed due to difference
of check criteria, it could happen again and again on next compaction
attempt so defer would not work as intended.

> 
> >Moreover, in the past, there is a gap between expectation for allocation
> >succeess in compaction and actual success in page allocator. But, now,
> >this gap would be diminished due to providing classzone_idx and alloc_flags
> >to watermark check in compaction and changed watermark check criteria
> >for high-order allocation. Therfore, it's not a big problem to update
> >defer counter when allocation is expected to succeed. This change
> >will help to simplify defer logic.
> 
> I guess that's true. But at least some experiment would be better.

Yeah, I tested it today and found that there is a difference.
Allocation is more successful(really minor, 0.25%) than checking
in compaction. Reason is that watermark check in try_to_compact_pages()
uses low_wmark_pages but get_page_from_freelist() after direct compaction
uses min_wmark_pages. When I change low_wmark_pages to min_wmark_pages,
I can't find any difference. It seems reasonable to change
low_wmark_pages to min_wmark_pages in some places where checking
compaction finish condition.

I will add the patch on next spin.

> 
> >Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> >---
> >  include/linux/compaction.h |  2 --
> >  mm/compaction.c            | 27 ++++++++-------------------
> >  mm/page_alloc.c            |  1 -
> >  3 files changed, 8 insertions(+), 22 deletions(-)
> >
> 
> ...
> 
> >diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> >index 7002c66..f3605fd 100644
> >--- a/mm/page_alloc.c
> >+++ b/mm/page_alloc.c
> >@@ -2815,7 +2815,6 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
> >  		struct zone *zone = page_zone(page);
> >
> >  		zone->compact_blockskip_flush = false;
> 
> While we are here, I wonder if this is useful at all?

I think it's useful. We still have some cases that premature
compaction complete happens (e.g. async compaction). In this case,
if next sync compaction succeed, compact_blockskip_flush is cleared
and pageblock skip bit will not be reset so overhead would be reduced.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
