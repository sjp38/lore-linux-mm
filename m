Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 749096B0274
	for <linux-mm@kvack.org>; Wed, 22 Nov 2017 16:08:20 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id m4so4614340pgc.23
        for <linux-mm@kvack.org>; Wed, 22 Nov 2017 13:08:20 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id f13si13909593pgp.663.2017.11.22.13.08.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Nov 2017 13:08:19 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH 40/62] shmem: Convert shmem_tag_pins to XArray
Date: Wed, 22 Nov 2017 13:07:17 -0800
Message-Id: <20171122210739.29916-41-willy@infradead.org>
In-Reply-To: <20171122210739.29916-1-willy@infradead.org>
References: <20171122210739.29916-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

Simplify the locking by taking the spinlock while we walk the tree on
the assumption that many acquires and releases of the lock will be
worse than holding the lock for a (potentially) long time.

We could replicate the same locking behaviour with the xarray, but would
have to be careful that the xa_node wasn't RCU-freed under us before we
took the lock.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 include/linux/xarray.h |  8 ++++++++
 mm/shmem.c             | 39 ++++++++++++++++-----------------------
 2 files changed, 24 insertions(+), 23 deletions(-)

diff --git a/include/linux/xarray.h b/include/linux/xarray.h
index 1648eda4a20d..dda61b5c8e49 100644
--- a/include/linux/xarray.h
+++ b/include/linux/xarray.h
@@ -669,6 +669,14 @@ static inline void *xas_next_tag(struct xarray *xa, struct xa_state *xas,
 	return xa_entry(xa, node, offset);
 }
 
+/*
+ * If iterating while holding a lock, drop the lock and reschedule
+ * every %XA_CHECK_SCHED loops.
+ */
+enum {
+	XA_CHECK_SCHED = 4096,
+};
+
 /**
  * xas_for_each() - Iterate over a range of an XArray
  * @xa: XArray.
diff --git a/mm/shmem.c b/mm/shmem.c
index b6f7fc283aad..302fcb62ba1f 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -2601,35 +2601,28 @@ static loff_t shmem_file_llseek(struct file *file, loff_t offset, int whence)
 
 static void shmem_tag_pins(struct address_space *mapping)
 {
-	struct radix_tree_iter iter;
-	void **slot;
-	pgoff_t start;
+	XA_STATE(xas, 0);
 	struct page *page;
+	unsigned int tagged = 0;
 
 	lru_add_drain();
-	start = 0;
-	rcu_read_lock();
 
-	radix_tree_for_each_slot(slot, &mapping->pages, &iter, start) {
-		page = radix_tree_deref_slot(slot);
-		if (!page || radix_tree_exception(page)) {
-			if (radix_tree_deref_retry(page)) {
-				slot = radix_tree_iter_retry(&iter);
-				continue;
-			}
-		} else if (page_count(page) - page_mapcount(page) > 1) {
-			xa_lock_irq(&mapping->pages);
-			radix_tree_tag_set(&mapping->pages, iter.index,
-					   SHMEM_TAG_PINNED);
-			xa_unlock_irq(&mapping->pages);
-		}
+	xa_lock_irq(&mapping->pages);
+	xas_for_each(&mapping->pages, &xas, page, ULONG_MAX) {
+		if (xa_is_value(page))
+			continue;
+		if (page_count(page) - page_mapcount(page) > 1)
+			xas_set_tag(&mapping->pages, &xas, SHMEM_TAG_PINNED);
 
-		if (need_resched()) {
-			slot = radix_tree_iter_resume(slot, &iter);
-			cond_resched_rcu();
-		}
+		if (++tagged % XA_CHECK_SCHED)
+			continue;
+
+		xas_pause(&xas);
+		xa_unlock_irq(&mapping->pages);
+		cond_resched();
+		xa_lock_irq(&mapping->pages);
 	}
-	rcu_read_unlock();
+	xa_unlock_irq(&mapping->pages);
 }
 
 /*
-- 
2.15.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
