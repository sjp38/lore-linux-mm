Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id E6B686B005D
	for <linux-mm@kvack.org>; Fri, 21 Dec 2012 16:28:38 -0500 (EST)
Received: by mail-pa0-f53.google.com with SMTP id hz1so3057496pad.26
        for <linux-mm@kvack.org>; Fri, 21 Dec 2012 13:28:38 -0800 (PST)
From: Andy Lutomirski <luto@amacapital.net>
Subject: [PATCH v2 0/3] Rework mtime and ctime updates on mmaped writes
Date: Fri, 21 Dec 2012 13:28:25 -0800
Message-Id: <cover.1356124965.git.luto@amacapital.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linux FS Devel <linux-fsdevel@vger.kernel.org>
Cc: Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Al Viro <viro@zeniv.linux.org.uk>, Andy Lutomirski <luto@amacapital.net>

Writes via mmap currently update mtime and ctime in ->page_mkwrite.
This is unfortunate from a performance and a correctness point of view.
The file times should be updated after writes, not before (so that every
write eventually results in a fresh timestamp).  This is needed for
POSIX compliance.  More importantly (for me), ->page_mkwrite is called
periodically even on mlocked pages, and some filesystems can sleep in
mark_inode_dirty.

This patchset attempts to fix both issues at once.  It adds a new
address_space flag AS_CMTIME that is set atomically whenever the system
transfers a pte dirty bit to a struct page backed by the address_space.
This can happen with various locks held and when low on memory.

Later on, whenever syncing an inode (which happens indirectly in msync)
or whenever a vma is torn down, if AS_CMTIME is set, then the file times
are updated.  This happens in a context from which (I think) it's safe
to dirty inodes.

One nice property of this approach is that it requires no fs-specific
work.  It's actually quite a bit simpler than I expected.

I've tested this, and mtime and ctime are updated on munmap, exit, MS_SYNC,
and fsync after writing via mmap.  The times are also updated 30 seconds
after writing, all by themselves :)  xfstest #215 also passes.Lockdep has
no complaints.

Changes from v1:
 - inode_update_time_writable now locks against the fs freezer
 - Minor cleanups
 - Major changelog improvements

Andy Lutomirski (3):
  mm: Explicitly track when the page dirty bit is transferred from a
    pte
  mm: Update file times when inodes are written after mmaped writes
  Remove file_update_time from all mkwrite paths

 fs/9p/vfs_file.c        |  3 ---
 fs/btrfs/inode.c        |  4 +--
 fs/buffer.c             |  6 -----
 fs/ceph/addr.c          |  3 ---
 fs/ext4/inode.c         |  1 -
 fs/gfs2/file.c          |  3 ---
 fs/inode.c              | 72 ++++++++++++++++++++++++++++++++++++++-----------
 fs/nilfs2/file.c        |  1 -
 fs/sysfs/bin.c          |  2 --
 include/linux/fs.h      |  1 +
 include/linux/mm.h      |  1 +
 include/linux/pagemap.h |  3 +++
 mm/filemap.c            |  1 -
 mm/memory-failure.c     |  4 +--
 mm/memory.c             |  5 +---
 mm/mmap.c               |  4 +++
 mm/page-writeback.c     | 42 +++++++++++++++++++++++++++--
 mm/rmap.c               |  9 ++++---
 18 files changed, 115 insertions(+), 50 deletions(-)

-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
