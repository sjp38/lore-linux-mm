Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 586656B0081
	for <linux-mm@kvack.org>; Fri, 29 May 2015 11:06:15 -0400 (EDT)
Received: by pacux9 with SMTP id ux9so20946844pac.3
        for <linux-mm@kvack.org>; Fri, 29 May 2015 08:06:15 -0700 (PDT)
Received: from mail-pd0-x229.google.com (mail-pd0-x229.google.com. [2607:f8b0:400e:c02::229])
        by mx.google.com with ESMTPS id x2si8798204pas.140.2015.05.29.08.06.14
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 May 2015 08:06:14 -0700 (PDT)
Received: by pdbki1 with SMTP id ki1so55643942pdb.1
        for <linux-mm@kvack.org>; Fri, 29 May 2015 08:06:14 -0700 (PDT)
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: [RFC][PATCH 03/10] zsmalloc: introduce zs_can_compact() function
Date: Sat, 30 May 2015 00:05:21 +0900
Message-Id: <1432911928-14654-4-git-send-email-sergey.senozhatsky@gmail.com>
In-Reply-To: <1432911928-14654-1-git-send-email-sergey.senozhatsky@gmail.com>
References: <1432911928-14654-1-git-send-email-sergey.senozhatsky@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

this function checks if class compaction will free any pages.
rephrasing, do we have enough unused objects to form at least one
ZS_EMPTY page and free it. it aborts compaction if class compaction
will not result into any (further) savings.

EXAMPLE (this debug output is not part of this patch set):

-- class size
-- number of allocated objects
-- number of used objects,
-- estimated number of pages that will be freed

[..]
[ 3303.108960] class-3072 objs:24652 inuse:24628 objs-per-page:4 pages-tofree:6
[ 3303.108965] class-3072 objs:24648 inuse:24628 objs-per-page:4 pages-tofree:5
[ 3303.108970] class-3072 objs:24644 inuse:24628 objs-per-page:4 pages-tofree:4
[ 3303.108973] class-3072 objs:24640 inuse:24628 objs-per-page:4 pages-tofree:3
[ 3303.108978] class-3072 objs:24636 inuse:24628 objs-per-page:4 pages-tofree:2
[ 3303.108982] class-3072 objs:24632 inuse:24628 objs-per-page:4 pages-tofree:1
[ 3303.108993] class-2720 objs:17970 inuse:17966 objs-per-page:3 pages-tofree:1
[ 3303.108997] class-2720 objs:17967 inuse:17966 objs-per-page:3 pages-tofree:0
[ 3303.108998] class-2720: Compaction is useless
[ 3303.109000] class-2448 objs:7680 inuse:7674 objs-per-page:5 pages-tofree:1
[ 3303.109005] class-2336 objs:13510 inuse:13500 objs-per-page:7 pages-tofree:1
[ 3303.109010] class-2336 objs:13503 inuse:13500 objs-per-page:7 pages-tofree:0
[ 3303.109011] class-2336: Compaction is useless
[ 3303.109013] class-1808 objs:1161 inuse:1154 objs-per-page:9 pages-tofree:0
[ 3303.109014] class-1808: Compaction is useless
[ 3303.109016] class-1744 objs:2135 inuse:2131 objs-per-page:7 pages-tofree:0
[ 3303.109017] class-1744: Compaction is useless
[ 3303.109019] class-1536 objs:1328 inuse:1323 objs-per-page:8 pages-tofree:0
[ 3303.109020] class-1536: Compaction is useless
[ 3303.109022] class-1488 objs:8855 inuse:8847 objs-per-page:11 pages-tofree:0
[ 3303.109023] class-1488: Compaction is useless
[ 3303.109025] class-1360 objs:14880 inuse:14878 objs-per-page:3 pages-tofree:0
[ 3303.109026] class-1360: Compaction is useless
[ 3303.109028] class-1248 objs:3588 inuse:3577 objs-per-page:13 pages-tofree:0
[ 3303.109029] class-1248: Compaction is useless
[ 3303.109031] class-1216 objs:3380 inuse:3372 objs-per-page:10 pages-tofree:0
[ 3303.109032] class-1216: Compaction is useless
[ 3303.109033] class-1168 objs:3416 inuse:3401 objs-per-page:7 pages-tofree:2
[ 3303.109037] class-1168 objs:3409 inuse:3401 objs-per-page:7 pages-tofree:1
[ 3303.109042] class-1104 objs:605 inuse:599 objs-per-page:11 pages-tofree:0
[ 3303.109043] class-1104: Compaction is useless
[..]

every "Compaction is useless" indicates that we saved some CPU cycles.

for example, class-1104 has

	605	object allocated
	599	objects used
	11	objects per-page

even if we have ALMOST_EMPTY page, we still don't have enough room to move
all of its objects and free this page; so compaction will not make a lot of
sense here, it's better to just leave it as is.

Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
---
 mm/zsmalloc.c | 25 +++++++++++++++++++++++++
 1 file changed, 25 insertions(+)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index 778b8db..9ef6f15 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -1673,6 +1673,28 @@ static struct page *isolate_source_page(struct size_class *class)
 	return page;
 }
 
+/*
+ * Make sure that we actually can compact this class,
+ * IOW if migration will empty at least one page.
+ *
+ * should be called under class->lock
+ */
+static bool zs_can_compact(struct size_class *class)
+{
+	/*
+	 * calculate how many unused allocated objects we
+	 * have and see if we can free any zspages. otherwise,
+	 * compaction can just move objects back and forth w/o
+	 * any memory gain.
+	 */
+	unsigned long ret = zs_stat_get(class, OBJ_ALLOCATED) -
+		zs_stat_get(class, OBJ_USED);
+
+	ret /= get_maxobj_per_zspage(class->size,
+			class->pages_per_zspage);
+	return ret > 0;
+}
+
 static unsigned long __zs_compact(struct zs_pool *pool,
 				struct size_class *class)
 {
@@ -1686,6 +1708,9 @@ static unsigned long __zs_compact(struct zs_pool *pool,
 
 		BUG_ON(!is_first_page(src_page));
 
+		if (!zs_can_compact(class))
+			break;
+
 		cc.index = 0;
 		cc.s_page = src_page;
 
-- 
2.4.2.337.gfae46aa

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
