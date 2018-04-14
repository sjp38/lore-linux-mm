Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6171E6B0006
	for <linux-mm@kvack.org>; Sat, 14 Apr 2018 10:13:27 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id z2-v6so7610499plk.3
        for <linux-mm@kvack.org>; Sat, 14 Apr 2018 07:13:27 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id f4-v6si1200661plo.316.2018.04.14.07.13.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 14 Apr 2018 07:13:25 -0700 (PDT)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v11 26/63] mm: Convert truncate to XArray
Date: Sat, 14 Apr 2018 07:12:39 -0700
Message-Id: <20180414141316.7167-27-willy@infradead.org>
In-Reply-To: <20180414141316.7167-1-willy@infradead.org>
References: <20180414141316.7167-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@redhat.com>, Lukas Czerner <lczerner@redhat.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@lst.de>, Goldwyn Rodrigues <rgoldwyn@suse.com>, Nicholas Piggin <npiggin@gmail.com>, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>, linux-nilfs@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, Chao Yu <yuchao0@huawei.com>, linux-f2fs-devel@lists.sourceforge.net, Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Mike Kravetz <mike.kravetz@oracle.com>

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
2.17.0
