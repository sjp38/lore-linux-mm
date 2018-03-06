Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 06F056B0275
	for <linux-mm@kvack.org>; Tue,  6 Mar 2018 14:24:45 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id x7so11996629pfd.19
        for <linux-mm@kvack.org>; Tue, 06 Mar 2018 11:24:44 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id q7-v6si11496129pls.600.2018.03.06.11.24.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 06 Mar 2018 11:24:43 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v8 57/63] fs: Convert writeback to XArray
Date: Tue,  6 Mar 2018 11:24:07 -0800
Message-Id: <20180306192413.5499-58-willy@infradead.org>
In-Reply-To: <20180306192413.5499-1-willy@infradead.org>
References: <20180306192413.5499-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <mawilcox@microsoft.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>, linux-nilfs@vger.kernel.org, linux-btrfs@vger.kernel.org

From: Matthew Wilcox <mawilcox@microsoft.com>

A couple of short loops.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 fs/fs-writeback.c | 25 +++++++++----------------
 1 file changed, 9 insertions(+), 16 deletions(-)

diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index 091577edc497..98e5e08274a2 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -339,9 +339,9 @@ static void inode_switch_wbs_work_fn(struct work_struct *work)
 	struct address_space *mapping = inode->i_mapping;
 	struct bdi_writeback *old_wb = inode->i_wb;
 	struct bdi_writeback *new_wb = isw->new_wb;
-	struct radix_tree_iter iter;
+	XA_STATE(xas, &mapping->i_pages, 0);
+	struct page *page;
 	bool switched = false;
-	void **slot;
 
 	/*
 	 * By the time control reaches here, RCU grace period has passed
@@ -375,25 +375,18 @@ static void inode_switch_wbs_work_fn(struct work_struct *work)
 	 * to possibly dirty pages while PAGECACHE_TAG_WRITEBACK points to
 	 * pages actually under writeback.
 	 */
-	radix_tree_for_each_tagged(slot, &mapping->i_pages, &iter, 0,
-				   PAGECACHE_TAG_DIRTY) {
-		struct page *page = radix_tree_deref_slot_protected(slot,
-						&mapping->i_pages.xa_lock);
-		if (likely(page) && PageDirty(page)) {
+	xas_for_each_tag(&xas, page, ULONG_MAX, PAGECACHE_TAG_DIRTY) {
+		if (PageDirty(page)) {
 			dec_wb_stat(old_wb, WB_RECLAIMABLE);
 			inc_wb_stat(new_wb, WB_RECLAIMABLE);
 		}
 	}
 
-	radix_tree_for_each_tagged(slot, &mapping->i_pages, &iter, 0,
-				   PAGECACHE_TAG_WRITEBACK) {
-		struct page *page = radix_tree_deref_slot_protected(slot,
-						&mapping->i_pages.xa_lock);
-		if (likely(page)) {
-			WARN_ON_ONCE(!PageWriteback(page));
-			dec_wb_stat(old_wb, WB_WRITEBACK);
-			inc_wb_stat(new_wb, WB_WRITEBACK);
-		}
+	xas_set(&xas, 0);
+	xas_for_each_tag(&xas, page, ULONG_MAX, PAGECACHE_TAG_WRITEBACK) {
+		WARN_ON_ONCE(!PageWriteback(page));
+		dec_wb_stat(old_wb, WB_WRITEBACK);
+		inc_wb_stat(new_wb, WB_WRITEBACK);
 	}
 
 	wb_get(new_wb);
-- 
2.16.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
