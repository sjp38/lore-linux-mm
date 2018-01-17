Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 78210280286
	for <linux-mm@kvack.org>; Wed, 17 Jan 2018 15:23:10 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id n2so12213562pgs.0
        for <linux-mm@kvack.org>; Wed, 17 Jan 2018 12:23:10 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id l19si5019793pfj.363.2018.01.17.12.23.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 17 Jan 2018 12:23:09 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v6 99/99] null_blk: Convert to XArray
Date: Wed, 17 Jan 2018 12:22:03 -0800
Message-Id: <20180117202203.19756-100-willy@infradead.org>
In-Reply-To: <20180117202203.19756-1-willy@infradead.org>
References: <20180117202203.19756-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-nilfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-usb@vger.kernel.org, Bjorn Andersson <bjorn.andersson@linaro.org>, Stefano Stabellini <sstabellini@kernel.org>, iommu@lists.linux-foundation.org, linux-remoteproc@vger.kernel.org, linux-s390@vger.kernel.org, intel-gfx@lists.freedesktop.org, cgroups@vger.kernel.org, linux-sh@vger.kernel.org, David Howells <dhowells@redhat.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

We can probably avoid the call to xa_reserve() by changing the locking,
but I didn't feel confident enough to do that.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 drivers/block/null_blk.c | 87 +++++++++++++++++++++---------------------------
 1 file changed, 38 insertions(+), 49 deletions(-)

diff --git a/drivers/block/null_blk.c b/drivers/block/null_blk.c
index ad0477ae820f..d90d173b8885 100644
--- a/drivers/block/null_blk.c
+++ b/drivers/block/null_blk.c
@@ -15,6 +15,7 @@
 #include <linux/lightnvm.h>
 #include <linux/configfs.h>
 #include <linux/badblocks.h>
+#include <linux/xarray.h>
 
 #define SECTOR_SHIFT		9
 #define PAGE_SECTORS_SHIFT	(PAGE_SHIFT - SECTOR_SHIFT)
@@ -90,8 +91,8 @@ struct nullb_page {
 struct nullb_device {
 	struct nullb *nullb;
 	struct config_item item;
-	struct radix_tree_root data; /* data stored in the disk */
-	struct radix_tree_root cache; /* disk cache data */
+	struct xarray data; /* data stored in the disk */
+	struct xarray cache; /* disk cache data */
 	unsigned long flags; /* device flags */
 	unsigned int curr_cache;
 	struct badblocks badblocks;
@@ -558,8 +559,8 @@ static struct nullb_device *null_alloc_dev(void)
 	dev = kzalloc(sizeof(*dev), GFP_KERNEL);
 	if (!dev)
 		return NULL;
-	INIT_RADIX_TREE(&dev->data, GFP_ATOMIC);
-	INIT_RADIX_TREE(&dev->cache, GFP_ATOMIC);
+	xa_init_flags(&dev->data, XA_FLAGS_LOCK_IRQ);
+	xa_init_flags(&dev->cache, XA_FLAGS_LOCK_IRQ);
 	if (badblocks_init(&dev->badblocks, 0)) {
 		kfree(dev);
 		return NULL;
@@ -752,18 +753,18 @@ static void null_free_sector(struct nullb *nullb, sector_t sector,
 	unsigned int sector_bit;
 	u64 idx;
 	struct nullb_page *t_page, *ret;
-	struct radix_tree_root *root;
+	struct xarray *xa;
 
-	root = is_cache ? &nullb->dev->cache : &nullb->dev->data;
+	xa = is_cache ? &nullb->dev->cache : &nullb->dev->data;
 	idx = sector >> PAGE_SECTORS_SHIFT;
 	sector_bit = (sector & SECTOR_MASK);
 
-	t_page = radix_tree_lookup(root, idx);
+	t_page = xa_load(xa, idx);
 	if (t_page) {
 		__clear_bit(sector_bit, &t_page->bitmap);
 
 		if (!t_page->bitmap) {
-			ret = radix_tree_delete_item(root, idx, t_page);
+			ret = xa_cmpxchg(xa, idx, t_page, NULL, 0);
 			WARN_ON(ret != t_page);
 			null_free_page(ret);
 			if (is_cache)
@@ -772,47 +773,34 @@ static void null_free_sector(struct nullb *nullb, sector_t sector,
 	}
 }
 
-static struct nullb_page *null_radix_tree_insert(struct nullb *nullb, u64 idx,
+static struct nullb_page *null_xa_insert(struct nullb *nullb, u64 idx,
 	struct nullb_page *t_page, bool is_cache)
 {
-	struct radix_tree_root *root;
+	struct xarray *xa = is_cache ? &nullb->dev->cache : &nullb->dev->data;
+	struct nullb_page *exist;
 
-	root = is_cache ? &nullb->dev->cache : &nullb->dev->data;
-
-	if (radix_tree_insert(root, idx, t_page)) {
+	exist = xa_cmpxchg(xa, idx, NULL, t_page, GFP_ATOMIC);
+	if (exist) {
 		null_free_page(t_page);
-		t_page = radix_tree_lookup(root, idx);
-		WARN_ON(!t_page || t_page->page->index != idx);
+		t_page = exist;
 	} else if (is_cache)
 		nullb->dev->curr_cache += PAGE_SIZE;
 
+	WARN_ON(t_page->page->index != idx);
 	return t_page;
 }
 
 static void null_free_device_storage(struct nullb_device *dev, bool is_cache)
 {
-	unsigned long pos = 0;
-	int nr_pages;
-	struct nullb_page *ret, *t_pages[FREE_BATCH];
-	struct radix_tree_root *root;
-
-	root = is_cache ? &dev->cache : &dev->data;
-
-	do {
-		int i;
-
-		nr_pages = radix_tree_gang_lookup(root,
-				(void **)t_pages, pos, FREE_BATCH);
-
-		for (i = 0; i < nr_pages; i++) {
-			pos = t_pages[i]->page->index;
-			ret = radix_tree_delete_item(root, pos, t_pages[i]);
-			WARN_ON(ret != t_pages[i]);
-			null_free_page(ret);
-		}
+	struct nullb_page *t_page;
+	XA_STATE(xas, is_cache ? &dev->cache : &dev->data, 0);
 
-		pos++;
-	} while (nr_pages == FREE_BATCH);
+	xas_lock(&xas);
+	xas_for_each(&xas, t_page, ULONG_MAX) {
+		xas_store(&xas, NULL);
+		null_free_page(t_page);
+	}
+	xas_unlock(&xas);
 
 	if (is_cache)
 		dev->curr_cache = 0;
@@ -824,13 +812,13 @@ static struct nullb_page *__null_lookup_page(struct nullb *nullb,
 	unsigned int sector_bit;
 	u64 idx;
 	struct nullb_page *t_page;
-	struct radix_tree_root *root;
+	struct xarray *xa;
 
 	idx = sector >> PAGE_SECTORS_SHIFT;
 	sector_bit = (sector & SECTOR_MASK);
 
-	root = is_cache ? &nullb->dev->cache : &nullb->dev->data;
-	t_page = radix_tree_lookup(root, idx);
+	xa = is_cache ? &nullb->dev->cache : &nullb->dev->data;
+	t_page = xa_load(xa, idx);
 	WARN_ON(t_page && t_page->page->index != idx);
 
 	if (t_page && (for_write || test_bit(sector_bit, &t_page->bitmap)))
@@ -854,6 +842,7 @@ static struct nullb_page *null_lookup_page(struct nullb *nullb,
 static struct nullb_page *null_insert_page(struct nullb *nullb,
 	sector_t sector, bool ignore_cache)
 {
+	struct xarray *xa;
 	u64 idx;
 	struct nullb_page *t_page;
 
@@ -867,14 +856,14 @@ static struct nullb_page *null_insert_page(struct nullb *nullb,
 	if (!t_page)
 		goto out_lock;
 
-	if (radix_tree_preload(GFP_NOIO))
+	idx = sector >> PAGE_SECTORS_SHIFT;
+	xa = ignore_cache ? &nullb->dev->data : &nullb->dev->cache;
+	if (xa_reserve(xa, idx, GFP_NOIO))
 		goto out_freepage;
 
 	spin_lock_irq(&nullb->lock);
-	idx = sector >> PAGE_SECTORS_SHIFT;
 	t_page->page->index = idx;
-	t_page = null_radix_tree_insert(nullb, idx, t_page, !ignore_cache);
-	radix_tree_preload_end();
+	t_page = null_xa_insert(nullb, idx, t_page, !ignore_cache);
 
 	return t_page;
 out_freepage:
@@ -900,8 +889,7 @@ static int null_flush_cache_page(struct nullb *nullb, struct nullb_page *c_page)
 	if (test_bit(NULLB_PAGE_FREE, &c_page->bitmap)) {
 		null_free_page(c_page);
 		if (t_page && t_page->bitmap == 0) {
-			ret = radix_tree_delete_item(&nullb->dev->data,
-				idx, t_page);
+			xa_cmpxchg(&nullb->dev->data, idx, t_page, NULL, 0);
 			null_free_page(t_page);
 		}
 		return 0;
@@ -926,7 +914,7 @@ static int null_flush_cache_page(struct nullb *nullb, struct nullb_page *c_page)
 	kunmap_atomic(dst);
 	kunmap_atomic(src);
 
-	ret = radix_tree_delete_item(&nullb->dev->cache, idx, c_page);
+	ret = xa_cmpxchg(&nullb->dev->cache, idx, c_page, NULL, 0);
 	null_free_page(ret);
 	nullb->dev->curr_cache -= PAGE_SIZE;
 
@@ -944,8 +932,9 @@ static int null_make_cache_space(struct nullb *nullb, unsigned long n)
 	     nullb->dev->curr_cache + n || nullb->dev->curr_cache == 0)
 		return 0;
 
-	nr_pages = radix_tree_gang_lookup(&nullb->dev->cache,
-			(void **)c_pages, nullb->cache_flush_pos, FREE_BATCH);
+	nr_pages = xa_extract(&nullb->dev->cache, (void **)c_pages,
+				nullb->cache_flush_pos, ULONG_MAX,
+				FREE_BATCH, XA_PRESENT);
 	/*
 	 * nullb_flush_cache_page could unlock before using the c_pages. To
 	 * avoid race, we don't allow page free
@@ -1086,7 +1075,7 @@ static int null_handle_flush(struct nullb *nullb)
 			break;
 	}
 
-	WARN_ON(!radix_tree_empty(&nullb->dev->cache));
+	WARN_ON(!xa_empty(&nullb->dev->cache));
 	spin_unlock_irq(&nullb->lock);
 	return err;
 }
-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
