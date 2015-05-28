Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f50.google.com (mail-qg0-f50.google.com [209.85.192.50])
	by kanga.kvack.org (Postfix) with ESMTP id AF4116B0032
	for <linux-mm@kvack.org>; Thu, 28 May 2015 14:51:01 -0400 (EDT)
Received: by qgg60 with SMTP id 60so20446541qgg.2
        for <linux-mm@kvack.org>; Thu, 28 May 2015 11:51:01 -0700 (PDT)
Received: from mail-qc0-x230.google.com (mail-qc0-x230.google.com. [2607:f8b0:400d:c01::230])
        by mx.google.com with ESMTPS id m70si3263827qhb.89.2015.05.28.11.51.00
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 May 2015 11:51:00 -0700 (PDT)
Received: by qchk10 with SMTP id k10so18271412qch.2
        for <linux-mm@kvack.org>; Thu, 28 May 2015 11:51:00 -0700 (PDT)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCHSET 3/3 v4 block/for-4.2/core] writeback: implement foreign cgroup inode bdi_writeback switching
Date: Thu, 28 May 2015 14:50:48 -0400
Message-Id: <1432839057-17609-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk
Cc: linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com, khlebnikov@yandex-team.ru

Hello,

The changes from the last take[L] are

* 0002-writeback-make-writeback_control-track-the-inode-bei.patch and
  0003-writeback-implement-foreign-cgroup-inode-detection.patch
  assumed that all wbc's are attached to the inode and wb being
  written out; however, pageout() path doesn't participate in cgroup
  writeback leading to oops.

  pageout() isn't the main writeback path, so the impact on isolation
  is relatively limited and as the whole path runs on the same thread
  we don't want it to block on slow cgroups anyway.  In the long term,
  the best route seems to make the path kick off the usual writeback
  path rather than trying to write pages directly.

  Both patches updated to skip cgroup writeback related processing if
  the wbc is not associated with inode / wb.

* might_lock() on tree_lock dropped from
  0007-writeback-add-lockdep-annotation-to-inode_to_wb.patch due to
  spurious locking context warnings.  Unfortunately, there isn't a
  simple way to express _irqsave for might_lock().

The previous two patchsets [1][2] implemented cgroup writeback support
and backpressure propagation through dirty throttling mechanism;
however, the inode is assigned to the wb (bdi_writeback) matching the
first dirtied page and stays there until released.  This first-use
policy can easily lead to gross misbehaviors - a single stray dirty
page can cause gigatbytes to be written by the wrong cgroup.  Also,
while concurrently write sharing an inode is extremely rare and
unsupported, inodes jumping cgroups over time are more common.

This patchset implements foreign cgroup inode detection and wb
switching.  Each writeback run tracks the majority wb being written
using a simple but fairly robust algorithm and when an inode
persistently writes out more foreign cgroup pages than local ones, the
inode is transferred to the majority winner.

This patchset adds 8 bytes to inode making the total per-inode space
overhead of cgroup writeback support 16 bytes on 64bit systems.  The
computational overhead should be negligible.  If the writer changes
from one cgroup to another entirely, the mechanism can render the
correct switch verdict in several seconds of IO time in most cases and
it can converge on the correct answer in reasonable amount of time
even in more ambiguous cases.

This patchset contains the following 8 patches.

 0001-writeback-relocate-wb-_try-_get-wb_put-inode_-attach.patch
 0002-writeback-make-writeback_control-track-the-inode-bei.patch
 0003-writeback-implement-foreign-cgroup-inode-detection.patch
 0004-writeback-implement-locked_-inode_to_wb_and_lock_lis.patch
 0005-writeback-implement-unlocked_inode_to_wb-transaction.patch
 0006-writeback-use-unlocked_inode_to_wb-transaction-in-in.patch
 0007-writeback-add-lockdep-annotation-to-inode_to_wb.patch
 0008-writeback-implement-foreign-cgroup-inode-bdi_writeba.patch
 0009-writeback-disassociate-inodes-from-dying-bdi_writeba.patch

This patchset is on top of

  block/for-4.2/core b04a5636a665 ("block: replace trylock with mutex_lock in blkdev_reread_part()")
+ [1] [PATCHSET 1/3 v4 block/for-4.2/core] writeback: cgroup writeback support
+ [2] [PATCHSET 2/3 v3 block/for-4.2/core] writeback: cgroup writeback backpressure propagation

and available in the following git branch.

 git://git.kernel.org/pub/scm/linux/kernel/git/tj/cgroup.git review-cgroup-writeback-switch-20150528

diffstat follows.  Thanks.

 fs/buffer.c                      |   26 -
 fs/fs-writeback.c                |  532 ++++++++++++++++++++++++++++++++++++++-
 fs/mpage.c                       |    3 
 include/linux/backing-dev-defs.h |   66 ++++
 include/linux/backing-dev.h      |  142 ++++------
 include/linux/fs.h               |   11 
 include/linux/mm.h               |    3 
 include/linux/writeback.h        |  130 +++++++++
 mm/backing-dev.c                 |   30 --
 mm/filemap.c                     |    5 
 mm/page-writeback.c              |   27 +
 11 files changed, 836 insertions(+), 139 deletions(-)

--
tejun

[L] http://lkml.kernel.org/g/1432334183-6324-1-git-send-email-tj@kernel.org
[1] http://lkml.kernel.org/g/1432329245-5844-1-git-send-email-tj@kernel.org
[2] http://lkml.kernel.org/g/1428350674-8303-1-git-send-email-tj@kernel.org

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
