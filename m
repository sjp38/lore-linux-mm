Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id B49186B0032
	for <linux-mm@kvack.org>; Thu,  4 Dec 2014 01:58:11 -0500 (EST)
Received: by mail-pa0-f51.google.com with SMTP id ey11so17280643pad.24
        for <linux-mm@kvack.org>; Wed, 03 Dec 2014 22:58:11 -0800 (PST)
Received: from lgeamrelo01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id gn9si41693549pac.127.2014.12.03.22.49.50
        for <linux-mm@kvack.org>;
        Wed, 03 Dec 2014 22:49:51 -0800 (PST)
Date: Thu, 4 Dec 2014 15:53:17 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: isolate_freepages_block and excessive CPU usage by OSD process
Message-ID: <20141204065317.GA12141@js1304-P5Q-DELUXE>
References: <20141123093348.GA16954@cucumber.anchor.net.au>
 <CABYiri8LYukujETMCb4gHUQd=J-MQ8m=rGRiEkTD1B42Jh=Ksg@mail.gmail.com>
 <20141128080331.GD11802@js1304-P5Q-DELUXE>
 <54783FB7.4030502@suse.cz>
 <20141201083118.GB2499@js1304-P5Q-DELUXE>
 <20141202014724.GA22239@cucumber.bridge.anchor.net.au>
 <20141202045324.GC6268@js1304-P5Q-DELUXE>
 <547DDED9.6080105@suse.cz>
 <20141203074957.GA6276@js1304-P5Q-DELUXE>
 <547F0573.90302@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <547F0573.90302@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org

On Wed, Dec 03, 2014 at 01:43:31PM +0100, Vlastimil Babka wrote:
> On 12/03/2014 08:49 AM, Joonsoo Kim wrote:
> > On Tue, Dec 02, 2014 at 04:46:33PM +0100, Vlastimil Babka wrote:
> >> 
> >> Indeed, although I somehow doubt your first patch could have made
> >> such difference. It only matters when you have a whole pageblock
> >> free. Without the patch, the particular compaction attempt that
> >> managed to free the block might not be terminated ASAP, but then the
> >> free pageblock is still allocatable by the following allocation
> >> attempts, so it shouldn't result in a stream of complete
> >> compactions.
> > 
> > High-order freepage made by compaction could be broken by other
> > order-0 allocation attempts, so following high-order allocation attempts
> > could result in new compaction. It would be dependent on workload.
> > 
> > Anyway, we should fix cc->order to order. :)
> 
> Sure, no doubts about it.

Okay.

> 
> >> 
> >> So I would expect it's either a fluke, or the second patch made the
> >> difference, to either SLUB or something else making such
> >> fallback-able allocations.
> >> 
> >> But hmm, I've never considered the implications of
> >> compact_finished() migratetypes handling on unmovable allocations.
> >> Regardless of cc->order, it often has to free a whole pageblock to
> >> succeed, as it's unlikely it will succeed compacting within a
> >> pageblock already marked as UNMOVABLE. Guess it's to prevent further
> >> fragmentation and that makes sense, but it does make high-order
> >> unmovable allocations problematic. At least the watermark checks for
> >> allowing compaction in the first place are then wrong - we decide
> >> that based on cc->order, but in we fact need at least a pageblock
> >> worth of space free to actually succeed.
> > 
> > I think that watermark check is okay but we need a elegant way to decide
> > the best timing compaction should be stopped. I made following two patches
> > about this. This patch would make non-movable compaction less
> > aggressive. This is just draft so ignore my poor description. :)
> > 
> > Could you comment it?
> > 
> > --------->8-----------------
> > From bd6b285c38fd94e5ec03a720bed4debae3914bde Mon Sep 17 00:00:00 2001
> > From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> > Date: Mon, 1 Dec 2014 11:56:57 +0900
> > Subject: [PATCH 1/2] mm/page_alloc: expands broken freepage to proper buddy
> >  list when steal
> > 
> > There is odd behaviour when we steal freepages from other migratetype
> > buddy list. In try_to_steal_freepages(), we move all freepages in
> > the pageblock that founded freepage is belong to to the request
> > migratetype in order to mitigate fragmentation. If the number of moved
> > pages are enough to change pageblock migratetype, there is no problem. If
> > not enough, we don't change pageblock migratetype and add broken freepages
> > to the original migratetype buddy list rather than request migratetype
> > one. For me, this is odd, because we already moved all freepages in this
> > pageblock to the request migratetype. This patch fixes this situation to
> > add broken freepages to the request migratetype buddy list in this case.
> >
> 
> Yeah, I have noticed this a while ago, and traced the history of how this
> happened. But surprisingly just changing this back didn't evaluate as a clear
> win, so I have added some further tunning. I will try to send this ASAP.

I'd like to see it.

Anyway, if there is no remarkable degradation you found, merging this patch
is better than as is. This is odd logic and we don't understand how it works
and whether it is better or not. So making logic understandable deserves
to consider.

> 
> > This patch introduce new function that can help to decide if we can
> > steal the page without resulting in fragmentation. It will be used in
> > following patch for compaction finish criteria.
> > 
> > Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> > ---
> > +static bool can_steal_freepages(unsigned int order,
> > +			int start_mt, int fallback_mt)
> > +{
> > +	/*
> > +	 * When borrowing from MIGRATE_CMA, we need to release the excess
> > +	 * buddy pages to CMA itself. We also ensure the freepage_migratetype
> > +	 * is set to CMA so it is returned to the correct freelist in case
> > +	 * the page ends up being not actually allocated from the pcp lists.
> > +	 */
> > +	if (is_migrate_cma(fallback_mt))
> > +		return false;
> >  
> > -	}
> > +	/* Can take ownership for orders >= pageblock_order */
> > +	if (order >= pageblock_order)
> > +		return true;
> > +
> > +	if (order >= pageblock_order / 2 ||
> > +		start_mt == MIGRATE_RECLAIMABLE ||
> > +		page_group_by_mobility_disabled)
> > +		return true;
> >  
> > -	return fallback_type;
> > +	return false;
> 
> Note that this is not exactly consistent for compaction and allocation.

Yes, I know. So I asked to ignore my poor description. :)
Sorry about that.

> Allocation will succeed as long as a large enough fallback page exist - it might
> not just steal extra free pages if the fallback page order is low (or it's not
> for MIGRATE_RECLAIMABLE allocation). But for compaction, with your patches you
> still evaluate whether it can steal also the extra pages, so it's more strict
> condition. It might make sense, but let's not claim it's fully consistent? And
> it definitely needs evaluation...

IMO, it's more strict, but, make more sense than current one. Do you agree?
Anyway, I need evaulation. My quick attempt results in good result. I will share
it after more testing.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
