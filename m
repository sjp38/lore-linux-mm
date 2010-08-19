Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 4D3FD6B020E
	for <linux-mm@kvack.org>; Thu, 19 Aug 2010 16:57:53 -0400 (EDT)
From: Michael Rubin <mrubin@google.com>
Subject: [PATCH 0/3] writeback: kernel visibility
Date: Thu, 19 Aug 2010 13:57:24 -0700
Message-Id: <1282251447-16937-1-git-send-email-mrubin@google.com>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
Cc: jack@suse.cz, riel@redhat.com, akpm@linux-foundation.org, david@fromorbit.com, npiggin@suse.de, hch@lst.de, axboe@kernel.dk, Michael Rubin <mrubin@google.com>
List-ID: <linux-mm.kvack.org>

Patch #1 sets up some helper functions for accounting.

Patch #2 adds writeback visibility in /proc/sys/vm.

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

There is a strong case for putting these files in /proc/sys/vm.
It was Christoph's suggestion that made me realize that /proc/sys/vm is
their proper home. Most if not all the tunables for writeback are
there. When one is trying to find the state of the system's writeback
activity that's the directory. In addition while the internals of
writeback will probably change the use of the dirty and writeback states
and pages will be around for a long time. Exposing them in /proc/sys/vm
should be acceptable.

Having these pages_dirtied and pages_entered_writeback in /proc/vmstat
to me feels like a way to make sure that users who would need them won't
find them unless they are reading source. And these are folks who aren't
reading source.

Patch #3 adds dirty thresholds to /proc/vmstat.

 # grep threshold /proc/vmstat
 nr_pages_dirty_threshold 409111
 nr_pages_dirty_background_threshold 818223

The files that report the dirty thresholds belong in /proc/vmstat. They
are meant for application writers so should not be in debugfs. But since
they are more related to internals of writeback, albeit internals that
are fundamental to how it works, /proc/sys/vm is not appropriate.

Michael Rubin (3):
  mm: helper functions for dirty and writeback accounting
  writeback: Adding pages_dirtied and pages_entered_writeback
  writeback: Reporting dirty thresholds in /proc/vmstat

 Documentation/sysctl/vm.txt |   20 +++++++++++++++---
 drivers/base/node.c         |   14 +++++++++++++
 fs/ceph/addr.c              |    8 +-----
 fs/nilfs2/segment.c         |    2 +-
 include/linux/mm.h          |    1 +
 include/linux/mmzone.h      |    4 +++
 include/linux/writeback.h   |    9 ++++++++
 kernel/sysctl.c             |   14 +++++++++++++
 mm/page-writeback.c         |   45 ++++++++++++++++++++++++++++++++++++++++--
 mm/vmstat.c                 |   10 +++++++++
 10 files changed, 113 insertions(+), 14 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
