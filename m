Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id E0F726B002B
	for <linux-mm@kvack.org>; Fri,  9 Nov 2012 07:16:05 -0500 (EST)
Date: Fri, 9 Nov 2012 12:16:02 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH v11 4/7] mm: introduce compaction and migration for
 ballooned pages
Message-ID: <20121109121602.GQ3886@csn.ul.ie>
References: <cover.1352256081.git.aquini@redhat.com>
 <08be4346b620ae9344691cc6c2ad0bc51f492e01.1352256088.git.aquini@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <08be4346b620ae9344691cc6c2ad0bc51f492e01.1352256088.git.aquini@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rafael Aquini <aquini@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, Rusty Russell <rusty@rustcorp.com.au>, "Michael S. Tsirkin" <mst@redhat.com>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Minchan Kim <minchan@kernel.org>, Peter Zijlstra <peterz@infradead.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

On Wed, Nov 07, 2012 at 01:05:51AM -0200, Rafael Aquini wrote:
> Memory fragmentation introduced by ballooning might reduce significantly
> the number of 2MB contiguous memory blocks that can be used within a guest,
> thus imposing performance penalties associated with the reduced number of
> transparent huge pages that could be used by the guest workload.
> 
> This patch introduces the helper functions as well as the necessary changes
> to teach compaction and migration bits how to cope with pages which are
> part of a guest memory balloon, in order to make them movable by memory
> compaction procedures.
> 
> Signed-off-by: Rafael Aquini <aquini@redhat.com>
> ---
>  mm/compaction.c | 21 +++++++++++++++++++--
>  mm/migrate.c    | 36 ++++++++++++++++++++++++++++++++++--
>  2 files changed, 53 insertions(+), 4 deletions(-)
> 
> diff --git a/mm/compaction.c b/mm/compaction.c
> index 9eef558..76abd84 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -14,6 +14,7 @@
>  #include <linux/backing-dev.h>
>  #include <linux/sysctl.h>
>  #include <linux/sysfs.h>
> +#include <linux/balloon_compaction.h>
>  #include "internal.h"
>  
>  #if defined CONFIG_COMPACTION || defined CONFIG_CMA
> @@ -565,9 +566,24 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
>  			goto next_pageblock;
>  		}
>  
> -		/* Check may be lockless but that's ok as we recheck later */
> -		if (!PageLRU(page))
> +		/*
> +		 * Check may be lockless but that's ok as we recheck later.
> +		 * It's possible to migrate LRU pages and balloon pages
> +		 * Skip any other type of page
> +		 */
> +		if (!PageLRU(page)) {
> +			if (unlikely(balloon_page_movable(page))) {

Because it's lockless, it really seems that the barrier stuck down there
is unnecessary. At worst you get a temporarily incorrect answer that you
recheck later under page lock in balloon_page_isolate.

> +				if (locked && balloon_page_isolate(page)) {
> +					/* Successfully isolated */
> +					cc->finished_update_migrate = true;
> +					list_add(&page->lru, migratelist);
> +					cc->nr_migratepages++;
> +					nr_isolated++;
> +					goto check_compact_cluster;
> +				}
> +			}
>  			continue;
> +		}
>  
>  		/*
>  		 * PageLRU is set. lru_lock normally excludes isolation
> @@ -621,6 +637,7 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
>  		cc->nr_migratepages++;
>  		nr_isolated++;
>  
> +check_compact_cluster:
>  		/* Avoid isolating too much */
>  		if (cc->nr_migratepages == COMPACT_CLUSTER_MAX) {
>  			++low_pfn;
> diff --git a/mm/migrate.c b/mm/migrate.c
> index 98c7a89..87ffe54 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -35,6 +35,7 @@
>  #include <linux/hugetlb.h>
>  #include <linux/hugetlb_cgroup.h>
>  #include <linux/gfp.h>
> +#include <linux/balloon_compaction.h>
>  
>  #include <asm/tlbflush.h>
>  
> @@ -79,7 +80,10 @@ void putback_lru_pages(struct list_head *l)
>  		list_del(&page->lru);
>  		dec_zone_page_state(page, NR_ISOLATED_ANON +
>  				page_is_file_cache(page));
> -		putback_lru_page(page);
> +		if (unlikely(balloon_page_movable(page)))
> +			balloon_page_putback(page);
> +		else
> +			putback_lru_page(page);
>  	}
>  }
>  
> @@ -778,6 +782,18 @@ static int __unmap_and_move(struct page *page, struct page *newpage,
>  		}
>  	}
>  
> +	if (unlikely(balloon_page_movable(page))) {
> +		/*
> +		 * A ballooned page does not need any special attention from
> +		 * physical to virtual reverse mapping procedures.
> +		 * Skip any attempt to unmap PTEs or to remap swap cache,
> +		 * in order to avoid burning cycles at rmap level, and perform
> +		 * the page migration right away (proteced by page lock).
> +		 */
> +		rc = balloon_page_migrate(newpage, page, mode);
> +		goto uncharge;
> +	}
> +
>  	/*
>  	 * Corner case handling:
>  	 * 1. When a new swap-cache page is read into, it is added to the LRU
> @@ -814,7 +830,9 @@ skip_unmap:
>  		put_anon_vma(anon_vma);
>  
>  uncharge:
> -	mem_cgroup_end_migration(mem, page, newpage, rc == MIGRATEPAGE_SUCCESS);
> +	mem_cgroup_end_migration(mem, page, newpage,
> +				 (rc == MIGRATEPAGE_SUCCESS ||
> +				  rc == MIGRATEPAGE_BALLOON_SUCCESS));
>  unlock:
>  	unlock_page(page);
>  out:
> @@ -846,6 +864,20 @@ static int unmap_and_move(new_page_t get_new_page, unsigned long private,
>  			goto out;
>  
>  	rc = __unmap_and_move(page, newpage, force, offlining, mode);
> +
> +	if (unlikely(rc == MIGRATEPAGE_BALLOON_SUCCESS)) {
> +		/*
> +		 * A ballooned page has been migrated already.
> +		 * Now, it's the time to remove the old page from the isolated
> +		 * pageset list and handle it back to Buddy, wrap-up counters
> +		 * and return.
> +		 */
> +		dec_zone_page_state(page, NR_ISOLATED_ANON +
> +				    page_is_file_cache(page));
> +		put_page(page);
> +		__free_page(page);
> +		return 0;
> +	}
>  out:
>  	if (rc != -EAGAIN) {
>  		/*

It may be necessary to make this more generic for migration-related
callbacks but I see nothing incompatible in your patch with doing that.
Doing the abstraction now would be overkill so

Acked-by: Mel Gorman <mel@csn.ul.ie>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
