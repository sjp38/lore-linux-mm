Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 7425A6B02A4
	for <linux-mm@kvack.org>; Wed,  4 Aug 2010 20:43:34 -0400 (EDT)
From: Michael Rubin <mrubin@google.com>
Subject: [PATCH 0/2] Adding two writeback files in /proc/sys/vm
Date: Wed,  4 Aug 2010 17:43:22 -0700
Message-Id: <1280969004-29530-1-git-send-email-mrubin@google.com>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
Cc: jack@suse.cz, akpm@linux-foundation.org, david@fromorbit.com, hch@lst.de, axboe@kernel.dk, Michael Rubin <mrubin@google.com>
List-ID: <linux-mm.kvack.org>

Patch #1 sets up some helper functions for accounting.

Patch #2 adds writeback files for visibility

To help developers and applications gain visibility into writeback
behaviour adding two read-only sysctl files into /proc/sys/vm.
These files allow user apps to understand writeback behaviour over time
and learn how it is impacting their performance.

  # cat /proc/sys/vm/pages_dirtied
  3747
  # cat /proc/sys/vm/pages_entered_writeback
  3618

These two new files are necessary to give visibility into writeback
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


Michael Rubin (2):
  mm: helper functions for dirty and writeback accounting
  writeback: Adding pages_dirtied and pages_entered_writeback

 Documentation/sysctl/vm.txt |   20 +++++++++++++++---
 drivers/base/node.c         |   14 +++++++++++++
 fs/ceph/addr.c              |    8 +-----
 fs/nilfs2/segment.c         |    2 +-
 include/linux/mm.h          |    1 +
 include/linux/mmzone.h      |    2 +
 include/linux/writeback.h   |    9 ++++++++
 kernel/sysctl.c             |   14 +++++++++++++
 mm/page-writeback.c         |   45 ++++++++++++++++++++++++++++++++++++++++--
 mm/vmstat.c                 |    2 +
 10 files changed, 103 insertions(+), 14 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
