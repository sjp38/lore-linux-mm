Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5CDC26B030B
	for <linux-mm@kvack.org>; Tue,  8 May 2018 21:34:15 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id b202so25175664qkc.6
        for <linux-mm@kvack.org>; Tue, 08 May 2018 18:34:15 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d13-v6sor12553948qta.84.2018.05.08.18.34.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 08 May 2018 18:34:14 -0700 (PDT)
From: Kent Overstreet <kent.overstreet@gmail.com>
Subject: [PATCH 00/10] Misc block layer patches for bcachefs
Date: Tue,  8 May 2018 21:33:48 -0400
Message-Id: <20180509013358.16399-1-kent.overstreet@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-mm@kvack.org, Jens Axboe <axboe@kernel.dk>, Ingo Molnar <mingo@kernel.org>
Cc: Kent Overstreet <kent.overstreet@gmail.com>

 - Add separately allowed mempools, biosets: bcachefs uses both all over the
   place

 - Bit of utility code - bio_copy_data_iter(), zero_fill_bio_iter()

 - bio_list_copy_data(), the bi_next check - defensiveness because of a bug I
   had fun chasing down at one point

 - add some exports, because bcachefs does dio its own way
 - show whether fua is supported in sysfs, because I don't know of anything that
   exports whether the _block layer_ specifically thinks fua is supported.

Kent Overstreet (10):
  mempool: Add mempool_init()/mempool_exit()
  block: Convert bio_set to mempool_init()
  block: Add bioset_init()/bioset_exit()
  block: Use bioset_init() for fs_bio_set
  block: Add bio_copy_data_iter(), zero_fill_bio_iter()
  block: Split out bio_list_copy_data()
  block: Add missing flush_dcache_page() call
  block: Add warning for bi_next not NULL in bio_endio()
  block: Export bio check/set pages_dirty
  block: Add sysfs entry for fua support

 block/bio-integrity.c               |  29 ++--
 block/bio.c                         | 226 ++++++++++++++++++----------
 block/blk-core.c                    |  10 +-
 block/blk-sysfs.c                   |  11 ++
 drivers/block/pktcdvd.c             |   2 +-
 drivers/target/target_core_iblock.c |   2 +-
 include/linux/bio.h                 |  35 +++--
 include/linux/mempool.h             |  34 +++++
 mm/mempool.c                        | 108 +++++++++----
 9 files changed, 320 insertions(+), 137 deletions(-)

-- 
2.17.0
