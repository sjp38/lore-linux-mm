Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 8B4D09003C7
	for <linux-mm@kvack.org>; Tue,  7 Jul 2015 00:34:50 -0400 (EDT)
Received: by pddu5 with SMTP id u5so30611464pdd.3
        for <linux-mm@kvack.org>; Mon, 06 Jul 2015 21:34:50 -0700 (PDT)
Received: from lgemrelse6q.lge.com (LGEMRELSE6Q.lge.com. [156.147.1.121])
        by mx.google.com with ESMTP id cq9si32532159pad.1.2015.07.06.21.34.48
        for <linux-mm@kvack.org>;
        Mon, 06 Jul 2015 21:34:49 -0700 (PDT)
From: Gioh Kim <gioh.kim@lge.com>
Subject: [RFCv3 1/5] fs/anon_inodes: new interface to create new inode
Date: Tue,  7 Jul 2015 13:36:21 +0900
Message-Id: <1436243785-24105-2-git-send-email-gioh.kim@lge.com>
In-Reply-To: <1436243785-24105-1-git-send-email-gioh.kim@lge.com>
References: <1436243785-24105-1-git-send-email-gioh.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: jlayton@poochiereds.net, bfields@fieldses.org, vbabka@suse.cz, iamjoonsoo.kim@lge.com, viro@zeniv.linux.org.uk, mst@redhat.com, koct9i@gmail.com, minchan@kernel.org, aquini@redhat.com, linux-fsdevel@vger.kernel.org, virtualization@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, linux-mm@kvack.org
Cc: gunho.lee@lge.com, akpm@linux-foundation.org, Gioh Kim <gurugio@hanmail.net>, Gioh Kim <gioh.kim@lge.com>

From: Gioh Kim <gurugio@hanmail.net>

The anon_inodes has already complete interfaces to create manage
many anonymous inodes but don't have interface to get
new inode. Other sub-modules can create anonymous inode
without creating and mounting it's own pseudo filesystem.

Signed-off-by: Gioh Kim <gioh.kim@lge.com>
---
 fs/anon_inodes.c            | 6 ++++++
 include/linux/anon_inodes.h | 1 +
 2 files changed, 7 insertions(+)

diff --git a/fs/anon_inodes.c b/fs/anon_inodes.c
index 80ef38c..1d51f96 100644
--- a/fs/anon_inodes.c
+++ b/fs/anon_inodes.c
@@ -162,6 +162,12 @@ err_put_unused_fd:
 }
 EXPORT_SYMBOL_GPL(anon_inode_getfd);
 
+struct inode *anon_inode_new(void)
+{
+	return alloc_anon_inode(anon_inode_mnt->mnt_sb);
+}
+EXPORT_SYMBOL_GPL(anon_inode_new);
+
 static int __init anon_inode_init(void)
 {
 	anon_inode_mnt = kern_mount(&anon_inode_fs_type);
diff --git a/include/linux/anon_inodes.h b/include/linux/anon_inodes.h
index 8013a45..ddbd67f 100644
--- a/include/linux/anon_inodes.h
+++ b/include/linux/anon_inodes.h
@@ -15,6 +15,7 @@ struct file *anon_inode_getfile(const char *name,
 				void *priv, int flags);
 int anon_inode_getfd(const char *name, const struct file_operations *fops,
 		     void *priv, int flags);
+struct inode *anon_inode_new(void);
 
 #endif /* _LINUX_ANON_INODES_H */
 
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
