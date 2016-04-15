Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 301CC6B0005
	for <linux-mm@kvack.org>; Thu, 14 Apr 2016 21:00:15 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id t124so159122126pfb.1
        for <linux-mm@kvack.org>; Thu, 14 Apr 2016 18:00:15 -0700 (PDT)
Received: from mail-pf0-x229.google.com (mail-pf0-x229.google.com. [2607:f8b0:400e:c00::229])
        by mx.google.com with ESMTPS id i22si10176878pfj.249.2016.04.14.18.00.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Apr 2016 18:00:11 -0700 (PDT)
Received: by mail-pf0-x229.google.com with SMTP id e128so51082080pfe.3
        for <linux-mm@kvack.org>; Thu, 14 Apr 2016 18:00:11 -0700 (PDT)
Date: Thu, 14 Apr 2016 18:00:03 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: mmotm woes, mainly compaction
In-Reply-To: <571026CA.6000708@suse.cz>
Message-ID: <alpine.LSU.2.11.1604141727230.2690@eggly.anvils>
References: <alpine.LSU.2.11.1604120005350.1832@eggly.anvils> <20160412121020.GC10771@dhcp22.suse.cz> <alpine.LSU.2.11.1604141114290.1086@eggly.anvils> <571026CA.6000708@suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 15 Apr 2016, Vlastimil Babka wrote:
> On 04/14/2016 10:15 PM, Hugh Dickins wrote:
> > ... because the thing that was really wrong (and I spent far too long
> > studying compaction.c before noticing in page_alloc.c) was this:
> > 
> > 	/*
> > 	 * It can become very expensive to allocate transparent hugepages at
> > 	 * fault, so use asynchronous memory compaction for THP unless it is
> > 	 * khugepaged trying to collapse.
> > 	 */
> > 	if (!is_thp_gfp_mask(gfp_mask) || (current->flags & PF_KTHREAD))
> > 		migration_mode = MIGRATE_SYNC_LIGHT;
> > 
> > Yes, but advancing migration_mode before should_compact_retry() checks
> > whether it was MIGRATE_ASYNC, so eliminating the retry when MIGRATE_ASYNC
> > compaction_failed().  And the bogus *migrate_mode++ code had appeared to
> > work by interposing an additional state for a retry.
> 
> Ouch. But AFAICS the is_thp_gfp_mask() path is already addressed properly in
> Michal's latest versions of the patches (patch 10/11 of "[PATCH 00/11] oom
> detection rework v5"). So that wasn't what you tested this time? Maybe mmotm
> still had the older version... But I guess Michal will know better than me.

What I've been testing is mmotm 2016-04-06-20-40, but (unsurprisingly)
linux next-20160414 is the same here.  I think these were based on
Michal's oom detection rework v5.

This muckup is probably a relic from when Andrew had to resolve the
conflict between Michal's 10/11 and my 30/31: I thought we reverted
to Michal's as is here, that was the intention; but maybe there was
a misunderstanding and this block got left behind.

But I don't think it's causing trouble at the moment for anyone but me,
I being the one with the order=2 OOMs nobody else could see (though
I'm not sure what happened to Sergey's).

> > 
> > And where compact_zone() sets whole_zone, I tried a BUG_ON if
> > compact_scanners_met() already, and hit that as a real possibility
> > (only when compactors competing perhaps): without the BUG_ON, it
> > would proceed to compact_finished() COMPACT_COMPLETE without doing
> > any work at all - and the new should_compact_retry() code is placing
> > more faith in that compact_result than perhaps it deserves.  No need
> > to BUG_ON then, just be stricter about setting whole_zone.
> 
> I warned Michal about the whole_zone settings being prone to races, thanks
> for confirming it's real. Although, compact_scanners_met() being immediately
> true, when the migration scanner is at the zone start, sounds really weird.
> That would mean the free scanner did previously advance as far as first
> pageblock to cache that pfn, which I wouldn't imagine except maybe a tiny
> zone... was it a ZONE_DMA? Or it's a sign of a larger issue.

I am constraining with mem=700M to do this swap testing (and all in the
one zone): smallish, but not tiny.

There is no locking when cc->migrate_pfn and cc->free_pfn are initialized
from zone->compact_cached*, so I assumed (but did not check) that it was
a consequence of a racing compactor updating zone->compact_cached_free_pfn
to the low pfn at an awkward moment; and separately I did see evidence of
the search for free sometimes skipping down lots of pageblocks, finding
too few pages free to place all the 32 migration candidates selected.
But I'm not at all familiar with the expectations here.

> 
> Anyway, too bad fixing this didn't help the rare OOMs as that would be a
> perfectly valid reason for them.
> 
> > (I do worry about the skip hints: once in MIGRATE_SYNC_LIGHT mode,
> > compaction seemed good at finding pages to migrate, but not so good
> > at then finding enough free pages to migrate them into.  Perhaps
> > there were none, but it left me suspicious.)
> 
> Skip hints could be another reason for the rare OOMs. What you describe
> sounds like the reclaim between async and sync_light compaction attempts did
> free some pages, but their pageblocks were not scanned due to the skip hints.
> A test patch setting compact_control.ignore_skip_hint for sync_(light)
> compaction could confirm (or also mask, I'm afraid) the issue.

Yes, at one stage I simply #ifdef'ed out respect for the skip hints.
But as soon as I'd found the real offender, I undid that hack and was
glad to find it was not needed - apart perhaps from those "rare OOMs":
I have no picture yet of how much of an issue they are (and since
I only saw them on the laptop from which I am replying to you,
and prefer not to be running a heavy swapping load while typing,
my testing is and will ever be very intermittent).

> 
> > Vlastimil, thanks so much for picking up my bits and pieces a couple
> > of days ago: I think I'm going to impose upon you again with the below,
> > if that's not too irritating.
> 
> No problem :)

Thanks!

> 
> > Signed-off-by: Hugh Dickins <hughd@google.com>
> > 
> > --- 4.6-rc2-mm1/mm/compaction.c	2016-04-11 11:35:08.536604712 -0700
> > +++ linux/mm/compaction.c	2016-04-13 23:17:03.671959715 -0700
> > @@ -1190,7 +1190,7 @@ static isolate_migrate_t isolate_migrate
> >   	struct page *page;
> >   	const isolate_mode_t isolate_mode =
> >   		(sysctl_compact_unevictable_allowed ? ISOLATE_UNEVICTABLE :
> > 0) |
> > -		(cc->mode == MIGRATE_ASYNC ? ISOLATE_ASYNC_MIGRATE : 0);
> > +		(cc->mode != MIGRATE_SYNC ? ISOLATE_ASYNC_MIGRATE : 0);
> > 
> >   	/*
> >   	 * Start at where we last stopped, or beginning of the zone as
> 
> I'll check this optimization, thanks.

Yes, please do (in /proc/vmstat, I could see the ratio of pgmigrate_success
to _fail go up, but the ratio of compact_migrate_scanned to _isolated go up).

> 
> > @@ -1459,8 +1459,8 @@ static enum compact_result compact_zone(
> >   		zone->compact_cached_migrate_pfn[1] = cc->migrate_pfn;
> >   	}
> > 
> > -	if (cc->migrate_pfn == start_pfn)
> > -		cc->whole_zone = true;
> > +	cc->whole_zone = cc->migrate_pfn == start_pfn &&
> > +			cc->free_pfn == pageblock_start_pfn(end_pfn - 1);
> > 
> >   	cc->last_migrated_pfn = 0;
> 
> This would be for Michal, but I agree.

Okay, thanks.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
