Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 3EBCA6007DC
	for <linux-mm@kvack.org>; Mon, 23 Aug 2010 03:15:41 -0400 (EDT)
Date: Mon, 23 Aug 2010 15:15:35 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH] writeback: remove the internal 5% low bound on
 dirty_ratio
Message-ID: <20100823071534.GA24566@localhost>
References: <20100820032506.GA6662@localhost>
 <20100823144248.15fbb700@notabene>
 <20100823062359.GA19586@localhost>
 <201008231630.40892.kernel@kolivas.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201008231630.40892.kernel@kolivas.org>
Sender: owner-linux-mm@kvack.org
To: Con Kolivas <kernel@kolivas.org>
Cc: Neil Brown <neilb@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "riel@redhat.com" <riel@redhat.com>, "david@fromorbit.com" <david@fromorbit.com>, "hch@lst.de" <hch@lst.de>, "axboe@kernel.dk" <axboe@kernel.dk>
List-ID: <linux-mm.kvack.org>

On Mon, Aug 23, 2010 at 02:30:40PM +0800, Con Kolivas wrote:
> On Mon, 23 Aug 2010 04:23:59 pm Wu Fengguang wrote:
> > On Mon, Aug 23, 2010 at 12:42:48PM +0800, Neil Brown wrote:
> > > On Fri, 20 Aug 2010 15:50:54 +1000
> > >
> > > Con Kolivas <kernel@kolivas.org> wrote:
> > > > On Fri, 20 Aug 2010 02:13:25 pm KOSAKI Motohiro wrote:
> > > > > > The dirty_ratio was silently limited to >= 5%. This is not a user
> > > > > > expected behavior. Let's rip it.
> > > > > >
> > > > > > It's not likely the user space will depend on the old behavior.
> > > > > > So the risk of breaking user space is very low.
> > > > > >
> > > > > > CC: Jan Kara <jack@suse.cz>
> > > > > > CC: Neil Brown <neilb@suse.de>
> > > > > > Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> > > > >
> > > > > Thank you.
> > > > > 	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> > > >
> > > > I have tried to do this in the past, and setting this value to 0 on
> > > > some machines caused the machine to come to a complete standstill with
> > > > small writes to disk. It seemed there was some kind of "minimum" amount
> > > > of data required by the VM before anything would make it to the disk
> > > > and I never quite found out where that blockade occurred. This was some
> > > > time ago (3 years ago) so I'm not sure if the problem has since been
> > > > fixed in the VM since then. I suggest you do some testing with this
> > > > value set to zero before approving this change.
> >
> > You are right, vm.dirty_ratio=0 will block applications for ever..
> 
> Indeed. And while you shouldn't set the lower limit to zero to avoid this 
> problem, it doesn't answer _why_ this happens. What is this "minimum write" 
> that blocks everything, will 1% be enough, and is it hiding another real bug 
> somewhere in the VM?

Good question.
This simple change will unblock the application even with vm_dirty_ratio=0.

# echo 0 > /proc/sys/vm/dirty_ratio
# echo 0 > /proc/sys/vm/dirty_background_ratio                                               
# vmmon nr_dirty nr_writeback nr_unstable

        nr_dirty     nr_writeback      nr_unstable
               0              444             1369
              37               37              326
               0                0               37
              74              772              694
               0                0               19
               0                0             1406
               0                0               23
               0                0                0
               0              370              186
              74             1073             1221
               0               12               26
               0              703             1147
              37                0              999
              37               37             1517
               0              888               63
               0                0                0
               0                0               20
              37                0                0
              37               74             1776
               0                0                8
              37              629              333
               0               12               19

Even with it, the 1% explicit bound still looks reasonable for me.
Who will want to set it to 0%? That would destroy IO inefficient.

Thanks,
Fengguang
---
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -542,8 +536,8 @@ static void balance_dirty_pages(struct address_space *mapping,
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
