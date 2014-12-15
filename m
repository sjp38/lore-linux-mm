Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id B488D6B0038
	for <linux-mm@kvack.org>; Mon, 15 Dec 2014 00:27:25 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id rd3so11104726pab.21
        for <linux-mm@kvack.org>; Sun, 14 Dec 2014 21:27:25 -0800 (PST)
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com. [209.85.220.54])
        by mx.google.com with ESMTPS id fy2si12373017pbb.67.2014.12.14.21.27.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 14 Dec 2014 21:27:24 -0800 (PST)
Received: by mail-pa0-f54.google.com with SMTP id fb1so11162534pad.13
        for <linux-mm@kvack.org>; Sun, 14 Dec 2014 21:27:23 -0800 (PST)
From: Omar Sandoval <osandov@osandov.com>
Subject: [PATCH 0/8] clean up and generalize swap-over-NFS
Date: Sun, 14 Dec 2014 21:26:54 -0800
Message-Id: <cover.1418618044.git.osandov@osandov.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Trond Myklebust <trond.myklebust@primarydata.com>, Christoph Hellwig <hch@infradead.org>, David Sterba <dsterba@suse.cz>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Omar Sandoval <osandov@osandov.com>

Hi, everyone,

This patch series contains all of the non-BTRFS changes that I've made
as a part of implementing swap file support on BTRFS. The BTRFS parts of
that series (https://lkml.org/lkml/2014/12/9/718) are still undergoing
development, and the non-BTRFS changes now outnumber those within BTRFS,
so it'll probably work best to get these in separately.

Long story short, the generic swap file infrastructure introduced for
swap-over-NFS isn't quite ready for other clients without making some
changes.

Before I forget, this patch series was built against cbfe0de in Linus'
tree (to avoid conflicts with the recent iov_iter work).

Patches 1 and 2 fix an issue with NFS and the swap file infrastructure
not following the direct_IO locking conventions, leading to locking
issues for anyone else trying to use the interface (discussed here:
https://lkml.org/lkml/2014/12/12/677).

Patch 3 removes the ITER_BVEC flag from the rw argument passed to
direct_IO, as many, but not all, direct_IO implementations expect either
rw == READ or rw == WRITE. The lack of documentation about what's
correct here is probably going to break something at some point, but
that's another conversation.

Patch 4 adds iov_iter_bvec for swap_writepage, the upcoming
swap_readpage change, and splice.

Patches 5 and 6 are preparation for patch 7, teaching the VFS and NFS to
handle ITER_BVEC reads.

Patch 7 is the biggest change in the series: it changes swap_readpage to
proxy through ->direct_IO rather than ->readpage. Using readpage for a
swapcache page requires all sorts of messy workarounds (see here for
context: https://lkml.org/lkml/2014/11/19/46). Patch 8 updates the
documentation accordingly.

Thanks!

Omar Sandoval (8):
  nfs: follow direct I/O write locking convention
  swap: lock i_mutex for swap_writepage direct_IO
  swap: don't add ITER_BVEC flag to direct_IO rw
  iov_iter: add iov_iter_bvec and convert callers
  direct-io: don't dirty ITER_BVEC pages on read
  nfs: don't dirty ITER_BVEC pages read through direct I/O
  swap: use direct I/O for SWP_FILE swap_readpage
  vfs: update swap_{,de}activate documentation

 Documentation/filesystems/Locking |  7 +++---
 Documentation/filesystems/vfs.txt |  7 +++---
 fs/direct-io.c                    |  8 ++++---
 fs/nfs/direct.c                   | 17 ++++++++-------
 fs/nfs/file.c                     |  8 +++++--
 fs/splice.c                       |  7 ++----
 include/linux/uio.h               |  2 ++
 mm/iov_iter.c                     | 12 +++++++++++
 mm/page_io.c                      | 45 ++++++++++++++++++++++++++++-----------
 9 files changed, 76 insertions(+), 37 deletions(-)

-- 
2.1.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
