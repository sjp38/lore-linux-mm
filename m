Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f50.google.com (mail-qg0-f50.google.com [209.85.192.50])
	by kanga.kvack.org (Postfix) with ESMTP id 2B1596B0124
	for <linux-mm@kvack.org>; Tue,  6 Jan 2015 16:26:29 -0500 (EST)
Received: by mail-qg0-f50.google.com with SMTP id z60so75080qgd.9
        for <linux-mm@kvack.org>; Tue, 06 Jan 2015 13:26:29 -0800 (PST)
Received: from mail-qa0-x22b.google.com (mail-qa0-x22b.google.com. [2607:f8b0:400d:c00::22b])
        by mx.google.com with ESMTPS id b8si65730678qaa.41.2015.01.06.13.26.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 06 Jan 2015 13:26:28 -0800 (PST)
Received: by mail-qa0-f43.google.com with SMTP id n4so230242qaq.2
        for <linux-mm@kvack.org>; Tue, 06 Jan 2015 13:26:27 -0800 (PST)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCHSET RFC block/for-next] writeback: cgroup writeback support
Date: Tue,  6 Jan 2015 16:25:37 -0500
Message-Id: <1420579582-8516-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk
Cc: linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com

Hello,

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

* This requires cooperation between memcg and blkcg.  The IOs are
  charged to the blkcg that the page's memcg corresponds to.  This
  currently works only on the unified hierarchy.

* Each memcg maintains reference counted front and back pointers to
  the correspending blkcg.  Whenever a page gets dirtied or initiates
  writeback, it uses the blkcg the front one points to.  The reference
  counting ensures that the association remains till the page is done
  and having front and back pointers guarantees that the association
  can change without being live-locked by pages being contiuously
  dirtied.

* struct bdi_writeback (wb) was always embedded in struct
  backing_dev_info (bdi) and the distinction between the two wasn't
  clear.  This patchset makes wb operate as an independent writeback

  execution.  bdi->wb is still embedded and serves the root cgroup but
  other wb's can be associated with a single bdi each serving a
  non-root wb.

* All writeback operations are made per-wb instead of per-bdi.
  bdi-wide operations are split across all member wb's.  If some
  finite amount needs to be distributed, be it number of pages to
  writeback or bdi->min/max_ratio, it's distributed according to the
  bandwidth proportion a wb has in the bdi.

* Non-root wb's host and write back only dirty pages (I_DIRTY_PAGES).
  I_DIRTY_[DATA]SYNC is always handled by the root wb.

* An inode may have pages dirtied by different memcgs, which naturally
  means that it should be able to be dirtied against multiple wb's.
  To support linking an inode against multiple wb's, iwbl
  (inode_wb_link) is introduced.  An inode has multiple iwbl's
  associated with it if it's dirty against multiple wb's.

* Overall, cgroup writeback support adds 2.5 pointers to struct inode
  where the 0.5 is masked by alignment if !CONFIG_IMA.


Missing pieces
--------------

* It requires some cooperation from the filesystem and currently only
  works with ext2.  The changes necessary on the filesystem side
  aren't too big.  I'll write up a documentation on it.

* When an inode has multiple iwbls, they're put on a sorted list.
  Depending on the usage, this list can grow quite long.  We really
  want an RCU-safe balanced tree here, which doesn't exist in the
  kernel yet.  Bonsai tree should do.

* balance_dirty_pages currently doesn't consider the task's memcg when
  calculating the number of dirtyable pages.  This means that tasks in
  memcg won't have the benefit of smooth background writeback and will
  bump into direct reclaim all the time.  This has always been like
  this but with cgroup writeback support, this is also finally
  fixable.  I'll work on this as the earlier part gets settled.

* balance_dirty_pages sleeps while holding i_mutex, which means that
  when an inode is being dirtied actively by multiple cgroups, the
  slowest writeback will choke others by sleeping most of the time
  while holding i_mutex.  Once the above per-memcg dirty ratio issue
  is solved, this can be worked around by deferring the actual pausing
  to right before control returns to userland.  This would lead to
  partial write completions when the inode is contended for writes by
  multiple cgroups.

* blk-throttle works but cfq-iosched isn't ready for writebacks coming
  down with different cgroups.  cfq-iosched should be updated to have
  a writeback ioc per cgroup and route writeback IOs through it.

* More testing and polishing.


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


This patchset contains the following 45 patches.

 0001-writeback-add-struct-dirty_context.patch
 0002-writeback-add-CONFIG-BDI_CAP-FS-_CGROUP_WRITEBACK.patch
 0003-memcg-encode-page_cgflags-in-the-lower-bits-of-page-.patch
 0004-memcg-writeback-implement-memcg_blkcg_ptr.patch
 0005-writeback-make-backing_dev_info-host-cgroup-specific.patch
 0006-writeback-blkcg-associate-each-blkcg_gq-with-the-cor.patch
 0007-writeback-attribute-stats-to-the-matching-per-cgroup.patch
 0008-writeback-let-balance_dirty_pages-work-on-the-matchi.patch
 0009-writeback-make-congestion-functions-per-bdi_writebac.patch
 0010-writeback-blkcg-restructure-blk_-set-clear-_queue_co.patch
 0011-writeback-blkcg-propagate-non-root-blkcg-congestion-.patch
 0012-writeback-implement-and-use-mapping_congested.patch
 0013-writeback-implement-WB_has_dirty_io-wb_state-flag.patch
 0014-writeback-implement-backing_dev_info-tot_write_bandw.patch
 0015-writeback-make-bdi_has_dirty_io-take-multiple-bdi_wr.patch
 0016-writeback-don-t-issue-wb_writeback_work-if-clean.patch
 0017-writeback-make-bdi-min-max_ratio-handling-cgroup-wri.patch
 0018-writeback-implement-bdi_for_each_wb.patch
 0019-writeback-remove-bdi_start_writeback.patch
 0020-writeback-make-laptop_mode_timer_fn-handle-multiple-.patch
 0021-writeback-make-writeback_in_progress-take-bdi_writeb.patch
 0022-writeback-make-bdi_start_background_writeback-take-b.patch
 0023-writeback-make-wakeup_flusher_threads-handle-multipl.patch
 0024-writeback-add-wb_writeback_work-auto_free.patch
 0025-writeback-implement-bdi_wait_for_completion.patch
 0026-writeback-implement-wb_wait_for_single_work.patch
 0027-writeback-restructure-try_writeback_inodes_sb-_nr.patch
 0028-writeback-make-writeback-initiation-functions-handle.patch
 0029-writeback-move-i_wb_list-emptiness-test-into-inode_w.patch
 0030-vfs-writeback-introduce-struct-inode_wb_link.patch
 0031-vfs-writeback-add-inode_wb_link-data-point-to-the-as.patch
 0032-vfs-writeback-move-inode-dirtied_when-into-inode-i_w.patch
 0033-writeback-minor-reorganization-of-fs-fs-writeback.c.patch
 0034-vfs-writeback-implement-support-for-multiple-inode_w.patch
 0035-vfs-writeback-implement-inode-i_nr_syncs.patch
 0036-writeback-dirty-inodes-against-their-matching-cgroup.patch
 0037-writeback-make-writeback_control-carry-the-inode_wb_.patch
 0038-writeback-make-cyclic-writeback-cursor-cgroup-writeb.patch
 0039-writeback-make-DIRTY_PAGES-tracking-cgroup-writeback.patch
 0040-writeback-make-write_cache_pages-cgroup-writeback-aw.patch
 0041-writeback-make-__writeback_single_inode-cgroup-write.patch
 0042-writeback-make-__filemap_fdatawrite_range-croup-writ.patch
 0043-buffer-writeback-make-__block_write_full_page-honor-.patch
 0044-mpage-make-__mpage_writepage-honor-cgroup-writeback.patch
 0045-ext2-enable-cgroup-writeback-support.patch

0001-0002 are basic preps.

0003-0004 implement memcg-blkcg association that dirty and
under-writeback pages can use.

0005-0029 gradually convert writeback code so that wb (bdi_writeback)
operates as an independent writeback domain instead of bdi
(backing_dev_info), a single bdi can have multiple per-cgroup wb's
working for it, and per-bdi operations are translated and distributed
to all its member wb's.

0030-0042 introduce iwbl (inode_wb_link) so that an inode can be
associated against multiple wb's as it gets dirtied by different
cgroups and make inode-wide operations be distributed across them.

0043-0045 make lower layers to properly propagate the cgroup
association from the writeback layer and enable cgroup writeback on
ext2.

This patchset is on top of

  -mm + percpu/for-3.20 + cgroup/for-3.20 as of today (2016-01-06)
  + [1] [PATCHSET v2] writeback: prepare for cgroup writeback support

and available in the following git branch.

 git://git.kernel.org/pub/scm/linux/kernel/git/tj/cgroup.git review-cgroup-writeback-20150106

diffstat follows.  Thanks.

 block/blk-cgroup.c               |   26 
 block/blk-core.c                 |   68 +
 fs/block_dev.c                   |    1 
 fs/buffer.c                      |   30 
 fs/ext2/super.c                  |    2 
 fs/fs-writeback.c                | 1450 +++++++++++++++++++++++++++++++--------
 fs/inode.c                       |   12 
 fs/mpage.c                       |    6 
 fs/xfs/xfs_aops.c                |    7 
 include/linux/backing-dev-defs.h |  153 +++-
 include/linux/backing-dev.h      |  626 ++++++++++++++++
 include/linux/blk-cgroup.h       |   10 
 include/linux/blkdev.h           |   19 
 include/linux/fs.h               |   14 
 include/linux/memcontrol.h       |   56 +
 include/linux/mm.h               |    3 
 include/linux/mm_types.h         |    3 
 include/linux/writeback.h        |   10 
 include/trace/events/writeback.h |    4 
 init/Kconfig                     |    5 
 mm/backing-dev.c                 |  304 +++++++-
 mm/debug.c                       |    2 
 mm/fadvise.c                     |    2 
 mm/filemap.c                     |    5 
 mm/memcontrol.c                  |  522 +++++++++++++-
 mm/page-writeback.c              |  184 ++++
 mm/readahead.c                   |    2 
 mm/truncate.c                    |    4 
 mm/vmscan.c                      |   12 
 29 files changed, 3074 insertions(+), 468 deletions(-)

--
tejun

[1] http://lkml.kernel.org/g/1420572557-11572-1-git-send-email-tj@kernel.org

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
