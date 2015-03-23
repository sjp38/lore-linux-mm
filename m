Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f47.google.com (mail-qg0-f47.google.com [209.85.192.47])
	by kanga.kvack.org (Postfix) with ESMTP id 88C656B0038
	for <linux-mm@kvack.org>; Mon, 23 Mar 2015 00:55:09 -0400 (EDT)
Received: by qgez102 with SMTP id z102so48333350qge.3
        for <linux-mm@kvack.org>; Sun, 22 Mar 2015 21:55:09 -0700 (PDT)
Received: from mail-qc0-x229.google.com (mail-qc0-x229.google.com. [2607:f8b0:400d:c01::229])
        by mx.google.com with ESMTPS id f198si11264270qka.3.2015.03.22.21.55.08
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 22 Mar 2015 21:55:08 -0700 (PDT)
Received: by qcay5 with SMTP id y5so46324983qca.1
        for <linux-mm@kvack.org>; Sun, 22 Mar 2015 21:55:08 -0700 (PDT)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCHSET 1/3 v2 block/for-4.1/core] writeback: cgroup writeback support
Date: Mon, 23 Mar 2015 00:54:11 -0400
Message-Id: <1427086499-15657-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk
Cc: linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com

Hello,

This is v2 of cgroup writeback support patchset.  Changes from the
last take[L] are

* Dropped dirtying an inode against multiple cgroups at the same time.
  At a given time, an inode always belongs to one cgroup
  bdi_writeback.  It's currently associated on the first-use but a
  later patchset will implement wb switching on foreign inodes.  This
  removed the colored blkcg_css association pointer in memcg and
  inode_wb_link.

* With the above change, cgroup writeback is now responsible for
  perfomring impedance matching when the association between memcg and
  blkcg changes.  This is achieved by making bdi_writeback per-memcg
  rather than per-blkcg.  On the unified hierarchy, blkcg implicitly
  enables memcg, so this gives a unique bdi_writeback for each memcg -
  blkcg combination.  This causes some complexities when the mapping
  changes and with congesttion state handling as there can be multiple
  wb's mapped to one blkcg.

* Refreshed on top of the current block/for-4.1/core bfd343aa1718
  ("blk-mq: don't wait in blk_mq_queue_enter() if __GFP_WAIT isn't
  set").  This includes refreshing on top of the new ->b_dirty_time
  changes.

blkio cgroup (blkcg) is severely crippled in that it can only control
read and direct write IOs.  blkcg can't tell which cgroup should be
held responsible for a given writeback IO and charges all of them to
the root cgroup - all normal write traffic ends up in the root cgroup.
Although the problem has been identified years ago, mainly because it
interacts with so many subsystems, it hasn't been solved yet.

This patchset finally implements cgroup writeback support so that
writeback of a page is attributed to the corresponding blkcg of the
memcg that the page belongs to.

Overall design
--------------

* This requires cooperation between memcg and blkcg.  Each inode is
  assigned to the blkcg mapped to the memcg being dirtied.

* struct bdi_writeback (wb) was always embedded in struct
  backing_dev_info (bdi) and the distinction between the two wasn't
  clear.  This patchset makes wb operate as an independent writeback
  execution domain.  bdi->wb is still embedded and serves the root
  cgroup but there can be other wb's for other cgroups.

* Each wb is associated with memcg.  As memcg is implicitly enabled by
  blkcg on the unified hierarchy, this gives a unique wb for each
  memcg-blkcg combination.  When memcg-blkcg mapping changes, a new wb
  is created and the existing wb is unlinked and drained.

* An inode is associated with the matching wb when it gets dirtied for
  the first time and written back by that wb.  A later patchset will
  implement dynamic wb switching.

* All writeback operations are made per-wb instead of per-bdi.
  bdi-wide operations are split across all member wb's.  If some
  finite amount needs to be distributed, be it number of pages to
  writeback or bdi->min/max_ratio, it's distributed according to the
  bandwidth proportion a wb has in the bdi.

* cgroup writeback support adds one pointer to struct inode.


Missing pieces
--------------

* It requires some cooperation from the filesystem and currently only
  works with ext2.  The changes necessary on the filesystem side are
  almost trivial.  I'll write up a documentation on it.

* blk-throttle works but cfq-iosched isn't ready for writebacks coming
  down with different cgroups.  cfq-iosched should be updated to have
  a writeback ioc per cgroup and route writeback IOs through it.


How to test
-----------

* Boot with kernel option "cgroup__DEVEL__legacy_files_on_dfl".

* umount /sys/fs/cgroup/memory
  umount /sys/fs/cgroup/blkio
  mkdir /sys/fs/cgroup/unified
  mount -t cgroup -o __DEVEL__sane_behavior cgroup /sys/fs/cgroup/unified
  echo +blkio > /sys/fs/cgroup/unified/cgroup.subtree_control

* Build the cgroup hierarchy (don't forget to enable blkio using
  subtree_control) and put processes in cgroups and run tests on ext2
  filesystems and blkio.throttle.* knobs.

This patchset contains the following 48 patches.

 0001-memcg-add-per-cgroup-dirty-page-accounting.patch
 0002-blkcg-move-block-blk-cgroup.h-to-include-linux-blk-c.patch
 0003-update-CONFIG_BLK_CGROUP-dummies-in-include-linux-bl.patch
 0004-memcg-add-mem_cgroup_root_css.patch
 0005-blkcg-add-blkcg_root_css.patch
 0006-cgroup-block-implement-task_get_css-and-use-it-in-bi.patch
 0007-blkcg-implement-task_get_blkcg_css.patch
 0008-blkcg-implement-bio_associate_blkcg.patch
 0009-memcg-implement-mem_cgroup_css_from_page.patch
 0010-writeback-move-backing_dev_info-state-into-bdi_write.patch
 0011-writeback-move-backing_dev_info-bdi_stat-into-bdi_wr.patch
 0012-writeback-move-bandwidth-related-fields-from-backing.patch
 0013-writeback-s-bdi-wb-in-mm-page-writeback.c.patch
 0014-writeback-move-backing_dev_info-wb_lock-and-worklist.patch
 0015-writeback-reorganize-mm-backing-dev.c.patch
 0016-writeback-separate-out-include-linux-backing-dev-def.patch
 0017-bdi-make-inode_to_bdi-inline.patch
 0018-writeback-add-gfp-to-wb_init.patch
 0019-bdi-separate-out-congested-state-into-a-separate-str.patch
 0020-writeback-add-CONFIG-BDI_CAP-FS-_CGROUP_WRITEBACK.patch
 0021-writeback-make-backing_dev_info-host-cgroup-specific.patch
 0022-writeback-blkcg-associate-each-blkcg_gq-with-the-cor.patch
 0023-writeback-attribute-stats-to-the-matching-per-cgroup.patch
 0024-writeback-let-balance_dirty_pages-work-on-the-matchi.patch
 0025-writeback-make-congestion-functions-per-bdi_writebac.patch
 0026-writeback-blkcg-restructure-blk_-set-clear-_queue_co.patch
 0027-writeback-blkcg-propagate-non-root-blkcg-congestion-.patch
 0028-writeback-implement-and-use-mapping_congested.patch
 0029-writeback-implement-WB_has_dirty_io-wb_state-flag.patch
 0030-writeback-implement-backing_dev_info-tot_write_bandw.patch
 0031-writeback-make-bdi_has_dirty_io-take-multiple-bdi_wr.patch
 0032-writeback-don-t-issue-wb_writeback_work-if-clean.patch
 0033-writeback-make-bdi-min-max_ratio-handling-cgroup-wri.patch
 0034-writeback-implement-bdi_for_each_wb.patch
 0035-writeback-remove-bdi_start_writeback.patch
 0036-writeback-make-laptop_mode_timer_fn-handle-multiple-.patch
 0037-writeback-make-writeback_in_progress-take-bdi_writeb.patch
 0038-writeback-make-bdi_start_background_writeback-take-b.patch
 0039-writeback-make-wakeup_flusher_threads-handle-multipl.patch
 0040-writeback-add-wb_writeback_work-auto_free.patch
 0041-writeback-implement-bdi_wait_for_completion.patch
 0042-writeback-implement-wb_wait_for_single_work.patch
 0043-writeback-restructure-try_writeback_inodes_sb-_nr.patch
 0044-writeback-make-writeback-initiation-functions-handle.patch
 0045-writeback-dirty-inodes-against-their-matching-cgroup.patch
 0046-buffer-writeback-make-__block_write_full_page-honor-.patch
 0047-mpage-make-__mpage_writepage-honor-cgroup-writeback.patch
 0048-ext2-enable-cgroup-writeback-support.patch

0001-0019 are preps.

0020-0045 gradually convert writeback code so that wb (bdi_writeback)
operates as an independent writeback domain instead of bdi
(backing_dev_info), a single bdi can have multiple per-cgroup wb's
working for it, and per-bdi operations are translated and distributed
to all its member wb's.

0046-0048 make lower layers to properly propagate the cgroup
association from the writeback layer and enable cgroup writeback on
ext2.

This patchset is on top of

  block/for-4.1/core bfd343aa1718 ("blk-mq: don't wait in blk_mq_queue_enter() if __GFP_WAIT isn't set")
+ [1] [PATCH] writeback: fix possible underflow in write bandwidth calculation

and available in the following git branch.

 git://git.kernel.org/pub/scm/linux/kernel/git/tj/cgroup.git review-cgroup-writeback-20150322

diffstat follows.  Thanks.

 Documentation/cgroups/memory.txt |    1 
 block/bio.c                      |   35 +-
 block/blk-cgroup.c               |   28 +
 block/blk-cgroup.h               |  603 -----------------------------------
 block/blk-core.c                 |   70 ++--
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
 fs/block_dev.c                   |    9 
 fs/buffer.c                      |   60 ++-
 fs/ext2/super.c                  |    2 
 fs/ext4/extents.c                |    1 
 fs/ext4/mballoc.c                |    1 
 fs/ext4/super.c                  |    1 
 fs/f2fs/node.c                   |    4 
 fs/f2fs/segment.h                |    3 
 fs/fs-writeback.c                |  609 +++++++++++++++++++++++++----------
 fs/fuse/file.c                   |   12 
 fs/gfs2/super.c                  |    2 
 fs/hfs/super.c                   |    1 
 fs/hfsplus/super.c               |    1 
 fs/inode.c                       |    1 
 fs/mpage.c                       |    2 
 fs/nfs/filelayout/filelayout.c   |    1 
 fs/nfs/internal.h                |    2 
 fs/nfs/write.c                   |    3 
 fs/ocfs2/file.c                  |    1 
 fs/reiserfs/super.c              |    1 
 fs/ufs/super.c                   |    1 
 fs/xfs/xfs_aops.c                |   12 
 fs/xfs/xfs_file.c                |    1 
 include/linux/backing-dev-defs.h |  188 ++++++++++
 include/linux/backing-dev.h      |  572 ++++++++++++++++++++++++---------
 include/linux/bio.h              |    3 
 include/linux/blk-cgroup.h       |  631 ++++++++++++++++++++++++++++++++++++
 include/linux/blkdev.h           |   21 -
 include/linux/cgroup.h           |   25 +
 include/linux/fs.h               |   13 
 include/linux/memcontrol.h       |   10 
 include/linux/mm.h               |    3 
 include/linux/pagemap.h          |    3 
 include/linux/writeback.h        |   25 -
 include/trace/events/writeback.h |    8 
 init/Kconfig                     |    5 
 mm/backing-dev.c                 |  667 +++++++++++++++++++++++++++++++--------
 mm/fadvise.c                     |    2 
 mm/filemap.c                     |   32 +
 mm/madvise.c                     |    1 
 mm/memcontrol.c                  |   59 +++
 mm/page-writeback.c              |  649 +++++++++++++++++++++----------------
 mm/readahead.c                   |    2 
 mm/rmap.c                        |    2 
 mm/truncate.c                    |   25 +
 mm/vmscan.c                      |   29 +
 69 files changed, 2979 insertions(+), 1501 deletions(-)

--
tejun

[L] http://lkml.kernel.org/g/1420579582-8516-1-git-send-email-tj@kernel.org
[1] http://lkml.kernel.org/g/20150323041848.GA8991@htj.duckdns.org

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
