Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f171.google.com (mail-io0-f171.google.com [209.85.223.171])
	by kanga.kvack.org (Postfix) with ESMTP id 0D0AB6B0005
	for <linux-mm@kvack.org>; Fri, 11 Mar 2016 02:29:53 -0500 (EST)
Received: by mail-io0-f171.google.com with SMTP id n190so135632738iof.0
        for <linux-mm@kvack.org>; Thu, 10 Mar 2016 23:29:53 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id a13si1328773igm.79.2016.03.10.23.29.48
        for <linux-mm@kvack.org>;
        Thu, 10 Mar 2016 23:29:48 -0800 (PST)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v1 03/19] fs/anon_inodes: new interface to create new inode
Date: Fri, 11 Mar 2016 16:30:07 +0900
Message-Id: <1457681423-26664-4-git-send-email-minchan@kernel.org>
In-Reply-To: <1457681423-26664-1-git-send-email-minchan@kernel.org>
References: <1457681423-26664-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, jlayton@poochiereds.net, bfields@fieldses.org, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, koct9i@gmail.com, aquini@redhat.com, virtualization@lists.linux-foundation.org, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, rknize@motorola.com, Rik van Riel <riel@redhat.com>, Gioh Kim <gurugio@hanmail.net>, Minchan Kim <minchan@kernel.org>

From: Gioh Kim <gurugio@hanmail.net>

The anon_inodes has already complete interfaces to create manage
many anonymous inodes but don't have interface to get
new inode. Other sub-modules can create anonymous inode
without creating and mounting it's own pseudo filesystem.

Acked-by: Rafael Aquini <aquini@redhat.com>
Signed-off-by: Gioh Kim <gurugio@hanmail.net>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 fs/anon_inodes.c            | 6 ++++++
 include/linux/anon_inodes.h | 1 +
 2 files changed, 7 insertions(+)

diff --git a/fs/anon_inodes.c b/fs/anon_inodes.c
index 80ef38c73e5a..1d51f96acdd9 100644
--- a/fs/anon_inodes.c
+++ b/fs/anon_inodes.c
@@ -162,6 +162,12 @@ int anon_inode_getfd(const char *name, const struct file_operations *fops,
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
index 8013a45242fe..ddbd67f8a73f 100644
--- a/include/linux/anon_inodes.h
+++ b/include/linux/anon_inodes.h
@@ -15,6 +15,7 @@ struct file *anon_inode_getfile(const char *name,
 				void *priv, int flags);
 int anon_inode_getfd(const char *name, const struct file_operations *fops,
 		     void *priv, int flags);
+struct inode *anon_inode_new(void);
 
 #endif /* _LINUX_ANON_INODES_H */
 
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
