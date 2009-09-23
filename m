Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id E33D66B00B1
	for <linux-mm@kvack.org>; Wed, 23 Sep 2009 20:29:44 -0400 (EDT)
From: Oren Laadan <orenl@librato.com>
Subject: [PATCH v18 41/80] Add the checkpoint operation for opened files of generic filesystems
Date: Wed, 23 Sep 2009 19:51:21 -0400
Message-Id: <1253749920-18673-42-git-send-email-orenl@librato.com>
In-Reply-To: <1253749920-18673-1-git-send-email-orenl@librato.com>
References: <1253749920-18673-1-git-send-email-orenl@librato.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@osdl.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Serge Hallyn <serue@us.ibm.com>, Ingo Molnar <mingo@elte.hu>, Pavel Emelyanov <xemul@openvz.org>, Matt Helsley <matthltc@us.ibm.com>, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

From: Matt Helsley <matthltc@us.ibm.com>

These patches extend the use of the generic file checkpoint operation to
non-extX filesystems which have lseek operations that ensure we can save
and restore the files for later use. Note that this does not include
things like FUSE, network filesystems, or pseudo-filesystem kernel
interfaces.

Only compile and boot tested (on x86-32).

[Oren Laadan] Folded patch series into a single patch; original post
included 36 separate patches for individual filesystems:

  [PATCH 01/36] Add the checkpoint operation for affs files and directories.
  [PATCH 02/36] Add the checkpoint operation for befs directories.
  [PATCH 03/36] Add the checkpoint operation for bfs files and directories.
  [PATCH 04/36] Add the checkpoint operation for btrfs files and directories.
  [PATCH 05/36] Add the checkpoint operation for cramfs directories.
  [PATCH 06/36] Add the checkpoint operation for ecryptfs files and directories.
  [PATCH 07/36] Add the checkpoint operation for fat files and directories.
  [PATCH 08/36] Add the checkpoint operation for freevxfs directories.
  [PATCH 09/36] Add the checkpoint operation for hfs files and directories.
  [PATCH 10/36] Add the checkpoint operation for hfsplus files and directories.
  [PATCH 11/36] Add the checkpoint operation for hpfs files and directories.
  [PATCH 12/36] Add the checkpoint operation for hppfs files and directories.
  [PATCH 13/36] Add the checkpoint operation for iso directories.
  [PATCH 14/36] Add the checkpoint operation for jffs2 files and directories.
  [PATCH 15/36] Add the checkpoint operation for jfs files and directories.
  [PATCH 16/36] Add the checkpoint operation for regular nfs files and directories. Skip the various /proc files for now.
  [PATCH 17/36] Add the checkpoint operation for ntfs directories.
  [PATCH 18/36] Add the checkpoint operation for openromfs directories. Explicitly skip the properties for now.
  [PATCH 19/36] Add the checkpoint operation for qnx4 files and directories.
  [PATCH 20/36] Add the checkpoint operation for reiserfs files and directories.
  [PATCH 21/36] Add the checkpoint operation for romfs directories.
  [PATCH 22/36] Add the checkpoint operation for squashfs directories.
  [PATCH 23/36] Add the checkpoint operation for sysv filesystem files and directories.
  [PATCH 24/36] Add the checkpoint operation for ubifs files and directories.
  [PATCH 25/36] Add the checkpoint operation for udf filesystem files and directories.
  [PATCH 26/36] Add the checkpoint operation for xfs files and directories.
  [PATCH 27/36] Add checkpoint operation for efs directories.
  [PATCH 28/36] Add the checkpoint operation for generic, read-only files. At present, some/all files of the following filesystems use this generic definition:
  [PATCH 29/36] Add checkpoint operation for minix filesystem files and directories.
  [PATCH 30/36] Add checkpoint operations for omfs files and directories.
  [PATCH 31/36] Add checkpoint operations for ufs files and directories.
  [PATCH 32/36] Add checkpoint operations for ramfs files. NOTE: since simple_dir_operations are shared between multiple filesystems including ramfs, it's not currently possible to checkpoint open ramfs directories.
  [PATCH 33/36] Add the checkpoint operation for adfs files and directories.
  [PATCH 34/36] Add the checkpoint operation to exofs files and directories.
  [PATCH 35/36] Add the checkpoint operation to nilfs2 files and directories.
  [PATCH 36/36] Add checkpoint operations for UML host filesystem files and directories.

Signed-off-by: Matt Helsley <matthltc@us.ibm.com>
Acked-by: Oren Laadan <orenl@cs.columbia.edu>
Cc: linux-fsdevel@vger.kernel.org
---
 fs/adfs/dir.c               |    1 +
 fs/adfs/file.c              |    1 +
 fs/affs/dir.c               |    1 +
 fs/affs/file.c              |    1 +
 fs/befs/linuxvfs.c          |    1 +
 fs/bfs/dir.c                |    1 +
 fs/bfs/file.c               |    1 +
 fs/btrfs/file.c             |    1 +
 fs/btrfs/inode.c            |    1 +
 fs/btrfs/super.c            |    1 +
 fs/cramfs/inode.c           |    1 +
 fs/ecryptfs/file.c          |    2 ++
 fs/ecryptfs/miscdev.c       |    1 +
 fs/efs/dir.c                |    1 +
 fs/exofs/dir.c              |    1 +
 fs/exofs/file.c             |    1 +
 fs/fat/dir.c                |    1 +
 fs/fat/file.c               |    1 +
 fs/freevxfs/vxfs_lookup.c   |    1 +
 fs/hfs/dir.c                |    1 +
 fs/hfs/inode.c              |    1 +
 fs/hfsplus/dir.c            |    1 +
 fs/hfsplus/inode.c          |    1 +
 fs/hostfs/hostfs_kern.c     |    2 ++
 fs/hpfs/dir.c               |    1 +
 fs/hpfs/file.c              |    1 +
 fs/hppfs/hppfs.c            |    2 ++
 fs/isofs/dir.c              |    1 +
 fs/jffs2/dir.c              |    1 +
 fs/jffs2/file.c             |    1 +
 fs/jfs/file.c               |    1 +
 fs/jfs/namei.c              |    1 +
 fs/minix/dir.c              |    1 +
 fs/minix/file.c             |    1 +
 fs/nfs/dir.c                |    1 +
 fs/nfs/file.c               |    1 +
 fs/nilfs2/dir.c             |    2 +-
 fs/nilfs2/file.c            |    1 +
 fs/ntfs/dir.c               |    1 +
 fs/ntfs/file.c              |    3 ++-
 fs/omfs/dir.c               |    1 +
 fs/omfs/file.c              |    1 +
 fs/openpromfs/inode.c       |    2 ++
 fs/qnx4/dir.c               |    1 +
 fs/qnx4/file.c              |    1 +
 fs/ramfs/file-mmu.c         |    1 +
 fs/ramfs/file-nommu.c       |    1 +
 fs/read_write.c             |    1 +
 fs/reiserfs/dir.c           |    1 +
 fs/reiserfs/file.c          |    1 +
 fs/romfs/mmap-nommu.c       |    1 +
 fs/romfs/super.c            |    1 +
 fs/squashfs/dir.c           |    3 ++-
 fs/sysv/dir.c               |    1 +
 fs/sysv/file.c              |    1 +
 fs/ubifs/debug.c            |    1 +
 fs/ubifs/dir.c              |    1 +
 fs/ubifs/file.c             |    1 +
 fs/udf/dir.c                |    1 +
 fs/udf/file.c               |    1 +
 fs/ufs/dir.c                |    1 +
 fs/ufs/file.c               |    1 +
 fs/xfs/linux-2.6/xfs_file.c |    2 ++
 63 files changed, 70 insertions(+), 3 deletions(-)

diff --git a/fs/adfs/dir.c b/fs/adfs/dir.c
index 23aa52f..7106f32 100644
--- a/fs/adfs/dir.c
+++ b/fs/adfs/dir.c
@@ -198,6 +198,7 @@ const struct file_operations adfs_dir_operations = {
 	.llseek		= generic_file_llseek,
 	.readdir	= adfs_readdir,
 	.fsync		= simple_fsync,
+	.checkpoint	= generic_file_checkpoint,
 };
 
 static int
diff --git a/fs/adfs/file.c b/fs/adfs/file.c
index 005ea34..97bd298 100644
--- a/fs/adfs/file.c
+++ b/fs/adfs/file.c
@@ -30,6 +30,7 @@ const struct file_operations adfs_file_operations = {
 	.write		= do_sync_write,
 	.aio_write	= generic_file_aio_write,
 	.splice_read	= generic_file_splice_read,
+	.checkpoint	= generic_file_checkpoint,
 };
 
 const struct inode_operations adfs_file_inode_operations = {
diff --git a/fs/affs/dir.c b/fs/affs/dir.c
index 8ca8f3a..6cc5e43 100644
--- a/fs/affs/dir.c
+++ b/fs/affs/dir.c
@@ -22,6 +22,7 @@ const struct file_operations affs_dir_operations = {
 	.llseek		= generic_file_llseek,
 	.readdir	= affs_readdir,
 	.fsync		= affs_file_fsync,
+	.checkpoint	= generic_file_checkpoint,
 };
 
 /*
diff --git a/fs/affs/file.c b/fs/affs/file.c
index 184e55c..d580a12 100644
--- a/fs/affs/file.c
+++ b/fs/affs/file.c
@@ -36,6 +36,7 @@ const struct file_operations affs_file_operations = {
 	.release	= affs_file_release,
 	.fsync		= affs_file_fsync,
 	.splice_read	= generic_file_splice_read,
+	.checkpoint	= generic_file_checkpoint,
 };
 
 const struct inode_operations affs_file_inode_operations = {
diff --git a/fs/befs/linuxvfs.c b/fs/befs/linuxvfs.c
index 615d549..6c46cb8 100644
--- a/fs/befs/linuxvfs.c
+++ b/fs/befs/linuxvfs.c
@@ -67,6 +67,7 @@ static const struct file_operations befs_dir_operations = {
 	.read		= generic_read_dir,
 	.readdir	= befs_readdir,
 	.llseek		= generic_file_llseek,
+	.checkpoint	= generic_file_checkpoint,
 };
 
 static const struct inode_operations befs_dir_inode_operations = {
diff --git a/fs/bfs/dir.c b/fs/bfs/dir.c
index 1e41aad..d78015e 100644
--- a/fs/bfs/dir.c
+++ b/fs/bfs/dir.c
@@ -80,6 +80,7 @@ const struct file_operations bfs_dir_operations = {
 	.readdir	= bfs_readdir,
 	.fsync		= simple_fsync,
 	.llseek		= generic_file_llseek,
+	.checkpoint	= generic_file_checkpoint,
 };
 
 extern void dump_imap(const char *, struct super_block *);
diff --git a/fs/bfs/file.c b/fs/bfs/file.c
index 88b9a3f..7f61ed6 100644
--- a/fs/bfs/file.c
+++ b/fs/bfs/file.c
@@ -29,6 +29,7 @@ const struct file_operations bfs_file_operations = {
 	.aio_write	= generic_file_aio_write,
 	.mmap		= generic_file_mmap,
 	.splice_read	= generic_file_splice_read,
+	.checkpoint	= generic_file_checkpoint,
 };
 
 static int bfs_move_block(unsigned long from, unsigned long to,
diff --git a/fs/btrfs/file.c b/fs/btrfs/file.c
index 4b83397..6425f19 100644
--- a/fs/btrfs/file.c
+++ b/fs/btrfs/file.c
@@ -1229,4 +1229,5 @@ struct file_operations btrfs_file_operations = {
 #ifdef CONFIG_COMPAT
 	.compat_ioctl	= btrfs_ioctl,
 #endif
+	.checkpoint	= generic_file_checkpoint,
 };
diff --git a/fs/btrfs/inode.c b/fs/btrfs/inode.c
index 59cba18..a13b1b7 100644
--- a/fs/btrfs/inode.c
+++ b/fs/btrfs/inode.c
@@ -5233,6 +5233,7 @@ static struct file_operations btrfs_dir_file_operations = {
 #endif
 	.release        = btrfs_release_file,
 	.fsync		= btrfs_sync_file,
+	.checkpoint	= generic_file_checkpoint,
 };
 
 static struct extent_io_ops btrfs_extent_io_ops = {
diff --git a/fs/btrfs/super.c b/fs/btrfs/super.c
index 6d6d06c..58569ba 100644
--- a/fs/btrfs/super.c
+++ b/fs/btrfs/super.c
@@ -694,6 +694,7 @@ static const struct file_operations btrfs_ctl_fops = {
 	.unlocked_ioctl	 = btrfs_control_ioctl,
 	.compat_ioctl = btrfs_control_ioctl,
 	.owner	 = THIS_MODULE,
+	.checkpoint = generic_file_checkpoint,
 };
 
 static struct miscdevice btrfs_misc = {
diff --git a/fs/cramfs/inode.c b/fs/cramfs/inode.c
index dd3634e..0927503 100644
--- a/fs/cramfs/inode.c
+++ b/fs/cramfs/inode.c
@@ -532,6 +532,7 @@ static const struct file_operations cramfs_directory_operations = {
 	.llseek		= generic_file_llseek,
 	.read		= generic_read_dir,
 	.readdir	= cramfs_readdir,
+	.checkpoint	= generic_file_checkpoint,
 };
 
 static const struct inode_operations cramfs_dir_inode_operations = {
diff --git a/fs/ecryptfs/file.c b/fs/ecryptfs/file.c
index 9e94405..e6d2523 100644
--- a/fs/ecryptfs/file.c
+++ b/fs/ecryptfs/file.c
@@ -306,6 +306,7 @@ const struct file_operations ecryptfs_dir_fops = {
 	.fsync = ecryptfs_fsync,
 	.fasync = ecryptfs_fasync,
 	.splice_read = generic_file_splice_read,
+	.checkpoint = generic_file_checkpoint,
 };
 
 const struct file_operations ecryptfs_main_fops = {
@@ -323,6 +324,7 @@ const struct file_operations ecryptfs_main_fops = {
 	.fsync = ecryptfs_fsync,
 	.fasync = ecryptfs_fasync,
 	.splice_read = generic_file_splice_read,
+	.checkpoint = generic_file_checkpoint,
 };
 
 static int
diff --git a/fs/ecryptfs/miscdev.c b/fs/ecryptfs/miscdev.c
index 4ec8f61..9fd9b39 100644
--- a/fs/ecryptfs/miscdev.c
+++ b/fs/ecryptfs/miscdev.c
@@ -481,6 +481,7 @@ static const struct file_operations ecryptfs_miscdev_fops = {
 	.read    = ecryptfs_miscdev_read,
 	.write   = ecryptfs_miscdev_write,
 	.release = ecryptfs_miscdev_release,
+	.checkpoint = generic_file_checkpoint,
 };
 
 static struct miscdevice ecryptfs_miscdev = {
diff --git a/fs/efs/dir.c b/fs/efs/dir.c
index 7ee6f7e..da344b8 100644
--- a/fs/efs/dir.c
+++ b/fs/efs/dir.c
@@ -13,6 +13,7 @@ const struct file_operations efs_dir_operations = {
 	.llseek		= generic_file_llseek,
 	.read		= generic_read_dir,
 	.readdir	= efs_readdir,
+	.checkpoint	= generic_file_checkpoint,
 };
 
 const struct inode_operations efs_dir_inode_operations = {
diff --git a/fs/exofs/dir.c b/fs/exofs/dir.c
index 4cfab1c..f6693d3 100644
--- a/fs/exofs/dir.c
+++ b/fs/exofs/dir.c
@@ -667,4 +667,5 @@ const struct file_operations exofs_dir_operations = {
 	.llseek		= generic_file_llseek,
 	.read		= generic_read_dir,
 	.readdir	= exofs_readdir,
+	.checkpoint	= generic_file_checkpoint,
 };
diff --git a/fs/exofs/file.c b/fs/exofs/file.c
index 839b9dc..257e9da 100644
--- a/fs/exofs/file.c
+++ b/fs/exofs/file.c
@@ -73,6 +73,7 @@ static int exofs_flush(struct file *file, fl_owner_t id)
 
 const struct file_operations exofs_file_operations = {
 	.llseek		= generic_file_llseek,
+	.checkpoint	= generic_file_checkpoint,
 	.read		= do_sync_read,
 	.write		= do_sync_write,
 	.aio_read	= generic_file_aio_read,
diff --git a/fs/fat/dir.c b/fs/fat/dir.c
index 530b4ca..e3fa353 100644
--- a/fs/fat/dir.c
+++ b/fs/fat/dir.c
@@ -841,6 +841,7 @@ const struct file_operations fat_dir_operations = {
 	.compat_ioctl	= fat_compat_dir_ioctl,
 #endif
 	.fsync		= fat_file_fsync,
+	.checkpoint	= generic_file_checkpoint,
 };
 
 static int fat_get_short_entry(struct inode *dir, loff_t *pos,
diff --git a/fs/fat/file.c b/fs/fat/file.c
index f042b96..56351c2 100644
--- a/fs/fat/file.c
+++ b/fs/fat/file.c
@@ -162,6 +162,7 @@ const struct file_operations fat_file_operations = {
 	.ioctl		= fat_generic_ioctl,
 	.fsync		= fat_file_fsync,
 	.splice_read	= generic_file_splice_read,
+	.checkpoint	= generic_file_checkpoint,
 };
 
 static int fat_cont_expand(struct inode *inode, loff_t size)
diff --git a/fs/freevxfs/vxfs_lookup.c b/fs/freevxfs/vxfs_lookup.c
index aee049c..3a09132 100644
--- a/fs/freevxfs/vxfs_lookup.c
+++ b/fs/freevxfs/vxfs_lookup.c
@@ -58,6 +58,7 @@ const struct inode_operations vxfs_dir_inode_ops = {
 
 const struct file_operations vxfs_dir_operations = {
 	.readdir =		vxfs_readdir,
+	.checkpoint =		generic_file_checkpoint,
 };
 
  
diff --git a/fs/hfs/dir.c b/fs/hfs/dir.c
index 7c69b98..8d90a24 100644
--- a/fs/hfs/dir.c
+++ b/fs/hfs/dir.c
@@ -318,6 +318,7 @@ const struct file_operations hfs_dir_operations = {
 	.readdir	= hfs_readdir,
 	.llseek		= generic_file_llseek,
 	.release	= hfs_dir_release,
+	.checkpoint	= generic_file_checkpoint,
 };
 
 const struct inode_operations hfs_dir_inode_operations = {
diff --git a/fs/hfs/inode.c b/fs/hfs/inode.c
index a1cbff2..bf8950f 100644
--- a/fs/hfs/inode.c
+++ b/fs/hfs/inode.c
@@ -607,6 +607,7 @@ static const struct file_operations hfs_file_operations = {
 	.fsync		= file_fsync,
 	.open		= hfs_file_open,
 	.release	= hfs_file_release,
+	.checkpoint	= generic_file_checkpoint,
 };
 
 static const struct inode_operations hfs_file_inode_operations = {
diff --git a/fs/hfsplus/dir.c b/fs/hfsplus/dir.c
index 5f40236..41fbf2d 100644
--- a/fs/hfsplus/dir.c
+++ b/fs/hfsplus/dir.c
@@ -497,4 +497,5 @@ const struct file_operations hfsplus_dir_operations = {
 	.ioctl          = hfsplus_ioctl,
 	.llseek		= generic_file_llseek,
 	.release	= hfsplus_dir_release,
+	.checkpoint	= generic_file_checkpoint,
 };
diff --git a/fs/hfsplus/inode.c b/fs/hfsplus/inode.c
index 1bcf597..19abd7e 100644
--- a/fs/hfsplus/inode.c
+++ b/fs/hfsplus/inode.c
@@ -286,6 +286,7 @@ static const struct file_operations hfsplus_file_operations = {
 	.open		= hfsplus_file_open,
 	.release	= hfsplus_file_release,
 	.ioctl          = hfsplus_ioctl,
+	.checkpoint	= generic_file_checkpoint,
 };
 
 struct inode *hfsplus_new_inode(struct super_block *sb, int mode)
diff --git a/fs/hostfs/hostfs_kern.c b/fs/hostfs/hostfs_kern.c
index 032604e..67e2356 100644
--- a/fs/hostfs/hostfs_kern.c
+++ b/fs/hostfs/hostfs_kern.c
@@ -417,6 +417,7 @@ int hostfs_fsync(struct file *file, struct dentry *dentry, int datasync)
 
 static const struct file_operations hostfs_file_fops = {
 	.llseek		= generic_file_llseek,
+	.checkpoint	= generic_file_checkpoint,
 	.read		= do_sync_read,
 	.splice_read	= generic_file_splice_read,
 	.aio_read	= generic_file_aio_read,
@@ -430,6 +431,7 @@ static const struct file_operations hostfs_file_fops = {
 
 static const struct file_operations hostfs_dir_fops = {
 	.llseek		= generic_file_llseek,
+	.checkpoint	= generic_file_checkpoint,
 	.readdir	= hostfs_readdir,
 	.read		= generic_read_dir,
 };
diff --git a/fs/hpfs/dir.c b/fs/hpfs/dir.c
index 8865c94..dcde10f 100644
--- a/fs/hpfs/dir.c
+++ b/fs/hpfs/dir.c
@@ -322,4 +322,5 @@ const struct file_operations hpfs_dir_ops =
 	.readdir	= hpfs_readdir,
 	.release	= hpfs_dir_release,
 	.fsync		= hpfs_file_fsync,
+	.checkpoint	= generic_file_checkpoint,
 };
diff --git a/fs/hpfs/file.c b/fs/hpfs/file.c
index 3efabff..f1211f0 100644
--- a/fs/hpfs/file.c
+++ b/fs/hpfs/file.c
@@ -139,6 +139,7 @@ const struct file_operations hpfs_file_ops =
 	.release	= hpfs_file_release,
 	.fsync		= hpfs_file_fsync,
 	.splice_read	= generic_file_splice_read,
+	.checkpoint	= generic_file_checkpoint,
 };
 
 const struct inode_operations hpfs_file_iops =
diff --git a/fs/hppfs/hppfs.c b/fs/hppfs/hppfs.c
index a5089a6..f132fa2 100644
--- a/fs/hppfs/hppfs.c
+++ b/fs/hppfs/hppfs.c
@@ -546,6 +546,7 @@ static const struct file_operations hppfs_file_fops = {
 	.read		= hppfs_read,
 	.write		= hppfs_write,
 	.open		= hppfs_open,
+	.checkpoint	= generic_file_checkpoint,
 };
 
 struct hppfs_dirent {
@@ -597,6 +598,7 @@ static const struct file_operations hppfs_dir_fops = {
 	.readdir	= hppfs_readdir,
 	.open		= hppfs_dir_open,
 	.fsync		= hppfs_fsync,
+	.checkpoint	= generic_file_checkpoint,
 };
 
 static int hppfs_statfs(struct dentry *dentry, struct kstatfs *sf)
diff --git a/fs/isofs/dir.c b/fs/isofs/dir.c
index 8ba5441..848059d 100644
--- a/fs/isofs/dir.c
+++ b/fs/isofs/dir.c
@@ -273,6 +273,7 @@ const struct file_operations isofs_dir_operations =
 {
 	.read = generic_read_dir,
 	.readdir = isofs_readdir,
+	.checkpoint = generic_file_checkpoint,
 };
 
 /*
diff --git a/fs/jffs2/dir.c b/fs/jffs2/dir.c
index 6f60cc9..c2b6487 100644
--- a/fs/jffs2/dir.c
+++ b/fs/jffs2/dir.c
@@ -41,6 +41,7 @@ const struct file_operations jffs2_dir_operations =
 	.unlocked_ioctl=jffs2_ioctl,
 	.fsync =	jffs2_fsync,
 	.llseek =	generic_file_llseek,
+	.checkpoint =	generic_file_checkpoint,
 };
 
 
diff --git a/fs/jffs2/file.c b/fs/jffs2/file.c
index 23c9475..7e5d2e2 100644
--- a/fs/jffs2/file.c
+++ b/fs/jffs2/file.c
@@ -50,6 +50,7 @@ const struct file_operations jffs2_file_operations =
 	.mmap =		generic_file_readonly_mmap,
 	.fsync =	jffs2_fsync,
 	.splice_read =	generic_file_splice_read,
+	.checkpoint =	generic_file_checkpoint,
 };
 
 /* jffs2_file_inode_operations */
diff --git a/fs/jfs/file.c b/fs/jfs/file.c
index 7f6063a..90ab090 100644
--- a/fs/jfs/file.c
+++ b/fs/jfs/file.c
@@ -116,4 +116,5 @@ const struct file_operations jfs_file_operations = {
 #ifdef CONFIG_COMPAT
 	.compat_ioctl	= jfs_compat_ioctl,
 #endif
+	.checkpoint	= generic_file_checkpoint,
 };
diff --git a/fs/jfs/namei.c b/fs/jfs/namei.c
index 514ee2e..5486db9 100644
--- a/fs/jfs/namei.c
+++ b/fs/jfs/namei.c
@@ -1556,6 +1556,7 @@ const struct file_operations jfs_dir_operations = {
 	.compat_ioctl	= jfs_compat_ioctl,
 #endif
 	.llseek		= generic_file_llseek,
+	.checkpoint	= generic_file_checkpoint,
 };
 
 static int jfs_ci_hash(struct dentry *dir, struct qstr *this)
diff --git a/fs/minix/dir.c b/fs/minix/dir.c
index d407e7a..9cf04af 100644
--- a/fs/minix/dir.c
+++ b/fs/minix/dir.c
@@ -23,6 +23,7 @@ const struct file_operations minix_dir_operations = {
 	.read		= generic_read_dir,
 	.readdir	= minix_readdir,
 	.fsync		= simple_fsync,
+	.checkpoint	= generic_file_checkpoint,
 };
 
 static inline void dir_put_page(struct page *page)
diff --git a/fs/minix/file.c b/fs/minix/file.c
index 3eec3e6..2048d09 100644
--- a/fs/minix/file.c
+++ b/fs/minix/file.c
@@ -21,6 +21,7 @@ const struct file_operations minix_file_operations = {
 	.mmap		= generic_file_mmap,
 	.fsync		= simple_fsync,
 	.splice_read	= generic_file_splice_read,
+	.checkpoint	= generic_file_checkpoint,
 };
 
 const struct inode_operations minix_file_inode_operations = {
diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 32062c3..43b9025 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -63,6 +63,7 @@ const struct file_operations nfs_dir_operations = {
 	.open		= nfs_opendir,
 	.release	= nfs_release,
 	.fsync		= nfs_fsync_dir,
+	.checkpoint	= generic_file_checkpoint,
 };
 
 const struct inode_operations nfs_dir_inode_operations = {
diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 0506232..813fd8d 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -78,6 +78,7 @@ const struct file_operations nfs_file_operations = {
 	.splice_write	= nfs_file_splice_write,
 	.check_flags	= nfs_check_flags,
 	.setlease	= nfs_setlease,
+	.checkpoint	= generic_file_checkpoint,
 };
 
 const struct inode_operations nfs_file_inode_operations = {
diff --git a/fs/nilfs2/dir.c b/fs/nilfs2/dir.c
index 1a4fa04..afa0f80 100644
--- a/fs/nilfs2/dir.c
+++ b/fs/nilfs2/dir.c
@@ -706,5 +706,5 @@ struct file_operations nilfs_dir_operations = {
 	.compat_ioctl	= nilfs_ioctl,
 #endif	/* CONFIG_COMPAT */
 	.fsync		= nilfs_sync_file,
-
+	.checkpoint	= generic_file_checkpoint,
 };
diff --git a/fs/nilfs2/file.c b/fs/nilfs2/file.c
index 6bd84a0..0f27ab5 100644
--- a/fs/nilfs2/file.c
+++ b/fs/nilfs2/file.c
@@ -136,6 +136,7 @@ static int nilfs_file_mmap(struct file *file, struct vm_area_struct *vma)
  */
 struct file_operations nilfs_file_operations = {
 	.llseek		= generic_file_llseek,
+	.checkpoint	= generic_file_checkpoint,
 	.read		= do_sync_read,
 	.write		= do_sync_write,
 	.aio_read	= generic_file_aio_read,
diff --git a/fs/ntfs/dir.c b/fs/ntfs/dir.c
index 5a9e344..4fe3759 100644
--- a/fs/ntfs/dir.c
+++ b/fs/ntfs/dir.c
@@ -1572,4 +1572,5 @@ const struct file_operations ntfs_dir_ops = {
 	/*.ioctl	= ,*/			/* Perform function on the
 						   mounted filesystem. */
 	.open		= ntfs_dir_open,	/* Open directory. */
+	.checkpoint	= generic_file_checkpoint,
 };
diff --git a/fs/ntfs/file.c b/fs/ntfs/file.c
index 3140a44..3f75c5e 100644
--- a/fs/ntfs/file.c
+++ b/fs/ntfs/file.c
@@ -2272,7 +2272,7 @@ const struct file_operations ntfs_file_ops = {
 						    mounted filesystem. */
 	.mmap		= generic_file_mmap,	 /* Mmap file. */
 	.open		= ntfs_file_open,	 /* Open file. */
-	.splice_read	= generic_file_splice_read /* Zero-copy data send with
+	.splice_read	= generic_file_splice_read, /* Zero-copy data send with
 						    the data source being on
 						    the ntfs partition.  We do
 						    not need to care about the
@@ -2282,6 +2282,7 @@ const struct file_operations ntfs_file_ops = {
 						    on the ntfs partition.  We
 						    do not need to care about
 						    the data source. */
+	.checkpoint	= generic_file_checkpoint,
 };
 
 const struct inode_operations ntfs_file_inode_ops = {
diff --git a/fs/omfs/dir.c b/fs/omfs/dir.c
index c7275cf..5ed9cb3 100644
--- a/fs/omfs/dir.c
+++ b/fs/omfs/dir.c
@@ -502,4 +502,5 @@ struct file_operations omfs_dir_operations = {
 	.read = generic_read_dir,
 	.readdir = omfs_readdir,
 	.llseek = generic_file_llseek,
+	.checkpoint = generic_file_checkpoint,
 };
diff --git a/fs/omfs/file.c b/fs/omfs/file.c
index d17e774..c85fb31 100644
--- a/fs/omfs/file.c
+++ b/fs/omfs/file.c
@@ -331,6 +331,7 @@ struct file_operations omfs_file_operations = {
 	.mmap = generic_file_mmap,
 	.fsync = simple_fsync,
 	.splice_read = generic_file_splice_read,
+	.checkpoint = generic_file_checkpoint,
 };
 
 struct inode_operations omfs_file_inops = {
diff --git a/fs/openpromfs/inode.c b/fs/openpromfs/inode.c
index ffcd04f..d1f0677 100644
--- a/fs/openpromfs/inode.c
+++ b/fs/openpromfs/inode.c
@@ -160,6 +160,7 @@ static const struct file_operations openpromfs_prop_ops = {
 	.read		= seq_read,
 	.llseek		= seq_lseek,
 	.release	= seq_release,
+	.checkpoint	= NULL,
 };
 
 static int openpromfs_readdir(struct file *, void *, filldir_t);
@@ -168,6 +169,7 @@ static const struct file_operations openprom_operations = {
 	.read		= generic_read_dir,
 	.readdir	= openpromfs_readdir,
 	.llseek		= generic_file_llseek,
+	.checkpoint	= generic_file_checkpoint,
 };
 
 static struct dentry *openpromfs_lookup(struct inode *, struct dentry *, struct nameidata *);
diff --git a/fs/qnx4/dir.c b/fs/qnx4/dir.c
index 003c68f..ca99e01 100644
--- a/fs/qnx4/dir.c
+++ b/fs/qnx4/dir.c
@@ -80,6 +80,7 @@ const struct file_operations qnx4_dir_operations =
 	.read		= generic_read_dir,
 	.readdir	= qnx4_readdir,
 	.fsync		= simple_fsync,
+	.checkpoint	= generic_file_checkpoint,
 };
 
 const struct inode_operations qnx4_dir_inode_operations =
diff --git a/fs/qnx4/file.c b/fs/qnx4/file.c
index 09b170a..8aaa882 100644
--- a/fs/qnx4/file.c
+++ b/fs/qnx4/file.c
@@ -30,6 +30,7 @@ const struct file_operations qnx4_file_operations =
 	.aio_write	= generic_file_aio_write,
 	.fsync		= simple_fsync,
 #endif
+	.checkpoint	= generic_file_checkpoint,
 };
 
 const struct inode_operations qnx4_file_inode_operations =
diff --git a/fs/ramfs/file-mmu.c b/fs/ramfs/file-mmu.c
index 78f613c..4430239 100644
--- a/fs/ramfs/file-mmu.c
+++ b/fs/ramfs/file-mmu.c
@@ -47,6 +47,7 @@ const struct file_operations ramfs_file_operations = {
 	.splice_read	= generic_file_splice_read,
 	.splice_write	= generic_file_splice_write,
 	.llseek		= generic_file_llseek,
+	.checkpoint	= generic_file_checkpoint,
 };
 
 const struct inode_operations ramfs_file_inode_operations = {
diff --git a/fs/ramfs/file-nommu.c b/fs/ramfs/file-nommu.c
index 11f0c06..d645bb3 100644
--- a/fs/ramfs/file-nommu.c
+++ b/fs/ramfs/file-nommu.c
@@ -45,6 +45,7 @@ const struct file_operations ramfs_file_operations = {
 	.splice_read		= generic_file_splice_read,
 	.splice_write		= generic_file_splice_write,
 	.llseek			= generic_file_llseek,
+	.checkpoint		= generic_file_checkpoint,
 };
 
 const struct inode_operations ramfs_file_inode_operations = {
diff --git a/fs/read_write.c b/fs/read_write.c
index d331975..d314234 100644
--- a/fs/read_write.c
+++ b/fs/read_write.c
@@ -27,6 +27,7 @@ const struct file_operations generic_ro_fops = {
 	.aio_read	= generic_file_aio_read,
 	.mmap		= generic_file_readonly_mmap,
 	.splice_read	= generic_file_splice_read,
+	.checkpoint	= generic_file_checkpoint,
 };
 
 EXPORT_SYMBOL(generic_ro_fops);
diff --git a/fs/reiserfs/dir.c b/fs/reiserfs/dir.c
index 6d2668f..40ce3fa 100644
--- a/fs/reiserfs/dir.c
+++ b/fs/reiserfs/dir.c
@@ -24,6 +24,7 @@ const struct file_operations reiserfs_dir_operations = {
 #ifdef CONFIG_COMPAT
 	.compat_ioctl = reiserfs_compat_ioctl,
 #endif
+	.checkpoint = generic_file_checkpoint,
 };
 
 static int reiserfs_dir_fsync(struct file *filp, struct dentry *dentry,
diff --git a/fs/reiserfs/file.c b/fs/reiserfs/file.c
index 9f43666..a5dcc02 100644
--- a/fs/reiserfs/file.c
+++ b/fs/reiserfs/file.c
@@ -297,6 +297,7 @@ const struct file_operations reiserfs_file_operations = {
 	.splice_read = generic_file_splice_read,
 	.splice_write = generic_file_splice_write,
 	.llseek = generic_file_llseek,
+	.checkpoint = generic_file_checkpoint,
 };
 
 const struct inode_operations reiserfs_file_inode_operations = {
diff --git a/fs/romfs/mmap-nommu.c b/fs/romfs/mmap-nommu.c
index f0511e8..03c24d9 100644
--- a/fs/romfs/mmap-nommu.c
+++ b/fs/romfs/mmap-nommu.c
@@ -72,4 +72,5 @@ const struct file_operations romfs_ro_fops = {
 	.splice_read		= generic_file_splice_read,
 	.mmap			= romfs_mmap,
 	.get_unmapped_area	= romfs_get_unmapped_area,
+	.checkpoint		= generic_file_checkpoint,
 };
diff --git a/fs/romfs/super.c b/fs/romfs/super.c
index 4ab3c03..7b6e951 100644
--- a/fs/romfs/super.c
+++ b/fs/romfs/super.c
@@ -282,6 +282,7 @@ error:
 static const struct file_operations romfs_dir_operations = {
 	.read		= generic_read_dir,
 	.readdir	= romfs_readdir,
+	.checkpoint	= generic_file_checkpoint,
 };
 
 static struct inode_operations romfs_dir_inode_operations = {
diff --git a/fs/squashfs/dir.c b/fs/squashfs/dir.c
index 566b0ea..b0c5336 100644
--- a/fs/squashfs/dir.c
+++ b/fs/squashfs/dir.c
@@ -231,5 +231,6 @@ failed_read:
 
 const struct file_operations squashfs_dir_ops = {
 	.read = generic_read_dir,
-	.readdir = squashfs_readdir
+	.readdir = squashfs_readdir,
+	.checkpoint = generic_file_checkpoint,
 };
diff --git a/fs/sysv/dir.c b/fs/sysv/dir.c
index 4e50286..53acd29 100644
--- a/fs/sysv/dir.c
+++ b/fs/sysv/dir.c
@@ -25,6 +25,7 @@ const struct file_operations sysv_dir_operations = {
 	.read		= generic_read_dir,
 	.readdir	= sysv_readdir,
 	.fsync		= simple_fsync,
+	.checkpoint	= generic_file_checkpoint,
 };
 
 static inline void dir_put_page(struct page *page)
diff --git a/fs/sysv/file.c b/fs/sysv/file.c
index 96340c0..aee556d 100644
--- a/fs/sysv/file.c
+++ b/fs/sysv/file.c
@@ -28,6 +28,7 @@ const struct file_operations sysv_file_operations = {
 	.mmap		= generic_file_mmap,
 	.fsync		= simple_fsync,
 	.splice_read	= generic_file_splice_read,
+	.checkpoint	= generic_file_checkpoint,
 };
 
 const struct inode_operations sysv_file_inode_operations = {
diff --git a/fs/ubifs/debug.c b/fs/ubifs/debug.c
index ce2cd83..69a8892 100644
--- a/fs/ubifs/debug.c
+++ b/fs/ubifs/debug.c
@@ -2530,6 +2530,7 @@ static ssize_t write_debugfs_file(struct file *file, const char __user *buf,
 static const struct file_operations dfs_fops = {
 	.open = open_debugfs_file,
 	.write = write_debugfs_file,
+	.checkpoint = generic_file_checkpoint,
 	.owner = THIS_MODULE,
 };
 
diff --git a/fs/ubifs/dir.c b/fs/ubifs/dir.c
index 552fb01..89ab2aa 100644
--- a/fs/ubifs/dir.c
+++ b/fs/ubifs/dir.c
@@ -1228,4 +1228,5 @@ const struct file_operations ubifs_dir_operations = {
 #ifdef CONFIG_COMPAT
 	.compat_ioctl   = ubifs_compat_ioctl,
 #endif
+	.checkpoint     = generic_file_checkpoint,
 };
diff --git a/fs/ubifs/file.c b/fs/ubifs/file.c
index 6d34dc7..2d94676 100644
--- a/fs/ubifs/file.c
+++ b/fs/ubifs/file.c
@@ -1595,4 +1595,5 @@ const struct file_operations ubifs_file_operations = {
 #ifdef CONFIG_COMPAT
 	.compat_ioctl   = ubifs_compat_ioctl,
 #endif
+	.checkpoint     = generic_file_checkpoint,
 };
diff --git a/fs/udf/dir.c b/fs/udf/dir.c
index 61d9a76..6586dbe 100644
--- a/fs/udf/dir.c
+++ b/fs/udf/dir.c
@@ -211,4 +211,5 @@ const struct file_operations udf_dir_operations = {
 	.readdir		= udf_readdir,
 	.ioctl			= udf_ioctl,
 	.fsync			= simple_fsync,
+	.checkpoint		= generic_file_checkpoint,
 };
diff --git a/fs/udf/file.c b/fs/udf/file.c
index 7464305..33c63a8 100644
--- a/fs/udf/file.c
+++ b/fs/udf/file.c
@@ -212,6 +212,7 @@ const struct file_operations udf_file_operations = {
 	.fsync			= simple_fsync,
 	.splice_read		= generic_file_splice_read,
 	.llseek			= generic_file_llseek,
+	.checkpoint		= generic_file_checkpoint,
 };
 
 const struct inode_operations udf_file_inode_operations = {
diff --git a/fs/ufs/dir.c b/fs/ufs/dir.c
index 6f671f1..9379010 100644
--- a/fs/ufs/dir.c
+++ b/fs/ufs/dir.c
@@ -668,4 +668,5 @@ const struct file_operations ufs_dir_operations = {
 	.readdir	= ufs_readdir,
 	.fsync		= simple_fsync,
 	.llseek		= generic_file_llseek,
+	.checkpoint	= generic_file_checkpoint,
 };
diff --git a/fs/ufs/file.c b/fs/ufs/file.c
index 73655c6..15c8616 100644
--- a/fs/ufs/file.c
+++ b/fs/ufs/file.c
@@ -43,4 +43,5 @@ const struct file_operations ufs_file_operations = {
 	.open           = generic_file_open,
 	.fsync		= simple_fsync,
 	.splice_read	= generic_file_splice_read,
+	.checkpoint	= generic_file_checkpoint,
 };
diff --git a/fs/xfs/linux-2.6/xfs_file.c b/fs/xfs/linux-2.6/xfs_file.c
index 0542fd5..2b4bdb6 100644
--- a/fs/xfs/linux-2.6/xfs_file.c
+++ b/fs/xfs/linux-2.6/xfs_file.c
@@ -257,6 +257,7 @@ const struct file_operations xfs_file_operations = {
 #ifdef HAVE_FOP_OPEN_EXEC
 	.open_exec	= xfs_file_open_exec,
 #endif
+	.checkpoint	= generic_file_checkpoint,
 };
 
 const struct file_operations xfs_dir_file_operations = {
@@ -269,6 +270,7 @@ const struct file_operations xfs_dir_file_operations = {
 	.compat_ioctl	= xfs_file_compat_ioctl,
 #endif
 	.fsync		= xfs_file_fsync,
+	.checkpoint	= generic_file_checkpoint,
 };
 
 static struct vm_operations_struct xfs_file_vm_ops = {
-- 
1.6.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
