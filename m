Message-Id: <20080129154949.974655390@szeredi.hu>
References: <20080129154900.145303789@szeredi.hu>
Date: Tue, 29 Jan 2008 16:49:03 +0100
From: Miklos Szeredi <miklos@szeredi.hu>
Subject: [patch 3/6] mm: bdi: expose the BDI object in sysfs for NFS
Content-Disposition: inline; filename=bdi-sysfs-nfs.patch
Sender: owner-linux-mm@kvack.org
From: Miklos Szeredi <mszeredi@suse.cz>
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: a.p.zijlstra@chello.nl, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Trond Myklebust <trond.myklebust@fys.uio.no>
List-ID: <linux-mm.kvack.org>

Register NFS' backing_dev_info under sysfs with the name
"nfs-MAJOR:MINOR"

Signed-off-by: Miklos Szeredi <mszeredi@suse.cz>
CC: Peter Zijlstra <a.p.zijlstra@chello.nl>
CC: Trond Myklebust <trond.myklebust@fys.uio.no>
---

Index: linux/fs/nfs/super.c
===================================================================
--- linux.orig/fs/nfs/super.c	2008-01-29 10:26:47.000000000 +0100
+++ linux/fs/nfs/super.c	2008-01-29 12:12:38.000000000 +0100
@@ -1475,6 +1475,12 @@ static int nfs_compare_super(struct supe
 	return nfs_compare_mount_options(sb, server, mntflags);
 }
 
+static int nfs_bdi_register(struct nfs_server *server)
+{
+	return bdi_register(&server->backing_dev_info, NULL, "nfs-%u:%u",
+			    MAJOR(server->s_dev), MINOR(server->s_dev));
+}
+
 static int nfs_get_sb(struct file_system_type *fs_type,
 	int flags, const char *dev_name, void *raw_data, struct vfsmount *mnt)
 {
@@ -1515,6 +1521,10 @@ static int nfs_get_sb(struct file_system
 	if (s->s_fs_info != server) {
 		nfs_free_server(server);
 		server = NULL;
+	} else {
+		error = nfs_bdi_register(server);
+		if (error)
+			goto error_splat_super;
 	}
 
 	if (!s->s_root) {
@@ -1555,6 +1565,7 @@ static void nfs_kill_super(struct super_
 {
 	struct nfs_server *server = NFS_SB(s);
 
+	bdi_unregister(&server->backing_dev_info);
 	kill_anon_super(s);
 	nfs_free_server(server);
 }
@@ -1599,6 +1610,10 @@ static int nfs_xdev_get_sb(struct file_s
 	if (s->s_fs_info != server) {
 		nfs_free_server(server);
 		server = NULL;
+	} else {
+		error = nfs_bdi_register(server);
+		if (error)
+			goto error_splat_super;
 	}
 
 	if (!s->s_root) {
@@ -1889,6 +1904,10 @@ static int nfs4_get_sb(struct file_syste
 	if (s->s_fs_info != server) {
 		nfs_free_server(server);
 		server = NULL;
+	} else {
+		error = nfs_bdi_register(server);
+		if (error)
+			goto error_splat_super;
 	}
 
 	if (!s->s_root) {
@@ -1974,6 +1993,10 @@ static int nfs4_xdev_get_sb(struct file_
 	if (s->s_fs_info != server) {
 		nfs_free_server(server);
 		server = NULL;
+	} else {
+		error = nfs_bdi_register(server);
+		if (error)
+			goto error_splat_super;
 	}
 
 	if (!s->s_root) {
@@ -2053,6 +2076,10 @@ static int nfs4_referral_get_sb(struct f
 	if (s->s_fs_info != server) {
 		nfs_free_server(server);
 		server = NULL;
+	} else {
+		error = nfs_bdi_register(server);
+		if (error)
+			goto error_splat_super;
 	}
 
 	if (!s->s_root) {

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
