Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id 9A9636B0031
	for <linux-mm@kvack.org>; Thu, 12 Sep 2013 09:46:45 -0400 (EDT)
Received: by mail-lb0-f169.google.com with SMTP id z5so935819lbh.0
        for <linux-mm@kvack.org>; Thu, 12 Sep 2013 06:46:43 -0700 (PDT)
Subject: [PATCH] shmem: fix double memory uncharge on error path
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Thu, 12 Sep 2013 17:46:41 +0400
Message-ID: <20130912134641.2306.24297.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

This patch removes erroneous call of shmem_unacct_size() from error path.
Shmem inode will release that memory reservation in shmem_evict_inode().
So, if following call of alloc_file fails we'll free reservation twice.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
---
 mm/shmem.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/mm/shmem.c b/mm/shmem.c
index 8297623..ff08920 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -2946,16 +2946,16 @@ struct file *shmem_file_setup(const char *name, loff_t size, unsigned long flags
 	this.len = strlen(name);
 	this.hash = 0; /* will go */
 	sb = shm_mnt->mnt_sb;
+	path.mnt = mntget(shm_mnt);
 	path.dentry = d_alloc_pseudo(sb, &this);
 	if (!path.dentry)
 		goto put_memory;
 	d_set_d_op(path.dentry, &anon_ops);
-	path.mnt = mntget(shm_mnt);
 
 	res = ERR_PTR(-ENOSPC);
 	inode = shmem_get_inode(sb, NULL, S_IFREG | S_IRWXUGO, 0, flags);
 	if (!inode)
-		goto put_dentry;
+		goto put_memory;
 
 	d_instantiate(path.dentry, inode);
 	inode->i_size = size;
@@ -2971,10 +2971,10 @@ struct file *shmem_file_setup(const char *name, loff_t size, unsigned long flags
 
 	return res;
 
-put_dentry:
-	path_put(&path);
 put_memory:
 	shmem_unacct_size(flags, size);
+put_dentry:
+	path_put(&path);
 	return res;
 }
 EXPORT_SYMBOL_GPL(shmem_file_setup);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
