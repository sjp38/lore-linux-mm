Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id BD9136B006E
	for <linux-mm@kvack.org>; Thu,  8 Jan 2015 03:21:08 -0500 (EST)
Received: by mail-pa0-f42.google.com with SMTP id et14so10387082pad.1
        for <linux-mm@kvack.org>; Thu, 08 Jan 2015 00:21:08 -0800 (PST)
Received: from lgeamrelo01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id sh4si7429214pbc.3.2015.01.08.00.21.05
        for <linux-mm@kvack.org>;
        Thu, 08 Jan 2015 00:21:07 -0800 (PST)
Date: Thu, 8 Jan 2015 17:21:14 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 2/3] mm/compaction: add more trace to understand
 compaction start/finish condition
Message-ID: <20150108082114.GD25453@js1304-P5Q-DELUXE>
References: <1417593127-6819-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1417593127-6819-2-git-send-email-iamjoonsoo.kim@lge.com>
 <54ABC13C.4030403@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <54ABC13C.4030403@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Jan 06, 2015 at 12:04:28PM +0100, Vlastimil Babka wrote:
> On 12/03/2014 08:52 AM, Joonsoo Kim wrote:
> > It is not well analyzed that when compaction start and when compaction
> > finish. With this tracepoint for compaction start/finish condition, I can
> > find following bug.
> > 
> > http://www.spinics.net/lists/linux-mm/msg81582.html
> > 
> > Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> > ---
> >  include/linux/compaction.h        |    2 +
> >  include/trace/events/compaction.h |   91 +++++++++++++++++++++++++++++++++++++
> >  mm/compaction.c                   |   40 ++++++++++++++--
> >  3 files changed, 129 insertions(+), 4 deletions(-)
> > 
> > diff --git a/include/linux/compaction.h b/include/linux/compaction.h
> > index a9547b6..bdb4b99 100644
> > --- a/include/linux/compaction.h
> > +++ b/include/linux/compaction.h
> > @@ -12,6 +12,8 @@
> >  #define COMPACT_PARTIAL		3
> >  /* The full zone was compacted */
> >  #define COMPACT_COMPLETE	4
> > +/* For more detailed tracepoint output, will be converted to COMPACT_CONTINUE */
> > +#define COMPACT_NOT_SUITABLE	5
> 
> So this makes it sound like the value means "compaction was not suitable to do
> in this zone", but later it means something different.
> 
> >  /* When adding new state, please change compaction_status_string, too */
> >  
> >  /* Used to signal whether compaction detected need_sched() or lock contention */
> > diff --git a/include/trace/events/compaction.h b/include/trace/events/compaction.h
> > index 139020b..5e47cb2 100644
> > --- a/include/trace/events/compaction.h
> > +++ b/include/trace/events/compaction.h
> > @@ -164,6 +164,97 @@ TRACE_EVENT(mm_compaction_end,
> >  		compaction_status_string[__entry->status])
> >  );
> >  
> > +TRACE_EVENT(mm_compaction_try_to_compact_pages,
> > +
> > +	TP_PROTO(
> > +		unsigned int order,
> > +		gfp_t gfp_mask,
> > +		enum migrate_mode mode,
> > +		int alloc_flags,
> > +		int classzone_idx),
> > +
> > +	TP_ARGS(order, gfp_mask, mode, alloc_flags, classzone_idx),
> > +
> > +	TP_STRUCT__entry(
> > +		__field(unsigned int, order)
> > +		__field(gfp_t, gfp_mask)
> > +		__field(enum migrate_mode, mode)
> > +		__field(int, alloc_flags)
> > +		__field(int, classzone_idx)
> > +	),
> > +
> > +	TP_fast_assign(
> > +		__entry->order = order;
> > +		__entry->gfp_mask = gfp_mask;
> > +		__entry->mode = mode;
> > +		__entry->alloc_flags = alloc_flags;
> > +		__entry->classzone_idx = classzone_idx;
> > +	),
> > +
> > +	TP_printk("order=%u gfp_mask=0x%x mode=%d alloc_flags=0x%x classzone_idx=%d",
> > +		__entry->order,
> > +		__entry->gfp_mask,
> > +		(int)__entry->mode,
> > +		__entry->alloc_flags,
> > +		__entry->classzone_idx)
> > +);
> > +
> > +DECLARE_EVENT_CLASS(mm_compaction_suitable_template,
> > +
> > +	TP_PROTO(struct zone *zone,
> > +		unsigned int order,
> > +		int alloc_flags,
> > +		int classzone_idx,
> > +		int ret),
> > +
> > +	TP_ARGS(zone, order, alloc_flags, classzone_idx, ret),
> > +
> > +	TP_STRUCT__entry(
> > +		__field(char *, name)
> > +		__field(unsigned int, order)
> > +		__field(int, alloc_flags)
> > +		__field(int, classzone_idx)
> > +		__field(int, ret)
> > +	),
> > +
> > +	TP_fast_assign(
> > +		__entry->name = (char *)zone->name;
> 
> This does not identify the NUMA node, just the zone type, isn't it?

Will fix.

> 
> > +		__entry->order = order;
> > +		__entry->alloc_flags = alloc_flags;
> > +		__entry->classzone_idx = classzone_idx;
> > +		__entry->ret = ret;
> > +	),
> > +
> > +	TP_printk("zone=%-8s order=%u alloc_flags=0x%x classzone_idx=%d ret=%s",
> > +		__entry->name,
> > +		__entry->order,
> > +		__entry->alloc_flags,
> > +		__entry->classzone_idx,
> > +		compaction_status_string[__entry->ret])
> > +);
> > +
> > +DEFINE_EVENT(mm_compaction_suitable_template, mm_compaction_finished,
> > +
> > +	TP_PROTO(struct zone *zone,
> > +		unsigned int order,
> > +		int alloc_flags,
> > +		int classzone_idx,
> > +		int ret),
> > +
> > +	TP_ARGS(zone, order, alloc_flags, classzone_idx, ret)
> > +);
> > +
> > +DEFINE_EVENT(mm_compaction_suitable_template, mm_compaction_suitable,
> > +
> > +	TP_PROTO(struct zone *zone,
> > +		unsigned int order,
> > +		int alloc_flags,
> > +		int classzone_idx,
> > +		int ret),
> > +
> > +	TP_ARGS(zone, order, alloc_flags, classzone_idx, ret)
> > +);
> > +
> >  #endif /* _TRACE_COMPACTION_H */
> >  
> >  /* This part must be outside protection */
> > diff --git a/mm/compaction.c b/mm/compaction.c
> > index 4c7b837..f5d2405 100644
> > --- a/mm/compaction.c
> > +++ b/mm/compaction.c
> > @@ -25,6 +25,7 @@ char *compaction_status_string[] = {
> >  	"continue",
> >  	"partial",
> >  	"complete",
> > +	"not_suitable_page",
> 
> So here COMPACT_NOT_SUITABLE is interpreted as "no suitable page was found".
> 
> >  };
> >  
> >  static inline void count_compact_event(enum vm_event_item item)
> > @@ -1048,7 +1049,7 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
> >  	return cc->nr_migratepages ? ISOLATE_SUCCESS : ISOLATE_NONE;
> >  }
> >  
> > -static int compact_finished(struct zone *zone, struct compact_control *cc,
> > +static int __compact_finished(struct zone *zone, struct compact_control *cc,
> >  			    const int migratetype)
> >  {
> >  	unsigned int order;
> > @@ -1103,7 +1104,21 @@ static int compact_finished(struct zone *zone, struct compact_control *cc,
> >  			return COMPACT_PARTIAL;
> >  	}
> >  
> > -	return COMPACT_CONTINUE;
> > +	return COMPACT_NOT_SUITABLE;
> 
> So for compact_finished tracepoint you print "not_suitable_page" and it's what
> it really means - watermarks were met, but no suitable page was actually found.
> But you use "COMPACT_NOT_SUITABLE" which hints at a different meaning.
> 
> > +}
> > +
> > +static int compact_finished(struct zone *zone, struct compact_control *cc,
> > +			    const int migratetype)
> > +{
> > +	int ret;
> > +
> > +	ret = __compact_finished(zone, cc, migratetype);
> > +	trace_mm_compaction_finished(zone, cc->order, cc->alloc_flags,
> > +						cc->classzone_idx, ret);
> > +	if (ret == COMPACT_NOT_SUITABLE)
> > +		ret = COMPACT_CONTINUE;
> > +
> > +	return ret;
> >  }
> >  
> >  /*
> > @@ -1113,7 +1128,7 @@ static int compact_finished(struct zone *zone, struct compact_control *cc,
> >   *   COMPACT_PARTIAL  - If the allocation would succeed without compaction
> >   *   COMPACT_CONTINUE - If compaction should run now
> >   */
> > -unsigned long compaction_suitable(struct zone *zone, int order,
> > +static unsigned long __compaction_suitable(struct zone *zone, int order,
> >  					int alloc_flags, int classzone_idx)
> >  {
> >  	int fragindex;
> > @@ -1157,11 +1172,25 @@ unsigned long compaction_suitable(struct zone *zone, int order,
> >  	 */
> >  	fragindex = fragmentation_index(zone, order);
> >  	if (fragindex >= 0 && fragindex <= sysctl_extfrag_threshold)
> > -		return COMPACT_SKIPPED;
> > +		return COMPACT_NOT_SUITABLE;
> 
> But here in compaction_suitable, return here means that fragmentation seems to
> be low and it's unlikely that compaction will help. COMPACT_NOT_SUITABLE sounds
> like a good name, but then tracepoint prints "not_suitable_page" and that's
> something different.

Okay. How about adding one more like below?

#define COMPACT_NO_SUITABLE_PAGE
#define COMPACT_NOT_SUITABLE_ZONE

It will distiguish return value properly.

> >  	return COMPACT_CONTINUE;
> >  }
> >  
> > +unsigned long compaction_suitable(struct zone *zone, int order,
> > +					int alloc_flags, int classzone_idx)
> > +{
> > +	unsigned long ret;
> > +
> > +	ret = __compaction_suitable(zone, order, alloc_flags, classzone_idx);
> > +	trace_mm_compaction_suitable(zone, order, alloc_flags,
> > +						classzone_idx, ret);
> > +	if (ret == COMPACT_NOT_SUITABLE)
> > +		ret = COMPACT_SKIPPED;
> 
> I don't like this wrapping just for tracepints, but I don't know of a better way :/

Yes, I don't like it, too. :/

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
