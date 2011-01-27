Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id B71688D0039
	for <linux-mm@kvack.org>; Thu, 27 Jan 2011 13:52:42 -0500 (EST)
Date: Thu, 27 Jan 2011 19:52:15 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: too big min_free_kbytes
Message-ID: <20110127185215.GE16981@random.random>
References: <1295841406.1949.953.camel@sli10-conroe>
 <20110124150033.GB9506@random.random>
 <20110126141746.GS18984@csn.ul.ie>
 <20110126152302.GT18984@csn.ul.ie>
 <20110126154203.GS926@random.random>
 <20110126163655.GU18984@csn.ul.ie>
 <20110126174236.GV18984@csn.ul.ie>
 <20110127134057.GA32039@csn.ul.ie>
 <20110127152755.GB30919@random.random>
 <20110127160301.GA29291@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110127160301.GA29291@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Shaohua Li <shaohua.li@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, linux-mm <linux-mm@kvack.org>, "Chen, Tim C" <tim.c.chen@intel.com>
List-ID: <linux-mm.kvack.org>

On Thu, Jan 27, 2011 at 04:03:01PM +0000, Mel Gorman wrote:
> Agreed, I considered your approach as well. I didn't go with it because it
> was the main heuristic that allowed kswapd to skip a zone but still allows
> kswapd to keep going. I made the choice to try and put kswapd to sleep
> sooner.

Ok, but a multiplication *8 remains excessive and while it may be ok
with min_free_kbytes=20M it's not ok when it's = 80M, especially when
it can be set to 80M on a 4G system that will end up with a small
over-4g zone that may not be shrunk as easily as the normal/pci32 zone
below 4g.

It's broken because this *8 adds is all about a 7*highwmark "gap".

I'm having a little trouble understanding your patch and I don't like
the magic >> 2 very much, if the node has little more than 1/4th of
the memory of the node, it'll still cause the other zones to be shrunk
8 times more than they should ever be shrunk! This will materialize
with ~mem=5g , with your patch a little more than 5g will still lead
to ~800M free by mistake. It seems more a band aid for the 4g case
than a real fix. This is why I think the real fix is to remove that *8
and create a real "balance gap ratio" that is in function of the
memory of the zone, not in function of the high wmark at all.

If we were using the old code the gap would be way smaller. The "gap"
is increasing excessively because the "high wmark" is increasing to a
fixed value in function of the pageblocks numbers, the migrate types
etc..., but from an algorithm point of view the high wmark has no
effect on the rotation of all lrus to balance the shrinking of all
zones. The high wmark is a fixed amount for all zones, the "gap"
doesn't need to increase with the high wmark.

Clearly the high wmark was used as in the old days it was a function
of the ram size, now it's not anymore. So clearly the "gap" must not
be in function of the high wmark a nymore but only in function of the
memory size! Which I think is the real fix.

> It was introduced by commit [32a4330d: mm: prevent kswapd from freeing
> excessive amounts of lowmem] and sure enough, it was intended to avoid a
> situation where memory was freed from every zone if one was imbalanced -
> sounds familiar.

Yes definitely. So it was limiting the waste to 8*high_wmark. But that
was ok because it had the assumtion wmark was a fuction of memory,
it's not ok anymore and we must make it a function of memory
explicitly to fix this.

> It should work in terms of free memory. When testing, monitor as well if
> kswapd is going asleep or if it is stuck in D state. If it's stuck in D state,
> it's looping around in balance_pgdat() and consuming CPU for no good reason
> (can use vmscan tracepoints to confirm).

I'll try another patch first to avoid disabling the balancing of all
zones that should provide for a nicer lru behavior than my previous
patch.

I am however uncertain this is really better than removing the *8 as
in my previous patch. But either this or previous patch I sent is the
solution I prefer, because this fixes it without a magic >>2 that will
break again quite badly at little more than mem=5g.

====
Subject: vmscan: kswapd must not free more than high_wmark+gap pages

From: Andrea Arcangeli <aarcange@redhat.com>

When the min_free_kbytes is set with `hugeadm
--set-recommended-min_free_kbytes" or with THP enabled (which runs the
equivalent of "hugeadm --set-recommended-min_free_kbytes" to activate
anti-frag at full effectiveness automatically at boot) the high wmark
of some zone is fixed as high as ~88M, not anymore in function of
memory size. 88M free on a 4G system isn't horrible, but 88M*8 = 704M
free on a 4G system is unbearable. This only tends to be visible on 4G
systems with tiny over-4g zone where kswapd insists to reach the high
wmark on the over-4g zone but doing so it shrunk up to 704M from the
normal zone by mistake. This patch makes the "gap" explicit in
function of memory size, because the high wmark isn't in function of
memory size anymore.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---

diff --git a/include/linux/swap.h b/include/linux/swap.h
index 4d55932..a57c6e7 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -155,6 +155,15 @@ enum {
 #define SWAP_CLUSTER_MAX 32
 #define COMPACT_CLUSTER_MAX SWAP_CLUSTER_MAX
 
+/*
+ * Ratio between the present memory in the zone and the "gap" that
+ * we're allowing kswapd to shrink in addition to the per-zone high
+ * wmark, even for zones that already have the high wmark satisfied,
+ * in order to provide better per-zone lru behavior. We are ok to
+ * spend not more than 1% of the memory for this zone balancing "gap".
+ */
+#define KSWAPD_ZONE_BALANCE_GAP_RATIO 100
+
 #define SWAP_MAP_MAX	0x3e	/* Max duplication count, in first swap_map */
 #define SWAP_MAP_BAD	0x3f	/* Note pageblock is bad, in first swap_map */
 #define SWAP_HAS_CACHE	0x40	/* Flag page is cached, in first swap_map */
diff --git a/mm/vmscan.c b/mm/vmscan.c
index f5d90de..f03441e 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2403,11 +2403,16 @@ loop_again:
 			mem_cgroup_soft_limit_reclaim(zone, order, sc.gfp_mask);
 
 			/*
-			 * We put equal pressure on every zone, unless one
-			 * zone has way too many pages free already.
+			 * We put equal pressure on every zone, unless
+			 * one zone has way too many pages free
+			 * already. The "too many pages" is defined
+			 * as the high wmark plus a "gap".
 			 */
 			if (!zone_watermark_ok_safe(zone, order,
-					8*high_wmark_pages(zone), end_zone, 0))
+					(zone->present_pages +
+					 KSWAPD_ZONE_BALANCE_GAP_RATIO-1) /
+					 KSWAPD_ZONE_BALANCE_GAP_RATIO +
+					high_wmark_pages(zone), end_zone, 0))
 				shrink_zone(priority, zone, &sc);
 			reclaim_state->reclaimed_slab = 0;
 			nr_slab = shrink_slab(sc.nr_scanned, GFP_KERNEL,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
