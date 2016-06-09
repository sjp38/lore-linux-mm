Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id AC08D828E5
	for <linux-mm@kvack.org>; Thu,  9 Jun 2016 01:05:47 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id e189so46654239pfa.2
        for <linux-mm@kvack.org>; Wed, 08 Jun 2016 22:05:47 -0700 (PDT)
Received: from mail-pf0-x243.google.com (mail-pf0-x243.google.com. [2607:f8b0:400e:c00::243])
        by mx.google.com with ESMTPS id f8si5519136pff.71.2016.06.08.22.05.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Jun 2016 22:05:45 -0700 (PDT)
Received: by mail-pf0-x243.google.com with SMTP id c74so2026391pfb.0
        for <linux-mm@kvack.org>; Wed, 08 Jun 2016 22:05:45 -0700 (PDT)
From: Deepa Dinamani <deepa.kernel@gmail.com>
Subject: [PATCH 04/21] fs: Replace CURRENT_TIME with current_fs_time() for inode timestamps
Date: Wed,  8 Jun 2016 22:04:48 -0700
Message-Id: <1465448705-25055-5-git-send-email-deepa.kernel@gmail.com>
In-Reply-To: <1465448705-25055-1-git-send-email-deepa.kernel@gmail.com>
References: <1465448705-25055-1-git-send-email-deepa.kernel@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Arnd Bergmann <arnd@arndb.de>, Thomas Gleixner <tglx@linutronix.de>, Al Viro <viro@zeniv.linux.org.uk>, Linus Torvalds <torvalds@linux-foundation.org>, y2038@lists.linaro.org, Steve French <sfrench@samba.org>, linux-cifs@vger.kernel.org, samba-technical@lists.samba.org, Joern Engel <joern@logfs.org>, Prasad Joshi <prasadjoshi.linux@gmail.com>, logfs@logfs.org, Andrew Morton <akpm@linux-foundation.org>, Julia Lawall <Julia.Lawall@lip6.fr>, David Howells <dhowells@redhat.com>, Firo Yang <firogm@gmail.com>, Jaegeuk Kim <jaegeuk@kernel.org>, Changman Lee <cm224.lee@samsung.com>, Chao Yu <chao2.yu@samsung.com>, linux-f2fs-devel@lists.sourceforge.net, Michal Hocko <mhocko@suse.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "J. Bruce Fields" <bfields@fieldses.org>, Jeff Layton <jlayton@poochiereds.net>, Trond Myklebust <trond.myklebust@primarydata.com>, Anna Schumaker <anna.schumaker@netapp.com>, "David S. Miller" <davem@davemloft.net>, linux-nfs@vger.kernel.org, netdev@vger.kernel.org, Steven Whitehouse <swhiteho@redhat.com>, Bob Peterson <rpeterso@redhat.com>, cluster-devel@redhat.com, Mark Fasheh <mfasheh@suse.com>, Joel Becker <jlbec@evilplan.org>, ocfs2-devel@oss.oracle.com, Anton Vorontsov <anton@enomsg.org>, Colin Cross <ccross@android.com>, Kees Cook <keescook@chromium.org>, Tony Luck <tony.luck@intel.com>, Chris Mason <clm@fb.com>, Josef Bacik <jbacik@fb.com>, David Sterba <dsterba@suse.com>, linux-btrfs@vger.kernel.org, Miklos Szeredi <miklos@szeredi.hu>, fuse-devel@lists.sourceforge.net, Felipe Balbi <balbi@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-usb@vger.kernel.org, Doug Ledford <dledford@redhat.com>, Sean Hefty <sean.hefty@intel.com>, Hal Rosenstock <hal.rosenstock@gmail.com>, linux-rdma@vger.kernel.org, Robert Richter <rric@kernel.org>, oprofile-list@lists.sf.net, Alexei Starovoitov <ast@kernel.org>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, Paul Moore <paul@paul-moore.com>, Stephen Smalley <sds@tycho.nsa.gov>, Eric Paris <eparis@parisplace.org>, selinux@tycho.nsa.gov, James Morris <james.l.morris@oracle.com>, "Serge E. Hallyn" <serge@hallyn.com>, linux-security-module@vger.kernel.org, Eric Van Hensbergen <ericvh@gmail.com>, Ron Minnich <rminnich@sandia.gov>, Latchesar Ionkov <lucho@ionkov.net>, v9fs-developer@lists.sourceforge.net, Ian Kent <raven@themaw.net>, autofs@vger.kernel.org, Matthew Garrett <matthew.garrett@nebula.com>, Jeremy Kerr <jk@ozlabs.org>, Matt Fleming <matt@codeblueprint.co.uk>, linux-efi@vger.kernel.org, Peter Hurley <peter@hurleysoftware.com>, Josh Triplett <josh@joshtriplett.org>, Boaz Harrosh <ooo@electrozaur.com>, Benny Halevy <bhalevy@primarydata.com>, osd-dev@open-osd.org, Mike Marshall <hubcap@omnibond.com>, pvfs2-developers@beowulf-underground.org, Nadia Yvette Chambers <nyc@holomorphy.com>, Dave Kleikamp <shaggy@kernel.org>, jfs-discussion@lists.sourceforge.net, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>, linux-nilfs@vger.kernel.org

CURRENT_TIME macro is not appropriate for filesystems as it
doesn't use the right granularity for filesystem timestamps.
Use current_fs_time() instead.

CURRENT_TIME is also not y2038 safe.

This is also in preparation for the patch that transitions
vfs timestamps to use 64 bit time and hence make them
y2038 safe. As part of the effort current_fs_time() will be
extended to do range checks. Hence, it is necessary for all
file system timestamps to use current_fs_time(). Also,
current_fs_time() will be transitioned along with vfs to be
y2038 safe.

Signed-off-by: Deepa Dinamani <deepa.kernel@gmail.com>
Cc: Steve French <sfrench@samba.org>
Cc: linux-cifs@vger.kernel.org
Cc: samba-technical@lists.samba.org
Cc: Joern Engel <joern@logfs.org>
Cc: Prasad Joshi <prasadjoshi.linux@gmail.com>
Cc: logfs@logfs.org
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Julia Lawall <Julia.Lawall@lip6.fr>
Cc: David Howells <dhowells@redhat.com>
Cc: Firo Yang <firogm@gmail.com>
Cc: Jaegeuk Kim <jaegeuk@kernel.org>
Cc: Changman Lee <cm224.lee@samsung.com>
Cc: Chao Yu <chao2.yu@samsung.com>
Cc: linux-f2fs-devel@lists.sourceforge.net
Cc: Michal Hocko <mhocko@suse.com>
Cc: Konstantin Khlebnikov <koct9i@gmail.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Jeff Layton <jlayton@poochiereds.net>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Anna Schumaker <anna.schumaker@netapp.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: linux-nfs@vger.kernel.org
Cc: netdev@vger.kernel.org
Cc: Steven Whitehouse <swhiteho@redhat.com>
Cc: Bob Peterson <rpeterso@redhat.com>
Cc: cluster-devel@redhat.com
Cc: Mark Fasheh <mfasheh@suse.com>
Cc: Joel Becker <jlbec@evilplan.org>
Cc: ocfs2-devel@oss.oracle.com
Cc: Anton Vorontsov <anton@enomsg.org>
Cc: Colin Cross <ccross@android.com>
Cc: Kees Cook <keescook@chromium.org>
Cc: Tony Luck <tony.luck@intel.com>
Cc: Chris Mason <clm@fb.com>
Cc: Josef Bacik <jbacik@fb.com>
Cc: David Sterba <dsterba@suse.com>
Cc: linux-btrfs@vger.kernel.org
Cc: Miklos Szeredi <miklos@szeredi.hu>
Cc: fuse-devel@lists.sourceforge.net
Cc: Felipe Balbi <balbi@kernel.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: linux-usb@vger.kernel.org
Cc: Doug Ledford <dledford@redhat.com>
Cc: Sean Hefty <sean.hefty@intel.com>
Cc: Hal Rosenstock <hal.rosenstock@gmail.com>
Cc: linux-rdma@vger.kernel.org
Cc: Robert Richter <rric@kernel.org>
Cc: oprofile-list@lists.sf.net
Cc: Alexei Starovoitov <ast@kernel.org>
Cc: Hugh Dickins <hughd@google.com>
Cc: linux-mm@kvack.org
Cc: Paul Moore <paul@paul-moore.com>
Cc: Stephen Smalley <sds@tycho.nsa.gov>
Cc: Eric Paris <eparis@parisplace.org>
Cc: selinux@tycho.nsa.gov
Cc: James Morris <james.l.morris@oracle.com>
Cc: "Serge E. Hallyn" <serge@hallyn.com>
Cc: linux-security-module@vger.kernel.org
Cc: Eric Van Hensbergen <ericvh@gmail.com>
Cc: Ron Minnich <rminnich@sandia.gov>
Cc: Latchesar Ionkov <lucho@ionkov.net>
Cc: v9fs-developer@lists.sourceforge.net
Cc: Ian Kent <raven@themaw.net>
Cc: autofs@vger.kernel.org
Cc: Matthew Garrett <matthew.garrett@nebula.com>
Cc: Jeremy Kerr <jk@ozlabs.org>
Cc: Matt Fleming <matt@codeblueprint.co.uk>
Cc: linux-efi@vger.kernel.org
Cc: Peter Hurley <peter@hurleysoftware.com>
Cc: Josh Triplett <josh@joshtriplett.org>
Cc: Boaz Harrosh <ooo@electrozaur.com>
Cc: Benny Halevy <bhalevy@primarydata.com>
Cc: osd-dev@open-osd.org
Cc: Mike Marshall <hubcap@omnibond.com>
Cc: pvfs2-developers@beowulf-underground.org
Cc: Nadia Yvette Chambers <nyc@holomorphy.com>
Cc: Dave Kleikamp <shaggy@kernel.org>
Cc: jfs-discussion@lists.sourceforge.net
Cc: Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>
Cc: linux-nilfs@vger.kernel.org
---
 arch/powerpc/platforms/cell/spufs/inode.c |  2 +-
 arch/s390/hypfs/inode.c                   |  4 ++--
 drivers/infiniband/hw/qib/qib_fs.c        |  2 +-
 drivers/misc/ibmasm/ibmasmfs.c            |  2 +-
 drivers/oprofile/oprofilefs.c             |  2 +-
 drivers/usb/core/devio.c                  | 19 +++++++++--------
 drivers/usb/gadget/function/f_fs.c        |  2 +-
 drivers/usb/gadget/legacy/inode.c         |  2 +-
 fs/9p/vfs_inode.c                         |  2 +-
 fs/adfs/inode.c                           |  2 +-
 fs/autofs4/inode.c                        |  2 +-
 fs/autofs4/root.c                         | 19 ++++++++++-------
 fs/btrfs/inode.c                          |  2 +-
 fs/devpts/inode.c                         |  6 +++---
 fs/efivarfs/inode.c                       |  2 +-
 fs/exofs/dir.c                            |  9 ++++----
 fs/exofs/inode.c                          |  7 ++++---
 fs/exofs/namei.c                          |  6 +++---
 fs/f2fs/dir.c                             |  8 +++----
 fs/f2fs/file.c                            |  8 +++----
 fs/f2fs/inline.c                          |  2 +-
 fs/f2fs/namei.c                           | 12 +++++------
 fs/f2fs/xattr.c                           |  2 +-
 fs/fuse/control.c                         |  2 +-
 fs/gfs2/bmap.c                            |  8 +++----
 fs/gfs2/dir.c                             | 12 +++++------
 fs/gfs2/inode.c                           |  8 +++----
 fs/gfs2/quota.c                           |  2 +-
 fs/gfs2/xattr.c                           |  8 +++----
 fs/hugetlbfs/inode.c                      | 10 ++++-----
 fs/jfs/acl.c                              |  2 +-
 fs/jfs/inode.c                            |  5 +++--
 fs/jfs/jfs_inode.c                        |  2 +-
 fs/jfs/namei.c                            | 35 +++++++++++++++++--------------
 fs/jfs/super.c                            |  2 +-
 fs/jfs/xattr.c                            |  2 +-
 fs/libfs.c                                | 14 ++++++-------
 fs/logfs/dir.c                            |  6 +++---
 fs/logfs/file.c                           |  2 +-
 fs/logfs/inode.c                          |  3 +--
 fs/logfs/readwrite.c                      |  4 ++--
 fs/nilfs2/dir.c                           |  6 +++---
 fs/nilfs2/inode.c                         |  4 ++--
 fs/nilfs2/ioctl.c                         |  2 +-
 fs/nilfs2/namei.c                         |  6 +++---
 fs/nsfs.c                                 |  5 +++--
 fs/ocfs2/acl.c                            |  2 +-
 fs/ocfs2/alloc.c                          |  2 +-
 fs/ocfs2/aops.c                           |  2 +-
 fs/ocfs2/dir.c                            |  4 ++--
 fs/ocfs2/dlmfs/dlmfs.c                    |  4 ++--
 fs/ocfs2/file.c                           | 12 +++++------
 fs/ocfs2/inode.c                          |  2 +-
 fs/ocfs2/move_extents.c                   |  2 +-
 fs/ocfs2/namei.c                          | 17 ++++++++-------
 fs/ocfs2/refcounttree.c                   |  4 ++--
 fs/ocfs2/xattr.c                          |  2 +-
 fs/openpromfs/inode.c                     |  2 +-
 fs/orangefs/file.c                        |  2 +-
 fs/orangefs/inode.c                       |  2 +-
 fs/orangefs/namei.c                       |  6 ++++--
 fs/pipe.c                                 |  5 +++--
 fs/posix_acl.c                            |  2 +-
 fs/proc/base.c                            |  2 +-
 fs/proc/inode.c                           |  4 ++--
 fs/proc/proc_sysctl.c                     |  2 +-
 fs/proc/self.c                            |  2 +-
 fs/proc/thread_self.c                     |  2 +-
 fs/pstore/inode.c                         |  2 +-
 fs/ramfs/inode.c                          | 12 ++++++-----
 fs/tracefs/inode.c                        |  2 +-
 ipc/mqueue.c                              | 21 ++++++++++---------
 kernel/bpf/inode.c                        |  2 +-
 mm/shmem.c                                | 26 ++++++++++++-----------
 net/sunrpc/rpc_pipe.c                     |  2 +-
 security/inode.c                          |  2 +-
 security/selinux/selinuxfs.c              |  2 +-
 77 files changed, 224 insertions(+), 205 deletions(-)

diff --git a/arch/powerpc/platforms/cell/spufs/inode.c b/arch/powerpc/platforms/cell/spufs/inode.c
index 5be15cf..4a07577 100644
--- a/arch/powerpc/platforms/cell/spufs/inode.c
+++ b/arch/powerpc/platforms/cell/spufs/inode.c
@@ -103,7 +103,7 @@ spufs_new_inode(struct super_block *sb, umode_t mode)
 	inode->i_mode = mode;
 	inode->i_uid = current_fsuid();
 	inode->i_gid = current_fsgid();
-	inode->i_atime = inode->i_mtime = inode->i_ctime = CURRENT_TIME;
+	inode->i_atime = inode->i_mtime = inode->i_ctime = current_fs_time(sb);
 out:
 	return inode;
 }
diff --git a/arch/s390/hypfs/inode.c b/arch/s390/hypfs/inode.c
index 255c7ee..3b11a72 100644
--- a/arch/s390/hypfs/inode.c
+++ b/arch/s390/hypfs/inode.c
@@ -51,7 +51,7 @@ static void hypfs_update_update(struct super_block *sb)
 	struct inode *inode = d_inode(sb_info->update_file);
 
 	sb_info->last_update = get_seconds();
-	inode->i_atime = inode->i_mtime = inode->i_ctime = CURRENT_TIME;
+	inode->i_atime = inode->i_mtime = inode->i_ctime = current_fs_time(sb);
 }
 
 /* directory tree removal functions */
@@ -99,7 +99,7 @@ static struct inode *hypfs_make_inode(struct super_block *sb, umode_t mode)
 		ret->i_mode = mode;
 		ret->i_uid = hypfs_info->uid;
 		ret->i_gid = hypfs_info->gid;
-		ret->i_atime = ret->i_mtime = ret->i_ctime = CURRENT_TIME;
+		ret->i_atime = ret->i_mtime = ret->i_ctime = current_fs_time(sb);
 		if (S_ISDIR(mode))
 			set_nlink(ret, 2);
 	}
diff --git a/drivers/infiniband/hw/qib/qib_fs.c b/drivers/infiniband/hw/qib/qib_fs.c
index fcdf3791..117b334 100644
--- a/drivers/infiniband/hw/qib/qib_fs.c
+++ b/drivers/infiniband/hw/qib/qib_fs.c
@@ -64,7 +64,7 @@ static int qibfs_mknod(struct inode *dir, struct dentry *dentry,
 	inode->i_uid = GLOBAL_ROOT_UID;
 	inode->i_gid = GLOBAL_ROOT_GID;
 	inode->i_blocks = 0;
-	inode->i_atime = CURRENT_TIME;
+	inode->i_atime = current_fs_time(inode->i_sb);
 	inode->i_mtime = inode->i_atime;
 	inode->i_ctime = inode->i_atime;
 	inode->i_private = data;
diff --git a/drivers/misc/ibmasm/ibmasmfs.c b/drivers/misc/ibmasm/ibmasmfs.c
index 9c677f3..045d9ac 100644
--- a/drivers/misc/ibmasm/ibmasmfs.c
+++ b/drivers/misc/ibmasm/ibmasmfs.c
@@ -144,7 +144,7 @@ static struct inode *ibmasmfs_make_inode(struct super_block *sb, int mode)
 	if (ret) {
 		ret->i_ino = get_next_ino();
 		ret->i_mode = mode;
-		ret->i_atime = ret->i_mtime = ret->i_ctime = CURRENT_TIME;
+		ret->i_atime = ret->i_mtime = ret->i_ctime = current_fs_time(sb);
 	}
 	return ret;
 }
diff --git a/drivers/oprofile/oprofilefs.c b/drivers/oprofile/oprofilefs.c
index a0e5260..baaca90 100644
--- a/drivers/oprofile/oprofilefs.c
+++ b/drivers/oprofile/oprofilefs.c
@@ -30,7 +30,7 @@ static struct inode *oprofilefs_get_inode(struct super_block *sb, int mode)
 	if (inode) {
 		inode->i_ino = get_next_ino();
 		inode->i_mode = mode;
-		inode->i_atime = inode->i_mtime = inode->i_ctime = CURRENT_TIME;
+		inode->i_atime = inode->i_mtime = inode->i_ctime = current_fs_time(sb);
 	}
 	return inode;
 }
diff --git a/drivers/usb/core/devio.c b/drivers/usb/core/devio.c
index e9f5043..85c12f0 100644
--- a/drivers/usb/core/devio.c
+++ b/drivers/usb/core/devio.c
@@ -2359,6 +2359,7 @@ static long usbdev_do_ioctl(struct file *file, unsigned int cmd,
 {
 	struct usb_dev_state *ps = file->private_data;
 	struct inode *inode = file_inode(file);
+	struct super_block *sb = inode->i_sb;
 	struct usb_device *dev = ps->dev;
 	int ret = -ENOTTY;
 
@@ -2402,21 +2403,21 @@ static long usbdev_do_ioctl(struct file *file, unsigned int cmd,
 		snoop(&dev->dev, "%s: CONTROL\n", __func__);
 		ret = proc_control(ps, p);
 		if (ret >= 0)
-			inode->i_mtime = CURRENT_TIME;
+			inode->i_mtime = current_fs_time(sb);
 		break;
 
 	case USBDEVFS_BULK:
 		snoop(&dev->dev, "%s: BULK\n", __func__);
 		ret = proc_bulk(ps, p);
 		if (ret >= 0)
-			inode->i_mtime = CURRENT_TIME;
+			inode->i_mtime = current_fs_time(sb);
 		break;
 
 	case USBDEVFS_RESETEP:
 		snoop(&dev->dev, "%s: RESETEP\n", __func__);
 		ret = proc_resetep(ps, p);
 		if (ret >= 0)
-			inode->i_mtime = CURRENT_TIME;
+			inode->i_mtime = current_fs_time(sb);
 		break;
 
 	case USBDEVFS_RESET:
@@ -2428,7 +2429,7 @@ static long usbdev_do_ioctl(struct file *file, unsigned int cmd,
 		snoop(&dev->dev, "%s: CLEAR_HALT\n", __func__);
 		ret = proc_clearhalt(ps, p);
 		if (ret >= 0)
-			inode->i_mtime = CURRENT_TIME;
+			inode->i_mtime = current_fs_time(sb);
 		break;
 
 	case USBDEVFS_GETDRIVER:
@@ -2455,7 +2456,7 @@ static long usbdev_do_ioctl(struct file *file, unsigned int cmd,
 		snoop(&dev->dev, "%s: SUBMITURB\n", __func__);
 		ret = proc_submiturb(ps, p);
 		if (ret >= 0)
-			inode->i_mtime = CURRENT_TIME;
+			inode->i_mtime = current_fs_time(sb);
 		break;
 
 #ifdef CONFIG_COMPAT
@@ -2463,14 +2464,14 @@ static long usbdev_do_ioctl(struct file *file, unsigned int cmd,
 		snoop(&dev->dev, "%s: CONTROL32\n", __func__);
 		ret = proc_control_compat(ps, p);
 		if (ret >= 0)
-			inode->i_mtime = CURRENT_TIME;
+			inode->i_mtime = current_fs_time(sb);
 		break;
 
 	case USBDEVFS_BULK32:
 		snoop(&dev->dev, "%s: BULK32\n", __func__);
 		ret = proc_bulk_compat(ps, p);
 		if (ret >= 0)
-			inode->i_mtime = CURRENT_TIME;
+			inode->i_mtime = current_fs_time(sb);
 		break;
 
 	case USBDEVFS_DISCSIGNAL32:
@@ -2482,7 +2483,7 @@ static long usbdev_do_ioctl(struct file *file, unsigned int cmd,
 		snoop(&dev->dev, "%s: SUBMITURB32\n", __func__);
 		ret = proc_submiturb_compat(ps, p);
 		if (ret >= 0)
-			inode->i_mtime = CURRENT_TIME;
+			inode->i_mtime = current_fs_time(sb);
 		break;
 
 	case USBDEVFS_IOCTL32:
@@ -2545,7 +2546,7 @@ static long usbdev_do_ioctl(struct file *file, unsigned int cmd,
  done:
 	usb_unlock_device(dev);
 	if (ret >= 0)
-		inode->i_atime = CURRENT_TIME;
+		inode->i_atime = current_fs_time(sb);
 	return ret;
 }
 
diff --git a/drivers/usb/gadget/function/f_fs.c b/drivers/usb/gadget/function/f_fs.c
index cc33d26..43051cf 100644
--- a/drivers/usb/gadget/function/f_fs.c
+++ b/drivers/usb/gadget/function/f_fs.c
@@ -1077,7 +1077,7 @@ ffs_sb_make_inode(struct super_block *sb, void *data,
 	inode = new_inode(sb);
 
 	if (likely(inode)) {
-		struct timespec current_time = CURRENT_TIME;
+		struct timespec current_time = current_fs_time(sb);
 
 		inode->i_ino	 = get_next_ino();
 		inode->i_mode    = perms->mode;
diff --git a/drivers/usb/gadget/legacy/inode.c b/drivers/usb/gadget/legacy/inode.c
index aa3707b..1540eb6 100644
--- a/drivers/usb/gadget/legacy/inode.c
+++ b/drivers/usb/gadget/legacy/inode.c
@@ -1913,7 +1913,7 @@ gadgetfs_make_inode (struct super_block *sb,
 		inode->i_uid = make_kuid(&init_user_ns, default_uid);
 		inode->i_gid = make_kgid(&init_user_ns, default_gid);
 		inode->i_atime = inode->i_mtime = inode->i_ctime
-				= CURRENT_TIME;
+				= current_fs_time(sb);
 		inode->i_private = data;
 		inode->i_fop = fops;
 	}
diff --git a/fs/9p/vfs_inode.c b/fs/9p/vfs_inode.c
index f4645c5..a1f9f08 100644
--- a/fs/9p/vfs_inode.c
+++ b/fs/9p/vfs_inode.c
@@ -276,7 +276,7 @@ int v9fs_init_inode(struct v9fs_session_info *v9ses,
 	inode_init_owner(inode, NULL, mode);
 	inode->i_blocks = 0;
 	inode->i_rdev = rdev;
-	inode->i_atime = inode->i_mtime = inode->i_ctime = CURRENT_TIME;
+	inode->i_atime = inode->i_mtime = inode->i_ctime = current_fs_time(inode->i_sb);
 	inode->i_mapping->a_ops = &v9fs_addr_operations;
 
 	switch (mode & S_IFMT) {
diff --git a/fs/adfs/inode.c b/fs/adfs/inode.c
index 335055d..c322bdc 100644
--- a/fs/adfs/inode.c
+++ b/fs/adfs/inode.c
@@ -199,7 +199,7 @@ adfs_adfs2unix_time(struct timespec *tv, struct inode *inode)
 	return;
 
  cur_time:
-	*tv = CURRENT_TIME;
+	*tv = current_fs_time(inode->i_sb);
 	return;
 
  too_early:
diff --git a/fs/autofs4/inode.c b/fs/autofs4/inode.c
index 61b2105..06410b1 100644
--- a/fs/autofs4/inode.c
+++ b/fs/autofs4/inode.c
@@ -359,7 +359,7 @@ struct inode *autofs4_get_inode(struct super_block *sb, umode_t mode)
 		inode->i_uid = d_inode(sb->s_root)->i_uid;
 		inode->i_gid = d_inode(sb->s_root)->i_gid;
 	}
-	inode->i_atime = inode->i_mtime = inode->i_ctime = CURRENT_TIME;
+	inode->i_atime = inode->i_mtime = inode->i_ctime = current_fs_time(sb);
 	inode->i_ino = get_next_ino();
 
 	if (S_ISDIR(mode)) {
diff --git a/fs/autofs4/root.c b/fs/autofs4/root.c
index 78bd802..58cb78c 100644
--- a/fs/autofs4/root.c
+++ b/fs/autofs4/root.c
@@ -550,7 +550,8 @@ static int autofs4_dir_symlink(struct inode *dir,
 			       struct dentry *dentry,
 			       const char *symname)
 {
-	struct autofs_sb_info *sbi = autofs4_sbi(dir->i_sb);
+	struct super_block *sb = dir->i_sb;
+	struct autofs_sb_info *sbi = autofs4_sbi(sb);
 	struct autofs_info *ino = autofs4_dentry_ino(dentry);
 	struct autofs_info *p_ino;
 	struct inode *inode;
@@ -574,7 +575,7 @@ static int autofs4_dir_symlink(struct inode *dir,
 
 	strcpy(cp, symname);
 
-	inode = autofs4_get_inode(dir->i_sb, S_IFLNK | 0555);
+	inode = autofs4_get_inode(sb, S_IFLNK | 0555);
 	if (!inode) {
 		kfree(cp);
 		if (!dentry->d_fsdata)
@@ -591,7 +592,7 @@ static int autofs4_dir_symlink(struct inode *dir,
 	if (p_ino && !IS_ROOT(dentry))
 		atomic_inc(&p_ino->count);
 
-	dir->i_mtime = CURRENT_TIME;
+	dir->i_mtime = current_fs_time(sb);
 
 	return 0;
 }
@@ -613,7 +614,8 @@ static int autofs4_dir_symlink(struct inode *dir,
  */
 static int autofs4_dir_unlink(struct inode *dir, struct dentry *dentry)
 {
-	struct autofs_sb_info *sbi = autofs4_sbi(dir->i_sb);
+	struct super_block *sb = dir->i_sb;
+	struct autofs_sb_info *sbi = autofs4_sbi(sb);
 	struct autofs_info *ino = autofs4_dentry_ino(dentry);
 	struct autofs_info *p_ino;
 
@@ -631,7 +633,7 @@ static int autofs4_dir_unlink(struct inode *dir, struct dentry *dentry)
 	d_inode(dentry)->i_size = 0;
 	clear_nlink(d_inode(dentry));
 
-	dir->i_mtime = CURRENT_TIME;
+	dir->i_mtime = current_fs_time(sb);
 
 	spin_lock(&sbi->lookup_lock);
 	__autofs4_add_expiring(dentry);
@@ -732,7 +734,8 @@ static int autofs4_dir_rmdir(struct inode *dir, struct dentry *dentry)
 static int autofs4_dir_mkdir(struct inode *dir,
 			     struct dentry *dentry, umode_t mode)
 {
-	struct autofs_sb_info *sbi = autofs4_sbi(dir->i_sb);
+	struct super_block *sb = dir->i_sb;
+	struct autofs_sb_info *sbi = autofs4_sbi(sb);
 	struct autofs_info *ino = autofs4_dentry_ino(dentry);
 	struct autofs_info *p_ino;
 	struct inode *inode;
@@ -748,7 +751,7 @@ static int autofs4_dir_mkdir(struct inode *dir,
 
 	autofs4_del_active(dentry);
 
-	inode = autofs4_get_inode(dir->i_sb, S_IFDIR | 0555);
+	inode = autofs4_get_inode(sb, S_IFDIR | 0555);
 	if (!inode)
 		return -ENOMEM;
 	d_add(dentry, inode);
@@ -762,7 +765,7 @@ static int autofs4_dir_mkdir(struct inode *dir,
 	if (p_ino && !IS_ROOT(dentry))
 		atomic_inc(&p_ino->count);
 	inc_nlink(dir);
-	dir->i_mtime = CURRENT_TIME;
+	dir->i_mtime = current_fs_time(sb);
 
 	return 0;
 }
diff --git a/fs/btrfs/inode.c b/fs/btrfs/inode.c
index 334b405..929adcb 100644
--- a/fs/btrfs/inode.c
+++ b/fs/btrfs/inode.c
@@ -9426,7 +9426,7 @@ static int btrfs_rename_exchange(struct inode *old_dir,
 	struct btrfs_root *dest = BTRFS_I(new_dir)->root;
 	struct inode *new_inode = new_dentry->d_inode;
 	struct inode *old_inode = old_dentry->d_inode;
-	struct timespec ctime = CURRENT_TIME;
+	struct timespec ctime = current_fs_time(old_dir->i_sb);
 	struct dentry *parent;
 	u64 old_ino = btrfs_ino(old_inode);
 	u64 new_ino = btrfs_ino(new_inode);
diff --git a/fs/devpts/inode.c b/fs/devpts/inode.c
index 0b2954d..3b8762d 100644
--- a/fs/devpts/inode.c
+++ b/fs/devpts/inode.c
@@ -281,7 +281,7 @@ static int mknod_ptmx(struct super_block *sb)
 	}
 
 	inode->i_ino = 2;
-	inode->i_mtime = inode->i_atime = inode->i_ctime = CURRENT_TIME;
+	inode->i_mtime = inode->i_atime = inode->i_ctime = current_fs_time(sb);
 
 	mode = S_IFCHR|opts->ptmxmode;
 	init_special_inode(inode, mode, MKDEV(TTYAUX_MAJOR, 2));
@@ -394,7 +394,7 @@ devpts_fill_super(struct super_block *s, void *data, int silent)
 	if (!inode)
 		goto fail;
 	inode->i_ino = 1;
-	inode->i_mtime = inode->i_atime = inode->i_ctime = CURRENT_TIME;
+	inode->i_mtime = inode->i_atime = inode->i_ctime = current_fs_time(s);
 	inode->i_mode = S_IFDIR | S_IRUGO | S_IXUGO | S_IWUSR;
 	inode->i_op = &simple_dir_inode_operations;
 	inode->i_fop = &simple_dir_operations;
@@ -627,7 +627,7 @@ struct dentry *devpts_pty_new(struct pts_fs_info *fsi, int index, void *priv)
 	inode->i_ino = index + 3;
 	inode->i_uid = opts->setuid ? opts->uid : current_fsuid();
 	inode->i_gid = opts->setgid ? opts->gid : current_fsgid();
-	inode->i_mtime = inode->i_atime = inode->i_ctime = CURRENT_TIME;
+	inode->i_mtime = inode->i_atime = inode->i_ctime = current_fs_time(sb);
 	init_special_inode(inode, S_IFCHR|opts->mode, MKDEV(UNIX98_PTY_SLAVE_MAJOR, index));
 
 	sprintf(s, "%d", index);
diff --git a/fs/efivarfs/inode.c b/fs/efivarfs/inode.c
index 1d73fc6..3cb1bb2 100644
--- a/fs/efivarfs/inode.c
+++ b/fs/efivarfs/inode.c
@@ -24,7 +24,7 @@ struct inode *efivarfs_get_inode(struct super_block *sb,
 	if (inode) {
 		inode->i_ino = get_next_ino();
 		inode->i_mode = mode;
-		inode->i_atime = inode->i_mtime = inode->i_ctime = CURRENT_TIME;
+		inode->i_atime = inode->i_mtime = inode->i_ctime = current_fs_time(sb);
 		inode->i_flags = is_removable ? 0 : S_IMMUTABLE;
 		switch (mode & S_IFMT) {
 		case S_IFREG:
diff --git a/fs/exofs/dir.c b/fs/exofs/dir.c
index f69a1b5..a0bb68d 100644
--- a/fs/exofs/dir.c
+++ b/fs/exofs/dir.c
@@ -416,7 +416,7 @@ int exofs_set_link(struct inode *dir, struct exofs_dir_entry *de,
 	if (likely(!err))
 		err = exofs_commit_chunk(page, pos, len);
 	exofs_put_page(page);
-	dir->i_mtime = dir->i_ctime = CURRENT_TIME;
+	dir->i_mtime = dir->i_ctime = current_fs_time(dir->i_sb);
 	mark_inode_dirty(dir);
 	return err;
 }
@@ -503,7 +503,7 @@ got_it:
 	de->inode_no = cpu_to_le64(inode->i_ino);
 	exofs_set_de_type(de, inode);
 	err = exofs_commit_chunk(page, pos, rec_len);
-	dir->i_mtime = dir->i_ctime = CURRENT_TIME;
+	dir->i_mtime = dir->i_ctime = current_fs_time(dir->i_sb);
 	mark_inode_dirty(dir);
 	sbi->s_numfiles++;
 
@@ -520,7 +520,8 @@ int exofs_delete_entry(struct exofs_dir_entry *dir, struct page *page)
 {
 	struct address_space *mapping = page->mapping;
 	struct inode *inode = mapping->host;
-	struct exofs_sb_info *sbi = inode->i_sb->s_fs_info;
+	struct super_block *sb = inode->i_sb;
+	struct exofs_sb_info *sbi = sb->s_fs_info;
 	char *kaddr = page_address(page);
 	unsigned from = ((char *)dir - kaddr) & ~(exofs_chunk_size(inode)-1);
 	unsigned to = ((char *)dir - kaddr) + le16_to_cpu(dir->rec_len);
@@ -554,7 +555,7 @@ int exofs_delete_entry(struct exofs_dir_entry *dir, struct page *page)
 	dir->inode_no = 0;
 	if (likely(!err))
 		err = exofs_commit_chunk(page, pos, to - from);
-	inode->i_ctime = inode->i_mtime = CURRENT_TIME;
+	inode->i_ctime = inode->i_mtime = current_fs_time(sb);
 	mark_inode_dirty(inode);
 	sbi->s_numfiles--;
 out:
diff --git a/fs/exofs/inode.c b/fs/exofs/inode.c
index 9dc4c6d..d87f798 100644
--- a/fs/exofs/inode.c
+++ b/fs/exofs/inode.c
@@ -1004,10 +1004,11 @@ static inline int exofs_inode_is_fast_symlink(struct inode *inode)
 static int _do_truncate(struct inode *inode, loff_t newsize)
 {
 	struct exofs_i_info *oi = exofs_i(inode);
-	struct exofs_sb_info *sbi = inode->i_sb->s_fs_info;
+	struct super_block *sb = inode->i_sb;
+	struct exofs_sb_info *sbi = sb->s_fs_info;
 	int ret;
 
-	inode->i_mtime = inode->i_ctime = CURRENT_TIME;
+	inode->i_mtime = inode->i_ctime = current_fs_time(sb);
 
 	ret = ore_truncate(&sbi->layout, &oi->oc, (u64)newsize);
 	if (likely(!ret))
@@ -1313,7 +1314,7 @@ struct inode *exofs_new_inode(struct inode *dir, umode_t mode)
 	inode_init_owner(inode, dir, mode);
 	inode->i_ino = sbi->s_nextid++;
 	inode->i_blkbits = EXOFS_BLKSHIFT;
-	inode->i_mtime = inode->i_atime = inode->i_ctime = CURRENT_TIME;
+	inode->i_mtime = inode->i_atime = inode->i_ctime = current_fs_time(sb);
 	oi->i_commit_size = inode->i_size = 0;
 	spin_lock(&sbi->s_next_gen_lock);
 	inode->i_generation = sbi->s_next_generation++;
diff --git a/fs/exofs/namei.c b/fs/exofs/namei.c
index 622a686..9833976 100644
--- a/fs/exofs/namei.c
+++ b/fs/exofs/namei.c
@@ -142,7 +142,7 @@ static int exofs_link(struct dentry *old_dentry, struct inode *dir,
 {
 	struct inode *inode = d_inode(old_dentry);
 
-	inode->i_ctime = CURRENT_TIME;
+	inode->i_ctime = current_fs_time(inode->i_sb);
 	inode_inc_link_count(inode);
 	ihold(inode);
 
@@ -261,7 +261,7 @@ static int exofs_rename(struct inode *old_dir, struct dentry *old_dentry,
 		if (!new_de)
 			goto out_dir;
 		err = exofs_set_link(new_dir, new_de, new_page, old_inode);
-		new_inode->i_ctime = CURRENT_TIME;
+		new_inode->i_ctime = current_fs_time(new_inode->i_sb);
 		if (dir_de)
 			drop_nlink(new_inode);
 		inode_dec_link_count(new_inode);
@@ -275,7 +275,7 @@ static int exofs_rename(struct inode *old_dir, struct dentry *old_dentry,
 			inode_inc_link_count(new_dir);
 	}
 
-	old_inode->i_ctime = CURRENT_TIME;
+	old_inode->i_ctime = current_fs_time(old_inode->i_sb);
 
 	exofs_delete_entry(old_de, old_page);
 	mark_inode_dirty(old_inode);
diff --git a/fs/f2fs/dir.c b/fs/f2fs/dir.c
index f9313f6..217870c 100644
--- a/fs/f2fs/dir.c
+++ b/fs/f2fs/dir.c
@@ -303,7 +303,7 @@ void f2fs_set_link(struct inode *dir, struct f2fs_dir_entry *de,
 	set_de_type(de, inode->i_mode);
 	f2fs_dentry_kunmap(dir, page);
 	set_page_dirty(page);
-	dir->i_mtime = dir->i_ctime = CURRENT_TIME;
+	dir->i_mtime = dir->i_ctime = current_fs_time(dir->i_sb);
 	mark_inode_dirty(dir);
 
 	f2fs_put_page(page, 1);
@@ -461,7 +461,7 @@ void update_parent_metadata(struct inode *dir, struct inode *inode,
 		}
 		clear_inode_flag(F2FS_I(inode), FI_NEW_INODE);
 	}
-	dir->i_mtime = dir->i_ctime = CURRENT_TIME;
+	dir->i_mtime = dir->i_ctime = current_fs_time(dir->i_sb);
 	mark_inode_dirty(dir);
 
 	if (F2FS_I(dir)->i_current_depth != current_depth) {
@@ -681,7 +681,7 @@ void f2fs_drop_nlink(struct inode *dir, struct inode *inode, struct page *page)
 		else
 			update_inode_page(dir);
 	}
-	inode->i_ctime = CURRENT_TIME;
+	inode->i_ctime = current_fs_time(inode->i_sb);
 
 	drop_nlink(inode);
 	if (S_ISDIR(inode->i_mode)) {
@@ -729,7 +729,7 @@ void f2fs_delete_entry(struct f2fs_dir_entry *dentry, struct page *page,
 	kunmap(page); /* kunmap - pair of f2fs_find_entry */
 	set_page_dirty(page);
 
-	dir->i_ctime = dir->i_mtime = CURRENT_TIME;
+	dir->i_ctime = dir->i_mtime = current_fs_time(dir->i_sb);
 
 	if (inode)
 		f2fs_drop_nlink(dir, inode, NULL);
diff --git a/fs/f2fs/file.c b/fs/f2fs/file.c
index f4c0086..2ef8217 100644
--- a/fs/f2fs/file.c
+++ b/fs/f2fs/file.c
@@ -637,7 +637,7 @@ int f2fs_truncate(struct inode *inode, bool lock)
 	if (err)
 		return err;
 
-	inode->i_mtime = inode->i_ctime = CURRENT_TIME;
+	inode->i_mtime = inode->i_ctime = current_fs_time(inode->i_sb);
 	mark_inode_dirty(inode);
 	return 0;
 }
@@ -716,7 +716,7 @@ int f2fs_setattr(struct dentry *dentry, struct iattr *attr)
 				if (err)
 					return err;
 			}
-			inode->i_mtime = inode->i_ctime = CURRENT_TIME;
+			inode->i_mtime = inode->i_ctime = current_fs_time(inode->i_sb);
 		}
 	}
 
@@ -1284,7 +1284,7 @@ static long f2fs_fallocate(struct file *file, int mode,
 	}
 
 	if (!ret) {
-		inode->i_mtime = inode->i_ctime = CURRENT_TIME;
+		inode->i_mtime = inode->i_ctime = current_fs_time(inode->i_sb);
 		mark_inode_dirty(inode);
 		f2fs_update_time(F2FS_I_SB(inode), REQ_TIME);
 	}
@@ -1377,7 +1377,7 @@ static int f2fs_ioc_setflags(struct file *filp, unsigned long arg)
 	inode_unlock(inode);
 
 	f2fs_set_inode_flags(inode);
-	inode->i_ctime = CURRENT_TIME;
+	inode->i_ctime = current_fs_time(inode->i_sb);
 	mark_inode_dirty(inode);
 out:
 	mnt_drop_write_file(filp);
diff --git a/fs/f2fs/inline.c b/fs/f2fs/inline.c
index a4bb155..30c4e4e 100644
--- a/fs/f2fs/inline.c
+++ b/fs/f2fs/inline.c
@@ -597,7 +597,7 @@ void f2fs_delete_inline_entry(struct f2fs_dir_entry *dentry, struct page *page,
 
 	set_page_dirty(page);
 
-	dir->i_ctime = dir->i_mtime = CURRENT_TIME;
+	dir->i_ctime = dir->i_mtime = current_fs_time(dir->i_sb);
 
 	if (inode)
 		f2fs_drop_nlink(dir, inode, page);
diff --git a/fs/f2fs/namei.c b/fs/f2fs/namei.c
index 324ed38..e6c080e 100644
--- a/fs/f2fs/namei.c
+++ b/fs/f2fs/namei.c
@@ -46,7 +46,7 @@ static struct inode *f2fs_new_inode(struct inode *dir, umode_t mode)
 
 	inode->i_ino = ino;
 	inode->i_blocks = 0;
-	inode->i_mtime = inode->i_atime = inode->i_ctime = CURRENT_TIME;
+	inode->i_mtime = inode->i_atime = inode->i_ctime = current_fs_time(inode->i_sb);
 	inode->i_generation = sbi->s_next_generation++;
 
 	err = insert_inode_locked(inode);
@@ -174,7 +174,7 @@ static int f2fs_link(struct dentry *old_dentry, struct inode *dir,
 
 	f2fs_balance_fs(sbi, true);
 
-	inode->i_ctime = CURRENT_TIME;
+	inode->i_ctime = current_fs_time(inode->i_sb);
 	ihold(inode);
 
 	set_inode_flag(F2FS_I(inode), FI_INC_LINK);
@@ -697,7 +697,7 @@ static int f2fs_rename(struct inode *old_dir, struct dentry *old_dentry,
 
 		f2fs_set_link(new_dir, new_entry, new_page, old_inode);
 
-		new_inode->i_ctime = CURRENT_TIME;
+		new_inode->i_ctime = current_fs_time(new_inode->i_sb);
 		down_write(&F2FS_I(new_inode)->i_sem);
 		if (old_dir_entry)
 			drop_nlink(new_inode);
@@ -756,7 +756,7 @@ static int f2fs_rename(struct inode *old_dir, struct dentry *old_dentry,
 		file_set_enc_name(old_inode);
 	up_write(&F2FS_I(old_inode)->i_sem);
 
-	old_inode->i_ctime = CURRENT_TIME;
+	old_inode->i_ctime = current_fs_time(old_inode->i_sb);
 	mark_inode_dirty(old_inode);
 
 	f2fs_delete_entry(old_entry, old_page, old_dir, NULL);
@@ -906,7 +906,7 @@ static int f2fs_cross_rename(struct inode *old_dir, struct dentry *old_dentry,
 
 	update_inode_page(old_inode);
 
-	old_dir->i_ctime = CURRENT_TIME;
+	old_dir->i_ctime = current_fs_time(old_inode->i_sb);
 	if (old_nlink) {
 		down_write(&F2FS_I(old_dir)->i_sem);
 		if (old_nlink < 0)
@@ -927,7 +927,7 @@ static int f2fs_cross_rename(struct inode *old_dir, struct dentry *old_dentry,
 
 	update_inode_page(new_inode);
 
-	new_dir->i_ctime = CURRENT_TIME;
+	new_dir->i_ctime = current_fs_time(new_inode->i_sb);
 	if (new_nlink) {
 		down_write(&F2FS_I(new_dir)->i_sem);
 		if (new_nlink < 0)
diff --git a/fs/f2fs/xattr.c b/fs/f2fs/xattr.c
index e3decae..cea9bf6 100644
--- a/fs/f2fs/xattr.c
+++ b/fs/f2fs/xattr.c
@@ -541,7 +541,7 @@ static int __f2fs_setxattr(struct inode *inode, int index,
 
 	if (is_inode_flag_set(fi, FI_ACL_MODE)) {
 		inode->i_mode = fi->i_acl_mode;
-		inode->i_ctime = CURRENT_TIME;
+		inode->i_ctime = current_fs_time(inode->i_sb);
 		clear_inode_flag(fi, FI_ACL_MODE);
 	}
 	if (index == F2FS_XATTR_INDEX_ENCRYPTION &&
diff --git a/fs/fuse/control.c b/fs/fuse/control.c
index f863ac6..5e5bb18 100644
--- a/fs/fuse/control.c
+++ b/fs/fuse/control.c
@@ -220,7 +220,7 @@ static struct dentry *fuse_ctl_add_dentry(struct dentry *parent,
 	inode->i_mode = mode;
 	inode->i_uid = fc->user_id;
 	inode->i_gid = fc->group_id;
-	inode->i_atime = inode->i_mtime = inode->i_ctime = CURRENT_TIME;
+	inode->i_atime = inode->i_mtime = inode->i_ctime = current_fs_time(fuse_control_sb);
 	/* setting ->i_op to NULL is not allowed */
 	if (iop)
 		inode->i_op = iop;
diff --git a/fs/gfs2/bmap.c b/fs/gfs2/bmap.c
index 24ce1cd..277e6f2 100644
--- a/fs/gfs2/bmap.c
+++ b/fs/gfs2/bmap.c
@@ -835,7 +835,7 @@ static int do_strip(struct gfs2_inode *ip, struct buffer_head *dibh,
 	gfs2_quota_change(ip, -(s64)btotal, ip->i_inode.i_uid,
 			  ip->i_inode.i_gid);
 
-	ip->i_inode.i_mtime = ip->i_inode.i_ctime = CURRENT_TIME;
+	ip->i_inode.i_mtime = ip->i_inode.i_ctime = current_fs_time(ip->i_inode.i_sb);
 
 	gfs2_dinode_out(ip, dibh->b_data);
 
@@ -1062,7 +1062,7 @@ static int trunc_start(struct inode *inode, u64 oldsize, u64 newsize)
 	}
 
 	i_size_write(inode, newsize);
-	ip->i_inode.i_mtime = ip->i_inode.i_ctime = CURRENT_TIME;
+	ip->i_inode.i_mtime = ip->i_inode.i_ctime = current_fs_time(ip->i_inode.i_sb);
 	gfs2_dinode_out(ip, dibh->b_data);
 
 	if (journaled)
@@ -1141,7 +1141,7 @@ static int trunc_end(struct gfs2_inode *ip)
 		gfs2_buffer_clear_tail(dibh, sizeof(struct gfs2_dinode));
 		gfs2_ordered_del_inode(ip);
 	}
-	ip->i_inode.i_mtime = ip->i_inode.i_ctime = CURRENT_TIME;
+	ip->i_inode.i_mtime = ip->i_inode.i_ctime = current_fs_time(ip->i_inode.i_sb);
 	ip->i_diskflags &= ~GFS2_DIF_TRUNC_IN_PROG;
 
 	gfs2_trans_add_meta(ip->i_gl, dibh);
@@ -1251,7 +1251,7 @@ static int do_grow(struct inode *inode, u64 size)
 		goto do_end_trans;
 
 	i_size_write(inode, size);
-	ip->i_inode.i_mtime = ip->i_inode.i_ctime = CURRENT_TIME;
+	ip->i_inode.i_mtime = ip->i_inode.i_ctime = current_fs_time(ip->i_inode.i_sb);
 	gfs2_trans_add_meta(ip->i_gl, dibh);
 	gfs2_dinode_out(ip, dibh->b_data);
 	brelse(dibh);
diff --git a/fs/gfs2/dir.c b/fs/gfs2/dir.c
index 271d939..ad2f43d 100644
--- a/fs/gfs2/dir.c
+++ b/fs/gfs2/dir.c
@@ -135,7 +135,7 @@ static int gfs2_dir_write_stuffed(struct gfs2_inode *ip, const char *buf,
 	memcpy(dibh->b_data + offset + sizeof(struct gfs2_dinode), buf, size);
 	if (ip->i_inode.i_size < offset + size)
 		i_size_write(&ip->i_inode, offset + size);
-	ip->i_inode.i_mtime = ip->i_inode.i_ctime = CURRENT_TIME;
+	ip->i_inode.i_mtime = ip->i_inode.i_ctime = current_fs_time(ip->i_inode.i_sb);
 	gfs2_dinode_out(ip, dibh->b_data);
 
 	brelse(dibh);
@@ -233,7 +233,7 @@ out:
 
 	if (ip->i_inode.i_size < offset + copied)
 		i_size_write(&ip->i_inode, offset + copied);
-	ip->i_inode.i_mtime = ip->i_inode.i_ctime = CURRENT_TIME;
+	ip->i_inode.i_mtime = ip->i_inode.i_ctime = current_fs_time(ip->i_inode.i_sb);
 
 	gfs2_trans_add_meta(ip->i_gl, dibh);
 	gfs2_dinode_out(ip, dibh->b_data);
@@ -872,7 +872,7 @@ static struct gfs2_leaf *new_leaf(struct inode *inode, struct buffer_head **pbh,
 	struct gfs2_leaf *leaf;
 	struct gfs2_dirent *dent;
 	struct qstr name = { .name = "" };
-	struct timespec tv = CURRENT_TIME;
+	struct timespec tv = current_fs_time(inode->i_sb);
 
 	error = gfs2_alloc_blocks(ip, &bn, &n, 0, NULL);
 	if (error)
@@ -1815,7 +1815,7 @@ int gfs2_dir_add(struct inode *inode, const struct qstr *name,
 			gfs2_inum_out(nip, dent);
 			dent->de_type = cpu_to_be16(IF2DT(nip->i_inode.i_mode));
 			dent->de_rahead = cpu_to_be16(gfs2_inode_ra_len(nip));
-			tv = CURRENT_TIME;
+			tv = current_fs_time(inode->i_sb);
 			if (ip->i_diskflags & GFS2_DIF_EXHASH) {
 				leaf = (struct gfs2_leaf *)bh->b_data;
 				be16_add_cpu(&leaf->lf_entries, 1);
@@ -1877,7 +1877,7 @@ int gfs2_dir_del(struct gfs2_inode *dip, const struct dentry *dentry)
 	const struct qstr *name = &dentry->d_name;
 	struct gfs2_dirent *dent, *prev = NULL;
 	struct buffer_head *bh;
-	struct timespec tv = CURRENT_TIME;
+	struct timespec tv = current_fs_time(dip->i_inode.i_sb);
 
 	/* Returns _either_ the entry (if its first in block) or the
 	   previous entry otherwise */
@@ -1959,7 +1959,7 @@ int gfs2_dir_mvino(struct gfs2_inode *dip, const struct qstr *filename,
 		gfs2_trans_add_meta(dip->i_gl, bh);
 	}
 
-	dip->i_inode.i_mtime = dip->i_inode.i_ctime = CURRENT_TIME;
+	dip->i_inode.i_mtime = dip->i_inode.i_ctime = current_fs_time(dip->i_inode.i_sb);
 	gfs2_dinode_out(dip, bh->b_data);
 	brelse(bh);
 	return 0;
diff --git a/fs/gfs2/inode.c b/fs/gfs2/inode.c
index 21dc784..a8e461a 100644
--- a/fs/gfs2/inode.c
+++ b/fs/gfs2/inode.c
@@ -609,7 +609,7 @@ static int gfs2_create_inode(struct inode *dir, struct dentry *dentry,
 	set_nlink(inode, S_ISDIR(mode) ? 2 : 1);
 	inode->i_rdev = dev;
 	inode->i_size = size;
-	inode->i_atime = inode->i_mtime = inode->i_ctime = CURRENT_TIME;
+	inode->i_atime = inode->i_mtime = inode->i_ctime = current_fs_time(inode->i_sb);
 	gfs2_set_inode_blocks(inode, 1);
 	munge_mode_uid_gid(dip, inode);
 	check_and_update_goal(dip);
@@ -936,7 +936,7 @@ static int gfs2_link(struct dentry *old_dentry, struct inode *dir,
 
 	gfs2_trans_add_meta(ip->i_gl, dibh);
 	inc_nlink(&ip->i_inode);
-	ip->i_inode.i_ctime = CURRENT_TIME;
+	ip->i_inode.i_ctime = current_fs_time(ip->i_inode.i_sb);
 	ihold(inode);
 	d_instantiate(dentry, inode);
 	mark_inode_dirty(inode);
@@ -1020,7 +1020,7 @@ static int gfs2_unlink_inode(struct gfs2_inode *dip,
 		return error;
 
 	ip->i_entries = 0;
-	inode->i_ctime = CURRENT_TIME;
+	inode->i_ctime = current_fs_time(inode->i_sb);
 	if (S_ISDIR(inode->i_mode))
 		clear_nlink(inode);
 	else
@@ -1283,7 +1283,7 @@ static int update_moved_ino(struct gfs2_inode *ip, struct gfs2_inode *ndip,
 	error = gfs2_meta_inode_buffer(ip, &dibh);
 	if (error)
 		return error;
-	ip->i_inode.i_ctime = CURRENT_TIME;
+	ip->i_inode.i_ctime = current_fs_time(ip->i_inode.i_sb);
 	gfs2_trans_add_meta(ip->i_gl, dibh);
 	gfs2_dinode_out(ip, dibh->b_data);
 	brelse(dibh);
diff --git a/fs/gfs2/quota.c b/fs/gfs2/quota.c
index ce7d69a..be52831 100644
--- a/fs/gfs2/quota.c
+++ b/fs/gfs2/quota.c
@@ -854,7 +854,7 @@ static int gfs2_adjust_quota(struct gfs2_inode *ip, loff_t loc,
 		size = loc + sizeof(struct gfs2_quota);
 		if (size > inode->i_size)
 			i_size_write(inode, size);
-		inode->i_mtime = inode->i_atime = CURRENT_TIME;
+		inode->i_mtime = inode->i_atime = current_fs_time(inode->i_sb);
 		mark_inode_dirty(inode);
 		set_bit(QDF_REFRESH, &qd->qd_flags);
 	}
diff --git a/fs/gfs2/xattr.c b/fs/gfs2/xattr.c
index 3a28535..67b114a 100644
--- a/fs/gfs2/xattr.c
+++ b/fs/gfs2/xattr.c
@@ -309,7 +309,7 @@ static int ea_dealloc_unstuffed(struct gfs2_inode *ip, struct buffer_head *bh,
 
 	error = gfs2_meta_inode_buffer(ip, &dibh);
 	if (!error) {
-		ip->i_inode.i_ctime = CURRENT_TIME;
+		ip->i_inode.i_ctime = current_fs_time(ip->i_inode.i_sb);
 		gfs2_trans_add_meta(ip->i_gl, dibh);
 		gfs2_dinode_out(ip, dibh->b_data);
 		brelse(dibh);
@@ -775,7 +775,7 @@ static int ea_alloc_skeleton(struct gfs2_inode *ip, struct gfs2_ea_request *er,
 
 	error = gfs2_meta_inode_buffer(ip, &dibh);
 	if (!error) {
-		ip->i_inode.i_ctime = CURRENT_TIME;
+		ip->i_inode.i_ctime = current_fs_time(ip->i_inode.i_sb);
 		gfs2_trans_add_meta(ip->i_gl, dibh);
 		gfs2_dinode_out(ip, dibh->b_data);
 		brelse(dibh);
@@ -910,7 +910,7 @@ static int ea_set_simple_noalloc(struct gfs2_inode *ip, struct buffer_head *bh,
 	error = gfs2_meta_inode_buffer(ip, &dibh);
 	if (error)
 		goto out;
-	ip->i_inode.i_ctime = CURRENT_TIME;
+	ip->i_inode.i_ctime = current_fs_time(ip->i_inode.i_sb);
 	gfs2_trans_add_meta(ip->i_gl, dibh);
 	gfs2_dinode_out(ip, dibh->b_data);
 	brelse(dibh);
@@ -1133,7 +1133,7 @@ static int ea_remove_stuffed(struct gfs2_inode *ip, struct gfs2_ea_location *el)
 
 	error = gfs2_meta_inode_buffer(ip, &dibh);
 	if (!error) {
-		ip->i_inode.i_ctime = CURRENT_TIME;
+		ip->i_inode.i_ctime = current_fs_time(ip->i_inode.i_sb);
 		gfs2_trans_add_meta(ip->i_gl, dibh);
 		gfs2_dinode_out(ip, dibh->b_data);
 		brelse(dibh);
diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index 4ea71eb..601e384 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -657,7 +657,7 @@ static long hugetlbfs_fallocate(struct file *file, int mode, loff_t offset,
 
 	if (!(mode & FALLOC_FL_KEEP_SIZE) && offset + len > inode->i_size)
 		i_size_write(inode, offset + len);
-	inode->i_ctime = CURRENT_TIME;
+	inode->i_ctime = current_fs_time(inode->i_sb);
 out:
 	inode_unlock(inode);
 	return error;
@@ -702,7 +702,7 @@ static struct inode *hugetlbfs_get_root(struct super_block *sb,
 		inode->i_mode = S_IFDIR | config->mode;
 		inode->i_uid = config->uid;
 		inode->i_gid = config->gid;
-		inode->i_atime = inode->i_mtime = inode->i_ctime = CURRENT_TIME;
+		inode->i_atime = inode->i_mtime = inode->i_ctime = current_fs_time(sb);
 		info = HUGETLBFS_I(inode);
 		mpol_shared_policy_init(&info->policy, NULL);
 		inode->i_op = &hugetlbfs_dir_inode_operations;
@@ -741,7 +741,7 @@ static struct inode *hugetlbfs_get_inode(struct super_block *sb,
 		lockdep_set_class(&inode->i_mapping->i_mmap_rwsem,
 				&hugetlbfs_i_mmap_rwsem_key);
 		inode->i_mapping->a_ops = &hugetlbfs_aops;
-		inode->i_atime = inode->i_mtime = inode->i_ctime = CURRENT_TIME;
+		inode->i_atime = inode->i_mtime = inode->i_ctime = current_fs_time(sb);
 		inode->i_mapping->private_data = resv_map;
 		info = HUGETLBFS_I(inode);
 		/*
@@ -790,7 +790,7 @@ static int hugetlbfs_mknod(struct inode *dir,
 
 	inode = hugetlbfs_get_inode(dir->i_sb, dir, mode, dev);
 	if (inode) {
-		dir->i_ctime = dir->i_mtime = CURRENT_TIME;
+		dir->i_ctime = dir->i_mtime = current_fs_time(dir->i_sb);
 		d_instantiate(dentry, inode);
 		dget(dentry);	/* Extra count - pin the dentry in core */
 		error = 0;
@@ -827,7 +827,7 @@ static int hugetlbfs_symlink(struct inode *dir,
 		} else
 			iput(inode);
 	}
-	dir->i_ctime = dir->i_mtime = CURRENT_TIME;
+	dir->i_ctime = dir->i_mtime = current_fs_time(dir->i_sb);
 
 	return error;
 }
diff --git a/fs/jfs/acl.c b/fs/jfs/acl.c
index 21fa92b..aab09d2 100644
--- a/fs/jfs/acl.c
+++ b/fs/jfs/acl.c
@@ -81,7 +81,7 @@ static int __jfs_set_acl(tid_t tid, struct inode *inode, int type,
 			rc = posix_acl_equiv_mode(acl, &inode->i_mode);
 			if (rc < 0)
 				return rc;
-			inode->i_ctime = CURRENT_TIME;
+			inode->i_ctime = current_fs_time(inode->i_sb);
 			mark_inode_dirty(inode);
 			if (rc == 0)
 				acl = NULL;
diff --git a/fs/jfs/inode.c b/fs/jfs/inode.c
index ad3e7b1..daa912c 100644
--- a/fs/jfs/inode.c
+++ b/fs/jfs/inode.c
@@ -374,6 +374,7 @@ const struct address_space_operations jfs_aops = {
  */
 void jfs_truncate_nolock(struct inode *ip, loff_t length)
 {
+	struct super_block *sb = ip->i_sb;
 	loff_t newsize;
 	tid_t tid;
 
@@ -385,7 +386,7 @@ void jfs_truncate_nolock(struct inode *ip, loff_t length)
 	}
 
 	do {
-		tid = txBegin(ip->i_sb, 0);
+		tid = txBegin(sb, 0);
 
 		/*
 		 * The commit_mutex cannot be taken before txBegin.
@@ -403,7 +404,7 @@ void jfs_truncate_nolock(struct inode *ip, loff_t length)
 			break;
 		}
 
-		ip->i_mtime = ip->i_ctime = CURRENT_TIME;
+		ip->i_mtime = ip->i_ctime = current_fs_time(sb);
 		mark_inode_dirty(ip);
 
 		txCommit(tid, 1, &ip, 0);
diff --git a/fs/jfs/jfs_inode.c b/fs/jfs/jfs_inode.c
index 5e33cb9..5e5e4a6 100644
--- a/fs/jfs/jfs_inode.c
+++ b/fs/jfs/jfs_inode.c
@@ -131,7 +131,7 @@ struct inode *ialloc(struct inode *parent, umode_t mode)
 	jfs_inode->mode2 |= inode->i_mode;
 
 	inode->i_blocks = 0;
-	inode->i_mtime = inode->i_atime = inode->i_ctime = CURRENT_TIME;
+	inode->i_mtime = inode->i_atime = inode->i_ctime = current_fs_time(sb);
 	jfs_inode->otime = inode->i_ctime.tv_sec;
 	inode->i_generation = JFS_SBI(sb)->gengen++;
 
diff --git a/fs/jfs/namei.c b/fs/jfs/namei.c
index 539dedd..6a5e5d2 100644
--- a/fs/jfs/namei.c
+++ b/fs/jfs/namei.c
@@ -162,7 +162,7 @@ static int jfs_create(struct inode *dip, struct dentry *dentry, umode_t mode,
 
 	mark_inode_dirty(ip);
 
-	dip->i_ctime = dip->i_mtime = CURRENT_TIME;
+	dip->i_ctime = dip->i_mtime = current_fs_time(dip->i_sb);
 
 	mark_inode_dirty(dip);
 
@@ -298,7 +298,7 @@ static int jfs_mkdir(struct inode *dip, struct dentry *dentry, umode_t mode)
 
 	/* update parent directory inode */
 	inc_nlink(dip);		/* for '..' from child directory */
-	dip->i_ctime = dip->i_mtime = CURRENT_TIME;
+	dip->i_ctime = dip->i_mtime = current_fs_time(dip->i_sb);
 	mark_inode_dirty(dip);
 
 	rc = txCommit(tid, 2, &iplist[0], 0);
@@ -353,6 +353,7 @@ static int jfs_rmdir(struct inode *dip, struct dentry *dentry)
 	struct inode *ip = d_inode(dentry);
 	ino_t ino;
 	struct component_name dname;
+	struct super_block *sb = dip->i_sb;
 	struct inode *iplist[2];
 	struct tblock *tblk;
 
@@ -376,7 +377,7 @@ static int jfs_rmdir(struct inode *dip, struct dentry *dentry)
 		goto out;
 	}
 
-	tid = txBegin(dip->i_sb, 0);
+	tid = txBegin(sb, 0);
 
 	mutex_lock_nested(&JFS_IP(dip)->commit_mutex, COMMIT_MUTEX_PARENT);
 	mutex_lock_nested(&JFS_IP(ip)->commit_mutex, COMMIT_MUTEX_CHILD);
@@ -406,7 +407,7 @@ static int jfs_rmdir(struct inode *dip, struct dentry *dentry)
 	/* update parent directory's link count corresponding
 	 * to ".." entry of the target directory deleted
 	 */
-	dip->i_ctime = dip->i_mtime = CURRENT_TIME;
+	dip->i_ctime = dip->i_mtime = current_fs_time(sb);
 	inode_dec_link_count(dip);
 
 	/*
@@ -483,6 +484,7 @@ static int jfs_unlink(struct inode *dip, struct dentry *dentry)
 	struct inode *ip = d_inode(dentry);
 	ino_t ino;
 	struct component_name dname;	/* object name */
+	struct super_block *sb = dip->i_sb;
 	struct inode *iplist[2];
 	struct tblock *tblk;
 	s64 new_size = 0;
@@ -503,7 +505,7 @@ static int jfs_unlink(struct inode *dip, struct dentry *dentry)
 
 	IWRITE_LOCK(ip, RDWRLOCK_NORMAL);
 
-	tid = txBegin(dip->i_sb, 0);
+	tid = txBegin(sb, 0);
 
 	mutex_lock_nested(&JFS_IP(dip)->commit_mutex, COMMIT_MUTEX_PARENT);
 	mutex_lock_nested(&JFS_IP(ip)->commit_mutex, COMMIT_MUTEX_CHILD);
@@ -528,7 +530,7 @@ static int jfs_unlink(struct inode *dip, struct dentry *dentry)
 
 	ASSERT(ip->i_nlink);
 
-	ip->i_ctime = dip->i_ctime = dip->i_mtime = CURRENT_TIME;
+	ip->i_ctime = dip->i_ctime = dip->i_mtime = current_fs_time(sb);
 	mark_inode_dirty(dip);
 
 	/* update target's inode */
@@ -576,7 +578,7 @@ static int jfs_unlink(struct inode *dip, struct dentry *dentry)
 	mutex_unlock(&JFS_IP(dip)->commit_mutex);
 
 	while (new_size && (rc == 0)) {
-		tid = txBegin(dip->i_sb, 0);
+		tid = txBegin(sb, 0);
 		mutex_lock(&JFS_IP(ip)->commit_mutex);
 		new_size = xtTruncate_pmap(tid, ip, new_size);
 		if (new_size < 0) {
@@ -806,6 +808,7 @@ static int jfs_link(struct dentry *old_dentry,
 	struct inode *ip = d_inode(old_dentry);
 	ino_t ino;
 	struct component_name dname;
+	struct super_block *sb = ip->i_sb;
 	struct btstack btstack;
 	struct inode *iplist[2];
 
@@ -815,7 +818,7 @@ static int jfs_link(struct dentry *old_dentry,
 	if (rc)
 		goto out;
 
-	tid = txBegin(ip->i_sb, 0);
+	tid = txBegin(sb, 0);
 
 	mutex_lock_nested(&JFS_IP(dir)->commit_mutex, COMMIT_MUTEX_PARENT);
 	mutex_lock_nested(&JFS_IP(ip)->commit_mutex, COMMIT_MUTEX_CHILD);
@@ -838,8 +841,7 @@ static int jfs_link(struct dentry *old_dentry,
 
 	/* update object inode */
 	inc_nlink(ip);		/* for new link */
-	ip->i_ctime = CURRENT_TIME;
-	dir->i_ctime = dir->i_mtime = CURRENT_TIME;
+	ip->i_ctime = dir->i_ctime = dir->i_mtime = current_fs_time(sb);
 	mark_inode_dirty(dir);
 	ihold(ip);
 
@@ -1039,7 +1041,7 @@ static int jfs_symlink(struct inode *dip, struct dentry *dentry,
 
 	mark_inode_dirty(ip);
 
-	dip->i_ctime = dip->i_mtime = CURRENT_TIME;
+	dip->i_ctime = dip->i_mtime = current_fs_time(dip->i_sb);
 	mark_inode_dirty(dip);
 	/*
 	 * commit update of parent directory and link object
@@ -1215,7 +1217,7 @@ static int jfs_rename(struct inode *old_dir, struct dentry *old_dentry,
 			tblk->xflag |= COMMIT_DELETE;
 			tblk->u.ip = new_ip;
 		} else {
-			new_ip->i_ctime = CURRENT_TIME;
+			new_ip->i_ctime = current_fs_time(new_ip->i_sb);
 			mark_inode_dirty(new_ip);
 		}
 	} else {
@@ -1278,7 +1280,7 @@ static int jfs_rename(struct inode *old_dir, struct dentry *old_dentry,
 	/*
 	 * Update ctime on changed/moved inodes & mark dirty
 	 */
-	old_ip->i_ctime = CURRENT_TIME;
+	old_ip->i_ctime = current_fs_time(old_ip->i_sb);
 	mark_inode_dirty(old_ip);
 
 	new_dir->i_ctime = new_dir->i_mtime = current_fs_time(new_dir->i_sb);
@@ -1293,7 +1295,7 @@ static int jfs_rename(struct inode *old_dir, struct dentry *old_dentry,
 
 	if (old_dir != new_dir) {
 		iplist[ipcount++] = new_dir;
-		old_dir->i_ctime = old_dir->i_mtime = CURRENT_TIME;
+		old_dir->i_ctime = old_dir->i_mtime = current_fs_time(old_ip->i_sb);
 		mark_inode_dirty(old_dir);
 	}
 
@@ -1366,6 +1368,7 @@ static int jfs_mknod(struct inode *dir, struct dentry *dentry,
 	struct jfs_inode_info *jfs_ip;
 	struct btstack btstack;
 	struct component_name dname;
+	struct super_block *sb = dir->i_sb;
 	ino_t ino;
 	struct inode *ip;
 	struct inode *iplist[2];
@@ -1389,7 +1392,7 @@ static int jfs_mknod(struct inode *dir, struct dentry *dentry,
 	}
 	jfs_ip = JFS_IP(ip);
 
-	tid = txBegin(dir->i_sb, 0);
+	tid = txBegin(sb, 0);
 
 	mutex_lock_nested(&JFS_IP(dir)->commit_mutex, COMMIT_MUTEX_PARENT);
 	mutex_lock_nested(&JFS_IP(ip)->commit_mutex, COMMIT_MUTEX_CHILD);
@@ -1426,7 +1429,7 @@ static int jfs_mknod(struct inode *dir, struct dentry *dentry,
 
 	mark_inode_dirty(ip);
 
-	dir->i_ctime = dir->i_mtime = CURRENT_TIME;
+	dir->i_ctime = dir->i_mtime = current_fs_time(sb);
 
 	mark_inode_dirty(dir);
 
diff --git a/fs/jfs/super.c b/fs/jfs/super.c
index cec8814..d79a2e3 100644
--- a/fs/jfs/super.c
+++ b/fs/jfs/super.c
@@ -830,7 +830,7 @@ out:
 	if (inode->i_size < off+len-towrite)
 		i_size_write(inode, off+len-towrite);
 	inode->i_version++;
-	inode->i_mtime = inode->i_ctime = CURRENT_TIME;
+	inode->i_mtime = inode->i_ctime = current_fs_time(sb);
 	mark_inode_dirty(inode);
 	inode_unlock(inode);
 	return len - towrite;
diff --git a/fs/jfs/xattr.c b/fs/jfs/xattr.c
index 0bf3c33..b1a3409 100644
--- a/fs/jfs/xattr.c
+++ b/fs/jfs/xattr.c
@@ -658,7 +658,7 @@ static int ea_put(tid_t tid, struct inode *inode, struct ea_buffer *ea_buf,
 	if (old_blocks)
 		dquot_free_block(inode, old_blocks);
 
-	inode->i_ctime = CURRENT_TIME;
+	inode->i_ctime = current_fs_time(inode->i_sb);
 
 	return 0;
 }
diff --git a/fs/libfs.c b/fs/libfs.c
index 3db2721..d811901 100644
--- a/fs/libfs.c
+++ b/fs/libfs.c
@@ -234,7 +234,7 @@ struct dentry *mount_pseudo(struct file_system_type *fs_type, char *name,
 	 */
 	root->i_ino = 1;
 	root->i_mode = S_IFDIR | S_IRUSR | S_IWUSR;
-	root->i_atime = root->i_mtime = root->i_ctime = CURRENT_TIME;
+	root->i_atime = root->i_mtime = root->i_ctime = current_fs_time(s);
 	dentry = __d_alloc(s, &d_name);
 	if (!dentry) {
 		iput(root);
@@ -264,7 +264,7 @@ int simple_link(struct dentry *old_dentry, struct inode *dir, struct dentry *den
 {
 	struct inode *inode = d_inode(old_dentry);
 
-	inode->i_ctime = dir->i_ctime = dir->i_mtime = CURRENT_TIME;
+	inode->i_ctime = dir->i_ctime = dir->i_mtime = current_fs_time(dir->i_sb);
 	inc_nlink(inode);
 	ihold(inode);
 	dget(dentry);
@@ -298,7 +298,7 @@ int simple_unlink(struct inode *dir, struct dentry *dentry)
 {
 	struct inode *inode = d_inode(dentry);
 
-	inode->i_ctime = dir->i_ctime = dir->i_mtime = CURRENT_TIME;
+	inode->i_ctime = dir->i_ctime = dir->i_mtime = current_fs_time(dir->i_sb);
 	drop_nlink(inode);
 	dput(dentry);
 	return 0;
@@ -338,7 +338,7 @@ int simple_rename(struct inode *old_dir, struct dentry *old_dentry,
 	}
 
 	old_dir->i_ctime = old_dir->i_mtime = new_dir->i_ctime =
-		new_dir->i_mtime = inode->i_ctime = CURRENT_TIME;
+		new_dir->i_mtime = inode->i_ctime = current_fs_time(inode->i_sb);
 
 	return 0;
 }
@@ -489,7 +489,7 @@ int simple_fill_super(struct super_block *s, unsigned long magic,
 	 */
 	inode->i_ino = 1;
 	inode->i_mode = S_IFDIR | 0755;
-	inode->i_atime = inode->i_mtime = inode->i_ctime = CURRENT_TIME;
+	inode->i_atime = inode->i_mtime = inode->i_ctime = current_fs_time(s);
 	inode->i_op = &simple_dir_inode_operations;
 	inode->i_fop = &simple_dir_operations;
 	set_nlink(inode, 2);
@@ -515,7 +515,7 @@ int simple_fill_super(struct super_block *s, unsigned long magic,
 			goto out;
 		}
 		inode->i_mode = S_IFREG | files->mode;
-		inode->i_atime = inode->i_mtime = inode->i_ctime = CURRENT_TIME;
+		inode->i_atime = inode->i_mtime = inode->i_ctime = current_fs_time(s);
 		inode->i_fop = files->ops;
 		inode->i_ino = i;
 		d_add(dentry, inode);
@@ -1061,7 +1061,7 @@ struct inode *alloc_anon_inode(struct super_block *s)
 	inode->i_uid = current_fsuid();
 	inode->i_gid = current_fsgid();
 	inode->i_flags |= S_PRIVATE;
-	inode->i_atime = inode->i_mtime = inode->i_ctime = CURRENT_TIME;
+	inode->i_atime = inode->i_mtime = inode->i_ctime = current_fs_time(s);
 	return inode;
 }
 EXPORT_SYMBOL(alloc_anon_inode);
diff --git a/fs/logfs/dir.c b/fs/logfs/dir.c
index 2d5336b..aa74d0f 100644
--- a/fs/logfs/dir.c
+++ b/fs/logfs/dir.c
@@ -226,7 +226,7 @@ static int logfs_unlink(struct inode *dir, struct dentry *dentry)
 	ta->state = UNLINK_1;
 	ta->ino = inode->i_ino;
 
-	inode->i_ctime = dir->i_ctime = dir->i_mtime = CURRENT_TIME;
+	inode->i_ctime = dir->i_ctime = dir->i_mtime = current_fs_time(dir->i_sb);
 
 	page = logfs_get_dd_page(dir, dentry);
 	if (!page) {
@@ -540,7 +540,7 @@ static int logfs_link(struct dentry *old_dentry, struct inode *dir,
 {
 	struct inode *inode = d_inode(old_dentry);
 
-	inode->i_ctime = dir->i_ctime = dir->i_mtime = CURRENT_TIME;
+	inode->i_ctime = dir->i_ctime = dir->i_mtime = current_fs_time(dir->i_sb);
 	ihold(inode);
 	inc_nlink(inode);
 	mark_inode_dirty_sync(inode);
@@ -573,7 +573,7 @@ static int logfs_delete_dd(struct inode *dir, loff_t pos)
 	 * (crc-protected) journal.
 	 */
 	BUG_ON(beyond_eof(dir, pos));
-	dir->i_ctime = dir->i_mtime = CURRENT_TIME;
+	dir->i_ctime = dir->i_mtime = current_fs_time(dir->i_sb);
 	log_dir(" Delete dentry (%lx, %llx)\n", dir->i_ino, pos);
 	return logfs_delete(dir, pos, NULL);
 }
diff --git a/fs/logfs/file.c b/fs/logfs/file.c
index f01ddfb..aec191e 100644
--- a/fs/logfs/file.c
+++ b/fs/logfs/file.c
@@ -211,7 +211,7 @@ long logfs_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 		li->li_flags = flags;
 		inode_unlock(inode);
 
-		inode->i_ctime = CURRENT_TIME;
+		inode->i_ctime = current_fs_time(inode->i_sb);
 		mark_inode_dirty_sync(inode);
 		return 0;
 
diff --git a/fs/logfs/inode.c b/fs/logfs/inode.c
index db9cfc5..65eaf09 100644
--- a/fs/logfs/inode.c
+++ b/fs/logfs/inode.c
@@ -213,8 +213,7 @@ static void logfs_init_inode(struct super_block *sb, struct inode *inode)
 	i_gid_write(inode, 0);
 	inode->i_size	= 0;
 	inode->i_blocks	= 0;
-	inode->i_ctime	= CURRENT_TIME;
-	inode->i_mtime	= CURRENT_TIME;
+	inode->i_ctime	= inode->i_mtime = current_fs_time(sb);
 	li->li_refcount = 1;
 	INIT_LIST_HEAD(&li->li_freeing_list);
 
diff --git a/fs/logfs/readwrite.c b/fs/logfs/readwrite.c
index 3fb8c6d..dc7ed5c 100644
--- a/fs/logfs/readwrite.c
+++ b/fs/logfs/readwrite.c
@@ -1546,7 +1546,7 @@ static int __logfs_write_buf(struct inode *inode, struct page *page, long flags)
 	int err;
 
 	flags |= WF_WRITE | WF_DELETE;
-	inode->i_ctime = inode->i_mtime = CURRENT_TIME;
+	inode->i_ctime = inode->i_mtime = current_fs_time(inode->i_sb);
 
 	logfs_unpack_index(index, &bix, &level);
 	if (logfs_block(page) && logfs_block(page)->reserved_bytes)
@@ -1578,7 +1578,7 @@ static int __logfs_delete(struct inode *inode, struct page *page)
 	long flags = WF_DELETE;
 	int err;
 
-	inode->i_ctime = inode->i_mtime = CURRENT_TIME;
+	inode->i_ctime = inode->i_mtime = current_fs_time(inode->i_sb);
 
 	if (page->index < I0_BLOCKS)
 		return logfs_write_direct(inode, page, flags);
diff --git a/fs/nilfs2/dir.c b/fs/nilfs2/dir.c
index e506f4f..87e53a2 100644
--- a/fs/nilfs2/dir.c
+++ b/fs/nilfs2/dir.c
@@ -420,7 +420,7 @@ void nilfs_set_link(struct inode *dir, struct nilfs_dir_entry *de,
 	nilfs_set_de_type(de, inode);
 	nilfs_commit_chunk(page, mapping, from, to);
 	nilfs_put_page(page);
-	dir->i_mtime = dir->i_ctime = CURRENT_TIME;
+	dir->i_mtime = dir->i_ctime = current_fs_time(dir->i_sb);
 }
 
 /*
@@ -510,7 +510,7 @@ got_it:
 	de->inode = cpu_to_le64(inode->i_ino);
 	nilfs_set_de_type(de, inode);
 	nilfs_commit_chunk(page, page->mapping, from, to);
-	dir->i_mtime = dir->i_ctime = CURRENT_TIME;
+	dir->i_mtime = dir->i_ctime = current_fs_time(dir->i_sb);
 	nilfs_mark_inode_dirty(dir);
 	/* OFFSET_CACHE */
 out_put:
@@ -558,7 +558,7 @@ int nilfs_delete_entry(struct nilfs_dir_entry *dir, struct page *page)
 		pde->rec_len = nilfs_rec_len_to_disk(to - from);
 	dir->inode = 0;
 	nilfs_commit_chunk(page, mapping, from, to);
-	inode->i_ctime = inode->i_mtime = CURRENT_TIME;
+	inode->i_ctime = inode->i_mtime = current_fs_time(inode->i_sb);
 out:
 	nilfs_put_page(page);
 	return err;
diff --git a/fs/nilfs2/inode.c b/fs/nilfs2/inode.c
index a0ebdb1..9def740 100644
--- a/fs/nilfs2/inode.c
+++ b/fs/nilfs2/inode.c
@@ -370,7 +370,7 @@ struct inode *nilfs_new_inode(struct inode *dir, umode_t mode)
 	atomic64_inc(&root->inodes_count);
 	inode_init_owner(inode, dir, mode);
 	inode->i_ino = ino;
-	inode->i_mtime = inode->i_atime = inode->i_ctime = CURRENT_TIME;
+	inode->i_mtime = inode->i_atime = inode->i_ctime = current_fs_time(sb);
 
 	if (S_ISREG(mode) || S_ISDIR(mode) || S_ISLNK(mode)) {
 		err = nilfs_bmap_read(ii->i_bmap, NULL);
@@ -752,7 +752,7 @@ void nilfs_truncate(struct inode *inode)
 
 	nilfs_truncate_bmap(ii, blkoff);
 
-	inode->i_mtime = inode->i_ctime = CURRENT_TIME;
+	inode->i_mtime = inode->i_ctime = current_fs_time(sb);
 	if (IS_SYNC(inode))
 		nilfs_set_transaction_flag(NILFS_TI_SYNC);
 
diff --git a/fs/nilfs2/ioctl.c b/fs/nilfs2/ioctl.c
index 358b57e..56df4ca 100644
--- a/fs/nilfs2/ioctl.c
+++ b/fs/nilfs2/ioctl.c
@@ -175,7 +175,7 @@ static int nilfs_ioctl_setflags(struct inode *inode, struct file *filp,
 		(flags & FS_FL_USER_MODIFIABLE);
 
 	nilfs_set_inode_flags(inode);
-	inode->i_ctime = CURRENT_TIME;
+	inode->i_ctime = current_fs_time(inode->i_sb);
 	if (IS_SYNC(inode))
 		nilfs_set_transaction_flag(NILFS_TI_SYNC);
 
diff --git a/fs/nilfs2/namei.c b/fs/nilfs2/namei.c
index 1ec8ae5..97edc6f 100644
--- a/fs/nilfs2/namei.c
+++ b/fs/nilfs2/namei.c
@@ -194,7 +194,7 @@ static int nilfs_link(struct dentry *old_dentry, struct inode *dir,
 	if (err)
 		return err;
 
-	inode->i_ctime = CURRENT_TIME;
+	inode->i_ctime = current_fs_time(inode->i_sb);
 	inode_inc_link_count(inode);
 	ihold(inode);
 
@@ -391,7 +391,7 @@ static int nilfs_rename(struct inode *old_dir, struct dentry *old_dentry,
 			goto out_dir;
 		nilfs_set_link(new_dir, new_de, new_page, old_inode);
 		nilfs_mark_inode_dirty(new_dir);
-		new_inode->i_ctime = CURRENT_TIME;
+		new_inode->i_ctime = current_fs_time(new_inode->i_sb);
 		if (dir_de)
 			drop_nlink(new_inode);
 		drop_nlink(new_inode);
@@ -410,7 +410,7 @@ static int nilfs_rename(struct inode *old_dir, struct dentry *old_dentry,
 	 * Like most other Unix systems, set the ctime for inodes on a
 	 * rename.
 	 */
-	old_inode->i_ctime = CURRENT_TIME;
+	old_inode->i_ctime = current_fs_time(old_inode->i_sb);
 
 	nilfs_delete_entry(old_de, old_page);
 
diff --git a/fs/nsfs.c b/fs/nsfs.c
index 8f20d60..7504c41 100644
--- a/fs/nsfs.c
+++ b/fs/nsfs.c
@@ -48,6 +48,7 @@ void *ns_get_path(struct path *path, struct task_struct *task,
 			const struct proc_ns_operations *ns_ops)
 {
 	struct vfsmount *mnt = mntget(nsfs_mnt);
+	struct super_block *s = mnt->mnt_sb;
 	struct qstr qname = { .name = "", };
 	struct dentry *dentry;
 	struct inode *inode;
@@ -75,14 +76,14 @@ got_it:
 	return NULL;
 slow:
 	rcu_read_unlock();
-	inode = new_inode_pseudo(mnt->mnt_sb);
+	inode = new_inode_pseudo(s);
 	if (!inode) {
 		ns_ops->put(ns);
 		mntput(mnt);
 		return ERR_PTR(-ENOMEM);
 	}
 	inode->i_ino = ns->inum;
-	inode->i_mtime = inode->i_atime = inode->i_ctime = CURRENT_TIME;
+	inode->i_mtime = inode->i_atime = inode->i_ctime = current_fs_time(s);
 	inode->i_flags |= S_IMMUTABLE;
 	inode->i_mode = S_IFREG | S_IRUGO;
 	inode->i_fop = &ns_file_operations;
diff --git a/fs/ocfs2/acl.c b/fs/ocfs2/acl.c
index 2162434..f45fc9c 100644
--- a/fs/ocfs2/acl.c
+++ b/fs/ocfs2/acl.c
@@ -201,7 +201,7 @@ static int ocfs2_acl_set_mode(struct inode *inode, struct buffer_head *di_bh,
 	}
 
 	inode->i_mode = new_mode;
-	inode->i_ctime = CURRENT_TIME;
+	inode->i_ctime = current_fs_time(inode->i_sb);
 	di->i_mode = cpu_to_le16(inode->i_mode);
 	di->i_ctime = cpu_to_le64(inode->i_ctime.tv_sec);
 	di->i_ctime_nsec = cpu_to_le32(inode->i_ctime.tv_nsec);
diff --git a/fs/ocfs2/alloc.c b/fs/ocfs2/alloc.c
index 460c0ce..37c1cee 100644
--- a/fs/ocfs2/alloc.c
+++ b/fs/ocfs2/alloc.c
@@ -7274,7 +7274,7 @@ int ocfs2_truncate_inline(struct inode *inode, struct buffer_head *di_bh,
 	}
 
 	inode->i_blocks = ocfs2_inode_sector_count(inode);
-	inode->i_ctime = inode->i_mtime = CURRENT_TIME;
+	inode->i_ctime = inode->i_mtime = current_fs_time(inode->i_sb);
 
 	di->i_ctime = di->i_mtime = cpu_to_le64(inode->i_ctime.tv_sec);
 	di->i_ctime_nsec = di->i_mtime_nsec = cpu_to_le32(inode->i_ctime.tv_nsec);
diff --git a/fs/ocfs2/aops.c b/fs/ocfs2/aops.c
index c034edf..e12c122 100644
--- a/fs/ocfs2/aops.c
+++ b/fs/ocfs2/aops.c
@@ -2057,7 +2057,7 @@ out_write_size:
 		}
 		inode->i_blocks = ocfs2_inode_sector_count(inode);
 		di->i_size = cpu_to_le64((u64)i_size_read(inode));
-		inode->i_mtime = inode->i_ctime = CURRENT_TIME;
+		inode->i_mtime = inode->i_ctime = current_fs_time(inode->i_sb);
 		di->i_mtime = di->i_ctime = cpu_to_le64(inode->i_mtime.tv_sec);
 		di->i_mtime_nsec = di->i_ctime_nsec = cpu_to_le32(inode->i_mtime.tv_nsec);
 		ocfs2_update_inode_fsync_trans(handle, inode, 1);
diff --git a/fs/ocfs2/dir.c b/fs/ocfs2/dir.c
index e1adf28..7e77215 100644
--- a/fs/ocfs2/dir.c
+++ b/fs/ocfs2/dir.c
@@ -1677,7 +1677,7 @@ int __ocfs2_add_entry(handle_t *handle,
 				offset, ocfs2_dir_trailer_blk_off(dir->i_sb));
 
 		if (ocfs2_dirent_would_fit(de, rec_len)) {
-			dir->i_mtime = dir->i_ctime = CURRENT_TIME;
+			dir->i_mtime = dir->i_ctime = current_fs_time(sb);
 			retval = ocfs2_mark_inode_dirty(handle, dir, parent_fe_bh);
 			if (retval < 0) {
 				mlog_errno(retval);
@@ -2990,7 +2990,7 @@ static int ocfs2_expand_inline_dir(struct inode *dir, struct buffer_head *di_bh,
 	ocfs2_dinode_new_extent_list(dir, di);
 
 	i_size_write(dir, sb->s_blocksize);
-	dir->i_mtime = dir->i_ctime = CURRENT_TIME;
+	dir->i_mtime = dir->i_ctime = current_fs_time(sb);
 
 	di->i_size = cpu_to_le64(sb->s_blocksize);
 	di->i_ctime = di->i_mtime = cpu_to_le64(dir->i_ctime.tv_sec);
diff --git a/fs/ocfs2/dlmfs/dlmfs.c b/fs/ocfs2/dlmfs/dlmfs.c
index 47b3b2d..ac00863 100644
--- a/fs/ocfs2/dlmfs/dlmfs.c
+++ b/fs/ocfs2/dlmfs/dlmfs.c
@@ -398,7 +398,7 @@ static struct inode *dlmfs_get_root_inode(struct super_block *sb)
 	if (inode) {
 		inode->i_ino = get_next_ino();
 		inode_init_owner(inode, NULL, mode);
-		inode->i_atime = inode->i_mtime = inode->i_ctime = CURRENT_TIME;
+		inode->i_atime = inode->i_mtime = inode->i_ctime = current_fs_time(sb);
 		inc_nlink(inode);
 
 		inode->i_fop = &simple_dir_operations;
@@ -421,7 +421,7 @@ static struct inode *dlmfs_get_inode(struct inode *parent,
 
 	inode->i_ino = get_next_ino();
 	inode_init_owner(inode, parent, mode);
-	inode->i_atime = inode->i_mtime = inode->i_ctime = CURRENT_TIME;
+	inode->i_atime = inode->i_mtime = inode->i_ctime = current_fs_time(sb);
 
 	ip = DLMFS_I(inode);
 	ip->ip_conn = DLMFS_I(parent)->ip_conn;
diff --git a/fs/ocfs2/file.c b/fs/ocfs2/file.c
index 4e7b0dc..83fe9ff 100644
--- a/fs/ocfs2/file.c
+++ b/fs/ocfs2/file.c
@@ -253,7 +253,7 @@ int ocfs2_should_update_atime(struct inode *inode,
 		return 0;
 	}
 
-	now = CURRENT_TIME;
+	now = current_fs_time(inode->i_sb);
 	if ((now.tv_sec - inode->i_atime.tv_sec <= osb->s_atime_quantum))
 		return 0;
 	else
@@ -287,7 +287,7 @@ int ocfs2_update_inode_atime(struct inode *inode,
 	 * have i_mutex to guard against concurrent changes to other
 	 * inode fields.
 	 */
-	inode->i_atime = CURRENT_TIME;
+	inode->i_atime = current_fs_time(inode->i_sb);
 	di->i_atime = cpu_to_le64(inode->i_atime.tv_sec);
 	di->i_atime_nsec = cpu_to_le32(inode->i_atime.tv_nsec);
 	ocfs2_update_inode_fsync_trans(handle, inode, 0);
@@ -308,7 +308,7 @@ int ocfs2_set_inode_size(handle_t *handle,
 
 	i_size_write(inode, new_i_size);
 	inode->i_blocks = ocfs2_inode_sector_count(inode);
-	inode->i_ctime = inode->i_mtime = CURRENT_TIME;
+	inode->i_ctime = inode->i_mtime = current_fs_time(inode->i_sb);
 
 	status = ocfs2_mark_inode_dirty(handle, inode, fe_bh);
 	if (status < 0) {
@@ -429,7 +429,7 @@ static int ocfs2_orphan_for_truncate(struct ocfs2_super *osb,
 	}
 
 	i_size_write(inode, new_i_size);
-	inode->i_ctime = inode->i_mtime = CURRENT_TIME;
+	inode->i_ctime = inode->i_mtime = current_fs_time(inode->i_sb);
 
 	di = (struct ocfs2_dinode *) fe_bh->b_data;
 	di->i_size = cpu_to_le64(new_i_size);
@@ -840,7 +840,7 @@ static int ocfs2_write_zero_page(struct inode *inode, u64 abs_from,
 	i_size_write(inode, abs_to);
 	inode->i_blocks = ocfs2_inode_sector_count(inode);
 	di->i_size = cpu_to_le64((u64)i_size_read(inode));
-	inode->i_mtime = inode->i_ctime = CURRENT_TIME;
+	inode->i_mtime = inode->i_ctime = current_fs_time(inode->i_sb);
 	di->i_mtime = di->i_ctime = cpu_to_le64(inode->i_mtime.tv_sec);
 	di->i_ctime_nsec = cpu_to_le32(inode->i_mtime.tv_nsec);
 	di->i_mtime_nsec = di->i_ctime_nsec;
@@ -1936,7 +1936,7 @@ static int __ocfs2_change_file_space(struct file *file, struct inode *inode,
 	if (change_size && i_size_read(inode) < size)
 		i_size_write(inode, size);
 
-	inode->i_ctime = inode->i_mtime = CURRENT_TIME;
+	inode->i_ctime = inode->i_mtime = current_fs_time(inode->i_sb);
 	ret = ocfs2_mark_inode_dirty(handle, inode, di_bh);
 	if (ret < 0)
 		mlog_errno(ret);
diff --git a/fs/ocfs2/inode.c b/fs/ocfs2/inode.c
index c56a767..b3395b9 100644
--- a/fs/ocfs2/inode.c
+++ b/fs/ocfs2/inode.c
@@ -703,7 +703,7 @@ static int ocfs2_remove_inode(struct inode *inode,
 		goto bail_commit;
 	}
 
-	di->i_dtime = cpu_to_le64(CURRENT_TIME.tv_sec);
+	di->i_dtime = cpu_to_le64(current_fs_time(inode->i_sb).tv_sec);
 	di->i_flags &= cpu_to_le32(~(OCFS2_VALID_FL | OCFS2_ORPHANED_FL));
 	ocfs2_journal_dirty(handle, di_bh);
 
diff --git a/fs/ocfs2/move_extents.c b/fs/ocfs2/move_extents.c
index e3d05d9..3b25721 100644
--- a/fs/ocfs2/move_extents.c
+++ b/fs/ocfs2/move_extents.c
@@ -953,7 +953,7 @@ static int ocfs2_move_extents(struct ocfs2_move_extents_context *context)
 	}
 
 	di = (struct ocfs2_dinode *)di_bh->b_data;
-	inode->i_ctime = CURRENT_TIME;
+	inode->i_ctime = current_fs_time(inode->i_sb);
 	di->i_ctime = cpu_to_le64(inode->i_ctime.tv_sec);
 	di->i_ctime_nsec = cpu_to_le32(inode->i_ctime.tv_nsec);
 	ocfs2_update_inode_fsync_trans(handle, inode, 0);
diff --git a/fs/ocfs2/namei.c b/fs/ocfs2/namei.c
index a8f1225..c4cfe0e 100644
--- a/fs/ocfs2/namei.c
+++ b/fs/ocfs2/namei.c
@@ -511,7 +511,8 @@ static int __ocfs2_mknod_locked(struct inode *dir,
 				u64 fe_blkno, u64 suballoc_loc, u16 suballoc_bit)
 {
 	int status = 0;
-	struct ocfs2_super *osb = OCFS2_SB(dir->i_sb);
+	struct super_block *sb = dir->i_sb;
+	struct ocfs2_super *osb = OCFS2_SB(sb);
 	struct ocfs2_dinode *fe = NULL;
 	struct ocfs2_extent_list *fel;
 	u16 feat;
@@ -565,9 +566,9 @@ static int __ocfs2_mknod_locked(struct inode *dir,
 	strcpy(fe->i_signature, OCFS2_INODE_SIGNATURE);
 	fe->i_flags |= cpu_to_le32(OCFS2_VALID_FL);
 	fe->i_atime = fe->i_ctime = fe->i_mtime =
-		cpu_to_le64(CURRENT_TIME.tv_sec);
+		cpu_to_le64(current_fs_time(sb).tv_sec);
 	fe->i_mtime_nsec = fe->i_ctime_nsec = fe->i_atime_nsec =
-		cpu_to_le32(CURRENT_TIME.tv_nsec);
+		cpu_to_le32(current_fs_time(sb).tv_nsec);
 	fe->i_dtime = 0;
 
 	/*
@@ -798,7 +799,7 @@ static int ocfs2_link(struct dentry *old_dentry,
 	}
 
 	inc_nlink(inode);
-	inode->i_ctime = CURRENT_TIME;
+	inode->i_ctime = current_fs_time(inode->i_sb);
 	ocfs2_set_links_count(fe, inode->i_nlink);
 	fe->i_ctime = cpu_to_le64(inode->i_ctime.tv_sec);
 	fe->i_ctime_nsec = cpu_to_le32(inode->i_ctime.tv_nsec);
@@ -1000,7 +1001,7 @@ static int ocfs2_unlink(struct inode *dir,
 	ocfs2_set_links_count(fe, inode->i_nlink);
 	ocfs2_journal_dirty(handle, fe_bh);
 
-	dir->i_ctime = dir->i_mtime = CURRENT_TIME;
+	dir->i_ctime = dir->i_mtime = current_fs_time(dir->i_sb);
 	if (S_ISDIR(inode->i_mode))
 		drop_nlink(dir);
 
@@ -1537,7 +1538,7 @@ static int ocfs2_rename(struct inode *old_dir,
 					 new_dir_bh, &target_insert);
 	}
 
-	old_inode->i_ctime = CURRENT_TIME;
+	old_inode->i_ctime = current_fs_time(old_inode->i_sb);
 	mark_inode_dirty(old_inode);
 
 	status = ocfs2_journal_access_di(handle, INODE_CACHE(old_inode),
@@ -1586,9 +1587,9 @@ static int ocfs2_rename(struct inode *old_dir,
 
 	if (new_inode) {
 		drop_nlink(new_inode);
-		new_inode->i_ctime = CURRENT_TIME;
+		new_inode->i_ctime = current_fs_time(new_inode->i_sb);
 	}
-	old_dir->i_ctime = old_dir->i_mtime = CURRENT_TIME;
+	old_dir->i_ctime = old_dir->i_mtime = current_fs_time(old_inode->i_sb);
 
 	if (update_dot_dot) {
 		status = ocfs2_update_entry(old_inode, handle,
diff --git a/fs/ocfs2/refcounttree.c b/fs/ocfs2/refcounttree.c
index 92bbe93..64f46f6 100644
--- a/fs/ocfs2/refcounttree.c
+++ b/fs/ocfs2/refcounttree.c
@@ -3778,7 +3778,7 @@ static int ocfs2_change_ctime(struct inode *inode,
 		goto out_commit;
 	}
 
-	inode->i_ctime = CURRENT_TIME;
+	inode->i_ctime = current_fs_time(inode->i_sb);
 	di->i_ctime = cpu_to_le64(inode->i_ctime.tv_sec);
 	di->i_ctime_nsec = cpu_to_le32(inode->i_ctime.tv_nsec);
 
@@ -4094,7 +4094,7 @@ static int ocfs2_complete_reflink(struct inode *s_inode,
 		 * we want mtime to appear identical to the source and
 		 * update ctime.
 		 */
-		t_inode->i_ctime = CURRENT_TIME;
+		t_inode->i_ctime = current_fs_time(t_inode->i_sb);
 
 		di->i_ctime = cpu_to_le64(t_inode->i_ctime.tv_sec);
 		di->i_ctime_nsec = cpu_to_le32(t_inode->i_ctime.tv_nsec);
diff --git a/fs/ocfs2/xattr.c b/fs/ocfs2/xattr.c
index d205385..6f7bc41 100644
--- a/fs/ocfs2/xattr.c
+++ b/fs/ocfs2/xattr.c
@@ -3431,7 +3431,7 @@ static int __ocfs2_xattr_set_handle(struct inode *inode,
 			goto out;
 		}
 
-		inode->i_ctime = CURRENT_TIME;
+		inode->i_ctime = current_fs_time(inode->i_sb);
 		di->i_ctime = cpu_to_le64(inode->i_ctime.tv_sec);
 		di->i_ctime_nsec = cpu_to_le32(inode->i_ctime.tv_nsec);
 		ocfs2_journal_dirty(ctxt->handle, xis->inode_bh);
diff --git a/fs/openpromfs/inode.c b/fs/openpromfs/inode.c
index c7a8699..e6db783 100644
--- a/fs/openpromfs/inode.c
+++ b/fs/openpromfs/inode.c
@@ -355,7 +355,7 @@ static struct inode *openprom_iget(struct super_block *sb, ino_t ino)
 	if (!inode)
 		return ERR_PTR(-ENOMEM);
 	if (inode->i_state & I_NEW) {
-		inode->i_mtime = inode->i_atime = inode->i_ctime = CURRENT_TIME;
+		inode->i_mtime = inode->i_atime = inode->i_ctime = current_fs_time(sb);
 		if (inode->i_ino == OPENPROM_ROOT_INO) {
 			inode->i_op = &openprom_inode_operations;
 			inode->i_fop = &openprom_operations;
diff --git a/fs/orangefs/file.c b/fs/orangefs/file.c
index 491e82c..8322af6 100644
--- a/fs/orangefs/file.c
+++ b/fs/orangefs/file.c
@@ -358,7 +358,7 @@ out:
 			file_accessed(file);
 		} else {
 			SetMtimeFlag(orangefs_inode);
-			inode->i_mtime = CURRENT_TIME;
+			inode->i_mtime = current_fs_time(inode->i_sb);
 			mark_inode_dirty_sync(inode);
 		}
 	}
diff --git a/fs/orangefs/inode.c b/fs/orangefs/inode.c
index 0f586bd..a9341de 100644
--- a/fs/orangefs/inode.c
+++ b/fs/orangefs/inode.c
@@ -441,7 +441,7 @@ struct inode *orangefs_new_inode(struct super_block *sb, struct inode *dir,
 	inode->i_mode = mode;
 	inode->i_uid = current_fsuid();
 	inode->i_gid = current_fsgid();
-	inode->i_atime = inode->i_mtime = inode->i_ctime = CURRENT_TIME;
+	inode->i_atime = inode->i_mtime = inode->i_ctime = current_fs_time(sb);
 	inode->i_size = PAGE_SIZE;
 	inode->i_rdev = dev;
 
diff --git a/fs/orangefs/namei.c b/fs/orangefs/namei.c
index 4ca377d..8c788b1 100644
--- a/fs/orangefs/namei.c
+++ b/fs/orangefs/namei.c
@@ -402,6 +402,7 @@ static int orangefs_rename(struct inode *old_dir,
 			struct dentry *new_dentry)
 {
 	struct orangefs_kernel_op_s *new_op;
+	struct inode *new_inode;
 	int ret;
 
 	gossip_debug(GOSSIP_NAME_DEBUG,
@@ -434,8 +435,9 @@ static int orangefs_rename(struct inode *old_dir,
 		     "orangefs_rename: got downcall status %d\n",
 		     ret);
 
-	if (new_dentry->d_inode)
-		new_dentry->d_inode->i_ctime = CURRENT_TIME;
+	new_inode = new_dentry->d_inode;
+	if (new_inode)
+		new_inode->i_ctime = current_fs_time(new_inode->i_sb);
 
 	op_release(new_op);
 	return ret;
diff --git a/fs/pipe.c b/fs/pipe.c
index 0d3f516..097d300 100644
--- a/fs/pipe.c
+++ b/fs/pipe.c
@@ -672,7 +672,8 @@ static const struct dentry_operations pipefs_dentry_operations = {
 
 static struct inode * get_pipe_inode(void)
 {
-	struct inode *inode = new_inode_pseudo(pipe_mnt->mnt_sb);
+	struct super_block *s = pipe_mnt->mnt_sb;
+	struct inode *inode = new_inode_pseudo(s);
 	struct pipe_inode_info *pipe;
 
 	if (!inode)
@@ -699,7 +700,7 @@ static struct inode * get_pipe_inode(void)
 	inode->i_mode = S_IFIFO | S_IRUSR | S_IWUSR;
 	inode->i_uid = current_fsuid();
 	inode->i_gid = current_fsgid();
-	inode->i_atime = inode->i_mtime = inode->i_ctime = CURRENT_TIME;
+	inode->i_atime = inode->i_mtime = inode->i_ctime = current_fs_time(s);
 
 	return inode;
 
diff --git a/fs/posix_acl.c b/fs/posix_acl.c
index 8a4a266..dfea8f2 100644
--- a/fs/posix_acl.c
+++ b/fs/posix_acl.c
@@ -893,7 +893,7 @@ int simple_set_acl(struct inode *inode, struct posix_acl *acl, int type)
 			acl = NULL;
 	}
 
-	inode->i_ctime = CURRENT_TIME;
+	inode->i_ctime = current_fs_time(inode->i_sb);
 	set_cached_acl(inode, type, acl);
 	return 0;
 }
diff --git a/fs/proc/base.c b/fs/proc/base.c
index a11eb71..a5af51b 100644
--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -1665,7 +1665,7 @@ struct inode *proc_pid_make_inode(struct super_block * sb, struct task_struct *t
 	/* Common stuff */
 	ei = PROC_I(inode);
 	inode->i_ino = get_next_ino();
-	inode->i_mtime = inode->i_atime = inode->i_ctime = CURRENT_TIME;
+	inode->i_mtime = inode->i_atime = inode->i_ctime = current_fs_time(sb);
 	inode->i_op = &proc_def_inode_operations;
 
 	/*
diff --git a/fs/proc/inode.c b/fs/proc/inode.c
index 42305dd..436bdd7 100644
--- a/fs/proc/inode.c
+++ b/fs/proc/inode.c
@@ -68,7 +68,7 @@ static struct inode *proc_alloc_inode(struct super_block *sb)
 	ei->sysctl_entry = NULL;
 	ei->ns_ops = NULL;
 	inode = &ei->vfs_inode;
-	inode->i_mtime = inode->i_atime = inode->i_ctime = CURRENT_TIME;
+	inode->i_mtime = inode->i_atime = inode->i_ctime = current_fs_time(sb);
 	return inode;
 }
 
@@ -421,7 +421,7 @@ struct inode *proc_get_inode(struct super_block *sb, struct proc_dir_entry *de)
 
 	if (inode) {
 		inode->i_ino = de->low_ino;
-		inode->i_mtime = inode->i_atime = inode->i_ctime = CURRENT_TIME;
+		inode->i_mtime = inode->i_atime = inode->i_ctime = current_fs_time(sb);
 		PROC_I(inode)->pde = de;
 
 		if (is_empty_pde(de)) {
diff --git a/fs/proc/proc_sysctl.c b/fs/proc/proc_sysctl.c
index 5e57c3e..deb9b6d 100644
--- a/fs/proc/proc_sysctl.c
+++ b/fs/proc/proc_sysctl.c
@@ -444,7 +444,7 @@ static struct inode *proc_sys_make_inode(struct super_block *sb,
 	ei->sysctl = head;
 	ei->sysctl_entry = table;
 
-	inode->i_mtime = inode->i_atime = inode->i_ctime = CURRENT_TIME;
+	inode->i_mtime = inode->i_atime = inode->i_ctime = current_fs_time(sb);
 	inode->i_mode = table->mode;
 	if (!S_ISDIR(table->mode)) {
 		inode->i_mode |= S_IFREG;
diff --git a/fs/proc/self.c b/fs/proc/self.c
index b6a8d35..25d4909 100644
--- a/fs/proc/self.c
+++ b/fs/proc/self.c
@@ -56,7 +56,7 @@ int proc_setup_self(struct super_block *s)
 		struct inode *inode = new_inode_pseudo(s);
 		if (inode) {
 			inode->i_ino = self_inum;
-			inode->i_mtime = inode->i_atime = inode->i_ctime = CURRENT_TIME;
+			inode->i_mtime = inode->i_atime = inode->i_ctime = current_fs_time(s);
 			inode->i_mode = S_IFLNK | S_IRWXUGO;
 			inode->i_uid = GLOBAL_ROOT_UID;
 			inode->i_gid = GLOBAL_ROOT_GID;
diff --git a/fs/proc/thread_self.c b/fs/proc/thread_self.c
index e58a31e..aa15827 100644
--- a/fs/proc/thread_self.c
+++ b/fs/proc/thread_self.c
@@ -58,7 +58,7 @@ int proc_setup_thread_self(struct super_block *s)
 		struct inode *inode = new_inode_pseudo(s);
 		if (inode) {
 			inode->i_ino = thread_self_inum;
-			inode->i_mtime = inode->i_atime = inode->i_ctime = CURRENT_TIME;
+			inode->i_mtime = inode->i_atime = inode->i_ctime = current_fs_time(s);
 			inode->i_mode = S_IFLNK | S_IRWXUGO;
 			inode->i_uid = GLOBAL_ROOT_UID;
 			inode->i_gid = GLOBAL_ROOT_GID;
diff --git a/fs/pstore/inode.c b/fs/pstore/inode.c
index 45d6110..16b1ac0 100644
--- a/fs/pstore/inode.c
+++ b/fs/pstore/inode.c
@@ -231,7 +231,7 @@ static struct inode *pstore_get_inode(struct super_block *sb)
 	struct inode *inode = new_inode(sb);
 	if (inode) {
 		inode->i_ino = get_next_ino();
-		inode->i_atime = inode->i_mtime = inode->i_ctime = CURRENT_TIME;
+		inode->i_atime = inode->i_mtime = inode->i_ctime = current_fs_time(sb);
 	}
 	return inode;
 }
diff --git a/fs/ramfs/inode.c b/fs/ramfs/inode.c
index 1ab6e6c..8ddea21 100644
--- a/fs/ramfs/inode.c
+++ b/fs/ramfs/inode.c
@@ -61,7 +61,7 @@ struct inode *ramfs_get_inode(struct super_block *sb,
 		inode->i_mapping->a_ops = &ramfs_aops;
 		mapping_set_gfp_mask(inode->i_mapping, GFP_HIGHUSER);
 		mapping_set_unevictable(inode->i_mapping);
-		inode->i_atime = inode->i_mtime = inode->i_ctime = CURRENT_TIME;
+		inode->i_atime = inode->i_mtime = inode->i_ctime = current_fs_time(sb);
 		switch (mode & S_IFMT) {
 		default:
 			init_special_inode(inode, mode, dev);
@@ -93,14 +93,15 @@ struct inode *ramfs_get_inode(struct super_block *sb,
 static int
 ramfs_mknod(struct inode *dir, struct dentry *dentry, umode_t mode, dev_t dev)
 {
-	struct inode * inode = ramfs_get_inode(dir->i_sb, dir, mode, dev);
+	struct super_block *sb = dir->i_sb;
+	struct inode *inode = ramfs_get_inode(sb, dir, mode, dev);
 	int error = -ENOSPC;
 
 	if (inode) {
 		d_instantiate(dentry, inode);
 		dget(dentry);	/* Extra count - pin the dentry in core */
 		error = 0;
-		dir->i_mtime = dir->i_ctime = CURRENT_TIME;
+		dir->i_mtime = dir->i_ctime = current_fs_time(sb);
 	}
 	return error;
 }
@@ -120,17 +121,18 @@ static int ramfs_create(struct inode *dir, struct dentry *dentry, umode_t mode,
 
 static int ramfs_symlink(struct inode * dir, struct dentry *dentry, const char * symname)
 {
+	struct super_block *sb = dir->i_sb;
 	struct inode *inode;
 	int error = -ENOSPC;
 
-	inode = ramfs_get_inode(dir->i_sb, dir, S_IFLNK|S_IRWXUGO, 0);
+	inode = ramfs_get_inode(sb, dir, S_IFLNK|S_IRWXUGO, 0);
 	if (inode) {
 		int l = strlen(symname)+1;
 		error = page_symlink(inode, symname, l);
 		if (!error) {
 			d_instantiate(dentry, inode);
 			dget(dentry);
-			dir->i_mtime = dir->i_ctime = CURRENT_TIME;
+			dir->i_mtime = dir->i_ctime = current_fs_time(sb);
 		} else
 			iput(inode);
 	}
diff --git a/fs/tracefs/inode.c b/fs/tracefs/inode.c
index 4a0e48f..052d39f 100644
--- a/fs/tracefs/inode.c
+++ b/fs/tracefs/inode.c
@@ -133,7 +133,7 @@ static struct inode *tracefs_get_inode(struct super_block *sb)
 	struct inode *inode = new_inode(sb);
 	if (inode) {
 		inode->i_ino = get_next_ino();
-		inode->i_atime = inode->i_mtime = inode->i_ctime = CURRENT_TIME;
+		inode->i_atime = inode->i_mtime = inode->i_ctime = current_fs_time(sb);
 	}
 	return inode;
 }
diff --git a/ipc/mqueue.c b/ipc/mqueue.c
index ade739f..3becf0d 100644
--- a/ipc/mqueue.c
+++ b/ipc/mqueue.c
@@ -225,7 +225,7 @@ static struct inode *mqueue_get_inode(struct super_block *sb,
 	inode->i_mode = mode;
 	inode->i_uid = current_fsuid();
 	inode->i_gid = current_fsgid();
-	inode->i_mtime = inode->i_ctime = inode->i_atime = CURRENT_TIME;
+	inode->i_mtime = inode->i_ctime = inode->i_atime = current_fs_time(sb);
 
 	if (S_ISREG(mode)) {
 		struct mqueue_inode_info *info;
@@ -419,6 +419,7 @@ static int mqueue_create(struct inode *dir, struct dentry *dentry,
 				umode_t mode, bool excl)
 {
 	struct inode *inode;
+	struct super_block *sb = dir->i_sb;
 	struct mq_attr *attr = dentry->d_fsdata;
 	int error;
 	struct ipc_namespace *ipc_ns;
@@ -438,7 +439,7 @@ static int mqueue_create(struct inode *dir, struct dentry *dentry,
 	ipc_ns->mq_queues_count++;
 	spin_unlock(&mq_lock);
 
-	inode = mqueue_get_inode(dir->i_sb, ipc_ns, mode, attr);
+	inode = mqueue_get_inode(sb, ipc_ns, mode, attr);
 	if (IS_ERR(inode)) {
 		error = PTR_ERR(inode);
 		spin_lock(&mq_lock);
@@ -448,7 +449,7 @@ static int mqueue_create(struct inode *dir, struct dentry *dentry,
 
 	put_ipc_ns(ipc_ns);
 	dir->i_size += DIRENT_SIZE;
-	dir->i_ctime = dir->i_mtime = dir->i_atime = CURRENT_TIME;
+	dir->i_ctime = dir->i_mtime = dir->i_atime = current_fs_time(sb);
 
 	d_instantiate(dentry, inode);
 	dget(dentry);
@@ -464,7 +465,7 @@ static int mqueue_unlink(struct inode *dir, struct dentry *dentry)
 {
 	struct inode *inode = d_inode(dentry);
 
-	dir->i_ctime = dir->i_mtime = dir->i_atime = CURRENT_TIME;
+	dir->i_ctime = dir->i_mtime = dir->i_atime = current_fs_time(dir->i_sb);
 	dir->i_size -= DIRENT_SIZE;
 	drop_nlink(inode);
 	dput(dentry);
@@ -502,7 +503,7 @@ static ssize_t mqueue_read_file(struct file *filp, char __user *u_data,
 	if (ret <= 0)
 		return ret;
 
-	file_inode(filp)->i_atime = file_inode(filp)->i_ctime = CURRENT_TIME;
+	file_inode(filp)->i_atime = file_inode(filp)->i_ctime = current_fs_time(file_inode(filp)->i_sb);
 	return ret;
 }
 
@@ -1062,7 +1063,7 @@ SYSCALL_DEFINE5(mq_timedsend, mqd_t, mqdes, const char __user *, u_msg_ptr,
 			__do_notify(info);
 		}
 		inode->i_atime = inode->i_mtime = inode->i_ctime =
-				CURRENT_TIME;
+				current_fs_time(inode->i_sb);
 	}
 out_unlock:
 	spin_unlock(&info->lock);
@@ -1158,7 +1159,7 @@ SYSCALL_DEFINE5(mq_timedreceive, mqd_t, mqdes, char __user *, u_msg_ptr,
 		msg_ptr = msg_get(info);
 
 		inode->i_atime = inode->i_mtime = inode->i_ctime =
-				CURRENT_TIME;
+				current_fs_time(inode->i_sb);
 
 		/* There is now free space in queue. */
 		pipelined_receive(&wake_q, info);
@@ -1279,7 +1280,7 @@ retry:
 	if (u_notification == NULL) {
 		if (info->notify_owner == task_tgid(current)) {
 			remove_notification(info);
-			inode->i_atime = inode->i_ctime = CURRENT_TIME;
+			inode->i_atime = inode->i_ctime = current_fs_time(inode->i_sb);
 		}
 	} else if (info->notify_owner != NULL) {
 		ret = -EBUSY;
@@ -1304,7 +1305,7 @@ retry:
 
 		info->notify_owner = get_pid(task_tgid(current));
 		info->notify_user_ns = get_user_ns(current_user_ns());
-		inode->i_atime = inode->i_ctime = CURRENT_TIME;
+		inode->i_atime = inode->i_ctime = current_fs_time(inode->i_sb);
 	}
 	spin_unlock(&info->lock);
 out_fput:
@@ -1361,7 +1362,7 @@ SYSCALL_DEFINE3(mq_getsetattr, mqd_t, mqdes,
 			f.file->f_flags &= ~O_NONBLOCK;
 		spin_unlock(&f.file->f_lock);
 
-		inode->i_atime = inode->i_ctime = CURRENT_TIME;
+		inode->i_atime = inode->i_ctime = current_fs_time(inode->i_sb);
 	}
 
 	spin_unlock(&info->lock);
diff --git a/kernel/bpf/inode.c b/kernel/bpf/inode.c
index 318858e..c83cc01 100644
--- a/kernel/bpf/inode.c
+++ b/kernel/bpf/inode.c
@@ -97,7 +97,7 @@ static struct inode *bpf_get_inode(struct super_block *sb,
 		return ERR_PTR(-ENOSPC);
 
 	inode->i_ino = get_next_ino();
-	inode->i_atime = CURRENT_TIME;
+	inode->i_atime = current_fs_time(sb);
 	inode->i_mtime = inode->i_atime;
 	inode->i_ctime = inode->i_atime;
 
diff --git a/mm/shmem.c b/mm/shmem.c
index a361449..4a2ff70 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -616,7 +616,7 @@ static void shmem_undo_range(struct inode *inode, loff_t lstart, loff_t lend,
 void shmem_truncate_range(struct inode *inode, loff_t lstart, loff_t lend)
 {
 	shmem_undo_range(inode, lstart, lend, false);
-	inode->i_ctime = inode->i_mtime = CURRENT_TIME;
+	inode->i_ctime = inode->i_mtime = current_fs_time(inode->i_sb);
 }
 EXPORT_SYMBOL_GPL(shmem_truncate_range);
 
@@ -660,7 +660,7 @@ static int shmem_setattr(struct dentry *dentry, struct iattr *attr)
 			if (error)
 				return error;
 			i_size_write(inode, newsize);
-			inode->i_ctime = inode->i_mtime = CURRENT_TIME;
+			inode->i_ctime = inode->i_mtime = current_fs_time(inode->i_sb);
 		}
 		if (newsize <= oldsize) {
 			loff_t holebegin = round_up(newsize, PAGE_SIZE);
@@ -1497,7 +1497,7 @@ static struct inode *shmem_get_inode(struct super_block *sb, const struct inode
 		inode->i_ino = get_next_ino();
 		inode_init_owner(inode, dir, mode);
 		inode->i_blocks = 0;
-		inode->i_atime = inode->i_mtime = inode->i_ctime = CURRENT_TIME;
+		inode->i_atime = inode->i_mtime = inode->i_ctime = current_fs_time(sb);
 		inode->i_generation = get_seconds();
 		info = SHMEM_I(inode);
 		memset(info, 0, (char *)inode - (char *)info);
@@ -2139,7 +2139,8 @@ static long shmem_fallocate(struct file *file, int mode, loff_t offset,
 							 loff_t len)
 {
 	struct inode *inode = file_inode(file);
-	struct shmem_sb_info *sbinfo = SHMEM_SB(inode->i_sb);
+	struct super_block *sb = inode->i_sb;
+	struct shmem_sb_info *sbinfo = SHMEM_SB(sb);
 	struct shmem_inode_info *info = SHMEM_I(inode);
 	struct shmem_falloc shmem_falloc;
 	pgoff_t start, index, end;
@@ -2254,7 +2255,7 @@ static long shmem_fallocate(struct file *file, int mode, loff_t offset,
 
 	if (!(mode & FALLOC_FL_KEEP_SIZE) && offset + len > inode->i_size)
 		i_size_write(inode, offset + len);
-	inode->i_ctime = CURRENT_TIME;
+	inode->i_ctime = current_fs_time(sb);
 undone:
 	spin_lock(&inode->i_lock);
 	inode->i_private = NULL;
@@ -2292,9 +2293,10 @@ static int
 shmem_mknod(struct inode *dir, struct dentry *dentry, umode_t mode, dev_t dev)
 {
 	struct inode *inode;
+	struct super_block *sb = dir->i_sb;
 	int error = -ENOSPC;
 
-	inode = shmem_get_inode(dir->i_sb, dir, mode, dev, VM_NORESERVE);
+	inode = shmem_get_inode(sb, dir, mode, dev, VM_NORESERVE);
 	if (inode) {
 		error = simple_acl_create(dir, inode);
 		if (error)
@@ -2307,7 +2309,7 @@ shmem_mknod(struct inode *dir, struct dentry *dentry, umode_t mode, dev_t dev)
 
 		error = 0;
 		dir->i_size += BOGO_DIRENT_SIZE;
-		dir->i_ctime = dir->i_mtime = CURRENT_TIME;
+		dir->i_ctime = dir->i_mtime = current_fs_time(sb);
 		d_instantiate(dentry, inode);
 		dget(dentry); /* Extra count - pin the dentry in core */
 	}
@@ -2375,7 +2377,7 @@ static int shmem_link(struct dentry *old_dentry, struct inode *dir, struct dentr
 		goto out;
 
 	dir->i_size += BOGO_DIRENT_SIZE;
-	inode->i_ctime = dir->i_ctime = dir->i_mtime = CURRENT_TIME;
+	inode->i_ctime = dir->i_ctime = dir->i_mtime = current_fs_time(dir->i_sb);
 	inc_nlink(inode);
 	ihold(inode);	/* New dentry reference */
 	dget(dentry);		/* Extra pinning count for the created dentry */
@@ -2392,7 +2394,7 @@ static int shmem_unlink(struct inode *dir, struct dentry *dentry)
 		shmem_free_inode(inode->i_sb);
 
 	dir->i_size -= BOGO_DIRENT_SIZE;
-	inode->i_ctime = dir->i_ctime = dir->i_mtime = CURRENT_TIME;
+	inode->i_ctime = dir->i_ctime = dir->i_mtime = current_fs_time(dir->i_sb);
 	drop_nlink(inode);
 	dput(dentry);	/* Undo the count from "create" - this does all the work */
 	return 0;
@@ -2425,7 +2427,7 @@ static int shmem_exchange(struct inode *old_dir, struct dentry *old_dentry, stru
 	old_dir->i_ctime = old_dir->i_mtime =
 	new_dir->i_ctime = new_dir->i_mtime =
 	d_inode(old_dentry)->i_ctime =
-	d_inode(new_dentry)->i_ctime = CURRENT_TIME;
+	d_inode(new_dentry)->i_ctime = current_fs_time(old_dir->i_sb);
 
 	return 0;
 }
@@ -2499,7 +2501,7 @@ static int shmem_rename2(struct inode *old_dir, struct dentry *old_dentry, struc
 	new_dir->i_size += BOGO_DIRENT_SIZE;
 	old_dir->i_ctime = old_dir->i_mtime =
 	new_dir->i_ctime = new_dir->i_mtime =
-	inode->i_ctime = CURRENT_TIME;
+	inode->i_ctime = current_fs_time(old_dir->i_sb);
 	return 0;
 }
 
@@ -2554,7 +2556,7 @@ static int shmem_symlink(struct inode *dir, struct dentry *dentry, const char *s
 		put_page(page);
 	}
 	dir->i_size += BOGO_DIRENT_SIZE;
-	dir->i_ctime = dir->i_mtime = CURRENT_TIME;
+	dir->i_ctime = dir->i_mtime = current_fs_time(dir->i_sb);
 	d_instantiate(dentry, inode);
 	dget(dentry);
 	return 0;
diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
index fc48eca..db70762 100644
--- a/net/sunrpc/rpc_pipe.c
+++ b/net/sunrpc/rpc_pipe.c
@@ -477,7 +477,7 @@ rpc_get_inode(struct super_block *sb, umode_t mode)
 		return NULL;
 	inode->i_ino = get_next_ino();
 	inode->i_mode = mode;
-	inode->i_atime = inode->i_mtime = inode->i_ctime = CURRENT_TIME;
+	inode->i_atime = inode->i_mtime = inode->i_ctime = current_fs_time(sb);
 	switch (mode & S_IFMT) {
 	case S_IFDIR:
 		inode->i_fop = &simple_dir_operations;
diff --git a/security/inode.c b/security/inode.c
index 28414b0..27cc83c 100644
--- a/security/inode.c
+++ b/security/inode.c
@@ -117,7 +117,7 @@ struct dentry *securityfs_create_file(const char *name, umode_t mode,
 
 	inode->i_ino = get_next_ino();
 	inode->i_mode = mode;
-	inode->i_atime = inode->i_mtime = inode->i_ctime = CURRENT_TIME;
+	inode->i_atime = inode->i_mtime = inode->i_ctime = current_fs_time(inode->i_sb);
 	inode->i_private = data;
 	if (is_dir) {
 		inode->i_op = &simple_dir_inode_operations;
diff --git a/security/selinux/selinuxfs.c b/security/selinux/selinuxfs.c
index 1b1fd27..7c47272 100644
--- a/security/selinux/selinuxfs.c
+++ b/security/selinux/selinuxfs.c
@@ -1089,7 +1089,7 @@ static struct inode *sel_make_inode(struct super_block *sb, int mode)
 
 	if (ret) {
 		ret->i_mode = mode;
-		ret->i_atime = ret->i_mtime = ret->i_ctime = CURRENT_TIME;
+		ret->i_atime = ret->i_mtime = ret->i_ctime = current_fs_time(sb);
 	}
 	return ret;
 }
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
