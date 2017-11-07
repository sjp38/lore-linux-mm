Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 93BFE280245
	for <linux-mm@kvack.org>; Tue,  7 Nov 2017 07:28:11 -0500 (EST)
Received: by mail-oi0-f70.google.com with SMTP id j83so12729516oif.7
        for <linux-mm@kvack.org>; Tue, 07 Nov 2017 04:28:11 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z10si510423oiz.212.2017.11.07.04.28.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Nov 2017 04:28:10 -0800 (PST)
From: =?UTF-8?q?Marc-Andr=C3=A9=20Lureau?= <marcandre.lureau@redhat.com>
Subject: [PATCH v3 2/9] shmem: rename functions that are memfd-related
Date: Tue,  7 Nov 2017 13:27:53 +0100
Message-Id: <20171107122800.25517-3-marcandre.lureau@redhat.com>
In-Reply-To: <20171107122800.25517-1-marcandre.lureau@redhat.com>
References: <20171107122800.25517-1-marcandre.lureau@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: aarcange@redhat.com, hughd@google.com, nyc@holomorphy.com, mike.kravetz@oracle.com, =?UTF-8?q?Marc-Andr=C3=A9=20Lureau?= <marcandre.lureau@redhat.com>

Those functions are called for memfd files, backed by shmem or
hugetlb (the next patches will handle hugetlb).

Signed-off-by: Marc-AndrA(C) Lureau <marcandre.lureau@redhat.com>
Reviewed-by: Mike Kravetz <mike.kravetz@oracle.com>
---
 fs/fcntl.c               |  2 +-
 include/linux/shmem_fs.h |  4 ++--
 mm/shmem.c               | 10 +++++-----
 3 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/fs/fcntl.c b/fs/fcntl.c
index 8d78ffd7b399..ad7995c64370 100644
--- a/fs/fcntl.c
+++ b/fs/fcntl.c
@@ -418,7 +418,7 @@ static long do_fcntl(int fd, unsigned int cmd, unsigned long arg,
 		break;
 	case F_ADD_SEALS:
 	case F_GET_SEALS:
-		err = shmem_fcntl(filp, cmd, arg);
+		err = memfd_fcntl(filp, cmd, arg);
 		break;
 	case F_GET_RW_HINT:
 	case F_SET_RW_HINT:
diff --git a/include/linux/shmem_fs.h b/include/linux/shmem_fs.h
index 1f5bf07cb8be..33b659f62c2b 100644
--- a/include/linux/shmem_fs.h
+++ b/include/linux/shmem_fs.h
@@ -110,11 +110,11 @@ extern void shmem_uncharge(struct inode *inode, long pages);
 
 #ifdef CONFIG_TMPFS
 
-extern long shmem_fcntl(struct file *file, unsigned int cmd, unsigned long arg);
+extern long memfd_fcntl(struct file *file, unsigned int cmd, unsigned long arg);
 
 #else
 
-static inline long shmem_fcntl(struct file *f, unsigned int c, unsigned long a)
+static inline long memfd_fcntl(struct file *f, unsigned int c, unsigned long a)
 {
 	return -EINVAL;
 }
diff --git a/mm/shmem.c b/mm/shmem.c
index 37260c5e12fa..b7811979611f 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -2722,7 +2722,7 @@ static int shmem_wait_for_pins(struct address_space *mapping)
 		     F_SEAL_GROW | \
 		     F_SEAL_WRITE)
 
-static int shmem_add_seals(struct file *file, unsigned int seals)
+static int memfd_add_seals(struct file *file, unsigned int seals)
 {
 	struct inode *inode = file_inode(file);
 	struct shmem_inode_info *info = SHMEM_I(inode);
@@ -2792,7 +2792,7 @@ static int shmem_add_seals(struct file *file, unsigned int seals)
 	return error;
 }
 
-static int shmem_get_seals(struct file *file)
+static int memfd_get_seals(struct file *file)
 {
 	if (file->f_op != &shmem_file_operations)
 		return -EINVAL;
@@ -2800,7 +2800,7 @@ static int shmem_get_seals(struct file *file)
 	return SHMEM_I(file_inode(file))->seals;
 }
 
-long shmem_fcntl(struct file *file, unsigned int cmd, unsigned long arg)
+long memfd_fcntl(struct file *file, unsigned int cmd, unsigned long arg)
 {
 	long error;
 
@@ -2810,10 +2810,10 @@ long shmem_fcntl(struct file *file, unsigned int cmd, unsigned long arg)
 		if (arg > UINT_MAX)
 			return -EINVAL;
 
-		error = shmem_add_seals(file, arg);
+		error = memfd_add_seals(file, arg);
 		break;
 	case F_GET_SEALS:
-		error = shmem_get_seals(file);
+		error = memfd_get_seals(file);
 		break;
 	default:
 		error = -EINVAL;
-- 
2.15.0.125.g8f49766d64

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
