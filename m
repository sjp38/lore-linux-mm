Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 62F196B0007
	for <linux-mm@kvack.org>; Mon, 29 Jan 2018 19:01:35 -0500 (EST)
Received: by mail-qt0-f199.google.com with SMTP id d15so9756176qtg.2
        for <linux-mm@kvack.org>; Mon, 29 Jan 2018 16:01:35 -0800 (PST)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id g24si2399664qte.120.2018.01.29.16.01.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Jan 2018 16:01:34 -0800 (PST)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [PATCH 1/3] mm: hugetlbfs: move HUGETLBFS_I outside #ifdef CONFIG_HUGETLBFS
Date: Mon, 29 Jan 2018 16:00:59 -0800
Message-Id: <20180130000101.7329-2-mike.kravetz@oracle.com>
In-Reply-To: <20180130000101.7329-1-mike.kravetz@oracle.com>
References: <20180130000101.7329-1-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@kernel.org>, =?UTF-8?q?Marc-Andr=C3=A9=20Lureau?= <marcandre.lureau@gmail.com>, David Herrmann <dh.herrmann@gmail.com>, Khalid Aziz <khalid.aziz@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>

HUGETLBFS_I will be referenced (but not used) in code outside #ifdef
CONFIG_HUGETLBFS.  Move the definition to prevent compiler errors.

Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
---
 include/linux/hugetlb.h | 27 ++++++++++++++++-----------
 1 file changed, 16 insertions(+), 11 deletions(-)

diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index 36fa6a2a82e3..222d2a329f14 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -9,6 +9,7 @@
 #include <linux/cgroup.h>
 #include <linux/list.h>
 #include <linux/kref.h>
+#include <linux/mempolicy.h>
 #include <asm/pgtable.h>
 
 struct ctl_table;
@@ -256,6 +257,21 @@ enum {
 	HUGETLB_ANONHUGE_INODE  = 2,
 };
 
+/*
+ * HUGETLBFS_I (and hugetlbfs_inode_info) referenced but not used by code
+ * outside #ifdef CONFIG_HUGETLBFS.  Define here to prevent compiler errors.
+ */
+struct hugetlbfs_inode_info {
+	struct shared_policy policy;
+	struct inode vfs_inode;
+	unsigned int seals;
+};
+
+static inline struct hugetlbfs_inode_info *HUGETLBFS_I(struct inode *inode)
+{
+	return container_of(inode, struct hugetlbfs_inode_info, vfs_inode);
+}
+
 #ifdef CONFIG_HUGETLBFS
 struct hugetlbfs_sb_info {
 	long	max_inodes;   /* inodes allowed */
@@ -273,17 +289,6 @@ static inline struct hugetlbfs_sb_info *HUGETLBFS_SB(struct super_block *sb)
 	return sb->s_fs_info;
 }
 
-struct hugetlbfs_inode_info {
-	struct shared_policy policy;
-	struct inode vfs_inode;
-	unsigned int seals;
-};
-
-static inline struct hugetlbfs_inode_info *HUGETLBFS_I(struct inode *inode)
-{
-	return container_of(inode, struct hugetlbfs_inode_info, vfs_inode);
-}
-
 extern const struct file_operations hugetlbfs_file_operations;
 extern const struct vm_operations_struct hugetlb_vm_ops;
 struct file *hugetlb_file_setup(const char *name, size_t size, vm_flags_t acct,
-- 
2.13.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
