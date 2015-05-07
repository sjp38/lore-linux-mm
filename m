Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f178.google.com (mail-qk0-f178.google.com [209.85.220.178])
	by kanga.kvack.org (Postfix) with ESMTP id 0DB596B0032
	for <linux-mm@kvack.org>; Thu,  7 May 2015 15:26:25 -0400 (EDT)
Received: by qku63 with SMTP id 63so34546907qku.3
        for <linux-mm@kvack.org>; Thu, 07 May 2015 12:26:24 -0700 (PDT)
Received: from relay4-d.mail.gandi.net (relay4-d.mail.gandi.net. [2001:4b98:c:538::196])
        by mx.google.com with ESMTPS id f199si250529qhc.20.2015.05.07.12.26.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 07 May 2015 12:26:23 -0700 (PDT)
Date: Thu, 7 May 2015 12:26:15 -0700
From: Josh Triplett <josh@joshtriplett.org>
Subject: [PATCHv2] devpts: If initialization failed, don't crash when opening
 /dev/ptmx
Message-ID: <20150507192615.GA16784@jtriplet-mobl1>
References: <20150507003547.GA6862@jtriplet-mobl1>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150507003547.GA6862@jtriplet-mobl1>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Fengguang Wu <fengguang.wu@intel.com>, Iulia Manda <iulia.manda21@gmail.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Fabian Frederick <fabf@skynet.be>, Peter Hurley <peter@hurleysoftware.com>, Linux Memory Management List <linux-mm@kvack.org>, linux-kernel@vger.kernel.org

If devpts failed to initialize, it would store an ERR_PTR in the global
devpts_mnt.  A subsequent open of /dev/ptmx would call devpts_new_index,
which would dereference devpts_mnt and crash.

Avoid storing invalid values in devpts_mnt; leave it NULL instead.
Make both devpts_new_index and devpts_pty_new fail gracefully with
ENODEV in that case, which then becomes the return value to the
userspace open call on /dev/ptmx.

Signed-off-by: Josh Triplett <josh@joshtriplett.org>
Reviewed-by: Peter Hurley <peter@hurleysoftware.com>
---

v2: Fix copy-paste error caught by Peter Hurley.

As mentioned in v1, this is separate from fixing the bug that makes devpts fail
to initialize in the first place, but this makes devpts fail gracefully rather
than crashing.

 fs/devpts/inode.c | 30 +++++++++++++++++++++++-------
 1 file changed, 23 insertions(+), 7 deletions(-)

diff --git a/fs/devpts/inode.c b/fs/devpts/inode.c
index cfe8466..016687b 100644
--- a/fs/devpts/inode.c
+++ b/fs/devpts/inode.c
@@ -142,6 +142,8 @@ static inline struct super_block *pts_sb_from_inode(struct inode *inode)
 	if (inode->i_sb->s_magic == DEVPTS_SUPER_MAGIC)
 		return inode->i_sb;
 #endif
+	if (!devpts_mnt)
+		return NULL;
 	return devpts_mnt->mnt_sb;
 }
 
@@ -525,10 +527,14 @@ static struct file_system_type devpts_fs_type = {
 int devpts_new_index(struct inode *ptmx_inode)
 {
 	struct super_block *sb = pts_sb_from_inode(ptmx_inode);
-	struct pts_fs_info *fsi = DEVPTS_SB(sb);
+	struct pts_fs_info *fsi;
 	int index;
 	int ida_ret;
 
+	if (!sb)
+		return -ENODEV;
+
+	fsi = DEVPTS_SB(sb);
 retry:
 	if (!ida_pre_get(&fsi->allocated_ptys, GFP_KERNEL))
 		return -ENOMEM;
@@ -584,11 +590,18 @@ struct inode *devpts_pty_new(struct inode *ptmx_inode, dev_t device, int index,
 	struct dentry *dentry;
 	struct super_block *sb = pts_sb_from_inode(ptmx_inode);
 	struct inode *inode;
-	struct dentry *root = sb->s_root;
-	struct pts_fs_info *fsi = DEVPTS_SB(sb);
-	struct pts_mount_opts *opts = &fsi->mount_opts;
+	struct dentry *root;
+	struct pts_fs_info *fsi;
+	struct pts_mount_opts *opts;
 	char s[12];
 
+	if (!sb)
+		return ERR_PTR(-ENODEV);
+
+	root = sb->s_root;
+	fsi = DEVPTS_SB(sb);
+	opts = &fsi->mount_opts;
+
 	inode = new_inode(sb);
 	if (!inode)
 		return ERR_PTR(-ENOMEM);
@@ -676,12 +689,15 @@ static int __init init_devpts_fs(void)
 	struct ctl_table_header *table;
 
 	if (!err) {
+		struct vfsmount *mnt;
 		table = register_sysctl_table(pty_root_table);
-		devpts_mnt = kern_mount(&devpts_fs_type);
-		if (IS_ERR(devpts_mnt)) {
-			err = PTR_ERR(devpts_mnt);
+		mnt = kern_mount(&devpts_fs_type);
+		if (IS_ERR(mnt)) {
+			err = PTR_ERR(mnt);
 			unregister_filesystem(&devpts_fs_type);
 			unregister_sysctl_table(table);
+		} else {
+			devpts_mnt = mnt;
 		}
 	}
 	return err;
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
