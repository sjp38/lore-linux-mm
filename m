Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 33A4C2806E8
	for <linux-mm@kvack.org>; Tue,  9 May 2017 11:49:38 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id m91so1449439qte.10
        for <linux-mm@kvack.org>; Tue, 09 May 2017 08:49:38 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 42si307259qtv.59.2017.05.09.08.49.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 May 2017 08:49:37 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH v4 00/27] fs: introduce new writeback error reporting and convert existing API as a wrapper around it
Date: Tue,  9 May 2017 11:49:03 -0400
Message-Id: <20170509154930.29524-1-jlayton@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-ext4@vger.kernel.org, linux-cifs@vger.kernel.org, linux-nfs@vger.kernel.org, linux-mm@kvack.org, jfs-discussion@lists.sourceforge.net, linux-xfs@vger.kernel.org, cluster-devel@redhat.com, linux-f2fs-devel@lists.sourceforge.net, v9fs-developer@lists.sourceforge.net, linux-nilfs@vger.kernel.org, linux-block@vger.kernel.org
Cc: dhowells@redhat.com, akpm@linux-foundation.org, hch@infradead.org, ross.zwisler@linux.intel.com, mawilcox@microsoft.com, jack@suse.com, viro@zeniv.linux.org.uk, corbet@lwn.net, neilb@suse.de, clm@fb.com, tytso@mit.edu, axboe@kernel.dk, josef@toxicpanda.com, hubcap@omnibond.com, rpeterso@redhat.com, bo.li.liu@oracle.com

v4: several more cleanup patches
    documentation and kerneldoc comment updates
    fix bugs in gfs2 patches
    make sync_file_range use same error reporting semantics
    bugfixes in buffer.c
    convert nfs to new scheme (maybe bogus, can be dropped)

v3: wb_err_t -> errseq_t conversion
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

Finally, there are several patches that attempt to codify the semantics
in the documentation and make it clear what filesystems should do when
there are writeback errors.

Unfortunately, testing this across so many filesystems is rather
difficult. I have a xfstest for block-based filesystems that uses
dm_error that I'll repost soon. It works well with xfs and ext4 and
those now pass after this patchset. btrfs still fails however, so it
may need some more work to get this right. I also don't have a good
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

Feedback is of course welcome.

Jeff Layton (27):
  fs: remove unneeded forward definition of mm_struct from fs.h
  mm: drop "wait" parameter from write_one_page
  mm: fix mapping_set_error call in me_pagecache_dirty
  buffer: use mapping_set_error instead of setting the flag
  btrfs: btrfs_wait_tree_block_writeback can be void return
  fs: check for writeback errors after syncing out buffers in
    generic_file_fsync
  orangefs: don't call filemap_write_and_wait from fsync
  dax: set errors in mapping when writeback fails
  nilfs2: set the mapping error when calling SetPageError on writeback
  9p: set mapping error when writeback fails in launder_page
  fuse: set mapping error in writepage_locked when it fails
  cifs: set mapping error when page writeback fails in writepage or
    launder_pages
  lib: add errseq_t type and infrastructure for handling it
  fs: new infrastructure for writeback error handling and reporting
  fs: retrofit old error reporting API onto new infrastructure
  fs: adapt sync_file_range to new reporting infrastructure
  mm: remove AS_EIO and AS_ENOSPC flags
  mm: don't TestClearPageError in __filemap_fdatawait_range
  buffer: set errors in mapping at the time that the error occurs
  cifs: cleanup writeback handling errors and comments
  mm: clean up error handling in write_one_page
  jbd2: don't reset error in journal_finish_inode_data_buffers
  gfs2: clean up some filemap_* calls
  nfs: convert to new errseq_t based error tracking for writeback errors
  Documentation: flesh out the section in vfs.txt on storing and
    reporting writeback errors
  mm: flesh out comments over mapping_set_error
  mm: clean up comments in me_pagecache_dirty

 Documentation/filesystems/vfs.txt |  49 +++++++++-
 drivers/dax/dax.c                 |   1 +
 fs/9p/vfs_addr.c                  |   5 +-
 fs/block_dev.c                    |   1 +
 fs/btrfs/disk-io.c                |   6 +-
 fs/btrfs/disk-io.h                |   2 +-
 fs/btrfs/file.c                   |  10 +-
 fs/btrfs/tree-log.c               |   9 +-
 fs/buffer.c                       |  19 ++--
 fs/cifs/cifsfs.c                  |   4 +-
 fs/cifs/file.c                    |  19 ++--
 fs/cifs/inode.c                   |  22 ++---
 fs/dax.c                          |   4 +-
 fs/exofs/dir.c                    |   2 +-
 fs/ext2/dir.c                     |   2 +-
 fs/ext2/file.c                    |   2 +-
 fs/f2fs/file.c                    |   3 +
 fs/f2fs/node.c                    |   6 +-
 fs/file_table.c                   |   1 +
 fs/fuse/file.c                    |   8 +-
 fs/gfs2/glops.c                   |  17 +---
 fs/gfs2/lops.c                    |   6 +-
 fs/gfs2/super.c                   |   6 +-
 fs/jbd2/commit.c                  |  13 +--
 fs/jfs/jfs_metapage.c             |   4 +-
 fs/libfs.c                        |   3 +
 fs/minix/dir.c                    |   2 +-
 fs/nfs/file.c                     |  19 ++--
 fs/nfs/inode.c                    |   5 +-
 fs/nfs/write.c                    |   2 +-
 fs/nilfs2/segment.c               |   1 +
 fs/open.c                         |   3 +
 fs/orangefs/file.c                |   5 +-
 fs/sync.c                         |  13 ++-
 fs/sysv/dir.c                     |   2 +-
 fs/ufs/dir.c                      |   2 +-
 include/linux/buffer_head.h       |   1 +
 include/linux/errseq.h            |  19 ++++
 include/linux/fs.h                |  45 +++++++--
 include/linux/mm.h                |   2 +-
 include/linux/nfs_fs.h            |   3 +-
 include/linux/pagemap.h           |  32 +++---
 lib/Makefile                      |   2 +-
 lib/errseq.c                      | 199 ++++++++++++++++++++++++++++++++++++++
 mm/filemap.c                      | 103 ++++++++++++--------
 mm/memory-failure.c               |  37 ++-----
 mm/page-writeback.c               |  23 +++--
 47 files changed, 512 insertions(+), 232 deletions(-)
 create mode 100644 include/linux/errseq.h
 create mode 100644 lib/errseq.c

-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
