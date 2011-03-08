Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 202978D0039
	for <linux-mm@kvack.org>; Tue,  8 Mar 2011 04:04:45 -0500 (EST)
From: Bob Liu <lliubbo@gmail.com>
Subject: [PATCH] shmem: put inode if alloc_file failed
Date: Tue, 8 Mar 2011 17:14:59 +0800
Message-ID: <1299575700-6901-1-git-send-email-lliubbo@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, viro@zeniv.linux.org.uk, hch@lst.de, hughd@google.com, npiggin@kernel.dk, Bob Liu <lliubbo@gmail.com>

Currently if alloc_file failed, inode willn't be put which may cause small
memory leak, this patch fix it.

Signed-off-by: Bob Liu <lliubbo@gmail.com>
---
 mm/shmem.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/mm/shmem.c b/mm/shmem.c
index 7c9cdc6..1e2bea7 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -2756,17 +2756,19 @@ struct file *shmem_file_setup(const char *name, loff_t size, unsigned long flags
 #ifndef CONFIG_MMU
 	error = ramfs_nommu_expand_for_mapping(inode, size);
 	if (error)
-		goto put_dentry;
+		goto put_inode;
 #endif
 
 	error = -ENFILE;
 	file = alloc_file(&path, FMODE_WRITE | FMODE_READ,
 		  &shmem_file_operations);
 	if (!file)
-		goto put_dentry;
+		goto put_inode;
 
 	return file;
 
+put_inode:
+	iput(inode);
 put_dentry:
 	path_put(&path);
 put_memory:
-- 
1.6.3.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
