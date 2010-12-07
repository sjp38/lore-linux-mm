Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 860776B0087
	for <linux-mm@kvack.org>; Tue,  7 Dec 2010 08:11:42 -0500 (EST)
Date: Tue, 7 Dec 2010 21:11:36 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH] writeback: safety margin for bdi stat errors
Message-ID: <20101207131136.GA20366@localhost>
References: <20101205064430.GA15027@localhost>
 <4CFB9BE1.3030902@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4CFB9BE1.3030902@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Jens Axboe <axboe@kernel.dk>, Mel Gorman <mel@csn.ul.ie>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Hellwig <hch@lst.de>, linux-mm <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Sun, Dec 05, 2010 at 10:04:17PM +0800, Rik van Riel wrote:
> On 12/05/2010 01:44 AM, Wu Fengguang wrote:
> > I noticed that my NFSROOT test system goes slow responding when there
> > is heavy dd to a local disk. Traces show that the NFSROOT's bdi_limit
> > is near 0 and many tasks in the system are repeatedly stuck in
> > balance_dirty_pages().
> >
> > There are two related problems:
> >
> > - light dirtiers at one device (more often than not the rootfs) get
> >    heavily impacted by heavy dirtiers on another independent device
> >
> > - the light dirtied device does heavy throttling because bdi_limit=0,
> >    and the heavy throttling may in turn withhold its bdi_limit in 0 as
> >    it cannot dirty fast enough to grow up the bdi's proportional weight.
> >
> > Fix it by introducing some "low pass" gate, which is a small (<=8MB)
> > value reserved by others and can be safely "stole" from the current
> > global dirty margin.  It does not need to be big to help the bdi gain
> > its initial weight.
> 
> Makes a lot of sense to me.
> 
> Acked-by: Rik van Riel <riel@redhat.com>

Thanks. I find the problem when testing the IO-less balance_dirty_pages(). 
The old kernel may behave a bit better, but should still benefit from
the patch.

Now I find one more problem..with a fix.

---
Subject: writeback: safety margin for bdi stat error
Date: Tue Dec 07 20:38:28 CST 2010

In a simple dd test on a 8p system with "mem=256M", I find the light
dirtier tasks on the root fs are all heavily throttled. That happens
because the global limit is exceeded. It's unbelievable at first sight,
because the test fs doing the heavy dd is under its bdi limit.  After
doing some tracing, it's discovered that

	bdi_dirty < bdi_limit < global_limit < nr_dirty

So the root cause is, the bdi_dirty is well under nr_dirty due to
accounting errors. They should be very close because there is only one
heavy dirtied bdi in the system. This can be fixed by using
bdi_stat_sum(), however that's costly on large NUMA machines. So do a
less costly fix of lowering the bdi limit, so that the accounting
errors won't lead to the absurd situation "global limit exceeded but
bdi limit not exceeded".

CC: Rik van Riel <riel@redhat.com>
CC: Peter Zijlstra <a.p.zijlstra@chello.nl>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 mm/page-writeback.c |    5 +++++
 1 file changed, 5 insertions(+)

--- linux-next.orig/mm/page-writeback.c	2010-12-07 20:35:00.000000000 +0800
+++ linux-next/mm/page-writeback.c	2010-12-07 20:37:34.000000000 +0800
@@ -451,6 +451,11 @@ unsigned long bdi_dirty_limit(struct bac
 	u64 bdi_dirty;
 	long numerator, denominator;
 
+	if (likely(dirty > bdi_stat_error(bdi)))
+		dirty -= bdi_stat_error(bdi);
+	else
+		return 0;
+
 	/*
 	 * Calculate this BDI's share of the dirty ratio.
 	 */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
