Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id D42F16B007B
	for <linux-mm@kvack.org>; Mon,  2 Nov 2009 11:05:41 -0500 (EST)
Date: Mon, 2 Nov 2009 16:05:34 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 3/3] vmscan: Force kswapd to take notice faster when
	high-order watermarks are being hit
Message-ID: <20091102160534.GA22046@csn.ul.ie>
References: <1256650833-15516-1-git-send-email-mel@csn.ul.ie> <1256650833-15516-4-git-send-email-mel@csn.ul.ie> <20091027131905.410ec04a.akpm@linux-foundation.org> <20091028102936.GS8900@csn.ul.ie> <20091028124756.7af44b6b.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20091028124756.7af44b6b.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: stable@kernel.org, linux-kernel@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, Frans Pop <elendil@planet.nl>, Jiri Kosina <jkosina@suse.cz>, Sven Geggus <lists@fuchsschwanzdomain.de>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, Tobias Oetiker <tobi@oetiker.ch>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Stephan von Krawczynski <skraw@ithnet.com>, Kernel Testers List <kernel-testers@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, Oct 28, 2009 at 12:47:56PM -0700, Andrew Morton wrote:
> On Wed, 28 Oct 2009 10:29:36 +0000
> Mel Gorman <mel@csn.ul.ie> wrote:
> 
> > On Tue, Oct 27, 2009 at 01:19:05PM -0700, Andrew Morton wrote:
> > > On Tue, 27 Oct 2009 13:40:33 +0000
> > > Mel Gorman <mel@csn.ul.ie> wrote:
> > > 
> > > > When a high-order allocation fails, kswapd is kicked so that it reclaims
> > > > at a higher-order to avoid direct reclaimers stall and to help GFP_ATOMIC
> > > > allocations. Something has changed in recent kernels that affect the timing
> > > > where high-order GFP_ATOMIC allocations are now failing with more frequency,
> > > > particularly under pressure. This patch forces kswapd to notice sooner that
> > > > high-order allocations are occuring.
> > > > 
> > > 
> > > "something has changed"?  Shouldn't we find out what that is?
> > > 
> > 
> > We've been trying but the answer right now is "lots". There were some
> > changes in the allocator itself which were unintentional and fixed in
> > patches 1 and 2 of this series. The two other major changes are
> > 
> > iwlagn is now making high order GFP_ATOMIC allocations which didn't
> > help. This is being addressed separetly and I believe the relevant
> > patches are now in mainline.
> > 
> > The other major change appears to be in page writeback. Reverting
> > commits 373c0a7e + 8aa7e847 significantly helps one bug reporter but
> > it's still unknown as to why that is.
> 
> Peculiar.  Those changes are fairly remote from large-order-GFP_ATOMIC
> allocations.
> 

Indeed. The significance of the patch seems to be how long and how often
processes sleep in the page allocator and what kswapd is doing.

> > ...
> >
> > Wireless drivers in particularly seem to be very
> > high-order GFP_ATOMIC happy.
> 
> It would be nice if we could find a way of preventing people from
> attempting high-order atomic allocations in the first place - it's a bit
> of a trap.
> 

True.

> Maybe add a runtime warning which is suppressable by GFP_NOWARN (or a
> new flag), then either fix existing callers or, after review, add the
> flag.
> 
> Of course, this might just end up with people adding these hopeless
> allocation attempts and just setting the nowarn flag :(
> 

That's the difficulty but we should consider adding such warnings or
maintaining in-kernel the unique GFP_ATOMIC callers and their frequency.
It would require a lot of monitoring though and a fair amount of stick
beatings to get the callers corrected.

> > > If one where to whack a printk in that `if' block, how often would it
> > > trigger, and under what circumstances?
> > 
> > I don't know the frequency. The circumstances are "under load" when
> > there are drivers depending on high-order allocations but the
> > reproduction cases are unreliable.
> > 
> > Do you want me to slap together a patch that adds a vmstat counter for
> > this? I can then ask future bug reporters to examine that counter and see
> > if it really is a major factor for a lot of people or not.
> 
> Something like that, if it will help us understand what's going on.  I
> don't see a permanent need for that instrumentation but while this
> problem is still in the research stage, sure, lard it up with debug
> stuff?
> 

I have a candidate patch below. One of the reasons it took so long to
get out is what I found on the way developing the patch. I had added a
debugging patch to printk what kswapd was doing. One massive difference I
noted was that in 2.6.30 kswapd often went to sleep for 25 jiffies (HZ/10)
in balance_pgdat(). In 2.6.31 and particularly in mainline, it sleeps less
and for shorter intervals. When the sleep interval is low, kswapd notices
the watermarks are ok and goes back to sleep far quicker than 2.6.30
did.

One consequence of this is that kswapd is going back to sleep just as the
high watermark is clear but if it had slept for longer it would have found
that the zone quickly went back below the high watermark due to parallel
allocators. i.e. in 2.6.30, kswapd worked for longer than current mainline.

To see if there is any merit to this, the patch below also counts the number
of times that kswapd prematurely went to sleep. If kswapd is routinely going
to sleep with watermarks not being met, one correction might be to make
balance_pgdat() unconditionally sleep for HZ/10 instead of sleeping based on
congestion as this would bring kswapd closer in line with 2.6.30. Of course,
the pain in the neck is that the premature-sleep-check itself is happening
too quickly.

> It's very important to understand _why_ the VM got worse.  And, of
> course, to fix that up.  But, separately, we should find a way of
> preventing developers from using these very unreliable allocations.
> 

Agreed. I think the main thing that has changed is timing.  congestion_wait()
is now doing the "right" thing and sleeping until congestion is
cleared. Unfortunately, it feels like some users of congestion_wait(),
such as kswapd, really wanted to sleep for a fixed interval and not based
on congestion. The comment in balance_pgdat() appears to indicate this was
the expected behaviour.

==== CUT HERE ====
vmscan: Help debug kswapd issues by counting number of rewakeups and premature sleeps

There is a growing amount of anedotal evidence that high-order atomic
allocation failures have been increasing since 2.6.31-rc1. The two
strongest possibilities are a marked increase in the number of
GFP_ATOMIC allocations and alterations in timing. Debugging printk
patches have shown for example that kswapd is sleeping for shorter
intervals and going to sleep when watermarks are still not being met.

This patch adds two kswapd counters to help identify if timing is an
issue. The first counter kswapd_highorder_rewakeup counts the number of
times that kswapd stops reclaiming at one order and restarts at a higher
order. The second counter kswapd_slept_prematurely counts the number of
times kswapd went to sleep when the high watermark was not met.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
--- 
 include/linux/vmstat.h |    1 +
 mm/vmscan.c            |   17 ++++++++++++++++-
 mm/vmstat.c            |    2 ++
 3 files changed, 19 insertions(+), 1 deletion(-)

diff --git a/include/linux/vmstat.h b/include/linux/vmstat.h
index 2d0f222..2e0d18d 100644
--- a/include/linux/vmstat.h
+++ b/include/linux/vmstat.h
@@ -40,6 +40,7 @@ enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
 		PGSCAN_ZONE_RECLAIM_FAILED,
 #endif
 		PGINODESTEAL, SLABS_SCANNED, KSWAPD_STEAL, KSWAPD_INODESTEAL,
+		KSWAPD_HIGHORDER_REWAKEUP, KSWAPD_PREMATURE_SLEEP,
 		PAGEOUTRUN, ALLOCSTALL, PGROTATED,
 #ifdef CONFIG_HUGETLB_PAGE
 		HTLB_BUDDY_PGALLOC, HTLB_BUDDY_PGALLOC_FAIL,
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 7eceb02..cf40136 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2021,6 +2021,7 @@ loop_again:
 			 * if it is known that higher orders are required
 			 */
 			if (pgdat->kswapd_max_order > order) {
+				count_vm_event(KSWAPD_HIGHORDER_REWAKEUP);
 				all_zones_ok = 1;
 				goto out;
 			}
@@ -2124,6 +2125,17 @@ out:
 	return sc.nr_reclaimed;
 }
 
+static int kswapd_sleeping_prematurely(int order)
+{
+	struct zone *zone;
+	for_each_populated_zone(zone)
+		if (!zone_watermark_ok(zone, order, high_wmark_pages(zone),
+								0, 0))
+			return 1;
+
+	return 0;
+}
+
 /*
  * The background pageout daemon, started as a kernel thread
  * from the init process.
@@ -2183,8 +2195,11 @@ static int kswapd(void *p)
 			 */
 			order = new_order;
 		} else {
-			if (!freezing(current))
+			if (!freezing(current)) {
+				if (kswapd_sleeping_prematurely(order))
+					count_vm_event(KSWAPD_PREMATURE_SLEEP);
 				schedule();
+			}
 
 			order = pgdat->kswapd_max_order;
 		}
diff --git a/mm/vmstat.c b/mm/vmstat.c
index c81321f..fa881c5 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -683,6 +683,8 @@ static const char * const vmstat_text[] = {
 	"slabs_scanned",
 	"kswapd_steal",
 	"kswapd_inodesteal",
+	"kswapd_highorder_rewakeup",
+	"kswapd_slept_prematurely",
 	"pageoutrun",
 	"allocstall",
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
