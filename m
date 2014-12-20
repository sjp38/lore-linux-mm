Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id E7FF66B0032
	for <linux-mm@kvack.org>; Fri, 19 Dec 2014 22:18:43 -0500 (EST)
Received: by mail-pa0-f49.google.com with SMTP id eu11so2344241pac.8
        for <linux-mm@kvack.org>; Fri, 19 Dec 2014 19:18:43 -0800 (PST)
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com. [209.85.192.176])
        by mx.google.com with ESMTPS id gb9si16486676pac.141.2014.12.19.19.18.41
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 19 Dec 2014 19:18:42 -0800 (PST)
Received: by mail-pd0-f176.google.com with SMTP id r10so2335441pdi.35
        for <linux-mm@kvack.org>; Fri, 19 Dec 2014 19:18:41 -0800 (PST)
From: Omar Sandoval <osandov@osandov.com>
Subject: [PATCH v2 0/5] clean up and generalize swap-over-NFS
Date: Fri, 19 Dec 2014 19:18:24 -0800
Message-Id: <cover.1419044605.git.osandov@osandov.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Trond Myklebust <trond.myklebust@primarydata.com>, Christoph Hellwig <hch@infradead.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Omar Sandoval <osandov@osandov.com>

Hi,

This patch series (based on ecb5ec0 in Linus' tree) contains all of the
non-BTRFS work that I've done to implement swapfiles on BTRFS. The BTRFS
portion is still undergoing development and is now outweighed by the
non-BTRFS changes, so I want to get these in separately.

Version 2 changes the generic swapfile interface to use ->read_iter and
->write_iter instead of using ->direct_IO directly in response to
discussion on the previous submission. It also adds the iov_iter_is_bvec
helper to factor out some common checks.

Version 1 can be found here: https://lkml.org/lkml/2014/12/15/7

Omar Sandoval (5):
  iov_iter: add ITER_BVEC helpers
  direct-io: don't dirty ITER_BVEC pages on read
  nfs: don't dirty ITER_BVEC pages read through direct I/O
  swapfile: use ->read_iter and ->write_iter
  vfs: update swap_{,de}activate documentation

 Documentation/filesystems/Locking |  7 ++++---
 Documentation/filesystems/vfs.txt |  7 ++++---
 fs/direct-io.c                    |  8 ++++---
 fs/nfs/direct.c                   |  5 ++++-
 fs/splice.c                       |  7 ++-----
 include/linux/uio.h               |  7 +++++++
 mm/iov_iter.c                     | 12 +++++++++++
 mm/page_io.c                      | 44 +++++++++++++++++++++++++--------------
 mm/swapfile.c                     | 11 +++++++++-
 9 files changed, 76 insertions(+), 32 deletions(-)

-- 
2.2.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
