Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9BEB26B0265
	for <linux-mm@kvack.org>; Wed, 19 Oct 2016 05:39:41 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id f193so12177235wmg.4
        for <linux-mm@kvack.org>; Wed, 19 Oct 2016 02:39:41 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l137si3726054wmb.38.2016.10.19.02.39.39
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 19 Oct 2016 02:39:40 -0700 (PDT)
Subject: Re: [PATCH] mm, compaction: fix NR_ISOLATED_* stats for pfn based
 migration
References: <20161019080240.9682-1-mhocko@kernel.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <2e4d79f9-74e5-5085-4037-caa9c1cb43e4@suse.cz>
Date: Wed, 19 Oct 2016 11:39:36 +0200
MIME-Version: 1.0
In-Reply-To: <20161019080240.9682-1-mhocko@kernel.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: "ming.ling" <ming.ling@spreadtrum.com>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On 10/19/2016 10:02 AM, Michal Hocko wrote:
> From: Ming Ling <ming.ling@spreadtrum.com>
>
> Since bda807d44454 ("mm: migrate: support non-lru movable page
> migration") isolate_migratepages_block) can isolate !PageLRU pages which
> would acct_isolated account as NR_ISOLATED_*. Accounting these non-lru
> pages NR_ISOLATED_{ANON,FILE} doesn't make any sense and it can misguide
> heuristics based on those counters such as pgdat_reclaimable_pages resp.
> too_many_isolated which would lead to unexpected stalls during the
> direct reclaim without any good reason. Note that
> __alloc_contig_migrate_range can isolate a lot of pages at once.
>
> On mobile devices such as 512M ram android Phone, it may use a big zram
> swap. In some cases zram(zsmalloc) uses too many non-lru but migratedable
> pages, such as:
>
>       MemTotal: 468148 kB
>       Normal free:5620kB
>       Free swap:4736kB
>       Total swap:409596kB
>       ZRAM: 164616kB(zsmalloc non-lru pages)
>       active_anon:60700kB
>       inactive_anon:60744kB
>       active_file:34420kB
>       inactive_file:37532kB
>
> Fix this by only accounting lru pages to NR_ISOLATED_* in
> isolate_migratepages_block right after they were isolated and we still
> know they were on LRU. Drop acct_isolated because it is called after the
> fact and we've lost that information. Batching per-cpu counter doesn't
> make much improvement anyway. Also make sure that we uncharge only LRU
> pages when putting them back on the LRU in putback_movable_pages resp.
> when unmap_and_move migrates the page.

[mhocko@suse.com: replace acct_isolated() with direct counting]
?

Indeed much better than before. IIRC I've personally introduced one or two bugs 
involving acct_isolated() (lack of) usage :) Thanks.

> Fixes: bda807d44454 ("mm: migrate: support non-lru movable page migration")
> Acked-by: Minchan Kim <minchan@kernel.org>
> Signed-off-by: Ming Ling <ming.ling@spreadtrum.com>
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> ---
>  mm/compaction.c | 25 +++----------------------
>  mm/migrate.c    | 15 +++++++++++----
>  2 files changed, 14 insertions(+), 26 deletions(-)
>
> diff --git a/mm/compaction.c b/mm/compaction.c
> index 0409a4ad6ea1..70e6bec46dc2 100644
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
> +		inc_node_page_state(page,
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

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
