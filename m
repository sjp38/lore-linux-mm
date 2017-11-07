Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7C04C280245
	for <linux-mm@kvack.org>; Tue,  7 Nov 2017 07:28:15 -0500 (EST)
Received: by mail-oi0-f71.google.com with SMTP id b189so12705675oia.10
        for <linux-mm@kvack.org>; Tue, 07 Nov 2017 04:28:15 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l185si521384oif.267.2017.11.07.04.28.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Nov 2017 04:28:14 -0800 (PST)
From: =?UTF-8?q?Marc-Andr=C3=A9=20Lureau?= <marcandre.lureau@redhat.com>
Subject: [PATCH v3 3/9] hugetlb: expose hugetlbfs_inode_info in header
Date: Tue,  7 Nov 2017 13:27:54 +0100
Message-Id: <20171107122800.25517-4-marcandre.lureau@redhat.com>
In-Reply-To: <20171107122800.25517-1-marcandre.lureau@redhat.com>
References: <20171107122800.25517-1-marcandre.lureau@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: aarcange@redhat.com, hughd@google.com, nyc@holomorphy.com, mike.kravetz@oracle.com, =?UTF-8?q?Marc-Andr=C3=A9=20Lureau?= <marcandre.lureau@redhat.com>

hugetlbfs inode information will need to be accessed by code in mm/shmem.c
for file sealing operations.  Move inode information definition from .c
file to header for needed access.

Signed-off-by: Marc-AndrA(C) Lureau <marcandre.lureau@redhat.com>
Reviewed-by: Mike Kravetz <mike.kravetz@oracle.com>
---
 fs/hugetlbfs/inode.c    | 10 ----------
 include/linux/hugetlb.h | 10 ++++++++++
 2 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index ed113ea17aff..f57aab929e41 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -55,16 +55,6 @@ struct hugetlbfs_config {
 	umode_t			mode;
 };
 
-struct hugetlbfs_inode_info {
-	struct shared_policy policy;
-	struct inode vfs_inode;
-};
-
-static inline struct hugetlbfs_inode_info *HUGETLBFS_I(struct inode *inode)
-{
-	return container_of(inode, struct hugetlbfs_inode_info, vfs_inode);
-}
-
 int sysctl_hugetlb_shm_group;
 
 enum {
diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index fbf5b31d47ee..590a77433a14 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -279,6 +279,16 @@ static inline struct hugetlbfs_sb_info *HUGETLBFS_SB(struct super_block *sb)
 	return sb->s_fs_info;
 }
 
+struct hugetlbfs_inode_info {
+	struct shared_policy policy;
+	struct inode vfs_inode;
+};
+
+static inline struct hugetlbfs_inode_info *HUGETLBFS_I(struct inode *inode)
+{
+	return container_of(inode, struct hugetlbfs_inode_info, vfs_inode);
+}
+
 extern const struct file_operations hugetlbfs_file_operations;
 extern const struct vm_operations_struct hugetlb_vm_ops;
 struct file *hugetlb_file_setup(const char *name, size_t size, vm_flags_t acct,
-- 
2.15.0.125.g8f49766d64

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
