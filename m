Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id CBAFB440460
	for <linux-mm@kvack.org>; Wed,  8 Nov 2017 20:41:32 -0500 (EST)
Received: by mail-qt0-f198.google.com with SMTP id 31so3336209qtz.20
        for <linux-mm@kvack.org>; Wed, 08 Nov 2017 17:41:32 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id 70si5406359qkc.381.2017.11.08.17.41.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Nov 2017 17:41:32 -0800 (PST)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [RFC PATCH 1/3] mm: hugetlbfs: move HUGETLBFS_I outside #ifdef CONFIG_HUGETLBFS
Date: Wed,  8 Nov 2017 17:41:07 -0800
Message-Id: <20171109014109.21077-2-mike.kravetz@oracle.com>
In-Reply-To: <20171109014109.21077-1-mike.kravetz@oracle.com>
References: <20171109014109.21077-1-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@kernel.org>, =?UTF-8?q?Marc-Andr=C3=A9=20Lureau?= <marcandre.lureau@redhat.com>, David Herrmann <dh.herrmann@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>

HUGETLBFS_I will be referenced but not used in code outside #ifdef
CONFIG_HUGETLBFS.  Move the definition to prevent compiler errors.

Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
---
 include/linux/hugetlb.h | 27 ++++++++++++++++-----------
 1 file changed, 16 insertions(+), 11 deletions(-)

diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index 128ef10902f3..f816ac29dee0 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -8,6 +8,7 @@
 #include <linux/cgroup.h>
 #include <linux/list.h>
 #include <linux/kref.h>
+#include <linux/mempolicy.h>
 #include <asm/pgtable.h>
 
 struct ctl_table;
@@ -261,6 +262,21 @@ enum {
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
@@ -278,17 +294,6 @@ static inline struct hugetlbfs_sb_info *HUGETLBFS_SB(struct super_block *sb)
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
