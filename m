Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id 6078A6B00ED
	for <linux-mm@kvack.org>; Thu, 16 Feb 2012 09:32:53 -0500 (EST)
From: =?UTF-8?q?Rados=C5=82aw=20Smogura?= <mail@smogura.eu>
Subject: [PATCH 06/18] Make migrate pages fucntion more flexible.
Date: Thu, 16 Feb 2012 15:31:33 +0100
Message-Id: <1329402705-25454-6-git-send-email-mail@smogura.eu>
In-Reply-To: <1329402705-25454-1-git-send-email-mail@smogura.eu>
References: <1329402705-25454-1-git-send-email-mail@smogura.eu>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Yongqiang Yang <xiaoqiangnk@gmail.com>, mail@smogura.eu, linux-ext4@vger.kernel.org

Changes migrate pages to more flexible form, allowing more complex usage then
LRU list and advanced page managing during migration.

Those changes are designed for Huge Page Cache to safly pass and migrate page
to new place, in particullary allowing passing locked and getted pages.
New implementation uses configuration structure with various
"life-cycle" methods for making callbacks when getting next, new page or
notifing result.

Signed-off-by: RadosA?aw Smogura <mail@smogura.eu>
---
 include/linux/migrate.h      |   52 ++++++++++++++++++++++++++++++++++++++++++
 include/linux/migrate_mode.h |    8 ++++--
 mm/migrate.c                 |   48 ++++++++++++++++++++++++++++++++++++--
 3 files changed, 102 insertions(+), 6 deletions(-)

diff --git a/include/linux/migrate.h b/include/linux/migrate.h
index 05ed282..0438aff 100644
--- a/include/linux/migrate.h
+++ b/include/linux/migrate.h
@@ -5,8 +5,42 @@
 #include <linux/mempolicy.h>
 #include <linux/migrate_mode.h>
 
+struct migration_ctl;
+
+typedef enum {
+	PAGE_LOCKED = (1 << 0)
+} page_mode;
+
+/** Keept for simplified, backward comptaible, list based migrate_pages */
 typedef struct page *new_page_t(struct page *, unsigned long private, int **);
 
+typedef struct page *mig_page_new_t(struct page *, struct migration_ctl *);
+
+typedef struct page *mig_page_next_t(struct migration_ctl *, page_mode *mode);
+
+typedef void mig_page_result_t(struct page *oldPage, struct page *newPage,
+	struct migration_ctl *ctl, int result);
+
+/** Control for extended migration support. */
+struct migration_ctl {
+	/** Attach some private data if you need one. */
+	unsigned long privateData;
+
+	/** Will be called to get next page for migration, {@code NULL} means
+	 * to end migration. In certain cases function may return same page
+	 * twice or more, depending on migration success.
+	 */
+	mig_page_next_t *getNextPage;
+
+	/** Will be called after getNextPage to get target page. */
+	mig_page_new_t *getNewPage;
+
+	/** Called after migration page ended, despiting success or failure.
+	 * This function is reponsible for cleanuping etc.
+	 */
+	mig_page_result_t *notifyResult;
+};
+
 #ifdef CONFIG_MIGRATION
 #define PAGE_MIGRATION 1
 
@@ -16,6 +50,24 @@ extern int migrate_page(struct address_space *,
 extern int migrate_pages(struct list_head *l, new_page_t x,
 			unsigned long private, bool offlining,
 			enum migrate_mode mode);
+
+/** Calback version of migrate_pages.
+ *
+ * Instead of getting pages from list passed callbacks are used
+ * to get next, new page and to notify result. If obtained old page
+ * was with PAGE_LOCKED flag then it will not be unlocked.<br/>
+ * Caller is responsible for cleaning (putting back if he wants) old and
+ * newpage. <br/>
+ * Function have following pseudo-call flow:
+ * while ({@link migration_ctl.getNextPage}) <br/>
+ *     if ({@link migration_ctl.getNewPage} != null) {
+ *             internal_processing(...);
+ *             {@link migration_ctl.notifyResult};
+ *     }
+ */
+extern void migrate_pages_cb(struct migration_ctl *ctl, bool offlining,
+	enum migrate_mode mode);
+
 extern int migrate_huge_pages(struct list_head *l, new_page_t x,
 			unsigned long private, bool offlining,
 			enum migrate_mode mode);
diff --git a/include/linux/migrate_mode.h b/include/linux/migrate_mode.h
index ebf3d89..3256eda 100644
--- a/include/linux/migrate_mode.h
+++ b/include/linux/migrate_mode.h
@@ -8,9 +8,11 @@
  * MIGRATE_SYNC will block when migrating pages
  */
 enum migrate_mode {
-	MIGRATE_ASYNC,
-	MIGRATE_SYNC_LIGHT,
-	MIGRATE_SYNC,
+	MIGRATE_ASYNC = 1 << 0,
+	MIGRATE_SYNC_LIGHT = 1 << 1,
+	MIGRATE_SYNC = 1 << 2,
+	/** Source page is getted, by caller. */
+	MIGRATE_SRC_GETTED = 1 << 3
 };
 
 #endif		/* MIGRATE_MODE_H_INCLUDED */
diff --git a/mm/migrate.c b/mm/migrate.c
index df141f6..456f680 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -273,6 +273,7 @@ static inline bool buffer_migrate_lock_buffers(struct buffer_head *head,
  * 1 for anonymous pages without a mapping
  * 2 for pages with a mapping
  * 3 for pages with a mapping and PagePrivate/PagePrivate2 set.
+ * {@code +1} if mode has MIGRATE_SRC_GETTED setted
  */
 static int migrate_page_move_mapping(struct address_space *mapping,
 		struct page *newpage, struct page *page,
@@ -294,6 +295,9 @@ static int migrate_page_move_mapping(struct address_space *mapping,
  					page_index(page));
 
 	expected_count = 2 + page_has_private(page);
+	if (mode | MIGRATE_SRC_GETTED)
+		expected_count++;
+
 	if (page_count(page) != expected_count ||
 		radix_tree_deref_slot_protected(pslot, &mapping->tree_lock) != page) {
 		spin_unlock_irq(&mapping->tree_lock);
@@ -675,6 +679,7 @@ static int move_to_new_page(struct page *newpage, struct page *page,
 }
 
 static int __unmap_and_move(struct page *page, struct page *newpage,
+			page_mode pageMode, struct migration_ctl *ctl,
 			int force, bool offlining, enum migrate_mode mode)
 {
 	int rc = -EAGAIN;
@@ -683,6 +688,9 @@ static int __unmap_and_move(struct page *page, struct page *newpage,
 	struct mem_cgroup *mem;
 	struct anon_vma *anon_vma = NULL;
 
+	if (pageMode & PAGE_LOCKED)
+		goto skip_lock;
+
 	if (!trylock_page(page)) {
 		if (!force || mode == MIGRATE_ASYNC)
 			goto out;
@@ -706,6 +714,7 @@ static int __unmap_and_move(struct page *page, struct page *newpage,
 		lock_page(page);
 	}
 
+skip_lock:
 	/*
 	 * Only memory hotplug's offline_pages() caller has locked out KSM,
 	 * and can safely migrate a KSM page.  The other cases have skipped
@@ -830,11 +839,17 @@ out:
  */
 static int unmap_and_move(new_page_t get_new_page, unsigned long private,
 			struct page *page, int force, bool offlining,
+			page_mode pageMode, struct migration_ctl *ctl,
 			enum migrate_mode mode)
 {
 	int rc = 0;
 	int *result = NULL;
-	struct page *newpage = get_new_page(page, private, &result);
+	struct page *newpage;
+
+	if (ctl)
+		newpage = ctl->getNewPage(page, ctl);
+	else
+		newpage = get_new_page(page, private, &result);
 
 	if (!newpage)
 		return -ENOMEM;
@@ -850,7 +865,13 @@ static int unmap_and_move(new_page_t get_new_page, unsigned long private,
 		if (unlikely(split_huge_page(page)))
 			goto out;
 
-	rc = __unmap_and_move(page, newpage, force, offlining, mode);
+	rc = __unmap_and_move(page, newpage, pageMode, ctl,
+				force, offlining, mode);
+
+	if (ctl) {
+		ctl->notifyResult(page, newpage, ctl, rc);
+		goto skip_self_clean;
+	}
 out:
 	if (rc != -EAGAIN) {
 		/*
@@ -875,6 +896,8 @@ out:
 		else
 			*result = page_to_nid(newpage);
 	}
+
+skip_self_clean:
 	return rc;
 }
 
@@ -987,7 +1010,7 @@ int migrate_pages(struct list_head *from,
 
 			rc = unmap_and_move(get_new_page, private,
 						page, pass > 2, offlining,
-						mode);
+						0, NULL, mode);
 
 			switch(rc) {
 			case -ENOMEM:
@@ -1015,6 +1038,25 @@ out:
 	return nr_failed + retry;
 }
 
+extern void migrate_pages_cb(struct migration_ctl *ctl, bool offlining,
+	enum migrate_mode migrationMode)
+{
+	struct page *page;
+	page_mode pageMode;
+	const int swapwrite = current->flags & PF_SWAPWRITE;
+
+	if (!swapwrite)
+		current->flags |= PF_SWAPWRITE;
+
+	while ((page = ctl->getNextPage(ctl, &pageMode)))
+		unmap_and_move(NULL, 0, page, 0, offlining, pageMode, ctl,
+			migrationMode);
+
+	if (!swapwrite)
+		current->flags &= ~PF_SWAPWRITE;
+
+}
+
 int migrate_huge_pages(struct list_head *from,
 		new_page_t get_new_page, unsigned long private, bool offlining,
 		enum migrate_mode mode)
-- 
1.7.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
