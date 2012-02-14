Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id 20B6F6B13F0
	for <linux-mm@kvack.org>; Tue, 14 Feb 2012 08:09:59 -0500 (EST)
Date: Tue, 14 Feb 2012 13:09:55 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [Bug 42578] Kernel crash "Out of memory error by X" when using
 NTFS file system on external USB Hard drive
Message-ID: <20120214130955.GM17917@csn.ul.ie>
References: <bug-42578-27@https.bugzilla.kernel.org/>
 <201201180922.q0I9MCYl032623@bugzilla.kernel.org>
 <20120119122448.1cce6e76.akpm@linux-foundation.org>
 <20120210163748.GR5796@csn.ul.ie>
 <4F36DD77.1080306@ntlworld.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <4F36DD77.1080306@ntlworld.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stuart Foster <smf.linux@ntlworld.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>

On Sat, Feb 11, 2012 at 09:28:23PM +0000, Stuart Foster wrote:
> Thanks for the update, my test results using kernel 3.3-rc3 are as follows:
> 
> 1 With all 16Gbyte enabled the system fails as previously reported.
> 
> 2 With memory limited to 8Gbyte the system does not fail.
> 
> 3 With the patch applied and the system using the full 16Gbyte the
> system does not fail.
> 

Thanks Stuart. Rik, Andrew, should the following be improved in some
way? I did not come to any decent conclusion on what to do with pages in
the inactive list with buffer_head as we are already stripping them when
the pages reach the end of the LRU.

---8<---
mm: vmscan: Forcibly scan highmem if there are too many buffer_heads pinning highmem

Stuart Foster reported on https://bugzilla.kernel.org/show_bug.cgi?id=42578
that copying large amounts of data from NTFS caused an OOM kill on 32-bit
X86 with 16G of memory. Andrew Morton correctly identified that the problem
was NTFS was using 512 blocks meaning each page had 8 buffer_heads in low
memory pinning it.

In the past, direct reclaim used to scan highmem even if the allocating
process did not specify __GFP_HIGHMEM but not any more. kswapd no longer
will reclaim from zones that are above the high watermark. The intention
in both cases was to minimise unnecessary reclaim. The downside is on
machines with large amounts of highmem that lowmem can be fully consumed
by buffer_heads with nothing trying to free them.

The following patch is based on a suggestion by Andrew Morton to extend
the buffer_heads_over_limit case to force kswapd and direct reclaim to
scan the highmem zone regardless of the allocation request or
watermarks.

Reported-and-tested-by: Stuart Foster <smf.linux@ntlworld.com>
Signed-off-by: Mel Gorman <mgorman@suse.de>
Cc: stable <stable@vger.kernel.org>
---
 mm/vmscan.c |   22 +++++++++++++++++++++-
 1 files changed, 21 insertions(+), 1 deletions(-)

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
