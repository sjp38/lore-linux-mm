Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id B3F0E6B0078
	for <linux-mm@kvack.org>; Thu, 18 Jun 2015 07:47:46 -0400 (EDT)
Received: by pdbki1 with SMTP id ki1so65104706pdb.1
        for <linux-mm@kvack.org>; Thu, 18 Jun 2015 04:47:46 -0700 (PDT)
Received: from mail-pa0-x233.google.com (mail-pa0-x233.google.com. [2607:f8b0:400e:c03::233])
        by mx.google.com with ESMTPS id gq6si11025978pac.114.2015.06.18.04.47.45
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Jun 2015 04:47:46 -0700 (PDT)
Received: by pacyx8 with SMTP id yx8so59889479pac.2
        for <linux-mm@kvack.org>; Thu, 18 Jun 2015 04:47:45 -0700 (PDT)
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: [RFC][PATCHv3 2/7] zsmalloc: partial page ordering within a fullness_list
Date: Thu, 18 Jun 2015 20:46:39 +0900
Message-Id: <1434628004-11144-3-git-send-email-sergey.senozhatsky@gmail.com>
In-Reply-To: <1434628004-11144-1-git-send-email-sergey.senozhatsky@gmail.com>
References: <1434628004-11144-1-git-send-email-sergey.senozhatsky@gmail.com>
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

It performs a trivial and cheap ->inuse compare which does not slow
down zsmalloc, and in the worst case it keeps the list pages not in
any particular order, just like we do it now.

A more expensive solution could sort fullness_list by ->inuse count.

Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
---
 mm/zsmalloc.c | 12 ++++++++++--
 1 file changed, 10 insertions(+), 2 deletions(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index 7d816c2..6e2ebb6 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -659,8 +659,16 @@ static void insert_zspage(struct page *page, struct size_class *class,
 		return;
 
 	head = &class->fullness_list[fullness];
-	if (*head)
-		list_add_tail(&page->lru, &(*head)->lru);
+	if (*head) {
+		/*
+		 * We want to see more ZS_FULL pages and less almost
+		 * empty/full. Put pages with higher ->inuse first.
+		 */
+		if (page->inuse < (*head)->inuse)
+			list_add_tail(&page->lru, &(*head)->lru);
+		else
+			list_add(&page->lru, &(*head)->lru);
+	}
 
 	*head = page;
 	zs_stat_inc(class, fullness == ZS_ALMOST_EMPTY ?
-- 
2.4.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
