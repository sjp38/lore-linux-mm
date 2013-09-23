Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f53.google.com (mail-pb0-f53.google.com [209.85.160.53])
	by kanga.kvack.org (Postfix) with ESMTP id CC75A6B003A
	for <linux-mm@kvack.org>; Mon, 23 Sep 2013 08:06:15 -0400 (EDT)
Received: by mail-pb0-f53.google.com with SMTP id up15so3110706pbc.26
        for <linux-mm@kvack.org>; Mon, 23 Sep 2013 05:06:15 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv6 13/22] mm, vfs: introduce i_split_sem
Date: Mon, 23 Sep 2013 15:05:41 +0300
Message-Id: <1379937950-8411-14-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1379937950-8411-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1379937950-8411-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, Dave Hansen <dave@sr71.net>, Ning Qu <quning@google.com>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

i_split_sem taken on read will protect hugepages in inode's pagecache
against splitting.

i_split_sem will be taken on write during splitting.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 fs/inode.c              |  3 +++
 include/linux/fs.h      |  3 +++
 include/linux/huge_mm.h | 10 ++++++++++
 3 files changed, 16 insertions(+)

diff --git a/fs/inode.c b/fs/inode.c
index b33ba8e021..ea06e378c6 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -162,6 +162,9 @@ int inode_init_always(struct super_block *sb, struct inode *inode)
 
 	atomic_set(&inode->i_dio_count, 0);
 
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE_PAGECACHE
+	init_rwsem(&inode->i_split_sem);
+#endif
 	mapping->a_ops = &empty_aops;
 	mapping->host = inode;
 	mapping->flags = 0;
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 3f40547ba1..26801f0bb1 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -610,6 +610,9 @@ struct inode {
 	atomic_t		i_readcount; /* struct files open RO */
 #endif
 	void			*i_private; /* fs or device private pointer */
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE_PAGECACHE
+	struct rw_semaphore	i_split_sem;
+#endif
 };
 
 static inline int inode_unhashed(struct inode *inode)
diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index 3700ada4d2..ce9fcae8ef 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -241,12 +241,22 @@ static inline int do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_str
 #define HPAGE_CACHE_NR         (1L << HPAGE_CACHE_ORDER)
 #define HPAGE_CACHE_INDEX_MASK (HPAGE_CACHE_NR - 1)
 
+#define i_split_down_read(inode) down_read(&inode->i_split_sem)
+#define i_split_up_read(inode) up_read(&inode->i_split_sem)
+
 #else
 
 #define HPAGE_CACHE_ORDER      ({ BUILD_BUG(); 0; })
 #define HPAGE_CACHE_NR         ({ BUILD_BUG(); 0; })
 #define HPAGE_CACHE_INDEX_MASK ({ BUILD_BUG(); 0; })
 
+static inline void i_split_down_read(struct inode *inode)
+{
+}
+
+static inline void i_split_up_read(struct inode *inode)
+{
+}
 #endif
 
 static inline bool transparent_hugepage_pagecache(void)
-- 
1.8.4.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
