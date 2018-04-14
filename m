Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id B04756B0024
	for <linux-mm@kvack.org>; Sat, 14 Apr 2018 10:13:30 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id y7-v6so7579806plh.7
        for <linux-mm@kvack.org>; Sat, 14 Apr 2018 07:13:30 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id e3si5938054pgn.471.2018.04.14.07.13.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 14 Apr 2018 07:13:29 -0700 (PDT)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v11 47/63] fs: Convert writeback to XArray
Date: Sat, 14 Apr 2018 07:13:00 -0700
Message-Id: <20180414141316.7167-48-willy@infradead.org>
In-Reply-To: <20180414141316.7167-1-willy@infradead.org>
References: <20180414141316.7167-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@redhat.com>, Lukas Czerner <lczerner@redhat.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@lst.de>, Goldwyn Rodrigues <rgoldwyn@suse.com>, Nicholas Piggin <npiggin@gmail.com>, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>, linux-nilfs@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, Chao Yu <yuchao0@huawei.com>, linux-f2fs-devel@lists.sourceforge.net, Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Mike Kravetz <mike.kravetz@oracle.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

A couple of short loops.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 fs/fs-writeback.c | 25 +++++++++----------------
 1 file changed, 9 insertions(+), 16 deletions(-)

diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index 18e7807c74ea..87a2827721e0 100644
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
2.17.0
