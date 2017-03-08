Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id EAF5C6B03F5
	for <linux-mm@kvack.org>; Wed,  8 Mar 2017 11:29:56 -0500 (EST)
Received: by mail-qk0-f200.google.com with SMTP id c85so95483408qkg.0
        for <linux-mm@kvack.org>; Wed, 08 Mar 2017 08:29:56 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m64si3319066qkl.83.2017.03.08.08.29.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Mar 2017 08:29:53 -0800 (PST)
From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH v2 0/9] mm/fs: get PG_error out of the writeback reporting business
Date: Wed,  8 Mar 2017 11:29:25 -0500
Message-Id: <20170308162934.21989-1-jlayton@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: viro@zeniv.linux.org.uk, akpm@linux-foundation.org
Cc: konishi.ryusuke@lab.ntt.co.jp, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-nilfs@vger.kernel.org, ross.zwisler@linux.intel.com, jack@suse.cz, neilb@suse.com, openosd@gmail.com, adilger@dilger.ca, James.Bottomley@HansenPartnership.com

v2:
- still ClearPageError during __filemap_fdatawait_range
- clear AS_* errors when reporting errors during write initiation
- set mapping errors when launder_page fails
- set mapping errors when writeback fails during migration
- set mapping errors when DAX writeback fails
- Documentation patch to give guidance about writeback errors

Here is v2 of this set. The main difference is some new patches to
ensure that mapping errors get set in a few rather obscure places when
writeback fails, and a patch (based on Jan's suggestion) to clear out
the address space errors when initiating writeback fails with -EIO. I
also left the code clearing PG_error in __filemap_fdatawait_range. We
may want to remove that eventually, but we need to ensure that it gets
cleared in some way when writeback fails.

I've done a bit of testing with this (mostly xfstests on xfs), and it
seems to work ok AFAICT.

Original cover letter follows:

------------------------------8<-----------------------------

I recently did some work to wire up -ENOSPC handling in ceph, and found
I could get back -EIO errors in some cases when I should have instead
gotten -ENOSPC. The problem was that the ceph writeback code would set
PG_error on a writeback error, and that error would clobber the mapping
error.

While I fixed that problem by simply not setting that bit on errors,
that led me down a rabbit hole of looking at how PG_error is being
handled in the kernel.

This patch series is a few fixes for things that I 100% noticed by
inspection. I don't have a great way to test these since they involve
error handling. I can certainly doctor up a kernel to inject errors
in this code and test by hand however if these look plausible up front.

Jeff Layton (9):
  mm: fix mapping_set_error call in me_pagecache_dirty
  mm: drop "wait" parameter from write_one_page
  mm: clear any AS_* errors when returning error on any fsync or close
  nilfs2: set the mapping error when calling SetPageError on writeback
  dax: set error in mapping when writeback fails
  mm: set mapping error when launder_pages fails
  mm: ensure that we set mapping error if writeout() fails
  mm: don't TestClearPageError in __filemap_fdatawait_range
  Documentation: document what to do on a writeback error

 Documentation/filesystems/vfs.txt |  7 +++++++
 fs/dax.c                          |  4 +++-
 fs/exofs/dir.c                    |  2 +-
 fs/ext2/dir.c                     |  2 +-
 fs/jfs/jfs_metapage.c             |  4 ++--
 fs/minix/dir.c                    |  2 +-
 fs/nilfs2/segment.c               |  1 +
 fs/sysv/dir.c                     |  2 +-
 fs/ufs/dir.c                      |  2 +-
 include/linux/mm.h                |  2 +-
 mm/filemap.c                      | 40 ++++++++++++++++++++++-----------------
 mm/memory-failure.c               |  2 +-
 mm/migrate.c                      |  6 +++++-
 mm/page-writeback.c               | 14 +++++++-------
 mm/truncate.c                     |  6 +++++-
 15 files changed, 60 insertions(+), 36 deletions(-)

-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
