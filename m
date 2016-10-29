Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id B06F86B028F
	for <linux-mm@kvack.org>; Sat, 29 Oct 2016 04:11:49 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id r13so58300122pag.1
        for <linux-mm@kvack.org>; Sat, 29 Oct 2016 01:11:49 -0700 (PDT)
Received: from mail-pf0-x243.google.com (mail-pf0-x243.google.com. [2607:f8b0:400e:c00::243])
        by mx.google.com with ESMTPS id z70si2370500pff.228.2016.10.29.01.11.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 29 Oct 2016 01:11:48 -0700 (PDT)
Received: by mail-pf0-x243.google.com with SMTP id u84so3373309pfj.1
        for <linux-mm@kvack.org>; Sat, 29 Oct 2016 01:11:48 -0700 (PDT)
From: Ming Lei <tom.leiming@gmail.com>
Subject: [PATCH 00/60] block: support multipage bvec
Date: Sat, 29 Oct 2016 16:07:59 +0800
Message-Id: <1477728600-12938-1-git-send-email-tom.leiming@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@fb.com>, linux-kernel@vger.kernel.org
Cc: linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, Christoph Hellwig <hch@infradead.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Ming Lei <tom.leiming@gmail.com>, Al Viro <viro@ZenIV.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Bart Van Assche <bart.vanassche@sandisk.com>, "open list:GFS2 FILE SYSTEM" <cluster-devel@redhat.com>, Coly Li <colyli@suse.de>, Dan Williams <dan.j.williams@intel.com>, "open list:DEVICE-MAPPER  LVM" <dm-devel@redhat.com>, "open list:DRBD DRIVER" <drbd-dev@lists.linbit.com>, Eric Wheeler <git@linux.ewheeler.net>, Guoqing Jiang <gqjiang@suse.com>, Hannes Reinecke <hare@suse.com>, Hannes Reinecke <hare@suse.de>, Jiri Kosina <jkosina@suse.cz>, Joe Perches <joe@perches.com>, Johannes Berg <johannes.berg@intel.com>, Johannes Thumshirn <jthumshirn@suse.de>, Keith Busch <keith.busch@intel.com>, Kent Overstreet <kent.overstreet@gmail.com>, Kent Overstreet <kmo@daterainc.com>, "open list:BCACHE BLOCK LAYER CACHE" <linux-bcache@vger.kernel.org>, "open list:BTRFS FILE SYSTEM" <linux-btrfs@vger.kernel.org>, "open list:EXT4 FILE SYSTEM" <linux-ext4@vger.kernel.org>, "open list:F2FS FILE SYSTEM" <linux-f2fs-devel@lists.sourceforge.net>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, "open list:NVM EXPRESS TARGET DRIVER" <linux-nvme@lists.infradead.org>, "open list:SUSPEND TO RAM" <linux-pm@vger.kernel.org>, "open list:SOFTWARE RAID Multiple Disks SUPPORT" <linux-raid@vger.kernel.org>, "open list:TARGET SUBSYSTEM" <linux-scsi@vger.kernel.org>, "open list:XFS FILESYSTEM" <linux-xfs@vger.kernel.org>, "open list:LogFS" <logfs@logfs.org>, Michal Hocko <mhocko@suse.com>, Mike Christie <mchristi@redhat.com>, Mike Snitzer <snitzer@redhat.com>, Minchan Kim <minchan@kernel.org>, Minfei Huang <mnghuan@gmail.com>, "open list:OSD LIBRARY and FILESYSTEM" <osd-dev@open-osd.org>, Petr Mladek <pmladek@suse.com>, Rasmus Villemoes <linux@rasmusvillemoes.dk>, Takashi Iwai <tiwai@suse.de>, "open list:TARGET SUBSYSTEM" <target-devel@vger.kernel.org>, Toshi Kani <toshi.kani@hpe.com>, Yijing Wang <wangyijing@huawei.com>, Zheng Liu <gnehzuil.liu@gmail.com>, Zheng Liu <wenqing.lz@taobao.com>

Hi,

This patchset brings multipage bvec into block layer. Basic
xfstests(-a auto) over virtio-blk/virtio-scsi have been run
and no regression is found, so it should be good enough
to show the approach now, and any comments are welcome!

1) what is multipage bvec?

Multipage bvecs means that one 'struct bio_bvec' can hold
multiple pages which are physically contiguous instead
of one single page used in linux kernel for long time.

2) why is multipage bvec introduced?

Kent proposed the idea[1] first. 

As system's RAM becomes much bigger than before, and 
at the same time huge page, transparent huge page and
memory compaction are widely used, it is a bit easy now
to see physically contiguous pages inside fs/block stack.
On the other hand, from block layer's view, it isn't
necessary to store intermediate pages into bvec, and
it is enough to just store the physicallly contiguous
'segment'.

Also huge pages are being brought to filesystem[2], we
can do IO a hugepage a time[3], requires that one bio can
transfer at least one huge page one time. Turns out it isn't
flexiable to change BIO_MAX_PAGES simply[3]. Multipage bvec
can fit in this case very well.

With multipage bvec:

- bio size can be increased and it should improve some
high-bandwidth IO case in theory[4].

- Inside block layer, both bio splitting and sg map can
become more efficient than before by just traversing the
physically contiguous 'segment' instead of each page.

- there is possibility in future to improve memory footprint
of bvecs usage. 

3) how is multipage bvec implemented in this patchset?

The 1st 22 patches cleanup on direct access to bvec table,
and comments on some special cases. With this approach,
most of cases are found as safe for multipage bvec,
only fs/buffer, pktcdvd, dm-io, MD and btrfs need to deal
with.

Given a little more work is involved to cleanup pktcdvd,
MD and btrfs, this patchset introduces QUEUE_FLAG_NO_MP for
them, and these components can still see/use singlepage bvec.
In the future, once the cleanup is done, the flag can be killed.

The 2nd part(23 ~ 60) implements multipage bvec in block:

- put all tricks into bvec/bio/rq iterators, and as far as
drivers and fs use these standard iterators, they are happy
with multipage bvec

- bio_for_each_segment_all() changes
this helper pass pointer of each bvec directly to user, and
it has to be changed. Two new helpers(bio_for_each_segment_all_rd()
and bio_for_each_segment_all_wt()) are introduced. 

- bio_clone() changes
At default bio_clone still clones one new bio in multipage bvec
way. Also single page version of bio_clone() is introduced
for some special cases, such as only single page bvec is used
for the new cloned bio(bio bounce, ...)

These patches can be found in the following git tree:

	https://github.com/ming1/linux/tree/mp-bvec-0.3-v4.9

Thanks Christoph for looking at the early version and providing
very good suggestions, such as: introduce bio_init_with_vec_table(),
remove another unnecessary helpers for cleanup and so on.

TODO:
	- cleanup direct access to bvec table for MD & btrfs


[1], http://marc.info/?l=linux-kernel&m=141680246629547&w=2
[2], http://lwn.net/Articles/700781/
[3], http://marc.info/?t=147735447100001&r=1&w=2
[4], http://marc.info/?l=linux-mm&m=147745525801433&w=2


Ming Lei (60):
  block: bio: introduce bio_init_with_vec_table()
  block drivers: convert to bio_init_with_vec_table()
  block: drbd: remove impossible failure handling
  block: floppy: use bio_add_page()
  target: avoid to access .bi_vcnt directly
  bcache: debug: avoid to access .bi_io_vec directly
  dm: crypt: use bio_add_page()
  dm: use bvec iterator helpers to implement .get_page and .next_page
  dm: dm.c: replace 'bio->bi_vcnt == 1' with !bio_multiple_segments
  fs: logfs: convert to bio_add_page() in sync_request()
  fs: logfs: use bio_add_page() in __bdev_writeseg()
  fs: logfs: use bio_add_page() in do_erase()
  fs: logfs: remove unnecesary check
  block: drbd: comment on direct access bvec table
  block: loop: comment on direct access to bvec table
  block: pktcdvd: comment on direct access to bvec table
  kernel/power/swap.c: comment on direct access to bvec table
  mm: page_io.c: comment on direct access to bvec table
  fs/buffer: comment on direct access to bvec table
  f2fs: f2fs_read_end_io: comment on direct access to bvec table
  bcache: comment on direct access to bvec table
  block: comment on bio_alloc_pages()
  block: introduce flag QUEUE_FLAG_NO_MP
  md: set NO_MP for request queue of md
  block: pktcdvd: set NO_MP for pktcdvd request queue
  btrfs: set NO_MP for request queues behind BTRFS
  block: introduce BIO_SP_MAX_SECTORS
  block: introduce QUEUE_FLAG_SPLIT_MP
  dm: limit the max bio size as BIO_SP_MAX_SECTORS << SECTOR_SHIFT
  bcache: set flag of QUEUE_FLAG_SPLIT_MP
  block: introduce multipage/single page bvec helpers
  block: implement sp version of bvec iterator helpers
  block: introduce bio_for_each_segment_mp()
  block: introduce bio_clone_sp()
  bvec_iter: introduce BVEC_ITER_ALL_INIT
  block: bounce: avoid direct access to bvec from bio->bi_io_vec
  block: bounce: don't access bio->bi_io_vec in copy_to_high_bio_irq
  block: bounce: convert multipage bvecs into singlepage
  bcache: debug: switch to bio_clone_sp()
  blk-merge: compute bio->bi_seg_front_size efficiently
  block: blk-merge: try to make front segments in full size
  block: use bio_for_each_segment_mp() to compute segments count
  block: use bio_for_each_segment_mp() to map sg
  block: introduce bvec_for_each_sp_bvec()
  block: bio: introduce bio_for_each_segment_all_rd() and its write pair
  block: deal with dirtying pages for multipage bvec
  block: convert to bio_for_each_segment_all_rd()
  fs/mpage: convert to bio_for_each_segment_all_rd()
  fs/direct-io: convert to bio_for_each_segment_all_rd()
  ext4: convert to bio_for_each_segment_all_rd()
  xfs: convert to bio_for_each_segment_all_rd()
  logfs: convert to bio_for_each_segment_all_rd()
  gfs2: convert to bio_for_each_segment_all_rd()
  f2fs: convert to bio_for_each_segment_all_rd()
  exofs: convert to bio_for_each_segment_all_rd()
  fs: crypto: convert to bio_for_each_segment_all_rd()
  bcache: convert to bio_for_each_segment_all_rd()
  dm-crypt: convert to bio_for_each_segment_all_rd()
  fs/buffer.c: use bvec iterator to truncate the bio
  block: enable multipage bvecs

 block/bio.c                        | 104 ++++++++++++++----
 block/blk-merge.c                  | 216 +++++++++++++++++++++++++++++--------
 block/bounce.c                     |  80 ++++++++++----
 drivers/block/drbd/drbd_bitmap.c   |   1 +
 drivers/block/drbd/drbd_receiver.c |  14 +--
 drivers/block/floppy.c             |  10 +-
 drivers/block/loop.c               |   5 +
 drivers/block/pktcdvd.c            |   8 ++
 drivers/md/bcache/btree.c          |   4 +-
 drivers/md/bcache/debug.c          |  19 +++-
 drivers/md/bcache/io.c             |   4 +-
 drivers/md/bcache/journal.c        |   4 +-
 drivers/md/bcache/movinggc.c       |   7 +-
 drivers/md/bcache/super.c          |  25 +++--
 drivers/md/bcache/util.c           |   7 ++
 drivers/md/bcache/writeback.c      |   6 +-
 drivers/md/dm-bufio.c              |   4 +-
 drivers/md/dm-crypt.c              |  11 +-
 drivers/md/dm-io.c                 |  34 ++++--
 drivers/md/dm-rq.c                 |   3 +-
 drivers/md/dm.c                    |  11 +-
 drivers/md/md.c                    |  12 +++
 drivers/md/raid5.c                 |   9 +-
 drivers/nvme/target/io-cmd.c       |   4 +-
 drivers/target/target_core_pscsi.c |   8 +-
 fs/btrfs/volumes.c                 |   3 +
 fs/buffer.c                        |  24 +++--
 fs/crypto/crypto.c                 |   3 +-
 fs/direct-io.c                     |   4 +-
 fs/exofs/ore.c                     |   3 +-
 fs/exofs/ore_raid.c                |   3 +-
 fs/ext4/page-io.c                  |   3 +-
 fs/ext4/readpage.c                 |   3 +-
 fs/f2fs/data.c                     |  13 ++-
 fs/gfs2/lops.c                     |   3 +-
 fs/gfs2/meta_io.c                  |   3 +-
 fs/logfs/dev_bdev.c                | 110 +++++++------------
 fs/mpage.c                         |   3 +-
 fs/xfs/xfs_aops.c                  |   3 +-
 include/linux/bio.h                | 108 +++++++++++++++++--
 include/linux/blk_types.h          |   6 ++
 include/linux/blkdev.h             |   4 +
 include/linux/bvec.h               | 123 +++++++++++++++++++--
 kernel/power/swap.c                |   2 +
 mm/page_io.c                       |   1 +
 45 files changed, 759 insertions(+), 276 deletions(-)

-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
