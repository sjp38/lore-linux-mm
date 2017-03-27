Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2AD5A6B0390
	for <linux-mm@kvack.org>; Mon, 27 Mar 2017 13:04:28 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id m66so81643360pga.15
        for <linux-mm@kvack.org>; Mon, 27 Mar 2017 10:04:28 -0700 (PDT)
Received: from shells.gnugeneration.com (shells.gnugeneration.com. [66.240.222.126])
        by mx.google.com with ESMTP id x21si1213333pgf.396.2017.03.27.10.04.27
        for <linux-mm@kvack.org>;
        Mon, 27 Mar 2017 10:04:27 -0700 (PDT)
Date: Mon, 27 Mar 2017 10:05:34 -0700
From: Vito Caputo <vcaputo@pengaru.com>
Subject: [PATCH] shmem: fix __shmem_file_setup error path leaks
Message-ID: <20170327170534.GA16903@shells.gnugeneration.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hughd@google.com
Cc: linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

The existing path and memory cleanups appear to be in reverse order, and
there's no iput() potentially leaking the inode in the last two error gotos.

Also make put_memory shmem_unacct_size() conditional on !inode since if we
entered cleanup at put_inode, shmem_evict_inode() occurs via
iput()->iput_final(), which performs the shmem_unacct_size() for us.

Signed-off-by: Vito Caputo <vcaputo@pengaru.com>
---

This caught my eye while looking through the memfd_create() implementation.
Included patch was compile tested only...

 mm/shmem.c | 15 +++++++++------
 1 file changed, 9 insertions(+), 6 deletions(-)

diff --git a/mm/shmem.c b/mm/shmem.c
index e67d6ba..a1a84eaf 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -4134,7 +4134,7 @@ static struct file *__shmem_file_setup(const char *name, loff_t size,
 				       unsigned long flags, unsigned int i_flags)
 {
 	struct file *res;
-	struct inode *inode;
+	struct inode *inode = NULL;
 	struct path path;
 	struct super_block *sb;
 	struct qstr this;
@@ -4162,7 +4162,7 @@ static struct file *__shmem_file_setup(const char *name, loff_t size,
 	res = ERR_PTR(-ENOSPC);
 	inode = shmem_get_inode(sb, NULL, S_IFREG | S_IRWXUGO, 0, flags);
 	if (!inode)
-		goto put_memory;
+		goto put_path;
 
 	inode->i_flags |= i_flags;
 	d_instantiate(path.dentry, inode);
@@ -4170,19 +4170,22 @@ static struct file *__shmem_file_setup(const char *name, loff_t size,
 	clear_nlink(inode);	/* It is unlinked */
 	res = ERR_PTR(ramfs_nommu_expand_for_mapping(inode, size));
 	if (IS_ERR(res))
-		goto put_path;
+		goto put_inode;
 
 	res = alloc_file(&path, FMODE_WRITE | FMODE_READ,
 		  &shmem_file_operations);
 	if (IS_ERR(res))
-		goto put_path;
+		goto put_inode;
 
 	return res;
 
-put_memory:
-	shmem_unacct_size(flags, size);
+put_inode:
+	iput(inode);
 put_path:
 	path_put(&path);
+put_memory:
+	if (!inode)
+		shmem_unacct_size(flags, size);
 	return res;
 }
 
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
