Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3A0446B0003
	for <linux-mm@kvack.org>; Wed, 25 Apr 2018 10:14:08 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id n2so10948015pgs.2
        for <linux-mm@kvack.org>; Wed, 25 Apr 2018 07:14:08 -0700 (PDT)
Received: from out30-130.freemail.mail.aliyun.com (out30-130.freemail.mail.aliyun.com. [115.124.30.130])
        by mx.google.com with ESMTPS id u3si16258075pfh.145.2018.04.25.07.14.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Apr 2018 07:14:06 -0700 (PDT)
From: Yang Shi <yang.shi@linux.alibaba.com>
Subject: [RFC v5 PATCH] mm: shmem: make stat.st_blksize return huge page size if THP is on
Date: Wed, 25 Apr 2018 22:13:53 +0800
Message-Id: <1524665633-83806-1-git-send-email-yang.shi@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kirill.shutemov@linux.intel.com, hughd@google.com, mhocko@kernel.org, hch@infradead.org, viro@zeniv.linux.org.uk, akpm@linux-foundation.org
Cc: yang.shi@linux.alibaba.com, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Since tmpfs THP was supported in 4.8, hugetlbfs is not the only
filesystem with huge page support anymore. tmpfs can use huge page via
THP when mounting by "huge=" mount option.

When applications use huge page on hugetlbfs, it just need check the
filesystem magic number, but it is not enough for tmpfs. Make
stat.st_blksize return huge page size if it is mounted by appropriate
"huge=" option to give applications a hint to optimize the behavior with
THP.

Some applications may not do wisely with THP. For example, QEMU may mmap
file on non huge page aligned hint address with MAP_FIXED, which results
in no pages are PMD mapped even though THP is used. Some applications
may mmap file with non huge page aligned offset. Both behaviors make THP
pointless.

statfs.f_bsize still returns 4KB for tmpfs since THP could be split, and it
also may fallback to 4KB page silently if there is not enough huge page.
Furthermore, different f_bsize makes max_blocks and free_blocks
calculation harder but without too much benefit. Returning huge page
size via stat.st_blksize sounds good enough.

Since PUD size huge page for THP has not been supported, now it just
returns HPAGE_PMD_SIZE.

Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Hugh Dickins <hughd@google.com>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>
Suggested-by: Christoph Hellwig <hch@infradead.org>
---
v4 --> v5:
* Adopted suggestion from Kirill to use IS_ENABLED and check 'force' and
  'deny'. Extracted the condition into an inline helper.
v3 --> v4:
* Rework the commit log per the education from Michal and Kirill
* Fix build error if CONFIG_TRANSPARENT_HUGEPAGE is disabled
v2 --> v3:
* Use shmem_sb_info.huge instead of global variable per Michal's comment
v2 --> v1:
* Adopted the suggestion from hch to return huge page size via st_blksize
  instead of creating a new flag.

 mm/shmem.c | 15 +++++++++++++++
 1 file changed, 15 insertions(+)

diff --git a/mm/shmem.c b/mm/shmem.c
index b859192..e9e888b 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -571,6 +571,16 @@ static unsigned long shmem_unused_huge_shrink(struct shmem_sb_info *sbinfo,
 }
 #endif /* CONFIG_TRANSPARENT_HUGE_PAGECACHE */
 
+static inline bool is_huge_enabled(struct shmem_sb_info *sbinfo)
+{
+	if (IS_ENABLED(CONFIG_TRANSPARENT_HUGE_PAGECACHE) &&
+	    (shmem_huge == SHMEM_HUGE_FORCE || sbinfo->huge) &&
+	    shmem_huge != SHMEM_HUGE_DENY)
+		return true;
+	else
+		return false;
+}
+
 /*
  * Like add_to_page_cache_locked, but error if expected item has gone.
  */
@@ -988,6 +998,7 @@ static int shmem_getattr(const struct path *path, struct kstat *stat,
 {
 	struct inode *inode = path->dentry->d_inode;
 	struct shmem_inode_info *info = SHMEM_I(inode);
+	struct shmem_sb_info *sb_info = SHMEM_SB(inode->i_sb);
 
 	if (info->alloced - info->swapped != inode->i_mapping->nrpages) {
 		spin_lock_irq(&info->lock);
@@ -995,6 +1006,10 @@ static int shmem_getattr(const struct path *path, struct kstat *stat,
 		spin_unlock_irq(&info->lock);
 	}
 	generic_fillattr(inode, stat);
+
+	if (is_huge_enabled(sb_info))
+		stat->blksize = HPAGE_PMD_SIZE;
+
 	return 0;
 }
 
-- 
1.8.3.1
