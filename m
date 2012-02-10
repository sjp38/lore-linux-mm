Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id E409F6B13FC
	for <linux-mm@kvack.org>; Fri, 10 Feb 2012 11:37:51 -0500 (EST)
Date: Fri, 10 Feb 2012 16:37:48 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [Bug 42578] Kernel crash "Out of memory error by X" when using
 NTFS file system on external USB Hard drive
Message-ID: <20120210163748.GR5796@csn.ul.ie>
References: <bug-42578-27@https.bugzilla.kernel.org/>
 <201201180922.q0I9MCYl032623@bugzilla.kernel.org>
 <20120119122448.1cce6e76.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20120119122448.1cce6e76.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org, Stuart Foster <smf.linux@ntlworld.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>

On Thu, Jan 19, 2012 at 12:24:48PM -0800, Andrew Morton wrote:
> 
> (switched to email.  Please respond via emailed reply-to-all, not via the
> bugzilla web interface).
> 
> On Wed, 18 Jan 2012 09:22:12 GMT
> bugzilla-daemon@bugzilla.kernel.org wrote:
> 
> > https://bugzilla.kernel.org/show_bug.cgi?id=42578
> 

Sorry again for taking so long to look at this.

> Stuart has an 8GB x86_32 machine. 

The bugzilla talks about a 16G machine. Is 8G a typo?

> It has large amounts of NTFS
> pagecache in highmem.  NTFS is using 512-byte buffer_heads.  All of the
> machine's lowmem is being consumed by struct buffer_heads which are
> attached to the highmem pagecache and the machine is dead in the water,
> getting a storm of ooms.
> 

Ok, I was at least able to confirm with an 8G machine that there are a lot
of buffer_heads allocated as you'd expect but it did not crash. I suspect
it's because the ratio of highmem/normal was insufficient to trigger the
bug. Stuart, if this is a 16G machine, can you test booting with mem=8G
to confirm the ratio of highmem/normal is the important factor please?

> A regression, I think.  A box-killing one on a pretty simple workload
> on a not uncommon machine.
> 

Because of the trigger, it's the type of bug that could have existed for
a long time without being noticed. When I went to reproduce this, I found
that my distro by default was using fuse to access the NTFS partition
which could have also contributed to hiding this.

> We used to handle this by scanning highmem even when there was plenty
> of free highmem and the request is for a lowmmem pages.  We have made a
> few changes in this area and I guess that's what broke it.
> 

I don't have much time to look at this unfortunately so I didn't dig too
deep but this assessment looks accurate. In direct reclaim for example,
we used to always scan all zones unconditionally. Now we filter what zones
we reclaim from based on the gfp mask of the caller.

> I think a suitable fix here would be to extend the
> buffer_heads_over_limit special-case.  If buffer_heads_over_limit is
> true, both direct-reclaimers and kswapd should scan the highmem zone
> regardless of incoming gfp_mask and regardless of the highmem free
> pages count.
> 

I've included a quick hatchet job below to test the basic theory. It has
not been tested properly I'm afraid but the basic idea is there.

> In this mode, we only scan the file lru.  We should perform writeback
> as well, because the buffer_heads might be dirty.
> 

With this patch against 3.3-rc3, it won't immediately initiate writeback by
kswapd. Direct reclaim cannot initiate writeback at all so there is still
a risk that enough dirty pages could exist to pin low memory and go OOM but
the machine would need at least 30G of machine and running in 32-bit mode.

> [aside: If all of a page's buffer_heads are dirty we can in fact
> reclaim them and mark the entire page dirty.  If some of the
> buffer_heads are dirty and the others are uptodate we can even reclaim
> them in this case, and mark the entire page dirty, causing extra I/O
> later.  But try_to_release_page() doesn't do these things.]
> 

Good tip.

> I think it is was always wrong that we only strip buffer_heads when
> moving pages to the inactive list.  What happens if those 600MB of
> buffer_heads are all attached to inactive pages?
> 

I wondered the same thing myself. With some use-once logic, there is
no guarantee that they even get promoted to the active list in the
first place. It's "always" been like this but we've changed how pages gets
promoted quite a bit and this use case could have been easily missed.

diff --git a/mm/vmscan.c b/mm/vmscan.c
index c52b235..3622765 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2235,6 +2235,14 @@ static bool shrink_zones(int priority, struct zonelist *zonelist,
 	unsigned long nr_soft_scanned;
 	bool aborted_reclaim = false;
 
+	/*
+	 * If the number of buffer_heads in the machine exceeds the maximum
+	 * allowed level, force direct reclaim to scan the highmem zone as
+	 * highmem pages could be pinning lowmem pages storing buffer_heads
+	 */
+	if (buffer_heads_over_limit)
+		sc->gfp_mask |= __GFP_HIGHMEM;
+
 	for_each_zone_zonelist_nodemask(zone, z, zonelist,
 					gfp_zone(sc->gfp_mask), sc->nodemask) {
 		if (!populated_zone(zone))
@@ -2724,6 +2732,17 @@ loop_again:
 			 */
 			age_active_anon(zone, &sc, priority);
 
+			/*
+			 * If the number of buffer_heads in the machine
+			 * exceeds the maximum allowed level and this node
+			 * has a highmem zone, force kswapd to reclaim from
+			 * it to relieve lowmem pressure.
+			 */
+			if (buffer_heads_over_limit && is_highmem_idx(i)) {
+				end_zone = i;
+				break;
+			}
+
 			if (!zone_watermark_ok_safe(zone, order,
 					high_wmark_pages(zone), 0, 0)) {
 				end_zone = i;
@@ -2786,7 +2805,8 @@ loop_again:
 				(zone->present_pages +
 					KSWAPD_ZONE_BALANCE_GAP_RATIO-1) /
 				KSWAPD_ZONE_BALANCE_GAP_RATIO);
-			if (!zone_watermark_ok_safe(zone, order,
+			if ((buffer_heads_over_limit && is_highmem_idx(i)) ||
+				    !zone_watermark_ok_safe(zone, order,
 					high_wmark_pages(zone) + balance_gap,
 					end_zone, 0)) {
 				shrink_zone(priority, zone, &sc);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
