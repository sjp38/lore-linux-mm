Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id 66AB06B006C
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 21:03:21 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so24313241pbb.14
        for <linux-mm@kvack.org>; Mon, 09 Jul 2012 18:03:20 -0700 (PDT)
From: Wanpeng Li <liwp.linux@gmail.com>
Subject: [PATCH] mm/hugetlb: fix error code in hugetlbfs_alloc_inode
Date: Tue, 10 Jul 2012 09:03:04 +0800
Message-Id: <1341882184-4549-1-git-send-email-liwp.linux@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, William Irwin <wli@holomorphy.com>, linux-kernel@vger.kernel.org, Wanpeng Li <liwp.linux@gmail.com>

From: Wanpeng Li <liwp@linux.vnet.ibm.com>

When kmem_cache_alloc fails alloc slab object from
hugetlbfs_inode_cachep, return -ENOMEM in usual. But
hugetlbfs_alloc_inode implementation has inconsitency
with it and returns NULL. Fix it to return -ENOMEM.

Signed-off-by: Wanpeng Li <liwp.linux@gmail.com>
---
 fs/hugetlbfs/inode.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index c4b85d0..79a0f33 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -696,7 +696,7 @@ static struct inode *hugetlbfs_alloc_inode(struct super_block *sb)
 	p = kmem_cache_alloc(hugetlbfs_inode_cachep, GFP_KERNEL);
 	if (unlikely(!p)) {
 		hugetlbfs_inc_free_inodes(sbinfo);
-		return NULL;
+		return -ENOMEM;
 	}
 	return &p->vfs_inode;
 }
-- 
1.7.5.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
