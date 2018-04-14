Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4ACE66B02A0
	for <linux-mm@kvack.org>; Sat, 14 Apr 2018 10:15:08 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id g1-v6so996362plm.2
        for <linux-mm@kvack.org>; Sat, 14 Apr 2018 07:15:08 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 9-v6si7940095plb.140.2018.04.14.07.13.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 14 Apr 2018 07:13:28 -0700 (PDT)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v11 43/63] memfd: Convert shmem_tag_pins to XArray
Date: Sat, 14 Apr 2018 07:12:56 -0700
Message-Id: <20180414141316.7167-44-willy@infradead.org>
In-Reply-To: <20180414141316.7167-1-willy@infradead.org>
References: <20180414141316.7167-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@redhat.com>, Lukas Czerner <lczerner@redhat.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@lst.de>, Goldwyn Rodrigues <rgoldwyn@suse.com>, Nicholas Piggin <npiggin@gmail.com>, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>, linux-nilfs@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, Chao Yu <yuchao0@huawei.com>, linux-f2fs-devel@lists.sourceforge.net, Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Mike Kravetz <mike.kravetz@oracle.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

Switch to a batch-processing model like shmem_wait_for_pins() and
use the xa_state previously set up by shmem_wait_for_pins().

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
Reviewed-by: Mike Kravetz <mike.kravetz@oracle.com>
---
 mm/shmem.c | 44 ++++++++++++++++++--------------------------
 1 file changed, 18 insertions(+), 26 deletions(-)

diff --git a/mm/shmem.c b/mm/shmem.c
index 017340fe933d..2283872a84a1 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -2577,43 +2577,35 @@ static loff_t shmem_file_llseek(struct file *file, loff_t offset, int whence)
 }
 
 /*
- * We need a tag: a new tag would expand every radix_tree_node by 8 bytes,
+ * We need a tag: a new tag would expand every xa_node by 8 bytes,
  * so reuse a tag which we firmly believe is never set or cleared on shmem.
  */
 #define SHMEM_TAG_PINNED        PAGECACHE_TAG_TOWRITE
 #define LAST_SCAN               4       /* about 150ms max */
 
-static void shmem_tag_pins(struct address_space *mapping)
+static void shmem_tag_pins(struct xa_state *xas)
 {
-	struct radix_tree_iter iter;
-	void **slot;
-	pgoff_t start;
 	struct page *page;
+	unsigned int tagged = 0;
 
 	lru_add_drain();
-	start = 0;
-	rcu_read_lock();
 
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
-					   SHMEM_TAG_PINNED);
-			xa_unlock_irq(&mapping->i_pages);
-		}
+	xas_lock_irq(xas);
+	xas_for_each(xas, page, ULONG_MAX) {
+		if (xa_is_value(page))
+			continue;
+		if (page_count(page) - page_mapcount(page) > 1)
+			xas_set_tag(xas, SHMEM_TAG_PINNED);
 
-		if (need_resched()) {
-			slot = radix_tree_iter_resume(slot, &iter);
-			cond_resched_rcu();
-		}
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
@@ -2631,7 +2623,7 @@ static int shmem_wait_for_pins(struct address_space *mapping)
 	struct page *page;
 	int error, scan;
 
-	shmem_tag_pins(mapping);
+	shmem_tag_pins(&xas);
 
 	error = 0;
 	for (scan = 0; scan <= LAST_SCAN; scan++) {
-- 
2.17.0
