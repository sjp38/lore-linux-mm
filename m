Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id A67B76B0005
	for <linux-mm@kvack.org>; Thu, 31 May 2018 14:06:19 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id 31-v6so13763983plf.19
        for <linux-mm@kvack.org>; Thu, 31 May 2018 11:06:19 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id l12-v6si30457362pgr.367.2018.05.31.11.06.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 31 May 2018 11:06:18 -0700 (PDT)
From: Christoph Hellwig <hch@lst.de>
Subject: iomap based buffered reads & iomap cleanups v5
Date: Thu, 31 May 2018 20:06:01 +0200
Message-Id: <20180531180614.21506-1-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-xfs@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

Hi all,

this series adds support for buffered reads without buffer heads to
the iomap and XFS code.  It has been split from the larger series
for easier review.


A git tree is available at:

    git://git.infradead.org/users/hch/xfs.git xfs-iomap-read.5

Gitweb:

    http://git.infradead.org/users/hch/xfs.git/shortlog/refs/heads/xfs-iomap-read.5

Changes since v4:
 - a couple comment updates

Changes since v3:
 - remove iomap_read_bio_alloc
 - set REQ_RAHEAD flag for readpages
 - better commen on the add_to_page_cache_lru semantics for readpages
 - move all write related patches to a separate series

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
