Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7261C6B026C
	for <linux-mm@kvack.org>; Wed, 22 Nov 2017 16:08:18 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id 26so15483812pfs.22
        for <linux-mm@kvack.org>; Wed, 22 Nov 2017 13:08:18 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id 63si14863735pla.782.2017.11.22.13.08.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Nov 2017 13:08:17 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH 11/62] Export __set_page_dirty
Date: Wed, 22 Nov 2017 13:06:48 -0800
Message-Id: <20171122210739.29916-12-willy@infradead.org>
In-Reply-To: <20171122210739.29916-1-willy@infradead.org>
References: <20171122210739.29916-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

XFS currently contains a copy-and-paste of __set_page_dirty().  Export
it from buffer.c instead.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 fs/buffer.c        |  3 ++-
 fs/xfs/xfs_aops.c  | 15 ++-------------
 include/linux/mm.h |  1 +
 3 files changed, 5 insertions(+), 14 deletions(-)

diff --git a/fs/buffer.c b/fs/buffer.c
index 0736a6a2e2f0..fd894c2ae284 100644
--- a/fs/buffer.c
+++ b/fs/buffer.c
@@ -601,7 +601,7 @@ EXPORT_SYMBOL(mark_buffer_dirty_inode);
  *
  * The caller must hold lock_page_memcg().
  */
-static void __set_page_dirty(struct page *page, struct address_space *mapping,
+void __set_page_dirty(struct page *page, struct address_space *mapping,
 			     int warn)
 {
 	unsigned long flags;
@@ -615,6 +615,7 @@ static void __set_page_dirty(struct page *page, struct address_space *mapping,
 	}
 	spin_unlock_irqrestore(&mapping->tree_lock, flags);
 }
+EXPORT_SYMBOL_GPL(__set_page_dirty);
 
 /*
  * Add a page to the dirty page list.
diff --git a/fs/xfs/xfs_aops.c b/fs/xfs/xfs_aops.c
index a3eeaba156c5..48b17d522fa1 100644
--- a/fs/xfs/xfs_aops.c
+++ b/fs/xfs/xfs_aops.c
@@ -1459,19 +1459,8 @@ xfs_vm_set_page_dirty(
 	newly_dirty = !TestSetPageDirty(page);
 	spin_unlock(&mapping->private_lock);
 
-	if (newly_dirty) {
-		/* sigh - __set_page_dirty() is static, so copy it here, too */
-		unsigned long flags;
-
-		spin_lock_irqsave(&mapping->tree_lock, flags);
-		if (page->mapping) {	/* Race with truncate? */
-			WARN_ON_ONCE(!PageUptodate(page));
-			account_page_dirtied(page, mapping);
-			radix_tree_tag_set(&mapping->page_tree,
-					page_index(page), PAGECACHE_TAG_DIRTY);
-		}
-		spin_unlock_irqrestore(&mapping->tree_lock, flags);
-	}
+	if (newly_dirty)
+		__set_page_dirty(page, mapping, 1);
 	unlock_page_memcg(page);
 	if (newly_dirty)
 		__mark_inode_dirty(mapping->host, I_DIRTY_PAGES);
diff --git a/include/linux/mm.h b/include/linux/mm.h
index ee073146aaa7..c692451245be 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1434,6 +1434,7 @@ extern int try_to_release_page(struct page * page, gfp_t gfp_mask);
 extern void do_invalidatepage(struct page *page, unsigned int offset,
 			      unsigned int length);
 
+void __set_page_dirty(struct page *, struct address_space *, int warn);
 int __set_page_dirty_nobuffers(struct page *page);
 int __set_page_dirty_no_writeback(struct page *page);
 int redirty_page_for_writepage(struct writeback_control *wbc,
-- 
2.15.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
