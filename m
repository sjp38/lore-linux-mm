Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id DE08B6B0005
	for <linux-mm@kvack.org>; Thu, 14 Apr 2016 19:25:02 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id a140so4746437wma.1
        for <linux-mm@kvack.org>; Thu, 14 Apr 2016 16:25:02 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id jp6si31690978wjc.223.2016.04.14.16.25.01
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 14 Apr 2016 16:25:01 -0700 (PDT)
Subject: Re: mmotm woes, mainly compaction
References: <alpine.LSU.2.11.1604120005350.1832@eggly.anvils>
 <20160412121020.GC10771@dhcp22.suse.cz>
 <alpine.LSU.2.11.1604141114290.1086@eggly.anvils>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <571026CA.6000708@suse.cz>
Date: Fri, 15 Apr 2016 01:24:58 +0200
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.11.1604141114290.1086@eggly.anvils>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 04/14/2016 10:15 PM, Hugh Dickins wrote:
> ... because the thing that was really wrong (and I spent far too long
> studying compaction.c before noticing in page_alloc.c) was this:
>
> 	/*
> 	 * It can become very expensive to allocate transparent hugepages at
> 	 * fault, so use asynchronous memory compaction for THP unless it is
> 	 * khugepaged trying to collapse.
> 	 */
> 	if (!is_thp_gfp_mask(gfp_mask) || (current->flags & PF_KTHREAD))
> 		migration_mode = MIGRATE_SYNC_LIGHT;
>
> Yes, but advancing migration_mode before should_compact_retry() checks
> whether it was MIGRATE_ASYNC, so eliminating the retry when MIGRATE_ASYNC
> compaction_failed().  And the bogus *migrate_mode++ code had appeared to
> work by interposing an additional state for a retry.

Ouch. But AFAICS the is_thp_gfp_mask() path is already addressed properly in 
Michal's latest versions of the patches (patch 10/11 of "[PATCH 00/11] oom 
detection rework v5"). So that wasn't what you tested this time? Maybe mmotm 
still had the older version... But I guess Michal will know better than me.

> So all I had to do to get OOM-free results, on both machines, was to
> remove those lines quoted above.  Now, no doubt it's wrong (for THP)
> to remove them completely, but I don't want to second-guess you on
> where to do the equivalent check: over to you for that.
>
> I'm over-optimistic when I say OOM-free: on the G5 yes; but I did
> see an order=2 OOM after an hour on the laptop one time, and much
> sooner when I applied your further three patches (classzone_idx etc),
> again on the laptop, on one occasion but not another.  Something not
> quite right, but much easier to live with than before, and will need
> a separate tedious investigation if it persists.
>
> Earlier on, when all my suspicions were in compaction.c, I did make a
> couple of probable fixes there, though neither helped out of my OOMs:
>
> At present MIGRATE_SYNC_LIGHT is allowing __isolate_lru_page() to
> isolate a PageWriteback page, which __unmap_and_move() then rejects
> with -EBUSY: of course the writeback might complete in between, but
> that's not what we usually expect, so probably better not to isolate it.
>
> And where compact_zone() sets whole_zone, I tried a BUG_ON if
> compact_scanners_met() already, and hit that as a real possibility
> (only when compactors competing perhaps): without the BUG_ON, it
> would proceed to compact_finished() COMPACT_COMPLETE without doing
> any work at all - and the new should_compact_retry() code is placing
> more faith in that compact_result than perhaps it deserves.  No need
> to BUG_ON then, just be stricter about setting whole_zone.

I warned Michal about the whole_zone settings being prone to races, thanks for 
confirming it's real. Although, compact_scanners_met() being immediately true, 
when the migration scanner is at the zone start, sounds really weird. That would 
mean the free scanner did previously advance as far as first pageblock to cache 
that pfn, which I wouldn't imagine except maybe a tiny zone... was it a 
ZONE_DMA? Or it's a sign of a larger issue.

Anyway, too bad fixing this didn't help the rare OOMs as that would be a 
perfectly valid reason for them.

> (I do worry about the skip hints: once in MIGRATE_SYNC_LIGHT mode,
> compaction seemed good at finding pages to migrate, but not so good
> at then finding enough free pages to migrate them into.  Perhaps
> there were none, but it left me suspicious.)

Skip hints could be another reason for the rare OOMs. What you describe sounds 
like the reclaim between async and sync_light compaction attempts did free some 
pages, but their pageblocks were not scanned due to the skip hints.
A test patch setting compact_control.ignore_skip_hint for sync_(light) 
compaction could confirm (or also mask, I'm afraid) the issue.

> Vlastimil, thanks so much for picking up my bits and pieces a couple
> of days ago: I think I'm going to impose upon you again with the below,
> if that's not too irritating.

No problem :)

> Signed-off-by: Hugh Dickins <hughd@google.com>
>
> --- 4.6-rc2-mm1/mm/compaction.c	2016-04-11 11:35:08.536604712 -0700
> +++ linux/mm/compaction.c	2016-04-13 23:17:03.671959715 -0700
> @@ -1190,7 +1190,7 @@ static isolate_migrate_t isolate_migrate
>   	struct page *page;
>   	const isolate_mode_t isolate_mode =
>   		(sysctl_compact_unevictable_allowed ? ISOLATE_UNEVICTABLE : 0) |
> -		(cc->mode == MIGRATE_ASYNC ? ISOLATE_ASYNC_MIGRATE : 0);
> +		(cc->mode != MIGRATE_SYNC ? ISOLATE_ASYNC_MIGRATE : 0);
>
>   	/*
>   	 * Start at where we last stopped, or beginning of the zone as

I'll check this optimization, thanks.

> @@ -1459,8 +1459,8 @@ static enum compact_result compact_zone(
>   		zone->compact_cached_migrate_pfn[1] = cc->migrate_pfn;
>   	}
>
> -	if (cc->migrate_pfn == start_pfn)
> -		cc->whole_zone = true;
> +	cc->whole_zone = cc->migrate_pfn == start_pfn &&
> +			cc->free_pfn == pageblock_start_pfn(end_pfn - 1);
>
>   	cc->last_migrated_pfn = 0;

This would be for Michal, but I agree.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
