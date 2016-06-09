Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id C453D828E5
	for <linux-mm@kvack.org>; Thu,  9 Jun 2016 01:05:37 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id u203so51645760itc.0
        for <linux-mm@kvack.org>; Wed, 08 Jun 2016 22:05:37 -0700 (PDT)
Received: from mail-pa0-x242.google.com (mail-pa0-x242.google.com. [2607:f8b0:400e:c03::242])
        by mx.google.com with ESMTPS id et5si5491436pad.127.2016.06.08.22.05.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Jun 2016 22:05:36 -0700 (PDT)
Received: by mail-pa0-x242.google.com with SMTP id gp3so1909382pac.2
        for <linux-mm@kvack.org>; Wed, 08 Jun 2016 22:05:36 -0700 (PDT)
From: Deepa Dinamani <deepa.kernel@gmail.com>
Subject: [PATCH 00/21] Delete CURRENT_TIME and CURRENT_TIME_SEC macros
Date: Wed,  8 Jun 2016 22:04:44 -0700
Message-Id: <1465448705-25055-1-git-send-email-deepa.kernel@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Arnd Bergmann <arnd@arndb.de>, Thomas Gleixner <tglx@linutronix.de>, Al Viro <viro@zeniv.linux.org.uk>, Linus Torvalds <torvalds@linux-foundation.org>, y2038@lists.linaro.org, Anna Schumaker <anna.schumaker@netapp.com>, Anton Vorontsov <anton@enomsg.org>, Benny Halevy <bhalevy@primarydata.com>, Boaz Harrosh <ooo@electrozaur.com>, Changman Lee <cm224.lee@samsung.com>, Chris Mason <clm@fb.com>, Colin Cross <ccross@android.com>, Dave Kleikamp <shaggy@kernel.org>, "David S. Miller" <davem@davemloft.net>, David Sterba <dsterba@suse.com>, Eric Van Hensbergen <ericvh@gmail.com>, Felipe Balbi <balbi@kernel.org>, Hugh Dickins <hughd@google.com>, Ian Kent <raven@themaw.net>, Jaegeuk Kim <jaegeuk@kernel.org>, Joern Engel <joern@logfs.org>, Josef Bacik <jbacik@fb.com>, Kees Cook <keescook@chromium.org>, Latchesar Ionkov <lucho@ionkov.net>, Matt Fleming <matt@codeblueprint.co.uk>, Matthew Garrett <matthew.garrett@nebula.com>, Miklos Szeredi <miklos@szeredi.hu>, Nadia Yvette Chambers <nyc@holomorphy.com>, Prasad Joshi <prasadjoshi.linux@gmail.com>, Robert Richter <rric@kernel.org>, Ron Minnich <rminnich@sandia.gov>, Tony Luck <tony.luck@intel.com>, Trond Myklebust <trond.myklebust@primarydata.com>, autofs@vger.kernel.org, cluster-devel@redhat.com, jfs-discussion@lists.sourceforge.net, linux-btrfs@vger.kernel.org, linux-efi@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-mm@kvack.org, linux-nfs@vger.kernel.org, linux-nilfs@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-rdma@vger.kernel.org, linux-s390@vger.kernel.org, linux-security-module@vger.kernel.org, linux-usb@vger.kernel.org, logfs@logfs.org, netdev@vger.kernel.org, ocfs2-devel@oss.oracle.com, oprofile-list@lists.sf.net, osd-dev@open-osd.org, selinux@tycho.nsa.gov, v9fs-developer@lists.sourceforge.net

The series is aimed at getting rid of CURRENT_TIME and CURRENT_TIME_SEC macros.
The macros are not y2038 safe. There is no plan to transition them into being
y2038 safe.
ktime_get_* api's can be used in their place. And, these are y2038 safe.

All filesystem timestamps use current_fs_time() for the right granularity
as mentioned in the respective commit texts of patches.

This series also serves as a preparatory series to transition vfs to 64 bit
timestamps as outlined here: https://lkml.org/lkml/2016/2/12/104 .

As per Linus's suggestion in https://lkml.org/lkml/2016/5/24/663 , all the
inode timestamp changes have been squashed into a single patch. Also,
current_fs_time() now is used as a single generic filesystem timestamp api.
Posting all patches together in a bigger series so that the big picture is
clear.

As per the suggestion in https://lwn.net/Articles/672598/ , CURRENT_TIME
macro bug fixes are being handled in a series separate from transitioning
vfs to use 64 bit timestamps.

Some reviewers have requested not to change line wrapping only for the
longer function call names, so checkpatch warnings for such cases are
ignored in the patch series.

Deepa Dinamani (21):
  fs: Replace CURRENT_TIME_SEC with current_fs_time()
  fs: ext4: Use current_fs_time() for inode timestamps
  fs: ubifs: Use current_fs_time() for inode timestamps
  fs: Replace CURRENT_TIME with current_fs_time() for inode timestamps
  fs: jfs: Replace CURRENT_TIME_SEC by current_fs_time()
  fs: udf: Replace CURRENT_TIME with current_fs_time()
  fs: cifs: Replace CURRENT_TIME by current_fs_time()
  fs: cifs: Replace CURRENT_TIME with ktime_get_real_ts()
  fs: cifs: Replace CURRENT_TIME by get_seconds
  fs: f2fs: Use ktime_get_real_seconds for sit_info times
  drivers: staging: lustre: Replace CURRENT_TIME with current_fs_time()
  block: rbd: Replace non inode CURRENT_TIME with current_fs_time()
  fs: ocfs2: Use time64_t to represent orphan scan times
  fs: ocfs2: Replace CURRENT_TIME with ktime_get_real_seconds()
  time: Add time64_to_tm()
  fnic: Use time64_t to represent trace timestamps
  audit: Use timespec64 to represent audit timestamps
  fs: nfs: Make nfs boot time y2038 safe
  libceph: Remove CURRENT_TIME references
  libceph: Replace CURRENT_TIME with ktime_get_real_ts
  time: Delete CURRENT_TIME_SEC and CURRENT_TIME macro

 arch/powerpc/platforms/cell/spufs/inode.c          |  2 +-
 arch/s390/hypfs/inode.c                            |  4 +--
 drivers/block/rbd.c                                |  2 +-
 drivers/infiniband/hw/qib/qib_fs.c                 |  2 +-
 drivers/misc/ibmasm/ibmasmfs.c                     |  2 +-
 drivers/oprofile/oprofilefs.c                      |  2 +-
 drivers/scsi/fnic/fnic_trace.c                     |  4 +--
 drivers/scsi/fnic/fnic_trace.h                     |  2 +-
 drivers/staging/lustre/lustre/llite/llite_lib.c    | 17 ++++++-----
 drivers/staging/lustre/lustre/llite/namei.c        |  4 +--
 drivers/staging/lustre/lustre/mdc/mdc_reint.c      |  6 ++--
 .../lustre/lustre/obdclass/linux/linux-obdo.c      |  6 ++--
 drivers/staging/lustre/lustre/obdclass/obdo.c      |  6 ++--
 drivers/staging/lustre/lustre/osc/osc_io.c         |  2 +-
 drivers/usb/core/devio.c                           | 19 ++++++------
 drivers/usb/gadget/function/f_fs.c                 |  2 +-
 drivers/usb/gadget/legacy/inode.c                  |  2 +-
 fs/9p/vfs_inode.c                                  |  2 +-
 fs/adfs/inode.c                                    |  2 +-
 fs/affs/amigaffs.c                                 |  6 ++--
 fs/affs/inode.c                                    |  2 +-
 fs/afs/inode.c                                     |  3 +-
 fs/autofs4/inode.c                                 |  2 +-
 fs/autofs4/root.c                                  | 19 +++++++-----
 fs/bfs/dir.c                                       | 18 ++++++-----
 fs/btrfs/inode.c                                   |  2 +-
 fs/cifs/cifsencrypt.c                              |  4 ++-
 fs/cifs/cifssmb.c                                  | 10 +++----
 fs/cifs/inode.c                                    | 15 +++++-----
 fs/coda/dir.c                                      |  2 +-
 fs/coda/file.c                                     |  2 +-
 fs/coda/inode.c                                    |  2 +-
 fs/devpts/inode.c                                  |  6 ++--
 fs/efivarfs/inode.c                                |  2 +-
 fs/exofs/dir.c                                     |  9 +++---
 fs/exofs/inode.c                                   |  7 +++--
 fs/exofs/namei.c                                   |  6 ++--
 fs/ext2/acl.c                                      |  2 +-
 fs/ext2/dir.c                                      |  6 ++--
 fs/ext2/ialloc.c                                   |  2 +-
 fs/ext2/inode.c                                    |  4 +--
 fs/ext2/ioctl.c                                    |  5 ++--
 fs/ext2/namei.c                                    |  6 ++--
 fs/ext2/super.c                                    |  2 +-
 fs/ext2/xattr.c                                    |  2 +-
 fs/ext4/acl.c                                      |  2 +-
 fs/ext4/ext4.h                                     |  6 ----
 fs/ext4/extents.c                                  | 10 +++----
 fs/ext4/ialloc.c                                   |  2 +-
 fs/ext4/inline.c                                   |  4 +--
 fs/ext4/inode.c                                    |  6 ++--
 fs/ext4/ioctl.c                                    |  8 ++---
 fs/ext4/namei.c                                    | 24 ++++++++-------
 fs/ext4/super.c                                    |  2 +-
 fs/ext4/xattr.c                                    |  2 +-
 fs/f2fs/dir.c                                      |  8 ++---
 fs/f2fs/file.c                                     |  8 ++---
 fs/f2fs/inline.c                                   |  2 +-
 fs/f2fs/namei.c                                    | 12 ++++----
 fs/f2fs/segment.c                                  |  2 +-
 fs/f2fs/segment.h                                  |  5 ++--
 fs/f2fs/xattr.c                                    |  2 +-
 fs/fat/dir.c                                       |  2 +-
 fs/fat/file.c                                      |  4 +--
 fs/fat/inode.c                                     |  2 +-
 fs/fat/namei_msdos.c                               | 13 ++++----
 fs/fat/namei_vfat.c                                | 10 +++----
 fs/fuse/control.c                                  |  2 +-
 fs/gfs2/bmap.c                                     |  8 ++---
 fs/gfs2/dir.c                                      | 12 ++++----
 fs/gfs2/inode.c                                    |  8 ++---
 fs/gfs2/quota.c                                    |  2 +-
 fs/gfs2/xattr.c                                    |  8 ++---
 fs/hfs/catalog.c                                   |  8 ++---
 fs/hfs/dir.c                                       |  2 +-
 fs/hfs/inode.c                                     |  2 +-
 fs/hfsplus/catalog.c                               |  8 ++---
 fs/hfsplus/dir.c                                   |  6 ++--
 fs/hfsplus/inode.c                                 |  2 +-
 fs/hfsplus/ioctl.c                                 |  2 +-
 fs/hugetlbfs/inode.c                               | 10 +++----
 fs/jffs2/acl.c                                     |  2 +-
 fs/jffs2/fs.c                                      |  2 +-
 fs/jfs/acl.c                                       |  2 +-
 fs/jfs/inode.c                                     |  5 ++--
 fs/jfs/ioctl.c                                     |  4 +--
 fs/jfs/jfs_inode.c                                 |  2 +-
 fs/jfs/namei.c                                     | 35 ++++++++++++----------
 fs/jfs/super.c                                     |  2 +-
 fs/jfs/xattr.c                                     |  2 +-
 fs/libfs.c                                         | 14 ++++-----
 fs/logfs/dir.c                                     |  6 ++--
 fs/logfs/file.c                                    |  2 +-
 fs/logfs/inode.c                                   |  3 +-
 fs/logfs/readwrite.c                               |  4 +--
 fs/minix/bitmap.c                                  |  2 +-
 fs/minix/dir.c                                     | 12 ++++----
 fs/minix/itree_common.c                            |  4 +--
 fs/minix/namei.c                                   |  4 +--
 fs/nfs/client.c                                    |  2 +-
 fs/nfs/netns.h                                     |  2 +-
 fs/nilfs2/dir.c                                    |  6 ++--
 fs/nilfs2/inode.c                                  |  4 +--
 fs/nilfs2/ioctl.c                                  |  2 +-
 fs/nilfs2/namei.c                                  |  6 ++--
 fs/nsfs.c                                          |  5 ++--
 fs/ocfs2/acl.c                                     |  2 +-
 fs/ocfs2/alloc.c                                   |  2 +-
 fs/ocfs2/aops.c                                    |  2 +-
 fs/ocfs2/cluster/heartbeat.c                       |  2 +-
 fs/ocfs2/dir.c                                     |  4 +--
 fs/ocfs2/dlmfs/dlmfs.c                             |  4 +--
 fs/ocfs2/file.c                                    | 12 ++++----
 fs/ocfs2/inode.c                                   |  2 +-
 fs/ocfs2/journal.c                                 |  4 +--
 fs/ocfs2/move_extents.c                            |  2 +-
 fs/ocfs2/namei.c                                   | 17 ++++++-----
 fs/ocfs2/ocfs2.h                                   |  2 +-
 fs/ocfs2/refcounttree.c                            |  4 +--
 fs/ocfs2/super.c                                   |  2 +-
 fs/ocfs2/xattr.c                                   |  2 +-
 fs/omfs/dir.c                                      |  4 +--
 fs/omfs/inode.c                                    |  2 +-
 fs/openpromfs/inode.c                              |  2 +-
 fs/orangefs/file.c                                 |  2 +-
 fs/orangefs/inode.c                                |  2 +-
 fs/orangefs/namei.c                                |  6 ++--
 fs/pipe.c                                          |  5 ++--
 fs/posix_acl.c                                     |  2 +-
 fs/proc/base.c                                     |  2 +-
 fs/proc/inode.c                                    |  4 +--
 fs/proc/proc_sysctl.c                              |  2 +-
 fs/proc/self.c                                     |  2 +-
 fs/proc/thread_self.c                              |  2 +-
 fs/pstore/inode.c                                  |  2 +-
 fs/ramfs/inode.c                                   | 12 ++++----
 fs/reiserfs/inode.c                                |  2 +-
 fs/reiserfs/ioctl.c                                |  4 +--
 fs/reiserfs/namei.c                                | 14 ++++-----
 fs/reiserfs/stree.c                                |  6 ++--
 fs/reiserfs/super.c                                |  2 +-
 fs/reiserfs/xattr.c                                |  2 +-
 fs/reiserfs/xattr_acl.c                            |  2 +-
 fs/sysv/dir.c                                      |  6 ++--
 fs/sysv/ialloc.c                                   |  2 +-
 fs/sysv/itree.c                                    |  4 +--
 fs/sysv/namei.c                                    |  4 +--
 fs/tracefs/inode.c                                 |  2 +-
 fs/ubifs/dir.c                                     | 10 +++----
 fs/ubifs/file.c                                    | 12 ++++----
 fs/ubifs/ioctl.c                                   |  2 +-
 fs/ubifs/misc.h                                    | 10 -------
 fs/ubifs/sb.c                                      | 18 ++++++++---
 fs/ubifs/xattr.c                                   |  6 ++--
 fs/udf/super.c                                     |  4 +--
 fs/ufs/dir.c                                       |  6 ++--
 fs/ufs/ialloc.c                                    |  8 +++--
 fs/ufs/inode.c                                     |  6 ++--
 fs/ufs/namei.c                                     |  6 ++--
 include/linux/audit.h                              |  4 +--
 include/linux/time.h                               | 18 ++++++++---
 ipc/mqueue.c                                       | 21 ++++++-------
 kernel/audit.c                                     | 10 +++----
 kernel/audit.h                                     |  2 +-
 kernel/auditsc.c                                   |  6 ++--
 kernel/bpf/inode.c                                 |  2 +-
 kernel/time/timeconv.c                             | 11 +++----
 mm/shmem.c                                         | 26 ++++++++--------
 net/ceph/messenger.c                               |  6 ++--
 net/ceph/osd_client.c                              |  4 +--
 net/sunrpc/rpc_pipe.c                              |  2 +-
 security/inode.c                                   |  2 +-
 security/selinux/selinuxfs.c                       |  2 +-
 173 files changed, 494 insertions(+), 458 deletions(-)

-- 
1.9.1

Cc: Anna Schumaker <anna.schumaker@netapp.com>
Cc: Anton Vorontsov <anton@enomsg.org>
Cc: Benny Halevy <bhalevy@primarydata.com>
Cc: Boaz Harrosh <ooo@electrozaur.com>
Cc: Changman Lee <cm224.lee@samsung.com>
Cc: Chris Mason <clm@fb.com>
Cc: Colin Cross <ccross@android.com>
Cc: Dave Kleikamp <shaggy@kernel.org>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: David Sterba <dsterba@suse.com>
Cc: Eric Van Hensbergen <ericvh@gmail.com>
Cc: Felipe Balbi <balbi@kernel.org>
Cc: Hugh Dickins <hughd@google.com>
Cc: Ian Kent <raven@themaw.net>
Cc: Jaegeuk Kim <jaegeuk@kernel.org>
Cc: Joern Engel <joern@logfs.org>
Cc: Josef Bacik <jbacik@fb.com>
Cc: Kees Cook <keescook@chromium.org>
Cc: Latchesar Ionkov <lucho@ionkov.net>
Cc: Matt Fleming <matt@codeblueprint.co.uk>
Cc: Matthew Garrett <matthew.garrett@nebula.com>
Cc: Miklos Szeredi <miklos@szeredi.hu>
Cc: Nadia Yvette Chambers <nyc@holomorphy.com>
Cc: Prasad Joshi <prasadjoshi.linux@gmail.com>
Cc: Robert Richter <rric@kernel.org>
Cc: Ron Minnich <rminnich@sandia.gov>
Cc: Tony Luck <tony.luck@intel.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: autofs@vger.kernel.org
Cc: cluster-devel@redhat.com
Cc: jfs-discussion@lists.sourceforge.net
Cc: linux-btrfs@vger.kernel.org
Cc: linux-efi@vger.kernel.org
Cc: linux-f2fs-devel@lists.sourceforge.net
Cc: linux-fsdevel@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
Cc: linux-nfs@vger.kernel.org
Cc: linux-nilfs@vger.kernel.org
Cc: linuxppc-dev@lists.ozlabs.org
Cc: linux-rdma@vger.kernel.org
Cc: linux-s390@vger.kernel.org
Cc: linux-security-module@vger.kernel.org
Cc: linux-usb@vger.kernel.org
Cc: logfs@logfs.org
Cc: netdev@vger.kernel.org
Cc: ocfs2-devel@oss.oracle.com
Cc: oprofile-list@lists.sf.net
Cc: osd-dev@open-osd.org
Cc: selinux@tycho.nsa.gov
Cc: v9fs-developer@lists.sourceforge.net

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
