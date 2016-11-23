Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f198.google.com (mail-wj0-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 428F16B028B
	for <linux-mm@kvack.org>; Wed, 23 Nov 2016 11:33:56 -0500 (EST)
Received: by mail-wj0-f198.google.com with SMTP id j10so3012344wjb.3
        for <linux-mm@kvack.org>; Wed, 23 Nov 2016 08:33:56 -0800 (PST)
Received: from outbound-smtp02.blacknight.com (outbound-smtp02.blacknight.com. [81.17.249.8])
        by mx.google.com with ESMTPS id g2si32001916wjt.33.2016.11.23.08.33.54
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 23 Nov 2016 08:33:54 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp02.blacknight.com (Postfix) with ESMTPS id 8B40B98A84
	for <linux-mm@kvack.org>; Wed, 23 Nov 2016 16:33:52 +0000 (UTC)
Date: Wed, 23 Nov 2016 16:33:51 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [RFC PATCH] mm: page_alloc: High-order per-cpu page allocator
Message-ID: <20161123163351.6s76ijwnqoakgcud@techsingularity.net>
References: <20161121155540.5327-1-mgorman@techsingularity.net>
 <4a9cdec4-b514-e414-de86-fc99681889d8@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <4a9cdec4-b514-e414-de86-fc99681889d8@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Linux-MM <linux-mm@kvack.org>, Christoph Lameter <cl@linux.com>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-Kernel <linux-kernel@vger.kernel.org>

On Wed, Nov 23, 2016 at 04:37:06PM +0100, Vlastimil Babka wrote:
> On 11/21/2016 04:55 PM, Mel Gorman wrote:
> 
> ...
> 
> > hackbench was also tested with both socket and pipes and both processes
> > and threads and the results are interesting in terms of how variability
> > is imapcted
> > 
> > 1-socket machine -- pipes and processes
> >                         4.9.0-rc5             4.9.0-rc5
> >                           vanilla        highmark-v1r12
> > Amean    1      12.9637 (  0.00%)     12.9570 (  0.05%)
> > Amean    3      13.4770 (  0.00%)     13.4447 (  0.24%)
> > Amean    5      18.5333 (  0.00%)     19.0917 ( -3.01%)
> > Amean    7      24.5690 (  0.00%)     26.1010 ( -6.24%)
> > Amean    12     39.7990 (  0.00%)     40.6763 ( -2.20%)
> > Amean    16     56.0520 (  0.00%)     58.2530 ( -3.93%)
> 
> Here, higher values are better or worse?
> 

Higher values are worse.

> > diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> > index 0f088f3a2fed..02eb24d90d70 100644
> > --- a/include/linux/mmzone.h
> > +++ b/include/linux/mmzone.h
> > @@ -255,6 +255,24 @@ enum zone_watermarks {
> >  	NR_WMARK
> >  };
> > 
> > +/*
> > + * One per migratetype for order-0 pages and one per high-order up to
> > + * and including PAGE_ALLOC_COSTLY_ORDER. This may allow unmovable
> > + * allocations to contaminate reclaimable pageblocks if high-order
> > + * pages are heavily used.
> > + */
> > +#define NR_PCP_LISTS (MIGRATE_PCPTYPES + PAGE_ALLOC_COSTLY_ORDER + 1)
> 
> Should it be "- 1" instead of "+ 1"?
> 

Yes.

> > +
> > +static inline unsigned int pindex_to_order(unsigned int pindex)
> > +{
> > +	return pindex < MIGRATE_PCPTYPES ? 0 : pindex - MIGRATE_PCPTYPES + 1;
> > +}
> > +
> > +static inline unsigned int order_to_pindex(int migratetype, unsigned int order)
> > +{
> > +	return (order == 0) ? migratetype : MIGRATE_PCPTYPES - 1 + order;
> 
> Here I think that "MIGRATE_PCPTYPES + order - 1" would be easier to
> understand as the array is for all migratetypes, but the order is shifted?
> 

As in migratetypes * costly_order ? That would be excessively large.

> > @@ -1083,10 +1083,12 @@ static bool bulkfree_pcp_prepare(struct page *page)
> >   * pinned" detection logic.
> >   */
> >  static void free_pcppages_bulk(struct zone *zone, int count,
> > -					struct per_cpu_pages *pcp)
> > +					struct per_cpu_pages *pcp,
> > +					int migratetype)
> >  {
> > -	int migratetype = 0;
> > -	int batch_free = 0;
> > +	unsigned int pindex = 0;
> 
> Should pindex be initialized to migratetype to match the list below?
> 

Functionally it doesn't matter. It affects which list is tried first if
the preferred list is empty. Arguably it would make more sense to init
it to NR_PCP_LISTS - 1 so all order-0 lists are always drained before the
high-order pages but there is not much justification for that.

I'll take your suggestion until there is data supporting that high-order
caches should be preserved.

Thanks.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
