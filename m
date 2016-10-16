Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 717096B0038
	for <linux-mm@kvack.org>; Sun, 16 Oct 2016 19:06:32 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id rz1so182923458pab.0
        for <linux-mm@kvack.org>; Sun, 16 Oct 2016 16:06:32 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id v189si24581759pgd.118.2016.10.16.16.06.30
        for <linux-mm@kvack.org>;
        Sun, 16 Oct 2016 16:06:31 -0700 (PDT)
Date: Mon, 17 Oct 2016 08:06:18 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v2] mm: exclude isolated non-lru pages from
 NR_ISOLATED_ANON or NR_ISOLATED_FILE.
Message-ID: <20161016230618.GB9196@bbox>
References: <1476340749-13281-1-git-send-email-ming.ling@spreadtrum.com>
 <20161013080936.GG21678@dhcp22.suse.cz>
 <20161014083219.GA20260@spreadtrum.com>
 <20161014113044.GB6063@dhcp22.suse.cz>
 <20161014134604.GA2179@blaptop>
 <20161014135334.GF6063@dhcp22.suse.cz>
 <20161014144448.GA2899@blaptop>
 <20161014150355.GH6063@dhcp22.suse.cz>
 <20161014152633.GA3157@blaptop>
 <20161015071044.GC9949@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161015071044.GC9949@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Ming Ling <ming.ling@spreadtrum.com>, akpm@linux-foundation.org, mgorman@techsingularity.net, vbabka@suse.cz, hannes@cmpxchg.org, baiyaowei@cmss.chinamobile.com, iamjoonsoo.kim@lge.com, rientjes@google.com, hughd@google.com, kirill.shutemov@linux.intel.com, riel@redhat.com, mgorman@suse.de, aquini@redhat.com, corbet@lwn.net, linux-mm@kvack.org, linux-kernel@vger.kernel.org, orson.zhai@spreadtrum.com, geng.ren@spreadtrum.com, chunyan.zhang@spreadtrum.com, zhizhou.tian@spreadtrum.com, yuming.han@spreadtrum.com, xiajing@spreadst.com

Hi Michal,

On Sat, Oct 15, 2016 at 09:10:45AM +0200, Michal Hocko wrote:
> On Sat 15-10-16 00:26:33, Minchan Kim wrote:
> > On Fri, Oct 14, 2016 at 05:03:55PM +0200, Michal Hocko wrote:
> [...]
> > > diff --git a/mm/compaction.c b/mm/compaction.c
> > > index 0409a4ad6ea1..6584705a46f6 100644
> > > --- a/mm/compaction.c
> > > +++ b/mm/compaction.c
> > > @@ -685,7 +685,8 @@ static bool too_many_isolated(struct zone *zone)
> > >   */
> > >  static unsigned long
> > >  isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
> > > -			unsigned long end_pfn, isolate_mode_t isolate_mode)
> > > +			unsigned long end_pfn, isolate_mode_t isolate_mode,
> > > +			unsigned long *isolated_file, unsigned long *isolated_anon)
> > >  {
> > >  	struct zone *zone = cc->zone;
> > >  	unsigned long nr_scanned = 0, nr_isolated = 0;
> > > @@ -866,6 +867,10 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
> > >  
> > >  		/* Successfully isolated */
> > >  		del_page_from_lru_list(page, lruvec, page_lru(page));
> > > +		if (page_is_file_cache(page))
> > > +			(*isolated_file)++;
> > > +		else
> > > +			(*isolated_anon)++;
> > >  
> > >  isolate_success:
> > >  		list_add(&page->lru, &cc->migratepages);
> > > 
> > > Makes more sense?
> > 
> > It is doable for isolation part. IOW, maybe we can make acct_isolated
> > simple with those counters but we need to handle migrate, putback part.
> > If you want to remove the check of __PageMoable with those counter, it
> > means we should pass the counter on every functions related migration
> > where isolate, migrate, putback parts.
> 
> OK, I see. Can we just get rid of acct_isolated altogether? Why cannot
> we simply update NR_ISOLATED_* while isolating pages? Just looking at
> isolate_migratepages_block:
> 			acct_isolated(zone, cc);
> 			putback_movable_pages(&cc->migratepages);
> 
> suggests we are doing something suboptimal. I guess we cannot get rid of
> __PageMoveble checks which is sad because that just adds a lot of
> confusion because checking for !__PageMovable(page) for LRU pages is
> just a head scratcher (LRU pages are movable arent' they?). Maybe it
> would be even good to get rid of this misnomer. PageNonLRUMovable?

Yeah, I hated the naming but didn't have a good idea.
PageNonLRUMovable, definitely, one I thought as candidate but dropped
by lenghthy naming. If others don't object, I am happy to change it.

> 
> Anyway, I would suggest to do something like this. Batching NR_ISOLATED*
> just doesn't make all that much sense as these are per-cpu and the
> resulting code seems to be easier without it.

Agree. Could you resend it as formal patch?

> ---
> diff --git a/mm/compaction.c b/mm/compaction.c
> index 0409a4ad6ea1..df1fd0c20e5c 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -634,22 +634,6 @@ isolate_freepages_range(struct compact_control *cc,
>  	return pfn;
>  }
>  
> -/* Update the number of anon and file isolated pages in the zone */
> -static void acct_isolated(struct zone *zone, struct compact_control *cc)
> -{
> -	struct page *page;
> -	unsigned int count[2] = { 0, };
> -
> -	if (list_empty(&cc->migratepages))
> -		return;
> -
> -	list_for_each_entry(page, &cc->migratepages, lru)
> -		count[!!page_is_file_cache(page)]++;
> -
> -	mod_node_page_state(zone->zone_pgdat, NR_ISOLATED_ANON, count[0]);
> -	mod_node_page_state(zone->zone_pgdat, NR_ISOLATED_FILE, count[1]);
> -}
> -
>  /* Similar to reclaim, but different enough that they don't share logic */
>  static bool too_many_isolated(struct zone *zone)
>  {
> @@ -866,6 +850,8 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
>  
>  		/* Successfully isolated */
>  		del_page_from_lru_list(page, lruvec, page_lru(page));
> +		inc_node_page_state(zone->zone_pgdat,
> +				NR_ISOLATED_ANON + page_is_file_cache(page));
>  
>  isolate_success:
>  		list_add(&page->lru, &cc->migratepages);
> @@ -902,7 +888,6 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
>  				spin_unlock_irqrestore(zone_lru_lock(zone), flags);
>  				locked = false;
>  			}
> -			acct_isolated(zone, cc);
>  			putback_movable_pages(&cc->migratepages);
>  			cc->nr_migratepages = 0;
>  			cc->last_migrated_pfn = 0;
> @@ -988,7 +973,6 @@ isolate_migratepages_range(struct compact_control *cc, unsigned long start_pfn,
>  		if (cc->nr_migratepages == COMPACT_CLUSTER_MAX)
>  			break;
>  	}
> -	acct_isolated(cc->zone, cc);
>  
>  	return pfn;
>  }
> @@ -1258,10 +1242,8 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
>  		low_pfn = isolate_migratepages_block(cc, low_pfn,
>  						block_end_pfn, isolate_mode);
>  
> -		if (!low_pfn || cc->contended) {
> -			acct_isolated(zone, cc);
> +		if (!low_pfn || cc->contended)
>  			return ISOLATE_ABORT;
> -		}
>  
>  		/*
>  		 * Either we isolated something and proceed with migration. Or
> @@ -1271,7 +1253,6 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
>  		break;
>  	}
>  
> -	acct_isolated(zone, cc);
>  	/* Record where migration scanner will be restarted. */
>  	cc->migrate_pfn = low_pfn;
>  
> diff --git a/mm/migrate.c b/mm/migrate.c
> index 99250aee1ac1..66ce6b490b13 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -168,8 +168,6 @@ void putback_movable_pages(struct list_head *l)
>  			continue;
>  		}
>  		list_del(&page->lru);
> -		dec_node_page_state(page, NR_ISOLATED_ANON +
> -				page_is_file_cache(page));
>  		/*
>  		 * We isolated non-lru movable page so here we can use
>  		 * __PageMovable because LRU page's mapping cannot have
> @@ -186,6 +184,8 @@ void putback_movable_pages(struct list_head *l)
>  			put_page(page);
>  		} else {
>  			putback_lru_page(page);
> +			dec_node_page_state(page, NR_ISOLATED_ANON +
> +					page_is_file_cache(page));
>  		}
>  	}
>  }
> @@ -1121,8 +1121,15 @@ static ICE_noinline int unmap_and_move(new_page_t get_new_page,
>  		 * restored.
>  		 */
>  		list_del(&page->lru);
> -		dec_node_page_state(page, NR_ISOLATED_ANON +
> -				page_is_file_cache(page));
> +
> +		/*
> +		 * Compaction can migrate also non-LRU pages which are
> +		 * not accounted to NR_ISOLATED_*. They can be recognized
> +		 * as __PageMovable
> +		 */
> +		if (likely(!__PageMovable(page)))
> +			dec_node_page_state(page, NR_ISOLATED_ANON +
> +					page_is_file_cache(page));
>  	}
>  
>  	/*
> 
> -- 
> Michal Hocko
> SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
