Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id F22606B02EA
	for <linux-mm@kvack.org>; Fri, 20 Aug 2010 05:31:47 -0400 (EDT)
From: Michael Rubin <mrubin@google.com>
Subject: [PATCH 0/4] writeback: kernel visibility
Date: Fri, 20 Aug 2010 02:31:25 -0700
Message-Id: <1282296689-25618-1-git-send-email-mrubin@google.com>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
Cc: fengguang.wu@intel.com, jack@suse.cz, riel@redhat.com, akpm@linux-foundation.org, david@fromorbit.com, npiggin@kernel.dk, hch@lst.de, axboe@kernel.dk, Michael Rubin <mrubin@google.com>
List-ID: <linux-mm.kvack.org>

Patch #1 sets up some helper functions for account_page_dirty

Patch #2 sets up some helper functions for account_page_writeback

Patch #3 adds writeback visibility in /proc/vmstat

Patch #4 add writeback thresholds to /proc/vmstat

To help developers and applications gain visibility into writeback
behaviour this patch adds two counters to /proc/vmstat.

   # grep nr_dirtied /proc/vmstat
   nr_dirtied 3747
   # grep nr_entered_writeback /proc/vmstat
   nr_entered_writeback 3618

These entries allow user apps to understand writeback behaviour over
time and learn how it is impacting their performance. Currently there
is no way to inspect dirty and writeback speed over time. It's not
possible for nr_dirty/nr_writeback.

These entries are necessary to give visibility into writeback
behaviour. We have /proc/diskstats which lets us understand the io in
the block layer. We have blktrace for more in depth understanding. We have
e2fsprogs and debugsfs to give insight into the file systems behaviour,
but we don't offer our users the ability understand what writeback is
doing. There is no way to know how active it is over the whole system,
if it's falling behind or to quantify it's efforts. With these values
exported users can easily see how much data applications are sending
through writeback and also at what rates writeback is processing this
data. Comparing the rates of change between the two allow developers
to see when writeback is not able to keep up with incoming traffic and
the rate of dirty memory being sent to the IO back end. This allows
folks to understand their io workloads and track kernel issues. Non
kernel engineers at Google often use these counters to solve puzzling
performance problems.

Patch #3 adds dirty thresholds to /proc/vmstat.

 # grep threshold /proc/vmstat
 nr_pages_dirty_threshold 409111
 nr_pages_dirty_background_threshold 818223

The files that report the dirty thresholds belong in /proc/vmstat. They
are meant for application writers so should not be in debugfs. But since
they are more related to internals of writeback, albeit internals that
are fundamental to how it works, /proc/sys/vm is not appropriate.

Michael Rubin (4):
  mm: exporting account_page_dirty
  mm: account_page_writeback added
  writeback: nr_dirtied and nr_entered_writeback in /proc/vmstat
  writeback: Reporting dirty thresholds in /proc/vmstat

 drivers/base/node.c    |   14 ++++++++++++++
 fs/ceph/addr.c         |    7 +------
 fs/nilfs2/segment.c    |    2 +-
 include/linux/mm.h     |    1 +
 include/linux/mmzone.h |    5 +++++
 mm/page-writeback.c    |   16 +++++++++++++++-
 mm/vmstat.c            |    8 ++++++++
 7 files changed, 45 insertions(+), 8 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
