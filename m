Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id D93AB6B0088
	for <linux-mm@kvack.org>; Tue, 21 Dec 2010 04:39:31 -0500 (EST)
Date: Tue, 21 Dec 2010 17:39:25 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH] writeback: skip balance_dirty_pages() for in-memory fs
Message-ID: <20101221093925.GA23110@localhost>
References: <20101213144646.341970461@intel.com>
 <20101213150329.002158963@intel.com>
 <20101217021934.GA9525@localhost>
 <alpine.LSU.2.00.1012162239270.23229@sister.anvils>
 <20101217112111.GA8323@localhost>
 <alpine.LSU.2.00.1012202127310.16112@tigran.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.00.1012202127310.16112@tigran.mtv.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Trond Myklebust <Trond.Myklebust@netapp.com>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, linux-mm <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, Dec 21, 2010 at 01:59:46PM +0800, Hugh Dickins wrote:
> On Fri, 17 Dec 2010, Wu Fengguang wrote:
> 
> > This avoids unnecessary checks and dirty throttling on tmpfs/ramfs.
> > 
> > It also prevents
> > 
> > [  388.126563] BUG: unable to handle kernel NULL pointer dereference at 0000000000000050
> > 
> > in the balance_dirty_pages tracepoint, which will call
> > 
> > 	dev_name(mapping->backing_dev_info->dev)
> > 
> > but shmem_backing_dev_info.dev is NULL.
> > 
> > CC: Hugh Dickins <hughd@google.com>
> > Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> 
> Whilst I do like this change, and I do think it's the right thing to do
> (given that the bdi has explicitly opted out of what it then got into),

Thanks.

> I've a sneaking feeling that something somewhere may show a regression
> from it.  IIRC, there were circumstances in which it actually did
> (inadvertently) end up throttling the tmpfs writing - if there were
> too many dirty non-tmpfs pages around??

Good point (that I missed!).

Here is the findings after double checks.

As for 2.6.36 and older kernels, the tmpfs writes will sleep inside
balance_dirty_pages() as long as we are over the (dirty+background)/2
global throttle threshold.  This is because both the dirty pages and
threshold will be 0 for tmpfs/ramfs. Hence this test will always
evaluate to TRUE:

                dirty_exceeded =
                        (bdi_nr_reclaimable + bdi_nr_writeback >= bdi_thresh)
                        || (nr_reclaimable + nr_writeback >= dirty_thresh);

As for 2.6.37, someone complained that the current logic does not
allow the users to set vm.dirty_ratio=0.  So the to-be-released 2.6.37
will have this change (commit 4cbec4c8b9)

@@ -542,8 +536,8 @@ static void balance_dirty_pages(struct address_space *mapping,
                 * the last resort safeguard.
                 */
                dirty_exceeded =
-                       (bdi_nr_reclaimable + bdi_nr_writeback >= bdi_thresh)
-                       || (nr_reclaimable + nr_writeback >= dirty_thresh);
+                       (bdi_nr_reclaimable + bdi_nr_writeback > bdi_thresh)
+                       || (nr_reclaimable + nr_writeback > dirty_thresh);

So for 2.6.37 it will behave differently for tmpfs/ramfs: it will
never get throttled unless the global dirty threshold is exceeded,
which is very unlikely to happen (once happen, will block many tasks).

I'd say that the 2.6.36 behavior is very bad for tmpfs/ramfs. It means
for a busy writing server, tmpfs write()s may get livelocked! The
"inadvertent" throttling can hardly bring help to any workload because
of its "either no throttling, or get throttled to death" property.

So based on 2.6.37, this patch won't bring more noticeable changes.

> What am I saying?!  I think I'm asking you to look more closely at what
> actually used to happen, and be more explicit about the behavior you're
> stopping here - although the patch is mainly code optimization, there
> is some functional change I think.  (You do mention throttling on
> tmpfs/ramfs, but the way it worked out wasn't straightforward.)

Good suggestion, thanks!

> I'd better not burble on for a third paragraph!

How about this updated patch?

Thanks,
Fengguang
---
Subject: writeback: skip balance_dirty_pages() for in-memory fs
Date: Thu Dec 16 22:22:00 CST 2010

This avoids unnecessary checks and dirty throttling on tmpfs/ramfs.

It also prevents

[  388.126563] BUG: unable to handle kernel NULL pointer dereference at 0000000000000050

in the balance_dirty_pages tracepoint, which will call

	dev_name(mapping->backing_dev_info->dev)

but shmem_backing_dev_info.dev is NULL.

Summary notes about the tmpfs/ramfs behavior changes:

As for 2.6.36 and older kernels, the tmpfs writes will sleep inside
balance_dirty_pages() as long as we are over the (dirty+background)/2
global throttle threshold.  This is because both the dirty pages and
threshold will be 0 for tmpfs/ramfs. Hence this test will always
evaluate to TRUE:

                dirty_exceeded =
                        (bdi_nr_reclaimable + bdi_nr_writeback >= bdi_thresh)
                        || (nr_reclaimable + nr_writeback >= dirty_thresh);

For 2.6.37, someone complained that the current logic does not allow the
users to set vm.dirty_ratio=0.  So commit 4cbec4c8b9 changed the test to

                dirty_exceeded =
                        (bdi_nr_reclaimable + bdi_nr_writeback > bdi_thresh)
                        || (nr_reclaimable + nr_writeback > dirty_thresh);

So 2.6.37 will behave differently for tmpfs/ramfs: it will never get
throttled unless the global dirty threshold is exceeded (which is very
unlikely to happen; once happen, will block many tasks).

I'd say that the 2.6.36 behavior is very bad for tmpfs/ramfs. It means
for a busy writing server, tmpfs write()s may get livelocked! The
"inadvertent" throttling can hardly bring help to any workload because
of its "either no throttling, or get throttled to death" property.

So based on 2.6.37, this patch won't bring more noticeable changes.

CC: Hugh Dickins <hughd@google.com>
CC: Peter Zijlstra <a.p.zijlstra@chello.nl>
Acked-by: Rik van Riel <riel@redhat.com>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 mm/page-writeback.c |   10 ++++------
 1 file changed, 4 insertions(+), 6 deletions(-)

--- linux-next.orig/mm/page-writeback.c	2010-12-18 09:14:53.000000000 +0800
+++ linux-next/mm/page-writeback.c	2010-12-21 17:35:44.000000000 +0800
@@ -230,13 +230,8 @@ void task_dirty_inc(struct task_struct *
 static void bdi_writeout_fraction(struct backing_dev_info *bdi,
 		long *numerator, long *denominator)
 {
-	if (bdi_cap_writeback_dirty(bdi)) {
-		prop_fraction_percpu(&vm_completions, &bdi->completions,
+	prop_fraction_percpu(&vm_completions, &bdi->completions,
 				numerator, denominator);
-	} else {
-		*numerator = 0;
-		*denominator = 1;
-	}
 }
 
 static inline void task_dirties_fraction(struct task_struct *tsk,
@@ -878,6 +873,9 @@ void balance_dirty_pages_ratelimited_nr(
 {
 	struct backing_dev_info *bdi = mapping->backing_dev_info;
 
+	if (!bdi_cap_account_dirty(bdi))
+		return;
+
 	current->nr_dirtied += nr_pages_dirtied;
 
 	if (unlikely(!current->nr_dirtied_pause))

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
