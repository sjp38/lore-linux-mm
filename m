Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id 33CD66B004D
	for <linux-mm@kvack.org>; Fri, 30 Nov 2012 19:46:33 -0500 (EST)
Date: Fri, 30 Nov 2012 19:45:20 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: kswapd craziness in 3.7
Message-ID: <20121201004520.GK2301@cmpxchg.org>
References: <20121127214928.GA20253@cmpxchg.org>
 <50B5387C.1030005@redhat.com>
 <20121127222637.GG2301@cmpxchg.org>
 <CA+55aFyrNRF8nWyozDPi4O1bdjzO189YAgMukyhTOZ9fwKqOpA@mail.gmail.com>
 <20121128101359.GT8218@suse.de>
 <20121128145215.d23aeb1b.akpm@linux-foundation.org>
 <20121128235412.GW8218@suse.de>
 <50B77F84.1030907@leemhuis.info>
 <20121129170512.GI2301@cmpxchg.org>
 <50B8A8E7.4030108@leemhuis.info>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <50B8A8E7.4030108@leemhuis.info>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thorsten Leemhuis <fedora@leemhuis.info>
Cc: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, George Spelvin <linux@horizon.com>, Johannes Hirte <johannes.hirte@fem.tu-ilmenau.de>, Tomas Racek <tracek@redhat.com>, Jan Kara <jack@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Josh Boyer <jwboyer@gmail.com>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Jiri Slaby <jslaby@suse.cz>, Zdenek Kabelac <zkabelac@redhat.com>, Bruno Wolff III <bruno@wolff.to>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, John Ellson <john.ellson@comcast.net>

Hi Thorsten,

On Fri, Nov 30, 2012 at 01:39:03PM +0100, Thorsten Leemhuis wrote:
> /me wonders how to elegantly get out of his man-in-the-middle position

You control the mighty koji :-)

But seriously, this is very helpful, thank you!  John now also Cc'd
directly.

> John was able to reproduce the problem quickly with a kernel that 
> contained the patch from your mail. For details see
> 
> https://bugzilla.redhat.com/show_bug.cgi?id=866988#c42 and later
> 
> He provided the informations there. Parts of it:

> /proc/vmstat while kswad0 at 100%cpu
> /proc/zoneinfo with kswapd0 at 100% cpu
> perf profile

Thanks.

I'm quoting the interesting bits in order of the cars on my possibly
derailing train of thought:

> pageoutrun 117729182
> allocstall 5

Okay, so kswapd is stupidly looping but it's still managing to do it's
actual job; nobody is dropping into direct reclaim.

> pgsteal_kswapd_dma 1
> pgsteal_kswapd_normal 202106
> pgsteal_kswapd_high 36515
> pgsteal_kswapd_movable 0

> pgscan_kswapd_dma 1
> pgscan_kswapd_normal 203044
> pgscan_kswapd_high 40407
> pgscan_kswapd_movable 0

Does not seem excessive, so apparently it also does not overreclaim.

> Node 0, zone      DMA
>   pages free     1655
>         min      196
>         low      245
>         high     294

> Node 0, zone   Normal
>   pages free     186234
>         min      10953
>         low      13691
>         high     16429

> Node 0, zone  HighMem
>   pages free     8983
>         min      34
>         low      475
>         high     917

These are all well above their watermarks, yet kswapd is definitely
finding something wrong with one of these as it actually does drop
into the reclaim loop, so zone_balanced() must be returning false:

>     16.52%      kswapd0  [kernel.kallsyms]          [k] idr_get_next                   
>                 |
>                 --- idr_get_next
>                    |          
>                    |--99.76%-- css_get_next
>                    |          mem_cgroup_iter
>                    |          |          
>                    |          |--50.49%-- shrink_zone
>                    |          |          kswapd
>                    |          |          kthread
>                    |          |          ret_from_kernel_thread
>                    |          |          
>                    |           --49.51%-- kswapd
>                    |                     kthread
>                    |                     ret_from_kernel_thread
>                     --0.24%-- [...]
> 
>     11.23%      kswapd0  [kernel.kallsyms]          [k] prune_super                    
>                 |
>                 --- prune_super
>                    |          
>                    |--86.74%-- shrink_slab
>                    |          kswapd
>                    |          kthread
>                    |          ret_from_kernel_thread
>                    |          
>                     --13.26%-- kswapd
>                               kthread
>                               ret_from_kernel_thread

Spending so much time in shrink_zone and shrink_slab without
overreclaiming a zone, I would say that a) this always stays on the
DEF_PRIORITY and b) only loops on the DMA zone.  At DEF_PRIORITY, the
scan goal for filepages in the other zones would be > 0 e.g.

As the DMA zone watermarks are fine, it must be the fragmentation
index that indicates a lack of memory.  Filling in the 1655 free pages
into the fragmentation index formula indicates lack of free memory
when these 1655 pages are lumped together in less than 9 page blocks.
Not unrealistic, I think: on my desktop machine, the DMA zone's free
3975 pages are lumped together in only 12 blocks.  But on my system,
the DMA zone is either never used and there is always at least one
page block available that could satisfy a huge page allocation
(fragmentation index == -1000).  Unless the system gets really close
to OOM, at which point the DMA zone is highly fragmented.  And keep in
mind that if the priority level goes below DEF_PRIORITY, as it does
close to OOM, the unreclaimable DMA zone is ignored anyway.  But the
DMA zone here is just barely used:

> Node 0, zone      DMA
[...]
>     nr_slab_reclaimable 3
>     nr_slab_unreclaimable 1
[...]
>     nr_dirtied   315
>     nr_written   315

which could explain a fragmentation index that asks for more free
memory while the watermarks are fine.

Why this all loops: there is one more inconsistency where the
conditions for reclaim and the conditions for compaction contradict
each other: reclaim also does not consider the DMA zone balanced, but
it needs only 25% of the whole node to be balanced, while compaction
requires every single zone to be balanced individually.

So these strict per-zone checks for compaction at the end of
balance_pgdat() are likely to be the culprits that keep kswapd looping
forever on this machine, trying to balance DMA for compaction while
reclaim decides it has enough balanced memory in the node overall.

I think we can just remove them: whenever the compaction code is
reached, the reclaim code balanced 25% of the memory available for the
classzone to be suitable for compaction.

Mel?  Rik?

---
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch] mm: vmscan: do not keep kswapd looping forever due
 to individual uncompactable zones

When a zone meets its high watermark and is compactable in case of
higher order allocations, it contributes to the percentage of the
node's memory that is considered balanced.

This requirement, that a node be only partially balanced, came about
when kswapd was desparately trying to balance tiny zones when all
bigger zones in the node had plenty of free memory.  Arguably, the
same should apply to compaction: if a significant part of the node is
balanced enough to run compaction, do not get hung up on that tiny
zone that might never get in shape.

When the compaction logic in kswapd is reached, we know that at least
25% of the node's memory is balanced properly for compaction (see
zone_balanced and pgdat_balanced).  Remove the individual zone checks
that restart the kswapd cycle.

Otherwise, we may observe more endless looping in kswapd where the
compaction code loops back to reclaim because of a single zone and
reclaim does nothing because the node is considered balanced overall.

Reported-by: Thorsten Leemhuis <fedora@leemhuis.info>
Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/vmscan.c | 16 ----------------
 1 file changed, 16 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 3b0aef4..486100f 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2806,22 +2806,6 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
 			if (!populated_zone(zone))
 				continue;
 
-			if (zone->all_unreclaimable &&
-			    sc.priority != DEF_PRIORITY)
-				continue;
-
-			/* Would compaction fail due to lack of free memory? */
-			if (COMPACTION_BUILD &&
-			    compaction_suitable(zone, order) == COMPACT_SKIPPED)
-				goto loop_again;
-
-			/* Confirm the zone is balanced for order-0 */
-			if (!zone_watermark_ok(zone, 0,
-					high_wmark_pages(zone), 0, 0)) {
-				order = sc.order = 0;
-				goto loop_again;
-			}
-
 			/* Check if the memory needs to be defragmented. */
 			if (zone_watermark_ok(zone, order,
 				    low_wmark_pages(zone), *classzone_idx, 0))
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
