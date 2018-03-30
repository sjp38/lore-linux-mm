Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4DE336B005C
	for <linux-mm@kvack.org>; Thu, 29 Mar 2018 23:43:00 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id b9so5700909pgu.13
        for <linux-mm@kvack.org>; Thu, 29 Mar 2018 20:43:00 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id p1-v6si7282957plb.745.2018.03.29.20.42.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 29 Mar 2018 20:42:59 -0700 (PDT)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v10 58/62] dax: Convert __dax_invalidate_entry to XArray
Date: Thu, 29 Mar 2018 20:42:41 -0700
Message-Id: <20180330034245.10462-59-willy@infradead.org>
In-Reply-To: <20180330034245.10462-1-willy@infradead.org>
References: <20180330034245.10462-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@redhat.com>, Lukas Czerner <lczerner@redhat.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@lst.de>, Goldwyn Rodrigues <rgoldwyn@suse.com>, Nicholas Piggin <npiggin@gmail.com>, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>, linux-nilfs@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, Chao Yu <yuchao0@huawei.com>, linux-f2fs-devel@lists.sourceforge.net, Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Mike Kravetz <mike.kravetz@oracle.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

Avoids walking the radix tree multiple times looking for tags.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 fs/dax.c | 17 +++++++++--------
 1 file changed, 9 insertions(+), 8 deletions(-)

diff --git a/fs/dax.c b/fs/dax.c
index 825bf153f499..9602db13aa65 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -657,27 +657,28 @@ EXPORT_SYMBOL_GPL(dax_layout_busy_page);
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
2.16.2
