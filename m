From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 00/47] IO-less dirty throttling v3
Date: Mon, 13 Dec 2010 14:42:49 +0800
Message-ID: <20101213064249.648862451@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by lo.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1PS2Ex-0005fZ-EB
	for glkm-linux-mm-2@m.gmane.org; Mon, 13 Dec 2010 07:50:32 +0100
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 837F46B00A6
	for <linux-mm@kvack.org>; Mon, 13 Dec 2010 01:49:41 -0500 (EST)
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Trond Myklebust <Trond.Myklebust@netapp.com>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, linux-mm <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
List-Id: linux-mm.kvack.org

Andrew,

I'm glad to release this extensively tested v3 IO-less dirty throttling
patchset. It's based on 2.6.37-rc5 and Jan's sync livelock patches.

Given its trickiness and possibility of side effects, independent tests
are highly welcome. Here is the git tree for easy access

git://git.kernel.org/pub/scm/linux/kernel/git/wfg/writeback.git dirty-throttling-v3

Andrew, I followed your suggestion to add some trace points, and goes further
to write scripts to do automated tests and to visualize the collected trace,
iostat and vmstat data. The help is tremendous. The tests and data analyzes
pave way to many fixes and algorithm improvements.

It still took long time. The most challenging tasks are the fluctuations on
100+ dd and on NFS, and various imperfections in the control system and in
many filesystems. I'd say I won't be able to go this far without the help of
the pretty graphs. And I believe they'll continue to make future maintenance
easy. To identify problems reported by the end users, just ask for the traces,
I'll then turn them into graphs and quickly get an overview of the problem.

The most up-to-date graphs and the corresponding scripts are uploaded to

	http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/tests

Here you may find and compare test results for this patchset (2.6.37-rc5+) and
for vanilla kernel (2.6.37-rc5). Filesystem developers may be interested
to take a look at the dynamics.

The control algorithms are generally doing good in the recent graphs.
There are regular fluctuations of the dirty pages number, however they
are mostly originated from underneath: the low level is reporting IO
completion in units of 1MB, 32MB or even more, leading to sudden drops
of the dirty pages.

The tests cover the common scenarios

- ext2, ext3, ext4, xfs, btrfs, nfs
- 256M, 512M, 3G, 16G memory sizes
- single disk and 12-disk array
- 1, 2, 10, 100, 1000 concurrent dd's

They disclose lots of imperfections and bugs of
1) this patchset
2) file system not working well with the new paradigm 
3) file system problems also exist in vanilla kernel

I managed to fix case (1) and most of (2) and report (3).
Below are some interesting graphs illustrating the problems.

BTRFS

case (3) problem, nr_dirty going all the way down to 0, fixed by
[PATCH 38/47] btrfs: wait on too many nr_async_bios
http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/tests/3G/btrfs-1dd-1K-8p-2953M-2.6.37-rc3+-2010-11-30-17/vmstat-dirty.png
http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/tests/3G/btrfs-1dd-1M-8p-2952M-2.6.37-rc5-2010-12-10-21-23/vmstat-dirty.png
http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/tests/3G/btrfs-1dd-1M-8p-2952M-2.6.37-rc5+-2010-12-08-21-30/vmstat-dirty-300.png                                                                                                                      
after fix
http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/tests/3G/btrfs-1dd-1M-8p-2952M-2.6.37-rc5+-2010-12-08-21-14/vmstat-dirty-300.png                                                                                                                      

case (3) problem, not good looking but otherwise harmless, not fixed yet
http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/tests/3G/btrfs-1dd-1K-8p-2953M-2.6.37-rc3+-2010-11-30-14/vmstat-written.png
root cause is btrfs always clear page dirty in the end of prepare_pages() and
then to set it dirty again in dirty_and_release_pages(). This leads to
duplicate dirty accounting on 1KB-size writes.

case (3) problem, bdi limit exceeded on 10+ concurrent dd's, fixed by
[PATCH 37/47] btrfs: lower the dirty balacing rate limit
http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/tests/3G/btrfs-100dd-1M-8p-2953M-2.6.37-rc3+-2010-12-02-20/vmstat-dirty.png
http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/tests/3G/btrfs-100dd-1M-8p-2953M-2.6.37-rc3+-2010-12-02-20/dirty-pages.png

case (2) problem, not root caused yet

in vanilla kernel, the dirty/writeback pages are interesting
http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/tests/16G-12HDD-RAID0/btrfs-1000dd-1M-24p-15976M-2.6.37-rc5-2010-12-10-14-37/vmstat-dirty.png

but performance is still excellent
http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/tests/16G-12HDD-RAID0/btrfs-1000dd-1M-24p-15976M-2.6.37-rc5-2010-12-10-14-37/iostat-bw.png

with IO-less balance_dirty_pages(), it's much more slow
http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/tests/16G-12HDD-RAID0/btrfs-1000dd-1M-24p-15976M-2.6.37-rc5+-2010-12-10-03-54/iostat-bw.png

dirty pages go very low
http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/tests/16G-12HDD-RAID0/btrfs-1000dd-1M-24p-15976M-2.6.37-rc5+-2010-12-10-03-54/vmstat-dirty.png

with only 20% disk util
http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/tests/16G-12HDD-RAID0/btrfs-1000dd-1M-24p-15976M-2.6.37-rc5+-2010-12-10-03-54/iostat-util.png

EXT4

case (3) problem, maybe memory leak, not root caused yet
http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/tests/16G-12HDD-RAID0/ext4-100dd-1M-24p-15976M-2.6.37-rc5+-2010-12-09-23-40/dirty-pages.png

case (3) problem, burst-of-redirty, known issue with data=ordered, would be non-trivial to fix
http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/tests/3G/ext4-1dd-1M-8p-2952M-2.6.37-rc5+-2010-12-09-00-37/dirty-pages-3000.png
the workaround now is to mount with data=writeback
http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/tests/3G/ext4_wb-1dd-1M-8p-2952M-2.6.37-rc5+-2010-12-12-13-40/dirty-pages.png

NFS

There are some hard problems
- large fluctuations of everything
- writeback/unstable pages squeezing dirty pages
- sometimes it may stall the dirtiers for 1-2 seconds because no COMMITs return
  during the time, hard to fix in the client side

before the patches
http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/tests/3G/nfs-1dd-1M-8p-2952M-2.6.37-rc5-2010-12-11-10-31/vmstat-dirty.png
http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/tests/3G/nfs-100dd-1M-8p-2952M-2.6.37-rc5-2010-12-10-12-40/vmstat-dirty.png
http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/tests/3G/nfs-1dd-4K-8p-2953M-2.6.37-rc3+-2010-11-29-10/vmstat-dirty.png
http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/tests/3G/nfs-1dd-4K-8p-2953M-2.6.37-rc3+-2010-11-29-10/dirty-bandwidth.png

after patches
http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/tests/3G/nfs-1dd-1M-8p-2952M-2.6.37-rc5+-2010-12-09-03-04/vmstat-dirty.png
http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/tests/3G/nfs-1dd-1M-8p-2952M-2.6.37-rc5+-2010-12-09-03-04/dirty-bandwidth-3000.png
http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/tests/3G/nfs-100dd-1M-8p-2952M-2.6.37-rc5+-2010-12-09-03-23/vmstat-dirty.png

burst of commit submits/returns
http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/tests/3G/nfs-100dd-1M-8p-2953M-2.6.37-rc3+-2010-12-03-01/nfs-commit-1000.png
after fix
http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/tests/3G/nfs-1dd-1M-8p-2952M-2.6.37-rc5+-2010-12-09-03-04/nfs-commit-300.png

The 1-second stall happens at around 317s and 321s. Fortunately it only
happens for 10+ concurrent dd's, which is not typical NFS client workloads.
http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/tests/3G/nfs-100dd-1M-8p-2952M-2.6.37-rc5+-2010-12-09-03-23/nfs-commit-300.png


XFS

performs mostly ideal, except for some trivial imperfections: somewhere
the lines are not straight.

dirty/writeback pages
http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/tests/16G-12HDD-RAID0/xfs-1000dd-1M-24p-15976M-2.6.37-rc5-2010-12-10-18-18/vmstat-dirty.png

avg queue size and wait time
http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/tests/16G-12HDD-RAID0/xfs-1000dd-1M-24p-15976M-2.6.37-rc5+-2010-12-10-02-53/iostat-misc.png

bandwidth
http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/tests/16G-12HDD-RAID0/xfs-1000dd-1M-24p-15976M-2.6.37-rc5+-2010-12-10-02-53/dirty-bandwidth.png


Changes from v2 <http://lkml.org/lkml/2010/11/16/728>

- lock protected bdi bandwidth estimation
- user space think time compensation
- raise max pause time to 200ms for lower CPU overheads on concurrent dirtiers
- control system enhancements to handle large pause time and huge number of tasks
- concurrent dd test suite and a lot of tests
- adaptive scale up writeback chunk size
- make it right for small memory systems
- various bug fixes
- new trace points

Changes from initial RFC <http://thread.gmane.org/gmane.linux.kernel.mm/52966>

- adaptive rate limiting, to reduce overheads when under throttle threshold
- prevent overrunning dirty limit on lots of concurrent dirtiers
- add Documentation/filesystems/writeback-throttling-design.txt
- lower max pause time from 200ms to 100ms; min pause time from 10ms to 1jiffy
- don't drop the laptop mode code
- update and comment the trace event
- benchmarks on concurrent dd and fs_mark covering both large and tiny files
- bdi->write_bandwidth updates should be rate limited on concurrent dirtiers,
  otherwise it will drift fast and fluctuate
- don't call balance_dirty_pages_ratelimit() when writing to already dirtied
  pages, otherwise the task will be throttled too much

bdi dirty limit fixes
	[PATCH 01/47] writeback: enabling gate limit for light dirtied bdi
	[PATCH 02/47] writeback: safety margin for bdi stat error

v2 patches rebased onto the above two fixes
	[PATCH 03/47] writeback: IO-less balance_dirty_pages()
	[PATCH 04/47] writeback: consolidate variable names in balance_dirty_pages()
	[PATCH 05/47] writeback: per-task rate limit on balance_dirty_pages()
	[PATCH 06/47] writeback: prevent duplicate balance_dirty_pages_ratelimited() calls
	[PATCH 07/47] writeback: account per-bdi accumulated written pages
	[PATCH 08/47] writeback: bdi write bandwidth estimation
	[PATCH 09/47] writeback: show bdi write bandwidth in debugfs
	[PATCH 10/47] writeback: quit throttling when bdi dirty pages dropped low
	[PATCH 11/47] writeback: reduce per-bdi dirty threshold ramp up time
	[PATCH 12/47] writeback: make reasonable gap between the dirty/background thresholds
	[PATCH 13/47] writeback: scale down max throttle bandwidth on concurrent dirtiers
	[PATCH 14/47] writeback: add trace event for balance_dirty_pages()
	[PATCH 15/47] writeback: make nr_to_write a per-file limit

trivial fixes for v2
	[PATCH 16/47] writeback: make-nr_to_write-a-per-file-limit fix
	[PATCH 17/47] writeback: do uninterruptible sleep in balance_dirty_pages()
	[PATCH 18/47] writeback: move BDI_WRITTEN accounting into __bdi_writeout_inc()
	[PATCH 19/47] writeback: fix increasement of nr_dirtied_pause
	[PATCH 20/47] writeback: use do_div in bw calculation
	[PATCH 21/47] writeback: prevent divide error on tiny HZ
	[PATCH 22/47] writeback: prevent bandwidth calculation overflow

spinlock protected bandwidth estimation, as suggested by Peter
	[PATCH 23/47] writeback: spinlock protected bdi bandwidth update

algorithm updates
	[PATCH 24/47] writeback: increase pause time on concurrent dirtiers
	[PATCH 25/47] writeback: make it easier to break from a dirty exceeded bdi
	[PATCH 26/47] writeback: start background writeback earlier
	[PATCH 27/47] writeback: user space think time compensation
	[PATCH 28/47] writeback: bdi base throttle bandwidth
	[PATCH 29/47] writeback: smoothed bdi dirty pages
	[PATCH 30/47] writeback: adapt max balance pause time to memory size
	[PATCH 31/47] writeback: increase min pause time on concurrent dirtiers

trace points
	[PATCH 32/47] writeback: extend balance_dirty_pages() trace event
	[PATCH 33/47] writeback: trace global dirty page states
	[PATCH 34/47] writeback: trace writeback_single_inode()

larger writeback chunk size
	[PATCH 35/47] writeback: scale IO chunk size up to device bandwidth

btrfs fixes
	[PATCH 36/47] btrfs: dont call balance_dirty_pages_ratelimited() on already dirty pages
	[PATCH 37/47] btrfs: lower the dirty balacing rate limit
	[PATCH 38/47] btrfs: wait on too many nr_async_bios

nfs fixes
	[PATCH 39/47] nfs: livelock prevention is now done in VFS
	[PATCH 40/47] NFS: writeback pages wait queue
	[PATCH 41/47] nfs: in-commit pages accounting and wait queue
	[PATCH 42/47] nfs: heuristics to avoid commit
	[PATCH 43/47] nfs: dont change wbc->nr_to_write in write_inode()
	[PATCH 44/47] nfs: limit the range of commits
	[PATCH 45/47] nfs: adapt congestion threshold to dirty threshold
	[PATCH 46/47] nfs: trace nfs_commit_unstable_pages()
	[PATCH 47/47] nfs: trace nfs_commit_release()

 Documentation/filesystems/writeback-throttling-design.txt |  210 ++++
 fs/btrfs/disk-io.c                                        |    7 
 fs/btrfs/file.c                                           |   16 
 fs/btrfs/ioctl.c                                          |    6 
 fs/btrfs/relocation.c                                     |    6 
 fs/fs-writeback.c                                         |   85 +
 fs/nfs/client.c                                           |    3 
 fs/nfs/file.c                                             |    9 
 fs/nfs/write.c                                            |  241 +++-
 include/linux/backing-dev.h                               |    9 
 include/linux/nfs_fs.h                                    |    1 
 include/linux/nfs_fs_sb.h                                 |    3 
 include/linux/sched.h                                     |    8 
 include/linux/writeback.h                                 |   26 
 include/trace/events/nfs.h                                |   89 +
 include/trace/events/writeback.h                          |  195 +++
 mm/backing-dev.c                                          |   32 
 mm/filemap.c                                              |    5 
 mm/memory_hotplug.c                                       |    3 
 mm/page-writeback.c                                       |  518 +++++++---
 20 files changed, 1212 insertions(+), 260 deletions(-)

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
