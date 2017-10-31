Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 20AE06B025F
	for <linux-mm@kvack.org>; Tue, 31 Oct 2017 14:41:04 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id v132so20018770oie.19
        for <linux-mm@kvack.org>; Tue, 31 Oct 2017 11:41:04 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r8si1130634oih.396.2017.10.31.11.41.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 31 Oct 2017 11:41:03 -0700 (PDT)
From: =?UTF-8?q?Marc-Andr=C3=A9=20Lureau?= <marcandre.lureau@redhat.com>
Subject: [PATCH 1/6] shmem: unexport shmem_add_seals()/shmem_get_seals()
Date: Tue, 31 Oct 2017 19:40:47 +0100
Message-Id: <20171031184052.25253-2-marcandre.lureau@redhat.com>
In-Reply-To: <20171031184052.25253-1-marcandre.lureau@redhat.com>
References: <20171031184052.25253-1-marcandre.lureau@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: aarcange@redhat.com, hughd@google.com, nyc@holomorphy.com, mike.kravetz@oracle.com, =?UTF-8?q?Marc-Andr=C3=A9=20Lureau?= <marcandre.lureau@redhat.com>

The functions are called through shmem_fcntl() only.

Signed-off-by: Marc-AndrA(C) Lureau <marcandre.lureau@redhat.com>
---
 include/linux/shmem_fs.h | 2 --
 mm/shmem.c               | 6 ++----
 2 files changed, 2 insertions(+), 6 deletions(-)

diff --git a/include/linux/shmem_fs.h b/include/linux/shmem_fs.h
index b6c3540e07bc..557d0c3b6eca 100644
--- a/include/linux/shmem_fs.h
+++ b/include/linux/shmem_fs.h
@@ -109,8 +109,6 @@ extern void shmem_uncharge(struct inode *inode, long pages);
 
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
