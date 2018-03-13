Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id C5F146B0007
	for <linux-mm@kvack.org>; Mon, 12 Mar 2018 22:10:38 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id r1so7469792pgq.7
        for <linux-mm@kvack.org>; Mon, 12 Mar 2018 19:10:38 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id s14-v6si4434411plq.674.2018.03.12.19.10.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Mar 2018 19:10:37 -0700 (PDT)
Date: Tue, 13 Mar 2018 10:11:41 +0800
From: Aaron Lu <aaron.lu@intel.com>
Subject: Re: [PATCH v4 1/3] mm/free_pcppages_bulk: update pcp->count inside
Message-ID: <20180313021141.GA13782@intel.com>
References: <20180301062845.26038-1-aaron.lu@intel.com>
 <20180301062845.26038-2-aaron.lu@intel.com>
 <a541716e-b55c-bb75-eab9-eb46a08d5ffa@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <a541716e-b55c-bb75-eab9-eb46a08d5ffa@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Huang Ying <ying.huang@intel.com>, Dave Hansen <dave.hansen@intel.com>, Kemi Wang <kemi.wang@intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Andi Kleen <ak@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Mel Gorman <mgorman@techsingularity.net>, Matthew Wilcox <willy@infradead.org>, David Rientjes <rientjes@google.com>

On Mon, Mar 12, 2018 at 02:22:28PM +0100, Vlastimil Babka wrote:
> On 03/01/2018 07:28 AM, Aaron Lu wrote:
> > Matthew Wilcox found that all callers of free_pcppages_bulk() currently
> > update pcp->count immediately after so it's natural to do it inside
> > free_pcppages_bulk().
> > 
> > No functionality or performance change is expected from this patch.
> 
> Well, it's N decrements instead of one decrement by N / assignment of
> zero. But I assume the difference is negligible anyway, right?

Yes.

> 
> > Suggested-by: Matthew Wilcox <willy@infradead.org>
> > Signed-off-by: Aaron Lu <aaron.lu@intel.com>
> 
> Acked-by: Vlastimil Babka <vbabka@suse.cz>

Thanks!

> > ---
> >  mm/page_alloc.c | 10 +++-------
> >  1 file changed, 3 insertions(+), 7 deletions(-)
> > 
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index cb416723538f..faa33eac1635 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -1148,6 +1148,7 @@ static void free_pcppages_bulk(struct zone *zone, int count,
> >  			page = list_last_entry(list, struct page, lru);
> >  			/* must delete as __free_one_page list manipulates */
> >  			list_del(&page->lru);
> > +			pcp->count--;
> >  
> >  			mt = get_pcppage_migratetype(page);
> >  			/* MIGRATE_ISOLATE page should not go to pcplists */
> > @@ -2416,10 +2417,8 @@ void drain_zone_pages(struct zone *zone, struct per_cpu_pages *pcp)
> >  	local_irq_save(flags);
> >  	batch = READ_ONCE(pcp->batch);
> >  	to_drain = min(pcp->count, batch);
> > -	if (to_drain > 0) {
> > +	if (to_drain > 0)
> >  		free_pcppages_bulk(zone, to_drain, pcp);
> > -		pcp->count -= to_drain;
> > -	}
> >  	local_irq_restore(flags);
> >  }
> >  #endif
> > @@ -2441,10 +2440,8 @@ static void drain_pages_zone(unsigned int cpu, struct zone *zone)
> >  	pset = per_cpu_ptr(zone->pageset, cpu);
> >  
> >  	pcp = &pset->pcp;
> > -	if (pcp->count) {
> > +	if (pcp->count)
> >  		free_pcppages_bulk(zone, pcp->count, pcp);
> > -		pcp->count = 0;
> > -	}
> >  	local_irq_restore(flags);
> >  }
> >  
> > @@ -2668,7 +2665,6 @@ static void free_unref_page_commit(struct page *page, unsigned long pfn)
> >  	if (pcp->count >= pcp->high) {
> >  		unsigned long batch = READ_ONCE(pcp->batch);
> >  		free_pcppages_bulk(zone, batch, pcp);
> > -		pcp->count -= batch;
> >  	}
> >  }
> >  
> > 
> 
