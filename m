Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id EF5A86B0266
	for <linux-mm@kvack.org>; Mon, 18 Dec 2017 07:23:08 -0500 (EST)
Received: by mail-oi0-f70.google.com with SMTP id f13so7031766oib.20
        for <linux-mm@kvack.org>; Mon, 18 Dec 2017 04:23:08 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t1si3928694oth.555.2017.12.18.04.23.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Dec 2017 04:23:07 -0800 (PST)
From: Ming Lei <ming.lei@redhat.com>
Subject: [PATCH V4 00/45] block: support multipage bvec
Date: Mon, 18 Dec 2017 20:22:02 +0800
Message-Id: <20171218122247.3488-1-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@fb.com>, Christoph Hellwig <hch@infradead.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Kent Overstreet <kent.overstreet@gmail.com>
Cc: Huang Ying <ying.huang@intel.com>, linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, "Darrick J . Wong" <darrick.wong@oracle.com>, Coly Li <colyli@suse.de>, Filipe Manana <fdmanana@gmail.com>, Ming Lei <ming.lei@redhat.com>

Hi,

This patchset brings multipage bvec into block layer:

1) what is multipage bvec?

Multipage bvecs means that one 'struct bio_bvec' can hold multiple pages
which are physically contiguous instead of one single page used in linux
kernel for long time.

2) why is multipage bvec introduced?

Kent proposed the idea[1] first. 

As system's RAM becomes much bigger than before, and huge page, transparent
huge page and memory compaction are widely used, it is a bit easy now
to see physically contiguous pages from fs in I/O. On the other hand, from
block layer's view, it isn't necessary to store intermediate pages into bvec,
and it is enough to just store the physicallly contiguous 'segment' in each
io vector.

Also huge pages are being brought to filesystem and swap [2][6], we can
do IO on a hugepage each time[3], which requires that one bio can transfer
at least one huge page one time. Turns out it isn't flexiable to change
BIO_MAX_PAGES simply[3][5]. Multipage bvec can fit in this case very well.
As we saw, if CONFIG_THP_SWAP is enabled, BIO_MAX_PAGES can be configured
as much bigger, such as 512, which requires at least two 4K pages for holding
the bvec table.

With multipage bvec:

- Inside block layer, both bio splitting and sg map can become more
efficient than before by just traversing the physically contiguous
'segment' instead of each page.

- segment handling in block layer can be improved much in future since it
should be quite easy to convert multipage bvec into segment easily. For
example, we might just store segment in each bvec directly in future.

- bio size can be increased and it should improve some high-bandwidth IO
case in theory[4].

- there is opportunity in future to improve memory footprint of bvecs. 

3) how is multipage bvec implemented in this patchset?

The 1st 17 patches are prepare patches for multipage bvec, and one big
change is to rename bio_for_each_segment*() as bio_for_each_page*().

The patches of 18~43 implement multipage bvec in block layer:

	- put all tricks into bvec/bio/rq iterators, and as far as
	drivers and fs use these standard iterators, they are happy
	with multipage bvec

	- use multipage bvec to split bio and map sg

	- introduce bio_for_each_segment*() for iterating bio segment by
	  segment

	- make current bio_for_each_page*() to itereate page by page and
	make sure current uses won't be broken

The patch 44 redefines BIO_MAX_PAGES as 256.

The patch 45 documents usages of bio iterator helpers.

These patches can be found in the following git tree:

	gitweb: https://github.com/ming1/linux/commits/v4.15-rc-mp-bvec_v4
	git:  https://github.com/ming1/linux.git  #v4.15-rc-mp-bvec_v4

xfstest(-g auto) has been run on nvme/sata and no regression is observed.

Thanks Christoph for reviewing the early version and providing very good
suggestions, such as: introduce bio_init_with_vec_table(), remove another
unnecessary helpers for cleanup and so on.

Any comments are welcome!

V4:
	- rename bio_for_each_segment*() as bio_for_each_page*(), rename
	bio_segments() as bio_pages(), rename rq_for_each_segment() as
	rq_for_each_pages(), because these helpers never return real
	segment, and they always return single page bvec
	
	- introducing segment_for_each_page_all()

	- introduce new bio_for_each_segment*()/rq_for_each_segment()/bio_segments()
	for returning real multipage segment

	- rewrite segment_last_page()

	- rename bvec iterator helper as suggested by Christoph

	- replace comment with applying bio helpers as suggested by Christoph

	- document usage of bio iterator helpers

	- redefine BIO_MAX_PAGES as 256 to make the biggest bvec table
	accommodated in 4K page

	- move bio_alloc_pages() into bcache as suggested by Christoph

V3:
	- rebase on v4.13-rc3 with for-next of block tree
	- run more xfstests: xfs/ext4 over NVMe, Sata, DM(linear),
	MD(raid1), and not see regressions triggered
	- add Reviewed-by on some btrfs patches
	- remove two MD patches because both are merged to linus tree
	  already

V2:
	- bvec table direct access in raid has been cleaned, so NO_MP
	flag is dropped
	- rebase on recent Neil Brown's change on bio and bounce code
	- reorganize the patchset

V1:
	- against v4.10-rc1 and some cleanup in V0 are in -linus already
	- handle queue_virt_boundary() in mp bvec change and make NVMe happy
	- further BTRFS cleanup
	- remove QUEUE_FLAG_SPLIT_MP
	- rename for two new helpers of bio_for_each_segment_all()
	- fix bounce convertion
	- address comments in V0

[1], http://marc.info/?l=linux-kernel&m=141680246629547&w=2
[2], https://patchwork.kernel.org/patch/9451523/
[3], http://marc.info/?t=147735447100001&r=1&w=2
[4], http://marc.info/?l=linux-mm&m=147745525801433&w=2
[5], http://marc.info/?t=149569484500007&r=1&w=2
[6], http://marc.info/?t=149820215300004&r=1&w=2

Ming Lei (45):
  block: introduce bio helpers for converting to multipage bvec
  block: conver to bio_first_bvec_all & bio_first_page_all
  fs: convert to bio_last_bvec_all()
  block: bounce: avoid direct access to bvec table
  block: bounce: don't access bio->bi_io_vec in copy_to_high_bio_irq
  dm: limit the max bio size as BIO_MAX_PAGES * PAGE_SIZE
  bcache: comment on direct access to bvec table
  block: move bio_alloc_pages() to bcache
  btrfs: avoid access to .bi_vcnt directly
  btrfs: avoid to access bvec table directly for a cloned bio
  dm-crypt: don't clear bvec->bv_page in crypt_free_buffer_pages()
  blk-merge: compute bio->bi_seg_front_size efficiently
  block: blk-merge: try to make front segments in full size
  block: blk-merge: remove unnecessary check
  block: rename bio_for_each_segment* with bio_for_each_page*
  block: rename rq_for_each_segment as rq_for_each_page
  block: rename bio_segments() with bio_pages()
  block: introduce multipage page bvec helpers
  block: introduce bio_for_each_segment()
  block: use bio_for_each_segment() to compute segments count
  block: use bio_for_each_segment() to map sg
  block: introduce segment_last_page()
  fs/buffer.c: use bvec iterator to truncate the bio
  btrfs: use segment_last_page to get bio's last page
  block: implement bio_pages_all() via bio_for_each_page_all()
  block: introduce bio_segments()
  block: introduce rq_for_each_segment()
  block: loop: pass segments to iov_iter
  block: bio: introduce bio_for_each_page_all2 and
    bio_for_each_segment_all
  block: deal with dirtying pages for multipage bvec
  block: convert to bio_for_each_page_all2()
  md/dm/bcache: conver to bio_for_each_page_all2 and
    bio_for_each_segment
  fs: conver to bio_for_each_page_all2
  btrfs: conver to bio_for_each_page_all2
  ext4: conver to bio_for_each_page_all2
  f2fs: conver to bio_for_each_page_all2
  xfs: conver to bio_for_each_page_all2
  exofs: conver to bio_for_each_page_all2
  gfs2: conver to bio_for_each_page_all2
  block: kill bio_for_each_page_all()
  block: rename bio_for_each_page_all2 as bio_for_each_page_all
  block: enable multipage bvecs
  block: bio: pass segments to bio if bio_add_page() is bypassed
  block: always define BIO_MAX_PAGES as 256
  block: document usage of bio iterator helpers

 Documentation/block/biodoc.txt      |   6 +-
 Documentation/block/biovecs.txt     |  36 +++++-
 arch/m68k/emu/nfblock.c             |   2 +-
 arch/powerpc/sysdev/axonram.c       |   2 +-
 arch/xtensa/platforms/iss/simdisk.c |   2 +-
 block/bio-integrity.c               |   2 +-
 block/bio.c                         | 162 ++++++++++++++++++--------
 block/blk-core.c                    |   2 +-
 block/blk-merge.c                   | 222 +++++++++++++++++++++++++++++-------
 block/blk-zoned.c                   |   5 +-
 block/bounce.c                      |  43 ++++---
 drivers/block/aoe/aoecmd.c          |   4 +-
 drivers/block/brd.c                 |   2 +-
 drivers/block/drbd/drbd_bitmap.c    |   2 +-
 drivers/block/drbd/drbd_main.c      |   4 +-
 drivers/block/drbd/drbd_receiver.c  |   2 +-
 drivers/block/drbd/drbd_worker.c    |   2 +-
 drivers/block/floppy.c              |   4 +-
 drivers/block/loop.c                |  10 +-
 drivers/block/nbd.c                 |   4 +-
 drivers/block/null_blk.c            |   4 +-
 drivers/block/ps3disk.c             |   4 +-
 drivers/block/ps3vram.c             |   2 +-
 drivers/block/rbd.c                 |   2 +-
 drivers/block/rsxx/dma.c            |   2 +-
 drivers/block/zram/zram_drv.c       |   4 +-
 drivers/md/bcache/btree.c           |   6 +-
 drivers/md/bcache/debug.c           |   4 +-
 drivers/md/bcache/movinggc.c        |   2 +-
 drivers/md/bcache/request.c         |   4 +-
 drivers/md/bcache/super.c           |   8 +-
 drivers/md/bcache/util.c            |  34 ++++++
 drivers/md/bcache/util.h            |   1 +
 drivers/md/bcache/writeback.c       |   2 +-
 drivers/md/dm-crypt.c               |   4 +-
 drivers/md/dm-integrity.c           |   4 +-
 drivers/md/dm-log-writes.c          |   4 +-
 drivers/md/dm.c                     |  12 +-
 drivers/md/raid1.c                  |   3 +-
 drivers/md/raid5.c                  |   2 +-
 drivers/nvdimm/blk.c                |   2 +-
 drivers/nvdimm/btt.c                |   2 +-
 drivers/nvdimm/pmem.c               |   2 +-
 drivers/s390/block/dasd_diag.c      |   4 +-
 drivers/s390/block/dasd_eckd.c      |  16 +--
 drivers/s390/block/dasd_fba.c       |   6 +-
 drivers/s390/block/dcssblk.c        |   2 +-
 drivers/s390/block/scm_blk.c        |   2 +-
 drivers/s390/block/xpram.c          |   2 +-
 drivers/target/target_core_pscsi.c  |   2 +-
 fs/block_dev.c                      |   6 +-
 fs/btrfs/check-integrity.c          |   6 +-
 fs/btrfs/compression.c              |  12 +-
 fs/btrfs/disk-io.c                  |   3 +-
 fs/btrfs/extent_io.c                |  25 ++--
 fs/btrfs/extent_io.h                |   2 +-
 fs/btrfs/file-item.c                |   4 +-
 fs/btrfs/inode.c                    |  20 ++--
 fs/btrfs/raid56.c                   |   4 +-
 fs/buffer.c                         |   7 +-
 fs/crypto/bio.c                     |   3 +-
 fs/direct-io.c                      |   4 +-
 fs/exofs/ore.c                      |   3 +-
 fs/exofs/ore_raid.c                 |   3 +-
 fs/ext4/page-io.c                   |   3 +-
 fs/ext4/readpage.c                  |   3 +-
 fs/f2fs/data.c                      |  11 +-
 fs/gfs2/lops.c                      |   6 +-
 fs/gfs2/meta_io.c                   |   3 +-
 fs/iomap.c                          |   3 +-
 fs/mpage.c                          |   3 +-
 fs/xfs/xfs_aops.c                   |   5 +-
 include/linux/bio.h                 | 119 ++++++++++++++++---
 include/linux/blkdev.h              |   6 +-
 include/linux/bvec.h                | 143 +++++++++++++++++++++--
 kernel/power/swap.c                 |   2 +-
 mm/page_io.c                        |   4 +-
 77 files changed, 806 insertions(+), 273 deletions(-)

-- 
2.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
