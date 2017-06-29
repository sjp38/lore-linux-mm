Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6E9D96B0292
	for <linux-mm@kvack.org>; Thu, 29 Jun 2017 09:20:00 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id 191so21739793oii.4
        for <linux-mm@kvack.org>; Thu, 29 Jun 2017 06:20:00 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id c198si3499580oib.24.2017.06.29.06.19.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Jun 2017 06:19:58 -0700 (PDT)
From: jlayton@kernel.org
Subject: [PATCH v8 00/18] fs: enhanced writeback error reporting with errseq_t (pile #1)
Date: Thu, 29 Jun 2017 09:19:36 -0400
Message-Id: <20170629131954.28733-1-jlayton@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@ZenIV.linux.org.uk>, Jan Kara <jack@suse.cz>, tytso@mit.edu, axboe@kernel.dk, mawilcox@microsoft.com, ross.zwisler@linux.intel.com, corbet@lwn.net, Chris Mason <clm@fb.com>, Josef Bacik <jbacik@fb.com>, David Sterba <dsterba@suse.com>, "Darrick J . Wong" <darrick.wong@oracle.com>
Cc: Carlos Maiolino <cmaiolino@redhat.com>, Eryu Guan <eguan@redhat.com>, David Howells <dhowells@redhat.com>, Christoph Hellwig <hch@infradead.org>, Liu Bo <bo.li.liu@oracle.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-ext4@vger.kernel.org, linux-xfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-block@vger.kernel.org

From: Jeff Layton <jlayton@redhat.com>

v8:
===
- rename filemap_report_wb_err to file_check_and_advance_wb_err (per
  Darrick's suggestion)
- add a file_write_and_wait helper function (per HCH's suggestion)
- change __generic_file_fsync to use errseq_t reporting
- focus on data writeback for now, leave metadata for a follow-on set
- drop patch to always do metadata writeback in __generic_file_fsync

This is the eighth posting of the patchset to revamp the way writeback
errors are tracked and reported. Some of these patches are not new,
but I want to make it clear what I'd like to get merged into v4.13.

The main changes since the last set are a name change for the "report"
function to better indicate that it has side-effects.

Also, I've added a file_write_and_wait function to act as an analogue of
the old filemap_write_and_wait, but that uses errseq_t reporting. With
that change, it became pretty easy to convert __generic_file_fsync, so
I've gone ahead and done that. vfat now passes the simple testcase as
well.

Finally, I've dropped off a few patches here that were intended to make
it possible to report metadata writeback errors on all open fds as well.
That part is turning out to be trickier than expected, so I've decided
to just focus on data writeback here. We can pick up that piece in a
later patcheset.

If no one has major objections, I'll plan to send Linus a PR with this
pile once the merge window opens (unless someone else wants to pick it
up...Al?).

Background:
===========
The basic problem is that we have (for a very long time) tracked and
reported writeback errors based on two flags in the address_space:
AS_EIO and AS_ENOSPC. Those flags are cleared when they are checked,
so only the first caller to check them is able to consume them.

That model is quite unreliable, for several related reasons:

* only the first fsync caller on the inode will see the error. In a
  world of containerized setups, that's no longer viable. Applications
  need to know that their writes are safely stored, and they can
  currently miss seeing errors that they should be aware of when
  they're not.

* there are a lot of internal callers to filemap_fdatawait* and
  filemap_write_and_wait* that clear these errors but then never report
  them to userland in any fashion.

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
The aim with this pile is to do the minimum possible to support for
reliable reporting of errors on fsync, without substantially changing
the internals of the filesystems themselves.

Most of the internal calls to filemap_fdatawait are left alone, so all
of the internal error checkers are using the same error handling they
always have. The only real difference here is that we're better
reporting errors at fsync.

I think that we probably will want to eventually convert all of those
internal callers to use errseq_t based reporting, but that can be done
in an incremental fashion in follow-on patchsets.

Testing:
========
I've primarily been testing this with some new xfstests that I will post
in a separate series. These tests use dm-error fault injection to make
the underlying block device start throwing I/O errors, and then test the
how the filesystem layer reports errors after that.

Jeff Layton (18):
  fs: remove call_fsync helper function
  buffer: use mapping_set_error instead of setting the flag
  fs: check for writeback errors after syncing out buffers in
    generic_file_fsync
  buffer: set errors in mapping at the time that the error occurs
  jbd2: don't clear and reset errors after waiting on writeback
  mm: clear AS_EIO/AS_ENOSPC when writeback initiation fails
  mm: don't TestClearPageError in __filemap_fdatawait_range
  mm: clean up error handling in write_one_page
  lib: add errseq_t type and infrastructure for handling it
  fs: new infrastructure for writeback error handling and reporting
  mm: set both AS_EIO/AS_ENOSPC and errseq_t in mapping_set_error
  Documentation: flesh out the section in vfs.txt on storing and
    reporting writeback errors
  dax: set errors in mapping when writeback fails
  block: convert to errseq_t based writeback error tracking
  fs: convert __generic_file_fsync to use errseq_t based reporting
  ext4: use errseq_t based error handling for reporting data writeback
    errors
  xfs: minimal conversion to errseq_t writeback error reporting
  btrfs: minimal conversion to errseq_t writeback error reporting on
    fsync

 Documentation/filesystems/vfs.txt |  43 +++++++-
 MAINTAINERS                       |   6 ++
 drivers/dax/device.c              |   1 +
 fs/block_dev.c                    |   3 +-
 fs/btrfs/file.c                   |   7 +-
 fs/buffer.c                       |  20 ++--
 fs/dax.c                          |   4 +-
 fs/ext2/file.c                    |   5 +-
 fs/ext4/fsync.c                   |  13 ++-
 fs/file_table.c                   |   1 +
 fs/gfs2/lops.c                    |   2 +-
 fs/jbd2/commit.c                  |  16 +--
 fs/libfs.c                        |   6 +-
 fs/open.c                         |   3 +
 fs/sync.c                         |   2 +-
 fs/xfs/xfs_file.c                 |   2 +-
 include/linux/buffer_head.h       |   1 +
 include/linux/errseq.h            |  19 ++++
 include/linux/fs.h                |  68 +++++++++++--
 include/linux/pagemap.h           |  31 ++++--
 include/trace/events/filemap.h    |  57 +++++++++++
 ipc/shm.c                         |   2 +-
 lib/Makefile                      |   2 +-
 lib/errseq.c                      | 208 ++++++++++++++++++++++++++++++++++++++
 mm/filemap.c                      | 128 +++++++++++++++++++----
 mm/page-writeback.c               |  13 ++-
 26 files changed, 584 insertions(+), 79 deletions(-)
 create mode 100644 include/linux/errseq.h
 create mode 100644 lib/errseq.c

-- 
2.13.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
