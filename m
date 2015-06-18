Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 0C0BB6B0078
	for <linux-mm@kvack.org>; Thu, 18 Jun 2015 08:49:16 -0400 (EDT)
Received: by pdjn11 with SMTP id n11so66236232pdj.0
        for <linux-mm@kvack.org>; Thu, 18 Jun 2015 05:49:15 -0700 (PDT)
Received: from mail-pd0-x229.google.com (mail-pd0-x229.google.com. [2607:f8b0:400e:c02::229])
        by mx.google.com with ESMTPS id fj8si11247512pdb.93.2015.06.18.05.49.15
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Jun 2015 05:49:15 -0700 (PDT)
Received: by pdjn11 with SMTP id n11so66236039pdj.0
        for <linux-mm@kvack.org>; Thu, 18 Jun 2015 05:49:14 -0700 (PDT)
Date: Thu, 18 Jun 2015 21:48:31 +0900
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: Re: [RFC][PATCHv3 2/7] zsmalloc: partial page ordering within a
 fullness_list
Message-ID: <20150618124831.GB2519@swordfish>
References: <1434628004-11144-1-git-send-email-sergey.senozhatsky@gmail.com>
 <1434628004-11144-3-git-send-email-sergey.senozhatsky@gmail.com>
 <20150618121314.GA518@swordfish>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150618121314.GA518@swordfish>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On (06/18/15 21:13), Sergey Senozhatsky wrote:
> I used a modified zsmalloc debug stats (to also account and report ZS_FULL
> zspages).

just in case. account and report per-class ZS_FULL numbers.

----

 mm/zsmalloc.c | 29 ++++++++++++++++++++---------
 1 file changed, 20 insertions(+), 9 deletions(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index e0d28a2..97ca25d 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -166,6 +166,7 @@ enum zs_stat_type {
 	OBJ_USED,
 	CLASS_ALMOST_FULL,
 	CLASS_ALMOST_EMPTY,
+	CLASS_FULL,
 	NR_ZS_STAT_TYPE,
 };
 
@@ -483,13 +484,13 @@ static int zs_stats_size_show(struct seq_file *s, void *v)
 	struct zs_pool *pool = s->private;
 	struct size_class *class;
 	int objs_per_zspage;
-	unsigned long class_almost_full, class_almost_empty;
+	unsigned long class_almost_full, class_full, class_almost_empty;
 	unsigned long obj_allocated, obj_used, pages_used;
-	unsigned long total_class_almost_full = 0, total_class_almost_empty = 0;
+	unsigned long total_class_almost_full = 0, total_class_full = 0, total_class_almost_empty = 0;
 	unsigned long total_objs = 0, total_used_objs = 0, total_pages = 0;
 
-	seq_printf(s, " %5s %5s %11s %12s %13s %10s %10s %16s\n",
-			"class", "size", "almost_full", "almost_empty",
+	seq_printf(s, " %5s %5s %11s %12s %12s %13s %10s %10s %16s\n",
+			"class", "size", "almost_full", "full", "almost_empty",
 			"obj_allocated", "obj_used", "pages_used",
 			"pages_per_zspage");
 
@@ -501,6 +502,7 @@ static int zs_stats_size_show(struct seq_file *s, void *v)
 
 		spin_lock(&class->lock);
 		class_almost_full = zs_stat_get(class, CLASS_ALMOST_FULL);
+		class_full = zs_stat_get(class, CLASS_FULL);
 		class_almost_empty = zs_stat_get(class, CLASS_ALMOST_EMPTY);
 		obj_allocated = zs_stat_get(class, OBJ_ALLOCATED);
 		obj_used = zs_stat_get(class, OBJ_USED);
@@ -511,12 +513,13 @@ static int zs_stats_size_show(struct seq_file *s, void *v)
 		pages_used = obj_allocated / objs_per_zspage *
 				class->pages_per_zspage;
 
-		seq_printf(s, " %5u %5u %11lu %12lu %13lu %10lu %10lu %16d\n",
-			i, class->size, class_almost_full, class_almost_empty,
+		seq_printf(s, " %5u %5u %11lu %12lu %12lu %13lu %10lu %10lu %16d\n",
+			i, class->size, class_almost_full, class_full, class_almost_empty,
 			obj_allocated, obj_used, pages_used,
 			class->pages_per_zspage);
 
 		total_class_almost_full += class_almost_full;
+		total_class_full += class_full;
 		total_class_almost_empty += class_almost_empty;
 		total_objs += obj_allocated;
 		total_used_objs += obj_used;
@@ -524,8 +527,9 @@ static int zs_stats_size_show(struct seq_file *s, void *v)
 	}
 
 	seq_puts(s, "\n");
-	seq_printf(s, " %5s %5s %11lu %12lu %13lu %10lu %10lu\n",
+	seq_printf(s, " %5s %5s %11lu %12lu %12lu %13lu %10lu %10lu\n",
 			"Total", "", total_class_almost_full,
+			total_class_full,
 			total_class_almost_empty, total_objs,
 			total_used_objs, total_pages);
 
@@ -652,7 +656,10 @@ static void insert_zspage(struct page *page, struct size_class *class,
 	}
 
 	*head = page;
-	zs_stat_inc(class, fullness == ZS_ALMOST_EMPTY ?
+	if (fullness == ZS_FULL)
+		zs_stat_inc(class, CLASS_FULL, 1);
+	else
+		zs_stat_inc(class, fullness == ZS_ALMOST_EMPTY ?
 			CLASS_ALMOST_EMPTY : CLASS_ALMOST_FULL, 1);
 }
 
@@ -679,7 +686,10 @@ static void remove_zspage(struct page *page, struct size_class *class,
 					struct page, lru);
 
 	list_del_init(&page->lru);
-	zs_stat_dec(class, fullness == ZS_ALMOST_EMPTY ?
+	if (fullness == ZS_FULL)
+		zs_stat_dec(class, CLASS_FULL, 1);
+	else
+		zs_stat_dec(class, fullness == ZS_ALMOST_EMPTY ?
 			CLASS_ALMOST_EMPTY : CLASS_ALMOST_FULL, 1);
 }
 
@@ -1410,6 +1420,7 @@ unsigned long zs_malloc(struct zs_pool *pool, size_t size)
 		spin_lock(&class->lock);
 		zs_stat_inc(class, OBJ_ALLOCATED, get_maxobj_per_zspage(
 				class->size, class->pages_per_zspage));
+		zs_stat_inc(class, CLASS_FULL, 1);
 	}
 
 	obj = obj_malloc(first_page, class, handle);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
