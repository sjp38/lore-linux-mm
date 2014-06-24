Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f46.google.com (mail-la0-f46.google.com [209.85.215.46])
	by kanga.kvack.org (Postfix) with ESMTP id E3F3C6B0031
	for <linux-mm@kvack.org>; Tue, 24 Jun 2014 16:16:12 -0400 (EDT)
Received: by mail-la0-f46.google.com with SMTP id el20so52246lab.33
        for <linux-mm@kvack.org>; Tue, 24 Jun 2014 13:16:12 -0700 (PDT)
Received: from mail-la0-x22f.google.com (mail-la0-x22f.google.com [2a00:1450:4010:c03::22f])
        by mx.google.com with ESMTPS id gk9si2648933lbc.45.2014.06.24.13.16.10
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 24 Jun 2014 13:16:11 -0700 (PDT)
Received: by mail-la0-f47.google.com with SMTP id s18so50905lam.6
        for <linux-mm@kvack.org>; Tue, 24 Jun 2014 13:16:10 -0700 (PDT)
Subject: [PATCH 1/3] shmem: fix double uncharge in __shmem_file_setup()
From: Konstantin Khlebnikov <koct9i@gmail.com>
Date: Wed, 25 Jun 2014 00:16:06 +0400
Message-ID: <20140624201606.18273.44270.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org

If __shmem_file_setup() fails on struct file allocation it uncharges memory
commitment twice: first by shmem_unacct_size() and second time implicitly in
shmem_evict_inode() when it kills newly created inode.
This patch removes shmem_unacct_size() from error path if inode already here.

Signed-off-by: Konstantin Khlebnikov <koct9i@gmail.com>
---
 mm/shmem.c |   12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/mm/shmem.c b/mm/shmem.c
index 8f419cf..0aabcbd 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -2895,16 +2895,16 @@ static struct file *__shmem_file_setup(const char *name, loff_t size,
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
 
 	inode->i_flags |= i_flags;
 	d_instantiate(path.dentry, inode);
@@ -2912,19 +2912,19 @@ static struct file *__shmem_file_setup(const char *name, loff_t size,
 	clear_nlink(inode);	/* It is unlinked */
 	res = ERR_PTR(ramfs_nommu_expand_for_mapping(inode, size));
 	if (IS_ERR(res))
-		goto put_dentry;
+		goto put_path;
 
 	res = alloc_file(&path, FMODE_WRITE | FMODE_READ,
 		  &shmem_file_operations);
 	if (IS_ERR(res))
-		goto put_dentry;
+		goto put_path;
 
 	return res;
 
-put_dentry:
-	path_put(&path);
 put_memory:
 	shmem_unacct_size(flags, size);
+put_path:
+	path_put(&path);
 	return res;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
