Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id F10C36B0044
	for <linux-mm@kvack.org>; Fri, 21 Sep 2012 17:35:58 -0400 (EDT)
Date: Fri, 21 Sep 2012 14:35:57 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 6/9] mm: compaction: Acquire the zone->lock as late as
 possible
Message-Id: <20120921143557.fe490819.akpm@linux-foundation.org>
In-Reply-To: <1348224383-1499-7-git-send-email-mgorman@suse.de>
References: <1348224383-1499-1-git-send-email-mgorman@suse.de>
	<1348224383-1499-7-git-send-email-mgorman@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Richard Davies <richard@arachsys.com>, Shaohua Li <shli@kernel.org>, Rik van Riel <riel@redhat.com>, Avi Kivity <avi@redhat.com>, QEMU-devel <qemu-devel@nongnu.org>, KVM <kvm@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, 21 Sep 2012 11:46:20 +0100
Mel Gorman <mgorman@suse.de> wrote:

> Compactions free scanner acquires the zone->lock when checking for PageBuddy
> pages and isolating them. It does this even if there are no PageBuddy pages
> in the range.
> 
> This patch defers acquiring the zone lock for as long as possible. In the
> event there are no free pages in the pageblock then the lock will not be
> acquired at all which reduces contention on zone->lock.
>
> ...
>
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -93,6 +93,28 @@ static inline bool compact_trylock_irqsave(spinlock_t *lock,
>  	return compact_checklock_irqsave(lock, flags, false, cc);
>  }
>  
> +/* Returns true if the page is within a block suitable for migration to */
> +static bool suitable_migration_target(struct page *page)
> +{
> +

stray newline

> +	int migratetype = get_pageblock_migratetype(page);
> +
> +	/* Don't interfere with memory hot-remove or the min_free_kbytes blocks */
> +	if (migratetype == MIGRATE_ISOLATE || migratetype == MIGRATE_RESERVE)
> +		return false;
> +
> +	/* If the page is a large free page, then allow migration */
> +	if (PageBuddy(page) && page_order(page) >= pageblock_order)
> +		return true;
> +
> +	/* If the block is MIGRATE_MOVABLE or MIGRATE_CMA, allow migration */
> +	if (migrate_async_suitable(migratetype))
> +		return true;
> +
> +	/* Otherwise skip the block */
> +	return false;
> +}
> +
>
> ...
>
> @@ -168,23 +193,38 @@ static unsigned long isolate_freepages_block(unsigned long blockpfn,
>  		int isolated, i;
>  		struct page *page = cursor;
>  
> -		if (!pfn_valid_within(blockpfn)) {
> -			if (strict)
> -				return 0;
> -			continue;
> -		}
> +		if (!pfn_valid_within(blockpfn))
> +			goto strict_check;
>  		nr_scanned++;
>  
> -		if (!PageBuddy(page)) {
> -			if (strict)
> -				return 0;
> -			continue;
> -		}
> +		if (!PageBuddy(page))
> +			goto strict_check;
> +
> +		/*
> +		 * The zone lock must be held to isolate freepages. This
> +		 * unfortunately this is a very coarse lock and can be

this this

> +		 * heavily contended if there are parallel allocations
> +		 * or parallel compactions. For async compaction do not
> +		 * spin on the lock and we acquire the lock as late as
> +		 * possible.
> +		 */
> +		locked = compact_checklock_irqsave(&cc->zone->lock, &flags,
> +								locked, cc);
> +		if (!locked)
> +			break;
> +
> +		/* Recheck this is a suitable migration target under lock */
> +		if (!strict && !suitable_migration_target(page))
> +			break;
> +
> +		/* Recheck this is a buddy page under lock */
> +		if (!PageBuddy(page))
> +			goto strict_check;
>  
>  		/* Found a free page, break it into order-0 pages */
>  		isolated = split_free_page(page);
>  		if (!isolated && strict)
> -			return 0;
> +			goto strict_check;
>  		total_isolated += isolated;
>  		for (i = 0; i < isolated; i++) {
>  			list_add(&page->lru, freelist);
> @@ -196,9 +236,23 @@ static unsigned long isolate_freepages_block(unsigned long blockpfn,
>  			blockpfn += isolated - 1;
>  			cursor += isolated - 1;
>  		}
> +
> +		continue;
> +
> +strict_check:
> +		/* Abort isolation if the caller requested strict isolation */
> +		if (strict) {
> +			total_isolated = 0;
> +			goto out;
> +		}
>  	}
>  
>  	trace_mm_compaction_isolate_freepages(nr_scanned, total_isolated);
> +
> +out:
> +	if (locked)
> +		spin_unlock_irqrestore(&cc->zone->lock, flags);
> +
>  	return total_isolated;
>  }

A a few things about this function.

Would it be cleaner if we did

	if (!strict) {
		if (!suitable_migration_target(page))
			break;
	} else {
		if (!PageBuddy(page))
			goto strict_check;
	}

and then remove the test of `strict' from strict_check (which then
should be renamed)?

Which perhaps means that the whole `strict_check' block can go away:

	if (!strict) {
		if (!suitable_migration_target(page))
			break;
	} else {
		if (!PageBuddy(page)) {
			total_isolated = 0;
			goto out;
	}

Have a think about it?  The function is a little straggly.

Secondly, it is correct/desirable to skip the (now misnamed
`trace_mm_compaction_isolate_freepages') tracepoint generation if we
baled out of the loop?  The fact that we entered
isolate_freepages_block() but failed to isolate anything is data which
people might be interested in?

Thirdly, that (existing) comment "This assumes the block is valid" is
either too vague or wrong.  If it's valid, why wo we check
pfn_valid_within()?

> @@ -218,13 +272,18 @@ static unsigned long isolate_freepages_block(unsigned long blockpfn,
>  unsigned long
>  isolate_freepages_range(unsigned long start_pfn, unsigned long end_pfn)
>  {
> -	unsigned long isolated, pfn, block_end_pfn, flags;
> +	unsigned long isolated, pfn, block_end_pfn;
>  	struct zone *zone = NULL;
>  	LIST_HEAD(freelist);
> +	struct compact_control cc;
>  
>  	if (pfn_valid(start_pfn))
>  		zone = page_zone(pfn_to_page(start_pfn));
>  
> +	/* cc needed for isolate_freepages_block to acquire zone->lock */
> +	cc.zone = zone;
> +	cc.sync = true;

We initialise two of cc's fields, leave the other 12 fields containing
random garbage, then start using it.  I see no bug here, but...


>  	for (pfn = start_pfn; pfn < end_pfn; pfn += isolated) {
>  		if (!pfn_valid(pfn) || zone != page_zone(pfn_to_page(pfn)))
>  			break;
> ...
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
