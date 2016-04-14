Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f71.google.com (mail-qg0-f71.google.com [209.85.192.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8250C6B0005
	for <linux-mm@kvack.org>; Thu, 14 Apr 2016 08:03:11 -0400 (EDT)
Received: by mail-qg0-f71.google.com with SMTP id j35so89627838qge.1
        for <linux-mm@kvack.org>; Thu, 14 Apr 2016 05:03:11 -0700 (PDT)
Received: from mail-oi0-x242.google.com (mail-oi0-x242.google.com. [2607:f8b0:4003:c06::242])
        by mx.google.com with ESMTPS id s30si13966875ota.85.2016.04.14.05.03.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Apr 2016 05:03:10 -0700 (PDT)
Received: by mail-oi0-x242.google.com with SMTP id q133so9553433oib.1
        for <linux-mm@kvack.org>; Thu, 14 Apr 2016 05:03:10 -0700 (PDT)
From: Ming Lei <tom.leiming@gmail.com>
Subject: [PATCH v1 00/27] block: cleanup direct access to .bi_vcnt & .bi_io_vec
Date: Thu, 14 Apr 2016 20:02:18 +0800
Message-Id: <1460635375-28282-1-git-send-email-tom.leiming@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@fb.com>, linux-kernel@vger.kernel.org
Cc: linux-block@vger.kernel.org, Christoph Hellwig <hch@infradead.org>, Ming Lei <tom.leiming@gmail.com>, Al Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <andreas.dilger@intel.com>, Andrew Morton <akpm@linux-foundation.org>, "open list:STAGING SUBSYSTEM" <devel@driverdev.osuosl.org>, "open list:DEVICE-MAPPER  LVM" <dm-devel@redhat.com>, "open list:DRBD DRIVER" <drbd-dev@lists.linbit.com>, Frank Zago <fzago@cray.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Hannes Reinecke <hare@suse.de>, James Simmons <jsimmons@infradead.org>, Jan Kara <jack@suse.cz>, Jarod Wilson <jarod@redhat.com>, Jiri Kosina <jkosina@suse.cz>, Joe Perches <joe@perches.com>, "John L. Hammond" <john.hammond@intel.com>, Julia Lawall <Julia.Lawall@lip6.fr>, Keith Busch <keith.busch@intel.com>, Kent Overstreet <kent.overstreet@gmail.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, "open list:BCACHE BLOCK LAYER CACHE" <linux-bcache@vger.kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, "open list:HIBERNATION aka Software Suspend, aka swsusp" <linux-pm@vger.kernel.org>, "open list:SOFTWARE RAID Multiple Disks SUPPORT" <linux-raid@vger.kernel.org>, "open list:TARGET SUBSYSTEM" <linux-scsi@vger.kernel.org>, "open list:LogFS" <logfs@logfs.org>, "moderated list:STAGING - LUSTRE PARALLEL FILESYSTEM" <lustre-devel@lists.lustre.org>, Mike Rapoport <mike.rapoport@gmail.com>, Mike Snitzer <snitzer@redhat.com>, Miklos Szeredi <mszeredi@suse.cz>, Minchan Kim <minchan@kernel.org>, NeilBrown <neilb@suse.com>, NeilBrown <neilb@suse.de>, Oleg Drokin <green@linuxhacker.ru>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Rasmus Villemoes <linux@rasmusvillemoes.dk>, Swee Hua Law <sweehua81@gmail.com>, "open list:TARGET SUBSYSTEM" <target-devel@vger.kernel.org>, Tejun Heo <tj@kernel.org>

Hi Guys,

It is always not a good practice to access bio->bi_vcnt and
bio->bi_io_vec from drivers directly. Also this kind of direct
access will cause trouble when converting to multipage bvecs
because currently drivers may suppose one bvec always include
one page, and use the two fields to figure out how to handle
pages.

Even the actual meaning of the two fields arn't change from
block subsystem's view, but it may change from driver or fs's
view, so this patchset takes a conservative approach to cleanup
direct access to the two fields for avoiding regressions.

The 1st patch introduces the following 3 bio helpers which can be
used inside drivers for avoiding direct access to .bi_vcnt and .bi_io_vec.

        bio_pages()
        bio_get_base_vec()
        bio_set_vec_table()

bio_pages() can be easy to convert to multipage bvecs.

For bio_get_base_vec() and bio_set_vec_table(), they are often used
during initializing a new bio or in case of single bvec bio. With the
two new helpers, it becomes quite easy to audit access to .bi_io_vec
and .bi_vcnt.

Most of the other patches use the 3 helpers to clean up most of direct
access to .bi_vcnt and .bi_io_vec from drivers, except for MD and btrfs,
which two subsystems will be handled with different way in future.

For btrfs, its direct access to .bi_vcnt & .bi_io_vec need to be cleanuped
and audited that there isn't issue once converting to multipage bvecs.

For raid(md), given its usage is quite complicated, we can just
not enable multipage bvecs for raid queue until all its usage
are cleaned up and audited. So it won't be a blocker for multipage
bvecs.

Also bio_add_page() is used in floppy, dm-crypt and fs/logfs to
avoiding direct access to .bi_vcnt & .bi_io_vec.

The patchset can be found in the following tree:

https://github.com/ming1/linux/tree/v4.6-rc-block-next-mpbvecs-cleanup.v1

V1:
	- add Reviewed-by
	- remove bio_is_full() helper because target can find it
	via the return value of bio_add_pc_page() (9/27)
	- add comment on another two uses of bio_get_base_vec() (16/27)
	- rebased on latest for-next branch of block tree

Ming Lei (27):
  block: bio: introduce 3 helpers for cleanup
  block: drbd: use bio_get_base_vec() to retrieve the 1st bvec
  block: drbd: remove impossible failure handling
  block: loop: use bio_get_base_vec() to retrive bvec table
  block: pktcdvd: use bio_get_base_vec() to retrive bvec table
  block: floppy: use bio_set_vec_table()
  block: floppy: use bio_add_page()
  staging: lustre: avoid to use bio->bi_vcnt directly
  target: avoid to access .bi_vcnt directly
  bcache: debug: avoid to access .bi_io_vec directly
  bcache: io.c: use bio_set_vec_table
  bcache: journal.c: use bio_set_vec_table()
  bcache: movinggc: use bio_set_vec_table()
  bcache: writeback: use bio_set_vec_table()
  bcache: super: use bio_set_vec_table()
  bcache: super: use bio_get_base_vec
  dm: crypt: use bio_add_page()
  dm: dm-io.c: use bio_get_base_vec()
  dm: dm.c: replace 'bio->bi_vcnt == 1' with !bio_multiple_segments
  dm: dm-bufio.c: use bio_set_vec_table()
  fs: logfs: use bio_set_vec_table()
  fs: logfs: convert to bio_add_page() in sync_request()
  fs: logfs: use bio_add_page() in __bdev_writeseg()
  fs: logfs: use bio_add_page() in do_erase()
  fs: logfs: remove unnecesary check
  kernel/power/swap.c: use bio_get_base_vec()
  mm: page_io.c: use bio_get_base_vec()

 drivers/block/drbd/drbd_bitmap.c            |   4 +-
 drivers/block/drbd/drbd_receiver.c          |  14 +---
 drivers/block/floppy.c                      |   9 +--
 drivers/block/loop.c                        |   5 +-
 drivers/block/pktcdvd.c                     |   3 +-
 drivers/md/bcache/debug.c                   |  11 ++-
 drivers/md/bcache/io.c                      |   3 +-
 drivers/md/bcache/journal.c                 |   3 +-
 drivers/md/bcache/movinggc.c                |   6 +-
 drivers/md/bcache/super.c                   |  33 ++++++---
 drivers/md/bcache/writeback.c               |   4 +-
 drivers/md/dm-bufio.c                       |   3 +-
 drivers/md/dm-crypt.c                       |   8 +--
 drivers/md/dm-io.c                          |   7 +-
 drivers/md/dm.c                             |   3 +-
 drivers/staging/lustre/lustre/llite/lloop.c |   9 +--
 drivers/target/target_core_pscsi.c          |   8 +--
 fs/logfs/dev_bdev.c                         | 107 +++++++++++-----------------
 include/linux/bio.h                         |  21 ++++++
 kernel/power/swap.c                         |  10 ++-
 mm/page_io.c                                |  18 ++++-
 21 files changed, 155 insertions(+), 134 deletions(-)

Thanks,
Ming
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
