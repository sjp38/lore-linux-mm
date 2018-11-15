Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id EDB786B026B
	for <linux-mm@kvack.org>; Thu, 15 Nov 2018 03:53:36 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id s19so43885211qke.20
        for <linux-mm@kvack.org>; Thu, 15 Nov 2018 00:53:36 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 51si971565qvt.60.2018.11.15.00.53.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Nov 2018 00:53:35 -0800 (PST)
From: Ming Lei <ming.lei@redhat.com>
Subject: [PATCH V10 00/19] block: support multi-page bvec
Date: Thu, 15 Nov 2018 16:52:47 +0800
Message-Id: <20181115085306.9910-1-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@kernel.dk>
Cc: linux-block@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ming Lei <ming.lei@redhat.com>, Dave Chinner <dchinner@redhat.com>, Kent Overstreet <kent.overstreet@gmail.com>, Mike Snitzer <snitzer@redhat.com>, dm-devel@redhat.com, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Shaohua Li <shli@kernel.org>, linux-raid@vger.kernel.org, linux-erofs@lists.ozlabs.org, David Sterba <dsterba@suse.com>, linux-btrfs@vger.kernel.org, "Darrick J . Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org, Gao Xiang <gaoxiang25@huawei.com>, Christoph Hellwig <hch@lst.de>, Theodore Ts'o <tytso@mit.edu>, linux-ext4@vger.kernel.org, Coly Li <colyli@suse.de>, linux-bcache@vger.kernel.org, Boaz Harrosh <ooo@electrozaur.com>, Bob Peterson <rpeterso@redhat.com>, cluster-devel@redhat.com

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

The patches of 1 ~ 14 implement multipage bvec in block layer:

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

Patch 15 redefines BIO_MAX_PAGES as 256.

Patch 16 documents usages of bio iterator helpers.

Patch 17~19 kills NO_SG_MERGE.

These patches can be found in the following git tree:

	git:  https://github.com/ming1/linux.git  for-4.21-block-mp-bvec-V10

Lots of test(blktest, xfstests, ltp io, ...) have been run with this patchset,
and not see regression.

Thanks Christoph for reviewing the early version and providing very good
suggestions, such as: introduce bio_init_with_vec_table(), remove another
unnecessary helpers for cleanup and so on.

Any comments are welcome!

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


Ming Lei (19):
  block: introduce multi-page page bvec helpers
  block: introduce bio_for_each_bvec()
  block: use bio_for_each_bvec() to compute multi-page bvec count
  block: use bio_for_each_bvec() to map sg
  block: introduce bvec_last_segment()
  fs/buffer.c: use bvec iterator to truncate the bio
  btrfs: use bvec_last_segment to get bio's last page
  btrfs: move bio_pages_all() to btrfs
  block: introduce bio_bvecs()
  block: loop: pass multi-page bvec to iov_iter
  bcache: avoid to use bio_for_each_segment_all() in
    bch_bio_alloc_pages()
  block: allow bio_for_each_segment_all() to iterate over multi-page
    bvec
  iomap & xfs: only account for new added page
  block: enable multipage bvecs
  block: always define BIO_MAX_PAGES as 256
  block: document usage of bio iterator helpers
  block: don't use bio->bi_vcnt to figure out segment number
  block: kill QUEUE_FLAG_NO_SG_MERGE
  block: kill BLK_MQ_F_SG_MERGE

 Documentation/block/biovecs.txt   |  26 +++++
 block/bio.c                       |  51 +++++++---
 block/blk-merge.c                 | 199 +++++++++++++++++++++++++-------------
 block/blk-mq-debugfs.c            |   2 -
 block/blk-mq.c                    |   3 -
 block/blk-zoned.c                 |   1 +
 block/bounce.c                    |   6 +-
 drivers/block/loop.c              |  25 ++---
 drivers/block/nbd.c               |   2 +-
 drivers/block/rbd.c               |   2 +-
 drivers/block/skd_main.c          |   1 -
 drivers/block/xen-blkfront.c      |   2 +-
 drivers/md/bcache/btree.c         |   3 +-
 drivers/md/bcache/util.c          |   2 +-
 drivers/md/dm-crypt.c             |   3 +-
 drivers/md/dm-rq.c                |   2 +-
 drivers/md/dm-table.c             |  13 ---
 drivers/md/raid1.c                |   3 +-
 drivers/mmc/core/queue.c          |   3 +-
 drivers/scsi/scsi_lib.c           |   2 +-
 drivers/staging/erofs/data.c      |   3 +-
 drivers/staging/erofs/unzip_vle.c |   3 +-
 fs/block_dev.c                    |   6 +-
 fs/btrfs/compression.c            |   8 +-
 fs/btrfs/disk-io.c                |   3 +-
 fs/btrfs/extent_io.c              |  29 ++++--
 fs/btrfs/inode.c                  |   6 +-
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
 fs/iomap.c                        |  28 ++++--
 fs/mpage.c                        |   3 +-
 fs/xfs/xfs_aops.c                 |  15 ++-
 include/linux/bio.h               |  94 ++++++++++++++----
 include/linux/blk-mq.h            |   1 -
 include/linux/blkdev.h            |   1 -
 include/linux/bvec.h              | 155 +++++++++++++++++++++++++++--
 45 files changed, 556 insertions(+), 195 deletions(-)

Cc: Dave Chinner <dchinner@redhat.com>
Cc: Kent Overstreet <kent.overstreet@gmail.com>
Cc: Mike Snitzer <snitzer@redhat.com>
Cc: dm-devel@redhat.com
Cc: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: linux-fsdevel@vger.kernel.org
Cc: Shaohua Li <shli@kernel.org>
Cc: linux-raid@vger.kernel.org
Cc: linux-erofs@lists.ozlabs.org
Cc: David Sterba <dsterba@suse.com>
Cc: linux-btrfs@vger.kernel.org
Cc: Darrick J. Wong <darrick.wong@oracle.com>
Cc: linux-xfs@vger.kernel.org
Cc: Gao Xiang <gaoxiang25@huawei.com>
Cc: Christoph Hellwig <hch@lst.de>
Cc: Theodore Ts'o <tytso@mit.edu>
Cc: linux-ext4@vger.kernel.org
Cc: Coly Li <colyli@suse.de>
Cc: linux-bcache@vger.kernel.org
Cc: Boaz Harrosh <ooo@electrozaur.com>
Cc: Bob Peterson <rpeterso@redhat.com>
Cc: cluster-devel@redhat.com


-- 
2.9.5
