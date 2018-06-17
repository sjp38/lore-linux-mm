Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id A2C426B0293
	for <linux-mm@kvack.org>; Sat, 16 Jun 2018 22:01:36 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id z11-v6so6701395pfn.1
        for <linux-mm@kvack.org>; Sat, 16 Jun 2018 19:01:36 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id f26-v6si10635008pfn.366.2018.06.16.19.01.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 16 Jun 2018 19:01:35 -0700 (PDT)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v14 66/74] dax: Convert __dax_invalidate_entry to XArray
Date: Sat, 16 Jun 2018 19:00:44 -0700
Message-Id: <20180617020052.4759-67-willy@infradead.org>
In-Reply-To: <20180617020052.4759-1-willy@infradead.org>
References: <20180617020052.4759-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <willy@infradead.org>, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@redhat.com>, Lukas Czerner <lczerner@redhat.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@lst.de>, Goldwyn Rodrigues <rgoldwyn@suse.com>, Nicholas Piggin <npiggin@gmail.com>, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>, linux-nilfs@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, Chao Yu <yuchao0@huawei.com>, linux-f2fs-devel@lists.sourceforge.net

Avoids walking the radix tree multiple times looking for tags.

Signed-off-by: Matthew Wilcox <willy@infradead.org>
---
 fs/dax.c | 17 +++++++++--------
 1 file changed, 9 insertions(+), 8 deletions(-)

diff --git a/fs/dax.c b/fs/dax.c
index 7b80b17cba50..fe5cc4470d99 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -752,27 +752,28 @@ EXPORT_SYMBOL_GPL(dax_layout_busy_page);
 static int __dax_invalidate_entry(struct address_space *mapping,
 					  pgoff_t index, bool trunc)
 {
+	XA_STATE(xas, &mapping->i_pages, index);
 	int ret = 0;
 	void *entry;
-	struct radix_tree_root *pages = &mapping->i_pages;
 
-	xa_lock_irq(pages);
-	entry = get_unlocked_mapping_entry(mapping, index, NULL);
+	xas_lock_irq(&xas);
+	entry = get_unlocked_entry(&xas);
 	if (!entry || WARN_ON_ONCE(!xa_is_value(entry)))
 		goto out;
 	if (!trunc &&
-	    (radix_tree_tag_get(pages, index, PAGECACHE_TAG_DIRTY) ||
-	     radix_tree_tag_get(pages, index, PAGECACHE_TAG_TOWRITE)))
+	    (xas_get_tag(&xas, PAGECACHE_TAG_DIRTY) ||
+	     xas_get_tag(&xas, PAGECACHE_TAG_TOWRITE)))
 		goto out;
 	dax_disassociate_entry(entry, mapping, trunc);
-	radix_tree_delete(pages, index);
+	xas_store(&xas, NULL);
 	mapping->nrexceptional--;
 	ret = 1;
 out:
-	put_unlocked_mapping_entry(mapping, index, entry);
-	xa_unlock_irq(pages);
+	put_unlocked_entry(&xas, entry);
+	xas_unlock_irq(&xas);
 	return ret;
 }
+
 /*
  * Delete DAX entry at @index from @mapping.  Wait for it
  * to be unlocked before deleting it.
-- 
2.17.1
