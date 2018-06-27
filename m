Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 225796B000D
	for <linux-mm@kvack.org>; Wed, 27 Jun 2018 08:46:04 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id i127-v6so1844718qkc.22
        for <linux-mm@kvack.org>; Wed, 27 Jun 2018 05:46:04 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id j15-v6si2928861qvi.120.2018.06.27.05.46.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Jun 2018 05:46:02 -0700 (PDT)
From: Ming Lei <ming.lei@redhat.com>
Subject: [PATCH V7 00/24] block: support multipage bvec
Date: Wed, 27 Jun 2018 20:45:24 +0800
Message-Id: <20180627124548.3456-1-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@fb.com>, Christoph Hellwig <hch@infradead.org>, Kent Overstreet <kent.overstreet@gmail.com>
Cc: David Sterba <dsterba@suse.cz>, Huang Ying <ying.huang@intel.com>, Mike Snitzer <snitzer@redhat.com>, linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, "Darrick J . Wong" <darrick.wong@oracle.com>, Coly Li <colyli@suse.de>, Filipe Manana <fdmanana@gmail.com>, Randy Dunlap <rdunlap@infradead.org>, Ming Lei <ming.lei@redhat.com>

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

The 1st 9 patches are prepare patches for multipage bvec, from Christoph
and Mike.

The patches of 10 ~ 22 implement multipage bvec in block layer:

	- put all tricks into bvec/bio/rq iterators, and as far as
	drivers and fs use these standard iterators, they are happy
	with multipage bvec

	- introduce bio_for_each_bvec() to iterate over multipage bvec for splitting
	bio and mapping sg

	- keep current bio_for_each_segment*() to itereate over singlepage bvec and
	make sure current users won't be broken; especailly, convert to this
	new helper prototype in single patch 21 given it is bascially a mechanism
	conversion

	- enalbe multipage bvec in patch 22

The patch 23 redefines BIO_MAX_PAGES as 256.

The patch 24 documents usages of bio iterator helpers.

These patches can be found in the following git tree:

	gitweb: https://github.com/ming1/linux/commits/v4.18-rc-mp-bvec-V7
	git:  https://github.com/ming1/linux.git  #v4.18-rc-mp-bvec-V7

Lots of test(blktest, xfstests, ltp io, ...) have been run with this patchset,
and not see regression.

Thanks Christoph for reviewing the early version and providing very good
suggestions, such as: introduce bio_init_with_vec_table(), remove another
unnecessary helpers for cleanup and so on.

Any comments are welcome!

V7:
	- include Christoph and Mike's bio_clone_bioset() patches, which is
	  actually prepare patches for multipage bvec
	- address Christoph's comments

V6:
	- avoid to introduce lots of renaming, follow Jen's suggestion of
	using the name of chunk for multipage io vector
	- include Christoph's three prepare patches
	- decrease stack usage for using bio_for_each_chunk_segment_all()
	- address Kent's comment

V5:
	- remove some of prepare patches, which have been merged already
	- add bio_clone_seg_bioset() to fix DM's bio clone, which
	is introduced by 18a25da84354c6b (dm: ensure bio submission follows
	a depth-first tree walk)
	- rebase on the latest block for-v4.18

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


Christoph Hellwig (8):
  bcache: don't clone bio in bch_data_verify
  exofs: use bio_clone_fast in _write_mirror
  block: remove bio_clone_kmalloc
  md: remove a bogus comment
  block: unexport bio_clone_bioset
  block: simplify bio_check_pages_dirty
  block: bio_set_pages_dirty can't see NULL bv_page in a valid bio_vec
  block: use bio_add_page in bio_iov_iter_get_pages

Mike Snitzer (1):
  dm: use bio_split() when splitting out the already processed bio

Ming Lei (15):
  block: introduce multipage page bvec helpers
  block: introduce bio_for_each_bvec()
  block: use bio_for_each_bvec() to compute multipage bvec count
  block: use bio_for_each_bvec() to map sg
  block: introduce bvec_last_segment()
  fs/buffer.c: use bvec iterator to truncate the bio
  btrfs: use bvec_last_segment to get bio's last page
  btrfs: move bio_pages_all() to btrfs
  block: introduce bio_bvecs()
  block: loop: pass multipage bvec to iov_iter
  bcache: avoid to use bio_for_each_segment_all() in
    bch_bio_alloc_pages()
  block: allow bio_for_each_segment_all() to iterate over multipage bvec
  block: enable multipage bvecs
  block: always define BIO_MAX_PAGES as 256
  block: document usage of bio iterator helpers

 Documentation/block/biovecs.txt |  27 +++++
 block/bio.c                     | 232 ++++++++++++++--------------------------
 block/blk-merge.c               | 162 ++++++++++++++++++++++------
 block/blk-zoned.c               |   5 +-
 block/bounce.c                  |  75 ++++++++++++-
 drivers/block/loop.c            |  24 ++---
 drivers/md/bcache/btree.c       |   3 +-
 drivers/md/bcache/debug.c       |   6 +-
 drivers/md/bcache/util.c        |   2 +-
 drivers/md/dm-crypt.c           |   3 +-
 drivers/md/dm.c                 |   5 +-
 drivers/md/md.c                 |   4 -
 drivers/md/raid1.c              |   3 +-
 fs/block_dev.c                  |   6 +-
 fs/btrfs/compression.c          |   8 +-
 fs/btrfs/disk-io.c              |   3 +-
 fs/btrfs/extent_io.c            |  29 +++--
 fs/btrfs/inode.c                |   6 +-
 fs/btrfs/raid56.c               |   3 +-
 fs/buffer.c                     |   5 +-
 fs/crypto/bio.c                 |   3 +-
 fs/direct-io.c                  |   4 +-
 fs/exofs/ore.c                  |   7 +-
 fs/exofs/ore_raid.c             |   3 +-
 fs/ext4/page-io.c               |   3 +-
 fs/ext4/readpage.c              |   3 +-
 fs/f2fs/data.c                  |   9 +-
 fs/gfs2/lops.c                  |   6 +-
 fs/gfs2/meta_io.c               |   3 +-
 fs/iomap.c                      |   3 +-
 fs/mpage.c                      |   3 +-
 fs/xfs/xfs_aops.c               |   5 +-
 include/linux/bio.h             |  90 +++++++++++-----
 include/linux/bvec.h            | 155 +++++++++++++++++++++++++--
 34 files changed, 626 insertions(+), 282 deletions(-)

-- 
2.9.5
