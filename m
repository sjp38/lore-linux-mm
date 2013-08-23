Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id CD8B16B006C
	for <linux-mm@kvack.org>; Thu, 22 Aug 2013 22:51:39 -0400 (EDT)
From: Rui Xiang <rui.xiang@huawei.com>
Subject: [PATCH 2/2] fs: use inode_set_user to set uid/gid of inode
Date: Fri, 23 Aug 2013 10:48:38 +0800
Message-ID: <1377226118-43756-3-git-send-email-rui.xiang@huawei.com>
In-Reply-To: <1377226118-43756-1-git-send-email-rui.xiang@huawei.com>
References: <1377226118-43756-1-git-send-email-rui.xiang@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org, viro@zeniv.linux.org.uk
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-rdma@vger.kernel.org, linux-usb@vger.kernel.org, v9fs-developer@lists.sourceforge.net, linux-mm@kvack.org, cgroups@vger.kernel.org, netdev@vger.kernel.org, Rui Xiang <rui.xiang@huawei.com>

Use the new interface to set i_uid/i_gid in inode struct.

Signed-off-by: Rui Xiang <rui.xiang@huawei.com>
---
 arch/ia64/kernel/perfmon.c                |  3 +--
 arch/powerpc/platforms/cell/spufs/inode.c |  3 +--
 arch/s390/hypfs/inode.c                   |  3 +--
 drivers/infiniband/hw/qib/qib_fs.c        |  3 +--
 drivers/usb/gadget/f_fs.c                 |  3 +--
 drivers/usb/gadget/inode.c                |  5 +++--
 fs/9p/vfs_inode.c                         |  6 ++----
 fs/adfs/inode.c                           |  3 +--
 fs/affs/inode.c                           |  6 ++----
 fs/afs/inode.c                            |  6 ++----
 fs/anon_inodes.c                          |  3 +--
 fs/autofs4/inode.c                        |  4 ++--
 fs/befs/linuxvfs.c                        |  8 ++++----
 fs/ceph/caps.c                            |  5 +++--
 fs/ceph/inode.c                           |  8 ++++----
 fs/cifs/inode.c                           |  6 ++----
 fs/configfs/inode.c                       |  3 +--
 fs/debugfs/inode.c                        |  3 +--
 fs/devpts/inode.c                         |  7 +++----
 fs/ext2/ialloc.c                          |  3 +--
 fs/ext3/ialloc.c                          |  3 +--
 fs/ext4/ialloc.c                          |  3 +--
 fs/fat/inode.c                            |  6 ++----
 fs/fuse/control.c                         |  3 +--
 fs/fuse/inode.c                           |  4 ++--
 fs/hfs/inode.c                            |  6 ++----
 fs/hfsplus/inode.c                        |  3 +--
 fs/hpfs/inode.c                           |  3 +--
 fs/hpfs/namei.c                           | 12 ++++--------
 fs/hugetlbfs/inode.c                      |  3 +--
 fs/isofs/inode.c                          |  3 +--
 fs/isofs/rock.c                           |  3 +--
 fs/ncpfs/inode.c                          |  3 +--
 fs/nfs/inode.c                            |  4 ++--
 fs/ntfs/inode.c                           | 12 ++++--------
 fs/ntfs/mft.c                             |  3 +--
 fs/ntfs/super.c                           |  3 +--
 fs/ocfs2/refcounttree.c                   |  3 +--
 fs/omfs/inode.c                           |  3 +--
 fs/pipe.c                                 |  3 +--
 fs/proc/base.c                            | 15 +++++----------
 fs/proc/fd.c                              |  8 ++++----
 fs/proc/inode.c                           |  3 +--
 fs/proc/self.c                            |  3 +--
 fs/stack.c                                |  3 +--
 fs/sysfs/inode.c                          |  3 +--
 fs/xfs/xfs_iops.c                         |  4 ++--
 ipc/mqueue.c                              |  3 +--
 kernel/cgroup.c                           |  3 +--
 mm/shmem.c                                |  3 +--
 net/socket.c                              |  3 +--
 51 files changed, 86 insertions(+), 142 deletions(-)

diff --git a/arch/ia64/kernel/perfmon.c b/arch/ia64/kernel/perfmon.c
index 5a9ff1c..73e1e55 100644
--- a/arch/ia64/kernel/perfmon.c
+++ b/arch/ia64/kernel/perfmon.c
@@ -2202,8 +2202,7 @@ pfm_alloc_file(pfm_context_t *ctx)
 	DPRINT(("new inode ino=%ld @%p\n", inode->i_ino, inode));
 
 	inode->i_mode = S_IFCHR|S_IRUGO;
-	inode->i_uid  = current_fsuid();
-	inode->i_gid  = current_fsgid();
+	inode_set_user(inode, current_fsuid(), current_fsgid());
 
 	/*
 	 * allocate a new dcache entry
diff --git a/arch/powerpc/platforms/cell/spufs/inode.c b/arch/powerpc/platforms/cell/spufs/inode.c
index 87ba7cf..4580c9b 100644
--- a/arch/powerpc/platforms/cell/spufs/inode.c
+++ b/arch/powerpc/platforms/cell/spufs/inode.c
@@ -101,8 +101,7 @@ spufs_new_inode(struct super_block *sb, umode_t mode)
 
 	inode->i_ino = get_next_ino();
 	inode->i_mode = mode;
-	inode->i_uid = current_fsuid();
-	inode->i_gid = current_fsgid();
+	inode_set_user(inode, current_fsuid(), current_fsgid());
 	inode->i_atime = inode->i_mtime = inode->i_ctime = CURRENT_TIME;
 out:
 	return inode;
diff --git a/arch/s390/hypfs/inode.c b/arch/s390/hypfs/inode.c
index 7a539f4..742e430 100644
--- a/arch/s390/hypfs/inode.c
+++ b/arch/s390/hypfs/inode.c
@@ -103,8 +103,7 @@ static struct inode *hypfs_make_inode(struct super_block *sb, umode_t mode)
 		struct hypfs_sb_info *hypfs_info = sb->s_fs_info;
 		ret->i_ino = get_next_ino();
 		ret->i_mode = mode;
-		ret->i_uid = hypfs_info->uid;
-		ret->i_gid = hypfs_info->gid;
+		inode_set_user(ret, hypfs_info->uid, hypfs_info->gid);
 		ret->i_atime = ret->i_mtime = ret->i_ctime = CURRENT_TIME;
 		if (S_ISDIR(mode))
 			set_nlink(ret, 2);
diff --git a/drivers/infiniband/hw/qib/qib_fs.c b/drivers/infiniband/hw/qib/qib_fs.c
index f247fc6e..6683837 100644
--- a/drivers/infiniband/hw/qib/qib_fs.c
+++ b/drivers/infiniband/hw/qib/qib_fs.c
@@ -61,13 +61,12 @@ static int qibfs_mknod(struct inode *dir, struct dentry *dentry,
 
 	inode->i_ino = get_next_ino();
 	inode->i_mode = mode;
-	inode->i_uid = GLOBAL_ROOT_UID;
-	inode->i_gid = GLOBAL_ROOT_GID;
 	inode->i_blocks = 0;
 	inode->i_atime = CURRENT_TIME;
 	inode->i_mtime = inode->i_atime;
 	inode->i_ctime = inode->i_atime;
 	inode->i_private = data;
+	inode_set_user(inode, GLOBAL_ROOT_UID, GLOBAL_ROOT_GID);
 	if (S_ISDIR(mode)) {
 		inode->i_op = &simple_dir_inode_operations;
 		inc_nlink(inode);
diff --git a/drivers/usb/gadget/f_fs.c b/drivers/usb/gadget/f_fs.c
index f394f29..95530f4 100644
--- a/drivers/usb/gadget/f_fs.c
+++ b/drivers/usb/gadget/f_fs.c
@@ -980,8 +980,6 @@ ffs_sb_make_inode(struct super_block *sb, void *data,
 
 		inode->i_ino	 = get_next_ino();
 		inode->i_mode    = perms->mode;
-		inode->i_uid     = perms->uid;
-		inode->i_gid     = perms->gid;
 		inode->i_atime   = current_time;
 		inode->i_mtime   = current_time;
 		inode->i_ctime   = current_time;
@@ -990,6 +988,7 @@ ffs_sb_make_inode(struct super_block *sb, void *data,
 			inode->i_fop = fops;
 		if (iops)
 			inode->i_op  = iops;
+		inode_set_user(inode, perms->uid, perms->gid);
 	}
 
 	return inode;
diff --git a/drivers/usb/gadget/inode.c b/drivers/usb/gadget/inode.c
index f255ad7..40eb2b9 100644
--- a/drivers/usb/gadget/inode.c
+++ b/drivers/usb/gadget/inode.c
@@ -1999,12 +1999,13 @@ gadgetfs_make_inode (struct super_block *sb,
 	if (inode) {
 		inode->i_ino = get_next_ino();
 		inode->i_mode = mode;
-		inode->i_uid = make_kuid(&init_user_ns, default_uid);
-		inode->i_gid = make_kgid(&init_user_ns, default_gid);
 		inode->i_atime = inode->i_mtime = inode->i_ctime
 				= CURRENT_TIME;
 		inode->i_private = data;
 		inode->i_fop = fops;
+		inode_set_user(inode,
+				make_kuid(&init_user_ns, default_uid),
+				make_kgid(&init_user_ns, default_gid));
 	}
 	return inode;
 }
diff --git a/fs/9p/vfs_inode.c b/fs/9p/vfs_inode.c
index 94de6d1..9578768 100644
--- a/fs/9p/vfs_inode.c
+++ b/fs/9p/vfs_inode.c
@@ -1170,12 +1170,10 @@ v9fs_stat2inode(struct p9_wstat *stat, struct inode *inode,
 	inode->i_mtime.tv_sec = stat->mtime;
 	inode->i_ctime.tv_sec = stat->mtime;
 
-	inode->i_uid = v9ses->dfltuid;
-	inode->i_gid = v9ses->dfltgid;
+	inode_set_user(inode, v9ses->dfltuid, v9ses->dfltgid);
 
 	if (v9fs_proto_dotu(v9ses)) {
-		inode->i_uid = stat->n_uid;
-		inode->i_gid = stat->n_gid;
+		inode_set_user(inode, stat->n_uid, stat->n_gid);
 	}
 	if ((S_ISREG(inode->i_mode)) || (S_ISDIR(inode->i_mode))) {
 		if (v9fs_proto_dotu(v9ses) && (stat->extension[0] != '\0')) {
diff --git a/fs/adfs/inode.c b/fs/adfs/inode.c
index b9acada..9c9a9ede 100644
--- a/fs/adfs/inode.c
+++ b/fs/adfs/inode.c
@@ -248,8 +248,7 @@ adfs_iget(struct super_block *sb, struct object_info *obj)
 	if (!inode)
 		goto out;
 
-	inode->i_uid	 = ADFS_SB(sb)->s_uid;
-	inode->i_gid	 = ADFS_SB(sb)->s_gid;
+	inode_set_user(inode, ADFS_SB(sb)->s_uid, ADFS_SB(sb)->s_gid);
 	inode->i_ino	 = obj->file_id;
 	inode->i_size	 = obj->size;
 	set_nlink(inode, 2);
diff --git a/fs/affs/inode.c b/fs/affs/inode.c
index 0e092d0..f969757 100644
--- a/fs/affs/inode.c
+++ b/fs/affs/inode.c
@@ -94,8 +94,7 @@ struct inode *affs_iget(struct super_block *sb, unsigned long ino)
 
 	switch (be32_to_cpu(tail->stype)) {
 	case ST_ROOT:
-		inode->i_uid = sbi->s_uid;
-		inode->i_gid = sbi->s_gid;
+		inode_set_user(inode, sbi->s_uid, sbi->s_gid);
 		/* fall through */
 	case ST_USERDIR:
 		if (be32_to_cpu(tail->stype) == ST_USERDIR ||
@@ -304,8 +303,7 @@ affs_new_inode(struct inode *dir)
 	mark_buffer_dirty_inode(bh, inode);
 	affs_brelse(bh);
 
-	inode->i_uid     = current_fsuid();
-	inode->i_gid     = current_fsgid();
+	inode_set_user(inode, current_fsuid(), current_fsgid());
 	inode->i_ino     = block;
 	set_nlink(inode, 1);
 	inode->i_mtime   = inode->i_atime = inode->i_ctime = CURRENT_TIME_SEC;
diff --git a/fs/afs/inode.c b/fs/afs/inode.c
index 789bc25..b27656a 100644
--- a/fs/afs/inode.c
+++ b/fs/afs/inode.c
@@ -68,8 +68,7 @@ static int afs_inode_map_status(struct afs_vnode *vnode, struct key *key)
 #endif
 
 	set_nlink(inode, vnode->status.nlink);
-	inode->i_uid		= vnode->status.owner;
-	inode->i_gid		= GLOBAL_ROOT_GID;
+	inode_set_user(inode, vnode->status.owner, GLOBAL_ROOT_GID);
 	inode->i_size		= vnode->status.size;
 	inode->i_ctime.tv_sec	= vnode->status.mtime_server;
 	inode->i_ctime.tv_nsec	= 0;
@@ -175,8 +174,7 @@ struct inode *afs_iget_autocell(struct inode *dir, const char *dev_name,
 	inode->i_mode		= S_IFDIR | S_IRUGO | S_IXUGO;
 	inode->i_op		= &afs_autocell_inode_operations;
 	set_nlink(inode, 2);
-	inode->i_uid		= GLOBAL_ROOT_UID;
-	inode->i_gid		= GLOBAL_ROOT_GID;
+	inode_set_user(inode, GLOBAL_ROOT_UID, GLOBAL_ROOT_GID);
 	inode->i_ctime.tv_sec	= get_seconds();
 	inode->i_ctime.tv_nsec	= 0;
 	inode->i_atime		= inode->i_mtime = inode->i_ctime;
diff --git a/fs/anon_inodes.c b/fs/anon_inodes.c
index 85c9618..16f78ac 100644
--- a/fs/anon_inodes.c
+++ b/fs/anon_inodes.c
@@ -77,10 +77,9 @@ static struct inode *anon_inode_mkinode(struct super_block *s)
 	 */
 	inode->i_state = I_DIRTY;
 	inode->i_mode = S_IRUSR | S_IWUSR;
-	inode->i_uid = current_fsuid();
-	inode->i_gid = current_fsgid();
 	inode->i_flags |= S_PRIVATE;
 	inode->i_atime = inode->i_mtime = inode->i_ctime = CURRENT_TIME;
+	inode_set_user(inode, current_fsuid(), current_fsgid());
 	return inode;
 }
 
diff --git a/fs/autofs4/inode.c b/fs/autofs4/inode.c
index 1b045ec..8e6e2ea 100644
--- a/fs/autofs4/inode.c
+++ b/fs/autofs4/inode.c
@@ -353,8 +353,8 @@ struct inode *autofs4_get_inode(struct super_block *sb, umode_t mode)
 
 	inode->i_mode = mode;
 	if (sb->s_root) {
-		inode->i_uid = sb->s_root->d_inode->i_uid;
-		inode->i_gid = sb->s_root->d_inode->i_gid;
+		inode_set_user(inode, sb->s_root->d_inode->i_uid,
+					sb->s_root->d_inode->i_gid);
 	}
 	inode->i_atime = inode->i_mtime = inode->i_ctime = CURRENT_TIME;
 	inode->i_ino = get_next_ino();
diff --git a/fs/befs/linuxvfs.c b/fs/befs/linuxvfs.c
index e9c75e2..40dbd80 100644
--- a/fs/befs/linuxvfs.c
+++ b/fs/befs/linuxvfs.c
@@ -356,12 +356,12 @@ static struct inode *befs_iget(struct super_block *sb, unsigned long ino)
 	 * you can change by "uid" or "gid" options.
 	 */   
 
-	inode->i_uid = befs_sb->mount_opts.use_uid ?
+	inode_set_user(inode, befs_sb->mount_opts.use_uid ?
 		befs_sb->mount_opts.uid :
-		make_kuid(&init_user_ns, fs32_to_cpu(sb, raw_inode->uid));
-	inode->i_gid = befs_sb->mount_opts.use_gid ?
+		make_kuid(&init_user_ns, fs32_to_cpu(sb, raw_inode->uid)),
+		befs_sb->mount_opts.use_gid ?
 		befs_sb->mount_opts.gid :
-		make_kgid(&init_user_ns, fs32_to_cpu(sb, raw_inode->gid));
+		make_kgid(&init_user_ns, fs32_to_cpu(sb, raw_inode->gid)));
 
 	set_nlink(inode, 1);
 
diff --git a/fs/ceph/caps.c b/fs/ceph/caps.c
index 430121a..d548f22 100644
--- a/fs/ceph/caps.c
+++ b/fs/ceph/caps.c
@@ -2433,8 +2433,9 @@ static void handle_cap_grant(struct inode *inode, struct ceph_mds_caps *grant,
 
 	if ((issued & CEPH_CAP_AUTH_EXCL) == 0) {
 		inode->i_mode = le32_to_cpu(grant->mode);
-		inode->i_uid = make_kuid(&init_user_ns, le32_to_cpu(grant->uid));
-		inode->i_gid = make_kgid(&init_user_ns, le32_to_cpu(grant->gid));
+		inode_set_user(inode,
+			make_kuid(&init_user_ns, le32_to_cpu(grant->uid)),
+			make_kgid(&init_user_ns, le32_to_cpu(grant->gid)));
 		dout("%p mode 0%o uid.gid %d.%d\n", inode, inode->i_mode,
 		     from_kuid(&init_user_ns, inode->i_uid),
 		     from_kgid(&init_user_ns, inode->i_gid));
diff --git a/fs/ceph/inode.c b/fs/ceph/inode.c
index 98b6e50..b3979e7 100644
--- a/fs/ceph/inode.c
+++ b/fs/ceph/inode.c
@@ -85,12 +85,11 @@ struct inode *ceph_get_snapdir(struct inode *parent)
 	if (IS_ERR(inode))
 		return inode;
 	inode->i_mode = parent->i_mode;
-	inode->i_uid = parent->i_uid;
-	inode->i_gid = parent->i_gid;
 	inode->i_op = &ceph_dir_iops;
 	inode->i_fop = &ceph_dir_fops;
 	ci->i_snap_caps = CEPH_CAP_PIN; /* so we can open */
 	ci->i_rbytes = 0;
+	inode_set_user(inode, parent->i_uid, parent->i_gid);
 	return inode;
 }
 
@@ -619,8 +618,9 @@ static int fill_inode(struct inode *inode,
 
 	if ((issued & CEPH_CAP_AUTH_EXCL) == 0) {
 		inode->i_mode = le32_to_cpu(info->mode);
-		inode->i_uid = make_kuid(&init_user_ns, le32_to_cpu(info->uid));
-		inode->i_gid = make_kgid(&init_user_ns, le32_to_cpu(info->gid));
+		inode_set_user(inode,
+			make_kuid(&init_user_ns, le32_to_cpu(info->uid)),
+			make_kgid(&init_user_ns, le32_to_cpu(info->gid)));
 		dout("%p mode 0%o uid.gid %d.%d\n", inode, inode->i_mode,
 		     from_kuid(&init_user_ns, inode->i_uid),
 		     from_kgid(&init_user_ns, inode->i_gid));
diff --git a/fs/cifs/inode.c b/fs/cifs/inode.c
index 90ef287..70eef44 100644
--- a/fs/cifs/inode.c
+++ b/fs/cifs/inode.c
@@ -135,8 +135,7 @@ cifs_fattr_to_inode(struct inode *inode, struct cifs_fattr *fattr)
 	inode->i_ctime = fattr->cf_ctime;
 	inode->i_rdev = fattr->cf_rdev;
 	set_nlink(inode, fattr->cf_nlink);
-	inode->i_uid = fattr->cf_uid;
-	inode->i_gid = fattr->cf_gid;
+	inode_set_user(inode, fattr->cf_uid, fattr->cf_gid);
 
 	/* if dynperm is set, don't clobber existing mode */
 	if (inode->i_state & I_NEW ||
@@ -918,8 +917,7 @@ struct inode *cifs_root_iget(struct super_block *sb)
 		set_nlink(inode, 2);
 		inode->i_op = &cifs_ipc_inode_ops;
 		inode->i_fop = &simple_dir_operations;
-		inode->i_uid = cifs_sb->mnt_uid;
-		inode->i_gid = cifs_sb->mnt_gid;
+		inode_set_user(inode, cifs_sb->mnt_uid, cifs_sb->mnt_gid);
 		spin_unlock(&inode->i_lock);
 	} else if (rc) {
 		iget_failed(inode);
diff --git a/fs/configfs/inode.c b/fs/configfs/inode.c
index a9d35b0..c9dc07a 100644
--- a/fs/configfs/inode.c
+++ b/fs/configfs/inode.c
@@ -123,11 +123,10 @@ static inline void set_default_inode_attr(struct inode * inode, umode_t mode)
 static inline void set_inode_attr(struct inode * inode, struct iattr * iattr)
 {
 	inode->i_mode = iattr->ia_mode;
-	inode->i_uid = iattr->ia_uid;
-	inode->i_gid = iattr->ia_gid;
 	inode->i_atime = iattr->ia_atime;
 	inode->i_mtime = iattr->ia_mtime;
 	inode->i_ctime = iattr->ia_ctime;
+	inode_set_user(inode, iattr->ia_uid, iattr->ia_gid);
 }
 
 struct inode *configfs_new_inode(umode_t mode, struct configfs_dirent *sd,
diff --git a/fs/debugfs/inode.c b/fs/debugfs/inode.c
index c7c83ff..f7f3687 100644
--- a/fs/debugfs/inode.c
+++ b/fs/debugfs/inode.c
@@ -207,8 +207,7 @@ static int debugfs_apply_options(struct super_block *sb)
 	inode->i_mode &= ~S_IALLUGO;
 	inode->i_mode |= opts->mode;
 
-	inode->i_uid = opts->uid;
-	inode->i_gid = opts->gid;
+	inode_set_user(inode, opts->uid, opts->gid);
 
 	return 0;
 }
diff --git a/fs/devpts/inode.c b/fs/devpts/inode.c
index 073d30b..a4d8c7a 100644
--- a/fs/devpts/inode.c
+++ b/fs/devpts/inode.c
@@ -280,8 +280,7 @@ static int mknod_ptmx(struct super_block *sb)
 
 	mode = S_IFCHR|opts->ptmxmode;
 	init_special_inode(inode, mode, MKDEV(TTYAUX_MAJOR, 2));
-	inode->i_uid = root_uid;
-	inode->i_gid = root_gid;
+	inode_set_user(inode, root_uid, root_gid);
 
 	d_add(dentry, inode);
 
@@ -588,8 +587,8 @@ struct inode *devpts_pty_new(struct inode *ptmx_inode, dev_t device, int index,
 		return ERR_PTR(-ENOMEM);
 
 	inode->i_ino = index + 3;
-	inode->i_uid = opts->setuid ? opts->uid : current_fsuid();
-	inode->i_gid = opts->setgid ? opts->gid : current_fsgid();
+	inode_set_user(inode, opts->setuid ? opts->uid : current_fsuid(),
+				opts->setgid ? opts->gid : current_fsgid());
 	inode->i_mtime = inode->i_atime = inode->i_ctime = CURRENT_TIME;
 	init_special_inode(inode, S_IFCHR|opts->mode, device);
 	inode->i_private = priv;
diff --git a/fs/ext2/ialloc.c b/fs/ext2/ialloc.c
index 7cadd82..ccb6678 100644
--- a/fs/ext2/ialloc.c
+++ b/fs/ext2/ialloc.c
@@ -544,8 +544,7 @@ got:
 	mark_buffer_dirty(bh2);
 	if (test_opt(sb, GRPID)) {
 		inode->i_mode = mode;
-		inode->i_uid = current_fsuid();
-		inode->i_gid = dir->i_gid;
+		inode_set_user(inode, current_fsuid(), dir->i_gid);
 	} else
 		inode_init_owner(inode, dir, mode);
 
diff --git a/fs/ext3/ialloc.c b/fs/ext3/ialloc.c
index 082afd7..b858f92 100644
--- a/fs/ext3/ialloc.c
+++ b/fs/ext3/ialloc.c
@@ -467,8 +467,7 @@ got:
 
 	if (test_opt(sb, GRPID)) {
 		inode->i_mode = mode;
-		inode->i_uid = current_fsuid();
-		inode->i_gid = dir->i_gid;
+		inode_set_user(inode, current_fsuid(), dir->i_gid);
 	} else
 		inode_init_owner(inode, dir, mode);
 
diff --git a/fs/ext4/ialloc.c b/fs/ext4/ialloc.c
index 666a5ed..6644ceb 100644
--- a/fs/ext4/ialloc.c
+++ b/fs/ext4/ialloc.c
@@ -722,8 +722,7 @@ struct inode *__ext4_new_inode(handle_t *handle, struct inode *dir,
 		i_gid_write(inode, owner[1]);
 	} else if (test_opt(sb, GRPID)) {
 		inode->i_mode = mode;
-		inode->i_uid = current_fsuid();
-		inode->i_gid = dir->i_gid;
+		inode_set_user(inode, current_fsuid(), dir->i_gid);
 	} else
 		inode_init_owner(inode, dir, mode);
 	dquot_initialize(inode);
diff --git a/fs/fat/inode.c b/fs/fat/inode.c
index 7152c07..92d2b4f 100644
--- a/fs/fat/inode.c
+++ b/fs/fat/inode.c
@@ -443,8 +443,7 @@ int fat_fill_inode(struct inode *inode, struct msdos_dir_entry *de)
 	int error;
 
 	MSDOS_I(inode)->i_pos = 0;
-	inode->i_uid = sbi->options.fs_uid;
-	inode->i_gid = sbi->options.fs_gid;
+	inode_set_user(inode, sbi->options.fs_uid, sbi->options.fs_gid);
 	inode->i_version++;
 	inode->i_generation = get_seconds();
 
@@ -1252,8 +1251,7 @@ static int fat_read_root(struct inode *inode)
 	int error;
 
 	MSDOS_I(inode)->i_pos = MSDOS_ROOT_INO;
-	inode->i_uid = sbi->options.fs_uid;
-	inode->i_gid = sbi->options.fs_gid;
+	inode_set_user(inode, sbi->options.fs_uid, sbi->options.fs_gid);
 	inode->i_version++;
 	inode->i_generation = 0;
 	inode->i_mode = fat_make_mode(sbi, ATTR_DIR, S_IRWXUGO);
diff --git a/fs/fuse/control.c b/fs/fuse/control.c
index a0b0855..117d6ae 100644
--- a/fs/fuse/control.c
+++ b/fs/fuse/control.c
@@ -218,8 +218,7 @@ static struct dentry *fuse_ctl_add_dentry(struct dentry *parent,
 
 	inode->i_ino = get_next_ino();
 	inode->i_mode = mode;
-	inode->i_uid = fc->user_id;
-	inode->i_gid = fc->group_id;
+	inode_set_user(inode, fc->user_id, fc->group_id);
 	inode->i_atime = inode->i_mtime = inode->i_ctime = CURRENT_TIME;
 	/* setting ->i_op to NULL is not allowed */
 	if (iop)
diff --git a/fs/fuse/inode.c b/fs/fuse/inode.c
index a24e2a7..3a76cf1 100644
--- a/fs/fuse/inode.c
+++ b/fs/fuse/inode.c
@@ -165,8 +165,8 @@ void fuse_change_attributes_common(struct inode *inode, struct fuse_attr *attr,
 	inode->i_ino     = fuse_squash_ino(attr->ino);
 	inode->i_mode    = (inode->i_mode & S_IFMT) | (attr->mode & 07777);
 	set_nlink(inode, attr->nlink);
-	inode->i_uid     = make_kuid(&init_user_ns, attr->uid);
-	inode->i_gid     = make_kgid(&init_user_ns, attr->gid);
+	inode_set_user(inode, make_kuid(&init_user_ns, attr->uid),
+				make_kgid(&init_user_ns, attr->gid));
 	inode->i_blocks  = attr->blocks;
 	inode->i_atime.tv_sec   = attr->atime;
 	inode->i_atime.tv_nsec  = attr->atimensec;
diff --git a/fs/hfs/inode.c b/fs/hfs/inode.c
index 3fe7b8e..b6de5ff 100644
--- a/fs/hfs/inode.c
+++ b/fs/hfs/inode.c
@@ -189,8 +189,7 @@ struct inode *hfs_new_inode(struct inode *dir, struct qstr *name, umode_t mode)
 	hfs_cat_build_key(sb, (btree_key *)&HFS_I(inode)->cat_key, dir->i_ino, name);
 	inode->i_ino = HFS_SB(sb)->next_id++;
 	inode->i_mode = mode;
-	inode->i_uid = current_fsuid();
-	inode->i_gid = current_fsgid();
+	inode_set_user(inode, current_fsuid(), current_fsgid());
 	set_nlink(inode, 1);
 	inode->i_mtime = inode->i_atime = inode->i_ctime = CURRENT_TIME_SEC;
 	HFS_I(inode)->flags = 0;
@@ -319,8 +318,7 @@ static int hfs_read_inode(struct inode *inode, void *data)
 	INIT_LIST_HEAD(&HFS_I(inode)->open_dir_list);
 
 	/* Initialize the inode */
-	inode->i_uid = hsb->s_uid;
-	inode->i_gid = hsb->s_gid;
+	inode_set_user(inode, hsb->s_uid, hsb->s_gid);
 	set_nlink(inode, 1);
 
 	if (idata->key)
diff --git a/fs/hfsplus/inode.c b/fs/hfsplus/inode.c
index 96d7a2c..75a9e57 100644
--- a/fs/hfsplus/inode.c
+++ b/fs/hfsplus/inode.c
@@ -421,8 +421,7 @@ struct inode *hfsplus_new_inode(struct super_block *sb, umode_t mode)
 
 	inode->i_ino = sbi->next_cnid++;
 	inode->i_mode = mode;
-	inode->i_uid = current_fsuid();
-	inode->i_gid = current_fsgid();
+	inode_set_user(inode, current_fsuid(), current_fsgid());
 	set_nlink(inode, 1);
 	inode->i_mtime = inode->i_atime = inode->i_ctime = CURRENT_TIME_SEC;
 
diff --git a/fs/hpfs/inode.c b/fs/hpfs/inode.c
index 9edeeb0..d16d8eb 100644
--- a/fs/hpfs/inode.c
+++ b/fs/hpfs/inode.c
@@ -15,8 +15,7 @@ void hpfs_init_inode(struct inode *i)
 	struct super_block *sb = i->i_sb;
 	struct hpfs_inode_info *hpfs_inode = hpfs_i(i);
 
-	i->i_uid = hpfs_sb(sb)->sb_uid;
-	i->i_gid = hpfs_sb(sb)->sb_gid;
+	inode_set_user(i, hpfs_sb(sb)->sb_uid, hpfs_sb(sb)->sb_gid);
 	i->i_mode = hpfs_sb(sb)->sb_mode;
 	i->i_size = -1;
 	i->i_blocks = -1;
diff --git a/fs/hpfs/namei.c b/fs/hpfs/namei.c
index 345713d..c5def10 100644
--- a/fs/hpfs/namei.c
+++ b/fs/hpfs/namei.c
@@ -94,8 +94,7 @@ static int hpfs_mkdir(struct inode *dir, struct dentry *dentry, umode_t mode)
 	if (!uid_eq(result->i_uid, current_fsuid()) ||
 	    !gid_eq(result->i_gid, current_fsgid()) ||
 	    result->i_mode != (mode | S_IFDIR)) {
-		result->i_uid = current_fsuid();
-		result->i_gid = current_fsgid();
+		inode_set_user(result, current_fsuid(), current_fsgid());
 		result->i_mode = mode | S_IFDIR;
 		hpfs_write_inode_nolock(result);
 	}
@@ -182,8 +181,7 @@ static int hpfs_create(struct inode *dir, struct dentry *dentry, umode_t mode, b
 	if (!uid_eq(result->i_uid, current_fsuid()) ||
 	    !gid_eq(result->i_gid, current_fsgid()) ||
 	    result->i_mode != (mode | S_IFREG)) {
-		result->i_uid = current_fsuid();
-		result->i_gid = current_fsgid();
+		inode_set_user(result, current_fsuid(), current_fsgid());
 		result->i_mode = mode | S_IFREG;
 		hpfs_write_inode_nolock(result);
 	}
@@ -240,8 +238,7 @@ static int hpfs_mknod(struct inode *dir, struct dentry *dentry, umode_t mode, de
 	result->i_mtime.tv_nsec = 0;
 	result->i_atime.tv_nsec = 0;
 	hpfs_i(result)->i_ea_size = 0;
-	result->i_uid = current_fsuid();
-	result->i_gid = current_fsgid();
+	inode_set_user(result, current_fsuid(), current_fsgid());
 	set_nlink(result, 1);
 	result->i_size = 0;
 	result->i_blocks = 1;
@@ -315,8 +312,7 @@ static int hpfs_symlink(struct inode *dir, struct dentry *dentry, const char *sy
 	result->i_atime.tv_nsec = 0;
 	hpfs_i(result)->i_ea_size = 0;
 	result->i_mode = S_IFLNK | 0777;
-	result->i_uid = current_fsuid();
-	result->i_gid = current_fsgid();
+	inode_set_user(result, current_fsuid(), current_fsgid());
 	result->i_blocks = 1;
 	set_nlink(result, 1);
 	result->i_size = strlen(symlink);
diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index 3442397..603d597 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -449,8 +449,7 @@ static struct inode *hugetlbfs_get_root(struct super_block *sb,
 		struct hugetlbfs_inode_info *info;
 		inode->i_ino = get_next_ino();
 		inode->i_mode = S_IFDIR | config->mode;
-		inode->i_uid = config->uid;
-		inode->i_gid = config->gid;
+		inode_set_user(inode, config->uid, config->gid);
 		inode->i_atime = inode->i_mtime = inode->i_ctime = CURRENT_TIME;
 		info = HUGETLBFS_I(inode);
 		mpol_shared_policy_init(&info->policy, NULL);
diff --git a/fs/isofs/inode.c b/fs/isofs/inode.c
index e5d408a..3d26462 100644
--- a/fs/isofs/inode.c
+++ b/fs/isofs/inode.c
@@ -1333,8 +1333,7 @@ static int isofs_read_inode(struct inode *inode)
 		}
 		set_nlink(inode, 1);
 	}
-	inode->i_uid = sbi->s_uid;
-	inode->i_gid = sbi->s_gid;
+	inode_set_user(inode, sbi->s_uid, sbi->s_gid);
 	inode->i_blocks = 0;
 
 	ei->i_format_parm[0] = 0;
diff --git a/fs/isofs/rock.c b/fs/isofs/rock.c
index c0bf424..4490509 100644
--- a/fs/isofs/rock.c
+++ b/fs/isofs/rock.c
@@ -497,8 +497,7 @@ repeat:
 			}
 			inode->i_mode = reloc->i_mode;
 			set_nlink(inode, reloc->i_nlink);
-			inode->i_uid = reloc->i_uid;
-			inode->i_gid = reloc->i_gid;
+			inode_set_user(inode, reloc->i_uid, reloc->i_gid);
 			inode->i_rdev = reloc->i_rdev;
 			inode->i_size = reloc->i_size;
 			inode->i_blocks = reloc->i_blocks;
diff --git a/fs/ncpfs/inode.c b/fs/ncpfs/inode.c
index 4659da6..52aea43 100644
--- a/fs/ncpfs/inode.c
+++ b/fs/ncpfs/inode.c
@@ -232,8 +232,7 @@ static void ncp_set_attr(struct inode *inode, struct ncp_entry_info *nwinfo)
 	DDPRINTK("ncp_read_inode: inode->i_mode = %u\n", inode->i_mode);
 
 	set_nlink(inode, 1);
-	inode->i_uid = server->m.uid;
-	inode->i_gid = server->m.gid;
+	inode_set_user(inode, server->m.uid, server->m.gid);
 
 	ncp_update_dates(inode, &nwinfo->i);
 	ncp_update_inode(inode, nwinfo);
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 42a584a..863799b 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -401,8 +401,8 @@ nfs_fhget(struct super_block *sb, struct nfs_fh *fh, struct nfs_fattr *fattr, st
 		inode->i_version = 0;
 		inode->i_size = 0;
 		clear_nlink(inode);
-		inode->i_uid = make_kuid(&init_user_ns, -2);
-		inode->i_gid = make_kgid(&init_user_ns, -2);
+		inode_set_user(inode, make_kuid(&init_user_ns, -2),
+					make_kgid(&init_user_ns, -2));
 		inode->i_blocks = 0;
 		memset(nfsi->cookieverf, 0, sizeof(nfsi->cookieverf));
 		nfsi->write_io = 0;
diff --git a/fs/ntfs/inode.c b/fs/ntfs/inode.c
index 2778b02..61aa5a7 100644
--- a/fs/ntfs/inode.c
+++ b/fs/ntfs/inode.c
@@ -568,8 +568,7 @@ static int ntfs_read_locked_inode(struct inode *vi)
 	 */
 	vi->i_version = 1;
 
-	vi->i_uid = vol->uid;
-	vi->i_gid = vol->gid;
+	inode_set_user(vi, vol->uid, vol->gid);
 	vi->i_mode = 0;
 
 	/*
@@ -1240,8 +1239,7 @@ static int ntfs_read_locked_attr_inode(struct inode *base_vi, struct inode *vi)
 
 	/* Just mirror the values from the base inode. */
 	vi->i_version	= base_vi->i_version;
-	vi->i_uid	= base_vi->i_uid;
-	vi->i_gid	= base_vi->i_gid;
+	inode_set_user(vi, base_vi->i_uid, base_vi->i_gid);
 	set_nlink(vi, base_vi->i_nlink);
 	vi->i_mtime	= base_vi->i_mtime;
 	vi->i_ctime	= base_vi->i_ctime;
@@ -1506,8 +1504,7 @@ static int ntfs_read_locked_index_inode(struct inode *base_vi, struct inode *vi)
 	base_ni = NTFS_I(base_vi);
 	/* Just mirror the values from the base inode. */
 	vi->i_version	= base_vi->i_version;
-	vi->i_uid	= base_vi->i_uid;
-	vi->i_gid	= base_vi->i_gid;
+	inode_set_user(vi, base_vi->i_uid, base_vi->i_gid);
 	set_nlink(vi, base_vi->i_nlink);
 	vi->i_mtime	= base_vi->i_mtime;
 	vi->i_ctime	= base_vi->i_ctime;
@@ -2125,8 +2122,7 @@ int ntfs_read_inode_mount(struct inode *vi)
 			 * ntfs_read_inode() will have set up the default ones.
 			 */
 			/* Set uid and gid to root. */
-			vi->i_uid = GLOBAL_ROOT_UID;
-			vi->i_gid = GLOBAL_ROOT_GID;
+			inode_set_user(vi, GLOBAL_ROOT_UID, GLOBAL_ROOT_GID);
 			/* Regular file. No access for anyone. */
 			vi->i_mode = S_IFREG;
 			/* No VFS initiated operations allowed for $MFT. */
diff --git a/fs/ntfs/mft.c b/fs/ntfs/mft.c
index 3014a36..d808a21 100644
--- a/fs/ntfs/mft.c
+++ b/fs/ntfs/mft.c
@@ -2648,8 +2648,7 @@ mft_rec_already_initialized:
 		vi->i_version = 1;
 
 		/* The owner and group come from the ntfs volume. */
-		vi->i_uid = vol->uid;
-		vi->i_gid = vol->gid;
+		inode_set_user(vi, vol->uid, vol->gid);
 
 		/* Initialize the ntfs specific part of @vi. */
 		ntfs_init_big_inode(vi);
diff --git a/fs/ntfs/super.c b/fs/ntfs/super.c
index 82650d5..09a2e72 100644
--- a/fs/ntfs/super.c
+++ b/fs/ntfs/super.c
@@ -1047,8 +1047,7 @@ static bool load_and_init_mft_mirror(ntfs_volume *vol)
 	 * ntfs_read_inode() will have set up the default ones.
 	 */
 	/* Set uid and gid to root. */
-	tmp_ino->i_uid = GLOBAL_ROOT_UID;
-	tmp_ino->i_gid = GLOBAL_ROOT_GID;
+	inode_set_user(tmp_ino, GLOBAL_ROOT_UID, GLOBAL_ROOT_GID);
 	/* Regular file.  No access for anyone. */
 	tmp_ino->i_mode = S_IFREG;
 	/* No VFS initiated operations allowed for $MFTMirr. */
diff --git a/fs/ocfs2/refcounttree.c b/fs/ocfs2/refcounttree.c
index bf4dfc1..84f4859 100644
--- a/fs/ocfs2/refcounttree.c
+++ b/fs/ocfs2/refcounttree.c
@@ -4100,8 +4100,7 @@ static int ocfs2_complete_reflink(struct inode *s_inode,
 	di->i_attr = s_di->i_attr;
 
 	if (preserve) {
-		t_inode->i_uid = s_inode->i_uid;
-		t_inode->i_gid = s_inode->i_gid;
+		inode_set_user(t_inode, s_inode->i_uid, s_inode->i_gid);
 		t_inode->i_mode = s_inode->i_mode;
 		di->i_uid = s_di->i_uid;
 		di->i_gid = s_di->i_gid;
diff --git a/fs/omfs/inode.c b/fs/omfs/inode.c
index d8b0afd..f4a252e 100644
--- a/fs/omfs/inode.c
+++ b/fs/omfs/inode.c
@@ -222,8 +222,7 @@ struct inode *omfs_iget(struct super_block *sb, ino_t ino)
 	if (ino != be64_to_cpu(oi->i_head.h_self))
 		goto fail_bh;
 
-	inode->i_uid = sbi->s_uid;
-	inode->i_gid = sbi->s_gid;
+	inode_set_user(inode, sbi->s_uid, sbi->s_gid);
 
 	ctime = be64_to_cpu(oi->i_ctime);
 	nsecs = do_div(ctime, 1000) * 1000L;
diff --git a/fs/pipe.c b/fs/pipe.c
index d2c45e1..6df8161 100644
--- a/fs/pipe.c
+++ b/fs/pipe.c
@@ -853,8 +853,7 @@ static struct inode * get_pipe_inode(void)
 	 */
 	inode->i_state = I_DIRTY;
 	inode->i_mode = S_IFIFO | S_IRUSR | S_IWUSR;
-	inode->i_uid = current_fsuid();
-	inode->i_gid = current_fsgid();
+	inode_set_user(inode, current_fsuid(), current_fsgid());
 	inode->i_atime = inode->i_mtime = inode->i_ctime = CURRENT_TIME;
 
 	return inode;
diff --git a/fs/proc/base.c b/fs/proc/base.c
index 1485e38..cd9e41e 100644
--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -1555,8 +1555,7 @@ struct inode *proc_pid_make_inode(struct super_block * sb, struct task_struct *t
 	if (task_dumpable(task)) {
 		rcu_read_lock();
 		cred = __task_cred(task);
-		inode->i_uid = cred->euid;
-		inode->i_gid = cred->egid;
+		inode_set_user(inode, cred->euid, cred->egid);
 		rcu_read_unlock();
 	}
 	security_task_to_inode(task, inode);
@@ -1636,12 +1635,10 @@ int pid_revalidate(struct dentry *dentry, unsigned int flags)
 		    task_dumpable(task)) {
 			rcu_read_lock();
 			cred = __task_cred(task);
-			inode->i_uid = cred->euid;
-			inode->i_gid = cred->egid;
+			inode_set_user(inode, cred->euid, cred->egid);
 			rcu_read_unlock();
 		} else {
-			inode->i_uid = GLOBAL_ROOT_UID;
-			inode->i_gid = GLOBAL_ROOT_GID;
+			inode_set_user(inode, GLOBAL_ROOT_UID, GLOBAL_ROOT_GID);
 		}
 		inode->i_mode &= ~(S_ISUID | S_ISGID);
 		security_task_to_inode(task, inode);
@@ -1765,12 +1762,10 @@ static int map_files_d_revalidate(struct dentry *dentry, unsigned int flags)
 		if (task_dumpable(task)) {
 			rcu_read_lock();
 			cred = __task_cred(task);
-			inode->i_uid = cred->euid;
-			inode->i_gid = cred->egid;
+			inode_set_user(inode, cred->euid, cred->egid);
 			rcu_read_unlock();
 		} else {
-			inode->i_uid = GLOBAL_ROOT_UID;
-			inode->i_gid = GLOBAL_ROOT_GID;
+			inode_set_user(inode, GLOBAL_ROOT_UID, GLOBAL_ROOT_GID)
 		}
 		security_task_to_inode(task, inode);
 		status = 1;
diff --git a/fs/proc/fd.c b/fs/proc/fd.c
index 0ff80f9..f62cb78 100644
--- a/fs/proc/fd.c
+++ b/fs/proc/fd.c
@@ -101,12 +101,12 @@ static int tid_fd_revalidate(struct dentry *dentry, unsigned int flags)
 				if (task_dumpable(task)) {
 					rcu_read_lock();
 					cred = __task_cred(task);
-					inode->i_uid = cred->euid;
-					inode->i_gid = cred->egid;
+					inode_set_user(inode,
+						cred->euid, cred->egid);
 					rcu_read_unlock();
 				} else {
-					inode->i_uid = GLOBAL_ROOT_UID;
-					inode->i_gid = GLOBAL_ROOT_GID;
+					inode_set_user(inode,
+					GLOBAL_ROOT_UID, GLOBAL_ROOT_GID);
 				}
 
 				if (S_ISLNK(inode->i_mode)) {
diff --git a/fs/proc/inode.c b/fs/proc/inode.c
index 073aea6..74e42bc 100644
--- a/fs/proc/inode.c
+++ b/fs/proc/inode.c
@@ -384,8 +384,7 @@ struct inode *proc_get_inode(struct super_block *sb, struct proc_dir_entry *de)
 
 		if (de->mode) {
 			inode->i_mode = de->mode;
-			inode->i_uid = de->uid;
-			inode->i_gid = de->gid;
+			inode_set_user(inode, de->uid, de->gid);
 		}
 		if (de->size)
 			inode->i_size = de->size;
diff --git a/fs/proc/self.c b/fs/proc/self.c
index 6b6a993..679f29d 100644
--- a/fs/proc/self.c
+++ b/fs/proc/self.c
@@ -66,9 +66,8 @@ int proc_setup_self(struct super_block *s)
 			inode->i_ino = self_inum;
 			inode->i_mtime = inode->i_atime = inode->i_ctime = CURRENT_TIME;
 			inode->i_mode = S_IFLNK | S_IRWXUGO;
-			inode->i_uid = GLOBAL_ROOT_UID;
-			inode->i_gid = GLOBAL_ROOT_GID;
 			inode->i_op = &proc_self_inode_operations;
+			inode_set_user(inode, GLOBAL_ROOT_UID, GLOBAL_ROOT_GID);
 			d_add(self, inode);
 		} else {
 			dput(self);
diff --git a/fs/stack.c b/fs/stack.c
index 5b53882..b147803 100644
--- a/fs/stack.c
+++ b/fs/stack.c
@@ -63,14 +63,13 @@ EXPORT_SYMBOL_GPL(fsstack_copy_inode_size);
 void fsstack_copy_attr_all(struct inode *dest, const struct inode *src)
 {
 	dest->i_mode = src->i_mode;
-	dest->i_uid = src->i_uid;
-	dest->i_gid = src->i_gid;
 	dest->i_rdev = src->i_rdev;
 	dest->i_atime = src->i_atime;
 	dest->i_mtime = src->i_mtime;
 	dest->i_ctime = src->i_ctime;
 	dest->i_blkbits = src->i_blkbits;
 	dest->i_flags = src->i_flags;
+	inode_set_user(dest, src->i_uid, src->i_gid);
 	set_nlink(dest, src->i_nlink);
 }
 EXPORT_SYMBOL_GPL(fsstack_copy_attr_all);
diff --git a/fs/sysfs/inode.c b/fs/sysfs/inode.c
index 3e2837a..87b06f7 100644
--- a/fs/sysfs/inode.c
+++ b/fs/sysfs/inode.c
@@ -194,11 +194,10 @@ static inline void set_default_inode_attr(struct inode * inode, umode_t mode)
 
 static inline void set_inode_attr(struct inode * inode, struct iattr * iattr)
 {
-	inode->i_uid = iattr->ia_uid;
-	inode->i_gid = iattr->ia_gid;
 	inode->i_atime = iattr->ia_atime;
 	inode->i_mtime = iattr->ia_mtime;
 	inode->i_ctime = iattr->ia_ctime;
+	inode_set_user(inode, iattr->ia_uid, iattr->ia_gid);
 }
 
 static void sysfs_refresh_inode(struct sysfs_dirent *sd, struct inode *inode)
diff --git a/fs/xfs/xfs_iops.c b/fs/xfs/xfs_iops.c
index 6d7e9e2..6d91cfa 100644
--- a/fs/xfs/xfs_iops.c
+++ b/fs/xfs/xfs_iops.c
@@ -1174,8 +1174,8 @@ xfs_setup_inode(
 
 	inode->i_mode	= ip->i_d.di_mode;
 	set_nlink(inode, ip->i_d.di_nlink);
-	inode->i_uid    = xfs_uid_to_kuid(ip->i_d.di_uid);
-	inode->i_gid    = xfs_gid_to_kgid(ip->i_d.di_gid);
+	inode_set_user(inode, xfs_uid_to_kuid(ip->i_d.di_uid),
+				xfs_gid_to_kgid(ip->i_d.di_gid));
 
 	switch (inode->i_mode & S_IFMT) {
 	case S_IFBLK:
diff --git a/ipc/mqueue.c b/ipc/mqueue.c
index ae1996d..cc7fb87 100644
--- a/ipc/mqueue.c
+++ b/ipc/mqueue.c
@@ -227,8 +227,7 @@ static struct inode *mqueue_get_inode(struct super_block *sb,
 
 	inode->i_ino = get_next_ino();
 	inode->i_mode = mode;
-	inode->i_uid = current_fsuid();
-	inode->i_gid = current_fsgid();
+	inode_set_user(inode, current_fsuid(), current_fsgid());
 	inode->i_mtime = inode->i_ctime = inode->i_atime = CURRENT_TIME;
 
 	if (S_ISREG(mode)) {
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 7b35ff9..14671ca 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -846,8 +846,7 @@ static struct inode *cgroup_new_inode(umode_t mode, struct super_block *sb)
 	if (inode) {
 		inode->i_ino = get_next_ino();
 		inode->i_mode = mode;
-		inode->i_uid = current_fsuid();
-		inode->i_gid = current_fsgid();
+		inode_set_user(inode, current_fsuid(), current_fsgid());
 		inode->i_atime = inode->i_mtime = inode->i_ctime = CURRENT_TIME;
 		inode->i_mapping->backing_dev_info = &cgroup_backing_dev_info;
 	}
diff --git a/mm/shmem.c b/mm/shmem.c
index f00c1c1..d554ac4f 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -2628,8 +2628,7 @@ int shmem_fill_super(struct super_block *sb, void *data, int silent)
 	inode = shmem_get_inode(sb, NULL, S_IFDIR | sbinfo->mode, 0, VM_NORESERVE);
 	if (!inode)
 		goto failed;
-	inode->i_uid = sbinfo->uid;
-	inode->i_gid = sbinfo->gid;
+	inode_set_user(inode, sbinfo->uid, sbinfo->gid);
 	sb->s_root = d_make_root(inode);
 	if (!sb->s_root)
 		goto failed;
diff --git a/net/socket.c b/net/socket.c
index ebed4b6..6c711a5 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -547,8 +547,7 @@ static struct socket *sock_alloc(void)
 	kmemcheck_annotate_bitfield(sock, type);
 	inode->i_ino = get_next_ino();
 	inode->i_mode = S_IFSOCK | S_IRWXUGO;
-	inode->i_uid = current_fsuid();
-	inode->i_gid = current_fsgid();
+	inode_set_user(inode, current_fsuid(), current_fsgid());
 	inode->i_op = &sockfs_inode_ops;
 
 	this_cpu_add(sockets_in_use, 1);
-- 
1.8.2.2


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
