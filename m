Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f169.google.com (mail-qc0-f169.google.com [209.85.216.169])
	by kanga.kvack.org (Postfix) with ESMTP id 539B26B00E9
	for <linux-mm@kvack.org>; Tue,  6 Jan 2015 14:29:23 -0500 (EST)
Received: by mail-qc0-f169.google.com with SMTP id w7so17418352qcr.28
        for <linux-mm@kvack.org>; Tue, 06 Jan 2015 11:29:23 -0800 (PST)
Received: from mail-qa0-x229.google.com (mail-qa0-x229.google.com. [2607:f8b0:400d:c00::229])
        by mx.google.com with ESMTPS id s3si65288540qak.101.2015.01.06.11.29.21
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 06 Jan 2015 11:29:22 -0800 (PST)
Received: by mail-qa0-f41.google.com with SMTP id s7so16801339qap.0
        for <linux-mm@kvack.org>; Tue, 06 Jan 2015 11:29:21 -0800 (PST)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCHSET v2 block/for-next] writeback: prepare for cgroup writeback support
Date: Tue,  6 Jan 2015 14:29:01 -0500
Message-Id: <1420572557-11572-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk
Cc: linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz

Hello,

Changes from the last take[L] are

* 0001-0006 added.

* Minor changes to accomodate review points from the last round and
  fix compile issues w/ different config options.

This patchset contains the following sixteen patches to prepare for
cgroup writeback support.  None of these patches introduces behavior
changes.

 0001-blkcg-move-block-blk-cgroup.h-to-include-linux-blk-c.patch
 0002-update-CONFIG_BLK_CGROUP-dummies-in-include-linux-bl.patch
 0003-blkcg-add-blkcg_root_css.patch
 0004-cgroup-block-implement-task_get_css-and-use-it-in-bi.patch
 0005-blkcg-implement-task_get_blkcg_css.patch
 0006-blkcg-implement-bio_associate_blkcg.patch
 0007-writeback-move-backing_dev_info-state-into-bdi_write.patch
 0008-writeback-move-backing_dev_info-bdi_stat-into-bdi_wr.patch
 0009-writeback-move-bandwidth-related-fields-from-backing.patch
 0010-writeback-move-backing_dev_info-wb_lock-and-worklist.patch
 0011-writeback-move-lingering-dirty-IO-lists-transfer-fro.patch
 0012-writeback-reorganize-mm-backing-dev.c.patch
 0013-writeback-separate-out-include-linux-backing-dev-def.patch
 0014-writeback-cosmetic-change-in-account_page_dirtied.patch
 0015-writeback-add-gfp-to-wb_init.patch
 0016-writeback-move-inode_to_bdi-to-include-linux-backing.patch

0001-0006 are prep patches in blkcg.  They're all self-explanatory.

0007-0011 move writeback related fields from bdi (backing_dev_info) to
wb (bdi_writeback).  Currently, one bdi embeds one wb and the
separation between the two is blurry.  bdi's lock protects wb's fields
and fields which are closely related are scattered across the two.
These five patches move all fields which are used during writeback
into wb.

0012-0016 are misc prep patches in writeback.  They're all rather
trivial and each is self-explanatory.

The patchset is on top of -mm + percpu/for-3.20 + cgroup/for-3.20 of
today (2016-01-06) and is available in the following git branch.

 git://git.kernel.org/pub/scm/linux/kernel/git/tj/cgroup.git review-cgroup-writeback-prep-20150106

diffstat follows.  Thanks.

 block/bio.c                      |   35 +-
 block/blk-cgroup.c               |    4 
 block/blk-cgroup.h               |  603 -------------------------------------
 block/blk-core.c                 |    3 
 block/blk-integrity.c            |    1 
 block/blk-sysfs.c                |    3 
 block/blk-throttle.c             |    2 
 block/bounce.c                   |    1 
 block/cfq-iosched.c              |    2 
 block/elevator.c                 |    2 
 block/genhd.c                    |    1 
 drivers/block/drbd/drbd_int.h    |    1 
 drivers/block/drbd/drbd_main.c   |   10 
 drivers/block/pktcdvd.c          |    1 
 drivers/char/raw.c               |    1 
 drivers/md/bcache/request.c      |    1 
 drivers/md/dm.c                  |    2 
 drivers/md/dm.h                  |    1 
 drivers/md/md.h                  |    1 
 drivers/md/raid1.c               |    4 
 drivers/md/raid10.c              |    2 
 drivers/mtd/devices/block2mtd.c  |    1 
 fs/aio.c                         |    1 
 fs/block_dev.c                   |    1 
 fs/ext4/extents.c                |    1 
 fs/ext4/mballoc.c                |    1 
 fs/f2fs/node.c                   |    4 
 fs/f2fs/segment.h                |    3 
 fs/fs-writeback.c                |  121 +++----
 fs/fuse/file.c                   |   12 
 fs/gfs2/super.c                  |    2 
 fs/hfs/super.c                   |    1 
 fs/hfsplus/super.c               |    1 
 fs/nfs/filelayout/filelayout.c   |    5 
 fs/nfs/write.c                   |   11 
 fs/reiserfs/super.c              |    1 
 fs/ufs/super.c                   |    1 
 include/linux/backing-dev-defs.h |  105 ++++++
 include/linux/backing-dev.h      |  174 ++--------
 include/linux/bio.h              |    3 
 include/linux/blk-cgroup.h       |  621 +++++++++++++++++++++++++++++++++++++++
 include/linux/blkdev.h           |    2 
 include/linux/cgroup.h           |   25 +
 include/linux/writeback.h        |   19 -
 include/trace/events/writeback.h |    8 
 mm/backing-dev.c                 |  306 +++++++++----------
 mm/filemap.c                     |    2 
 mm/madvise.c                     |    1 
 mm/page-writeback.c              |  320 ++++++++++----------
 mm/truncate.c                    |    4 
 50 files changed, 1261 insertions(+), 1177 deletions(-)

--
tejun

[L] http://lkml.kernel.org/g/1416299848-22112-1-git-send-email-tj@kernel.org

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
