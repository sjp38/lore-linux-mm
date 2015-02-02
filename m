Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id D3CCA6B0038
	for <linux-mm@kvack.org>; Mon,  2 Feb 2015 02:09:32 -0500 (EST)
Received: by mail-pa0-f49.google.com with SMTP id fa1so78822420pad.8
        for <linux-mm@kvack.org>; Sun, 01 Feb 2015 23:09:32 -0800 (PST)
Received: from lgeamrelo02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id uv4si22512174pbc.110.2015.02.01.23.09.30
        for <linux-mm@kvack.org>;
        Sun, 01 Feb 2015 23:09:31 -0800 (PST)
Date: Mon, 2 Feb 2015 16:11:09 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v2 4/4] mm/compaction: enhance compaction finish condition
Message-ID: <20150202071109.GC6488@js1304-P5Q-DELUXE>
References: <1422621252-29859-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1422621252-29859-5-git-send-email-iamjoonsoo.kim@lge.com>
 <54CB988F.4080109@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <54CB988F.4080109@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Jan 30, 2015 at 03:43:27PM +0100, Vlastimil Babka wrote:
> On 01/30/2015 01:34 PM, Joonsoo Kim wrote:
> > From: Joonsoo <iamjoonsoo.kim@lge.com>
> > 
> > Compaction has anti fragmentation algorithm. It is that freepage
> > should be more than pageblock order to finish the compaction if we don't
> > find any freepage in requested migratetype buddy list. This is for
> > mitigating fragmentation, but, there is a lack of migratetype
> > consideration and it is too excessive compared to page allocator's anti
> > fragmentation algorithm.
> > 
> > Not considering migratetype would cause premature finish of compaction.
> > For example, if allocation request is for unmovable migratetype,
> > freepage with CMA migratetype doesn't help that allocation and
> > compaction should not be stopped. But, current logic regards this
> > situation as compaction is no longer needed, so finish the compaction.
> > 
> > Secondly, condition is too excessive compared to page allocator's logic.
> > We can steal freepage from other migratetype and change pageblock
> > migratetype on more relaxed conditions in page allocator. This is designed
> > to prevent fragmentation and we can use it here. Imposing hard constraint
> > only to the compaction doesn't help much in this case since page allocator
> > would cause fragmentation again.
> > 
> > To solve these problems, this patch borrows anti fragmentation logic from
> > page allocator. It will reduce premature compaction finish in some cases
> > and reduce excessive compaction work.
> > 
> > stress-highalloc test in mmtests with non movable order 7 allocation shows
> > considerable increase of compaction success rate.
> > 
> > Compaction success rate (Compaction success * 100 / Compaction stalls, %)
> > 31.82 : 42.20
> > 
> > Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> 
> I have some worries about longer-term fragmentation, some testing of
> stress-highalloc several times without restarts could be helpful.

Okay. I will do it.

> 
> > ---
> >  include/linux/mmzone.h |  3 +++
> >  mm/compaction.c        | 30 ++++++++++++++++++++++++++++--
> >  mm/internal.h          |  1 +
> >  mm/page_alloc.c        |  5 ++---
> >  4 files changed, 34 insertions(+), 5 deletions(-)
> > 
> > diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> > index f279d9c..a2906bc 100644
> > --- a/include/linux/mmzone.h
> > +++ b/include/linux/mmzone.h
> > @@ -63,6 +63,9 @@ enum {
> >  	MIGRATE_TYPES
> >  };
> >  
> > +#define FALLBACK_MIGRATETYPES (4)
> > +extern int fallbacks[MIGRATE_TYPES][FALLBACK_MIGRATETYPES];
> > +
> >  #ifdef CONFIG_CMA
> >  #  define is_migrate_cma(migratetype) unlikely((migratetype) == MIGRATE_CMA)
> >  #else
> > diff --git a/mm/compaction.c b/mm/compaction.c
> > index 782772d..0460e4b 100644
> > --- a/mm/compaction.c
> > +++ b/mm/compaction.c
> > @@ -1125,6 +1125,29 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
> >  	return cc->nr_migratepages ? ISOLATE_SUCCESS : ISOLATE_NONE;
> >  }
> >  
> > +static bool can_steal_fallbacks(struct free_area *area,
> > +			unsigned int order, int migratetype)
> 
> Could you move this to page_alloc.c and then you don't have to export the
> fallbacks arrays?

Okay.

> 
> > +{
> > +	int i;
> > +	int fallback_mt;
> > +
> > +	if (area->nr_free == 0)
> > +		return false;
> > +
> > +	for (i = 0; i < FALLBACK_MIGRATETYPES; i++) {
> > +		fallback_mt = fallbacks[migratetype][i];
> > +		if (fallback_mt == MIGRATE_RESERVE)
> > +			break;
> > +
> > +		if (list_empty(&area->free_list[fallback_mt]))
> > +			continue;
> > +
> > +		if (can_steal_freepages(order, migratetype, fallback_mt))
> > +			return true;
> > +	}
> > +	return false;
> > +}
> > +
> >  static int __compact_finished(struct zone *zone, struct compact_control *cc,
> >  			    const int migratetype)
> >  {
> > @@ -1175,8 +1198,11 @@ static int __compact_finished(struct zone *zone, struct compact_control *cc,
> >  		if (!list_empty(&area->free_list[migratetype]))
> >  			return COMPACT_PARTIAL;
> >  
> > -		/* Job done if allocation would set block type */
> > -		if (order >= pageblock_order && area->nr_free)
> > +		/*
> > +		 * Job done if allocation would steal freepages from
> > +		 * other migratetype buddy lists.
> > +		 */
> > +		if (can_steal_fallbacks(area, order, migratetype))
> >  			return COMPACT_PARTIAL;
> 
> Seems somewhat wasteful in scenario where we want to satisfy a movable
> allocation and it's an async compaction. Then we don't compact in
> unmovable/reclaimable pageblock, and yet we will keep checking them for
> fallbacks. A price to pay for having generic code?

I think that there would be lucky case that high order freepage on
unmovable/reclaimable pageblock is made by concurrent freeing.
In this case, finishing compaction would be good thing. And, this logic
would cause marginal overhead so generic code seems justificable to me.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
