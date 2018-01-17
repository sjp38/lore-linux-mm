Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 15788280262
	for <linux-mm@kvack.org>; Wed, 17 Jan 2018 15:22:49 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id q8so9436509pfh.12
        for <linux-mm@kvack.org>; Wed, 17 Jan 2018 12:22:49 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id v11si4333858pgb.825.2018.01.17.12.22.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 17 Jan 2018 12:22:48 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v6 47/99] shmem: Convert shmem_alloc_hugepage to XArray
Date: Wed, 17 Jan 2018 12:21:11 -0800
Message-Id: <20180117202203.19756-48-willy@infradead.org>
In-Reply-To: <20180117202203.19756-1-willy@infradead.org>
References: <20180117202203.19756-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-nilfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-usb@vger.kernel.org, Bjorn Andersson <bjorn.andersson@linaro.org>, Stefano Stabellini <sstabellini@kernel.org>, iommu@lists.linux-foundation.org, linux-remoteproc@vger.kernel.org, linux-s390@vger.kernel.org, intel-gfx@lists.freedesktop.org, cgroups@vger.kernel.org, linux-sh@vger.kernel.org, David Howells <dhowells@redhat.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

xa_find() is a slightly easier API to use than
radix_tree_gang_lookup_slot() because it contains its own RCU locking.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 mm/shmem.c | 14 ++++----------
 1 file changed, 4 insertions(+), 10 deletions(-)

diff --git a/mm/shmem.c b/mm/shmem.c
index 0f49edae05e4..e8233cb7ab5c 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -1413,23 +1413,17 @@ static struct page *shmem_alloc_hugepage(gfp_t gfp,
 		struct shmem_inode_info *info, pgoff_t index)
 {
 	struct vm_area_struct pvma;
-	struct inode *inode = &info->vfs_inode;
-	struct address_space *mapping = inode->i_mapping;
-	pgoff_t idx, hindex;
-	void __rcu **results;
+	struct address_space *mapping = info->vfs_inode.i_mapping;
+	pgoff_t hindex;
 	struct page *page;
 
 	if (!IS_ENABLED(CONFIG_TRANSPARENT_HUGE_PAGECACHE))
 		return NULL;
 
 	hindex = round_down(index, HPAGE_PMD_NR);
-	rcu_read_lock();
-	if (radix_tree_gang_lookup_slot(&mapping->pages, &results, &idx,
-				hindex, 1) && idx < hindex + HPAGE_PMD_NR) {
-		rcu_read_unlock();
+	if (xa_find(&mapping->pages, &hindex, hindex + HPAGE_PMD_NR - 1,
+								XA_PRESENT))
 		return NULL;
-	}
-	rcu_read_unlock();
 
 	shmem_pseudo_vma_init(&pvma, info, hindex);
 	page = alloc_pages_vma(gfp | __GFP_COMP | __GFP_NORETRY | __GFP_NOWARN,
-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
