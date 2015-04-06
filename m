Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f181.google.com (mail-qc0-f181.google.com [209.85.216.181])
	by kanga.kvack.org (Postfix) with ESMTP id 0DD0E6B0070
	for <linux-mm@kvack.org>; Mon,  6 Apr 2015 16:18:33 -0400 (EDT)
Received: by qcbii10 with SMTP id ii10so15430739qcb.2
        for <linux-mm@kvack.org>; Mon, 06 Apr 2015 13:18:32 -0700 (PDT)
Received: from mail-qc0-x236.google.com (mail-qc0-x236.google.com. [2607:f8b0:400d:c01::236])
        by mx.google.com with ESMTPS id q12si5192091qkh.83.2015.04.06.13.18.31
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Apr 2015 13:18:32 -0700 (PDT)
Received: by qcgx3 with SMTP id x3so15353759qcg.3
        for <linux-mm@kvack.org>; Mon, 06 Apr 2015 13:18:31 -0700 (PDT)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCHSET 3/3 v2 block/for-4.1/core] writeback: implement foreign cgroup inode bdi_writeback switching
Date: Mon,  6 Apr 2015 16:18:18 -0400
Message-Id: <1428351508-8399-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk
Cc: linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com

Hello,

The changes from the last take[L] are

* inode_wb_stat_unlocked_begin/end() are generalized and renamed to
  inode_wb_unlocked_begin/end() and now used for inode_congested()
  which needs to determine the associated wb locklessly.  This adds
  0007-writeback-use-unlocked_inode_to_wb-transaction-in-in.patch.

* 0010-writeback-disassociate-inodes-from-dying-bdi_writeba.patch
  added to implement immediate switching from dead wb's.

The previous two patchsets [2][3] implemented cgroup writeback support
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
 0004-truncate-swap-the-order-of-conditionals-in-cancel_di.patch
 0005-writeback-implement-locked_-inode_to_wb_and_lock_lis.patch
 0006-writeback-implement-unlocked_inode_to_wb-transaction.patch
 0007-writeback-use-unlocked_inode_to_wb-transaction-in-in.patch
 0008-writeback-add-lockdep-annotation-to-inode_to_wb.patch
 0009-writeback-implement-foreign-cgroup-inode-bdi_writeba.patch
 0010-writeback-disassociate-inodes-from-dying-bdi_writeba.patch

This patchset is on top of

  block/for-4.1/core bfd343aa1718 ("blk-mq: don't wait in blk_mq_queue_enter() if __GFP_WAIT isn't set")
+ [1] [PATCH] writeback: fix possible underflow in write bandwidth calculation
+ [2] [PATCHSET 1/3 v3 block/for-4.1/core] writeback: cgroup writeback support
+ [3] [PATCHSET 2/3 v2 block/for-4.1/core] writeback: cgroup writeback backpressure propagation

and available in the following git branch.

 git://git.kernel.org/pub/scm/linux/kernel/git/tj/cgroup.git review-cgroup-writeback-switch-20150322

diffstat follows.  Thanks.

 fs/buffer.c                      |   26 -
 fs/fs-writeback.c                |  523 ++++++++++++++++++++++++++++++++++++++-
 fs/mpage.c                       |    3 
 include/linux/backing-dev-defs.h |   66 ++++
 include/linux/backing-dev.h      |  142 ++++------
 include/linux/fs.h               |   11 
 include/linux/writeback.h        |  123 +++++++++
 mm/backing-dev.c                 |   30 --
 mm/filemap.c                     |    2 
 mm/page-writeback.c              |   16 -
 mm/truncate.c                    |   21 -
 11 files changed, 821 insertions(+), 142 deletions(-)

--
tejun

[L] http://lkml.kernel.org/g/1427088344-17542-1-git-send-email-tj@kernel.org
[L] http://lkml.kernel.org/g/1428350674-8303-1-git-send-email-tj@kernel.org
[1] http://lkml.kernel.org/g/20150323041848.GA8991@htj.duckdns.org
[2] http://lkml.kernel.org/g/1428350318-8215-1-git-send-email-tj@kernel.org

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
