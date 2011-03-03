Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id EDE928D0049
	for <linux-mm@kvack.org>; Thu,  3 Mar 2011 03:17:57 -0500 (EST)
Message-Id: <20110303064505.718671603@intel.com>
Date: Thu, 03 Mar 2011 14:45:05 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 00/27] IO-less dirty throttling v6
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Trond Myklebust <Trond.Myklebust@netapp.com>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Wu Fengguang <fengguang.wu@intel.com>, linux-mm <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

Andrew,

The v6 patchset is a major rework of the unreleased v5 and tested to run
OK for all the test cases, including

- ext2, ext3, ext4, xfs, btrfs, nfs
- 256M, 512M, 3G, 16G, 64G memory sizes and different dirty ratios
- single HDD, SSD, hybrid UKey+disk and 10-disk JBOD/RAID0 arrays
- 1, 2, 10, 100 and 1000 concurrent dd's

The test results (near 8000 graphs) can be explored at

http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/dirty-throttling-v6/

The tests disclosed some problems, but they are normally FS specific
imperfections presented in v4 and non of them are blocking issue for
this patchset.

It contains some "algorithms" that may sound distrusting, however the worst
case will be bounded by the upper/lower threshold of the control scope.

It selects the critical "dirty pages" and "dirty rates" as key parameters
to control. The control policies should be easy to understand, and it
can by nature support more advanced features like

- when memory pressure increases and page reclaim encounters dirty pages,
  it could instantly scale down the dirty goal to eliminate pageout(). The
  lowered dirty goal will be executed by halving (or more) the throttle
  bandwith and won't brute forcely block the dirtier tasks. The progress
  will look very much like the "bdi dirty" line in the below graph,
  where the USB key is doing the same task of bringing down the initial
  high number of dirty pages to its dirty goal:

  http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/dirty-throttling-v6/1UKEY+1HDD-3G/ext3-1dd-1M-8p-970M-20%25-2.6.38-rc6-dt6+-2011-02-28-16-37/balance_dirty_pages-pages.png

- serve as simple IO controllers: if provide an interface for the user
  to set task_bw directly (by returning the user specified value
  directly at the beginning of dirty_throttle_bandwidth(), plus always
  throttle such tasks even under the background dirty threshold), we get
  a bandwidth based per-task async write IO controller; let the user
  scale up/down the @priority parameter in dirty_throttle_bandwidth(),
  we get a priority based IO controller. It's possible to extend the
  capabilities to the scope of cgroup, too.


v4 patchset:		https://lkml.org/lkml/2010/12/13/320
v6 introduction: 	http://comments.gmane.org/gmane.linux.file-systems/51237

Minor fixes

	[PATCH 01/27] writeback: add bdi_dirty_limit() kernel-doc
	[PATCH 02/27] writeback: avoid duplicate balance_dirty_pages_ratelimited() calls
	[PATCH 03/27] writeback: skip balance_dirty_pages() for in-memory fs
	[PATCH 04/27] writeback: reduce per-bdi dirty threshold ramp up time

btrfs/nfs improvements
There are no direct inter-dependencies between the FS and VFS patches;
the patches simply make btrfs/nfs work better with the new balance_dirty_pages().

	[PATCH 05/27] btrfs: avoid duplicate balance_dirty_pages_ratelimited() calls
	[PATCH 06/27] btrfs: lower the dirty balance poll interval
	[PATCH 07/27] btrfs: wait on too many nr_async_bios
	[PATCH 08/27] nfs: dirty livelock prevention is now done in VFS
	[PATCH 09/27] nfs: writeback pages wait queue
	[PATCH 10/27] nfs: limit the commit size to reduce fluctuations
	[PATCH 11/27] nfs: limit the commit range
	[PATCH 12/27] nfs: lower writeback threshold proportionally to dirty threshold

supporting functionalities

	[PATCH 13/27] writeback: account per-bdi accumulated written pages
	[PATCH 14/27] writeback: account per-bdi accumulated dirtied pages
	[PATCH 15/27] writeback: bdi write bandwidth estimation
	[PATCH 16/27] writeback: smoothed global/bdi dirty pages
	[PATCH 17/27] writeback: smoothed dirty threshold and limit
	[PATCH 18/27] writeback: enforce 1/4 gap between the dirty/background thresholds

core changes

	[PATCH 19/27] writeback: dirty throttle bandwidth control
	[PATCH 20/27] writeback: IO-less balance_dirty_pages()

tracing

	[PATCH 21/27] writeback: show bdi write bandwidth in debugfs
	[PATCH 22/27] writeback: trace dirty_throttle_bandwidth
	[PATCH 23/27] writeback: trace balance_dirty_pages
	[PATCH 24/27] writeback: trace global_dirty_state

larger IO size

	[PATCH 25/27] writeback: make nr_to_write a per-file limit
	[PATCH 26/27] writeback: scale IO chunk size up to device bandwidth
	[PATCH 27/27] writeback: trace writeback_single_inode


 fs/btrfs/disk-io.c               |    7 
 fs/btrfs/file.c                  |   16 
 fs/btrfs/ioctl.c                 |    6 
 fs/btrfs/relocation.c            |    6 
 fs/fs-writeback.c                |   79 +-
 fs/nfs/client.c                  |    2 
 fs/nfs/file.c                    |    9 
 fs/nfs/write.c                   |  142 ++-
 include/linux/backing-dev.h      |   21 
 include/linux/nfs_fs.h           |    1 
 include/linux/nfs_fs_sb.h        |    1 
 include/linux/sched.h            |    8 
 include/linux/writeback.h        |   58 +
 include/trace/events/writeback.h |  245 ++++++
 mm/backing-dev.c                 |   51 +
 mm/filemap.c                     |    5 
 mm/memory_hotplug.c              |    3 
 mm/page-writeback.c              | 1083 +++++++++++++++++++++++------
 18 files changed, 1445 insertions(+), 298 deletions(-)

git tree for easy access

git://git.kernel.org/pub/scm/linux/kernel/git/wfg/writeback.git dirty-throttling-v6

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
