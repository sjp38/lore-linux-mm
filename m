Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 03E3E6B0256
	for <linux-mm@kvack.org>; Wed,  4 Nov 2015 10:01:34 -0500 (EST)
Received: by wmeg8 with SMTP id g8so43742581wme.1
        for <linux-mm@kvack.org>; Wed, 04 Nov 2015 07:01:33 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q141si4170913wmg.85.2015.11.04.07.01.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 04 Nov 2015 07:01:25 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH 3/5] mm, page_owner: copy page owner info during migration
Date: Wed,  4 Nov 2015 16:00:59 +0100
Message-Id: <1446649261-27122-4-git-send-email-vbabka@suse.cz>
In-Reply-To: <1446649261-27122-1-git-send-email-vbabka@suse.cz>
References: <1446649261-27122-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Minchan Kim <minchan@kernel.org>, Sasha Levin <sasha.levin@oracle.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>

The page_owner mechanism stores gfp_flags of an allocation and stack trace
that lead to it. During page migration, the original information is
essentially replaced by the allocation of free page as the migration target.
Arguably this is less useful and might lead to all the page_owner info for
migratable pages gradually converge towards compaction or numa balancing
migrations. It has also lead to inaccuracies such as one fixed by commit
e2cfc91120fa ("mm/page_owner: set correct gfp_mask on page_owner").

This patch thus introduces copying the page_owner info during migration.
However, since the fact that the page has been migrated from its original
place might be useful for debugging, the next patch will introduce a way to
track that information as well.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 include/linux/page_owner.h | 10 +++++++++-
 mm/migrate.c               |  2 ++
 mm/page_owner.c            | 16 ++++++++++++++++
 3 files changed, 27 insertions(+), 1 deletion(-)

diff --git a/include/linux/page_owner.h b/include/linux/page_owner.h
index 8e2eb15..6440daa 100644
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
index 1ae0113..9f82e03 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -38,6 +38,7 @@
 #include <linux/balloon_compaction.h>
 #include <linux/mmu_notifier.h>
 #include <linux/page_idle.h>
+#include <linux/page_owner.h>
 
 #include <asm/tlbflush.h>
 
@@ -775,6 +776,7 @@ static int move_to_new_page(struct page *newpage, struct page *page,
 		set_page_memcg(page, NULL);
 		if (!PageAnon(page))
 			page->mapping = NULL;
+		copy_page_owner(page, newpage);
 	}
 	return rc;
 }
diff --git a/mm/page_owner.c b/mm/page_owner.c
index 7664b85..7ebd3d0 100644
--- a/mm/page_owner.c
+++ b/mm/page_owner.c
@@ -84,6 +84,22 @@ gfp_t __get_page_owner_gfp(struct page *page)
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
+	__set_bit(PAGE_EXT_OWNER, &new_ext->flags);
+}
+
 static ssize_t
 print_page_owner(char __user *buf, size_t count, unsigned long pfn,
 		struct page *page, struct page_ext *page_ext)
-- 
2.6.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
