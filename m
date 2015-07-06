Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 526C52802A5
	for <linux-mm@kvack.org>; Mon,  6 Jul 2015 08:19:17 -0400 (EDT)
Received: by pdbdz6 with SMTP id dz6so10050169pdb.0
        for <linux-mm@kvack.org>; Mon, 06 Jul 2015 05:19:17 -0700 (PDT)
Received: from mail-pd0-x231.google.com (mail-pd0-x231.google.com. [2607:f8b0:400e:c02::231])
        by mx.google.com with ESMTPS id ig4si28751387pbb.82.2015.07.06.05.19.16
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Jul 2015 05:19:16 -0700 (PDT)
Received: by pdbep18 with SMTP id ep18so105291593pdb.1
        for <linux-mm@kvack.org>; Mon, 06 Jul 2015 05:19:16 -0700 (PDT)
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: [PATCH v5 6/7] zsmalloc: account the number of compacted pages
Date: Mon,  6 Jul 2015 21:17:49 +0900
Message-Id: <1436185070-1940-7-git-send-email-sergey.senozhatsky@gmail.com>
In-Reply-To: <1436185070-1940-1-git-send-email-sergey.senozhatsky@gmail.com>
References: <1436185070-1940-1-git-send-email-sergey.senozhatsky@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey@kvack.org, "Senozhatsky <sergey.senozhatsky.work"@gmail.com, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

Compaction returns back to zram the number of migrated objects,
which is quite uninformative -- we have objects of different
sizes so user space cannot obtain any valuable data from that
number. Change compaction to operate in terms of pages and
return back to compaction issuer the number of pages that
were freed during compaction. So from now on `num_compacted'
column in zram<id>/mm_stat represents more meaningful value:
the number of freed (compacted) pages.

Return first_page's fullness_group from putback_zspage(),
so we now for sure know that putback_zspage() has issued
free_zspage() and we must update compaction stats.

Update documentation.

Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
---
 Documentation/blockdev/zram.txt |  3 ++-
 mm/zsmalloc.c                   | 27 +++++++++++++++++----------
 2 files changed, 19 insertions(+), 11 deletions(-)

diff --git a/Documentation/blockdev/zram.txt b/Documentation/blockdev/zram.txt
index c4de576..71f4744 100644
--- a/Documentation/blockdev/zram.txt
+++ b/Documentation/blockdev/zram.txt
@@ -144,7 +144,8 @@ mem_used_max      RW    the maximum amount memory zram have consumed to
                         store compressed data
 mem_limit         RW    the maximum amount of memory ZRAM can use to store
                         the compressed data
-num_migrated      RO    the number of objects migrated migrated by compaction
+num_migrated      RO    the number of pages freed during compaction
+                        (available only via zram<id>/mm_stat node)
 compact           WO    trigger memory compaction
 
 WARNING
diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index e0f508a..a761733 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -245,7 +245,7 @@ struct zs_pool {
 	/* Allocation flags used when growing pool */
 	gfp_t			flags;
 	atomic_long_t		pages_allocated;
-	/* How many objects were migrated */
+	/* How many pages were migrated (freed) */
 	unsigned long		num_migrated;
 
 #ifdef CONFIG_ZSMALLOC_STAT
@@ -1596,8 +1596,6 @@ struct zs_compact_control {
 	 /* Starting object index within @s_page which used for live object
 	  * in the subpage. */
 	int index;
-	/* How many of objects were migrated */
-	int nr_migrated;
 };
 
 static int migrate_zspage(struct zs_pool *pool, struct size_class *class,
@@ -1634,7 +1632,6 @@ static int migrate_zspage(struct zs_pool *pool, struct size_class *class,
 		record_obj(handle, free_obj);
 		unpin_tag(handle);
 		obj_free(pool, class, used_obj);
-		cc->nr_migrated++;
 	}
 
 	/* Remember last position in this iteration */
@@ -1660,8 +1657,17 @@ static struct page *isolate_target_page(struct size_class *class)
 	return page;
 }
 
-static void putback_zspage(struct zs_pool *pool, struct size_class *class,
-				struct page *first_page)
+/*
+ * putback_zspage - add @first_page into right class's fullness list
+ * @pool: target pool
+ * @class: destination class
+ * @first_page: target page
+ *
+ * Return @fist_page's fullness_group
+ */
+static enum fullness_group putback_zspage(struct zs_pool *pool,
+			struct size_class *class,
+			struct page *first_page)
 {
 	enum fullness_group fullness;
 
@@ -1679,6 +1685,8 @@ static void putback_zspage(struct zs_pool *pool, struct size_class *class,
 
 		free_zspage(first_page);
 	}
+
+	return fullness;
 }
 
 static struct page *isolate_source_page(struct size_class *class)
@@ -1720,7 +1728,6 @@ static void __zs_compact(struct zs_pool *pool, struct size_class *class)
 	struct page *src_page;
 	struct page *dst_page = NULL;
 
-	cc.nr_migrated = 0;
 	spin_lock(&class->lock);
 	while ((src_page = isolate_source_page(class))) {
 
@@ -1749,7 +1756,9 @@ static void __zs_compact(struct zs_pool *pool, struct size_class *class)
 			break;
 
 		putback_zspage(pool, class, dst_page);
-		putback_zspage(pool, class, src_page);
+		if (putback_zspage(pool, class, src_page) == ZS_EMPTY)
+			pool->num_migrated +=
+				get_pages_per_zspage(class->size);
 		spin_unlock(&class->lock);
 		cond_resched();
 		spin_lock(&class->lock);
@@ -1758,8 +1767,6 @@ static void __zs_compact(struct zs_pool *pool, struct size_class *class)
 	if (src_page)
 		putback_zspage(pool, class, src_page);
 
-	pool->num_migrated += cc.nr_migrated;
-
 	spin_unlock(&class->lock);
 }
 
-- 
2.5.0.rc0.3.g912bd49

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
