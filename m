Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 302AD6B0071
	for <linux-mm@kvack.org>; Wed, 10 Feb 2010 12:03:51 -0500 (EST)
From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 00/13] Allow the VM to manage NFS unstable writes
Date: Wed, 10 Feb 2010 12:03:20 -0500
Message-Id: <1265821413-21618-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
List-ID: <linux-mm.kvack.org>

Hi,

The following patch series applies on top of Al Viro's 'write_inode' branch
in git://git.kernel.org/pub/scm/linux/kernel/git/viro/vfs-2.6.git/
(which basically just adds a struct writeback_control * argument to the
superblock's 'write_inode' callback).

These patches are designed to ensure better control by the VM of the NFS
'unstable writes'. It should allow balance_dirty_pages() to manage the
unstable write page budget, by giving it a method to tell the NFS
client when it needs to clear out unstable writes and, by implication,
when it can continue to cache them.

This patchset has already been posted on the linux-nfs and linux-kernel
mailing lists. I'm posting it here in order to hopefully get some feedback
from the VM community (and possibly a few more Acks).

Apologies to those of you who have already received these patches through
the other mailing lists...

Cheers
  Trond

Peter Zijlstra (1):
  VM: Split out the accounting of unstable writes from BDI_RECLAIMABLE

Trond Myklebust (12):
  VM: Don't call bdi_stat(BDI_UNSTABLE) on non-nfs backing-devices
  NFS: Cleanup - move nfs_write_inode() into fs/nfs/write.c
  NFS: Reduce the number of unnecessary COMMIT calls
  VM/NFS: The VM must tell the filesystem when to free reclaimable
    pages
  NFS: Run COMMIT as an asynchronous RPC call when wbc->for_background
    is set
  NFS: Ensure inode is always marked I_DIRTY_DATASYNC, if it has
    unstable pages
  NFS: Simplify nfs_wb_page_cancel()
  NFS: Replace __nfs_write_mapping with sync_inode()
  NFS: Simplify nfs_wb_page()
  NFS: Clean up nfs_sync_mapping
  NFS: Remove requirement for inode->i_mutex from
    nfs_invalidate_mapping
  NFS: Don't write out dirty pages in nfs_release_page()

 fs/nfs/client.c             |    1 +
 fs/nfs/dir.c                |    2 +-
 fs/nfs/file.c               |    7 ++
 fs/nfs/inode.c              |   82 ++-------------
 fs/nfs/symlink.c            |    2 +-
 fs/nfs/write.c              |  238 ++++++++++++-------------------------------
 include/linux/backing-dev.h |    9 ++-
 include/linux/nfs_fs.h      |   13 ---
 include/linux/writeback.h   |    5 +
 mm/backing-dev.c            |    6 +-
 mm/filemap.c                |    2 +-
 mm/page-writeback.c         |   30 +++++-
 mm/truncate.c               |    2 +-
 13 files changed, 130 insertions(+), 269 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
