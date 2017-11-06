Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 134546B0069
	for <linux-mm@kvack.org>; Mon,  6 Nov 2017 09:39:58 -0500 (EST)
Received: by mail-oi0-f72.google.com with SMTP id r128so10346272oig.3
        for <linux-mm@kvack.org>; Mon, 06 Nov 2017 06:39:58 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id y199si5282694oia.505.2017.11.06.06.39.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Nov 2017 06:39:56 -0800 (PST)
From: =?UTF-8?q?Marc-Andr=C3=A9=20Lureau?= <marcandre.lureau@redhat.com>
Subject: [PATCH v2 1/9] shmem: unexport shmem_add_seals()/shmem_get_seals()
Date: Mon,  6 Nov 2017 15:39:36 +0100
Message-Id: <20171106143944.13821-2-marcandre.lureau@redhat.com>
In-Reply-To: <20171106143944.13821-1-marcandre.lureau@redhat.com>
References: <20171106143944.13821-1-marcandre.lureau@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: aarcange@redhat.com, hughd@google.com, nyc@holomorphy.com, mike.kravetz@oracle.com, =?UTF-8?q?Marc-Andr=C3=A9=20Lureau?= <marcandre.lureau@redhat.com>

The functions are called through shmem_fcntl() only.  And no danger in
removing the EXPORTs as the routines only work with shmem file
structs.

Signed-off-by: Marc-AndrA(C) Lureau <marcandre.lureau@redhat.com>
Reviewed-by: Mike Kravetz <mike.kravetz@oracle.com>
---
 include/linux/shmem_fs.h | 2 --
 mm/shmem.c               | 6 ++----
 2 files changed, 2 insertions(+), 6 deletions(-)

diff --git a/include/linux/shmem_fs.h b/include/linux/shmem_fs.h
index ed91ce57c428..1f5bf07cb8be 100644
--- a/include/linux/shmem_fs.h
+++ b/include/linux/shmem_fs.h
@@ -110,8 +110,6 @@ extern void shmem_uncharge(struct inode *inode, long pages);
 
 #ifdef CONFIG_TMPFS
 
-extern int shmem_add_seals(struct file *file, unsigned int seals);
-extern int shmem_get_seals(struct file *file);
 extern long shmem_fcntl(struct file *file, unsigned int cmd, unsigned long arg);
 
 #else
diff --git a/mm/shmem.c b/mm/shmem.c
index 07a1d22807be..37260c5e12fa 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -2722,7 +2722,7 @@ static int shmem_wait_for_pins(struct address_space *mapping)
 		     F_SEAL_GROW | \
 		     F_SEAL_WRITE)
 
-int shmem_add_seals(struct file *file, unsigned int seals)
+static int shmem_add_seals(struct file *file, unsigned int seals)
 {
 	struct inode *inode = file_inode(file);
 	struct shmem_inode_info *info = SHMEM_I(inode);
@@ -2791,16 +2791,14 @@ int shmem_add_seals(struct file *file, unsigned int seals)
 	inode_unlock(inode);
 	return error;
 }
-EXPORT_SYMBOL_GPL(shmem_add_seals);
 
-int shmem_get_seals(struct file *file)
+static int shmem_get_seals(struct file *file)
 {
 	if (file->f_op != &shmem_file_operations)
 		return -EINVAL;
 
 	return SHMEM_I(file_inode(file))->seals;
 }
-EXPORT_SYMBOL_GPL(shmem_get_seals);
 
 long shmem_fcntl(struct file *file, unsigned int cmd, unsigned long arg)
 {
-- 
2.15.0.rc0.40.gaefcc5f6f

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
