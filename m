Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 5DAB4900016
	for <linux-mm@kvack.org>; Fri,  5 Jun 2015 08:04:53 -0400 (EDT)
Received: by pdjm12 with SMTP id m12so52220774pdj.3
        for <linux-mm@kvack.org>; Fri, 05 Jun 2015 05:04:53 -0700 (PDT)
Received: from mail-pd0-x22b.google.com (mail-pd0-x22b.google.com. [2607:f8b0:400e:c02::22b])
        by mx.google.com with ESMTPS id oj16si10640797pdb.160.2015.06.05.05.04.52
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 Jun 2015 05:04:52 -0700 (PDT)
Received: by pdjn11 with SMTP id n11so14449065pdj.0
        for <linux-mm@kvack.org>; Fri, 05 Jun 2015 05:04:52 -0700 (PDT)
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: [RFC][PATCHv2 2/8] zsmalloc: partial page ordering within a fullness_list
Date: Fri,  5 Jun 2015 21:03:52 +0900
Message-Id: <1433505838-23058-3-git-send-email-sergey.senozhatsky@gmail.com>
In-Reply-To: <1433505838-23058-1-git-send-email-sergey.senozhatsky@gmail.com>
References: <1433505838-23058-1-git-send-email-sergey.senozhatsky@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

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
index ce3310c..cd37bda 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -658,8 +658,16 @@ static void insert_zspage(struct page *page, struct size_class *class,
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
2.4.2.387.gf86f31a

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
