Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id EC13C6B3F63
	for <linux-mm@kvack.org>; Sun, 25 Nov 2018 21:17:45 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id z68so18195150qkb.14
        for <linux-mm@kvack.org>; Sun, 25 Nov 2018 18:17:45 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id s2si1450840qvm.19.2018.11.25.18.17.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 25 Nov 2018 18:17:44 -0800 (PST)
From: Ming Lei <ming.lei@redhat.com>
Subject: [PATCH V12 00/20] block: support multi-page bvec 
Date: Mon, 26 Nov 2018 10:17:00 +0800
Message-Id: <20181126021720.19471-1-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@kernel.dk>
Cc: linux-block@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, Omar Sandoval <osandov@fb.com>, Sagi Grimberg <sagi@grimberg.me>, Dave Chinner <dchinner@redhat.com>, Kent Overstreet <kent.overstreet@gmail.com>, Mike Snitzer <snitzer@redhat.com>, dm-devel@redhat.com, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Shaohua Li <shli@kernel.org>, linux-raid@vger.kernel.org, David Sterba <dsterba@suse.com>, linux-btrfs@vger.kernel.org, "Darrick J . Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org, Gao Xiang <gaoxiang25@huawei.com>, Christoph Hellwig <hch@lst.de>, linux-ext4@vger.kernel.org, Coly Li <colyli@suse.de>, linux-bcache@vger.kernel.org, Boaz Harrosh <ooo@electrozaur.com>, Bob Peterson <rpeterso@redhat.com>, cluster-devel@redhat.com, Ming Lei <ming.lei@redhat.com>

Hi,

This patchset brings multi-page bvec into block layer:

1) what is multi-page bvec?

Multipage bvecs means that one 'struct bio_bvec' can hold multiple pages
which are physically contiguous instead of one single page used in linux
kernel for long time.

2) why is multi-page bvec introduced?

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

With multi-page bvec:

- Inside block layer, both bio splitting and sg map can become more
efficient than before by just traversing the physically contiguous
'segment' instead of each page.

- segment handling in block layer can be improved much in future since it
should be quite easy to convert multipage bvec into segment easily. For
example, we might just store segment in each bvec directly in future.

- bio size can be increased and it should improve some high-bandwidth IO
case in theory[4].

- there is opportunity in future to improve memory footprint of bvecs. 

3) how is multi-page bvec implemented in this patchset?

Patch 1 ~ 6 parpares for supporting multi-page bvec. 

Patches 7 ~ 16 implement multipage bvec in block layer:

	- put all tricks into bvec/bio/rq iterators, and as far as
	drivers and fs use these standard iterators, they are happy
	with multipage bvec

	- introduce bio_for_each_bvec() to iterate over multipage bvec for splitting
	bio and mapping sg

	- keep current bio_for_each_segment*() to itereate over singlepage bvec and
	make sure current users won't be broken; especailly, convert to this
	new helper prototype in single patch 21 given it is bascially a mechanism
	conversion

	- deal with iomap & xfs's sub-pagesize io vec in patch 13

	- enalbe multipage bvec in patch 14 

Patch 17 redefines BIO_MAX_PAGES as 256.

Patch 18 documents usages of bio iterator helpers.

Patch 19~20 kills NO_SG_MERGE.

These patches can be found in the following git tree:

	git:  https://github.com/ming1/linux.git  for-4.21-block-mp-bvec-V12

Lots of test(blktest, xfstests, ltp io, ...) have been run with this patchset,
and not see regression.

Thanks Christoph for reviewing the early version and providing very good
suggestions, such as: introduce bio_init_with_vec_table(), remove another
unnecessary helpers for cleanup and so on.

Thanks Chritoph and Omar for reviewing V10/V11, and provides lots of helpful
comments.

V12:
	- deal with non-cluster by max segment size & segment boundary limit
	- rename bvec helper's name
	- revert new change on bvec_iter_advance() in V11
	- introduce rq_for_each_bvec()
	- use simpler check on enalbing multi-page bvec
	- fix Document change

V11:
	- address most of reviews from Omar and christoph
	- rename mp_bvec_* as segment_* helpers
	- remove 'mp' parameter from bvec_iter_advance() and related helpers
	- cleanup patch on bvec_split_segs() and blk_bio_segment_split(),
	  remove unnecessary checks
	- simplify bvec_last_segment()
	- drop bio_pages_all()
	- introduce dedicated functions/file for handling non-cluser bio for
	avoiding checking queue cluster before adding page to bio
	- introduce bio_try_merge_segment() for simplifying iomap/xfs page
	  accounting code
	- Fix Document change

V10:
	- no any code change, just add more guys and list into patch's CC list,
	as suggested by Christoph and Dave Chinner
V9:
	- fix regression on iomap's sub-pagesize io vec, covered by patch 13
V8:
	- remove prepare patches which all are merged to linus tree
	- rebase on for-4.21/block
	- address comments on V7
	- add patches of killing NO_SG_MERGE

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




Christoph Hellwig (3):
  btrfs: remove various bio_offset arguments
  btrfs: look at bi_size for repair decisions
  block: remove the "cluster" flag

Ming Lei (17):
  block: don't use bio->bi_vcnt to figure out segment number
  block: remove bvec_iter_rewind()
  block: rename bvec helpers
  block: introduce multi-page bvec helpers
  block: introduce bio_for_each_bvec() and rq_for_each_bvec()
  block: use bio_for_each_bvec() to compute multi-page bvec count
  block: use bio_for_each_bvec() to map sg
  block: introduce bvec_last_segment()
  fs/buffer.c: use bvec iterator to truncate the bio
  block: loop: pass multi-page bvec to iov_iter
  bcache: avoid to use bio_for_each_segment_all() in
    bch_bio_alloc_pages()
  block: allow bio_for_each_segment_all() to iterate over multi-page
    bvec
  block: enable multipage bvecs
  block: always define BIO_MAX_PAGES as 256
  block: document usage of bio iterator helpers
  block: kill QUEUE_FLAG_NO_SG_MERGE
  block: kill BLK_MQ_F_SG_MERGE

 .clang-format                     |   2 +-
 Documentation/block/biovecs.txt   |  25 +++++
 block/bio.c                       |  49 +++++---
 block/blk-merge.c                 | 227 ++++++++++++++++++++++++--------------
 block/blk-mq-debugfs.c            |   2 -
 block/blk-mq.c                    |   3 -
 block/blk-settings.c              |   3 -
 block/blk-sysfs.c                 |   5 +-
 block/bounce.c                    |   6 +-
 drivers/block/loop.c              |  22 ++--
 drivers/block/nbd.c               |   2 +-
 drivers/block/rbd.c               |   2 +-
 drivers/block/skd_main.c          |   1 -
 drivers/block/xen-blkfront.c      |   2 +-
 drivers/md/bcache/btree.c         |   3 +-
 drivers/md/bcache/util.c          |   6 +-
 drivers/md/dm-crypt.c             |   3 +-
 drivers/md/dm-integrity.c         |   2 +-
 drivers/md/dm-io.c                |   4 +-
 drivers/md/dm-rq.c                |   2 +-
 drivers/md/dm-table.c             |  13 ---
 drivers/md/raid1.c                |   3 +-
 drivers/mmc/core/queue.c          |   3 +-
 drivers/nvdimm/blk.c              |   4 +-
 drivers/nvdimm/btt.c              |   4 +-
 drivers/scsi/scsi_lib.c           |  22 +++-
 drivers/staging/erofs/data.c      |   3 +-
 drivers/staging/erofs/unzip_vle.c |   3 +-
 fs/block_dev.c                    |   6 +-
 fs/btrfs/compression.c            |   3 +-
 fs/btrfs/disk-io.c                |  24 ++--
 fs/btrfs/disk-io.h                |   2 +-
 fs/btrfs/extent_io.c              |  20 ++--
 fs/btrfs/extent_io.h              |   5 +-
 fs/btrfs/inode.c                  |  23 ++--
 fs/btrfs/raid56.c                 |   3 +-
 fs/buffer.c                       |   5 +-
 fs/crypto/bio.c                   |   3 +-
 fs/direct-io.c                    |   4 +-
 fs/exofs/ore.c                    |   3 +-
 fs/exofs/ore_raid.c               |   3 +-
 fs/ext4/page-io.c                 |   3 +-
 fs/ext4/readpage.c                |   3 +-
 fs/f2fs/data.c                    |   9 +-
 fs/gfs2/lops.c                    |   6 +-
 fs/gfs2/meta_io.c                 |   3 +-
 fs/iomap.c                        |  10 +-
 fs/mpage.c                        |   3 +-
 fs/xfs/xfs_aops.c                 |   9 +-
 include/linux/bio.h               |  47 ++++----
 include/linux/blk-mq.h            |   1 -
 include/linux/blkdev.h            |  11 +-
 include/linux/bvec.h              | 104 ++++++++++++-----
 include/linux/ceph/messenger.h    |   2 +-
 lib/iov_iter.c                    |   2 +-
 net/ceph/messenger.c              |  14 +--
 56 files changed, 460 insertions(+), 297 deletions(-)

-- 
2.9.5
