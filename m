Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id AE3656B0278
	for <linux-mm@kvack.org>; Wed, 30 May 2018 06:00:21 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id e7-v6so10583759pfi.8
        for <linux-mm@kvack.org>; Wed, 30 May 2018 03:00:21 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id z30-v6si33754878pfg.266.2018.05.30.03.00.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 30 May 2018 03:00:18 -0700 (PDT)
From: Christoph Hellwig <hch@lst.de>
Subject: buffered writes without buffer heads in xfs and iomap v4
Date: Wed, 30 May 2018 11:59:55 +0200
Message-Id: <20180530100013.31358-1-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-xfs@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

Hi all,

this series adds support for buffered writes without buffer heads to
the iomap and XFS code.

For now this series only contains support for block size == PAGE_SIZE,
with the 4k support split into a separate series.


A git tree is available at:

    git://git.infradead.org/users/hch/xfs.git xfs-iomap-write.4

Gitweb:

    http://git.infradead.org/users/hch/xfs.git/shortlog/refs/heads/xfs-iomap-write.4

Changes since v3:
 - iterate backwards in xfs_bmap_punch_delalloc_range
 - remove the cow_valid variable in xfs_reflink_trim_irec_to_next_cow
 - additional trivial xfs_map_blocks simplifications
 - split the read side into a separate prep series
 - moved the SEEK_HOLE/DATA patches not strictly required out of the series

Changes since v2:
 - minor page_seek_hole_data tweaks
 - don't read data entirely covered by the write operation in write_begin
 - fix zeroing on write_begin I/O failure
 - remove iomap_block_needs_zeroing to make the code more clear
 - update comments on __do_page_cache_readahead

Changes since v1:
 - fix the iomap_readpages error handling
 - use unsigned file offsets in a few places to avoid arithmetic overflows
 - allocate a iomap_page in iomap_page_mkwrite to fix generic/095
 - improve a few comments
 - add more asserts
 - warn about truncated block numbers from ->bmap
 - new patch to change the __do_page_cache_readahead return value to
   unsigned int
 - remove an incorrectly added empty line
 - make inline data an explicit iomap type instead of a flag
 - add a IOMAP_F_BUFFER_HEAD flag to force use of buffers heads for gfs2,
   and keep the basic buffer head infrastructure around for now.
