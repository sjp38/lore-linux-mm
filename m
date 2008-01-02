Date: Wed, 2 Jan 2008 18:50:53 +0100
From: Andrea Arcangeli <andrea@cpushare.com>
Subject: Re: [PATCH 01 of 24] remove nr_scan_inactive/active
Message-ID: <20080102175050.GS19333@v2.random>
References: <patchbomb.1187786927@v2.random> <c8ec651562ad6514753e.1187786928@v2.random> <20070912044450.cef400fa.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070912044450.cef400fa.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

Hi Andrew,

On Wed, Sep 12, 2007 at 04:44:50AM -0700, Andrew Morton wrote:
> Does that above text describe something which you've observed and measured
> in practice, or is it theoretical-from-code-inspection?

it's hard to tell why oom handling takes so long while scanning the
lrus, so I tried to cut the useless work in places that could
generated overwork in that area. It's mostly theoretical though.

> The old code took care of the situtaion where zone_page_state(zone,
> NR_ACTIVE) is smaller than (1 << priority): do a bit of reclaim in that
> case anyway.  This is a minor issue, as we'll at least perform some
> scanning when priority is low.  But you should have depeted the now-wrong
> comment.

I see what you mean.

> Your change breaks that logic and there is potential that a small LRU will
> be underscanned, especially when reclaim is not under distress.

When the race triggers it may be underscanned anyway, so it can't
depend on it for correct operation, but most of the time it can help
and removing the code like I did will surely scan less in your
small-lru scenario.

> According to the above-described logic, one would think that it would be
> more accurate to replace the existing
> 
> 	if (nr_active >= sc->swap_cluster_max)
> 		zone->nr_scan_active = 0;
> 
> with
> 
> 	if (nr_active >= sc->swap_cluster_max)
> 		zone->nr_scan_active -= sc->swap_cluster_max;

not sure I follow why, this will underscan if it's the only change,
and it will make the race condition even more dangerous.

> Yet another alternative approach would be to remove the batching
> altogether.  If (zone_page_state(zone, NR_ACTIVE) >> priority) evaluates to
> "3", well, just go in and scan three pages.  That should address any
> accuracy problems and it will address the problem which you're addressing,
> but it will add unknown-but-probably-small computational cost.

It's quite simpler. All I care about is that nr_scan_*active, doesn't
grow to insane levels without any good reason in bigsmp, like it can
happen now.

I thought this racy code didn't deserve to exist but that's not my
priority, my priority is to avoid huge nr_*active values especially
with priorities going down to zero during oom, and that's easy enough
to achieve like this (mostly untested):

# HG changeset patch
# User Andrea Arcangeli <andrea@suse.de>
# Date 1199294746 -3600
# Node ID bc803863094aaef8a03dbec584370fb2b68b17d0
# Parent  e28e1be3fae5183e3e36e32e3feb9a59ec59c825
limit shrink zone scanning

Assume two tasks adds to nr_scan_*active at the same time (first line of the
old buggy code), they'll effectively double their scan rate, for no good
reason. What can happen is that instead of scanning nr_entries each, they'll
scan nr_entries*2 each. The more CPUs the bigger the race and the higher the
multiplication effect and the harder it will be to detect oom. This puts a cap
on the amount of work that it makes sense to do in case the race triggers.

Signed-off-by: Andrea Arcangeli <andrea@suse.de>

diff --git a/mm/vmscan.c b/mm/vmscan.c
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1114,7 +1114,7 @@ static unsigned long shrink_zone(int pri
 	 */
 	zone->nr_scan_active +=
 		(zone_page_state(zone, NR_ACTIVE) >> priority) + 1;
-	nr_active = zone->nr_scan_active;
+	nr_active = min(zone->nr_scan_active, zone_page_state(zone, NR_ACTIVE));
 	if (nr_active >= sc->swap_cluster_max)
 		zone->nr_scan_active = 0;
 	else
@@ -1122,7 +1122,7 @@ static unsigned long shrink_zone(int pri
 
 	zone->nr_scan_inactive +=
 		(zone_page_state(zone, NR_INACTIVE) >> priority) + 1;
-	nr_inactive = zone->nr_scan_inactive;
+	nr_inactive = min(zone->nr_scan_inactive, zone_page_state(zone, NR_INACTIVE));
 	if (nr_inactive >= sc->swap_cluster_max)
 		zone->nr_scan_inactive = 0;
 	else

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
