Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id E355B6B0267
	for <linux-mm@kvack.org>; Thu, 13 Oct 2016 04:09:40 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id n3so43544566lfn.5
        for <linux-mm@kvack.org>; Thu, 13 Oct 2016 01:09:40 -0700 (PDT)
Received: from mail-lf0-f67.google.com (mail-lf0-f67.google.com. [209.85.215.67])
        by mx.google.com with ESMTPS id u8si7498640lff.258.2016.10.13.01.09.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Oct 2016 01:09:39 -0700 (PDT)
Received: by mail-lf0-f67.google.com with SMTP id x79so11367685lff.2
        for <linux-mm@kvack.org>; Thu, 13 Oct 2016 01:09:39 -0700 (PDT)
Date: Thu, 13 Oct 2016 10:09:37 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2] mm: exclude isolated non-lru pages from
 NR_ISOLATED_ANON or NR_ISOLATED_FILE.
Message-ID: <20161013080936.GG21678@dhcp22.suse.cz>
References: <1476340749-13281-1-git-send-email-ming.ling@spreadtrum.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1476340749-13281-1-git-send-email-ming.ling@spreadtrum.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "ming.ling" <ming.ling@spreadtrum.com>
Cc: akpm@linux-foundation.org, mgorman@techsingularity.net, vbabka@suse.cz, hannes@cmpxchg.org, baiyaowei@cmss.chinamobile.com, iamjoonsoo.kim@lge.com, minchan@kernel.org, rientjes@google.com, hughd@google.com, kirill.shutemov@linux.intel.com, riel@redhat.com, mgorman@suse.de, aquini@redhat.com, corbet@lwn.net, linux-mm@kvack.org, linux-kernel@vger.kernel.org, orson.zhai@spreadtrum.com, geng.ren@spreadtrum.com, chunyan.zhang@spreadtrum.com, zhizhou.tian@spreadtrum.com, yuming.han@spreadtrum.com, xiajing@spreadst.com

On Thu 13-10-16 14:39:09, ming.ling wrote:
> From: Ming Ling <ming.ling@spreadtrum.com>
> 
> Non-lru pages don't belong to any lru, so counting them to
> NR_ISOLATED_ANON or NR_ISOLATED_FILE doesn't make any sense.
> It may misguide functions such as pgdat_reclaimable_pages and
> too_many_isolated.

That doesn't make much sense to me. I guess you wanted to say something
like
"
Accounting non-lru pages isolated for migration during pfn walk to
NR_ISOLATED_{ANON,FILE} doesn't make any sense and it can misguide
heuristics based on those counters such as pgdat_reclaimable_pages resp.
too_many_isolated. Note that __alloc_contig_migrate_range can isolate
a lot of pages at once.
"
> On mobile devices such as 512M ram android Phone, it may use
> a big zram swap. In some cases zram(zsmalloc) uses too many
> non-lru pages, such as:
> 	MemTotal: 468148 kB
> 	Normal free:5620kB
> 	Free swap:4736kB
> 	Total swap:409596kB
> 	ZRAM: 164616kB(zsmalloc non-lru pages)
> 	active_anon:60700kB
> 	inactive_anon:60744kB
> 	active_file:34420kB
> 	inactive_file:37532kB

I assume those zsmalloc pages are migrateable and that is the problem?
Please state that explicitly so that even people not familiar with
zsmalloc understand the motivation.

> More non-lru pages which used by zram for swap, it influences
> pgdat_reclaimable_pages and too_many_isolated more.

It would be good to mention what would be a visible effect of this.
"If the NR_ISOLATED_* is too large then the direct reclaim might get
throttled prematurely inducing longer allocation latencies without any
strong reason."

> This patch excludes isolated non-lru pages from NR_ISOLATED_ANON
> or NR_ISOLATED_FILE to ensure their counts are right.

But this patch doesn't do that. It just relies on __PageMovable. It is
true that all LRU pages should be movable (well except for
NR_UNEVICTABLE in certain configurations) but is it true that all
movable pages are on the LRU list?

Why don't you simply mimic what shrink_inactive_list does? Aka count the
number of isolated pages and then account them when appropriate?
 
> Signed-off-by: Ming ling <ming.ling@spreadtrum.com>
> ---
>  mm/compaction.c | 6 ++++--
>  mm/migrate.c    | 9 +++++----
>  2 files changed, 9 insertions(+), 6 deletions(-)
> 
> diff --git a/mm/compaction.c b/mm/compaction.c
> index 0409a4a..ed4c553 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -643,8 +643,10 @@ static void acct_isolated(struct zone *zone, struct compact_control *cc)
>  	if (list_empty(&cc->migratepages))
>  		return;
>  
> -	list_for_each_entry(page, &cc->migratepages, lru)
> -		count[!!page_is_file_cache(page)]++;
> +	list_for_each_entry(page, &cc->migratepages, lru) {
> +		if (likely(!__PageMovable(page)))
> +			count[!!page_is_file_cache(page)]++;
> +	}
>  
>  	mod_node_page_state(zone->zone_pgdat, NR_ISOLATED_ANON, count[0]);
>  	mod_node_page_state(zone->zone_pgdat, NR_ISOLATED_FILE, count[1]);
> diff --git a/mm/migrate.c b/mm/migrate.c
> index 99250ae..abe48cc 100644
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
> @@ -185,6 +183,8 @@ void putback_movable_pages(struct list_head *l)
>  			unlock_page(page);
>  			put_page(page);
>  		} else {
> +			dec_node_page_state(page, NR_ISOLATED_ANON +
> +					page_is_file_cache(page));
>  			putback_lru_page(page);
>  		}
>  	}
> @@ -1121,8 +1121,9 @@ static ICE_noinline int unmap_and_move(new_page_t get_new_page,
>  		 * restored.
>  		 */
>  		list_del(&page->lru);
> -		dec_node_page_state(page, NR_ISOLATED_ANON +
> -				page_is_file_cache(page));
> +		if (likely(!__PageMovable(page)))
> +			dec_node_page_state(page, NR_ISOLATED_ANON +
> +					page_is_file_cache(page));
>  	}
>  
>  	/*
> -- 
> 1.9.1

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
