Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id A89A46B0006
	for <linux-mm@kvack.org>; Thu, 21 Feb 2013 14:42:43 -0500 (EST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH 2/9] migrate: make core migration code aware of hugepage
Date: Thu, 21 Feb 2013 14:41:41 -0500
Message-Id: <1361475708-25991-3-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1361475708-25991-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1361475708-25991-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org

Before enabling each user of page migration to support hugepage,
this patch adds necessary changes on core migration code.
The main change is that the list of pages to migrate can link
not only LRU pages, but also hugepages.
Along with this, functions such as migrate_pages() and
putback_movable_pages() need to be changed to handle hugepages.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 include/linux/hugetlb.h   |  4 ++++
 include/linux/mempolicy.h |  2 +-
 include/linux/migrate.h   |  6 ++++++
 mm/hugetlb.c              | 16 ++++++++++++++++
 mm/migrate.c              | 27 +++++++++++++++++++++++++--
 5 files changed, 52 insertions(+), 3 deletions(-)

diff --git v3.8.orig/include/linux/hugetlb.h v3.8/include/linux/hugetlb.h
index 40b27f6..8f87115 100644
--- v3.8.orig/include/linux/hugetlb.h
+++ v3.8/include/linux/hugetlb.h
@@ -67,6 +67,8 @@ int hugetlb_reserve_pages(struct inode *inode, long from, long to,
 						vm_flags_t vm_flags);
 void hugetlb_unreserve_pages(struct inode *inode, long offset, long freed);
 int dequeue_hwpoisoned_huge_page(struct page *page);
+void putback_active_hugepage(struct page *page);
+void putback_active_hugepages(struct list_head *l);
 void copy_huge_page(struct page *dst, struct page *src);
 
 extern unsigned long hugepages_treat_as_movable;
@@ -130,6 +132,8 @@ static inline int dequeue_hwpoisoned_huge_page(struct page *page)
 	return 0;
 }
 
+#define putback_active_hugepage(p) 0
+#define putback_active_hugepages(l) 0
 static inline void copy_huge_page(struct page *dst, struct page *src)
 {
 }
diff --git v3.8.orig/include/linux/mempolicy.h v3.8/include/linux/mempolicy.h
index 0d7df39..2e475b5 100644
--- v3.8.orig/include/linux/mempolicy.h
+++ v3.8/include/linux/mempolicy.h
@@ -173,7 +173,7 @@ extern int mpol_to_str(char *buffer, int maxlen, struct mempolicy *pol);
 /* Check if a vma is migratable */
 static inline int vma_migratable(struct vm_area_struct *vma)
 {
-	if (vma->vm_flags & (VM_IO | VM_HUGETLB | VM_PFNMAP))
+	if (vma->vm_flags & (VM_IO | VM_PFNMAP))
 		return 0;
 	/*
 	 * Migration allocates pages in the highest zone. If we cannot
diff --git v3.8.orig/include/linux/migrate.h v3.8/include/linux/migrate.h
index 1e9f627..d626c27 100644
--- v3.8.orig/include/linux/migrate.h
+++ v3.8/include/linux/migrate.h
@@ -42,6 +42,9 @@ extern int migrate_page(struct address_space *,
 extern int migrate_pages(struct list_head *l, new_page_t x,
 			unsigned long private, bool offlining,
 			enum migrate_mode mode, int reason);
+extern int migrate_movable_pages(struct list_head *from,
+		new_page_t get_new_page, unsigned long private, bool offlining,
+		enum migrate_mode mode, int reason);
 extern int migrate_huge_page(struct page *, new_page_t x,
 			unsigned long private, bool offlining,
 			enum migrate_mode mode);
@@ -64,6 +67,9 @@ static inline void putback_movable_pages(struct list_head *l) {}
 static inline int migrate_pages(struct list_head *l, new_page_t x,
 		unsigned long private, bool offlining,
 		enum migrate_mode mode, int reason) { return -ENOSYS; }
+static inline int migrate_movable_pages(struct list_head *from,
+		new_page_t get_new_page, unsigned long private, bool offlining,
+		enum migrate_mode mode, int reason) { return -ENOSYS; }
 static inline int migrate_huge_page(struct page *page, new_page_t x,
 		unsigned long private, bool offlining,
 		enum migrate_mode mode) { return -ENOSYS; }
diff --git v3.8.orig/mm/hugetlb.c v3.8/mm/hugetlb.c
index 351025e..cb9d43b8 100644
--- v3.8.orig/mm/hugetlb.c
+++ v3.8/mm/hugetlb.c
@@ -3186,3 +3186,19 @@ int dequeue_hwpoisoned_huge_page(struct page *hpage)
 	return ret;
 }
 #endif
+
+void putback_active_hugepage(struct page *page)
+{
+	VM_BUG_ON(!PageHead(page));
+	list_move_tail(&page->lru, &(page_hstate(page))->hugepage_activelist);
+	put_page(page);
+}
+
+void putback_active_hugepages(struct list_head *l)
+{
+	struct page *page;
+	struct page *page2;
+
+	list_for_each_entry_safe(page, page2, l, lru)
+		putback_active_hugepage(page);
+}
diff --git v3.8.orig/mm/migrate.c v3.8/mm/migrate.c
index 7d84f4c..e305dc0 100644
--- v3.8.orig/mm/migrate.c
+++ v3.8/mm/migrate.c
@@ -100,6 +100,10 @@ void putback_movable_pages(struct list_head *l)
 	struct page *page2;
 
 	list_for_each_entry_safe(page, page2, l, lru) {
+		if (unlikely(PageHuge(page))) {
+			putback_active_hugepage(page);
+			continue;
+		}
 		list_del(&page->lru);
 		dec_zone_page_state(page, NR_ISOLATED_ANON +
 				page_is_file_cache(page));
@@ -1046,8 +1050,12 @@ int migrate_pages(struct list_head *from,
 
 		list_for_each_entry_safe(page, page2, from, lru) {
 			cond_resched();
-
-			rc = unmap_and_move(get_new_page, private,
+			if (PageHuge(page))
+				rc = unmap_and_move_huge_page(get_new_page,
+						private, page, pass > 2,
+						offlining, mode);
+			else
+				rc = unmap_and_move(get_new_page, private,
 						page, pass > 2, offlining,
 						mode);
 
@@ -1081,6 +1089,21 @@ int migrate_pages(struct list_head *from,
 	return rc;
 }
 
+int migrate_movable_pages(struct list_head *from, new_page_t get_new_page,
+			unsigned long private, bool offlining,
+			enum migrate_mode mode, int reason)
+{
+	int err = 0;
+
+	if (!list_empty(from)) {
+		err = migrate_pages(from, get_new_page, private,
+				    offlining, mode, reason);
+		if (err)
+			putback_movable_pages(from);
+	}
+	return err;
+}
+
 int migrate_huge_page(struct page *hpage, new_page_t get_new_page,
 		      unsigned long private, bool offlining,
 		      enum migrate_mode mode)
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
