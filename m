Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 0B4F26B0075
	for <linux-mm@kvack.org>; Tue, 30 Jun 2015 08:37:02 -0400 (EDT)
Received: by pabvl15 with SMTP id vl15so5102219pab.1
        for <linux-mm@kvack.org>; Tue, 30 Jun 2015 05:37:01 -0700 (PDT)
Received: from mail-pa0-x234.google.com (mail-pa0-x234.google.com. [2607:f8b0:400e:c03::234])
        by mx.google.com with ESMTPS id fj8si70067209pdb.93.2015.06.30.05.37.00
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Jun 2015 05:37:01 -0700 (PDT)
Received: by paceq1 with SMTP id eq1so5029553pac.3
        for <linux-mm@kvack.org>; Tue, 30 Jun 2015 05:37:00 -0700 (PDT)
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: [RFC][PATCHv4 3/7] zsmalloc: introduce zs_can_compact() function
Date: Tue, 30 Jun 2015 21:35:54 +0900
Message-Id: <1435667758-14075-4-git-send-email-sergey.senozhatsky@gmail.com>
In-Reply-To: <1435667758-14075-1-git-send-email-sergey.senozhatsky@gmail.com>
References: <1435667758-14075-1-git-send-email-sergey.senozhatsky@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

This function checks if class compaction will free any pages.
Rephrasing -- do we have enough unused objects to form at least
one ZS_EMPTY page and free it. It aborts compaction if class
compaction will not result in any (further) savings.

EXAMPLE (this debug output is not part of this patch set):

-- class size
-- number of allocated objects
-- number of used objects
-- max objects per zspage
-- pages per zspage
-- estimated number of pages that will be freed

[..]
class-512 objs:544 inuse:540 maxobj-per-zspage:8  pages-per-zspage:1 zspages-to-free:0
 ... class-512 compaction is useless. break
class-496 objs:660 inuse:570 maxobj-per-zspage:33 pages-per-zspage:4 zspages-to-free:2
class-496 objs:627 inuse:570 maxobj-per-zspage:33 pages-per-zspage:4 zspages-to-free:1
class-496 objs:594 inuse:570 maxobj-per-zspage:33 pages-per-zspage:4 zspages-to-free:0
 ... class-496 compaction is useless. break
class-448 objs:657 inuse:617 maxobj-per-zspage:9  pages-per-zspage:1 zspages-to-free:4
class-448 objs:648 inuse:617 maxobj-per-zspage:9  pages-per-zspage:1 zspages-to-free:3
class-448 objs:639 inuse:617 maxobj-per-zspage:9  pages-per-zspage:1 zspages-to-free:2
class-448 objs:630 inuse:617 maxobj-per-zspage:9  pages-per-zspage:1 zspages-to-free:1
class-448 objs:621 inuse:617 maxobj-per-zspage:9  pages-per-zspage:1 zspages-to-free:0
 ... class-448 compaction is useless. break
class-432 objs:728 inuse:685 maxobj-per-zspage:28 pages-per-zspage:3 zspages-to-free:1
class-432 objs:700 inuse:685 maxobj-per-zspage:28 pages-per-zspage:3 zspages-to-free:0
 ... class-432 compaction is useless. break
class-416 objs:819 inuse:705 maxobj-per-zspage:39 pages-per-zspage:4 zspages-to-free:2
class-416 objs:780 inuse:705 maxobj-per-zspage:39 pages-per-zspage:4 zspages-to-free:1
class-416 objs:741 inuse:705 maxobj-per-zspage:39 pages-per-zspage:4 zspages-to-free:0
 ... class-416 compaction is useless. break
class-400 objs:690 inuse:674 maxobj-per-zspage:10 pages-per-zspage:1 zspages-to-free:1
class-400 objs:680 inuse:674 maxobj-per-zspage:10 pages-per-zspage:1 zspages-to-free:0
 ... class-400 compaction is useless. break
class-384 objs:736 inuse:709 maxobj-per-zspage:32 pages-per-zspage:3 zspages-to-free:0
 ... class-384 compaction is useless. break
[..]

Every "compaction is useless" indicates that we saved CPU cycles.

class-512 has
	544	object allocated
	540	objects used
	8	objects per-page

Even if we have a ALMOST_EMPTY zspage, we still don't have enough room to
migrate all of its objects and free this zspage; so compaction will not
make a lot of sense, it's better to just leave it as is.

Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
---
 mm/zsmalloc.c | 25 +++++++++++++++++++++++++
 1 file changed, 25 insertions(+)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index 036baa8..b7410c1 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -1685,6 +1685,28 @@ static struct page *isolate_source_page(struct size_class *class)
 	return page;
 }
 
+/*
+ *
+ * Based on the number of unused allocated objects calculate
+ * and return the number of pages that we can free.
+ *
+ * Should be called under class->lock.
+ */
+static unsigned long zs_can_compact(struct size_class *class)
+{
+	unsigned long obj_wasted;
+
+	if (!zs_stat_get(class, CLASS_ALMOST_EMPTY))
+		return 0;
+
+	obj_wasted = zs_stat_get(class, OBJ_ALLOCATED) -
+		zs_stat_get(class, OBJ_USED);
+
+	obj_wasted /= get_maxobj_per_zspage(class->size,
+			class->pages_per_zspage);
+	return obj_wasted * get_pages_per_zspage(class->size);
+}
+
 static unsigned long __zs_compact(struct zs_pool *pool,
 				struct size_class *class)
 {
@@ -1698,6 +1720,9 @@ static unsigned long __zs_compact(struct zs_pool *pool,
 
 		BUG_ON(!is_first_page(src_page));
 
+		if (!zs_can_compact(class))
+			break;
+
 		cc.index = 0;
 		cc.s_page = src_page;
 
-- 
2.5.0.rc0.3.g912bd49

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
