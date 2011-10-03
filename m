Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 3F3599000C6
	for <linux-mm@kvack.org>; Mon,  3 Oct 2011 09:45:55 -0400 (EDT)
Message-Id: <20111003134228.090592370@intel.com>
Date: Mon, 03 Oct 2011 21:42:28 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 00/11] IO-less dirty throttling v12 
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Wu Fengguang <fengguang.wu@intel.com>

Hi,

This is the minimal IO-less balance_dirty_pages() changes that are expected to
be regression free (well, except for NFS).

        git://github.com/fengguang/linux.git dirty-throttling-v12

Tests results will be posted in a separate email.

Changes since v11:

- improve bdi reserve area parameters (based on test results)
- drop bdi underrun flag
- drop aux bdi control line
- make bdi->dirty_ratelimit more stable

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

Wu Fengguang (11):
      writeback: account per-bdi accumulated dirtied pages
      writeback: dirty position control
      writeback: add bg_threshold parameter to __bdi_update_bandwidth()
      writeback: dirty rate control
      writeback: stabilize bdi->dirty_ratelimit
      writeback: per task dirty rate limit
      writeback: IO-less balance_dirty_pages()
      writeback: limit max dirty pause time
      writeback: control dirty pause time
      writeback: dirty position control - bdi reserve area
      writeback: per-bdi background threshold

diffstat:

 fs/fs-writeback.c                |   19 +-
 include/linux/backing-dev.h      |   11 +
 include/linux/sched.h            |    7 +
 include/linux/writeback.h        |    1 +
 include/trace/events/writeback.h |   24 --
 kernel/fork.c                    |    3 +
 mm/backing-dev.c                 |    4 +
 mm/page-writeback.c              |  678 +++++++++++++++++++++++++++++---------
 8 files changed, 566 insertions(+), 181 deletions(-)

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
