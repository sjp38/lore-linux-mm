Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id B3CE76B0032
	for <linux-mm@kvack.org>; Tue, 30 Jun 2015 08:33:14 -0400 (EDT)
Received: by pdbep18 with SMTP id ep18so5650359pdb.1
        for <linux-mm@kvack.org>; Tue, 30 Jun 2015 05:33:14 -0700 (PDT)
Received: from mail-pd0-x22e.google.com (mail-pd0-x22e.google.com. [2607:f8b0:400e:c02::22e])
        by mx.google.com with ESMTPS id ff5si69951131pac.199.2015.06.30.05.33.13
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Jun 2015 05:33:13 -0700 (PDT)
Received: by pdjd13 with SMTP id d13so5692817pdj.0
        for <linux-mm@kvack.org>; Tue, 30 Jun 2015 05:33:13 -0700 (PDT)
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: [PATCH] zsmalloc: partial page ordering within a fullness_list
Date: Tue, 30 Jun 2015 21:32:22 +0900
Message-Id: <1435667542-8142-1-git-send-email-sergey.senozhatsky@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

We want to see more ZS_FULL pages and less ZS_ALMOST_{FULL, EMPTY}
pages. Put a page with higher ->inuse count first within its
->fullness_list, which will give us better chances to fill up this
page with new objects (find_get_zspage() return ->fullness_list head
for new object allocation), so some zspages will become
ZS_ALMOST_FULL/ZS_FULL quicker.

It performs a trivial and cheap ->inuse compare which does not
slow down zsmalloc and in the worst case keeps the list pages in
no particular order.

A more expensive solution could sort fullness_list by ->inuse count.

[Minchan Kim: code adjustments]
Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
---
 mm/zsmalloc.c | 19 ++++++++++++++-----
 1 file changed, 14 insertions(+), 5 deletions(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index 0a7f81a..3538b8c 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -658,13 +658,22 @@ static void insert_zspage(struct page *page, struct size_class *class,
 	if (fullness >= _ZS_NR_FULLNESS_GROUPS)
 		return;
 
-	head = &class->fullness_list[fullness];
-	if (*head)
-		list_add_tail(&page->lru, &(*head)->lru);
-
-	*head = page;
 	zs_stat_inc(class, fullness == ZS_ALMOST_EMPTY ?
 			CLASS_ALMOST_EMPTY : CLASS_ALMOST_FULL, 1);
+
+	head = &class->fullness_list[fullness];
+	if (!*head) {
+		*head = page;
+		return;
+	}
+
+	/*
+	 * We want to see more ZS_FULL pages and less almost
+	 * empty/full. Put pages with higher ->inuse first.
+	 */
+	list_add_tail(&page->lru, &(*head)->lru);
+	if (page->inuse >= (*head)->inuse)
+		*head = page;
 }
 
 /*
-- 
2.5.0.rc0.3.g912bd49

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
