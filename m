Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 558D36007DC
	for <linux-mm@kvack.org>; Mon, 23 Aug 2010 02:24:06 -0400 (EDT)
Date: Mon, 23 Aug 2010 14:23:59 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH] writeback: remove the internal 5% low bound on
 dirty_ratio
Message-ID: <20100823062359.GA19586@localhost>
References: <20100820032506.GA6662@localhost>
 <20100820131249.5FF4.A69D9226@jp.fujitsu.com>
 <201008201550.54164.kernel@kolivas.org>
 <20100823144248.15fbb700@notabene>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100823144248.15fbb700@notabene>
Sender: owner-linux-mm@kvack.org
To: Neil Brown <neilb@suse.de>
Cc: Con Kolivas <kernel@kolivas.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "riel@redhat.com" <riel@redhat.com>, "david@fromorbit.com" <david@fromorbit.com>, "hch@lst.de" <hch@lst.de>, "axboe@kernel.dk" <axboe@kernel.dk>
List-ID: <linux-mm.kvack.org>

On Mon, Aug 23, 2010 at 12:42:48PM +0800, Neil Brown wrote:
> On Fri, 20 Aug 2010 15:50:54 +1000
> Con Kolivas <kernel@kolivas.org> wrote:
> 
> > On Fri, 20 Aug 2010 02:13:25 pm KOSAKI Motohiro wrote:
> > > > The dirty_ratio was silently limited to >= 5%. This is not a user
> > > > expected behavior. Let's rip it.
> > > >
> > > > It's not likely the user space will depend on the old behavior.
> > > > So the risk of breaking user space is very low.
> > > >
> > > > CC: Jan Kara <jack@suse.cz>
> > > > CC: Neil Brown <neilb@suse.de>
> > > > Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> > >
> > > Thank you.
> > > 	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> > 
> > I have tried to do this in the past, and setting this value to 0 on some 
> > machines caused the machine to come to a complete standstill with small 
> > writes to disk. It seemed there was some kind of "minimum" amount of data 
> > required by the VM before anything would make it to the disk and I never 
> > quite found out where that blockade occurred. This was some time ago (3 years 
> > ago) so I'm not sure if the problem has since been fixed in the VM since 
> > then. I suggest you do some testing with this value set to zero before 
> > approving this change.

You are right, vm.dirty_ratio=0 will block applications for ever..

> 
>  If it is appropriate to have a lower limit, that should be imposed where
>  the sysctl is defined in kernel/sysctl.c, not imposed after the fact where
>  the value is used.
> 
>  As we now have dirty_bytes which over-rides dirty_ratio, there is little
>  cost in having a lower_limit for dirty_ratio - it could even stay at 5% -
>  but it really shouldn't be silent.  Writing a number below the limit to the
>  sysctl file should fail.

How about imposing an explicit bound of 1%? That's more natural and
its risk of breaking user space should be lower than 5%.

Thanks,
Fengguang
---
writeback: remove the internal 5% low bound on dirty_ratio

The dirty_ratio was silently limited in global_dirty_limits() to >= 5%. This
is not a user expected behavior. And it's inconsistent with calc_period_shift(),
which uses the plain vm_dirty_ratio value. So let's rip the internal bound.

At the same time, force a user visible low bound of 1% for the vm.dirty_ratio
interface. Applications trying to write 0 will be rejected with -EINVAL. This
will break user space applications if they
1) try to write 0 to vm.dirty_ratio
2) and check the return value
That is very weird combination, so the risk of breaking user space is low.

CC: Jan Kara <jack@suse.cz>
CC: Neil Brown <neilb@suse.de>
CC: Rik van Riel <riel@redhat.com>
CC: Con Kolivas <kernel@kolivas.org>
CC: Peter Zijlstra <a.p.zijlstra@chello.nl>
CC: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 kernel/sysctl.c     |    2 +-
 mm/page-writeback.c |   10 ++--------
 2 files changed, 3 insertions(+), 9 deletions(-)

--- linux-next.orig/mm/page-writeback.c	2010-08-20 20:14:11.000000000 +0800
+++ linux-next/mm/page-writeback.c	2010-08-23 10:31:01.000000000 +0800
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
--- linux-next.orig/kernel/sysctl.c	2010-08-23 14:06:11.000000000 +0800
+++ linux-next/kernel/sysctl.c	2010-08-23 14:07:30.000000000 +0800
@@ -1029,7 +1029,7 @@ static struct ctl_table vm_table[] = {
 		.maxlen		= sizeof(vm_dirty_ratio),
 		.mode		= 0644,
 		.proc_handler	= dirty_ratio_handler,
-		.extra1		= &zero,
+		.extra1		= &one,
 		.extra2		= &one_hundred,
 	},
 	{

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
