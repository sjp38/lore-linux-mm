Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id E07A16B0003
	for <linux-mm@kvack.org>; Thu, 18 Oct 2018 00:10:53 -0400 (EDT)
Received: by mail-io1-f72.google.com with SMTP id n10-v6so15708470iog.5
        for <linux-mm@kvack.org>; Wed, 17 Oct 2018 21:10:53 -0700 (PDT)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id t200-v6si3117321itc.56.2018.10.17.21.10.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Oct 2018 21:10:52 -0700 (PDT)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [PATCH] hugetlbfs: dirty pages as they are added to pagecache
Date: Wed, 17 Oct 2018 21:10:22 -0700
Message-Id: <20181018041022.4529-1-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Hugh Dickins <hughd@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Davidlohr Bueso <dave@stgolabs.net>, Alexander Viro <viro@zeniv.linux.org.uk>, Mike Kravetz <mike.kravetz@oracle.com>, stable@vger.kernel.org

Some test systems were experiencing negative huge page reserve
counts and incorrect file block counts.  This was traced to
/proc/sys/vm/drop_caches removing clean pages from hugetlbfs
file pagecaches.  When non-hugetlbfs explicit code removes the
pages, the appropriate accounting is not performed.

This can be recreated as follows:
 fallocate -l 2M /dev/hugepages/foo
 echo 1 > /proc/sys/vm/drop_caches
 fallocate -l 2M /dev/hugepages/foo
 grep -i huge /proc/meminfo
   AnonHugePages:         0 kB
   ShmemHugePages:        0 kB
   HugePages_Total:    2048
   HugePages_Free:     2047
   HugePages_Rsvd:    18446744073709551615
   HugePages_Surp:        0
   Hugepagesize:       2048 kB
   Hugetlb:         4194304 kB
 ls -lsh /dev/hugepages/foo
   4.0M -rw-r--r--. 1 root root 2.0M Oct 17 20:05 /dev/hugepages/foo

To address this issue, dirty pages as they are added to pagecache.
This can easily be reproduced with fallocate as shown above. Read
faulted pages will eventually end up being marked dirty.  But there
is a window where they are clean and could be impacted by code such
as drop_caches.  So, just dirty them all as they are added to the
pagecache.

In addition, it makes little sense to even try to drop hugetlbfs
pagecache pages, so disable calls to these filesystems in drop_caches
code.

Fixes: 70c3547e36f5 ("hugetlbfs: add hugetlbfs_fallocate()")
Cc: stable@vger.kernel.org
Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
---
 fs/drop_caches.c | 7 +++++++
 mm/hugetlb.c     | 6 ++++++
 2 files changed, 13 insertions(+)

diff --git a/fs/drop_caches.c b/fs/drop_caches.c
index 82377017130f..b72c5bc502a8 100644
--- a/fs/drop_caches.c
+++ b/fs/drop_caches.c
@@ -9,6 +9,7 @@
 #include <linux/writeback.h>
 #include <linux/sysctl.h>
 #include <linux/gfp.h>
+#include <linux/magic.h>
 #include "internal.h"
 
 /* A global variable is a bit ugly, but it keeps the code simple */
@@ -18,6 +19,12 @@ static void drop_pagecache_sb(struct super_block *sb, void *unused)
 {
 	struct inode *inode, *toput_inode = NULL;
 
+	/*
+	 * It makes no sense to try and drop hugetlbfs page cache pages.
+	 */
+	if (sb->s_magic == HUGETLBFS_MAGIC)
+		return;
+
 	spin_lock(&sb->s_inode_list_lock);
 	list_for_each_entry(inode, &sb->s_inodes, i_sb_list) {
 		spin_lock(&inode->i_lock);
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 5c390f5a5207..7b5c0ad9a6bd 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -3690,6 +3690,12 @@ int huge_add_to_page_cache(struct page *page, struct address_space *mapping,
 		return err;
 	ClearPagePrivate(page);
 
+	/*
+	 * set page dirty so that it will not be removed from cache/file
+	 * by non-hugetlbfs specific code paths.
+	 */
+	set_page_dirty(page);
+
 	spin_lock(&inode->i_lock);
 	inode->i_blocks += blocks_per_huge_page(h);
 	spin_unlock(&inode->i_lock);
-- 
2.17.2
