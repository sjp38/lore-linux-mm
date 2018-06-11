Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 626B96B0295
	for <linux-mm@kvack.org>; Mon, 11 Jun 2018 10:07:08 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id z9-v6so10263061pfe.23
        for <linux-mm@kvack.org>; Mon, 11 Jun 2018 07:07:08 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id o26-v6si24587140pfe.44.2018.06.11.07.07.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 11 Jun 2018 07:07:07 -0700 (PDT)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v13 54/72] memfd: Convert memfd_tag_pins to XArray
Date: Mon, 11 Jun 2018 07:06:21 -0700
Message-Id: <20180611140639.17215-55-willy@infradead.org>
In-Reply-To: <20180611140639.17215-1-willy@infradead.org>
References: <20180611140639.17215-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@redhat.com>, Lukas Czerner <lczerner@redhat.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@lst.de>, Goldwyn Rodrigues <rgoldwyn@suse.com>, Nicholas Piggin <npiggin@gmail.com>, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>, linux-nilfs@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, Chao Yu <yuchao0@huawei.com>, linux-f2fs-devel@lists.sourceforge.net

From: Matthew Wilcox <mawilcox@microsoft.com>

Switch to a batch-processing model like memfd_wait_for_pins() and
use the xa_state previously set up by memfd_wait_for_pins().

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
Reviewed-by: Mike Kravetz <mike.kravetz@oracle.com>
---
 mm/memfd.c | 44 ++++++++++++++++++--------------------------
 1 file changed, 18 insertions(+), 26 deletions(-)

diff --git a/mm/memfd.c b/mm/memfd.c
index e7d6be725b7a..636de8d5c7c3 100644
--- a/mm/memfd.c
+++ b/mm/memfd.c
@@ -28,37 +28,29 @@
 #define MEMFD_TAG_PINNED        PAGECACHE_TAG_TOWRITE
 #define LAST_SCAN               4       /* about 150ms max */
 
-static void memfd_tag_pins(struct address_space *mapping)
+static void memfd_tag_pins(struct xa_state *xas)
 {
-	struct radix_tree_iter iter;
-	void __rcu **slot;
-	pgoff_t start;
 	struct page *page;
+	unsigned int tagged = 0;
 
 	lru_add_drain();
-	start = 0;
-	rcu_read_lock();
-
-	radix_tree_for_each_slot(slot, &mapping->i_pages, &iter, start) {
-		page = radix_tree_deref_slot(slot);
-		if (!page || radix_tree_exception(page)) {
-			if (radix_tree_deref_retry(page)) {
-				slot = radix_tree_iter_retry(&iter);
-				continue;
-			}
-		} else if (page_count(page) - page_mapcount(page) > 1) {
-			xa_lock_irq(&mapping->i_pages);
-			radix_tree_tag_set(&mapping->i_pages, iter.index,
-					   MEMFD_TAG_PINNED);
-			xa_unlock_irq(&mapping->i_pages);
-		}
 
-		if (need_resched()) {
-			slot = radix_tree_iter_resume(slot, &iter);
-			cond_resched_rcu();
-		}
+	xas_lock_irq(xas);
+	xas_for_each(xas, page, ULONG_MAX) {
+		if (xa_is_value(page))
+			continue;
+		if (page_count(page) - page_mapcount(page) > 1)
+			xas_set_tag(xas, MEMFD_TAG_PINNED);
+
+		if (++tagged % XA_CHECK_SCHED)
+			continue;
+
+		xas_pause(xas);
+		xas_unlock_irq(xas);
+		cond_resched();
+		xas_lock_irq(xas);
 	}
-	rcu_read_unlock();
+	xas_unlock_irq(xas);
 }
 
 /*
@@ -76,7 +68,7 @@ static int memfd_wait_for_pins(struct address_space *mapping)
 	struct page *page;
 	int error, scan;
 
-	memfd_tag_pins(mapping);
+	memfd_tag_pins(&xas);
 
 	error = 0;
 	for (scan = 0; scan <= LAST_SCAN; scan++) {
-- 
2.17.1
