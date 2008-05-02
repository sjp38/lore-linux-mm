Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e34.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m421mkBl003764
	for <linux-mm@kvack.org>; Thu, 1 May 2008 21:48:46 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m421pUew157990
	for <linux-mm@kvack.org>; Thu, 1 May 2008 19:51:30 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m421pUQ5030455
	for <linux-mm@kvack.org>; Thu, 1 May 2008 19:51:30 -0600
Subject: [RFC][PATCH 1/2] Add shared and reserve control to
	hugetlb_file_setup
From: Eric B Munson <ebmunson@us.ibm.com>
Reply-To: ebmunson@us.ibm.com
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-CMoCLz5bdgTzTvWUMm2m"
Date: Thu, 01 May 2008 18:51:29 -0700
Message-Id: <1209693089.8483.22.camel@grover.beaverton.ibm.com>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: nacc <nacc@linux.vnet.ibm.com>, mel@csn.ul.ie, andyw <andyw@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

--=-CMoCLz5bdgTzTvWUMm2m
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

In order to back stacks with huge pages, we will want to make hugetlbfs
files to back them; these will be used to back private mappings.
Currently hugetlb_file_setup creates files to back shared memory segments.
Modify this to create both private and shared files, and update callers
to the new signatures.

By not reserving requested huge pages for stack areas, we allow many progra=
ms to
have vma's which total to more huge pages than available on the system
without affecting eachother until they attempt to use all the pages.  This
will be the case with the proposed huge page backed stack patch in this
series.

Based on 2.6.25

Signed-off-by: Eric Munson <ebmunson@us.ibm.com>

---

 fs/hugetlbfs/inode.c    |   39 +++++++++++++++++++++++++--------------
 include/linux/hugetlb.h |   16 ++++++++++++++--
 ipc/shm.c               |    3 ++-
 3 files changed, 41 insertions(+), 17 deletions(-)

diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index 6846785..8c0ba46 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -488,7 +488,8 @@ out:
 }
=20
 static struct inode *hugetlbfs_get_inode(struct super_block *sb, uid_t uid=
,=20
-					gid_t gid, int mode, dev_t dev)
+					gid_t gid, int mode, dev_t dev,
+					unsigned long creat_flags)
 {
 	struct inode *inode;
=20
@@ -504,7 +505,9 @@ static struct inode *hugetlbfs_get_inode(struct super_b=
lock *sb, uid_t uid,
 		inode->i_atime =3D inode->i_mtime =3D inode->i_ctime =3D CURRENT_TIME;
 		INIT_LIST_HEAD(&inode->i_mapping->private_list);
 		info =3D HUGETLBFS_I(inode);
-		mpol_shared_policy_init(&info->policy, MPOL_DEFAULT, NULL);
+		if (creat_flags & HUGETLB_SHARED)
+			mpol_shared_policy_init(&info->policy, MPOL_DEFAULT,
+						NULL);
 		switch (mode & S_IFMT) {
 		default:
 			init_special_inode(inode, mode, dev);
@@ -545,7 +548,8 @@ static int hugetlbfs_mknod(struct inode *dir,
 	} else {
 		gid =3D current->fsgid;
 	}
-	inode =3D hugetlbfs_get_inode(dir->i_sb, current->fsuid, gid, mode, dev);
+	inode =3D hugetlbfs_get_inode(dir->i_sb, current->fsuid, gid, mode, dev,
+					HUGETLB_SHARED | HUGETLB_RESERVE);
 	if (inode) {
 		dir->i_ctime =3D dir->i_mtime =3D CURRENT_TIME;
 		d_instantiate(dentry, inode);
@@ -581,7 +585,8 @@ static int hugetlbfs_symlink(struct inode *dir,
 		gid =3D current->fsgid;
=20
 	inode =3D hugetlbfs_get_inode(dir->i_sb, current->fsuid,
-					gid, S_IFLNK|S_IRWXUGO, 0);
+					gid, S_IFLNK|S_IRWXUGO, 0,
+					HUGETLB_SHARED | HUGETLB_RESERVE);
 	if (inode) {
 		int l =3D strlen(symname)+1;
 		error =3D page_symlink(inode, symname, l);
@@ -845,7 +850,8 @@ hugetlbfs_fill_super(struct super_block *sb, void *data=
, int silent)
 	sb->s_op =3D &hugetlbfs_ops;
 	sb->s_time_gran =3D 1;
 	inode =3D hugetlbfs_get_inode(sb, config.uid, config.gid,
-					S_IFDIR | config.mode, 0);
+					S_IFDIR | config.mode, 0,
+					HUGETLB_SHARED | HUGETLB_RESERVE);
 	if (!inode)
 		goto out_free;
=20
@@ -910,7 +916,8 @@ static int can_do_hugetlb_shm(void)
 			can_do_mlock());
 }
=20
-struct file *hugetlb_file_setup(const char *name, size_t size)
+struct file *hugetlb_file_setup(const char *name, size_t size,
+				unsigned long creat_flags)
 {
 	int error =3D -ENOMEM;
 	struct file *file;
@@ -921,11 +928,13 @@ struct file *hugetlb_file_setup(const char *name, siz=
e_t size)
 	if (!hugetlbfs_vfsmount)
 		return ERR_PTR(-ENOENT);
=20
-	if (!can_do_hugetlb_shm())
-		return ERR_PTR(-EPERM);
+	if (creat_flags & HUGETLB_SHARED) {
+		if (!can_do_hugetlb_shm())
+			return ERR_PTR(-EPERM);
=20
-	if (!user_shm_lock(size, current->user))
-		return ERR_PTR(-ENOMEM);
+		if (!user_shm_lock(size, current->user))
+			return ERR_PTR(-ENOMEM);
+	}
=20
 	root =3D hugetlbfs_vfsmount->mnt_root;
 	quick_string.name =3D name;
@@ -936,13 +945,14 @@ struct file *hugetlb_file_setup(const char *name, siz=
e_t size)
 		goto out_shm_unlock;
=20
 	error =3D -ENOSPC;
-	inode =3D hugetlbfs_get_inode(root->d_sb, current->fsuid,
-				current->fsgid, S_IFREG | S_IRWXUGO, 0);
+	inode =3D hugetlbfs_get_inode(root->d_sb, current->fsuid, current->fsgid,
+				    S_IFREG | S_IRWXUGO, 0, creat_flags);
 	if (!inode)
 		goto out_dentry;
=20
 	error =3D -ENOMEM;
-	if (hugetlb_reserve_pages(inode, 0, size >> HPAGE_SHIFT))
+	if ((creat_flags & HUGETLB_RESERVE) &&
+		hugetlb_reserve_pages(inode, 0, size >> HPAGE_SHIFT))
 		goto out_inode;
=20
 	d_instantiate(dentry, inode);
@@ -963,7 +973,8 @@ out_inode:
 out_dentry:
 	dput(dentry);
 out_shm_unlock:
-	user_shm_unlock(size, current->user);
+	if (creat_flags & HUGETLB_SHARED)
+		user_shm_unlock(size, current->user);
 	return ERR_PTR(error);
 }
=20
diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index addca4c..66b7a2b 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -165,12 +165,24 @@ static inline struct hugetlbfs_sb_info *HUGETLBFS_SB(=
struct super_block *sb)
=20
 extern const struct file_operations hugetlbfs_file_operations;
 extern struct vm_operations_struct hugetlb_vm_ops;
-struct file *hugetlb_file_setup(const char *name, size_t);
+struct file *hugetlb_file_setup(const char *name, size_t,
+				unsigned long creat_flags);
 int hugetlb_get_quota(struct address_space *mapping, long delta);
 void hugetlb_put_quota(struct address_space *mapping, long delta);
=20
 #define BLOCKS_PER_HUGEPAGE	(HPAGE_SIZE / 512)
=20
+#define HUGETLB_SHARED  0x00000001UL	/* Make the huge pages backed by the
+					 * file being created shared */
+
+#define HUGETLB_RESERVE 0x00000002UL	/* Reserve the huge pages backed by t=
he
+					 * new file */
+
+#define HUGETLB_STACK_FILE "hugetlb-stack"
+
+/* to align the pointer to the (next) huge page boundary */
+#define HPAGE_ALIGN(addr)	(((addr)+HPAGE_SIZE-1)&HPAGE_MASK)
+
 static inline int is_file_hugepages(struct file *file)
 {
 	if (file->f_op =3D=3D &hugetlbfs_file_operations)
@@ -189,7 +201,7 @@ static inline void set_file_hugepages(struct file *file=
)
=20
 #define is_file_hugepages(file)		0
 #define set_file_hugepages(file)	BUG()
-#define hugetlb_file_setup(name,size)	ERR_PTR(-ENOSYS)
+#define hugetlb_file_setup(name,size,creat_flags)	ERR_PTR(-ENOSYS)
=20
 #endif /* !CONFIG_HUGETLBFS */
=20
diff --git a/ipc/shm.c b/ipc/shm.c
index cc63fae..38941eb 100644
--- a/ipc/shm.c
+++ b/ipc/shm.c
@@ -401,7 +401,8 @@ static int newseg(struct ipc_namespace *ns, struct ipc_=
params *params)
 	sprintf (name, "SYSV%08x", key);
 	if (shmflg & SHM_HUGETLB) {
 		/* hugetlb_file_setup takes care of mlock user accounting */
-		file =3D hugetlb_file_setup(name, size);
+		file =3D hugetlb_file_setup(name, size,
+					  HUGETLB_SHARED | HUGETLB_RESERVE);
 		shp->mlock_user =3D current->user;
 	} else {
 		int acctflag =3D VM_ACCOUNT;


--=-CMoCLz5bdgTzTvWUMm2m
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQBIGnOhsnv9E83jkzoRAvdpAKCcbk2ykSbQ169lU+VhUgQLME2nEgCfdgEL
D855frHCoUAIZrT4MfeLUfw=
=QxY1
-----END PGP SIGNATURE-----

--=-CMoCLz5bdgTzTvWUMm2m--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
