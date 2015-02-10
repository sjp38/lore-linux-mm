Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id E0CC96B0032
	for <linux-mm@kvack.org>; Tue, 10 Feb 2015 03:52:16 -0500 (EST)
Received: by mail-pa0-f47.google.com with SMTP id lj1so39864697pab.6
        for <linux-mm@kvack.org>; Tue, 10 Feb 2015 00:52:16 -0800 (PST)
Received: from lgeamrelo04.lge.com (lgeamrelo04.lge.com. [156.147.1.127])
        by mx.google.com with ESMTP id u14si16826281pdi.101.2015.02.10.00.52.14
        for <linux-mm@kvack.org>;
        Tue, 10 Feb 2015 00:52:15 -0800 (PST)
Date: Tue, 10 Feb 2015 17:54:20 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [RFC PATCH 0/5] compaction: changing initial position of scanners
Message-ID: <20150210085420.GA29292@js1304-P5Q-DELUXE>
References: <1421661920-4114-1-git-send-email-vbabka@suse.cz>
 <20150203064941.GA9822@js1304-P5Q-DELUXE>
 <54D08F48.5030909@suse.cz>
 <CAAmzW4Oe+65bF5QQxTkJ72H4YpxmcxP0qSSdus6BmCspMyd1DA@mail.gmail.com>
 <54D0EE90.5030305@suse.cz>
 <CAAmzW4PRpQg871ymGQPsuht_j0+vyVo233gKhw3qvJS1WSu++Q@mail.gmail.com>
 <54D22F1D.6060906@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <54D22F1D.6060906@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Christoph Lameter <cl@linux.com>, Mel Gorman <mgorman@suse.de>, Michal Nazarewicz <mina86@mina86.com>, Minchan Kim <minchan@kernel.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Rik van Riel <riel@redhat.com>

On Wed, Feb 04, 2015 at 03:39:25PM +0100, Vlastimil Babka wrote:
> On 02/03/2015 06:07 PM, Joonsoo Kim wrote:
> >2015-02-04 0:51 GMT+09:00 Vlastimil Babka <vbabka@suse.cz>:
> >>Ah, I think I see where the misunderstanding comes from now. So to clarify,
> >>let's consider
> >>
> >>1. single compaction run - single invocation of compact_zone(). It can start
> >>from cached pfn's from previous run, or zone boundaries (or pivot, after this
> >>series), and terminate with scanners meeting or not meeting.
> >>
> >>2. full zone compaction - consists one or more compaction runs, where the first
> >>run starts at boundaries (pivot). It ends when scanners meet -
> >>compact_finished() returns COMPACT_COMPLETE
> >>
> >>3. compaction after full defer cycle - this is full zone compaction, where
> >>compaction_restarting() returns true in its first run
> >>
> >>My understanding is that you think pivot changing occurs after each full zone
> >>compaction (definition 2), but in fact it occurs only each defer cycle
> >>(definition 3). See patch 5 for detailed reasoning. I don't think it's short
> >>term. It means full zone compactions (def 2) already failed many times and then
> >>was deferred for further time, using the same unchanged pivot.
> >
> >Ah... thanks for clarifying. I actually think pivot changing occurs at
> >definition 2
> >as you guess. :)
> 
> Great it's clarified :)
> 
> >>I think any of the alternatives you suggested below where migrate scanner
> >>processes whole zone during full zone compaction (2), would necessarily result
> >>in shorter-term back and forth migration than this scheme. On the other hand,
> >>the pivot changing proposed here might be too long-term. But it's a first
> >>attempt, and the frequency can be further tuned.
> >
> >Yes, your proposal would be less problematic on back and forth problem than
> >my suggestion.
> >
> >Hmm...nevertheless, I can't completely agree with pivot approach.
> >
> >I'd like to remove dependency of migrate scanner and free scanner such as
> >termination criteria at this chance. Meeting position of both scanner is roughly
> 
> Well at some point compaction should terminate if it scanned the
> whole zone, and failed. How else to check that than using the
> scanner positions?

We can count number of pageblock we are scanning and if it matches
with zone span we can terminate.

> >determined by on amount of free memory in the zone. If 200 MB is free in
> >the zone, migrate scanner can scan at maximum 200 MB from the start pfn
> >of the pivot. Without changing pivot quickly, we can scan only
> >this region regardless zone size so it cause bad effect to high order
> >allocation for a long time.
> >
> >In stress-highalloc test, it doesn't matter since we try to attempt a lot of
> >allocations. This bad effect would not appear easily. Although middle of
> >allocation attempts are failed, latter attempts would succeed
> >since pivot would be changed in the middle of attempts.
> 
> OK, that might be true. It's not a perfect benchmark.
> 
> >But, in real world scenario, all allocation attempts are precise and
> >it'd be better
> >first come high order allocation request to succeed and this is another problem
> >than allocation success rate in stress-highalloc test. To accomplish it, we
> >need to change pivot as soon as possible. Without it, we could miss some
> >precise allocation attempt until pivot is changed. For this purpose, we should
> >remove defer logic or change it more loosely and then, resetting pivot would
> >occur soon so we could encounter back and forth problem frequently.
> 
> It seems to me that you can't have both the "migration scanner
> should try scanning whole zone during single compaction (or during
> relatively few attempts)" and "we shouldn't migrate pages that we
> have just (relatively recently) migrated", in any scheme including
> the two you proposed in previous mail. These features just go
> against each other.
> 
> In any scheme you should divide the zone between part that's scanned
> for pages to migrate from, and part that scanned for free pages as
> migration targets. If you don't divide, then you end up migrating
> back and forth instantly, which would be bad.

Okay. My proposal isn't perfect but it is just quick thought. :)
I hope that it is a seed for better idea, not the solution.
It may be true that we need to divide region for each scanner.

> 
> So what happens after you don't have any free pages in the part that
> was for the free scanner (this is what happen in current scheme when
> scanners meet). If you wanted to continue with the migration
> scanner, the only free pages are in the part which the migration
> scanner just processed. And funnily enough, the pivot changing
> scheme will put the free scanner just in the position to scan this
> part. But doing that immediately could mean excessive migration.
> 
> Your alternative scheme where free scanner follows the migration
> scanner at some distance is not very different in this sense. If you
> manage to tune the distance properly, you will also scan for free
> pages the part that was just processed by the migration scanner. It
> might be more efficient in that you don't rescan the part that the
> migration scanner didn't reach both before and after pivot change.
> But fundamentally, it means migrating pages that were recently
> migrated.

What I'm worrying about in pivot approach is that if pivot is changed
frequently due to burst of failed high order allocation or we decide
to make compaction aggressive, immediate migration back and forth
could happen. Isn't it the problem we need to consider here?

One of main difference of my approach is the direction of free scanner
and if we scan in same direction with migration scanner, we can
guarantees that certain migrated pages are migrated again as late as
possible. But, with reverse direction, it's not possible to keep this
order. See following example.

PIVOT(REVERSE DIRECTION)
|---1---2---3-----|------------------|
=> after compaction
|-----------------|---3---2---1------|
=> after pivot changed, #3 page which is migrated recently is migrated
first.

SAME DIRECTION
|---1---2---3-----|------------------|
=> after compaction
|-----------------|---1---2---3------|
=> we can keep the order of migratable pages.

I know that if we want to scan whole zone range, we can't avoid back
and forth migration. Best thing we can do is something like this that
preserve order of migration and my proposal aims at this purpose.

Thanks.

> >Therefore, it's better to change compaction logic more fundamentally.
> 
> Maybe it's indeed better to excessively migrate than keep rescanning
> the same pageblocks and then defer compaction. But we shouldn't
> forget that immediate success rate is not the only criteria. We
> should also keep the overhead sane. That's why there's pageblock
> suitability bitfield, deferred compaction etc, which I'm not sure
> how those would fit into the "continuously progressing migration
> scanner" scheme.
> So what I think should precede such increase in compact aggressivity:
> - on direct compaction, only try migrate when successfully isolated
> all pages needed for merging the desired order page. I've had such
> patch already in one series last year, but it affected the
> anti-fragmentation effects of compaction.
> - no more THP page faults (also for other good reasons), leave
> collapsing to khugepaged, or rather task_work, leaving only the
> expensive sync compaction to dedicated per-node daemons. These
> should hopefully solve the anti-fragmentation issue as well.
> 
> >Thanks.
> >
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
