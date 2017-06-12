Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 392CF6B0314
	for <linux-mm@kvack.org>; Mon, 12 Jun 2017 08:23:21 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id o41so42575669qtf.8
        for <linux-mm@kvack.org>; Mon, 12 Jun 2017 05:23:21 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b46si8612978qtb.40.2017.06.12.05.23.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Jun 2017 05:23:19 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH v6 00/20] fs: enhanced writeback error reporting with errseq_t (pile #1)
Date: Mon, 12 Jun 2017 08:22:52 -0400
Message-Id: <20170612122316.13244-1-jlayton@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@ZenIV.linux.org.uk>, Jan Kara <jack@suse.cz>, tytso@mit.edu, axboe@kernel.dk, mawilcox@microsoft.com, ross.zwisler@linux.intel.com, corbet@lwn.net, Chris Mason <clm@fb.com>, Josef Bacik <jbacik@fb.com>, David Sterba <dsterba@suse.com>, "Darrick J . Wong" <darrick.wong@oracle.com>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-ext4@vger.kernel.org, linux-xfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-block@vger.kernel.org

v6:
===
This is the sixth posting of the patchset to revamp the way writeback
errors are tracked and reported.

This is a smaller set than the last one. The main difference from the
last set is that this one just adds errseq_t based error reporting for
the purposes of fsync, while leaving the internal callers of filemap_*
functions and the like largely untouched.

Some of these patches have been posted separately, but I'm re-posting
them here to make it clear that they're prerequisites to the later
patches in the series.

Background:
===========
The basic problem is that we have (for a very long time) tracked and
reported writeback errors based on two flags in the address_space:
AS_EIO and AS_ENOSPC. Those flags are cleared when they are checked,
so only the first caller to check them is able to consume them.

That model is quite unreliable though, for several related reasons:

* only the first fsync caller on the inode will see the error. In a
  world of containerized setups, that's no longer viable. Applications
  need to know that their writes are safely stored, and they can
  currently miss seeing errors that they should be aware of when
  they're not.

* there are a lot of internal callers to filemap_fdatawait* and
  filemap_write_and_wait* that clear the error flags but then never
  report them to userland in any fashion.

* Some internal callers report writeback errors, but can do so at
  non-sensical times. For instance, we might want to truncate a file,
  which triggers a pagecache flush. If that writeback fails, we might
  report that error to the truncate caller, but a subsequent fsync
  will likely not see it.

* Some internal callers try to reset the error flags after clearing
  them, but that's racy. Another task could check the flags between
  those two events.

Solution:
=========
This patchset adds a new datatype called an errseq_t that represents a
sequence of errors. It's a u32, with a field for a POSIX-flavor error
and a counter, managed with atomics. We can sample that value at a
particular point in time, and can later tell whether there have been any
errors since that point.

That allows us to provide traditional check-and-clear fsync semantics
on every open file description in a lightweight fashion. fsync callers
no longer need to coordinate between one another in order to ensure
that errors at fsync time are handled correctly.

Strategy:
=========
The aim with this set is to do the minimum possible to support for
reliable reporting of errors on fsync, without substantially changing
the internals of the filesystems themselves.

Most of the internal calls to filemap_fdatawait are left alone, so all
of the internal error error checking is done using the traditional flag
based checks. The only real difference here is more reliable reporting
of errors at fsync.

I think that we probably will want to eventually convert all of the
internal callers to use errseq_t based reporting too, but that can be
done in an incremental fashion in follow-on patchsets.

Testing:
========
I've primarily been testing this with a couple of new xfstests that I
will post separately. These tests use dm-error fault injection to flip
the underlying block device to start throwing I/O errors, and then test
the behavior of the filesystem layer on top of that.

Jeff Layton (20):
  mm: fix mapping_set_error call in me_pagecache_dirty
  buffer: use mapping_set_error instead of setting the flag
  fs: check for writeback errors after syncing out buffers in
    generic_file_fsync
  buffer: set errors in mapping at the time that the error occurs
  mm: don't TestClearPageError in __filemap_fdatawait_range
  mm: drop "wait" parameter from write_one_page
  mm: clean up error handling in write_one_page
  lib: add errseq_t type and infrastructure for handling it
  fs: new infrastructure for writeback error handling and reporting
  mm: tracepoints for writeback error events
  mm: set both AS_EIO/AS_ENOSPC and errseq_t in mapping_set_error
  fs: add a new fstype flag to indicate how writeback errors are tracked
  Documentation: flesh out the section in vfs.txt on storing and
    reporting writeback errors
  dax: set errors in mapping when writeback fails
  fs: have call_fsync call filemap_report_wb_err if FS_WB_ERRSEQ is set
  block: convert to errseq_t based writeback error tracking
  fs: add f_md_wb_err field to struct file for tracking metadata errors
  ext4: use errseq_t based error handling for reporting data writeback
    errors
  xfs: minimal conversion to errseq_t writeback error reporting
  btrfs: minimal conversion to errseq_t writeback error reporting on
    fsync

 Documentation/filesystems/vfs.txt |  48 ++++++++-
 drivers/dax/device.c              |   1 +
 fs/block_dev.c                    |   2 +
 fs/btrfs/super.c                  |   2 +-
 fs/buffer.c                       |  20 ++--
 fs/dax.c                          |  18 +++-
 fs/exofs/dir.c                    |   2 +-
 fs/ext2/dir.c                     |   2 +-
 fs/ext2/file.c                    |   2 +-
 fs/ext4/dir.c                     |   8 +-
 fs/ext4/file.c                    |   5 +-
 fs/ext4/fsync.c                   |  23 ++++-
 fs/ext4/super.c                   |   6 +-
 fs/file_table.c                   |   1 +
 fs/gfs2/lops.c                    |   2 +-
 fs/jfs/jfs_metapage.c             |   4 +-
 fs/libfs.c                        |   3 +-
 fs/minix/dir.c                    |   2 +-
 fs/open.c                         |   3 +
 fs/sysv/dir.c                     |   2 +-
 fs/ufs/dir.c                      |   2 +-
 fs/xfs/xfs_super.c                |   2 +-
 include/linux/buffer_head.h       |   1 +
 include/linux/errseq.h            |  19 ++++
 include/linux/fs.h                |  80 +++++++++++++--
 include/linux/mm.h                |   2 +-
 include/linux/pagemap.h           |  31 ++++--
 include/trace/events/filemap.h    |  52 ++++++++++
 lib/Makefile                      |   2 +-
 lib/errseq.c                      | 208 ++++++++++++++++++++++++++++++++++++++
 mm/filemap.c                      |  91 ++++++++++++++---
 mm/memory-failure.c               |   2 +-
 mm/page-writeback.c               |  21 ++--
 33 files changed, 595 insertions(+), 74 deletions(-)
 create mode 100644 include/linux/errseq.h
 create mode 100644 lib/errseq.c

-- 
2.13.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
