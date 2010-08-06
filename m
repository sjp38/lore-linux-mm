Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id BAC906B02A4
	for <linux-mm@kvack.org>; Sat,  7 Aug 2010 12:30:58 -0400 (EDT)
Date: Fri, 6 Aug 2010 20:44:52 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 07/13] writeback: explicit low bound for vm.dirty_ratio
Message-ID: <20100806124452.GC4717@localhost>
References: <20100805161051.501816677@intel.com>
 <20100805162433.673243074@intel.com>
 <20100805163401.e9754032.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100805163401.e9754032.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Dave Chinner <david@fromorbit.com>, Christoph Hellwig <hch@infradead.org>, Mel Gorman <mel@csn.ul.ie>, Chris Mason <chris.mason@oracle.com>, Jens Axboe <axboe@kernel.dk>, Jan Kara <jack@suse.cz>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, Aug 06, 2010 at 07:34:01AM +0800, Andrew Morton wrote:
> On Fri, 06 Aug 2010 00:10:58 +0800
> Wu Fengguang <fengguang.wu@intel.com> wrote:
> 
> > Force a user visible low bound of 5% for the vm.dirty_ratio interface.
> > 
> > Currently global_dirty_limits() applies a low bound of 5% for
> > vm_dirty_ratio.  This is not very user visible -- if the user sets
> > vm.dirty_ratio=1, the operation seems to succeed but will be rounded up
> > to 5% when used.
> > 
> > Another problem is inconsistency: calc_period_shift() uses the plain
> > vm_dirty_ratio value, which may be a problem when vm.dirty_ratio is set
> > to < 5 by the user.
> 
> The changelog describes the old behaviour but doesn't describe the
> proposed new behaviour.

Yeah, fixed below.

> > --- linux-next.orig/kernel/sysctl.c	2010-08-05 22:48:34.000000000 +0800
> > +++ linux-next/kernel/sysctl.c	2010-08-05 22:48:47.000000000 +0800
> > @@ -126,6 +126,7 @@ static int ten_thousand = 10000;
> >  
> >  /* this is needed for the proc_doulongvec_minmax of vm_dirty_bytes */
> >  static unsigned long dirty_bytes_min = 2 * PAGE_SIZE;
> > +static int dirty_ratio_min = 5;
> >  
> >  /* this is needed for the proc_dointvec_minmax for [fs_]overflow UID and GID */
> >  static int maxolduid = 65535;
> > @@ -1031,7 +1032,7 @@ static struct ctl_table vm_table[] = {
> >  		.maxlen		= sizeof(vm_dirty_ratio),
> >  		.mode		= 0644,
> >  		.proc_handler	= dirty_ratio_handler,
> > -		.extra1		= &zero,
> > +		.extra1		= &dirty_ratio_min,
> >  		.extra2		= &one_hundred,
> >  	},
> 
> I forget how the procfs core handles this.  Presumably the write will
> now fail with -EINVAL or something?

Right.
         # echo 111 > /proc/sys/vm/dirty_ratio
         echo: write error: invalid argument

> So people's scripts will now error out and their space shuttles will
> crash?

Looks like a serious problem. I'm now much more reserved on pushing
this patch :)

> All of which illustrates why it's important to fully describe changes
> in the changelog!  So people can consider and discuss the end-user
> implications of a change.

Good point. Here is the patch with updated changelog.

Thanks,
Fengguang
---
Subject: writeback: explicit low bound for vm.dirty_ratio
From: Wu Fengguang <fengguang.wu@intel.com>
Date: Thu Jul 15 10:28:57 CST 2010

Force a user visible low bound of 5% for the vm.dirty_ratio interface.

This is an interface change. When doing

	echo N > /proc/sys/vm/dirty_ratio

where N < 5, the old behavior is pretend to accept the value, while
the new behavior is to reject it explicitly with -EINVAL.  This will
possibly break user space if they checks the return value.

Currently global_dirty_limits() applies a low bound of 5% for
vm_dirty_ratio.  This is not very user visible -- if the user sets
vm.dirty_ratio=1, the operation seems to succeed but will be rounded up
to 5% when used.

Another problem is inconsistency: calc_period_shift() uses the plain
vm_dirty_ratio value, which may be a problem when vm.dirty_ratio is set
to < 5 by the user.

CC: Peter Zijlstra <a.p.zijlstra@chello.nl>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 kernel/sysctl.c     |    3 ++-
 mm/page-writeback.c |   10 ++--------
 2 files changed, 4 insertions(+), 9 deletions(-)

--- linux-next.orig/kernel/sysctl.c	2010-08-05 22:48:34.000000000 +0800
+++ linux-next/kernel/sysctl.c	2010-08-05 22:48:47.000000000 +0800
@@ -126,6 +126,7 @@ static int ten_thousand = 10000;
 
 /* this is needed for the proc_doulongvec_minmax of vm_dirty_bytes */
 static unsigned long dirty_bytes_min = 2 * PAGE_SIZE;
+static int dirty_ratio_min = 5;
 
 /* this is needed for the proc_dointvec_minmax for [fs_]overflow UID and GID */
 static int maxolduid = 65535;
@@ -1031,7 +1032,7 @@ static struct ctl_table vm_table[] = {
 		.maxlen		= sizeof(vm_dirty_ratio),
 		.mode		= 0644,
 		.proc_handler	= dirty_ratio_handler,
-		.extra1		= &zero,
+		.extra1		= &dirty_ratio_min,
 		.extra2		= &one_hundred,
 	},
 	{
--- linux-next.orig/mm/page-writeback.c	2010-08-05 22:48:42.000000000 +0800
+++ linux-next/mm/page-writeback.c	2010-08-05 22:48:47.000000000 +0800
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

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
