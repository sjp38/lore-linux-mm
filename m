Message-ID: <386462833.05717@ustc.edu.cn>
Date: Tue, 7 Aug 2007 13:00:33 +0800
From: Fengguang Wu <fengguang.wu@gmail.com>
Subject: Re: make swappiness safer to use
Message-ID: <20070807050032.GA16179@mail.ustc.edu.cn>
References: <20070731215228.GU6910@v2.random> <20070731151244.3395038e.akpm@linux-foundation.org> <20070731224052.GW6910@v2.random> <20070731155109.228b4f19.akpm@linux-foundation.org> <20070731230251.GX6910@v2.random> <20070801011925.GB20109@mail.ustc.edu.cn> <20070801012222.GA20565@mail.ustc.edu.cn> <20070801013208.GA20085@mail.ustc.edu.cn> <20070801023315.GB6910@v2.random> <20070806112154.f8c5bcdc.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070806112154.f8c5bcdc.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <andrea@suse.de>, linux-mm@kvack.org, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Mon, Aug 06, 2007 at 11:21:54AM -0700, Andrew Morton wrote:
> On Wed, 1 Aug 2007 04:33:15 +0200 Andrea Arcangeli <andrea@suse.de> wrote:
> 
> > On Wed, Aug 01, 2007 at 09:32:08AM +0800, Fengguang Wu wrote:
> > > Here's the updated patch without underflows.
> > 
> > this is ok.
> 
> I lost the plot a bit here.  Can I please have a resend of the full and
> final patch?

OK, here it is.

===
From: Andrea Arcangeli <andrea@suse.de>
Subject: make swappiness safer to use

Swappiness isn't a safe sysctl. Setting it to 0 for example can hang a
system. That's a corner case but even setting it to 10 or lower can
waste enormous amounts of cpu without making much progress. We've
customers who wants to use swappiness but they can't because of the
current implementation (if you change it so the system stops swapping
it really stops swapping and nothing works sane anymore if you really
had to swap something to make progress).

This patch from Kurt Garloff makes swappiness safer to use (no more
huge cpu usage or hangs with low swappiness values).

I think the prev_priority can also be nuked since it wastes 4 bytes
per zone (that would be an incremental patch but I wait the
nr_scan_[in]active to be nuked first for similar reasons). Clearly
somebody at some point noticed how broken that thing was and they had
to add min(priority, prev_priority) to give it some reliability, but
they didn't go the last mile to nuke prev_priority too. Calculating
distress only in function of not-racy priority is correct and sure
more than enough without having to add randomness into the equation.

Patch is tested on older kernels but it compiles and it's quite simple
so...

Overall I'm not very satisified by the swappiness tweak, since it
doesn't rally do anything with the dirty pagecache that may be
inactive. We need another kind of tweak that controls the inactive
scan and tunes the can_writepage feature (not yet in mainline despite
having submitted it a few times), not only the active one. That new
tweak will tell the kernel how hard to scan the inactive list for pure
clean pagecache (something the mainline kernel isn't capable of
yet). We already have that feature working in all our enterprise
kernels with the default reasonable tune, or they can't even run a
readonly backup with tar without triggering huge write I/O. I think it
should be available also in mainline later.

Cc: Nick Piggin <npiggin@suse.de>
Cc: Andrew Morton <akpm@osdl.org>
Signed-off-by: Kurt Garloff <garloff@suse.de>
Signed-off-by: Andrea Arcangeli <andrea@suse.de>
Signed-off-by: Fengguang Wu <wfg@mail.ustc.edu.cn>

---
 mm/vmscan.c |   41 +++++++++++++++++++++++++++++++++++++++++
 1 file changed, 41 insertions(+)

--- linux-2.6.22-rc6-mm1.orig/mm/vmscan.c
+++ linux-2.6.22-rc6-mm1/mm/vmscan.c
@@ -887,6 +887,7 @@ static void shrink_active_list(unsigned 
 		long mapped_ratio;
 		long distress;
 		long swap_tendency;
+		long imbalance;
 
 		if (zone_is_near_oom(zone))
 			goto force_reclaim_mapped;
@@ -922,6 +923,46 @@ static void shrink_active_list(unsigned 
 		swap_tendency = mapped_ratio / 2 + distress + sc->swappiness;
 
 		/*
+		 * If there's huge imbalance between active and inactive
+		 * (think active 100 times larger than inactive) we should
+		 * become more permissive, or the system will take too much
+		 * cpu before it start swapping during memory pressure.
+		 * Distress is about avoiding early-oom, this is about
+		 * making swappiness graceful despite setting it to low
+		 * values.
+		 *
+		 * Avoid div by zero with nr_inactive+1, and max resulting
+		 * value is vm_total_pages.
+		 */
+		imbalance  = zone_page_state(zone, NR_ACTIVE);
+		imbalance /= zone_page_state(zone, NR_INACTIVE) + 1;
+
+		/*
+		 * Reduce the effect of imbalance if swappiness is low,
+		 * this means for a swappiness very low, the imbalance
+		 * must be much higher than 100 for this logic to make
+		 * the difference.
+		 *
+		 * Max temporary value is vm_total_pages*100.
+		 */
+		imbalance *= (vm_swappiness + 1);
+		imbalance /= 100;
+
+		/*
+		 * If not much of the ram is mapped, makes the imbalance
+		 * less relevant, it's high priority we refill the inactive
+		 * list with mapped pages only in presence of high ratio of
+		 * mapped pages.
+		 *
+		 * Max temporary value is vm_total_pages*100.
+		 */
+		imbalance *= mapped_ratio;
+		imbalance /= 100;
+
+		/* apply imbalance feedback to swap_tendency */
+		swap_tendency += imbalance;
+
+		/*
 		 * Now use this metric to decide whether to start moving mapped
 		 * memory onto the inactive list.
 		 */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
