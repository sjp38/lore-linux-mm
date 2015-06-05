Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 11BCD900016
	for <linux-mm@kvack.org>; Fri,  5 Jun 2015 08:05:05 -0400 (EDT)
Received: by pdjn11 with SMTP id n11so14452358pdj.0
        for <linux-mm@kvack.org>; Fri, 05 Jun 2015 05:05:04 -0700 (PDT)
Received: from mail-pa0-x234.google.com (mail-pa0-x234.google.com. [2607:f8b0:400e:c03::234])
        by mx.google.com with ESMTPS id ey4si10630819pdb.172.2015.06.05.05.05.04
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 Jun 2015 05:05:04 -0700 (PDT)
Received: by pabqy3 with SMTP id qy3so49376578pab.3
        for <linux-mm@kvack.org>; Fri, 05 Jun 2015 05:05:04 -0700 (PDT)
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: [RFC][PATCHv2 5/8] zsmalloc: introduce zs_can_compact() function
Date: Fri,  5 Jun 2015 21:03:55 +0900
Message-Id: <1433505838-23058-6-git-send-email-sergey.senozhatsky@gmail.com>
In-Reply-To: <1433505838-23058-1-git-send-email-sergey.senozhatsky@gmail.com>
References: <1433505838-23058-1-git-send-email-sergey.senozhatsky@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

This function checks if class compaction will free any pages.
Rephrasing -- do we have enough unused objects to form at least
one ZS_EMPTY page and free it. It aborts compaction if class
compaction will not result in any (further) savings.

EXAMPLE (this debug output is not part of this patch set):

-- class size
-- number of allocated objects
-- number of used objects,
-- estimated number of pages that will be freed

[..]
 class-3072 objs:24652 inuse:24628 maxobjs-per-page:4  pages-tofree:6
 class-3072 objs:24648 inuse:24628 maxobjs-per-page:4  pages-tofree:5
 class-3072 objs:24644 inuse:24628 maxobjs-per-page:4  pages-tofree:4
 class-3072 objs:24640 inuse:24628 maxobjs-per-page:4  pages-tofree:3
 class-3072 objs:24636 inuse:24628 maxobjs-per-page:4  pages-tofree:2
 class-3072 objs:24632 inuse:24628 maxobjs-per-page:4  pages-tofree:1
 class-2720 objs:17970 inuse:17966 maxobjs-per-page:3  pages-tofree:1
 class-2720 objs:17967 inuse:17966 maxobjs-per-page:3  pages-tofree:0
 class-2720: Compaction is useless
 class-2448 objs:7680  inuse:7674  maxobjs-per-page:5  pages-tofree:1
 class-2336 objs:13510 inuse:13500 maxobjs-per-page:7  pages-tofree:1
 class-2336 objs:13503 inuse:13500 maxobjs-per-page:7  pages-tofree:0
 class-2336: Compaction is useless
 class-1808 objs:1161  inuse:1154  maxobjs-per-page:9  pages-tofree:0
 class-1808: Compaction is useless
 class-1744 objs:2135  inuse:2131  maxobjs-per-page:7  pages-tofree:0
 class-1744: Compaction is useless
 class-1536 objs:1328  inuse:1323  maxobjs-per-page:8  pages-tofree:0
 class-1536: Compaction is useless
 class-1488 objs:8855  inuse:8847  maxobjs-per-page:11 pages-tofree:0
 class-1488: Compaction is useless
 class-1360 objs:14880 inuse:14878 maxobjs-per-page:3  pages-tofree:0
 class-1360: Compaction is useless
 class-1248 objs:3588  inuse:3577  maxobjs-per-page:13 pages-tofree:0
 class-1248: Compaction is useless
 class-1216 objs:3380  inuse:3372  maxobjs-per-page:10 pages-tofree:0
 class-1216: Compaction is useless
 class-1168 objs:3416  inuse:3401  maxobjs-per-page:7  pages-tofree:2
 class-1168 objs:3409  inuse:3401  maxobjs-per-page:7  pages-tofree:1
 class-1104 objs:605   inuse:599   maxobjs-per-page:11 pages-tofree:0
 class-1104: Compaction is useless
[..]

Every "Compaction is useless" indicates that we saved some CPU cycles.

class-1104 has
	605	object allocated
	599	objects used
	11	objects per-page

Even if we have a ALMOST_EMPTY zspage, we still don't have enough room to
migrate all of its objects and free this zspage; so compaction will not
make a lot of sense here, it's better to just leave it as is.

Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
---
 mm/zsmalloc.c | 25 +++++++++++++++++++++++++
 1 file changed, 25 insertions(+)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index 0453347..5d8f1d4 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -1682,6 +1682,28 @@ static struct page *isolate_source_page(struct size_class *class)
 	return page;
 }
 
+/*
+ * Make sure that we actually can compact this class,
+ * IOW if migration will empty at least one page.
+ *
+ * Should be called under class->lock
+ */
+static unsigned long zs_can_compact(struct size_class *class)
+{
+	/*
+	 * Calculate how many unused allocated objects we
+	 * have and see if we can free any zspages. Otherwise,
+	 * compaction can just move objects back and forth w/o
+	 * any memory gain.
+	 */
+	unsigned long obj_wasted = zs_stat_get(class, OBJ_ALLOCATED) -
+		zs_stat_get(class, OBJ_USED);
+
+	obj_wasted /= get_maxobj_per_zspage(class->size,
+			class->pages_per_zspage);
+	return obj_wasted;
+}
+
 static unsigned long __zs_compact(struct zs_pool *pool,
 				struct size_class *class)
 {
@@ -1695,6 +1717,9 @@ static unsigned long __zs_compact(struct zs_pool *pool,
 
 		BUG_ON(!is_first_page(src_page));
 
+		if (!zs_can_compact(class))
+			break;
+
 		cc.index = 0;
 		cc.s_page = src_page;
 
-- 
2.4.2.387.gf86f31a

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
