Date: Wed, 12 Sep 2007 04:44:50 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 01 of 24] remove nr_scan_inactive/active
Message-Id: <20070912044450.cef400fa.akpm@linux-foundation.org>
In-Reply-To: <c8ec651562ad6514753e.1187786928@v2.random>
References: <patchbomb.1187786927@v2.random>
	<c8ec651562ad6514753e.1187786928@v2.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: linux-mm@kvack.org, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

On Wed, 22 Aug 2007 14:48:48 +0200 Andrea Arcangeli <andrea@suse.de> wrote:

> # HG changeset patch
> # User Andrea Arcangeli <andrea@suse.de>
> # Date 1187778124 -7200
> # Node ID c8ec651562ad6514753e408596e30d7d9e448a51
> # Parent  b03dfad58a311488ec373c30fd5dc97dc03aecae
> remove nr_scan_inactive/active
> 
> The older atomic_add/atomic_set were pointless (atomic_set vs atomic_add would
> race), but removing them didn't actually remove the race, the race is still
> there, for the same reasons atomic_add/set couldn't prevent it. This is really
> the kind of code that I dislike because it's sort of buggy, and it shouldn't be
> making any measurable difference and when it does something for real it can
> only hurt!
> 
> The real focus is on shrink_zone (ignore the other places where it's being used
> that are even less interesting). Assume two tasks adds to nr_scan_*active at
> the same time (first line of the old buggy code), they'll effectively double their
> scan rate, for no good reason. What can happen is that instead of scanning
> nr_entries each, they'll scan nr_entries*2 each. The more CPUs the bigger the
> race and the higher the multiplication effect and the harder it will be to
> detect oom. In the case that nr_*active < sc->swap_cluster_max, regardless of
> whatever future invocation of alloc_pages, we'll be going down in the
> priorities in the current alloc_pages invocation if the DEF_PRIORITY was too
> high to make any work, so again accumulating the nr_scan_*active doesn't seem
> interesting even when it's smaller than sc->swap_cluster_max. Each task should
> work for itself without much care of what the others are doing.

You're coming at this from the wrong end of town.  The code in there is to
address small zones (actually small LRU lists) at "easy" scanning
priorities.  I suspect you just broke it in that region of operation.

Does that above text describe something which you've observed and measured
in practice, or is it theoretical-from-code-inspection?


> ...
>

We go from this:

	/*
	 * Add one to `nr_to_scan' just to make sure that the kernel will
	 * slowly sift through the active list.
	 */
	zone->nr_scan_active +=
		(zone_page_state(zone, NR_ACTIVE) >> priority) + 1;
	nr_active = zone->nr_scan_active;
	if (nr_active >= sc->swap_cluster_max)
		zone->nr_scan_active = 0;
	else
		nr_active = 0;

	zone->nr_scan_inactive +=
		(zone_page_state(zone, NR_INACTIVE) >> priority) + 1;
	nr_inactive = zone->nr_scan_inactive;
	if (nr_inactive >= sc->swap_cluster_max)
		zone->nr_scan_inactive = 0;
	else
		nr_inactive = 0;

	while (nr_active || nr_inactive) {


to this:


	/*
	 * Add one to `nr_to_scan' just to make sure that the kernel will
	 * slowly sift through the active list.
	 */
	nr_active = zone_page_state(zone, NR_ACTIVE) >> priority;
	if (nr_active < sc->swap_cluster_max)
		nr_active = 0;
	nr_inactive = zone_page_state(zone, NR_INACTIVE) >> priority;
	if (nr_inactive < sc->swap_cluster_max)
		nr_inactive = 0;

	while (nr_active || nr_inactive) {


I have issues.


The old code took care of the situtaion where zone_page_state(zone,
NR_ACTIVE) is smaller than (1 << priority): do a bit of reclaim in that
case anyway.  This is a minor issue, as we'll at least perform some
scanning when priority is low.  But you should have depeted the now-wrong
comment.


More serious issue: the logic in there takes care of balancing a small LRU
list.  If (zone_page_state(zone, NR_ACTIVE)>>priority) is, umm, "3" then
we'll add "3" into zone->nr_scan_active and then leave the zone alone. 
Once we've done this enough times, the "3"s will add up to something which
is larger than swap_cluster_max and then we'll do a round of scanning for
real.

Your change breaks that logic and there is potential that a small LRU will
be underscanned, especially when reclaim is not under distress.

I don't know how serious this change is, but it's a change for the worse
and it would take quite a bit of thought and careful testing to be able to
justify this change.

According to the above-described logic, one would think that it would be
more accurate to replace the existing

	if (nr_active >= sc->swap_cluster_max)
		zone->nr_scan_active = 0;

with

	if (nr_active >= sc->swap_cluster_max)
		zone->nr_scan_active -= sc->swap_cluster_max;

and for twelve seconds on 12 March 2004 we were partially doing that, but
then I merged this:

commit 4d5e349b89e4017ddbdbd06345e94c59e8b851b7
Author: akpm <akpm>
Date:   Fri Mar 12 16:25:24 2004 +0000

    [PATCH] fix vm-batch-inactive-scanning.patch
    
    - prevent nr_scan_inactive from going negative
    
    - compare `count' with SWAP_CLUSTER_MAX, not `max_scan'
    
    - Use ">= SWAP_CLUSTER_MAX", not "> SWAP_CLUSTER_MAX".
    
    BKrev: 4051e474u37Zwj2o6Q5o5NeVCL-5kQ

diff --git a/mm/vmscan.c b/mm/vmscan.c
index fb86cb2..65824df 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -757,14 +757,14 @@ shrink_zone(struct zone *zone, int max_s
 	ratio = (unsigned long)SWAP_CLUSTER_MAX * zone->nr_active /
 				((zone->nr_inactive | 1) * 2);
 	atomic_add(ratio+1, &zone->nr_scan_active);
-	if (atomic_read(&zone->nr_scan_active) > SWAP_CLUSTER_MAX) {
+	count = atomic_read(&zone->nr_scan_active);
+	if (count >= SWAP_CLUSTER_MAX) {
 		/*
 		 * Don't try to bring down too many pages in one attempt.
 		 * If this fails, the caller will increase `priority' and
 		 * we'll try again, with an increased chance of reclaiming
 		 * mapped memory.
 		 */
-		count = atomic_read(&zone->nr_scan_active);
 		if (count > SWAP_CLUSTER_MAX * 4)
 			count = SWAP_CLUSTER_MAX * 4;
 		atomic_set(&zone->nr_scan_active, 0);
@@ -773,8 +773,8 @@ shrink_zone(struct zone *zone, int max_s
 
 	atomic_add(max_scan, &zone->nr_scan_inactive);
 	count = atomic_read(&zone->nr_scan_inactive);
-	if (max_scan > SWAP_CLUSTER_MAX) {
-		atomic_sub(count, &zone->nr_scan_inactive);
+	if (count >= SWAP_CLUSTER_MAX) {
+		atomic_set(&zone->nr_scan_inactive, 0);
 		return shrink_cache(zone, gfp_mask, count, total_scanned);
 	}
 	return 0;


which made both the inactive and active list scanning the same (and
inaccurate).

So I'm thinking that a correct fix to all these problems is to go back to
atomics and to not just set the counters to zero, but to subtract the
number-of-scanned-pages from them as we're supposed to so.

An alternative approach might be to only touch nr_scanned_[in]active at all
when (zone_page_state(zone, NR_ACTIVE) >> priority) is less than
(1<<priority).  So most of the time we'll just go in there and scan the
full swap_cluster_max pages.  And the nr_scan_[in]active counters are
purely used as "fractional" counters to prevent the underscanning in the
corner cases to which I referred above.

Yet another alternative approach would be to remove the batching
altogether.  If (zone_page_state(zone, NR_ACTIVE) >> priority) evaluates to
"3", well, just go in and scan three pages.  That should address any
accuracy problems and it will address the problem which you're addressing,
but it will add unknown-but-probably-small computational cost.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
