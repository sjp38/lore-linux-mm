Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f178.google.com (mail-ig0-f178.google.com [209.85.213.178])
	by kanga.kvack.org (Postfix) with ESMTP id F0D896B0092
	for <linux-mm@kvack.org>; Wed,  4 Jun 2014 19:46:21 -0400 (EDT)
Received: by mail-ig0-f178.google.com with SMTP id h18so1678067igc.17
        for <linux-mm@kvack.org>; Wed, 04 Jun 2014 16:46:21 -0700 (PDT)
Received: from mail-ig0-x233.google.com (mail-ig0-x233.google.com [2607:f8b0:4001:c05::233])
        by mx.google.com with ESMTPS id x3si31009952igl.24.2014.06.04.16.46.21
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 04 Jun 2014 16:46:21 -0700 (PDT)
Received: by mail-ig0-f179.google.com with SMTP id hn18so1684843igb.12
        for <linux-mm@kvack.org>; Wed, 04 Jun 2014 16:46:21 -0700 (PDT)
Date: Wed, 4 Jun 2014 16:46:19 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC PATCH 2/6] mm, compaction: skip rechecks when lock was
 already held
In-Reply-To: <1401898310-14525-2-git-send-email-vbabka@suse.cz>
Message-ID: <alpine.DEB.2.02.1406041641330.18899@chino.kir.corp.google.com>
References: <alpine.DEB.2.02.1405211954410.13243@chino.kir.corp.google.com> <1401898310-14525-1-git-send-email-vbabka@suse.cz> <1401898310-14525-2-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>

On Wed, 4 Jun 2014, Vlastimil Babka wrote:

> diff --git a/mm/compaction.c b/mm/compaction.c
> index f0fd4b5..27c73d7 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -332,6 +332,16 @@ static unsigned long isolate_freepages_block(struct compact_control *cc,
>  			goto isolate_fail;
>  
>  		/*
> +		 * If we already hold the lock, we can skip some rechecking.
> +		 * Note that if we hold the lock now, checked_pageblock was
> +		 * already set in some previous iteration (or strict is true),
> +		 * so it is correct to skip the suitable migration target
> +		 * recheck as well.
> +		 */
> +		if (locked)
> +			goto skip_recheck;
> +
> +		/*
>  		 * The zone lock must be held to isolate freepages.
>  		 * Unfortunately this is a very coarse lock and can be
>  		 * heavily contended if there are parallel allocations
> @@ -339,9 +349,7 @@ static unsigned long isolate_freepages_block(struct compact_control *cc,
>  		 * spin on the lock and we acquire the lock as late as
>  		 * possible.
>  		 */
> -		if (!locked)
> -			locked = compact_trylock_irqsave(&cc->zone->lock,
> -								&flags, cc);
> +		locked = compact_trylock_irqsave(&cc->zone->lock, &flags, cc);
>  		if (!locked)
>  			break;
>  
> @@ -361,6 +369,7 @@ static unsigned long isolate_freepages_block(struct compact_control *cc,
>  		if (!PageBuddy(page))
>  			goto isolate_fail;
>  
> +skip_recheck:
>  		/* Found a free page, break it into order-0 pages */
>  		isolated = split_free_page(page);
>  		total_isolated += isolated;

This doesn't apply cleanly, you probably need Andrew's 
"mm/compaction.c:isolate_freepages_block(): small tuneup"?  Rebasing the 
series on -mm would probably be best.

> @@ -671,10 +680,11 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
>  		    page_count(page) > page_mapcount(page))
>  			continue;
>  
> -		/* If the lock is not held, try to take it */
> -		if (!locked)
> -			locked = compact_trylock_irqsave(&zone->lru_lock,
> -								&flags, cc);
> +		/* If we already hold the lock, we can skip some rechecking */
> +		if (locked)
> +			goto skip_recheck;
> +
> +		locked = compact_trylock_irqsave(&zone->lru_lock, &flags, cc);
>  		if (!locked)
>  			break;
>  
> @@ -686,6 +696,7 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
>  			continue;
>  		}
>  
> +skip_recheck:
>  		lruvec = mem_cgroup_page_lruvec(page, zone);
>  
>  		/* Try isolate the page */

Looks good.  I wonder how the lock-taking and the rechecks would look 
nested in a "if (!locked)" clause and whether that would be cleaner (and 
avoid the gotos), but I assume you already looked at that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
