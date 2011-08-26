Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 8F0216B016B
	for <linux-mm@kvack.org>; Fri, 26 Aug 2011 07:47:52 -0400 (EDT)
Message-Id: <20110826113813.895522398@intel.com>
Date: Fri, 26 Aug 2011 19:38:13 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 00/10] IO-less dirty throttling v10 
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Wu Fengguang <fengguang.wu@intel.com>

Hi,

The core algorithms for IO-less balance_dirty_pages().

        git://git.kernel.org/pub/scm/linux/kernel/git/wfg/writeback.git dirty-throttling-v10

Changes since v9:

- a lot of renames and comment/changelog rework, again
- seperate out the dirty_ratelimit update policy (as patch 04)
- add think time compensation
- add 3 trace events

Changes since v8:

- a lot of renames and comment/changelog rework
- use 3rd order polynomial as the global control line (Peter)
- stabilize dirty_ratelimit by decreasing update step size on small errors
- limit per-CPU dirtied pages to avoid dirty pages run away on 1k+ tasks (Peter)

Thanks a lot to Peter, Vivek and Andrea for the careful reviews!

shortlog:

	Wu Fengguang (10):
	      writeback: account per-bdi accumulated dirtied pages
	      writeback: dirty position control
	      writeback: dirty rate control
	      writeback: stabilize bdi->dirty_ratelimit
	      writeback: per task dirty rate limit
	      writeback: IO-less balance_dirty_pages()
	      writeback: dirty ratelimit - think time compensation
	      writeback: trace balance_dirty_pages
	      writeback: trace dirty_ratelimit
	      trace task_io (RFC)

diffstat:

	 fs/fs-writeback.c                |    2 +-
	 include/linux/backing-dev.h      |    8 +
	 include/linux/sched.h            |    8 +
	 include/linux/writeback.h        |    1 +
	 include/trace/events/writeback.h |  181 +++++++++--
	 kernel/fork.c                    |    4 +
	 mm/backing-dev.c                 |    3 +
	 mm/page-writeback.c              |  664 +++++++++++++++++++++++++++++---------
	 8 files changed, 693 insertions(+), 178 deletions(-)

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
