Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 695FE6B0072
	for <linux-mm@kvack.org>; Fri, 21 Nov 2014 05:16:08 -0500 (EST)
Received: by mail-pd0-f175.google.com with SMTP id y10so5024918pdj.20
        for <linux-mm@kvack.org>; Fri, 21 Nov 2014 02:16:05 -0800 (PST)
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com. [209.85.192.170])
        by mx.google.com with ESMTPS id w4si7501274pdi.115.2014.11.21.02.16.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 21 Nov 2014 02:16:04 -0800 (PST)
Received: by mail-pd0-f170.google.com with SMTP id fp1so5027680pdb.1
        for <linux-mm@kvack.org>; Fri, 21 Nov 2014 02:16:03 -0800 (PST)
From: Omar Sandoval <osandov@osandov.com>
Subject: [PATCH v2 4/5] btrfs: don't allow -C or +c chattrs on a swap file
Date: Fri, 21 Nov 2014 02:08:30 -0800
Message-Id: <a422e8d7ce252474b998eeca3af5f1e2964c5c50.1416563833.git.osandov@osandov.com>
In-Reply-To: <cover.1416563833.git.osandov@osandov.com>
References: <cover.1416563833.git.osandov@osandov.com>
In-Reply-To: <cover.1416563833.git.osandov@osandov.com>
References: <cover.1416563833.git.osandov@osandov.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Chris Mason <clm@fb.com>, Josef Bacik <jbacik@fb.com>, linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-nfs@vger.kernel.org, Trond Myklebust <trond.myklebust@primarydata.com>, Mel Gorman <mgorman@suse.de>
Cc: Omar Sandoval <osandov@osandov.com>

swap_activate will check for a compressed or copy-on-write file; we shouldn't
allow it to become either once it has already been activated.

Signed-off-by: Omar Sandoval <osandov@osandov.com>
---
 fs/btrfs/ioctl.c | 50 +++++++++++++++++++++++++++++++-------------------
 1 file changed, 31 insertions(+), 19 deletions(-)

diff --git a/fs/btrfs/ioctl.c b/fs/btrfs/ioctl.c
index 4399f0c..f022dce 100644
--- a/fs/btrfs/ioctl.c
+++ b/fs/btrfs/ioctl.c
@@ -293,14 +293,21 @@ static int btrfs_ioctl_setflags(struct file *file, void __user *arg)
 		}
 	} else {
 		/*
-		 * Revert back under same assuptions as above
+		 * swap_activate checks that we don't swapon a copy-on-write
+		 * file, but we must also make sure that it doesn't become
+		 * copy-on-write.
 		 */
-		if (S_ISREG(mode)) {
-			if (inode->i_size == 0)
-				ip->flags &= ~(BTRFS_INODE_NODATACOW
-				             | BTRFS_INODE_NODATASUM);
-		} else {
-			ip->flags &= ~BTRFS_INODE_NODATACOW;
+		if (!IS_SWAPFILE(inode)) {
+			/*
+			 * Revert back under same assumptions as above
+			 */
+			if (S_ISREG(mode)) {
+				if (inode->i_size == 0)
+					ip->flags &= ~(BTRFS_INODE_NODATACOW |
+						       BTRFS_INODE_NODATASUM);
+			} else {
+				ip->flags &= ~BTRFS_INODE_NODATACOW;
+			}
 		}
 	}
 
@@ -317,20 +324,25 @@ static int btrfs_ioctl_setflags(struct file *file, void __user *arg)
 		if (ret && ret != -ENODATA)
 			goto out_drop;
 	} else if (flags & FS_COMPR_FL) {
-		const char *comp;
-
-		ip->flags |= BTRFS_INODE_COMPRESS;
-		ip->flags &= ~BTRFS_INODE_NOCOMPRESS;
+		/*
+		 * Like nodatacow, swap_activate checks that we don't swapon a
+		 * compressed file, so we shouldn't let it become compressed.
+		 */
+		if (!IS_SWAPFILE(inode)) {
+			const char *comp;
 
-		if (root->fs_info->compress_type == BTRFS_COMPRESS_LZO)
-			comp = "lzo";
-		else
-			comp = "zlib";
-		ret = btrfs_set_prop(inode, "btrfs.compression",
-				     comp, strlen(comp), 0);
-		if (ret)
-			goto out_drop;
+			ip->flags |= BTRFS_INODE_COMPRESS;
+			ip->flags &= ~BTRFS_INODE_NOCOMPRESS;
 
+			if (root->fs_info->compress_type == BTRFS_COMPRESS_LZO)
+				comp = "lzo";
+			else
+				comp = "zlib";
+			ret = btrfs_set_prop(inode, "btrfs.compression",
+					     comp, strlen(comp), 0);
+			if (ret)
+				goto out_drop;
+		}
 	} else {
 		ret = btrfs_set_prop(inode, "btrfs.compression", NULL, 0, 0);
 		if (ret && ret != -ENODATA)
-- 
2.1.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
