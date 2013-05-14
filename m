Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id 417496B0093
	for <linux-mm@kvack.org>; Tue, 14 May 2013 12:37:42 -0400 (EDT)
From: Lukas Czerner <lczerner@redhat.com>
Subject: [PATCH v4 00/20] change invalidatepage prototype to accept length
Date: Tue, 14 May 2013 18:37:14 +0200
Message-Id: <1368549454-8930-1-git-send-email-lczerner@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, akpm@linux-foundation.org, hughd@google.com, lczerner@redhat.com

Hi,

This set of patches are aimed to allow truncate_inode_pages_range() handle
ranges which are not aligned at the end of the page. Currently it will
hit BUG_ON() when the end of the range is not aligned. Punch hole feature
however can benefit from this ability saving file systems some work not
forcing them to implement their own invalidate code to handle unaligned
ranges.

In order for this to woke we need change ->invalidatepage() address space
operation to to accept range to invalidate by adding 'length' argument in
addition to 'offset'. This is different from my previous attempt to create
new aop ->invalidatepage_range (http://lwn.net/Articles/514828/) which I
reconsidered to be unnecessary.

It would be for the best if this series could go through ext4 branch since
there are a lot of ext4 changes which are based on dev branch of ext4 
(git://git.kernel.org/pub/scm/linux/kernel/git/tytso/ext4.git)

For description purposes this patch set can be divided into following
groups:

patch 0001:    Change ->invalidatepage() prototype adding 'length' argument
	and changing all the instances. In very simple cases file
	system methods are completely adapted, otherwise only
	prototype is changed and the rest will follow. This patch
	also implement the 'range' invalidation in
	block_invalidatepage().

patch 0002 - 0009:
	Make the use of new 'length' argument in the file system
	itself. Some file systems can take advantage of it trying
	to invalidate only portion of the page if possible, some
	can't, however none of the file systems currently attempt
	to truncate non page aligned ranges.


patch 0010:    Teach truncate_inode_pages_range() to handle non page aligned
	ranges.

patch 0011 - 0020:
	Ext4 changes build on top of previous changes, simplifying
	punch hole code. Not all changes are realated specifically
	to invalidatepage() change, but all are related to the punch
	hole feature.

Even though this patch set would mainly affect functionality of the file
file systems implementing punch hole I've tested all the following file
system using xfstests without noticing any bugs related to this change.

ext3, ext4, xfs, btrfs, gfs2 and reiserfs

I've also tested block size < page size on ext4 with xfstests and fsx.


v3 -> v4: Some minor changes based on the reviews. Added two ext4 patches
	  as suggested by Jan Kara.

Thanks!
-Lukas

-- 
 Documentation/filesystems/Locking |    6 +-
 Documentation/filesystems/vfs.txt |   20 +-
 fs/9p/vfs_addr.c                  |    5 +-
 fs/afs/file.c                     |   10 +-
 fs/btrfs/disk-io.c                |    3 +-
 fs/btrfs/extent_io.c              |    2 +-
 fs/btrfs/inode.c                  |    3 +-
 fs/buffer.c                       |   21 ++-
 fs/ceph/addr.c                    |   15 +-
 fs/cifs/file.c                    |    5 +-
 fs/exofs/inode.c                  |    6 +-
 fs/ext3/inode.c                   |    9 +-
 fs/ext4/ext4.h                    |   14 +-
 fs/ext4/extents.c                 |   96 ++++++----
 fs/ext4/inode.c                   |  402 ++++++++++++++-----------------------
 fs/ext4/super.c                   |    1 +
 fs/f2fs/data.c                    |    3 +-
 fs/f2fs/node.c                    |    3 +-
 fs/gfs2/aops.c                    |   17 +-
 fs/jbd/transaction.c              |   19 ++-
 fs/jbd2/transaction.c             |   24 ++-
 fs/jfs/jfs_metapage.c             |    5 +-
 fs/logfs/file.c                   |    3 +-
 fs/logfs/segment.c                |    3 +-
 fs/nfs/file.c                     |    8 +-
 fs/ntfs/aops.c                    |    2 +-
 fs/ocfs2/aops.c                   |    5 +-
 fs/reiserfs/inode.c               |   12 +-
 fs/ubifs/file.c                   |    5 +-
 fs/xfs/xfs_aops.c                 |   14 +-
 fs/xfs/xfs_trace.h                |   15 +-
 include/linux/buffer_head.h       |    3 +-
 include/linux/fs.h                |    2 +-
 include/linux/jbd.h               |    2 +-
 include/linux/jbd2.h              |    2 +-
 include/linux/mm.h                |    3 +-
 include/trace/events/ext3.h       |   12 +-
 include/trace/events/ext4.h       |   64 ++++---
 mm/readahead.c                    |    2 +-
 mm/truncate.c                     |  117 ++++++++----
 40 files changed, 503 insertions(+), 460 deletions(-)

[PATCH v4 01/20] mm: change invalidatepage prototype to accept
[PATCH v4 02/20] jbd2: change jbd2_journal_invalidatepage to accept
[PATCH v4 03/20] ext4: use ->invalidatepage() length argument
[PATCH v4 04/20] jbd: change journal_invalidatepage() to accept
[PATCH v4 05/20] xfs: use ->invalidatepage() length argument
[PATCH v4 06/20] ocfs2: use ->invalidatepage() length argument
[PATCH v4 07/20] ceph: use ->invalidatepage() length argument
[PATCH v4 08/20] gfs2: use ->invalidatepage() length argument
[PATCH v4 09/20] reiserfs: use ->invalidatepage() length argument
[PATCH v4 10/20] mm: teach truncate_inode_pages_range() to handle
[PATCH v4 11/20] Revert "ext4: remove no longer used functions in
[PATCH v4 12/20] ext4: Call ext4_jbd2_file_inode() after zeroing
[PATCH v4 13/20] Revert "ext4: fix fsx truncate failure"
[PATCH v4 14/20] ext4: truncate_inode_pages() in orphan cleanup path
[PATCH v4 15/20] ext4: use ext4_zero_partial_blocks in punch_hole
[PATCH v4 16/20] ext4: remove unused discard_partial_page_buffers
[PATCH v4 17/20] ext4: remove unused code from ext4_remove_blocks()
[PATCH v4 18/20] ext4: update ext4_ext_remove_space trace point
[PATCH v4 19/20] ext4: make punch hole code path work with bigalloc
[PATCH v4 20/20] ext4: Allow punch hole with bigalloc enabled

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
