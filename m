Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id 79A0F6B0081
	for <linux-mm@kvack.org>; Wed, 14 Jan 2015 04:44:05 -0500 (EST)
Received: by mail-wi0-f174.google.com with SMTP id h11so26884532wiw.1
        for <linux-mm@kvack.org>; Wed, 14 Jan 2015 01:44:05 -0800 (PST)
Received: from casper.infradead.org (casper.infradead.org. [2001:770:15f::2])
        by mx.google.com with ESMTPS id gy6si25109362wib.66.2015.01.14.01.44.01
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Jan 2015 01:44:01 -0800 (PST)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 10/12] nfs: don't call bdi_unregister
Date: Wed, 14 Jan 2015 10:42:39 +0100
Message-Id: <1421228561-16857-11-git-send-email-hch@lst.de>
In-Reply-To: <1421228561-16857-1-git-send-email-hch@lst.de>
References: <1421228561-16857-1-git-send-email-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@fb.com>
Cc: David Howells <dhowells@redhat.com>, Tejun Heo <tj@kernel.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-mtd@lists.infradead.org, linux-nfs@vger.kernel.org, ceph-devel@vger.kernel.org

bdi_destroy already does all the work, and if we delay freeing the
anon bdev we can get away with just that single call.

Addintionally remove the call during mount failure, as
deactivate_super_locked will already call ->kill_sb and clean up
the bdi for us.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfs/internal.h  |  1 -
 fs/nfs/nfs4super.c |  1 -
 fs/nfs/super.c     | 24 ++++++------------------
 3 files changed, 6 insertions(+), 20 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index efaa31c..f519d41 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -416,7 +416,6 @@ int  nfs_show_options(struct seq_file *, struct dentry *);
 int  nfs_show_devname(struct seq_file *, struct dentry *);
 int  nfs_show_path(struct seq_file *, struct dentry *);
 int  nfs_show_stats(struct seq_file *, struct dentry *);
-void nfs_put_super(struct super_block *);
 int nfs_remount(struct super_block *sb, int *flags, char *raw_data);
 
 /* write.c */
diff --git a/fs/nfs/nfs4super.c b/fs/nfs/nfs4super.c
index 6f340f0..ab30a3a 100644
--- a/fs/nfs/nfs4super.c
+++ b/fs/nfs/nfs4super.c
@@ -53,7 +53,6 @@ static const struct super_operations nfs4_sops = {
 	.destroy_inode	= nfs_destroy_inode,
 	.write_inode	= nfs4_write_inode,
 	.drop_inode	= nfs_drop_inode,
-	.put_super	= nfs_put_super,
 	.statfs		= nfs_statfs,
 	.evict_inode	= nfs4_evict_inode,
 	.umount_begin	= nfs_umount_begin,
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 31a11b0..6ec4fe2 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -311,7 +311,6 @@ const struct super_operations nfs_sops = {
 	.destroy_inode	= nfs_destroy_inode,
 	.write_inode	= nfs_write_inode,
 	.drop_inode	= nfs_drop_inode,
-	.put_super	= nfs_put_super,
 	.statfs		= nfs_statfs,
 	.evict_inode	= nfs_evict_inode,
 	.umount_begin	= nfs_umount_begin,
@@ -2569,7 +2568,7 @@ struct dentry *nfs_fs_mount_common(struct nfs_server *server,
 		error = nfs_bdi_register(server);
 		if (error) {
 			mntroot = ERR_PTR(error);
-			goto error_splat_bdi;
+			goto error_splat_super;
 		}
 		server->super = s;
 	}
@@ -2601,9 +2600,6 @@ error_splat_root:
 	dput(mntroot);
 	mntroot = ERR_PTR(error);
 error_splat_super:
-	if (server && !s->s_root)
-		bdi_unregister(&server->backing_dev_info);
-error_splat_bdi:
 	deactivate_locked_super(s);
 	goto out;
 }
@@ -2651,27 +2647,19 @@ out:
 EXPORT_SYMBOL_GPL(nfs_fs_mount);
 
 /*
- * Ensure that we unregister the bdi before kill_anon_super
- * releases the device name
- */
-void nfs_put_super(struct super_block *s)
-{
-	struct nfs_server *server = NFS_SB(s);
-
-	bdi_unregister(&server->backing_dev_info);
-}
-EXPORT_SYMBOL_GPL(nfs_put_super);
-
-/*
  * Destroy an NFS2/3 superblock
  */
 void nfs_kill_super(struct super_block *s)
 {
 	struct nfs_server *server = NFS_SB(s);
+	dev_t dev = s->s_dev;
+
+	generic_shutdown_super(s);
 
-	kill_anon_super(s);
 	nfs_fscache_release_super_cookie(s);
+
 	nfs_free_server(server);
+	free_anon_bdev(dev);
 }
 EXPORT_SYMBOL_GPL(nfs_kill_super);
 
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
