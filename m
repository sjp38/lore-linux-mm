Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f43.google.com (mail-pb0-f43.google.com [209.85.160.43])
	by kanga.kvack.org (Postfix) with ESMTP id B3E086B003C
	for <linux-mm@kvack.org>; Mon, 12 May 2014 20:42:21 -0400 (EDT)
Received: by mail-pb0-f43.google.com with SMTP id up15so284683pbc.30
        for <linux-mm@kvack.org>; Mon, 12 May 2014 17:42:21 -0700 (PDT)
Received: from lgeamrelo01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id sr9si11520246pab.7.2014.05.12.17.42.19
        for <linux-mm@kvack.org>;
        Mon, 12 May 2014 17:42:20 -0700 (PDT)
Date: Tue, 13 May 2014 09:44:10 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH] mm, compaction: properly signal and act upon lock and
 need_sched() contention
Message-ID: <20140513004410.GA23803@js1304-P5Q-DELUXE>
References: <20140508051747.GA9161@js1304-P5Q-DELUXE>
 <1399904111-23520-1-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1399904111-23520-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Greg Thelen <gthelen@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>

On Mon, May 12, 2014 at 04:15:11PM +0200, Vlastimil Babka wrote:
> Compaction uses compact_checklock_irqsave() function to periodically check for
> lock contention and need_resched() to either abort async compaction, or to
> free the lock, schedule and retake the lock. When aborting, cc->contended is
> set to signal the contended state to the caller. Two problems have been
> identified in this mechanism.
> 
> First, compaction also calls directly cond_resched() in both scanners when no
> lock is yet taken. This call either does not abort async compaction, or set
> cc->contended appropriately. This patch introduces a new
> compact_check_resched() function to achieve both.
> 
> Second, isolate_freepages() does not check if isolate_freepages_block()
> aborted due to contention, and advances to the next pageblock. This violates
> the principle of aborting on contention, and might result in pageblocks not
> being scanned completely, since the scanning cursor is advanced. This patch
> makes isolate_freepages_block() check the cc->contended flag and abort.
> 
> Reported-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
> Cc: Michal Nazarewicz <mina86@mina86.com>
> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: Christoph Lameter <cl@linux.com>
> Cc: Rik van Riel <riel@redhat.com>
> ---
>  mm/compaction.c | 40 +++++++++++++++++++++++++++++++++-------
>  1 file changed, 33 insertions(+), 7 deletions(-)
> 
> diff --git a/mm/compaction.c b/mm/compaction.c
> index 83ca6f9..b34ab7c 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -222,6 +222,27 @@ static bool compact_checklock_irqsave(spinlock_t *lock, unsigned long *flags,
>  	return true;
>  }
>  
> +/*
> + * Similar to compact_checklock_irqsave() (see its comment) for places where
> + * a zone lock is not concerned.
> + *
> + * Returns false when compaction should abort.
> + */
> +static inline bool compact_check_resched(struct compact_control *cc)
> +{
> +	/* async compaction aborts if contended */
> +	if (need_resched()) {
> +		if (cc->mode == MIGRATE_ASYNC) {
> +			cc->contended = true;
> +			return false;
> +		}
> +
> +		cond_resched();
> +	}
> +
> +	return true;
> +}
> +
>  /* Returns true if the page is within a block suitable for migration to */
>  static bool suitable_migration_target(struct page *page)
>  {
> @@ -491,11 +512,8 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
>  			return 0;
>  	}
>  
> -	if (cond_resched()) {
> -		/* Async terminates prematurely on need_resched() */
> -		if (cc->mode == MIGRATE_ASYNC)
> -			return 0;
> -	}
> +	if (!compact_check_resched(cc))
> +		return 0;
>  
>  	/* Time to isolate some pages for migration */
>  	for (; low_pfn < end_pfn; low_pfn++) {
> @@ -718,9 +736,10 @@ static void isolate_freepages(struct zone *zone,
>  		/*
>  		 * This can iterate a massively long zone without finding any
>  		 * suitable migration targets, so periodically check if we need
> -		 * to schedule.
> +		 * to schedule, or even abort async compaction.
>  		 */
> -		cond_resched();
> +		if (!compact_check_resched(cc))
> +			break;
>  
>  		if (!pfn_valid(block_start_pfn))
>  			continue;
> @@ -758,6 +777,13 @@ static void isolate_freepages(struct zone *zone,
>  		 */
>  		if (isolated)
>  			cc->finished_update_free = true;
> +
> +		/*
> +		 * isolate_freepages_block() might have aborted due to async
> +		 * compaction being contended
> +		 */
> +		if (cc->contended)
> +			break;
>  	}

Hello,

I think that we can do further.

The problem is that this cc->contended is checked only in
isolate_migratepages() to break out the compaction. So if there are
free pages we are already taken, compaction wouldn't stopped
immediately and isolate_freepages() could be invoked again on next
compaction_alloc(). If there is no contention at this time, we would try
to get free pages from one pageblock because cc->contended checking is
on bottom of the loop in isolate_migratepages() and will continue to
run compaction. AFAIK, we want to stop the compaction in this case. 

Moreover, if this isolate_freepages() don't stop the compaction,
next isolate_migratepages() will be invoked and it would be stopped
by checking cc->contended after isolating some pages for migration.
This is useless overhead so should be removed.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
