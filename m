Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id D04386B0297
	for <linux-mm@kvack.org>; Mon, 24 Apr 2017 09:23:09 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id u68so41521577qkd.20
        for <linux-mm@kvack.org>; Mon, 24 Apr 2017 06:23:09 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d189si18004845qkf.270.2017.04.24.06.23.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Apr 2017 06:23:08 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH v3 00/20] fs: introduce new writeback error reporting and convert existing API as a wrapper around it
Date: Mon, 24 Apr 2017 09:22:39 -0400
Message-Id: <20170424132259.8680-1-jlayton@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-ext4@vger.kernel.org, linux-cifs@vger.kernel.org, linux-mm@kvack.org, jfs-discussion@lists.sourceforge.net, linux-xfs@vger.kernel.org, cluster-devel@redhat.com, linux-f2fs-devel@lists.sourceforge.net, v9fs-developer@lists.sourceforge.net, osd-dev@open-osd.org, linux-nilfs@vger.kernel.org, linux-block@vger.kernel.org
Cc: dhowells@redhat.com, akpm@linux-foundation.org, hch@infradead.org, ross.zwisler@linux.intel.com, mawilcox@microsoft.com, jack@suse.com, viro@zeniv.linux.org.uk, corbet@lwn.net, neilb@suse.de, clm@fb.com, tytso@mit.edu, axboe@kernel.dk

v3: wb_err_t -> errseq_t
    clean up places that re-set errors after calling filemap_* functions

v2: introduce wb_err_t, use atomics

Apologies for the wide posting here, but this touches a lot of areas.
This is v3 of the patchset to improve how we're tracking and reporting
errors that occur during pagecache writeback.

There are several situations where the kernel can "lose" errors that
occur during writeback, such that fsync will return success even
though it failed to write back some data previously. The basic idea
here is to have the kernel be more deliberate about the point from
which errors are checked to ensure that that doesn't happen.

Additionally, this set changes the behavior of fsync in Linux to report
writeback errors on all fds instead of just the first one. This allows
writers to reliably tell whether their data made it to the backing
device without having to coordinate fsync calls with other writers.

This set sprawls over a large swath of kernel code. I think the first 12
patches in the series are pretty straightforward and are more or less
ready for merge.

The real changes start with patch 13. That adds support for errseq_t,
builds a new writeback error tracking API on top of that, and converts
the existing code to use it. After that, there are a few cleanup patches
to eliminate some unneeded error re-setting, etc.

Unfortunately, testing this across so many filesystems is rather
difficult. I have a xfstest for block-based filesystems that uses
dm_error that I'll post soon. That works well with ext4, but btrfs and
xfs seem to go r/o soon after the first error. I also don't have a good
general method for testing this on network filesystems (yet!).

I'd like to see better testing here and am open to suggestions. I will
note that the POSIX fsync spec says this:

"It is reasonable to assert that the key aspects of fsync() are
unreasonable to test in a test suite. That does not make the function
any less valuable, just more difficult to test. [...] It would also not
be unreasonable to omit testing for fsync(), allowing it to be treated
as a quality-of-implementation issue."

Of course, they're talking about a POSIX conformance test, but I
think the same point applies here.

At this point, I'd like to start getting some of the preliminary patches
merged (the first 12 or so). Most of those aren't terribly controversial
and seem like reasonable bugfixes and cleanups. If any subsystem
maintainers want to pick those up, then please do.

After that, I'd like to get the larger changes into linux-next with an
aim for merge in v4.13 or v4.14 (depending on how testing goes).

Feedback is of course welcome!

Jeff Layton (20):
  mm: drop "wait" parameter from write_one_page
  mm: fix mapping_set_error call in me_pagecache_dirty
  buffer: use mapping_set_error instead of setting the flag
  fs: check for writeback errors after syncing out buffers in
    generic_file_fsync
  orangefs: don't call filemap_write_and_wait from fsync
  dax: set errors in mapping when writeback fails
  nilfs2: set the mapping error when calling SetPageError on writeback
  mm: ensure that we set mapping error if writeout() fails
  9p: set mapping error when writeback fails in launder_page
  fuse: set mapping error in writepage_locked when it fails
  cifs: set mapping error when page writeback fails in writepage or
    launder_pages
  lib: add errseq_t type and infrastructure for handling it
  fs: new infrastructure for writeback error handling and reporting
  fs: retrofit old error reporting API onto new infrastructure
  mm: remove AS_EIO and AS_ENOSPC flags
  mm: don't TestClearPageError in __filemap_fdatawait_range
  cifs: cleanup writeback handling errors and comments
  mm: clean up error handling in write_one_page
  jbd2: don't reset error in journal_finish_inode_data_buffers
  gfs2: clean up some filemap_* calls

 Documentation/filesystems/vfs.txt |   9 +-
 fs/9p/vfs_addr.c                  |   5 +-
 fs/btrfs/file.c                   |  10 +-
 fs/btrfs/tree-log.c               |   9 +-
 fs/buffer.c                       |   2 +-
 fs/cifs/cifsfs.c                  |   4 +-
 fs/cifs/file.c                    |  17 ++--
 fs/cifs/inode.c                   |  22 ++---
 fs/dax.c                          |   4 +-
 fs/exofs/dir.c                    |   2 +-
 fs/ext2/dir.c                     |   2 +-
 fs/ext2/file.c                    |   2 +-
 fs/f2fs/file.c                    |   3 +
 fs/f2fs/node.c                    |   6 +-
 fs/fuse/file.c                    |   8 +-
 fs/gfs2/glops.c                   |  12 +--
 fs/gfs2/lops.c                    |   4 +-
 fs/gfs2/super.c                   |   6 +-
 fs/jbd2/commit.c                  |  13 +--
 fs/jfs/jfs_metapage.c             |   4 +-
 fs/libfs.c                        |   3 +
 fs/minix/dir.c                    |   2 +-
 fs/nilfs2/segment.c               |   1 +
 fs/open.c                         |   3 +
 fs/orangefs/file.c                |   5 +-
 fs/sysv/dir.c                     |   2 +-
 fs/ufs/dir.c                      |   2 +-
 include/linux/errseq.h            |  16 +++
 include/linux/fs.h                |  41 ++++++--
 include/linux/mm.h                |   2 +-
 include/linux/pagemap.h           |  18 ++--
 lib/Makefile                      |   2 +-
 lib/errseq.c                      | 199 ++++++++++++++++++++++++++++++++++++++
 mm/filemap.c                      |  88 ++++++++++-------
 mm/memory-failure.c               |   2 +-
 mm/migrate.c                      |   6 +-
 mm/page-writeback.c               |  23 +++--
 37 files changed, 398 insertions(+), 161 deletions(-)
 create mode 100644 include/linux/errseq.h
 create mode 100644 lib/errseq.c

-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
