Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f170.google.com (mail-pf0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 0CD4B6B0269
	for <linux-mm@kvack.org>; Mon, 21 Mar 2016 02:30:33 -0400 (EDT)
Received: by mail-pf0-f170.google.com with SMTP id n5so253230437pfn.2
        for <linux-mm@kvack.org>; Sun, 20 Mar 2016 23:30:33 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id kr9si10659746pab.190.2016.03.20.23.30.14
        for <linux-mm@kvack.org>;
        Sun, 20 Mar 2016 23:30:15 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v2 13/18] mm/compaction: support non-lru movable page migration
Date: Mon, 21 Mar 2016 15:31:02 +0900
Message-Id: <1458541867-27380-14-git-send-email-minchan@kernel.org>
In-Reply-To: <1458541867-27380-1-git-send-email-minchan@kernel.org>
References: <1458541867-27380-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, jlayton@poochiereds.net, bfields@fieldses.org, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, koct9i@gmail.com, aquini@redhat.com, virtualization@lists.linux-foundation.org, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Rik van Riel <riel@redhat.com>, rknize@motorola.com, Gioh Kim <gi-oh.kim@profitbricks.com>, Sangseok Lee <sangseok.lee@lge.com>, Chan Gyun Jeong <chan.jeong@lge.com>, Al Viro <viro@ZenIV.linux.org.uk>, YiPing Xu <xuyiping@hisilicon.com>, Minchan Kim <minchan@kernel.org>, dri-devel@lists.freedesktop.org, Gioh Kim <gurugio@hanmail.net>

We have allowed migration for only LRU pages until now and it was
enough to make high-order pages. But recently, embedded system(e.g.,
webOS, android) uses lots of non-movable pages(e.g., zram, GPU memory)
so we have seen several reports about troubles of small high-order
allocation. For fixing the problem, there were several efforts
(e,g,. enhance compaction algorithm, SLUB fallback to 0-order page,
reserved memory, vmalloc and so on) but if there are lots of
non-movable pages in system, their solutions are void in the long run.

So, this patch is to support facility to change non-movable pages
with movable. For the feature, this patch introduces functions related
to migration to address_space_operations as well as some page flags.

Basically, this patch supports two page-flags and two functions related
to page migration. The flag and page->mapping stability are protected
by PG_lock.

	PG_movable
	PG_isolated

	bool (*isolate_page) (struct page *, isolate_mode_t);
	void (*putback_page) (struct page *);

Duty of subsystem want to make their pages as migratable are
as follows:

1. It should register address_space to page->mapping then mark
the page as PG_movable via __SetPageMovable.

2. It should mark the page as PG_isolated via SetPageIsolated
if isolation is sucessful and return true.

3. If migration is successful, it should clear PG_isolated and
PG_movable of the page for free preparation then release the
reference of the page to free.

4. If migration fails, putback function of subsystem should
clear PG_isolated via ClearPageIsolated.

Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Hugh Dickins <hughd@google.com>
Cc: dri-devel@lists.freedesktop.org
Cc: virtualization@lists.linux-foundation.org
Signed-off-by: Gioh Kim <gurugio@hanmail.net>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 Documentation/filesystems/Locking      |   4 +
 Documentation/filesystems/vfs.txt      |   5 ++
 fs/proc/page.c                         |   3 +
 include/linux/fs.h                     |   2 +
 include/linux/migrate.h                |   2 +
 include/linux/page-flags.h             |  29 ++++++++
 include/uapi/linux/kernel-page-flags.h |   1 +
 mm/compaction.c                        |  14 +++-
 mm/migrate.c                           | 132 +++++++++++++++++++++++++++++----
 9 files changed, 177 insertions(+), 15 deletions(-)

diff --git a/Documentation/filesystems/Locking b/Documentation/filesystems/Locking
index 619af9bfdcb3..0bb79560abb3 100644
--- a/Documentation/filesystems/Locking
+++ b/Documentation/filesystems/Locking
@@ -195,7 +195,9 @@ unlocks and drops the reference.
 	int (*releasepage) (struct page *, int);
 	void (*freepage)(struct page *);
 	int (*direct_IO)(struct kiocb *, struct iov_iter *iter, loff_t offset);
+	bool (*isolate_page) (struct page *, isolate_mode_t);
 	int (*migratepage)(struct address_space *, struct page *, struct page *);
+	void (*putback_page) (struct page *);
 	int (*launder_page)(struct page *);
 	int (*is_partially_uptodate)(struct page *, unsigned long, unsigned long);
 	int (*error_remove_page)(struct address_space *, struct page *);
@@ -219,7 +221,9 @@ invalidatepage:		yes
 releasepage:		yes
 freepage:		yes
 direct_IO:
+isolate_page:		yes
 migratepage:		yes (both)
+putback_page:		yes
 launder_page:		yes
 is_partially_uptodate:	yes
 error_remove_page:	yes
diff --git a/Documentation/filesystems/vfs.txt b/Documentation/filesystems/vfs.txt
index b02a7d598258..4c1b6c3b4bc8 100644
--- a/Documentation/filesystems/vfs.txt
+++ b/Documentation/filesystems/vfs.txt
@@ -592,9 +592,14 @@ struct address_space_operations {
 	int (*releasepage) (struct page *, int);
 	void (*freepage)(struct page *);
 	ssize_t (*direct_IO)(struct kiocb *, struct iov_iter *iter, loff_t offset);
+	/* isolate a page for migration */
+	bool (*isolate_page) (struct page *, isolate_mode_t);
 	/* migrate the contents of a page to the specified target */
 	int (*migratepage) (struct page *, struct page *);
+	/* put the page back to right list */
+	void (*putback_page) (struct page *);
 	int (*launder_page) (struct page *);
+
 	int (*is_partially_uptodate) (struct page *, unsigned long,
 					unsigned long);
 	void (*is_dirty_writeback) (struct page *, bool *, bool *);
diff --git a/fs/proc/page.c b/fs/proc/page.c
index 712f1b9992cc..e2066e73a9b8 100644
--- a/fs/proc/page.c
+++ b/fs/proc/page.c
@@ -157,6 +157,9 @@ u64 stable_page_flags(struct page *page)
 	if (page_is_idle(page))
 		u |= 1 << KPF_IDLE;
 
+	if (PageMovable(page))
+		u |= 1 << KPF_MOVABLE;
+
 	u |= kpf_copy_bit(k, KPF_LOCKED,	PG_locked);
 
 	u |= kpf_copy_bit(k, KPF_SLAB,		PG_slab);
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 14a97194b34b..b7ef2e41fa4a 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -401,6 +401,8 @@ struct address_space_operations {
 	 */
 	int (*migratepage) (struct address_space *,
 			struct page *, struct page *, enum migrate_mode);
+	bool (*isolate_page)(struct page *, isolate_mode_t);
+	void (*putback_page)(struct page *);
 	int (*launder_page) (struct page *);
 	int (*is_partially_uptodate) (struct page *, unsigned long,
 					unsigned long);
diff --git a/include/linux/migrate.h b/include/linux/migrate.h
index 9b50325e4ddf..404fbfefeb33 100644
--- a/include/linux/migrate.h
+++ b/include/linux/migrate.h
@@ -37,6 +37,8 @@ extern int migrate_page(struct address_space *,
 			struct page *, struct page *, enum migrate_mode);
 extern int migrate_pages(struct list_head *l, new_page_t new, free_page_t free,
 		unsigned long private, enum migrate_mode mode, int reason);
+extern bool isolate_movable_page(struct page *page, isolate_mode_t mode);
+extern void putback_movable_page(struct page *page);
 
 extern int migrate_prep(void);
 extern int migrate_prep_local(void);
diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index f4ed4f1b0c77..3885064641c4 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -129,6 +129,10 @@ enum pageflags {
 
 	/* Compound pages. Stored in first tail page's flags */
 	PG_double_map = PG_private_2,
+
+	/* non-lru movable pages */
+	PG_movable = PG_reclaim,
+	PG_isolated = PG_owner_priv_1,
 };
 
 #ifndef __GENERATING_BOUNDS_H
@@ -614,6 +618,31 @@ static inline void __ClearPageBalloon(struct page *page)
 	atomic_set(&page->_mapcount, -1);
 }
 
+#define PAGE_MOVABLE_MAPCOUNT_VALUE (-255)
+
+static inline int PageMovable(struct page *page)
+{
+	return ((test_bit(PG_movable, &(page)->flags) &&
+		atomic_read(&page->_mapcount) == PAGE_MOVABLE_MAPCOUNT_VALUE)
+		|| PageBalloon(page));
+}
+
+/*
+ * Caller should hold a PG_lock */
+static inline void __SetPageMovable(struct page *page)
+{
+	__set_bit(PG_movable, &page->flags);
+	atomic_set(&page->_mapcount, PAGE_MOVABLE_MAPCOUNT_VALUE);
+}
+
+static inline void __ClearPageMovable(struct page *page)
+{
+	atomic_set(&page->_mapcount, -1);
+	__clear_bit(PG_movable, &(page)->flags);
+}
+
+PAGEFLAG(Isolated, isolated, PF_ANY);
+
 /*
  * If network-based swap is enabled, sl*b must keep track of whether pages
  * were allocated from pfmemalloc reserves.
diff --git a/include/uapi/linux/kernel-page-flags.h b/include/uapi/linux/kernel-page-flags.h
index 5da5f8751ce7..a184fd2434fa 100644
--- a/include/uapi/linux/kernel-page-flags.h
+++ b/include/uapi/linux/kernel-page-flags.h
@@ -34,6 +34,7 @@
 #define KPF_BALLOON		23
 #define KPF_ZERO_PAGE		24
 #define KPF_IDLE		25
+#define KPF_MOVABLE		26
 
 
 #endif /* _UAPILINUX_KERNEL_PAGE_FLAGS_H */
diff --git a/mm/compaction.c b/mm/compaction.c
index ccf97b02b85f..7557aedddaee 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -703,7 +703,7 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 
 		/*
 		 * Check may be lockless but that's ok as we recheck later.
-		 * It's possible to migrate LRU pages and balloon pages
+		 * It's possible to migrate LRU and movable kernel pages.
 		 * Skip any other type of page
 		 */
 		is_lru = PageLRU(page);
@@ -714,6 +714,18 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 					goto isolate_success;
 				}
 			}
+
+			if (unlikely(PageMovable(page)) &&
+					!PageIsolated(page)) {
+				if (locked) {
+					spin_unlock_irqrestore(&zone->lru_lock,
+									flags);
+					locked = false;
+				}
+
+				if (isolate_movable_page(page, isolate_mode))
+					goto isolate_success;
+			}
 		}
 
 		/*
diff --git a/mm/migrate.c b/mm/migrate.c
index b65c84267ce0..fc2842a15807 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -73,6 +73,75 @@ int migrate_prep_local(void)
 	return 0;
 }
 
+bool isolate_movable_page(struct page *page, isolate_mode_t mode)
+{
+	bool ret = false;
+
+	/*
+	 * Avoid burning cycles with pages that are yet under __free_pages(),
+	 * or just got freed under us.
+	 *
+	 * In case we 'win' a race for a movable page being freed under us and
+	 * raise its refcount preventing __free_pages() from doing its job
+	 * the put_page() at the end of this block will take care of
+	 * release this page, thus avoiding a nasty leakage.
+	 */
+	if (unlikely(!get_page_unless_zero(page)))
+		goto out;
+
+	/*
+	 * As movable pages are not isolated from LRU lists, concurrent
+	 * compaction threads can race against page migration functions
+	 * as well as race against the releasing a page.
+	 *
+	 * In order to avoid having an already isolated movable page
+	 * being (wrongly) re-isolated while it is under migration,
+	 * or to avoid attempting to isolate pages being released,
+	 * lets be sure we have the page lock
+	 * before proceeding with the movable page isolation steps.
+	 */
+	if (unlikely(!trylock_page(page)))
+		goto out_putpage;
+
+	if (!PageMovable(page) || PageIsolated(page))
+		goto out_no_isolated;
+
+	ret = page->mapping->a_ops->isolate_page(page, mode);
+	if (!ret)
+		goto out_no_isolated;
+
+	WARN_ON_ONCE(!PageIsolated(page));
+	unlock_page(page);
+	return ret;
+
+out_no_isolated:
+	unlock_page(page);
+out_putpage:
+	put_page(page);
+out:
+	return ret;
+}
+
+void putback_movable_page(struct page *page)
+{
+	struct address_space *mapping;
+
+	/*
+	 * 'lock_page()' stabilizes the page and prevents races against
+	 * concurrent isolation threads attempting to re-isolate it.
+	 */
+	lock_page(page);
+	mapping = page_mapping(page);
+	if (mapping) {
+		mapping->a_ops->putback_page(page);
+		WARN_ON_ONCE(PageIsolated(page));
+	}
+	unlock_page(page);
+	/* drop the extra ref count taken for movable page isolation */
+	put_page(page);
+}
+
+
 /*
  * Put previously isolated pages back onto the appropriate lists
  * from where they were once taken off for compaction/migration.
@@ -96,6 +165,8 @@ void putback_movable_pages(struct list_head *l)
 				page_is_file_cache(page));
 		if (unlikely(isolated_balloon_page(page)))
 			balloon_page_putback(page);
+		else if (unlikely(PageIsolated(page)))
+			putback_movable_page(page);
 		else
 			putback_lru_page(page);
 	}
@@ -592,7 +663,7 @@ void migrate_page_copy(struct page *newpage, struct page *page)
  ***********************************************************/
 
 /*
- * Common logic to directly migrate a single page suitable for
+ * Common logic to directly migrate a single LRU page suitable for
  * pages that do not use PagePrivate/PagePrivate2.
  *
  * Pages are locked upon entry and exit.
@@ -755,24 +826,53 @@ static int move_to_new_page(struct page *newpage, struct page *page,
 				enum migrate_mode mode)
 {
 	struct address_space *mapping;
-	int rc;
+	int rc = -EAGAIN;
+	bool isolated_lru_page;
 
 	VM_BUG_ON_PAGE(!PageLocked(page), page);
 	VM_BUG_ON_PAGE(!PageLocked(newpage), newpage);
 
 	mapping = page_mapping(page);
-	if (!mapping)
-		rc = migrate_page(mapping, newpage, page, mode);
-	else if (mapping->a_ops->migratepage)
+	/*
+	 * In case of non-lru page, it could be released after
+	 * isolation step. In that case, we shouldn't try
+	 * fallback migration which was designed for LRU pages.
+	 *
+	 * To identify such pages, we cannot use PageMovable
+	 * because owner of the page can reset it. So intead,
+	 * use PG_isolated bit.
+	 */
+	isolated_lru_page = !PageIsolated(page);
+
+	if (likely(isolated_lru_page)) {
+		if (!mapping)
+			rc = migrate_page(mapping, newpage, page, mode);
+		else if (mapping->a_ops->migratepage)
+			/*
+			 * Most pages have a mapping and most filesystems
+			 * provide a migratepage callback. Anonymous pages
+			 * are part of swap space which also has its own
+			 * migratepage callback. This is the most common path
+			 * for page migration.
+			 */
+			rc = mapping->a_ops->migratepage(mapping, newpage,
+							page, mode);
+		else
+			rc = fallback_migrate_page(mapping, newpage,
+							page, mode);
+	} else {
 		/*
-		 * Most pages have a mapping and most filesystems provide a
-		 * migratepage callback. Anonymous pages are part of swap
-		 * space which also has its own migratepage callback. This
-		 * is the most common path for page migration.
+		 * If mapping is NULL, it returns -EAGAIN so retrial
+		 * of migration will see refcount as 1 and free it,
+		 * finally.
 		 */
-		rc = mapping->a_ops->migratepage(mapping, newpage, page, mode);
-	else
-		rc = fallback_migrate_page(mapping, newpage, page, mode);
+		if (mapping) {
+			rc = mapping->a_ops->migratepage(mapping, newpage,
+							page, mode);
+			WARN_ON_ONCE(rc == MIGRATEPAGE_SUCCESS &&
+				PageIsolated(page));
+		}
+	}
 
 	/*
 	 * When successful, old pagecache page->mapping must be cleared before
@@ -1000,8 +1100,12 @@ static ICE_noinline int unmap_and_move(new_page_t get_new_page,
 				num_poisoned_pages_inc();
 		}
 	} else {
-		if (rc != -EAGAIN)
-			putback_lru_page(page);
+		if (rc != -EAGAIN) {
+			if (likely(!PageIsolated(page)))
+				putback_lru_page(page);
+			else
+				putback_movable_page(page);
+		}
 		if (put_new_page)
 			put_new_page(newpage, private);
 		else
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
