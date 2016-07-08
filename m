Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9D9DE6B0263
	for <linux-mm@kvack.org>; Fri,  8 Jul 2016 08:12:12 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id e189so92406059pfa.2
        for <linux-mm@kvack.org>; Fri, 08 Jul 2016 05:12:12 -0700 (PDT)
Received: from mail-pa0-x242.google.com (mail-pa0-x242.google.com. [2607:f8b0:400e:c03::242])
        by mx.google.com with ESMTPS id sm3si580019pab.180.2016.07.08.05.12.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Jul 2016 05:12:11 -0700 (PDT)
Received: by mail-pa0-x242.google.com with SMTP id dx3so6196390pab.2
        for <linux-mm@kvack.org>; Fri, 08 Jul 2016 05:12:11 -0700 (PDT)
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: [RFC][PATCH v2 2/3] mm/page_owner: rename PAGE_EXT_OWNER flag
Date: Fri,  8 Jul 2016 21:11:31 +0900
Message-Id: <20160708121132.8253-3-sergey.senozhatsky@gmail.com>
In-Reply-To: <20160708121132.8253-1-sergey.senozhatsky@gmail.com>
References: <20160708121132.8253-1-sergey.senozhatsky@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>

A cosmetic change:

PAGE_OWNER_TRACK_FREE will introduce one more page_owner
flag: PAGE_EXT_OWNER_FREE. To make names symmetrical, rename
PAGE_EXT_OWNER to PAGE_EXT_OWNER_ALLOC.

Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
---
 include/linux/page_ext.h |  2 +-
 mm/page_owner.c          | 12 ++++++------
 mm/vmstat.c              |  2 +-
 3 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/include/linux/page_ext.h b/include/linux/page_ext.h
index 03f2a3e..66ba2bb 100644
--- a/include/linux/page_ext.h
+++ b/include/linux/page_ext.h
@@ -26,7 +26,7 @@ struct page_ext_operations {
 enum page_ext_flags {
 	PAGE_EXT_DEBUG_POISON,		/* Page is poisoned */
 	PAGE_EXT_DEBUG_GUARD,
-	PAGE_EXT_OWNER,
+	PAGE_EXT_OWNER_ALLOC,
 #if defined(CONFIG_IDLE_PAGE_TRACKING) && !defined(CONFIG_64BIT)
 	PAGE_EXT_YOUNG,
 	PAGE_EXT_IDLE,
diff --git a/mm/page_owner.c b/mm/page_owner.c
index fde443a..4acccb7 100644
--- a/mm/page_owner.c
+++ b/mm/page_owner.c
@@ -94,7 +94,7 @@ void __page_owner_free_pages(struct page *page, unsigned int order)
 		page_ext = lookup_page_ext(page + i);
 		if (unlikely(!page_ext))
 			continue;
-		__clear_bit(PAGE_EXT_OWNER, &page_ext->flags);
+		__clear_bit(PAGE_EXT_OWNER_ALLOC, &page_ext->flags);
 	}
 }
 
@@ -160,7 +160,7 @@ noinline void __page_owner_alloc_pages(struct page *page, unsigned int order,
 	page_ext->gfp_mask = gfp_mask;
 	page_ext->last_migrate_reason = -1;
 
-	__set_bit(PAGE_EXT_OWNER, &page_ext->flags);
+	__set_bit(PAGE_EXT_OWNER_ALLOC, &page_ext->flags);
 }
 
 void __set_page_owner_migrate_reason(struct page *page, int reason)
@@ -207,7 +207,7 @@ void __copy_page_owner(struct page *oldpage, struct page *newpage)
 	 * in that case we also don't need to explicitly clear the info from
 	 * the new page, which will be freed.
 	 */
-	__set_bit(PAGE_EXT_OWNER, &new_ext->flags);
+	__set_bit(PAGE_EXT_OWNER_ALLOC, &new_ext->flags);
 }
 
 static ssize_t
@@ -301,7 +301,7 @@ void __dump_page_owner(struct page *page)
 	gfp_mask = page_ext->gfp_mask;
 	mt = gfpflags_to_migratetype(gfp_mask);
 
-	if (!test_bit(PAGE_EXT_OWNER, &page_ext->flags)) {
+	if (!test_bit(PAGE_EXT_OWNER_ALLOC, &page_ext->flags)) {
 		pr_alert("page_owner info is not active (free page?)\n");
 		return;
 	}
@@ -374,7 +374,7 @@ read_page_owner(struct file *file, char __user *buf, size_t count, loff_t *ppos)
 		 * Some pages could be missed by concurrent allocation or free,
 		 * because we don't hold the zone lock.
 		 */
-		if (!test_bit(PAGE_EXT_OWNER, &page_ext->flags))
+		if (!test_bit(PAGE_EXT_OWNER_ALLOC, &page_ext->flags))
 			continue;
 
 		/*
@@ -448,7 +448,7 @@ static void init_pages_in_zone(pg_data_t *pgdat, struct zone *zone)
 				continue;
 
 			/* Maybe overraping zone */
-			if (test_bit(PAGE_EXT_OWNER, &page_ext->flags))
+			if (test_bit(PAGE_EXT_OWNER_ALLOC, &page_ext->flags))
 				continue;
 
 			/* Found early allocated page */
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 7997f529..63ef65f 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -1070,7 +1070,7 @@ static void pagetypeinfo_showmixedcount_print(struct seq_file *m,
 			if (unlikely(!page_ext))
 				continue;
 
-			if (!test_bit(PAGE_EXT_OWNER, &page_ext->flags))
+			if (!test_bit(PAGE_EXT_OWNER_ALLOC, &page_ext->flags))
 				continue;
 
 			page_mt = gfpflags_to_migratetype(page_ext->gfp_mask);
-- 
2.9.0.37.g6d523a3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
