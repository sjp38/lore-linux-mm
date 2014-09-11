Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f178.google.com (mail-ig0-f178.google.com [209.85.213.178])
	by kanga.kvack.org (Postfix) with ESMTP id 7D4326B003D
	for <linux-mm@kvack.org>; Thu, 11 Sep 2014 16:55:00 -0400 (EDT)
Received: by mail-ig0-f178.google.com with SMTP id a13so1736533igq.17
        for <linux-mm@kvack.org>; Thu, 11 Sep 2014 13:55:00 -0700 (PDT)
Received: from mail-ig0-x231.google.com (mail-ig0-x231.google.com [2607:f8b0:4001:c05::231])
        by mx.google.com with ESMTPS id y2si6199047igl.47.2014.09.11.13.54.59
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 11 Sep 2014 13:54:59 -0700 (PDT)
Received: by mail-ig0-f177.google.com with SMTP id uq10so5713293igb.10
        for <linux-mm@kvack.org>; Thu, 11 Sep 2014 13:54:59 -0700 (PDT)
From: Dan Streetman <ddstreet@ieee.org>
Subject: [PATCH 05/10] zsmalloc: add atomic index to find zspage to reclaim
Date: Thu, 11 Sep 2014 16:53:56 -0400
Message-Id: <1410468841-320-6-git-send-email-ddstreet@ieee.org>
In-Reply-To: <1410468841-320-1-git-send-email-ddstreet@ieee.org>
References: <1410468841-320-1-git-send-email-ddstreet@ieee.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Nitin Gupta <ngupta@vflare.org>, Seth Jennings <sjennings@variantweb.net>, Andrew Morton <akpm@linux-foundation.org>, Dan Streetman <ddstreet@ieee.org>

Add an atomic index that allows multiple threads to concurrently and
sequentially iterate through the zspages in all classes and fullness
groups.  Add a function find_next_lru_class_fg() to find the next class
fullness group to check for a zspage.  Add a function find_lru_zspage()
which calls find_next_lru_class_fg() until a fullness group with an
available zspage is found.  This is required to implement zsmalloc pool
shrinking, which needs to be able to find a zspage to reclaim.

Since zsmalloc categorizes its zspages in arrays of fullness groups, which
are themselves inside arrays of classes, there is no (simple) way to
determine the LRU order of all a zsmalloc pool's zspages.  But to implement
shrinking, there must be some way to select the zspage to reclaim.  This
can't use a simple iteration through all classes, since any failure to
reclaim a zspage would result in any following reclaims to attempt to
reclaim the same zspage, which would likely result in repeated failures
to shrink the pool.

Signed-off-by: Dan Streetman <ddstreet@ieee.org>
Cc: Minchan Kim <minchan@kernel.org>
---
 mm/zsmalloc.c | 68 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 68 insertions(+)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index cff8935..a2e417b 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -242,6 +242,16 @@ struct mapping_area {
 	enum zs_mapmode vm_mm; /* mapping mode */
 };
 
+/* atomic counter indicating which class/fg to reclaim from */
+static atomic_t lru_class_fg;
+/* specific order of fg we want to reclaim from */
+static enum fullness_group lru_fg[] = {
+	ZS_ALMOST_EMPTY,
+	ZS_ALMOST_FULL,
+	ZS_FULL
+};
+#define _ZS_NR_LRU_CLASS_FG (ZS_SIZE_CLASSES * ARRAY_SIZE(lru_fg))
+
 /* zpool driver */
 
 #ifdef CONFIG_ZPOOL
@@ -752,6 +762,64 @@ static struct page *find_available_zspage(struct size_class *class)
 	return page;
 }
 
+/* this simply iterates atomically through all classes,
+ * using a specific fullness group.  At the end, it starts
+ * over using the next fullness group, and so on.  The
+ * fullness groups are used in a specific order, from
+ * least to most full.
+ */
+static void find_next_lru_class_fg(struct zs_pool *pool,
+			struct size_class **class, enum fullness_group *fg)
+{
+	int i = atomic_inc_return(&lru_class_fg);
+
+	if (i >= _ZS_NR_LRU_CLASS_FG) {
+		int orig = i;
+
+		i %= _ZS_NR_LRU_CLASS_FG;
+		/* only need to try once, since if we don't
+		 * succeed whoever changed it will also try
+		 * and eventually someone will reset it
+		 */
+		atomic_cmpxchg(&lru_class_fg, orig, i);
+	}
+	*class = &pool->size_class[i % ZS_SIZE_CLASSES];
+	*fg = lru_fg[i / ZS_SIZE_CLASSES];
+}
+
+/*
+ * This attempts to find the LRU zspage, but that's not really possible
+ * because zspages are not contained in a single LRU list, they're
+ * contained inside fullness groups which are themselves contained
+ * inside classes.  So this simply iterates through the classes and
+ * fullness groups to find the next non-empty fullness group, and
+ * uses the LRU zspage there.
+ *
+ * On success, the zspage is returned with its class locked.
+ * On failure, NULL is returned.
+ */
+static struct page *find_lru_zspage(struct zs_pool *pool)
+{
+	struct size_class *class;
+	struct page *page;
+	enum fullness_group fg;
+	int tries = 0;
+
+	while (tries++ < _ZS_NR_LRU_CLASS_FG) {
+		find_next_lru_class_fg(pool, &class, &fg);
+
+		spin_lock(&class->lock);
+
+		page = class->fullness_list[fg];
+		if (page)
+			return list_prev_entry(page, lru);
+
+		spin_unlock(&class->lock);
+	}
+
+	return NULL;
+}
+
 #ifdef CONFIG_PGTABLE_MAPPING
 static inline int __zs_cpu_up(struct mapping_area *area)
 {
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
