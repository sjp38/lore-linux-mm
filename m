Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id AB9956B004A
	for <linux-mm@kvack.org>; Wed, 28 Mar 2012 10:23:00 -0400 (EDT)
Message-Id: <20120328121308.568545879@intel.com>
Date: Wed, 28 Mar 2012 20:13:08 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: [PATCH 0/6] buffered write IO controller in balance_dirty_pages()
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux Memory Management List <linux-mm@kvack.org>
Cc: Vivek Goyal <vgoyal@redhat.com>, Suresh Jayaraman <sjayaraman@suse.com>, Andrea Righi <andrea@betterlinux.com>, Jeff Moyer <jmoyer@redhat.com>, linux-fsdevel@vger.kernel.org, Fengguang Wu <fengguang.wu@intel.com>, LKML <linux-kernel@vger.kernel.org>


Here is one possible solution to "buffered write IO controller", based on Linux
v3.3

git://git.kernel.org/pub/scm/linux/kernel/git/wfg/linux.git  buffered-write-io-controller

Features:
- support blkio.weight
- support blkio.throttle.buffered_write_bps

Possibilities:
- it's trivial to support per-bdi .weight or .buffered_write_bps

Pros:
1) simple
2) virtually no space/time overheads
3) independent of the block layer and IO schedulers, hence
3.1) supports all filesystems/storages, eg. NFS/pNFS, CIFS, sshfs, ...
3.2) supports all IO schedulers. One may use noop for SSDs, inside virtual machines, over iSCSI, etc.

Cons:
1) don't try to smooth bursty IO submission in the flusher thread (*)
2) don't support IOPS based throttling
3) introduces semantic differences to blkio.weight, which will be
   - working by "bandwidth" for buffered writes
   - working by "device time" for direct IO

(*) Maybe not a big concern, since the bursties are limited to 500ms: if one dd
is throttled to 50% disk bandwidth, the flusher thread will be waking up on
every 1 second, keep the disk busy for 500ms and then go idle for 500ms; if
throttled to 10% disk bandwidth, the flusher thread will wake up on every 5s,
keep busy for 500ms and stay idle for 4.5s.

The test results included in the last patch look pretty good in despite of the
simple implementation.

 [PATCH 1/6] blk-cgroup: move blk-cgroup.h in include/linux/blk-cgroup.h
 [PATCH 2/6] blk-cgroup: account dirtied pages
 [PATCH 3/6] blk-cgroup: buffered write IO controller - bandwidth weight
 [PATCH 4/6] blk-cgroup: buffered write IO controller - bandwidth limit
 [PATCH 5/6] blk-cgroup: buffered write IO controller - bandwidth limit interface
 [PATCH 6/6] blk-cgroup: buffered write IO controller - debug trace

The changeset is dominated by the blk-cgroup.h move.
The core changes (to page-writeback.c) are merely 77 lines.

 block/blk-cgroup.c               |   27 +
 block/blk-cgroup.h               |  364 --------------------------
 block/blk-throttle.c             |    2 
 block/cfq.h                      |    2 
 include/linux/blk-cgroup.h       |  396 +++++++++++++++++++++++++++++
 include/trace/events/writeback.h |   34 ++
 mm/page-writeback.c              |   77 +++++
 7 files changed, 530 insertions(+), 372 deletions(-)

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
