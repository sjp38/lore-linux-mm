Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 9DB026B0070
	for <linux-mm@kvack.org>; Tue,  2 Jun 2015 03:27:22 -0400 (EDT)
Received: by pdbnf5 with SMTP id nf5so65808986pdb.2
        for <linux-mm@kvack.org>; Tue, 02 Jun 2015 00:27:22 -0700 (PDT)
Received: from lgeamrelo04.lge.com (lgeamrelo04.lge.com. [156.147.1.127])
        by mx.google.com with ESMTP id r11si25076510pdj.220.2015.06.02.00.27.20
        for <linux-mm@kvack.org>;
        Tue, 02 Jun 2015 00:27:21 -0700 (PDT)
From: Gioh Kim <gioh.kim@lge.com>
Subject: [RFC 1/4] mm/compaction: enable driver page migration
Date: Tue,  2 Jun 2015 16:27:41 +0900
Message-Id: <1433230065-3573-2-git-send-email-gioh.kim@lge.com>
In-Reply-To: <1433230065-3573-1-git-send-email-gioh.kim@lge.com>
References: <1433230065-3573-1-git-send-email-gioh.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: jlayton@poochiereds.net, bfields@fieldses.org, akpm@linux-foundation.org, vbabka@suse.cz, iamjoonsoo.kim@lge.com, mst@redhat.com, kirill@shutemov.name, minchan@kernel.org, mgorman@suse.de
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, virtualization@lists.linux-foundation.org, gunho.lee@lge.com, Gioh Kim <gioh.kim@lge.com>

Add framework to register callback functions and
check migratable pages.
There are some modes to isolate page so that isolate interface
has arguments of page address and isolation mode.

Signed-off-by: Gioh Kim <gioh.kim@lge.com>
---
 include/linux/compaction.h | 13 +++++++++++++
 include/linux/fs.h         |  2 ++
 include/linux/mm.h         | 19 +++++++++++++++++++
 include/linux/pagemap.h    | 27 +++++++++++++++++++++++++++
 4 files changed, 61 insertions(+)

diff --git a/include/linux/compaction.h b/include/linux/compaction.h
index a014559..1acfa21 100644
--- a/include/linux/compaction.h
+++ b/include/linux/compaction.h
@@ -1,6 +1,9 @@
 #ifndef _LINUX_COMPACTION_H
 #define _LINUX_COMPACTION_H
 
+#include <linux/pagemap.h>
+#include <linux/mm.h>
+
 /* Return values for compact_zone() and try_to_compact_pages() */
 /* compaction didn't start as it was deferred due to past failures */
 #define COMPACT_DEFERRED	0
@@ -50,6 +53,11 @@ extern void compaction_defer_reset(struct zone *zone, int order,
 				bool alloc_success);
 extern bool compaction_restarting(struct zone *zone, int order);
 
+static inline bool driver_page_migratable(struct page *page)
+{
+	return PageMigratable(page) && mapping_migratable(page->mapping);
+}
+
 #else
 static inline unsigned long try_to_compact_pages(gfp_t gfp_mask,
 			unsigned int order, int alloc_flags,
@@ -82,6 +90,11 @@ static inline bool compaction_deferred(struct zone *zone, int order)
 	return true;
 }
 
+static inline bool driver_page_migratable(struct page *page)
+{
+	return false
+}
+
 #endif /* CONFIG_COMPACTION */
 
 #if defined(CONFIG_COMPACTION) && defined(CONFIG_SYSFS) && defined(CONFIG_NUMA)
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 52cc449..bdfcadf 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -368,6 +368,8 @@ struct address_space_operations {
 	 */
 	int (*migratepage) (struct address_space *,
 			struct page *, struct page *, enum migrate_mode);
+	bool (*isolatepage) (struct page *, isolate_mode_t);
+	void (*putbackpage) (struct page *);
 	int (*launder_page) (struct page *);
 	int (*is_partially_uptodate) (struct page *, unsigned long,
 					unsigned long);
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 47a9392..422c484 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -618,6 +618,25 @@ static inline void __ClearPageBalloon(struct page *page)
 	atomic_set(&page->_mapcount, -1);
 }
 
+#define PAGE_MIGRATABLE_MAPCOUNT_VALUE (-256)
+
+static inline int PageMigratable(struct page *page)
+{
+	return atomic_read(&page->_mapcount) == PAGE_MIGRATABLE_MAPCOUNT_VALUE;
+}
+
+static inline void __SetPageMigratable(struct page *page)
+{
+	VM_BUG_ON_PAGE(atomic_read(&page->_mapcount) != -1, page);
+	atomic_set(&page->_mapcount, PAGE_MIGRATABLE_MAPCOUNT_VALUE);
+}
+
+static inline void __ClearPageMigratable(struct page *page)
+{
+	VM_BUG_ON_PAGE(!PageMigratable(page), page);
+	atomic_set(&page->_mapcount, -1);
+}
+
 void put_page(struct page *page);
 void put_pages_list(struct list_head *pages);
 
diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index 4b3736f..e924dfe 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -25,8 +25,35 @@ enum mapping_flags {
 	AS_MM_ALL_LOCKS	= __GFP_BITS_SHIFT + 2,	/* under mm_take_all_locks() */
 	AS_UNEVICTABLE	= __GFP_BITS_SHIFT + 3,	/* e.g., ramdisk, SHM_LOCK */
 	AS_EXITING	= __GFP_BITS_SHIFT + 4, /* final truncate in progress */
+	AS_MIGRATABLE   = __GFP_BITS_SHIFT + 5,
 };
 
+static inline void mapping_set_migratable(struct address_space *mapping)
+{
+	set_bit(AS_MIGRATABLE, &mapping->flags);
+}
+
+static inline void mapping_clear_migratable(struct address_space *mapping)
+{
+	clear_bit(AS_MIGRATABLE, &mapping->flags);
+}
+
+static inline int __mapping_ops(struct address_space *mapping)
+{
+	/* migrating page should define all following methods */
+	return mapping->a_ops &&
+		mapping->a_ops->migratepage &&
+		mapping->a_ops->isolatepage &&
+		mapping->a_ops->putbackpage;
+}
+
+static inline int mapping_migratable(struct address_space *mapping)
+{
+	if (mapping && __mapping_ops(mapping))
+		return test_bit(AS_MIGRATABLE, &mapping->flags);
+	return !!mapping;
+}
+
 static inline void mapping_set_error(struct address_space *mapping, int error)
 {
 	if (unlikely(error)) {
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
