Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 67863280271
	for <linux-mm@kvack.org>; Wed, 17 Jan 2018 15:22:56 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id e26so15091174pfi.15
        for <linux-mm@kvack.org>; Wed, 17 Jan 2018 12:22:56 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id n14si4974771pfh.229.2018.01.17.12.22.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 17 Jan 2018 12:22:54 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v6 63/99] dax: Convert dax_insert_mapping_entry to XArray
Date: Wed, 17 Jan 2018 12:21:27 -0800
Message-Id: <20180117202203.19756-64-willy@infradead.org>
In-Reply-To: <20180117202203.19756-1-willy@infradead.org>
References: <20180117202203.19756-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-nilfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-usb@vger.kernel.org, Bjorn Andersson <bjorn.andersson@linaro.org>, Stefano Stabellini <sstabellini@kernel.org>, iommu@lists.linux-foundation.org, linux-remoteproc@vger.kernel.org, linux-s390@vger.kernel.org, intel-gfx@lists.freedesktop.org, cgroups@vger.kernel.org, linux-sh@vger.kernel.org, David Howells <dhowells@redhat.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 fs/dax.c | 18 ++++++------------
 1 file changed, 6 insertions(+), 12 deletions(-)

diff --git a/fs/dax.c b/fs/dax.c
index e6b25ef112f2..494e8fb7a98f 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -498,9 +498,9 @@ static void *dax_insert_mapping_entry(struct address_space *mapping,
 				      void *entry, sector_t sector,
 				      unsigned long flags, bool dirty)
 {
-	struct radix_tree_root *pages = &mapping->pages;
 	void *new_entry;
 	pgoff_t index = vmf->pgoff;
+	XA_STATE(xas, &mapping->pages, index);
 
 	if (dirty)
 		__mark_inode_dirty(mapping->host, I_DIRTY_PAGES);
@@ -516,7 +516,7 @@ static void *dax_insert_mapping_entry(struct address_space *mapping,
 					PAGE_SIZE, 0);
 	}
 
-	xa_lock_irq(&mapping->pages);
+	xas_lock_irq(&xas);
 	new_entry = dax_radix_locked_entry(sector, flags);
 
 	if (dax_is_zero_entry(entry) || dax_is_empty_entry(entry)) {
@@ -528,21 +528,15 @@ static void *dax_insert_mapping_entry(struct address_space *mapping,
 		 * existing entry is a PMD, we will just leave the PMD in the
 		 * tree and dirty it if necessary.
 		 */
-		struct radix_tree_node *node;
-		void **slot;
-		void *ret;
-
-		ret = __radix_tree_lookup(pages, index, &node, &slot);
-		WARN_ON_ONCE(ret != entry);
-		__radix_tree_replace(pages, node, slot,
-				     new_entry, NULL);
+		void *prev = xas_store(&xas, new_entry);
+		WARN_ON_ONCE(prev != entry);
 		entry = new_entry;
 	}
 
 	if (dirty)
-		radix_tree_tag_set(pages, index, PAGECACHE_TAG_DIRTY);
+		xas_set_tag(&xas, PAGECACHE_TAG_DIRTY);
 
-	xa_unlock_irq(&mapping->pages);
+	xas_unlock_irq(&xas);
 	return entry;
 }
 
-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
