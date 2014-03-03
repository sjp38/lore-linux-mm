Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id AFE516B0035
	for <linux-mm@kvack.org>; Mon,  3 Mar 2014 03:21:53 -0500 (EST)
Received: by mail-pd0-f173.google.com with SMTP id z10so3420564pdj.4
        for <linux-mm@kvack.org>; Mon, 03 Mar 2014 00:21:53 -0800 (PST)
Received: from lgeamrelo04.lge.com (lgeamrelo04.lge.com. [156.147.1.127])
        by mx.google.com with ESMTP id s1si9755236pav.335.2014.03.03.00.21.51
        for <linux-mm@kvack.org>;
        Mon, 03 Mar 2014 00:21:52 -0800 (PST)
Date: Mon, 3 Mar 2014 17:22:27 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 2/6] mm: add get_pageblock_migratetype_nolock() for cases
 where locking is undesirable
Message-ID: <20140303082227.GA28899@lge.com>
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

Hello, Vlastimil.

First of all, thanks for nice work!
I have another opinion about this implementation. It can be wrong, so if it
is wrong, please let me know.

Although this implementation would close the race which triggers NULL dereference,
I think that this isn't enough if you have a plan to add more
{start,undo}_isolate_page_range().

Consider that there are lots of {start,undo}_isolate_page_range() calls
on the system without CMA.

bit representation of migratetype is like as following.

MIGRATE_MOVABLE = 010
MIGRATE_ISOLATE = 100

We could read following values as migratetype of the page on movable pageblock
if race occurs.

start_isolate_page_range() case: 010 -> 100
010, 000, 100

undo_isolate_page_range() case: 100 -> 010
100, 110, 010

Above implementation prevents us from getting 110, but, it can't prevent us from
getting 000, that is, MIGRATE_UNMOVABLE. If this race occurs in free_hot_cold_page(),
this page would go into unmovable pcp and then allocated for that migratetype.
It results in more fragmented memory.


Consider another case that system enables CONFIG_CMA,

MIGRATE_MOVABLE = 010
MIGRATE_ISOLATE = 101

start_isolate_page_range() case: 010 -> 101
010, 011, 001, 101

undo_isolate_page_range() case: 101 -> 010
101, 100, 110, 010

This can results in totally different values and this also makes the problem
mentioned above. And, although this doesn't cause any problem on CMA for now,
if another migratetype is introduced or some migratetype is removed, it can cause
CMA typed page to go into other migratetype and makes CMA permanently failed.

To close this kind of races without dependency how many pageblock isolation occurs,
I recommend that you use separate pageblock bits for MIGRATE_CMA, MIGRATE_ISOLATE
and use accessor function whenver we need to check migratetype. IMHO, it may not
impose much overhead.

How about it?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
