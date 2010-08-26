Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 0400C6B02BF
	for <linux-mm@kvack.org>; Wed, 25 Aug 2010 21:29:51 -0400 (EDT)
Date: Thu, 26 Aug 2010 09:29:45 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH] writeback: remove the internal 5% low bound on
 dirty_ratio
Message-ID: <20100826012945.GA7859@localhost>
References: <20100820032506.GA6662@localhost>
 <201008241620.54048.kernel@kolivas.org>
 <20100824071440.GA14598@localhost>
 <201008251840.00532.kernel@kolivas.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201008251840.00532.kernel@kolivas.org>
Sender: owner-linux-mm@kvack.org
To: Con Kolivas <kernel@kolivas.org>
Cc: Jan Kara <jack@suse.cz>, Neil Brown <neilb@suse.de>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "Wu, Fengguang" <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "david@fromorbit.com" <david@fromorbit.com>, "hch@lst.de" <hch@lst.de>, "axboe@kernel.dk" <axboe@kernel.dk>
List-ID: <linux-mm.kvack.org>

On Wed, Aug 25, 2010 at 04:40:00PM +0800, Con Kolivas wrote:
> On Tue, 24 Aug 2010 05:14:40 pm you wrote:
> > On Tue, Aug 24, 2010 at 02:20:54PM +0800, Con Kolivas wrote:
> > > On Mon, 23 Aug 2010 05:15:35 pm you wrote:
> > > > On Mon, Aug 23, 2010 at 02:30:40PM +0800, Con Kolivas wrote:
> > > > > On Mon, 23 Aug 2010 04:23:59 pm Wu Fengguang wrote:
> > > > > > On Mon, Aug 23, 2010 at 12:42:48PM +0800, Neil Brown wrote:
> > > > > > > On Fri, 20 Aug 2010 15:50:54 +1000
> > > > > > >
> > > > > > > Con Kolivas <kernel@kolivas.org> wrote:
> > > > > > > > On Fri, 20 Aug 2010 02:13:25 pm KOSAKI Motohiro wrote:
> > > > > > > > > > The dirty_ratio was silently limited to >= 5%. This is not
> > > > > > > > > > a user expected behavior. Let's rip it.
> > > > > > > > > >
> > > > > > > > > > It's not likely the user space will depend on the old
> > > > > > > > > > behavior. So the risk of breaking user space is very low.
> > > > > > > > > >
> > > > > > > > > > CC: Jan Kara <jack@suse.cz>
> > > > > > > > > > CC: Neil Brown <neilb@suse.de>
> > > > > > > > > > Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> > > > > > > > >
> > > > > > > > > Thank you.
> > > > > > > > > 	Reviewed-by: KOSAKI Motohiro
> > > > > > > > > <kosaki.motohiro@jp.fujitsu.com>
> > > > > > > >
> > > > > > > > I have tried to do this in the past, and setting this value to
> > > > > > > > 0 on some machines caused the machine to come to a complete
> > > > > > > > standstill with small writes to disk. It seemed there was some
> > > > > > > > kind of "minimum" amount of data required by the VM before
> > > > > > > > anything would make it to the disk and I never quite found out
> > > > > > > > where that blockade occurred. This was some time ago (3 years
> > > > > > > > ago) so I'm not sure if the problem has since been fixed in the
> > > > > > > > VM since then. I suggest you do some testing with this value
> > > > > > > > set to zero before approving this change.
> > > > > >
> > > > > > You are right, vm.dirty_ratio=0 will block applications for ever..
> > > > >
> > > > > Indeed. And while you shouldn't set the lower limit to zero to avoid
> > > > > this problem, it doesn't answer _why_ this happens. What is this
> > > > > "minimum write" that blocks everything, will 1% be enough, and is it
> > > > > hiding another real bug somewhere in the VM?
> > > >
> > > > Good question.
> > > > This simple change will unblock the application even with
> > > > vm_dirty_ratio=0.
> > > >
> > > > # echo 0 > /proc/sys/vm/dirty_ratio
> > > > # echo 0 > /proc/sys/vm/dirty_background_ratio
> > > > # vmmon nr_dirty nr_writeback nr_unstable
> > > >
> > > >         nr_dirty     nr_writeback      nr_unstable
> > > >                0              444             1369
> > > >               37               37              326
> > > >                0                0               37
> > > >               74              772              694
> > > >                0                0               19
> > > >                0                0             1406
> > > >                0                0               23
> > > >                0                0                0
> > > >                0              370              186
> > > >               74             1073             1221
> > > >                0               12               26
> > > >                0              703             1147
> > > >               37                0              999
> > > >               37               37             1517
> > > >                0              888               63
> > > >                0                0                0
> > > >                0                0               20
> > > >               37                0                0
> > > >               37               74             1776
> > > >                0                0                8
> > > >               37              629              333
> > > >                0               12               19
> > > >
> > > > Even with it, the 1% explicit bound still looks reasonable for me.
> > > > Who will want to set it to 0%? That would destroy IO inefficient.
> > >
> > > Thanks for your work in this area. I'll experiment with these later.
> > > There are low latency applications that would benefit with it set to
> > > zero.
> >
> > It might be useful to some users. Shall we give the rope to users, heh?
> >
> > Note that for these applications, they may well use
> > /proc/sys/vm/dirty_bytes for more fine grained control. That interface only
> > imposes a low limit of 2 pages.
> 
> I don't see why there needs to be a limit. Users fiddling with sysctls should 
> know what they're messing with, and there may well be a valid use out there 
> somewhere for it.

OK, the following patch gives users the full freedom. I tested 1
single dirtier and 9 parallel dirtiers, the system remains alive, but
with much slower IO throughput. Maybe not all users care IO performance
in all situations?

Thanks,
Fengguang
---
writeback: remove the internal 5% low bound on dirty_ratio

The dirty_ratio was silently limited in global_dirty_limits() to >= 5%.
This is not a user expected behavior. And it's inconsistent with
calc_period_shift(), which uses the plain vm_dirty_ratio value.

Let's rip the internal bound.

At the same time, fix balance_dirty_pages() to work with the
dirty_thresh=0 case. This allows applications to proceed when
dirty+writeback pages are all cleaned.

CC: Jan Kara <jack@suse.cz>
CC: Neil Brown <neilb@suse.de>
CC: Con Kolivas <kernel@kolivas.org>
CC: Rik van Riel <riel@redhat.com>
CC: Peter Zijlstra <a.p.zijlstra@chello.nl>
CC: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 mm/page-writeback.c |   14 ++++----------
 1 file changed, 4 insertions(+), 10 deletions(-)

--- linux-next.orig/mm/page-writeback.c	2010-08-26 08:37:31.000000000 +0800
+++ linux-next/mm/page-writeback.c	2010-08-26 08:37:55.000000000 +0800
@@ -415,14 +415,8 @@ void global_dirty_limits(unsigned long *
 
 	if (vm_dirty_bytes)
 		dirty = DIV_ROUND_UP(vm_dirty_bytes, PAGE_SIZE);
-	else {
-		int dirty_ratio;
-
-		dirty_ratio = vm_dirty_ratio;
-		if (dirty_ratio < 5)
-			dirty_ratio = 5;
-		dirty = (dirty_ratio * available_memory) / 100;
-	}
+	else
+		dirty = (vm_dirty_ratio * available_memory) / 100;
 
 	if (dirty_background_bytes)
 		background = DIV_ROUND_UP(dirty_background_bytes, PAGE_SIZE);
@@ -542,8 +536,8 @@ static void balance_dirty_pages(struct a
 		 * the last resort safeguard.
 		 */
 		dirty_exceeded =
-			(bdi_nr_reclaimable + bdi_nr_writeback >= bdi_thresh)
-			|| (nr_reclaimable + nr_writeback >= dirty_thresh);
+			(bdi_nr_reclaimable + bdi_nr_writeback > bdi_thresh)
+			|| (nr_reclaimable + nr_writeback > dirty_thresh);
 
 		if (!dirty_exceeded)
 			break;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
