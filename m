Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 9C03F8D004B
	for <linux-mm@kvack.org>; Wed, 20 Apr 2011 04:46:15 -0400 (EDT)
Message-Id: <20110420080918.560499032@intel.com>
Date: Wed, 20 Apr 2011 16:03:42 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 6/6] writeback: refill b_io iff empty
References: <20110420080336.441157866@intel.com>
Content-Disposition: inline; filename=writeback-refill-queue-iff-empty.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, Mel Gorman <mel@linux.vnet.ibm.com>, Mel Gorman <mel@csn.ul.ie>, Wu Fengguang <fengguang.wu@intel.com>, Dave Chinner <david@fromorbit.com>, Itaru Kitayama <kitayama@cl.bb4u.ne.jp>, Minchan Kim <minchan.kim@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

There is no point to carry different refill policies between for_kupdate
and other type of works. Use a consistent "refill b_io iff empty" policy
which can guarantee fairness in an easy to understand way.

A b_io refill will setup a _fixed_ work set with all currently eligible
inodes and start a new round of walk through b_io. The "fixed" work set
means no new inodes will be added to the work set during the walk.
Only when a complete walk over b_io is done, new inodes that are
eligible at the time will be enqueued and the walk be started over.

This procedure provides fairness among the inodes because it guarantees
each inode to be synced once and only once at each round. So all inodes
will be free from starvations.

This change relies on wb_writeback() to keep retrying as long as we made
some progress on cleaning some pages and/or inodes. Without that ability,
the old logic on background works relies on aggressively queuing all
eligible inodes into b_io at every time. But that's not a guarantee.

The below test script completes a slightly faster now on XFS:

             2.6.39-rc3	  2.6.39-rc3-dyn-expire+
------------------------------------------------
all elapsed     256.043      252.367
stddev           24.381       12.530

tar elapsed      30.097       28.808
dd  elapsed      13.214       11.782

	#!/bin/zsh

	cp /c/linux-2.6.38.3.tar.bz2 /dev/shm/

	umount /dev/sda7
	mkfs.xfs -f /dev/sda7
	mount /dev/sda7 /fs

	echo 3 > /proc/sys/vm/drop_caches

	tic=$(cat /proc/uptime|cut -d' ' -f2)

	cd /fs
	time tar jxf /dev/shm/linux-2.6.38.3.tar.bz2 &
	time dd if=/dev/zero of=/fs/zero bs=1M count=1000 &

	wait
	sync
	tac=$(cat /proc/uptime|cut -d' ' -f2)
	echo elapsed: $((tac - tic))

It maintains roughly the same small vs. large file writeout shares, and
offers large files better chances to be written in nice 4M chunks.

Analyzes from Dave Chinner in great details:

Let's say we have lots of inodes with 100 dirty pages being created,
and one large writeback going on. We expire 8 new inodes for every
1024 pages we write back.

With the old code, we do:

	b_more_io (large inode) -> b_io (1l)
	8 newly expired inodes -> b_io (1l, 8s)

	writeback  large inode 1024 pages -> b_more_io

	b_more_io (large inode) -> b_io (8s, 1l)
	8 newly expired inodes -> b_io (8s, 1l, 8s)

	writeback  8 small inodes 800 pages
		   1 large inode 224 pages -> b_more_io

	b_more_io (large inode) -> b_io (8s, 1l)
	8 newly expired inodes -> b_io (8s, 1l, 8s)
	.....

Your new code:

	b_more_io (large inode) -> b_io (1l)
	8 newly expired inodes -> b_io (1l, 8s)

	writeback  large inode 1024 pages -> b_more_io
	(b_io == 8s)
	writeback  8 small inodes 800 pages

	b_io empty: (1800 pages written)
		b_more_io (large inode) -> b_io (1l)
		14 newly expired inodes -> b_io (1l, 14s)

	writeback  large inode 1024 pages -> b_more_io
	(b_io == 14s)
	writeback  10 small inodes 1000 pages
		   1 small inode 24 pages -> b_more_io (1l, 1s(24))
	writeback  5 small inodes 500 pages
	b_io empty: (2548 pages written)
		b_more_io (large inode) -> b_io (1l, 1s(24))
		20 newly expired inodes -> b_io (1l, 1s(24), 20s)
	......

Rough progression of pages written at b_io refill:

Old code:

	total	large file	% of writeback
	1024	224		21.9% (fixed)

New code:
	total	large file	% of writeback
	1800	1024		~55%
	2550	1024		~40%
	3050	1024		~33%
	3500	1024		~29%
	3950	1024		~26%
	4250	1024		~24%
	4500	1024		~22.7%
	4700	1024		~21.7%
	4800	1024		~21.3%
	4800	1024		~21.3%
	(pretty much steady state from here)

Ok, so the steady state is reached with a similar percentage of
writeback to the large file as the existing code. Ok, that's good,
but providing some evidence that is doesn't change the shared of
writeback to the large should be in the commit message ;)

The other advantage to this is that we always write 1024 page chunks
to the large file, rather than smaller "whatever remains" chunks.

CC: Jan Kara <jack@suse.cz>
Acked-by: Mel Gorman <mel@csn.ul.ie>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 fs/fs-writeback.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

--- linux-next.orig/fs/fs-writeback.c	2011-04-20 12:07:48.000000000 +0800
+++ linux-next/fs/fs-writeback.c	2011-04-20 12:08:13.000000000 +0800
@@ -579,7 +579,8 @@ void writeback_inodes_wb(struct bdi_writ
 	if (!wbc->wb_start)
 		wbc->wb_start = jiffies; /* livelock avoidance */
 	spin_lock(&inode_wb_list_lock);
-	if (!wbc->for_kupdate || list_empty(&wb->b_io))
+
+	if (list_empty(&wb->b_io))
 		queue_io(wb, wbc);
 
 	while (!list_empty(&wb->b_io)) {
@@ -606,7 +607,7 @@ static void __writeback_inodes_sb(struct
 	WARN_ON(!rwsem_is_locked(&sb->s_umount));
 
 	spin_lock(&inode_wb_list_lock);
-	if (!wbc->for_kupdate || list_empty(&wb->b_io))
+	if (list_empty(&wb->b_io))
 		queue_io(wb, wbc);
 	writeback_sb_inodes(sb, wb, wbc, true);
 	spin_unlock(&inode_wb_list_lock);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
