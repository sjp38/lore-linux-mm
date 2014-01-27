Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f52.google.com (mail-bk0-f52.google.com [209.85.214.52])
	by kanga.kvack.org (Postfix) with ESMTP id 4F9936B0031
	for <linux-mm@kvack.org>; Mon, 27 Jan 2014 09:03:02 -0500 (EST)
Received: by mail-bk0-f52.google.com with SMTP id e11so2844762bkh.39
        for <linux-mm@kvack.org>; Mon, 27 Jan 2014 06:03:01 -0800 (PST)
Received: from mail-qc0-x233.google.com (mail-qc0-x233.google.com [2607:f8b0:400d:c01::233])
        by mx.google.com with ESMTPS id tb1si14526299bkb.21.2014.01.27.06.03.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 27 Jan 2014 06:03:01 -0800 (PST)
Received: by mail-qc0-f179.google.com with SMTP id e16so7939416qcx.38
        for <linux-mm@kvack.org>; Mon, 27 Jan 2014 06:02:59 -0800 (PST)
From: Dan Streetman <ddstreet@ieee.org>
Subject: [PATCH v2] mm/zswap: add writethrough option
Date: Mon, 27 Jan 2014 09:01:19 -0500
Message-Id: <1390831279-5525-1-git-send-email-ddstreet@ieee.org>
In-Reply-To: <1387459407-29342-1-git-send-email-ddstreet@ieee.org>
References: <1387459407-29342-1-git-send-email-ddstreet@ieee.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjennings@variantweb.net>, Andrew Morton <akpm@linux-foundation.org>
Cc: Dan Streetman <ddstreet@ieee.org>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Bob Liu <bob.liu@oracle.com>, Minchan Kim <minchan@kernel.org>, Weijie Yang <weijie.yang@samsung.com>, Shirish Pargaonkar <spargaonkar@suse.com>, Mel Gorman <mgorman@suse.de>

Currently, zswap is writeback cache; stored pages are not sent
to swap disk, and when zswap wants to evict old pages it must
first write them back to swap cache/disk manually.  This avoids
swap out disk I/O up front, but only moves that disk I/O to
the writeback case (for pages that are evicted), and adds the
overhead of having to uncompress the evicted pages and the
need for an additional free page (to store the uncompressed page).

This optionally changes zswap to writethrough cache by enabling
frontswap_writethrough() before registering, so that any
successful page store will also be written to swap disk.  The
default remains writeback.  To enable writethrough, the param
zswap.writethrough=1 must be used at boot.

Whether writeback or writethrough will provide better performance
depends on many factors including disk I/O speed/throughput,
CPU speed(s), system load, etc.  In most cases it is likely
that writeback has better performance than writethrough before
zswap is full, but after zswap fills up writethrough has
better performance than writeback.

The reason to add this option now is, first to allow any zswap
user to be able to test using writethrough to determine if they
get better performance than using writeback, and second to allow
future updates to zswap, such as the possibility of dynamically
switching between writeback and writethrough.

Signed-off-by: Dan Streetman <ddstreet@ieee.org>

---

Changes in v2:
 - update changelog with reasoning to include patch now,
   in response to Minchan's concerns

Based on specjbb testing on my laptop, the results for both writeback
and writethrough are better than not using zswap at all, but writeback
does seem to be better than writethrough while zswap isn't full.  Once
it fills up, performance for writethrough is essentially close to not
using zswap, while writeback seems to be worse than not using zswap.
However, I think more testing on a wider span of systems and conditions
is needed.  Additionally, I'm not sure that specjbb is measuring true
performance under fully loaded cpu conditions, so additional cpu load
might need to be added or specjbb parameters modified (I took the
values from the 4 "warehouses" test run).

In any case though, I think having writethrough as an option is still
useful.  More changes could be made, such as changing from writeback
to writethrough based on the zswap % full.  And the patch doesn't
change default behavior - writethrough must be specifically enabled.

The %-ized numbers I got from specjbb on average, using the default
20% max_pool_percent and varying the amount of heap used as shown:

ram | no zswap | writeback | writethrough
75     93.08     100         96.90
87     96.58     95.58       96.72
100    92.29     89.73       86.75
112    63.80     38.66       19.66
125    4.79      29.90       15.75
137    4.99      4.50        4.75
150    4.28      4.62        5.01
162    5.20      2.94        4.66
175    5.71      2.11        4.84



 mm/zswap.c | 68 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++----
 1 file changed, 64 insertions(+), 4 deletions(-)

diff --git a/mm/zswap.c b/mm/zswap.c
index e55bab9..2f919db 100644
--- a/mm/zswap.c
+++ b/mm/zswap.c
@@ -61,6 +61,8 @@ static atomic_t zswap_stored_pages = ATOMIC_INIT(0);
 static u64 zswap_pool_limit_hit;
 /* Pages written back when pool limit was reached */
 static u64 zswap_written_back_pages;
+/* Pages evicted when pool limit was reached */
+static u64 zswap_evicted_pages;
 /* Store failed due to a reclaim failure after pool limit was reached */
 static u64 zswap_reject_reclaim_fail;
 /* Compressed page was too big for the allocator to (optimally) store */
@@ -89,6 +91,10 @@ static unsigned int zswap_max_pool_percent = 20;
 module_param_named(max_pool_percent,
 			zswap_max_pool_percent, uint, 0644);
 
+/* Writeback/writethrough mode (fixed at boot for now) */
+static bool zswap_writethrough;
+module_param_named(writethrough, zswap_writethrough, bool, 0444);
+
 /*********************************
 * compression functions
 **********************************/
@@ -629,6 +635,48 @@ end:
 }
 
 /*********************************
+* evict code
+**********************************/
+
+/*
+ * This evicts pages that have already been written through to swap.
+ */
+static int zswap_evict_entry(struct zbud_pool *pool, unsigned long handle)
+{
+	struct zswap_header *zhdr;
+	swp_entry_t swpentry;
+	struct zswap_tree *tree;
+	pgoff_t offset;
+	struct zswap_entry *entry;
+
+	/* extract swpentry from data */
+	zhdr = zbud_map(pool, handle);
+	swpentry = zhdr->swpentry; /* here */
+	zbud_unmap(pool, handle);
+	tree = zswap_trees[swp_type(swpentry)];
+	offset = swp_offset(swpentry);
+	BUG_ON(pool != tree->pool);
+
+	/* find and ref zswap entry */
+	spin_lock(&tree->lock);
+	entry = zswap_rb_search(&tree->rbroot, offset);
+	if (!entry) {
+		/* entry was invalidated */
+		spin_unlock(&tree->lock);
+		return 0;
+	}
+
+	zswap_evicted_pages++;
+
+	zswap_rb_erase(&tree->rbroot, entry);
+	zswap_entry_put(tree, entry);
+
+	spin_unlock(&tree->lock);
+
+	return 0;
+}
+
+/*********************************
 * frontswap hooks
 **********************************/
 /* attempts to compress and store an single page */
@@ -744,7 +792,7 @@ static int zswap_frontswap_load(unsigned type, pgoff_t offset,
 	spin_lock(&tree->lock);
 	entry = zswap_entry_find_get(&tree->rbroot, offset);
 	if (!entry) {
-		/* entry was written back */
+		/* entry was written back or evicted */
 		spin_unlock(&tree->lock);
 		return -1;
 	}
@@ -778,7 +826,7 @@ static void zswap_frontswap_invalidate_page(unsigned type, pgoff_t offset)
 	spin_lock(&tree->lock);
 	entry = zswap_rb_search(&tree->rbroot, offset);
 	if (!entry) {
-		/* entry was written back */
+		/* entry was written back or evicted */
 		spin_unlock(&tree->lock);
 		return;
 	}
@@ -813,18 +861,26 @@ static void zswap_frontswap_invalidate_area(unsigned type)
 	zswap_trees[type] = NULL;
 }
 
-static struct zbud_ops zswap_zbud_ops = {
+static struct zbud_ops zswap_zbud_writeback_ops = {
 	.evict = zswap_writeback_entry
 };
+static struct zbud_ops zswap_zbud_writethrough_ops = {
+	.evict = zswap_evict_entry
+};
 
 static void zswap_frontswap_init(unsigned type)
 {
 	struct zswap_tree *tree;
+	struct zbud_ops *ops;
 
 	tree = kzalloc(sizeof(struct zswap_tree), GFP_KERNEL);
 	if (!tree)
 		goto err;
-	tree->pool = zbud_create_pool(GFP_KERNEL, &zswap_zbud_ops);
+	if (zswap_writethrough)
+		ops = &zswap_zbud_writethrough_ops;
+	else
+		ops = &zswap_zbud_writeback_ops;
+	tree->pool = zbud_create_pool(GFP_KERNEL, ops);
 	if (!tree->pool)
 		goto freetree;
 	tree->rbroot = RB_ROOT;
@@ -875,6 +931,8 @@ static int __init zswap_debugfs_init(void)
 			zswap_debugfs_root, &zswap_reject_compress_poor);
 	debugfs_create_u64("written_back_pages", S_IRUGO,
 			zswap_debugfs_root, &zswap_written_back_pages);
+	debugfs_create_u64("evicted_pages", S_IRUGO,
+			zswap_debugfs_root, &zswap_evicted_pages);
 	debugfs_create_u64("duplicate_entry", S_IRUGO,
 			zswap_debugfs_root, &zswap_duplicate_entry);
 	debugfs_create_u64("pool_pages", S_IRUGO,
@@ -919,6 +977,8 @@ static int __init init_zswap(void)
 		pr_err("per-cpu initialization failed\n");
 		goto pcpufail;
 	}
+	if (zswap_writethrough)
+		frontswap_writethrough(true);
 	frontswap_register_ops(&zswap_frontswap_ops);
 	if (zswap_debugfs_init())
 		pr_warn("debugfs initialization failed\n");
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
