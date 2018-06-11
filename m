Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9E85A6B0292
	for <linux-mm@kvack.org>; Mon, 11 Jun 2018 10:07:04 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id z11-v6so4872813pfn.1
        for <linux-mm@kvack.org>; Mon, 11 Jun 2018 07:07:04 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id f8-v6si44016757plt.35.2018.06.11.07.07.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 11 Jun 2018 07:07:03 -0700 (PDT)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v13 48/72] shmem: Convert find_swap_entry to XArray
Date: Mon, 11 Jun 2018 07:06:15 -0700
Message-Id: <20180611140639.17215-49-willy@infradead.org>
In-Reply-To: <20180611140639.17215-1-willy@infradead.org>
References: <20180611140639.17215-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@redhat.com>, Lukas Czerner <lczerner@redhat.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@lst.de>, Goldwyn Rodrigues <rgoldwyn@suse.com>, Nicholas Piggin <npiggin@gmail.com>, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>, linux-nilfs@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, Chao Yu <yuchao0@huawei.com>, linux-f2fs-devel@lists.sourceforge.net

From: Matthew Wilcox <mawilcox@microsoft.com>

This is a 1:1 conversion.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 mm/shmem.c | 27 ++++++++++-----------------
 1 file changed, 10 insertions(+), 17 deletions(-)

diff --git a/mm/shmem.c b/mm/shmem.c
index 479e4a8e6d68..983a27656e2e 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -1099,34 +1099,27 @@ static void shmem_evict_inode(struct inode *inode)
 	clear_inode(inode);
 }
 
-static unsigned long find_swap_entry(struct radix_tree_root *root, void *item)
+static unsigned long find_swap_entry(struct xarray *xa, void *item)
 {
-	struct radix_tree_iter iter;
-	void __rcu **slot;
-	unsigned long found = -1;
+	XA_STATE(xas, xa, 0);
 	unsigned int checked = 0;
+	void *entry;
 
 	rcu_read_lock();
-	radix_tree_for_each_slot(slot, root, &iter, 0) {
-		void *entry = radix_tree_deref_slot(slot);
-
-		if (radix_tree_deref_retry(entry)) {
-			slot = radix_tree_iter_retry(&iter);
+	xas_for_each(&xas, entry, ULONG_MAX) {
+		if (xas_retry(&xas, entry))
 			continue;
-		}
-		if (entry == item) {
-			found = iter.index;
+		if (entry == item)
 			break;
-		}
 		checked++;
-		if ((checked % 4096) != 0)
+		if ((checked % XA_CHECK_SCHED) != 0)
 			continue;
-		slot = radix_tree_iter_resume(slot, &iter);
+		xas_pause(&xas);
 		cond_resched_rcu();
 	}
-
 	rcu_read_unlock();
-	return found;
+
+	return xas_invalid(&xas) ? -1 : xas.xa_index;
 }
 
 /*
-- 
2.17.1
