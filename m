Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4DC906B0038
	for <linux-mm@kvack.org>; Fri, 30 Sep 2016 06:24:06 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id fu14so190938358pad.0
        for <linux-mm@kvack.org>; Fri, 30 Sep 2016 03:24:06 -0700 (PDT)
Received: from SHSQR01.spreadtrum.com ([222.66.158.135])
        by mx.google.com with ESMTPS id q2si19480961paw.217.2016.09.30.03.24.02
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 30 Sep 2016 03:24:03 -0700 (PDT)
Date: Fri, 30 Sep 2016 18:15:24 +0800
From: Ming Ling <ming.ling@spreadtrum.com>
Subject: Re: [PATCH] mm: exclude isolated non-lru pages from NR_ISOLATED_ANON
 or NR_ISOLATED_FILE.
Message-ID: <20160930101523.GA24978@spreadtrum.com>
References: <1475055063-1588-1-git-send-email-ming.ling@spreadtrum.com>
 <20160930023737.GA6357@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20160930023737.GA6357@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: akpm@linux-foundation.org, mgorman@techsingularity.net, vbabka@suse.cz, hannes@cmpxchg.org, mhocko@suse.com, baiyaowei@cmss.chinamobile.com, iamjoonsoo.kim@lge.com, rientjes@google.com, hughd@google.com, kirill.shutemov@linux.intel.com, riel@redhat.com, mgorman@suse.de, aquini@redhat.com, corbet@lwn.net, linux-mm@kvack.org, linux-kernel@vger.kernel.org, orson.zhai@spreadtrum.com, geng.ren@spreadtrum.com, chunyan.zhang@spreadtrum.com, zhizhou.tian@spreadtrum.com, yuming.han@spreadtrum.com, xiajing@spreadst.com

Hello,

On ao?,  9ae?? 30, 2016 at 11:37:37a,?a?? +0900, Minchan Kim wrote:
> Hello,
> 
> On Wed, Sep 28, 2016 at 05:31:03PM +0800, ming.ling wrote:
> > Non-lru pages don't belong to any lru, so accounting them to
> > NR_ISOLATED_ANON or NR_ISOLATED_FILE doesn't make any sense.
> > It may misguide functions such as pgdat_reclaimable_pages and
> > too_many_isolated.
> 
> I agree this part. It would be happier if you give any story you suffered
> from. Although you don't have, it's okay because you are correcting
> clearly wrong part. Thanks. :)
> 
I haven't suffered from any actual problem yet. It is very hard to make a
special case making reclaim artificially throttled (hung) because of too
many non LRU pages being isolated. But since i do some develpments on low ram
Android devicesi 1/4 ?512M...), i am very sensitive on memory footprint analysis.
Incorrect counting of non-lru pages makes me confused on it.
And patch "mm, vmscan: consider isolated pages in zone_reclaimable_pages
(9f6c399d)" which had been committed by Michal Hocko adds isolated pages in
zone_reclaimable_pages. So i think it is worth to ensure their counts are right.
> > 
> > This patch adds NR_ISOLATED_NONLRU to vmstat and moves isolated non-lru
> > pages from NR_ISOLATED_ANON or NR_ISOLATED_FILE to NR_ISOLATED_NONLRU.
> > And with non-lru pages in vmstat, it helps to optimize algorithm of
> > function too_many_isolated oneday.
> 
> Need more justfication to add new vmstat because once we add it, it's
> really hard to change/remove it(i.e., maintainace trobule) so I want
> to add it when it really would be helpful sometime, not now.
> 
> Could you resend the patch without part adding new vmstat?
> 
> Thanks.
>
No problem, let's add it when it really would be helpful sometime.
I will resend the patch without part adding new vmstat later.

Thank you very much. 
> > 
> > Signed-off-by: ming.ling <ming.ling@spreadtrum.com>
> > ---
> >  include/linux/mmzone.h |  1 +
> >  mm/compaction.c        | 12 +++++++++---
> >  mm/migrate.c           | 14 ++++++++++----
> >  3 files changed, 20 insertions(+), 7 deletions(-)
> > 
> > diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> > index 7f2ae99..dc0adba 100644
> > --- a/include/linux/mmzone.h
> > +++ b/include/linux/mmzone.h
> > @@ -169,6 +169,7 @@ enum node_stat_item {
> >  	NR_VMSCAN_IMMEDIATE,	/* Prioritise for reclaim when writeback ends */
> >  	NR_DIRTIED,		/* page dirtyings since bootup */
> >  	NR_WRITTEN,		/* page writings since bootup */
> > +	NR_ISOLATED_NONLRU,	/* Temporary isolated pages from non-lru */
> >  	NR_VM_NODE_STAT_ITEMS
> >  };
> >  
> > diff --git a/mm/compaction.c b/mm/compaction.c
> > index 9affb29..8da1dca 100644
> > --- a/mm/compaction.c
> > +++ b/mm/compaction.c
> > @@ -638,16 +638,21 @@ isolate_freepages_range(struct compact_control *cc,
> >  static void acct_isolated(struct zone *zone, struct compact_control *cc)
> >  {
> >  	struct page *page;
> > -	unsigned int count[2] = { 0, };
> > +	unsigned int count[3] = { 0, };
> >  
> >  	if (list_empty(&cc->migratepages))
> >  		return;
> >  
> > -	list_for_each_entry(page, &cc->migratepages, lru)
> > -		count[!!page_is_file_cache(page)]++;
> > +	list_for_each_entry(page, &cc->migratepages, lru) {
> > +		if (PageLRU(page))
> > +			count[!!page_is_file_cache(page)]++;
> > +		else
> > +			count[2]++;
> > +	}
> >  
> >  	mod_node_page_state(zone->zone_pgdat, NR_ISOLATED_ANON, count[0]);
> >  	mod_node_page_state(zone->zone_pgdat, NR_ISOLATED_FILE, count[1]);
> > +	mod_node_page_state(zone->zone_pgdat, NR_ISOLATED_NONLRU, count[2]);
> >  }
> >  
> >  /* Similar to reclaim, but different enough that they don't share logic */
> > @@ -659,6 +664,7 @@ static bool too_many_isolated(struct zone *zone)
> >  			node_page_state(zone->zone_pgdat, NR_INACTIVE_ANON);
> >  	active = node_page_state(zone->zone_pgdat, NR_ACTIVE_FILE) +
> >  			node_page_state(zone->zone_pgdat, NR_ACTIVE_ANON);
> > +	/* Is it necessary to add NR_ISOLATED_NONLRU?? */
> >  	isolated = node_page_state(zone->zone_pgdat, NR_ISOLATED_FILE) +
> >  			node_page_state(zone->zone_pgdat, NR_ISOLATED_ANON);
> >  
> > diff --git a/mm/migrate.c b/mm/migrate.c
> > index f7ee04a..cd5abb2 100644
> > --- a/mm/migrate.c
> > +++ b/mm/migrate.c
> > @@ -168,8 +168,11 @@ void putback_movable_pages(struct list_head *l)
> >  			continue;
> >  		}
> >  		list_del(&page->lru);
> > -		dec_node_page_state(page, NR_ISOLATED_ANON +
> > -				page_is_file_cache(page));
> > +		if (PageLRU(page))
> > +			dec_node_page_state(page, NR_ISOLATED_ANON +
> > +					page_is_file_cache(page));
> > +		else
> > +			dec_node_page_state(page, NR_ISOLATED_NONLRU);
> >  		/*
> >  		 * We isolated non-lru movable page so here we can use
> >  		 * __PageMovable because LRU page's mapping cannot have
> > @@ -1121,8 +1124,11 @@ out:
> >  		 * restored.
> >  		 */
> >  		list_del(&page->lru);
> > -		dec_node_page_state(page, NR_ISOLATED_ANON +
> > -				page_is_file_cache(page));
> > +		if (PageLRU(page))
> > +			dec_node_page_state(page, NR_ISOLATED_ANON +
> > +					page_is_file_cache(page));
> > +		else
> > +			dec_node_page_state(page, NR_ISOLATED_NONLRU);
> >  	}
> >  
> >  	/*
> > -- 
> > 1.9.1
> > 
> > --
> > To unsubscribe, send a message with 'unsubscribe linux-mm' in
> > the body to majordomo@kvack.org.  For more info on Linux MM,
> > see: http://www.linux-mm.org/ .
> > Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
