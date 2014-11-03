Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 6AB0E6B010C
	for <linux-mm@kvack.org>; Mon,  3 Nov 2014 03:21:30 -0500 (EST)
Received: by mail-pa0-f52.google.com with SMTP id fa1so11738058pad.11
        for <linux-mm@kvack.org>; Mon, 03 Nov 2014 00:21:30 -0800 (PST)
Received: from lgeamrelo04.lge.com (lgeamrelo04.lge.com. [156.147.1.127])
        by mx.google.com with ESMTP id lm4si14726652pab.217.2014.11.03.00.21.27
        for <linux-mm@kvack.org>;
        Mon, 03 Nov 2014 00:21:29 -0800 (PST)
Date: Mon, 3 Nov 2014 17:23:02 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH for v3.18] mm/compaction: skip the range until proper
 target pageblock is met
Message-ID: <20141103082302.GD7052@js1304-P5Q-DELUXE>
References: <1414740235-3975-1-git-send-email-iamjoonsoo.kim@lge.com>
 <545375B2.6050800@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <545375B2.6050800@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Minchan Kim <minchan@kernel.org>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

On Fri, Oct 31, 2014 at 12:42:42PM +0100, Vlastimil Babka wrote:
> On 10/31/2014 08:23 AM, Joonsoo Kim wrote:
> >commit 7d49d8868336 ("mm, compaction: reduce zone checking frequency in
> >the migration scanner") makes side-effect that change iteration
> >range calculation. Before change, block_end_pfn is calculated using
> >start_pfn, but, now, blindly add pageblock_nr_pages to previous value.
> >
> >This cause the problem that isolation_start_pfn is larger than
> >block_end_pfn when we isolation the page with more than pageblock order.
> >In this case, isolation would be failed due to invalid range parameter.
> >
> >To prevent this, this patch implement skipping the range until proper
> >target pageblock is met. Without this patch, CMA with more than pageblock
> >order always fail, but, with this patch, it will succeed.
> 
> Well, that's a shame, a third fix you send for my series... And only
> the first was caught before going mainline. I guess -rcX phase is
> intended for this, but how could we do better to catch this in
> -next?
> Anyway, thanks!

Yeah, I'd like to catch these in -next. :)
It'd be better to have CMA test cases in kernel tree or mmtest.
I have some CMA test program, but, it is really ad-hoc so I can't
submit it. If time allows, I update it and try to submit it.

> 
> >Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> >---
> >  mm/compaction.c |    6 ++++--
> >  1 file changed, 4 insertions(+), 2 deletions(-)
> >
> >diff --git a/mm/compaction.c b/mm/compaction.c
> >index ec74cf0..212682a 100644
> >--- a/mm/compaction.c
> >+++ b/mm/compaction.c
> >@@ -472,18 +472,20 @@ isolate_freepages_range(struct compact_control *cc,
> >  	pfn = start_pfn;
> >  	block_end_pfn = ALIGN(pfn + 1, pageblock_nr_pages);
> >
> >-	for (; pfn < end_pfn; pfn += isolated,
> >-				block_end_pfn += pageblock_nr_pages) {
> >+	for (; pfn < end_pfn; block_end_pfn += pageblock_nr_pages) {
> >  		/* Protect pfn from changing by isolate_freepages_block */
> >  		unsigned long isolate_start_pfn = pfn;
> >
> >  		block_end_pfn = min(block_end_pfn, end_pfn);
> >+		if (pfn >= block_end_pfn)
> >+			continue;
> 
> Without any comment, this will surely confuse anyone reading the code.
> Also I wonder if just recalculating block_end_pfn wouldn't be
> cheaper cpu-wise (not that it matters much?) and easier to
> understand than conditionals. IIRC backward jumps (i.e. continue)
> are by default predicted as "likely" if there's no history in the
> branch predictor cache, but this rather unlikely?

I also think that comment is needed and conditional would be better
than above. I will rework it.

> >  		if (!pageblock_pfn_to_page(pfn, block_end_pfn, cc->zone))
> >  			break;
> >
> >  		isolated = isolate_freepages_block(cc, &isolate_start_pfn,
> >  						block_end_pfn, &freelist, true);
> >+		pfn += isolated;
> 
> Moving the "pfn += isolated" here doesn't change anything, or does
> it? Do you just find it nicer?

When skipping, we should not do 'pfn += isolated'. There are two
choice achiving it. 1) reset isolated to 0. 2) above change.
I just selected 2) one. Maybe next version uses 1) approach.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
