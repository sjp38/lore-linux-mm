Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id 774856B0078
	for <linux-mm@kvack.org>; Thu, 29 Nov 2012 12:06:11 -0500 (EST)
Date: Thu, 29 Nov 2012 12:05:12 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: kswapd craziness in 3.7
Message-ID: <20121129170512.GI2301@cmpxchg.org>
References: <CA+55aFywygqWUBNWtZYa+vk8G0cpURZbFdC7+tOzyWk6tLi=WA@mail.gmail.com>
 <50B52DC4.5000109@redhat.com>
 <20121127214928.GA20253@cmpxchg.org>
 <50B5387C.1030005@redhat.com>
 <20121127222637.GG2301@cmpxchg.org>
 <CA+55aFyrNRF8nWyozDPi4O1bdjzO189YAgMukyhTOZ9fwKqOpA@mail.gmail.com>
 <20121128101359.GT8218@suse.de>
 <20121128145215.d23aeb1b.akpm@linux-foundation.org>
 <20121128235412.GW8218@suse.de>
 <50B77F84.1030907@leemhuis.info>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <50B77F84.1030907@leemhuis.info>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thorsten Leemhuis <fedora@leemhuis.info>
Cc: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, George Spelvin <linux@horizon.com>, Johannes Hirte <johannes.hirte@fem.tu-ilmenau.de>, Tomas Racek <tracek@redhat.com>, Jan Kara <jack@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Josh Boyer <jwboyer@gmail.com>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Jiri Slaby <jslaby@suse.cz>, Zdenek Kabelac <zkabelac@redhat.com>, Bruno Wolff III <bruno@wolff.to>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Thu, Nov 29, 2012 at 04:30:12PM +0100, Thorsten Leemhuis wrote:
> Mel Gorman wrote on 29.11.2012 00:54:
> > On Wed, Nov 28, 2012 at 02:52:15PM -0800, Andrew Morton wrote:
> >> On Wed, 28 Nov 2012 10:13:59 +0000
> >> Mel Gorman <mgorman@suse.de> wrote:
> >> 
> >> > Based on the reports I've seen I expect the following to work for 3.7
> >> > Keep
> >> >   96710098 mm: revert "mm: vmscan: scale number of pages reclaimed by reclaim/compaction based on failures"
> >> >   ef6c5be6 fix incorrect NR_FREE_PAGES accounting (appears like memory leak)
> >> > Revert
> >> >   82b212f4 Revert "mm: remove __GFP_NO_KSWAPD"
> >> > Merge
> >> >   mm: vmscan: fix kswapd endless loop on higher order allocation
> >> >   mm: Avoid waking kswapd for THP allocations when compaction is deferred or contended
> >> "mm: Avoid waking kswapd for THP ..." is marked "I have not tested it
> >> myself" and when Zdenek tested it he hit an unexplained oom.
> > I thought Zdenek was testing with __GFP_NO_KSWAPD when he hit that OOM.
> > Further, when he hit that OOM, it looked like a genuine OOM. He had no
> > swap configured and inactive/active file pages were very low. Finally,
> > the free pages for Normal looked off and could also have been affected by
> > the accounting bug. I'm looking at https://lkml.org/lkml/2012/11/18/132
> > here. Are you thinking of something else?
> > 
> > I have not tested with the patch admittedly but Thorsten has and seemed
> > to be ok with it https://lkml.org/lkml/2012/11/23/276.
> 
> Yeah, on my two main work horses a few different kernels based on rc6 or
> rc7 worked fine with this patch. But sorry, it seems the patch doesn't
> fix the problems Fedora user John Ellson sees, who tried kernels I built
> in the Fedora buildsystem. Details:
> 
> In https://bugzilla.redhat.com/show_bug.cgi?id=866988#c35 he mentioned
> his machine worked fine with a rc6 based kernel I built that contained
> 82b212f4 (Revert "mm: remove __GFP_NO_KSWAPD"). Before that he had tried
> a kernel with the same baseline that contained "Avoid waking kswapd for
> THP allocations when [a?|]" instead and reported it didn't help on his
> i686 machine (seems it helped the x86-64 one):
> https://bugzilla.redhat.com/show_bug.cgi?id=866988#c33
> 
> He now tried a recent mainline kernel I built 20 hours ago that is based
> on a git checkout from round about two days ago, reverts 82b212f4, and had
>  * fix-kswapd-endless-loop-on-higher-order-allocation.patch
>  * Avoid-waking-kswapd-for-THP-allocations-when.patch
>  * mm-compaction-Fix-return-value-of-capture_free_page.patch
> applied. In https://bugzilla.redhat.com/show_bug.cgi?id=866988#c39 and
> comment 41 he reported that this kernel on his i686 host showed 100%cpu
> usage by kswapd0 :-/
> 
> Build log for said kernel rpms (I quite sure I applied the patches
> properly, but you know: mistakes happen, so be careful, maybe I did
> something stupid somewhere...):
> http://kojipkgs.fedoraproject.org//work/tasks/8253/4738253/build.log
> 
> I know, this makes things more complicated again; but I wanted to let
> you guys know that some problem might still be lurking somewhere. Side
> note: right now it seems John with kernels that contain
> "Avoid-waking-kswapd-for-THP-allocations-when" can trigger the problem
> quicker (or only?) on i686 than on x86-64.

Humm, highmem...  Could this be the lowmem protection forcing kswapd
to reclaim highmem at DEF_PRIORITY (not useful but burns CPU) every
time it's woken up?

This requires somebody to wake up kswapd regularly, though and from
his report it's not quite clear to me if kswapd gets stuck or just has
really high CPU usage while the system is still under load.  The
initial post says he would expect "<5% cpu when idling" but his top
snippet in there shows there are other tasks running as well.  So does
it happen while the system is busy or when it's otherwise idle?

[ On the other hand, not waking kswapd from THP allocations seems to
  not show this problem on his i686 machine.  But it could also just
  be a tiny window of conditions aligning perfectly that drops kswapd
  in an endless loop, and the increased wakeups increase the
  probability of hitting it.  So, yeah, this would be good to know. ]

As the system is still responsive when this happens, any chance he
could capture /proc/zoneinfo and /proc/vmstat when kswapd goes
haywire?

Or even run perf record -a -g sleep 5; perf report > kswapd.txt?

Preferrably with this patch applied, to rule out faulty lowmem
protection:

buffer_heads_over_limit can put kswapd into reclaim, but it's ignored
when figuring out whether the zone is balanced and so priority levels
are not descended and no progress is ever made.

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 3b0aef4..73c4f5f 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2400,6 +2400,14 @@ static void age_active_anon(struct zone *zone, struct scan_control *sc)
 static bool zone_balanced(struct zone *zone, int order,
 			  unsigned long balance_gap, int classzone_idx)
 {
+	/*
+	 * If the number of buffer_heads in the machine exceeds the
+	 * maximum allowed level and this node has a highmem zone,
+	 * force kswapd to reclaim from it to relieve lowmem pressure.
+	 */
+	if (is_highmem(zone) && buffer_heads_over_limit)
+		return false;
+
 	if (!zone_watermark_ok_safe(zone, order, high_wmark_pages(zone) +
 				    balance_gap, classzone_idx, 0))
 		return false;
@@ -2586,17 +2594,6 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
 			 */
 			age_active_anon(zone, &sc);
 
-			/*
-			 * If the number of buffer_heads in the machine
-			 * exceeds the maximum allowed level and this node
-			 * has a highmem zone, force kswapd to reclaim from
-			 * it to relieve lowmem pressure.
-			 */
-			if (buffer_heads_over_limit && is_highmem_idx(i)) {
-				end_zone = i;
-				break;
-			}
-
 			if (!zone_balanced(zone, order, 0, 0)) {
 				end_zone = i;
 				break;
@@ -2672,8 +2669,7 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
 						COMPACT_SKIPPED)
 				testorder = 0;
 
-			if ((buffer_heads_over_limit && is_highmem_idx(i)) ||
-			    !zone_balanced(zone, testorder,
+			if (!zone_balanced(zone, testorder,
 					   balance_gap, end_zone)) {
 				shrink_zone(zone, &sc);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
