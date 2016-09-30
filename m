Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 742656B0038
	for <linux-mm@kvack.org>; Fri, 30 Sep 2016 00:50:47 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id y67so26811083oig.3
        for <linux-mm@kvack.org>; Thu, 29 Sep 2016 21:50:47 -0700 (PDT)
Received: from SHSQR01.spreadtrum.com ([222.66.158.135])
        by mx.google.com with ESMTPS id n128si12180124oib.39.2016.09.29.21.50.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 29 Sep 2016 21:50:45 -0700 (PDT)
Date: Fri, 30 Sep 2016 12:41:10 +0800
From: Ming Ling <ming.ling@spreadtrum.com>
Subject: Re: [PATCH] mm: exclude isolated non-lru pages from NR_ISOLATED_ANON
 or NR_ISOLATED_FILE.
Message-ID: <20160930044110.GA31160@spreadtrum.com>
References: <1475055063-1588-1-git-send-email-ming.ling@spreadtrum.com>
 <201609290806.u8T86Ik0052869@TPSPAM01.spreadtrum.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <201609290806.u8T86Ik0052869@TPSPAM01.spreadtrum.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: akpm@linux-foundation.org, mgorman@techsingularity.net, vbabka@suse.cz, hannes@cmpxchg.org, baiyaowei@cmss.chinamobile.com, iamjoonsoo.kim@lge.com, minchan@kernel.org, rientjes@google.com, hughd@google.com, kirill.shutemov@linux.intel.com, riel@redhat.com, mgorman@suse.de, aquini@redhat.com, corbet@lwn.net, linux-mm@kvack.org, linux-kernel@vger.kernel.org, orson.zhai@spreadtrum.com, geng.ren@spreadtrum.com, chunyan.zhang@spreadtrum.com, zhizhou.tian@spreadtrum.com, yuming.han@spreadtrum.com, xiajing@spreadst.com

On a??,  9ae?? 29, 2016 at 10:01:43a,?a?? +0200, Michal Hocko wrote:
> On Wed 28-09-16 17:31:03, ming.ling wrote:
> > Non-lru pages don't belong to any lru, so accounting them to
> > NR_ISOLATED_ANON or NR_ISOLATED_FILE doesn't make any sense.
> > It may misguide functions such as pgdat_reclaimable_pages and
> > too_many_isolated.
> 
> OK, but it would be better to mention that this related to pfn based
> migration (e.g. compaction). It is also highly appreciated to describe
> the actual problem that you are seeing and tryin to fix. Is a reclaim
> artificially throttled (hung) because of too many non LRU pages being
> isolated? Is there a way to trigger that condition? So please tell us
> more.
>
Yes, you are right, it only related to pfn based migration such as
compaction and alloc_contig_range. On mobile devices such as 512M ram
android Phone, it may use a big zram swap. In some case zram(zsmalloc) 
use too many non-lru pages,such as:
	MemTotal: 468148 kB
	Normal free:5620kB
	Free swap:4736kB
	Total swap:409596kB
	ZRAM: 164616kB(zsmalloc non-lru pages)
	active_anon:60700kB
	inactive_anon:60744kB
	active_file:34420kB
	inactive_file:37532kB
More non-lru pages which used by zram for swap, it influences
pgdat_reclaimable_pages and too_many_isolated more. But it is very hard
to make a special case making reclaim artificially throttled (hung) 
because of too many non LRU pages being isolated. Larger swap disk,
higher swapness, more backup applications, lower lowmemory killer minfree
water level, more high order pageblock allocation may trigger that condition.  
> > This patch adds NR_ISOLATED_NONLRU to vmstat and moves isolated non-lru
> > pages from NR_ISOLATED_ANON or NR_ISOLATED_FILE to NR_ISOLATED_NONLRU.
> > And with non-lru pages in vmstat, it helps to optimize algorithm of
> > function too_many_isolated oneday.
> 
> I am not entirely sure a new vmstat counter is really needed but I have
> to admit that the role of too_many_isolated in isolate_migratepages_block
> is quite unclear to me. Besides that I believe the patch is not correct
> because you are checking PageLRU after those pages have already been
> isolated from the LRU. For example putback_movable_pages operates on
> pages which are put back to the LRU. I haven't checked others but I
> suspect they would be in a similar situation.
> 
Yes, i had make a mistake. After those pages have already been isolated from
the LRU, it has to check __PageMovable instead of PageLRU such as function
putback_movable_pages, unmap_and_move and __unmap_and_move.
I will correct it in next patch,. Thank you very much.
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
> 
> -- 
> Michal Hocko
> SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
