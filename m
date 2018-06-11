Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id AA1116B0282
	for <linux-mm@kvack.org>; Mon, 11 Jun 2018 10:06:57 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id t5-v6so6575104pgt.18
        for <linux-mm@kvack.org>; Mon, 11 Jun 2018 07:06:57 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id b3-v6si43659821pls.119.2018.06.11.07.06.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 11 Jun 2018 07:06:56 -0700 (PDT)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v13 36/72] mm: Convert truncate to XArray
Date: Mon, 11 Jun 2018 07:06:03 -0700
Message-Id: <20180611140639.17215-37-willy@infradead.org>
In-Reply-To: <20180611140639.17215-1-willy@infradead.org>
References: <20180611140639.17215-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@redhat.com>, Lukas Czerner <lczerner@redhat.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@lst.de>, Goldwyn Rodrigues <rgoldwyn@suse.com>, Nicholas Piggin <npiggin@gmail.com>, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>, linux-nilfs@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, Chao Yu <yuchao0@huawei.com>, linux-f2fs-devel@lists.sourceforge.net

From: Matthew Wilcox <mawilcox@microsoft.com>

This is essentially xa_cmpxchg() with the locking handled above us,
and it doesn't have to handle replacing a NULL entry.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 mm/truncate.c | 15 ++++++---------
 1 file changed, 6 insertions(+), 9 deletions(-)

diff --git a/mm/truncate.c b/mm/truncate.c
index ed778555c9f3..45d68e90b703 100644
--- a/mm/truncate.c
+++ b/mm/truncate.c
@@ -33,15 +33,12 @@
 static inline void __clear_shadow_entry(struct address_space *mapping,
 				pgoff_t index, void *entry)
 {
-	struct radix_tree_node *node;
-	void **slot;
+	XA_STATE(xas, &mapping->i_pages, index);
 
-	if (!__radix_tree_lookup(&mapping->i_pages, index, &node, &slot))
+	xas_set_update(&xas, workingset_update_node);
+	if (xas_load(&xas) != entry)
 		return;
-	if (*slot != entry)
-		return;
-	__radix_tree_replace(&mapping->i_pages, node, slot, NULL,
-			     workingset_update_node);
+	xas_store(&xas, NULL);
 	mapping->nrexceptional--;
 }
 
@@ -738,10 +735,10 @@ int invalidate_inode_pages2_range(struct address_space *mapping,
 		index++;
 	}
 	/*
-	 * For DAX we invalidate page tables after invalidating radix tree.  We
+	 * For DAX we invalidate page tables after invalidating page cache.  We
 	 * could invalidate page tables while invalidating each entry however
 	 * that would be expensive. And doing range unmapping before doesn't
-	 * work as we have no cheap way to find whether radix tree entry didn't
+	 * work as we have no cheap way to find whether page cache entry didn't
 	 * get remapped later.
 	 */
 	if (dax_mapping(mapping)) {
-- 
2.17.1
