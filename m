Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 3AF626B0035
	for <linux-mm@kvack.org>; Wed,  4 Jun 2014 12:07:25 -0400 (EDT)
Received: by mail-wi0-f172.google.com with SMTP id hi2so8682129wib.11
        for <linux-mm@kvack.org>; Wed, 04 Jun 2014 09:07:23 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z13si5692336wjr.48.2014.06.04.09.07.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 04 Jun 2014 09:07:23 -0700 (PDT)
Message-ID: <538F4434.2080802@suse.cz>
Date: Wed, 04 Jun 2014 18:07:16 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [patch -mm 3/3] mm, compaction: avoid compacting memory for thp
 if pageblock cannot become free
References: <1399904111-23520-1-git-send-email-vbabka@suse.cz> <1400233673-11477-1-git-send-email-vbabka@suse.cz> <alpine.DEB.2.02.1405211954410.13243@chino.kir.corp.google.com> <537DB0E5.40602@suse.cz> <alpine.DEB.2.02.1405220127320.13630@chino.kir.corp.google.com> <537DE799.3040400@suse.cz> <alpine.DEB.2.02.1406031728390.5312@chino.kir.corp.google.com> <alpine.DEB.2.02.1406031729410.5312@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.02.1406031729410.5312@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Hugh Dickins <hughd@google.com>, Greg Thelen <gthelen@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>, Michal Nazarewicz <mina86@mina86.com>, Rik van Riel <riel@redhat.com>

On 06/04/2014 02:30 AM, David Rientjes wrote:
> It's pointless to migrate pages within a pageblock if the entire pageblock will
> not become free for a thp allocation.
>
> If we encounter a page that cannot be migrated and a direct compactor other than
> khugepaged is trying to allocate a hugepage for thp, then skip the entire
> pageblock and avoid migrating pages needlessly.

The problem here is that if you encounter a PageBuddy with order > 0, in 
the next iteration you will see a page that's neither PageBuddy nor 
PageLRU and skip the rest of the pageblock.

I was working on slightly different approach, which is not properly 
tested yet so I will just post a RFC for discussion.

> Signed-off-by: David Rientjes <rientjes@google.com>
> ---
>   mm/compaction.c | 41 ++++++++++++++++++++++++++++-------------
>   1 file changed, 28 insertions(+), 13 deletions(-)
>
> diff --git a/mm/compaction.c b/mm/compaction.c
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -537,12 +537,12 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
>   		if ((low_pfn & (MAX_ORDER_NR_PAGES - 1)) == 0) {
>   			if (!pfn_valid(low_pfn)) {
>   				low_pfn += MAX_ORDER_NR_PAGES - 1;
> -				continue;
> +				goto next;
>   			}
>   		}
>
>   		if (!pfn_valid_within(low_pfn))
> -			continue;
> +			goto next;
>   		nr_scanned++;
>
>   		/*
> @@ -553,7 +553,7 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
>   		 */
>   		page = pfn_to_page(low_pfn);
>   		if (page_zone(page) != zone)
> -			continue;
> +			goto next;
>
>   		if (!valid_page)
>   			valid_page = page;
> @@ -599,7 +599,7 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
>   					goto isolate_success;
>   				}
>   			}
> -			continue;
> +			goto next;
>   		}
>
>   		/*
> @@ -616,7 +616,7 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
>   			if (!locked)
>   				goto next_pageblock;
>   			low_pfn += (1 << compound_order(page)) - 1;
> -			continue;
> +			goto next;
>   		}
>
>   		/*
> @@ -626,7 +626,7 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
>   		 */
>   		if (!page_mapping(page) &&
>   		    page_count(page) > page_mapcount(page))
> -			continue;
> +			goto next;
>
>   		/* Check if it is ok to still hold the lock */
>   		locked = compact_checklock_irqsave(&zone->lru_lock, &flags,
> @@ -636,17 +636,17 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
>
>   		/* Recheck PageLRU and PageTransHuge under lock */
>   		if (!PageLRU(page))
> -			continue;
> +			goto next;
>   		if (PageTransHuge(page)) {
>   			low_pfn += (1 << compound_order(page)) - 1;
> -			continue;
> +			goto next;
>   		}
>
>   		lruvec = mem_cgroup_page_lruvec(page, zone);
>
>   		/* Try isolate the page */
>   		if (__isolate_lru_page(page, mode) != 0)
> -			continue;
> +			goto next;
>
>   		VM_BUG_ON_PAGE(PageTransCompound(page), page);
>
> @@ -669,6 +669,24 @@ isolate_success:
>
>   next_pageblock:
>   		low_pfn = ALIGN(low_pfn + 1, pageblock_nr_pages) - 1;
> +
> +next:
> +		/*
> +		 * It is too expensive for compaction to migrate pages from a
> +		 * pageblock for thp page faults unless the entire pageblock
> +		 * will become free.
> +		 */
> +		if ((cc->gfp_mask & __GFP_NO_KSWAPD) &&
> +		    !(current->flags & PF_KTHREAD)) {
> +			if (locked) {
> +				spin_unlock_irqrestore(&zone->lru_lock, flags);
> +				locked = false;
> +			}
> +			putback_movable_pages(migratelist);
> +			cc->nr_migratepages = 0;
> +			nr_isolated = 0;
> +			low_pfn = ALIGN(low_pfn + 1, pageblock_nr_pages) - 1;
> +		}
>   	}
>
>   	acct_isolated(zone, locked, cc);
> @@ -880,7 +898,7 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
>
>   	cc->migrate_pfn = low_pfn;
>
> -	return ISOLATE_SUCCESS;
> +	return cc->nr_migratepages ? ISOLATE_SUCCESS : ISOLATE_NONE;
>   }
>
>   static int compact_finished(struct zone *zone, struct compact_control *cc,
> @@ -1055,9 +1073,6 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
>   			;
>   		}
>
> -		if (!cc->nr_migratepages)
> -			continue;
> -
>   		err = migrate_pages(&cc->migratepages, compaction_alloc,
>   				compaction_free, (unsigned long)cc, cc->mode,
>   				MR_COMPACTION);
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
