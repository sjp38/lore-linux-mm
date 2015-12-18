Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 6EF5D6B0023
	for <linux-mm@kvack.org>; Fri, 18 Dec 2015 04:04:02 -0500 (EST)
Received: by mail-wm0-f44.google.com with SMTP id p187so55188966wmp.0
        for <linux-mm@kvack.org>; Fri, 18 Dec 2015 01:04:02 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ia6si24128040wjb.29.2015.12.18.01.03.37
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 18 Dec 2015 01:03:38 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH v3 11/14] mm, page_owner: copy page owner info during migration
Date: Fri, 18 Dec 2015 10:03:23 +0100
Message-Id: <1450429406-7081-12-git-send-email-vbabka@suse.cz>
In-Reply-To: <1450429406-7081-1-git-send-email-vbabka@suse.cz>
References: <1450429406-7081-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Minchan Kim <minchan@kernel.org>, Sasha Levin <sasha.levin@oracle.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>

The page_owner mechanism stores gfp_flags of an allocation and stack trace
that lead to it. During page migration, the original information is
practically replaced by the allocation of free page as the migration target.
Arguably this is less useful and might lead to all the page_owner info for
migratable pages gradually converge towards compaction or numa balancing
migrations. It has also lead to inaccuracies such as one fixed by commit
e2cfc91120fa ("mm/page_owner: set correct gfp_mask on page_owner").

This patch thus introduces copying the page_owner info during migration.
However, since the fact that the page has been migrated from its original
place might be useful for debugging, the next patch will introduce a way to
track that information as well.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Sasha Levin <sasha.levin@oracle.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Hugh Dickins <hughd@google.com>
---
 include/linux/page_owner.h | 10 +++++++++-
 mm/migrate.c               |  3 +++
 mm/page_owner.c            | 25 +++++++++++++++++++++++++
 3 files changed, 37 insertions(+), 1 deletion(-)

diff --git a/include/linux/page_owner.h b/include/linux/page_owner.h
index 8e2eb153c7b9..6440daab4ef8 100644
--- a/include/linux/page_owner.h
+++ b/include/linux/page_owner.h
@@ -11,6 +11,7 @@ extern void __reset_page_owner(struct page *page, unsigned int order);
 extern void __set_page_owner(struct page *page,
 			unsigned int order, gfp_t gfp_mask);
 extern gfp_t __get_page_owner_gfp(struct page *page);
+extern void __copy_page_owner(struct page *oldpage, struct page *newpage);
 
 static inline void reset_page_owner(struct page *page, unsigned int order)
 {
@@ -32,6 +33,11 @@ static inline gfp_t get_page_owner_gfp(struct page *page)
 	else
 		return 0;
 }
+static inline void copy_page_owner(struct page *oldpage, struct page *newpage)
+{
+	if (static_branch_unlikely(&page_owner_inited))
+		__copy_page_owner(oldpage, newpage);
+}
 #else
 static inline void reset_page_owner(struct page *page, unsigned int order)
 {
@@ -44,6 +50,8 @@ static inline gfp_t get_page_owner_gfp(struct page *page)
 {
 	return 0;
 }
-
+static inline void copy_page_owner(struct page *oldpage, struct page *newpage)
+{
+}
 #endif /* CONFIG_PAGE_OWNER */
 #endif /* __LINUX_PAGE_OWNER_H */
diff --git a/mm/migrate.c b/mm/migrate.c
index b1034f9c77e7..863a0f1fe23f 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -38,6 +38,7 @@
 #include <linux/balloon_compaction.h>
 #include <linux/mmu_notifier.h>
 #include <linux/page_idle.h>
+#include <linux/page_owner.h>
 
 #include <asm/tlbflush.h>
 
@@ -578,6 +579,8 @@ void migrate_page_copy(struct page *newpage, struct page *page)
 	 */
 	if (PageWriteback(newpage))
 		end_page_writeback(newpage);
+
+	copy_page_owner(page, newpage);
 }
 
 /************************************************************
diff --git a/mm/page_owner.c b/mm/page_owner.c
index c8ea1361146e..a390d2665df2 100644
--- a/mm/page_owner.c
+++ b/mm/page_owner.c
@@ -84,6 +84,31 @@ gfp_t __get_page_owner_gfp(struct page *page)
 	return page_ext->gfp_mask;
 }
 
+void __copy_page_owner(struct page *oldpage, struct page *newpage)
+{
+	struct page_ext *old_ext = lookup_page_ext(oldpage);
+	struct page_ext *new_ext = lookup_page_ext(newpage);
+	int i;
+
+	new_ext->order = old_ext->order;
+	new_ext->gfp_mask = old_ext->gfp_mask;
+	new_ext->nr_entries = old_ext->nr_entries;
+
+	for (i = 0; i < ARRAY_SIZE(new_ext->trace_entries); i++)
+		new_ext->trace_entries[i] = old_ext->trace_entries[i];
+
+	/*
+	 * We don't clear the bit on the oldpage as it's going to be freed
+	 * after migration. Until then, the info can be useful in case of
+	 * a bug, and the overal stats will be off a bit only temporarily.
+	 * Also, migrate_misplaced_transhuge_page() can still fail the
+	 * migration and then we want the oldpage to retain the info. But
+	 * in that case we also don't need to explicitly clear the info from
+	 * the new page, which will be freed.
+	 */
+	__set_bit(PAGE_EXT_OWNER, &new_ext->flags);
+}
+
 static ssize_t
 print_page_owner(char __user *buf, size_t count, unsigned long pfn,
 		struct page *page, struct page_ext *page_ext)
-- 
2.6.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
