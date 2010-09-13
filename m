Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 98D506B00E2
	for <linux-mm@kvack.org>; Mon, 13 Sep 2010 01:58:54 -0400 (EDT)
From: Michael Rubin <mrubin@google.com>
Subject: [PATCH 0/5] writeback: kernel visibility
Date: Sun, 12 Sep 2010 22:58:08 -0700
Message-Id: <1284357493-20078-1-git-send-email-mrubin@google.com>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
Cc: fengguang.wu@intel.com, jack@suse.cz, riel@redhat.com, akpm@linux-foundation.org, david@fromorbit.com, kosaki.motohiro@jp.fujitsu.com, npiggin@kernel.dk, hch@lst.de, axboe@kernel.dk, Michael Rubin <mrubin@google.com>
List-ID: <linux-mm.kvack.org>

Patch #1 sets up some helper functions for account_page_dirty and fixes
a bug in ceph

Patch #2 sets up some helper functions for account_page_writeback

Patch #3 adds writeback visibility in /proc/vmstat

To help developers and applications gain visibility into writeback
behaviour this patch adds two counters to /proc/vmstat.

  # grep nr_dirtied /proc/vmstat
  nr_dirtied 3747
  # grep nr_written /proc/vmstat
  nr_written 3618

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

Patch #4 adds a pernode vmstat file with nr_dirtied and nr_written

Patch #5 add writeback thresholds to /proc/vmstat

Currently these values are in debugfs. But they should be promoted to
/proc since they are useful for developers who are writing databases
and file servers and are not debugging the kernel.

The output is as below:

 # grep threshold /proc/vmstat
 nr_pages_dirty_threshold 409111
 nr_pages_dirty_background_threshold 818223

Michael Rubin (5):
  mm: exporting account_page_dirty
  mm: account_page_writeback added
  writeback: nr_dirtied and nr_written in /proc/vmstat
  writeback: Adding /sys/devices/system/node/<node>/vmstat
  writeback: Reporting dirty thresholds in /proc/vmstat

 drivers/base/node.c    |   14 ++++++++++++++
 fs/ceph/addr.c         |    8 +-------
 fs/nilfs2/segment.c    |    2 +-
 include/linux/mm.h     |    1 +
 include/linux/mmzone.h |    2 ++
 mm/page-writeback.c    |   16 +++++++++++++++-
 mm/vmstat.c            |   42 ++++++++++++++++++++++++++++--------------
 7 files changed, 62 insertions(+), 23 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
