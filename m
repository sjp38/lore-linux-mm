Date: Tue, 6 Mar 2007 13:55:11 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC} memory unplug patchset prep [11/16] page isolation core
Message-Id: <20070306135511.9eec09b7.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20070306133223.5d610daf.kamezawa.hiroyu@jp.fujitsu.com>
References: <20070306133223.5d610daf.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, mel@skynet.ie, clameter@engr.sgi.com, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

This patch is for supporting making page unused.

Isolate pages by capturing freed pages before inserting free_area[],
buddy allocator.
If you have an idea for avoiding spin_lock(), please advise me.

Isolating pages in free_area[] is implemented in other patch.

Signed-Off-By: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

---
 include/linux/mmzone.h         |    8 +
 include/linux/page_isolation.h |   52 +++++++++++
 mm/Kconfig                     |    7 +
 mm/page_alloc.c                |  184 +++++++++++++++++++++++++++++++++++++++++
 4 files changed, 251 insertions(+)

Index: devel-tree-2.6.20-mm2/include/linux/mmzone.h
===================================================================
--- devel-tree-2.6.20-mm2.orig/include/linux/mmzone.h
+++ devel-tree-2.6.20-mm2/include/linux/mmzone.h
@@ -315,6 +315,14 @@ struct zone {
 	/* zone_start_pfn == zone_start_paddr >> PAGE_SHIFT */
 	unsigned long		zone_start_pfn;
 
+#ifdef CONFIG_PAGE_ISOLATION
+	/*
+	 *  For pages which are not used but not free.
+	 *  See include/linux/page_isolation.h
+	 */
+	spinlock_t		isolation_lock;
+	struct list_head	isolation_list;
+#endif
 	/*
 	 * zone_start_pfn, spanned_pages and present_pages are all
 	 * protected by span_seqlock.  It is a seqlock because it has
Index: devel-tree-2.6.20-mm2/mm/page_alloc.c
===================================================================
--- devel-tree-2.6.20-mm2.orig/mm/page_alloc.c
+++ devel-tree-2.6.20-mm2/mm/page_alloc.c
@@ -41,6 +41,7 @@
 #include <linux/pfn.h>
 #include <linux/backing-dev.h>
 #include <linux/fault-inject.h>
+#include <linux/page_isolation.h>
 
 #include <asm/tlbflush.h>
 #include <asm/div64.h>
@@ -421,6 +422,9 @@ static inline void __free_one_page(struc
 	if (unlikely(PageCompound(page)))
 		destroy_compound_page(page, order);
 
+	if (page_under_isolation(zone, page, order))
+		return;
+
 	page_idx = page_to_pfn(page) & ((1 << MAX_ORDER) - 1);
 
 	VM_BUG_ON(page_idx & (order_size - 1));
@@ -2969,6 +2973,10 @@ static void __meminit free_area_init_cor
 		zone->nr_scan_inactive = 0;
 		zap_zone_vm_stats(zone);
 		atomic_set(&zone->reclaim_in_progress, 0);
+#ifdef CONFIG_PAGE_ISOLATION
+		spin_lock_init(&zone->isolation_lock);
+		INIT_LIST_HEAD(&zone->isolation_list);
+#endif
 		if (!size)
 			continue;
 
@@ -3728,3 +3736,179 @@ EXPORT_SYMBOL(pfn_to_page);
 EXPORT_SYMBOL(page_to_pfn);
 #endif /* CONFIG_OUT_OF_LINE_PFN_TO_PAGE */
 
+#ifdef CONFIG_PAGE_ISOLATION
+/*
+ * Page Isolation.
+ *
+ * If a page is removed from usual free_list and will never be used,
+ * It is linked to "struct isolation_info" and set Reserved, Private
+ * bit. page->mapping points to isolation_info in it.
+ * and page_count(page) is 0.
+ *
+ * This can be used for creating a chunk of contiguous *unused* memory.
+ *
+ * current user is Memory-Hot-Remove.
+ * maybe move to some other file is better.
+ */
+static void
+isolate_page_nolock(struct isolation_info *info, struct page *page, int order)
+{
+	int pagenum;
+	pagenum = 1 << order;
+	while (pagenum > 0) {
+		SetPageReserved(page);
+		SetPagePrivate(page);
+		page->private = (unsigned long)info;
+		list_add(&page->lru, &info->pages);
+		page++;
+		pagenum--;
+	}
+}
+
+/*
+ * This function is called from page_under_isolation()l
+ */
+
+int __page_under_isolation(struct zone *zone, struct page *page, int order)
+{
+	struct isolation_info *info;
+	unsigned long pfn = page_to_pfn(page);
+	unsigned long flags;
+	int found = 0;
+
+	spin_lock_irqsave(&zone->isolation_lock,flags);
+	list_for_each_entry(info, &zone->isolation_list, list) {
+		if (info->start_pfn <= pfn && pfn < info->end_pfn) {
+			found = 1;
+			break;
+		}
+	}
+	if (found) {
+		isolate_page_nolock(info, page, order);
+	}
+	spin_unlock_irqrestore(&zone->isolation_lock, flags);
+	return found;
+}
+
+/*
+ * start and end must be in the same zone.
+ *
+ */
+struct isolation_info  *
+register_isolation(unsigned long start, unsigned long end)
+{
+	struct zone *zone;
+	struct isolation_info *info = NULL, *tmp;
+	unsigned long flags;
+	unsigned long last_pfn = end - 1;
+
+	if (!pfn_valid(start) || !pfn_valid(last_pfn) || (start >= end))
+		return ERR_PTR(-EINVAL);
+	/* check start and end is in the same zone */
+	zone = page_zone(pfn_to_page(start));
+
+	if (zone != page_zone(pfn_to_page(last_pfn)))
+		return ERR_PTR(-EINVAL);
+	/* target range has to match MAX_ORDER alignmet */
+	if ((start & (MAX_ORDER_NR_PAGES - 1)) ||
+		(end & (MAX_ORDER_NR_PAGES - 1)))
+		return ERR_PTR(-EINVAL);
+	info = kmalloc(sizeof(*info), GFP_KERNEL);
+	if (!info)
+		return ERR_PTR(-ENOMEM);
+	spin_lock_irqsave(&zone->isolation_lock, flags);
+	/* we don't allow overlap among isolation areas */
+	if (!list_empty(&zone->isolation_list)) {
+		list_for_each_entry(tmp, &zone->isolation_list, list) {
+			if (start < tmp->end_pfn && end > tmp->start_pfn) {
+				goto out_free;
+			}
+		}
+	}
+	info->start_pfn = start;
+	info->end_pfn = end;
+	info->zone = zone;
+	INIT_LIST_HEAD(&info->list);
+	INIT_LIST_HEAD(&info->pages);
+	list_add(&info->list, &zone->isolation_list);
+out_unlock:
+	spin_unlock_irqrestore(&zone->isolation_lock, flags);
+	return info;
+out_free:
+	kfree(info);
+	info = ERR_PTR(-EBUSY);
+	goto out_unlock;
+}
+/*
+ * Remove IsolationInfo from zone.
+ * After this, we can unuse memory in info or
+ * free back to freelist.
+ */
+
+void
+detach_isolation_info_zone(struct isolation_info *info)
+{
+	unsigned long flags;
+	struct zone *zone = info->zone;
+	spin_lock_irqsave(&zone->isolation_lock,flags);
+	list_del(&info->list);
+	info->zone = NULL;
+	spin_unlock_irqrestore(&zone->isolation_lock,flags);
+}
+
+/*
+ * All pages in info->pages should be remvoed before calling this.
+ * And info should be detached from zone.
+ */
+void
+free_isolation_info(struct isolation_info *info)
+{
+	BUG_ON(!list_empty(&info->pages));
+	BUG_ON(info->zone);
+	kfree(info);
+	return;
+}
+
+/*
+ * Mark All pages in the isolation_info to be Reserved.
+ * When onlining these pages again, a user must check
+ * which page is usable by IORESOURCE_RAM
+ * please see memory_hotplug.c/online_pages() if unclear.
+ *
+ * info should be detached from zone before calling this.
+ */
+void
+unuse_all_isolated_pages(struct isolation_info *info)
+{
+	struct page *page, *n;
+	BUG_ON(info->zone);
+	list_for_each_entry_safe(page, n, &info->pages, lru) {
+		SetPageReserved(page);
+		page->private = 0;
+		ClearPagePrivate(page);
+		list_del(&page->lru);
+	}
+}
+
+/*
+ * Free all pages connected in isolation list.
+ * pages are moved back to free_list.
+ */
+void
+free_all_isolated_pages(struct isolation_info *info)
+{
+	struct page *page, *n;
+	BUG_ON(info->zone);
+	list_for_each_entry_safe(page, n ,&info->pages, lru) {
+		ClearPagePrivate(page);
+		ClearPageReserved(page);
+		page->private = 0;
+		list_del(&page->lru);
+		set_page_count(page, 0);
+		set_page_refcounted(page);
+		/* This is sage because info is detached from zone */
+		__free_page(page);
+	}
+}
+
+#endif
Index: devel-tree-2.6.20-mm2/mm/Kconfig
===================================================================
--- devel-tree-2.6.20-mm2.orig/mm/Kconfig
+++ devel-tree-2.6.20-mm2/mm/Kconfig
@@ -224,3 +224,10 @@ config DEBUG_READAHEAD
 
 	  Say N for production servers.
 
+config PAGE_ISOLATION
+	bool	"Page Isolation Framework"
+	help
+	  This option adds page isolation framework to mm.
+	  This is used for isolate amount of contiguous pages from linux
+	  memory management.
+	  Say N if unsure.
Index: devel-tree-2.6.20-mm2/include/linux/page_isolation.h
===================================================================
--- /dev/null
+++ devel-tree-2.6.20-mm2/include/linux/page_isolation.h
@@ -0,0 +1,52 @@
+#ifndef __LINIX_PAGE_ISOLATION_H
+#define __LINUX_PAGE_ISOLATION_H
+
+#ifdef CONFIG_PAGE_ISOLATION
+
+struct isolation_info {
+	struct list_head	list;
+	unsigned long	start_pfn;
+	unsigned long	end_pfn;
+	struct zone		*zone;
+	struct list_head	pages;
+};
+
+extern int
+__page_under_isolation(struct zone *zone, struct page *page, int order);
+
+static inline int
+page_under_isolation(struct zone *zone, struct page *page, int order)
+{
+	if (likely(list_empty(&zone->isolation_list)))
+		return 0;
+	return __page_under_isolation(zone, page, order);
+}
+
+static inline int
+is_page_isolated(struct isolation_info *info, struct page *page)
+{
+	if (PageReserved(page) && PagePrivate(page) &&
+	    page_count(page) == 0 &&
+	    page->private == (unsigned long)info)
+		return 1;
+	return 0;
+}
+
+extern struct isolation_info *
+register_isolation(unsigned long start, unsigned long end);
+
+extern void detach_isolation_info_zone(struct isolation_info *info);
+extern void free_isolation_info(struct isolation_info *info);
+extern void unuse_all_isolated_pages(struct isolation_info *info);
+extern void free_all_isolated_pages(struct isolation_info *info);
+
+#else
+
+static inline int
+page_under_isolation(struct zone *zone, struct page *page, int order)
+{
+	return 0;
+}
+
+#endif
+#endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
