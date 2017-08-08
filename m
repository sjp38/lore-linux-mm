Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1A6EA6B025F
	for <linux-mm@kvack.org>; Tue,  8 Aug 2017 04:46:14 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id r194so13043060qke.3
        for <linux-mm@kvack.org>; Tue, 08 Aug 2017 01:46:14 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f68si758412qkj.390.2017.08.08.01.46.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Aug 2017 01:46:13 -0700 (PDT)
From: Ming Lei <ming.lei@redhat.com>
Subject: [PATCH v3 00/49] block: support multipage bvec
Date: Tue,  8 Aug 2017 16:44:59 +0800
Message-Id: <20170808084548.18963-1-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@fb.com>, Christoph Hellwig <hch@infradead.org>, Huang Ying <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>
Cc: linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Ming Lei <ming.lei@redhat.com>

Hi,

This patchset brings multipage bvec into block layer:

1) what is multipage bvec?

Multipage bvecs means that one 'struct bio_bvec' can hold
multiple pages which are physically contiguous instead
of one single page used in linux kernel for long time.

2) why is multipage bvec introduced?

Kent proposed the idea[1] first. 

As system's RAM becomes much bigger than before, and 
at the same time huge page, transparent huge page and
memory compaction are widely used, it is a bit easy now
to see physically contiguous pages from fs in I/O.
On the other hand, from block layer's view, it isn't
necessary to store intermediate pages into bvec, and
it is enough to just store the physicallly contiguous
'segment' in each io vector.

Also huge pages are being brought to filesystem and swap
[2][6], we can do IO on a hugepage each time[3], which
requires that one bio can transfer at least one huge page
one time. Turns out it isn't flexiable to change BIO_MAX_PAGES
simply[3][5]. Multipage bvec can fit in this case very well.

With multipage bvec:

- segment handling in block layer can be improved much
in future since it should be quite easy to convert
multipage bvec into segment easily. For example, we might 
just store segment in each bvec directly in future.

- bio size can be increased and it should improve some
high-bandwidth IO case in theory[4].

- Inside block layer, both bio splitting and sg map can
become more efficient than before by just traversing the
physically contiguous 'segment' instead of each page.

- there is opportunity in future to improve memory footprint
of bvecs. 

3) how is multipage bvec implemented in this patchset?

The 1st 17 patches comment on some special cases and deal with
some special cases of direct access to bvec table.

The 2nd part(18~29) implements multipage bvec in block layer:

	- put all tricks into bvec/bio/rq iterators, and as far as
	drivers and fs use these standard iterators, they are happy
	with multipage bvec

	- use multipage bvec to split bio and map sg

	- bio_for_each_segment_all() changes
	this helper pass pointer of each bvec directly to user, and
	it has to be changed. Two new helpers(bio_for_each_segment_all_sp()
	and bio_for_each_segment_all_mp()) are introduced. 

The 3rd part(32~47) convert current users of bio_for_each_segment_all()
to bio_for_each_segment_all_sp()/bio_for_each_segment_all_mp().

The last part(48~49) enables multipage bvec.

These patches can be found in the following git tree:

	https://github.com/ming1/linux/commits/v4.13-rc3-block-next-mp-bvec-V3

Thanks Christoph for looking at the early version and providing
very good suggestions, such as: introduce bio_init_with_vec_table(),
remove another unnecessary helpers for cleanup and so on.

Any comments are welcome!

BTW, I will be on a trip in the following week, so may not reply
in time.

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

Ming Lei (49):
  block: drbd: comment on direct access bvec table
  block: loop: comment on direct access to bvec table
  kernel/power/swap.c: comment on direct access to bvec table
  mm: page_io.c: comment on direct access to bvec table
  fs/buffer: comment on direct access to bvec table
  f2fs: f2fs_read_end_io: comment on direct access to bvec table
  bcache: comment on direct access to bvec table
  block: comment on bio_alloc_pages()
  block: comment on bio_iov_iter_get_pages()
  dm: limit the max bio size as BIO_MAX_PAGES * PAGE_SIZE
  btrfs: avoid access to .bi_vcnt directly
  btrfs: avoid to access bvec table directly for a cloned bio
  btrfs: comment on direct access bvec table
  block: bounce: avoid direct access to bvec table
  bvec_iter: introduce BVEC_ITER_ALL_INIT
  block: bounce: don't access bio->bi_io_vec in copy_to_high_bio_irq
  block: comments on bio_for_each_segment[_all]
  block: introduce multipage/single page bvec helpers
  block: implement sp version of bvec iterator helpers
  block: introduce bio_for_each_segment_mp()
  blk-merge: compute bio->bi_seg_front_size efficiently
  block: blk-merge: try to make front segments in full size
  block: blk-merge: remove unnecessary check
  block: use bio_for_each_segment_mp() to compute segments count
  block: use bio_for_each_segment_mp() to map sg
  block: introduce bvec_for_each_sp_bvec()
  block: bio: introduce single/multi page version of
    bio_for_each_segment_all()
  block: introduce bvec_get_last_page()
  fs/buffer.c: use bvec iterator to truncate the bio
  btrfs: use bvec_get_last_page to get bio's last page
  block: deal with dirtying pages for multipage bvec
  block: convert to singe/multi page version of
    bio_for_each_segment_all()
  bcache: convert to bio_for_each_segment_all_sp()
  md: raid1: convert to bio_for_each_segment_all_sp()
  dm-crypt: don't clear bvec->bv_page in crypt_free_buffer_pages()
  dm-crypt: convert to bio_for_each_segment_all_sp()
  fs/mpage: convert to bio_for_each_segment_all_sp()
  fs/block: convert to bio_for_each_segment_all_sp()
  fs/iomap: convert to bio_for_each_segment_all_sp()
  ext4: convert to bio_for_each_segment_all_sp()
  xfs: convert to bio_for_each_segment_all_sp()
  gfs2: convert to bio_for_each_segment_all_sp()
  f2fs: convert to bio_for_each_segment_all_sp()
  exofs: convert to bio_for_each_segment_all_sp()
  fs: crypto: convert to bio_for_each_segment_all_sp()
  fs/btrfs: convert to bio_for_each_segment_all_sp()
  fs/direct-io: convert to bio_for_each_segment_all_sp()
  block: enable multipage bvecs
  block: bio: pass segments to bio if bio_add_page() is bypassed

 block/bio.c                      | 137 ++++++++++++++++++++----
 block/blk-merge.c                | 226 +++++++++++++++++++++++++++++++--------
 block/blk-zoned.c                |   5 +-
 block/bounce.c                   |  39 ++++---
 drivers/block/drbd/drbd_bitmap.c |   1 +
 drivers/block/loop.c             |   5 +
 drivers/md/bcache/btree.c        |   4 +-
 drivers/md/bcache/super.c        |   6 ++
 drivers/md/bcache/util.c         |   7 ++
 drivers/md/dm-crypt.c            |   4 +-
 drivers/md/dm.c                  |  11 +-
 drivers/md/raid1.c               |   3 +-
 fs/block_dev.c                   |   6 +-
 fs/btrfs/compression.c           |  12 ++-
 fs/btrfs/disk-io.c               |   3 +-
 fs/btrfs/extent_io.c             |  38 +++++--
 fs/btrfs/extent_io.h             |   2 +-
 fs/btrfs/inode.c                 |  22 +++-
 fs/btrfs/raid56.c                |   1 +
 fs/buffer.c                      |  11 +-
 fs/crypto/bio.c                  |   3 +-
 fs/direct-io.c                   |   4 +-
 fs/exofs/ore.c                   |   3 +-
 fs/exofs/ore_raid.c              |   3 +-
 fs/ext4/page-io.c                |   3 +-
 fs/ext4/readpage.c               |   3 +-
 fs/f2fs/data.c                   |  13 ++-
 fs/gfs2/lops.c                   |   3 +-
 fs/gfs2/meta_io.c                |   3 +-
 fs/iomap.c                       |   3 +-
 fs/mpage.c                       |   3 +-
 fs/xfs/xfs_aops.c                |   3 +-
 include/linux/bio.h              |  67 +++++++++++-
 include/linux/blk_types.h        |   6 ++
 include/linux/bvec.h             | 141 ++++++++++++++++++++++--
 kernel/power/swap.c              |   2 +
 mm/page_io.c                     |   2 +
 37 files changed, 674 insertions(+), 134 deletions(-)

-- 
2.9.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
