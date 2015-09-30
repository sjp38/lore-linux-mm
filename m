Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 2B1156B0038
	for <linux-mm@kvack.org>; Wed, 30 Sep 2015 04:37:27 -0400 (EDT)
Received: by padhy16 with SMTP id hy16so34022677pad.1
        for <linux-mm@kvack.org>; Wed, 30 Sep 2015 01:37:26 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id tl10si38040801pbc.253.2015.09.30.01.37.25
        for <linux-mm@kvack.org>;
        Wed, 30 Sep 2015 01:37:26 -0700 (PDT)
Date: Wed, 30 Sep 2015 17:38:49 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v2 8/9] mm/compaction: don't use higher order freepage
 than compaction aims at
Message-ID: <20150930083849.GD29589@js1304-P5Q-DELUXE>
References: <1440382773-16070-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1440382773-16070-9-git-send-email-iamjoonsoo.kim@lge.com>
 <560532FC.5000800@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <560532FC.5000800@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan@kernel.org>

On Fri, Sep 25, 2015 at 01:41:48PM +0200, Vlastimil Babka wrote:
> On 08/24/2015 04:19 AM, Joonsoo Kim wrote:
> > Purpose of compaction is to make high order page. To achive this purpose,
> > it is the best strategy that compaction migrates contiguous used pages
> > to fragmented unused freepages. Currently, freepage scanner don't
> > distinguish whether freepage is fragmented or not and blindly use
> > any freepage for migration target regardless of freepage's order.
> > 
> > Using higher order freepage than compaction aims at is not good because
> > what we do here is breaking high order freepage at somewhere and migrating
> > used pages from elsewhere to this broken high order freepages in order to
> > make new high order freepage. That is just position change of high order
> > freepage.
> > 
> > This is useless effort and doesn't help to make more high order freepages
> > because we can't be sure that migrating used pages makes high order
> > freepage. So, this patch makes freepage scanner only uses the ordered
> > freepage lower than compaction order.
> 
> How often does this happen? If there's a free page of the order we need, then we
> are done compacting anyway, no? Or is this happening because of the current
> high-order watermark checking implementation? It would be interesting to measure
> how often this skip would trigger. Also watermark checking should change with
> Mel's patchset and then this patch shouldn't be needed?

Yes, you are right. This would be happening because of the current
high-order watermakr checking implementation and Mel's patchset will
solve it and if it is merged, this patch isn't needed.

> 
> > Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> > ---
> >  mm/compaction.c | 15 +++++++++++++++
> >  1 file changed, 15 insertions(+)
> > 
> > diff --git a/mm/compaction.c b/mm/compaction.c
> > index ca4d6d1..e61ee77 100644
> > --- a/mm/compaction.c
> > +++ b/mm/compaction.c
> > @@ -455,6 +455,7 @@ static unsigned long isolate_freepages_block(struct compact_control *cc,
> >  	unsigned long flags = 0;
> >  	bool locked = false;
> >  	unsigned long blockpfn = *start_pfn;
> > +	unsigned long freepage_order;
> >  
> >  	cursor = pfn_to_page(blockpfn);
> >  
> > @@ -482,6 +483,20 @@ static unsigned long isolate_freepages_block(struct compact_control *cc,
> >  		if (!PageBuddy(page))
> >  			goto isolate_fail;
> >  
> > +		if (!strict && cc->order != -1) {
> > +			freepage_order = page_order_unsafe(page);
> > +
> > +			if (freepage_order > 0 && freepage_order < MAX_ORDER) {
> > +				/*
> > +				 * Do not use high order freepage for migration
> > +				 * taret. It would not be beneficial for
> > +				 * compaction success rate.
> > +				 */
> > +				if (freepage_order >= cc->order)
> 
> It would be better to skip the whole freepage_order.

Okay.

Thanks.

> 
> > +					goto isolate_fail;
> > +			}
> > +		}
> > +
> >  		/*
> >  		 * If we already hold the lock, we can skip some rechecking.
> >  		 * Note that if we hold the lock now, checked_pageblock was
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
