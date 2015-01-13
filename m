Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id D761A6B0032
	for <linux-mm@kvack.org>; Tue, 13 Jan 2015 02:18:13 -0500 (EST)
Received: by mail-pd0-f172.google.com with SMTP id y13so1886179pdi.3
        for <linux-mm@kvack.org>; Mon, 12 Jan 2015 23:18:13 -0800 (PST)
Received: from lgeamrelo04.lge.com (lgeamrelo04.lge.com. [156.147.1.127])
        by mx.google.com with ESMTP id kp11si26143006pab.94.2015.01.12.23.18.11
        for <linux-mm@kvack.org>;
        Mon, 12 Jan 2015 23:18:12 -0800 (PST)
Date: Tue, 13 Jan 2015 16:18:39 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v2 5/5] mm/compaction: add tracepoint to observe
 behaviour of compaction defer
Message-ID: <20150113071839.GB29898@js1304-P5Q-DELUXE>
References: <1421050875-26332-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1421050875-26332-5-git-send-email-iamjoonsoo.kim@lge.com>
 <54B3F7E3.4000803@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <54B3F7E3.4000803@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Jan 12, 2015 at 05:35:47PM +0100, Vlastimil Babka wrote:
> On 01/12/2015 09:21 AM, Joonsoo Kim wrote:
> > compaction deferring logic is heavy hammer that block the way to
> > the compaction. It doesn't consider overall system state, so it
> > could prevent user from doing compaction falsely. In other words,
> > even if system has enough range of memory to compact, compaction would be
> > skipped due to compaction deferring logic. This patch add new tracepoint
> > to understand work of deferring logic. This will also help to check
> > compaction success and fail.
> > 
> > Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> > ---
> >  include/linux/compaction.h        |   65 +++------------------------------
> >  include/trace/events/compaction.h |   55 ++++++++++++++++++++++++++++
> >  mm/compaction.c                   |   72 +++++++++++++++++++++++++++++++++++++
> >  3 files changed, 132 insertions(+), 60 deletions(-)
> > 
> > diff --git a/include/linux/compaction.h b/include/linux/compaction.h
> > index d82181a..026ff64 100644
> > --- a/include/linux/compaction.h
> > +++ b/include/linux/compaction.h
> > @@ -44,66 +44,11 @@ extern void reset_isolation_suitable(pg_data_t *pgdat);
> >  extern unsigned long compaction_suitable(struct zone *zone, int order,
> >  					int alloc_flags, int classzone_idx);
> >  
> > -/* Do not skip compaction more than 64 times */
> > -#define COMPACT_MAX_DEFER_SHIFT 6
> > -
> > -/*
> > - * Compaction is deferred when compaction fails to result in a page
> > - * allocation success. 1 << compact_defer_limit compactions are skipped up
> > - * to a limit of 1 << COMPACT_MAX_DEFER_SHIFT
> > - */
> > -static inline void defer_compaction(struct zone *zone, int order)
> > -{
> > -	zone->compact_considered = 0;
> > -	zone->compact_defer_shift++;
> > -
> > -	if (order < zone->compact_order_failed)
> > -		zone->compact_order_failed = order;
> > -
> > -	if (zone->compact_defer_shift > COMPACT_MAX_DEFER_SHIFT)
> > -		zone->compact_defer_shift = COMPACT_MAX_DEFER_SHIFT;
> > -}
> > -
> > -/* Returns true if compaction should be skipped this time */
> > -static inline bool compaction_deferred(struct zone *zone, int order)
> > -{
> > -	unsigned long defer_limit = 1UL << zone->compact_defer_shift;
> > -
> > -	if (order < zone->compact_order_failed)
> > -		return false;
> > -
> > -	/* Avoid possible overflow */
> > -	if (++zone->compact_considered > defer_limit)
> > -		zone->compact_considered = defer_limit;
> > -
> > -	return zone->compact_considered < defer_limit;
> > -}
> > -
> > -/*
> > - * Update defer tracking counters after successful compaction of given order,
> > - * which means an allocation either succeeded (alloc_success == true) or is
> > - * expected to succeed.
> > - */
> > -static inline void compaction_defer_reset(struct zone *zone, int order,
> > -		bool alloc_success)
> > -{
> > -	if (alloc_success) {
> > -		zone->compact_considered = 0;
> > -		zone->compact_defer_shift = 0;
> > -	}
> > -	if (order >= zone->compact_order_failed)
> > -		zone->compact_order_failed = order + 1;
> > -}
> > -
> > -/* Returns true if restarting compaction after many failures */
> > -static inline bool compaction_restarting(struct zone *zone, int order)
> > -{
> > -	if (order < zone->compact_order_failed)
> > -		return false;
> > -
> > -	return zone->compact_defer_shift == COMPACT_MAX_DEFER_SHIFT &&
> > -		zone->compact_considered >= 1UL << zone->compact_defer_shift;
> > -}
> > +extern void defer_compaction(struct zone *zone, int order);
> > +extern bool compaction_deferred(struct zone *zone, int order);
> > +extern void compaction_defer_reset(struct zone *zone, int order,
> > +				bool alloc_success);
> > +extern bool compaction_restarting(struct zone *zone, int order);
> >  
> >  #else
> >  static inline unsigned long try_to_compact_pages(struct zonelist *zonelist,
> > diff --git a/include/trace/events/compaction.h b/include/trace/events/compaction.h
> > index 839dd4f..f879f41 100644
> > --- a/include/trace/events/compaction.h
> > +++ b/include/trace/events/compaction.h
> > @@ -258,6 +258,61 @@ DEFINE_EVENT(mm_compaction_suitable_template, mm_compaction_suitable,
> >  	TP_ARGS(zone, order, alloc_flags, classzone_idx, ret)
> >  );
> >  
> > +DECLARE_EVENT_CLASS(mm_compaction_defer_template,
> > +
> > +	TP_PROTO(struct zone *zone, int order),
> > +
> > +	TP_ARGS(zone, order),
> > +
> > +	TP_STRUCT__entry(
> > +		__field(int, nid)
> > +		__field(char *, name)
> > +		__field(int, order)
> > +		__field(unsigned int, considered)
> > +		__field(unsigned int, defer_shift)
> > +		__field(int, order_failed)
> > +	),
> > +
> > +	TP_fast_assign(
> > +		__entry->nid = zone_to_nid(zone);
> > +		__entry->name = (char *)zone->name;
> > +		__entry->order = order;
> > +		__entry->considered = zone->compact_considered;
> > +		__entry->defer_shift = zone->compact_defer_shift;
> > +		__entry->order_failed = zone->compact_order_failed;
> > +	),
> > +
> > +	TP_printk("node=%d zone=%-8s order=%d order_failed=%d reason=%s consider=%u limit=%lu",
> > +		__entry->nid,
> > +		__entry->name,
> > +		__entry->order,
> > +		__entry->order_failed,
> > +		__entry->order < __entry->order_failed ? "order" : "try",
> 
> This "reason" only makes sense for compaction_deferred, no? And "order" would
> never be printed there anyway, because of bug below. Also it's quite trivial to
> derive from the other data printed, so I would just remove it.

Will remove.

> 
> > +		__entry->considered,
> > +		1UL << __entry->defer_shift)
> > +);
> > +
> > +DEFINE_EVENT(mm_compaction_defer_template, mm_compaction_deffered,
> 
>                                                             _deferred

Okay.

> > +
> > +	TP_PROTO(struct zone *zone, int order),
> > +
> > +	TP_ARGS(zone, order)
> > +);
> > +
> > +DEFINE_EVENT(mm_compaction_defer_template, mm_compaction_defer_compaction,
> > +
> > +	TP_PROTO(struct zone *zone, int order),
> > +
> > +	TP_ARGS(zone, order)
> > +);
> > +
> > +DEFINE_EVENT(mm_compaction_defer_template, mm_compaction_defer_reset,
> > +
> > +	TP_PROTO(struct zone *zone, int order),
> > +
> > +	TP_ARGS(zone, order)
> > +);
> > +
> >  #endif /* _TRACE_COMPACTION_H */
> >  
> >  /* This part must be outside protection */
> > diff --git a/mm/compaction.c b/mm/compaction.c
> > index 7500f01..7aa4249 100644
> > --- a/mm/compaction.c
> > +++ b/mm/compaction.c
> > @@ -123,6 +123,77 @@ static struct page *pageblock_pfn_to_page(unsigned long start_pfn,
> >  }
> >  
> >  #ifdef CONFIG_COMPACTION
> > +
> > +/* Do not skip compaction more than 64 times */
> > +#define COMPACT_MAX_DEFER_SHIFT 6
> > +
> > +/*
> > + * Compaction is deferred when compaction fails to result in a page
> > + * allocation success. 1 << compact_defer_limit compactions are skipped up
> > + * to a limit of 1 << COMPACT_MAX_DEFER_SHIFT
> > + */
> > +void defer_compaction(struct zone *zone, int order)
> > +{
> > +	zone->compact_considered = 0;
> > +	zone->compact_defer_shift++;
> > +
> > +	if (order < zone->compact_order_failed)
> > +		zone->compact_order_failed = order;
> > +
> > +	if (zone->compact_defer_shift > COMPACT_MAX_DEFER_SHIFT)
> > +		zone->compact_defer_shift = COMPACT_MAX_DEFER_SHIFT;
> > +
> > +	trace_mm_compaction_defer_compaction(zone, order);
> > +}
> > +
> > +/* Returns true if compaction should be skipped this time */
> > +bool compaction_deferred(struct zone *zone, int order)
> > +{
> > +	unsigned long defer_limit = 1UL << zone->compact_defer_shift;
> > +
> > +	if (order < zone->compact_order_failed)
> 
> - no tracepoint (with reason="order") in this case?
> 
> > +		return false;
> > +
> > +	/* Avoid possible overflow */
> > +	if (++zone->compact_considered > defer_limit)
> > +		zone->compact_considered = defer_limit;
> > +
> > +	if (zone->compact_considered >= defer_limit)
> 
> - no tracepoint here as well? Oh did you want to trace just when it's true? That
> makes sense, but then just remove the reason part.

Yes, it's my intention to print trace when true.

> Hm what if we avoided dirtying the cache line in the non-deferred case? Would be
> simpler, too?
> 
> if (zone->compact_considered + 1 >= defer_limit)
>      return false;
> 
> zone->compact_considered++;
> 
> trace_mm_compaction_defer_compaction(zone, order);
> 
> return true;

Okay. I will include this minor optimization in next version of this
patch.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
