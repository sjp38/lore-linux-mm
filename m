Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id E33496B0253
	for <linux-mm@kvack.org>; Sat,  9 Jul 2016 11:55:33 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id e189so155911152pfa.2
        for <linux-mm@kvack.org>; Sat, 09 Jul 2016 08:55:33 -0700 (PDT)
Received: from out4439.biz.mail.alibaba.com (out4439.biz.mail.alibaba.com. [47.88.44.39])
        by mx.google.com with ESMTP id k4si4744792paz.154.2016.07.09.08.55.31
        for <linux-mm@kvack.org>;
        Sat, 09 Jul 2016 08:55:33 -0700 (PDT)
From: chengang@emindsoft.com.cn
Subject: [PATCH] mm: migrate: Use bool instead of int for the return value of PageMovable
Date: Sat,  9 Jul 2016 23:55:04 +0800
Message-Id: <1468079704-5477-1-git-send-email-chengang@emindsoft.com.cn>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, minchan@kernel.org, vbabka@suse.cz, mgorman@techsingularity.net, mhocko@suse.com
Cc: gi-oh.kim@profitbricks.com, iamjoonsoo.kim@lge.com, hillf.zj@alibaba-inc.com, rientjes@google.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Chen Gang <chengang@emindsoft.com.cn>, Chen Gang <gang.chen.5i5j@gmail.com>

From: Chen Gang <chengang@emindsoft.com.cn>

For pure bool function's return value, bool is a little better more or
less than int.

And return boolean result directly, since 'if' statement is also for
boolean checking, and return boolean result, too.

Signed-off-by: Chen Gang <gang.chen.5i5j@gmail.com>
---
 include/linux/migrate.h | 4 ++--
 mm/compaction.c         | 9 +++------
 2 files changed, 5 insertions(+), 8 deletions(-)

diff --git a/include/linux/migrate.h b/include/linux/migrate.h
index ae8d475..0e366f8 100644
--- a/include/linux/migrate.h
+++ b/include/linux/migrate.h
@@ -72,11 +72,11 @@ static inline int migrate_huge_page_move_mapping(struct address_space *mapping,
 #endif /* CONFIG_MIGRATION */
 
 #ifdef CONFIG_COMPACTION
-extern int PageMovable(struct page *page);
+extern bool PageMovable(struct page *page);
 extern void __SetPageMovable(struct page *page, struct address_space *mapping);
 extern void __ClearPageMovable(struct page *page);
 #else
-static inline int PageMovable(struct page *page) { return 0; };
+static inline bool PageMovable(struct page *page) { return false; };
 static inline void __SetPageMovable(struct page *page,
 				struct address_space *mapping)
 {
diff --git a/mm/compaction.c b/mm/compaction.c
index 0bd53fb..cfcfe88 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -95,19 +95,16 @@ static inline bool migrate_async_suitable(int migratetype)
 
 #ifdef CONFIG_COMPACTION
 
-int PageMovable(struct page *page)
+bool PageMovable(struct page *page)
 {
 	struct address_space *mapping;
 
 	VM_BUG_ON_PAGE(!PageLocked(page), page);
 	if (!__PageMovable(page))
-		return 0;
+		return false;
 
 	mapping = page_mapping(page);
-	if (mapping && mapping->a_ops && mapping->a_ops->isolate_page)
-		return 1;
-
-	return 0;
+	return mapping && mapping->a_ops && mapping->a_ops->isolate_page;
 }
 EXPORT_SYMBOL(PageMovable);
 
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
