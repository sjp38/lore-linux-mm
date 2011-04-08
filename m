Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id EE0158D003B
	for <linux-mm@kvack.org>; Fri,  8 Apr 2011 15:44:16 -0400 (EDT)
Date: Fri, 8 Apr 2011 21:44:11 +0200
From: Jan Kara <jack@suse.cz>
Subject: IO-less throttling problem statement
Message-ID: <20110408194411.GD16729@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Dave Chinner <david@fromorbit.com>, Christoph Hellwig <hch@infradead.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

  Hi,

  below is my summary of problems observed with current throttling scheme.
I guess other guys will have some changes but this I what I remembered from
top of my head.

									Honza
---

The problems people see with current balance_dirty_pages() implementation:
a) IO submission from several processes in parallel causes suboptimal IO
patterns in some cases because we interleave several sequential IO streams
which causes more seeks (IO scheduler does not have queue long enough to sort
out everything) and more filesystem fragmentation (currently worked around
in each filesystem separately by writing more than asked for etc.).
b) IO submission from several threads causes increased pressure on shared
data structures and locks. For example inode_bw_list_lock seems to be a
bottleneck on large systems.
c) In cases where there are only a few large files dirty, throttled process
just walks the list of dirty inodes, moves all of them to b_more_io because all
of the inodes have I_SYNC set (other processes are already doing writeback
against these files) and resorts to waiting for some time after which it just
tries again. This creates a possibility for basically locking out a process
in balance_dirty_pages() for arbitrarily long time.

All of the above issues get resolved when IO submission happens from just a
single thread so for the above problems basically any IO-less throttling will
do. We get only a single stream of IO, less contention on shared data
structures from writeback, no problems with not having another inode to write
out.

IO less throttling also offers further possibilities for improvement. If we do
not submit IO from a throttled thread, we have more flexibility in choosing how
often and for how long do we throttle a thread since we are no longer limited
by trying to achieve a sensible IO pattern. This creates a possibility for
achieving lower latencies and smoother wait time behavior. Fengguang is taking
advantage of this in his patch set.
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
