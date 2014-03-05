Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id AFB726B0071
	for <linux-mm@kvack.org>; Tue,  4 Mar 2014 19:37:12 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id hz1so301321pad.35
        for <linux-mm@kvack.org>; Tue, 04 Mar 2014 16:37:12 -0800 (PST)
Received: from LGEAMRELO02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id ub8si490085pac.155.2014.03.04.16.37.10
        for <linux-mm@kvack.org>;
        Tue, 04 Mar 2014 16:37:11 -0800 (PST)
Date: Wed, 5 Mar 2014 09:37:10 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 2/6] mm: add get_pageblock_migratetype_nolock() for cases
 where locking is undesirable
Message-ID: <20140305003709.GB2340@lge.com>
References: <1393596904-16537-1-git-send-email-vbabka@suse.cz>
 <1393596904-16537-3-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1393596904-16537-3-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Fri, Feb 28, 2014 at 03:15:00PM +0100, Vlastimil Babka wrote:
> In order to prevent race with set_pageblock_migratetype, most of calls to
> get_pageblock_migratetype have been moved under zone->lock. For the remaining
> call sites, the extra locking is undesirable, notably in free_hot_cold_page().
> 
> This patch introduces a _nolock version to be used on these call sites, where
> a wrong value does not affect correctness. The function makes sure that the
> value does not exceed valid migratetype numbers. Such too-high values are
> assumed to be a result of race and caller-supplied fallback value is returned
> instead.
> 
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> ---
>  include/linux/mmzone.h | 24 ++++++++++++++++++++++++
>  mm/compaction.c        | 14 +++++++++++---
>  mm/memory-failure.c    |  3 ++-
>  mm/page_alloc.c        | 22 +++++++++++++++++-----
>  mm/vmstat.c            |  2 +-
>  5 files changed, 55 insertions(+), 10 deletions(-)
> 
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index fac5509..7c3f678 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -75,6 +75,30 @@ enum {
>  
>  extern int page_group_by_mobility_disabled;
>  
> +/*
> + * When called without zone->lock held, a race with set_pageblock_migratetype
> + * may result in bogus values. Use this variant only when this does not affect
> + * correctness, and taking zone->lock would be costly. Values >= MIGRATE_TYPES
> + * are considered to be a result of this race and the value of race_fallback
> + * argument is returned instead.
> + */
> +static inline int get_pageblock_migratetype_nolock(struct page *page,
> +	int race_fallback)
> +{
> +	int ret = get_pageblock_flags_group(page, PB_migrate, PB_migrate_end);
> +
> +	if (unlikely(ret >= MIGRATE_TYPES))
> +		ret = race_fallback;
> +
> +	return ret;
> +}

How about below forms?

get_pageblock_migratetype_locked(struct page *page)
get_pageblock_migratetype(struct page *page, int race_fallback)

get_pageblock_migratetype() and _nolock looks error-prone because developer
who try to use get_pageblock_migratetype() may not know that it needs lock.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
