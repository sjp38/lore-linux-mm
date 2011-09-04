Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 817FD6B0184
	for <linux-mm@kvack.org>; Sat,  3 Sep 2011 22:13:25 -0400 (EDT)
Message-Id: <20110904015305.367445271@intel.com>
Date: Sun, 04 Sep 2011 09:53:05 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 00/18] IO-less dirty throttling v11 
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Wu Fengguang <fengguang.wu@intel.com>

Hi,

Finally, the complete IO-less balance_dirty_pages(). NFS is observed to perform
better or worse depending on the memory size. Otherwise the added patches can
address all known regressions.

        git://git.kernel.org/pub/scm/linux/kernel/git/wfg/writeback.git dirty-throttling-v11
	(to be updated; currently it contains a pre-release v11)

Changes since v10:

- complete the renames
- add protections for IO queue underrun
  - pause time reduction
  - bdi reserve area
  - bdi underrun flag
- more accurate task dirty accounting for
  - sub-page writes
  - FS re-dirties
  - short lived tasks

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

Thanks a lot to Peter, Vivek, Andrea and Jan for the careful reviews!

shortlog:

	Wu Fengguang (18):
	      writeback: account per-bdi accumulated dirtied pages
	      writeback: dirty position control
	      writeback: dirty rate control
	      writeback: stabilize bdi->dirty_ratelimit
	      writeback: per task dirty rate limit
	      writeback: IO-less balance_dirty_pages()
	      writeback: dirty ratelimit - think time compensation
	      writeback: trace dirty_ratelimit
	      writeback: trace balance_dirty_pages
	      writeback: dirty position control - bdi reserve area
	      block: add bdi flag to indicate risk of io queue underrun
	      writeback: balanced_rate cannot exceed write bandwidth
	      writeback: limit max dirty pause time
	      writeback: control dirty pause time
	      writeback: charge leaked page dirties to active tasks
	      writeback: fix dirtied pages accounting on sub-page writes
	      writeback: fix dirtied pages accounting on redirty
	      btrfs: fix dirtied pages accounting on sub-page writes

diffstat:

	 block/blk-core.c                 |    7 
	 fs/btrfs/file.c                  |    3 
	 fs/fs-writeback.c                |    2 
	 include/linux/backing-dev.h      |   26 
	 include/linux/blkdev.h           |   12 
	 include/linux/sched.h            |    8 
	 include/linux/writeback.h        |    5 
	 include/trace/events/writeback.h |  151 ++++-
	 kernel/exit.c                    |    2 
	 kernel/fork.c                    |    4 
	 mm/backing-dev.c                 |    3 
	 mm/page-writeback.c              |  768 +++++++++++++++++++++++------
	 12 files changed, 816 insertions(+), 175 deletions(-)

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
