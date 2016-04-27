Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7C2B06B025E
	for <linux-mm@kvack.org>; Wed, 27 Apr 2016 03:47:22 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id 203so67142983pfy.2
        for <linux-mm@kvack.org>; Wed, 27 Apr 2016 00:47:22 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id kj7si3978492pab.136.2016.04.27.00.47.20
        for <linux-mm@kvack.org>;
        Wed, 27 Apr 2016 00:47:21 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v4 02/12] mm: migrate: support non-lru movable page migration
Date: Wed, 27 Apr 2016 16:48:15 +0900
Message-Id: <1461743305-19970-3-git-send-email-minchan@kernel.org>
In-Reply-To: <1461743305-19970-1-git-send-email-minchan@kernel.org>
References: <1461743305-19970-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Rafael Aquini <aquini@redhat.com>, virtualization@lists.linux-foundation.org, Jonathan Corbet <corbet@lwn.net>, John Einar Reitan <john.reitan@foss.arm.com>, dri-devel@lists.freedesktop.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Gioh Kim <gi-oh.kim@profitbricks.com>

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

If a driver want to make own pages movable, it should define three functions
which are function pointers of struct address_space_operations.

1. bool (*isolate_page) (struct page *page, isolate_mode_t mode);

What VM expects on isolate_page function of driver is to return *true*
if driver isolates page successfully. On returing true, VM marks the page
as PG_isolated so concurrent isolation in several CPUs skip the page
for isolation. If a driver cannot isolate the page, it should return *false*.

Once page is successfully isolated, VM uses page.lru fields so driver
shouldn't expect to preserve values in that fields.

2. int (*migratepage) (struct address_space *mapping,
		struct page *newpage, struct page *oldpage, enum migrate_mode);

After isolation, VM calls migratepage of driver with isolated page.
The function of migratepage is to move content of the old page to new page
and set up fields of struct page newpage. Keep in mind that you should
clear PG_movable of oldpage via __ClearPageMovable under page_lock if you
migrated the oldpage successfully and returns MIGRATEPAGE_SUCCESS.
If driver cannot migrate the page at the moment, driver can return -EAGAIN.
On -EAGAIN, VM will retry page migration in a short time because VM interprets
-EAGAIN as "temporal migration failure". On returning any error except -EAGAIN,
VM will give up the page migration without retrying in this time.

Driver shouldn't touch page.lru field VM using in the functions.

3. void (*putback_page)(struct page *);

If migration fails on isolated page, VM should return the isolated page
to the driver so VM calls driver's putback_page with migration failed page.
In this function, driver should put the isolated page back to the own data
structure.

4. non-lru movable page flags

There are two page flags for supporting non-lru movable page.

* PG_movable

Driver should use the below function to make page movable under page_lock.

	void __SetPageMovable(struct page *page, struct address_space *mapping)

It needs argument of address_space for registering migration family functions
which will be called by VM. Exactly speaking, PG_movable is not a real flag of
struct page. Rather than, VM reuses page->mapping's lower bits to represent it.

	#define PAGE_MAPPING_MOVABLE 0x2
	page->mapping = page->mapping | PAGE_MAPPING_MOVABLE;

so driver shouldn't access page->mapping directly. Instead, driver should
use page_mapping which mask off the low two bits of page->mapping so it can get
right struct address_space.

For testing of non-lru movable page, VM supports __PageMovable function.
However, it doesn't guarantee to identify non-lru movable page because
page->mapping field is unified with other variables in struct page.
As well, if driver releases the page after isolation by VM, page->mapping
doesn't have stable value although it has PAGE_MAPPING_MOVABLE
(Look at __ClearPageMovable). But __PageMovable is cheap to catch whether
page is LRU or non-lru movable once the page has been isolated. Because
LRU pages never can have PAGE_MAPPING_MOVABLE in page->mapping. It is also
good for just peeking to test non-lru movable pages before more expensive
checking with lock_page in pfn scanning to select victim.

For guaranteeing non-lru movable page, VM provides PageMovable function.
Unlike __PageMovable, PageMovable functions validates page->mapping and
mapping->a_ops->isolate_page under lock_page. The lock_page prevents sudden
destroying of page->mapping.

Driver using __SetPageMovable should clear the flag via __ClearMovablePage
under page_lock before the releasing the page.

* PG_isolated

To prevent concurrent isolation among several CPUs, VM marks isolated page
as PG_isolated under lock_page. So if a CPU encounters PG_isolated non-lru
movable page, it can skip it. Driver doesn't need to manipulate the flag
because VM will set/clear it automatically. Keep in mind that if driver
sees PG_isolated page, it means the page have been isolated by VM so it
shouldn't touch page.lru field.
PG_isolated is alias with PG_reclaim flag so driver shouldn't use the flag
for own purpose.

Cc: Rik van Riel <riel@redhat.com>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Hugh Dickins <hughd@google.com>
Cc: Rafael Aquini <aquini@redhat.com>
Cc: virtualization@lists.linux-foundation.org
Cc: Jonathan Corbet <corbet@lwn.net>
Cc: John Einar Reitan <john.reitan@foss.arm.com>
Cc: dri-devel@lists.freedesktop.org
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Signed-off-by: Gioh Kim <gi-oh.kim@profitbricks.com>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 Documentation/filesystems/Locking |   4 +
 Documentation/filesystems/vfs.txt |  11 ++
 Documentation/vm/page_migration   | 107 +++++++++++++++++-
 include/linux/fs.h                |   2 +
 include/linux/ksm.h               |   3 +-
 include/linux/migrate.h           |   5 +
 include/linux/mm.h                |   1 +
 include/linux/page-flags.h        |  23 +++-
 mm/compaction.c                   |  47 +++++---
 mm/ksm.c                          |   4 +-
 mm/migrate.c                      | 222 ++++++++++++++++++++++++++++++++++----
 mm/page_alloc.c                   |   4 +-
 mm/util.c                         |   6 +-
 13 files changed, 390 insertions(+), 49 deletions(-)

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
index 4164bd6397a2..4fa8f54d94c8 100644
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
+	/* put migration-failed page back to right list */
+	void (*putback_page) (struct page *);
 	int (*launder_page) (struct page *);
+
 	int (*is_partially_uptodate) (struct page *, unsigned long,
 					unsigned long);
 	void (*is_dirty_writeback) (struct page *, bool *, bool *);
@@ -747,6 +752,10 @@ struct address_space_operations {
         and transfer data directly between the storage and the
         application's address space.
 
+  isolate_page: Called by the VM when isolating a movable non-lru page.
+	If page is successfully isolated, VM marks the page as PG_isolated
+	via __SetPageIsolated.
+
   migrate_page:  This is used to compact the physical memory usage.
         If the VM wants to relocate a page (maybe off a memory card
         that is signalling imminent failure) it will pass a new page
@@ -754,6 +763,8 @@ struct address_space_operations {
 	transfer any private data across and update any references
         that it has to the page.
 
+  putback_page: Called by the VM when isolated page's migration fails.
+
   launder_page: Called before freeing a page - it writes back the dirty page. To
   	prevent redirtying the page, it is kept locked during the whole
 	operation.
diff --git a/Documentation/vm/page_migration b/Documentation/vm/page_migration
index fea5c0864170..b89d1de026df 100644
--- a/Documentation/vm/page_migration
+++ b/Documentation/vm/page_migration
@@ -142,5 +142,110 @@ is increased so that the page cannot be freed while page migration occurs.
 20. The new page is moved to the LRU and can be scanned by the swapper
     etc again.
 
-Christoph Lameter, May 8, 2006.
+C. Non-LRU page migration
+-------------------------
+
+Although original migration aimed for reducing the latency of memory access
+for NUMA, compaction who want to create high-order page is also main customer.
+
+Current problem of the implementation is that it is designed to migrate only
+*LRU* pages. However, there are potential non-lru pages which can be migrated
+in drivers, for example, zsmalloc, virtio-balloon pages.
+
+For virtio-balloon pages, some parts of migration code path have been hooked
+up and added virtio-balloon specific functions to intercept migration logics.
+It's too specific to a driver so other drivers who want to make their pages
+movable would have to add own specific hooks in migration path.
+
+To overclome the problem, VM supports non-LRU page migration which provides
+generic functions for non-LRU movable pages without driver specific hooks
+migration path.
+
+If a driver want to make own pages movable, it should define three functions
+which are function pointers of struct address_space_operations.
+
+1. bool (*isolate_page) (struct page *page, isolate_mode_t mode);
+
+What VM expects on isolate_page function of driver is to return *true*
+if driver isolates page successfully. On returing true, VM marks the page
+as PG_isolated so concurrent isolation in several CPUs skip the page
+for isolation. If a driver cannot isolate the page, it should return *false*.
+
+Once page is successfully isolated, VM uses page.lru fields so driver
+shouldn't expect to preserve values in that fields.
+
+2. int (*migratepage) (struct address_space *mapping,
+		struct page *newpage, struct page *oldpage, enum migrate_mode);
+
+After isolation, VM calls migratepage of driver with isolated page.
+The function of migratepage is to move content of the old page to new page
+and set up fields of struct page newpage. Keep in mind that you should
+clear PG_movable of oldpage via __ClearPageMovable under page_lock if you
+migrated the oldpage successfully and returns MIGRATEPAGE_SUCCESS.
+If driver cannot migrate the page at the moment, driver can return -EAGAIN.
+On -EAGAIN, VM will retry page migration in a short time because VM interprets
+-EAGAIN as "temporal migration failure". On returning any error except -EAGAIN,
+VM will give up the page migration without retrying in this time.
+
+Driver shouldn't touch page.lru field VM using in the functions.
+
+3. void (*putback_page)(struct page *);
+
+If migration fails on isolated page, VM should return the isolated page
+to the driver so VM calls driver's putback_page with migration failed page.
+In this function, driver should put the isolated page back to the own data
+structure.
 
+4. non-lru movable page flags
+
+There are two page flags for supporting non-lru movable page.
+
+* PG_movable
+
+Driver should use the below function to make page movable under page_lock.
+
+	void __SetPageMovable(struct page *page, struct address_space *mapping)
+
+It needs argument of address_space for registering migration family functions
+which will be called by VM. Exactly speaking, PG_movable is not a real flag of
+struct page. Rather than, VM reuses page->mapping's lower bits to represent it.
+
+	#define PAGE_MAPPING_MOVABLE 0x2
+	page->mapping = page->mapping | PAGE_MAPPING_MOVABLE;
+
+so driver shouldn't access page->mapping directly. Instead, driver should
+use page_mapping which mask off the low two bits of page->mapping so it can get
+right struct address_space.
+
+For testing of non-lru movable page, VM supports __PageMovable function.
+However, it doesn't guarantee to identify non-lru movable page because
+page->mapping field is unified with other variables in struct page.
+As well, if driver releases the page after isolation by VM, page->mapping
+doesn't have stable value although it has PAGE_MAPPING_MOVABLE
+(Look at __ClearPageMovable). But __PageMovable is cheap to catch whether
+page is LRU or non-lru movable once the page has been isolated. Because
+LRU pages never can have PAGE_MAPPING_MOVABLE in page->mapping. It is also
+good for just peeking to test non-lru movable pages before more expensive
+checking with lock_page in pfn scanning to select victim.
+
+For guaranteeing non-lru movable page, VM provides PageMovable function.
+Unlike __PageMovable, PageMovable functions validates page->mapping and
+mapping->a_ops->isolate_page under lock_page. The lock_page prevents sudden
+destroying of page->mapping.
+
+Driver using __SetPageMovable should clear the flag via __ClearMovablePage
+under page_lock before the releasing the page.
+
+* PG_isolated
+
+To prevent concurrent isolation among several CPUs, VM marks isolated page
+as PG_isolated under lock_page. So if a CPU encounters PG_isolated non-lru
+movable page, it can skip it. Driver doesn't need to manipulate the flag
+because VM will set/clear it automatically. Keep in mind that if driver
+sees PG_isolated page, it means the page have been isolated by VM so it
+shouldn't touch page.lru field.
+PG_isolated is alias with PG_reclaim flag so driver shouldn't use the flag
+for own purpose.
+
+Christoph Lameter, May 8, 2006.
+Minchan Kim, Mar 28, 2016.
diff --git a/include/linux/fs.h b/include/linux/fs.h
index e3c0b7e54d47..e520d365adf6 100644
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
diff --git a/include/linux/ksm.h b/include/linux/ksm.h
index 7ae216a39c9e..481c8c4627ca 100644
--- a/include/linux/ksm.h
+++ b/include/linux/ksm.h
@@ -43,8 +43,7 @@ static inline struct stable_node *page_stable_node(struct page *page)
 static inline void set_page_stable_node(struct page *page,
 					struct stable_node *stable_node)
 {
-	page->mapping = (void *)stable_node +
-				(PAGE_MAPPING_ANON | PAGE_MAPPING_KSM);
+	page->mapping = (void *)((unsigned long)stable_node | PAGE_MAPPING_KSM);
 }
 
 /*
diff --git a/include/linux/migrate.h b/include/linux/migrate.h
index f087653baf94..9365858db978 100644
--- a/include/linux/migrate.h
+++ b/include/linux/migrate.h
@@ -34,11 +34,16 @@ extern char *migrate_reason_names[MR_TYPES];
 
 #ifdef CONFIG_MIGRATION
 
+extern int PageMovable(struct page *page);
+extern void __SetPageMovable(struct page *page, struct address_space *mapping);
+extern void __ClearPageMovable(struct page *page);
 extern void putback_movable_pages(struct list_head *l);
 extern int migrate_page(struct address_space *,
 			struct page *, struct page *, enum migrate_mode);
 extern int migrate_pages(struct list_head *l, new_page_t new, free_page_t free,
 		unsigned long private, enum migrate_mode mode, int reason);
+extern bool isolate_movable_page(struct page *page, isolate_mode_t mode);
+extern void putback_movable_page(struct page *page);
 
 extern int migrate_prep(void);
 extern int migrate_prep_local(void);
diff --git a/include/linux/mm.h b/include/linux/mm.h
index ebc23193f556..d1095c8ea851 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1021,6 +1021,7 @@ static inline pgoff_t page_file_index(struct page *page)
 }
 
 bool page_mapped(struct page *page);
+struct address_space *page_mapping(struct page *page);
 
 /*
  * Return true only if the page has been allocated with
diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index 36e3a3fa41b2..079a90ceae75 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -132,6 +132,9 @@ enum pageflags {
 
 	/* Compound pages. Stored in first tail page's flags */
 	PG_double_map = PG_private_2,
+
+	/* non-lru isolated movable page */
+	PG_isolated = PG_reclaim,
 };
 
 #ifndef __GENERATING_BOUNDS_H
@@ -367,15 +370,17 @@ PAGEFLAG(Idle, idle, PF_ANY)
  * and then page->mapping points, not to an anon_vma, but to a private
  * structure which KSM associates with that merged page.  See ksm.h.
  *
- * PAGE_MAPPING_KSM without PAGE_MAPPING_ANON is currently never used.
+ * PAGE_MAPPING_KSM without PAGE_MAPPING_ANON is used for non-lru movable
+ * page and then page->mapping points a struct address_space.
  *
  * Please note that, confusingly, "page_mapping" refers to the inode
  * address_space which maps the page from disk; whereas "page_mapped"
  * refers to user virtual address space into which the page is mapped.
  */
-#define PAGE_MAPPING_ANON	1
-#define PAGE_MAPPING_KSM	2
-#define PAGE_MAPPING_FLAGS	(PAGE_MAPPING_ANON | PAGE_MAPPING_KSM)
+#define PAGE_MAPPING_ANON	0x1
+#define PAGE_MAPPING_MOVABLE	0x2
+#define PAGE_MAPPING_KSM	(PAGE_MAPPING_ANON | PAGE_MAPPING_MOVABLE)
+#define PAGE_MAPPING_FLAGS	(PAGE_MAPPING_ANON | PAGE_MAPPING_MOVABLE)
 
 static __always_inline int PageAnon(struct page *page)
 {
@@ -383,6 +388,12 @@ static __always_inline int PageAnon(struct page *page)
 	return ((unsigned long)page->mapping & PAGE_MAPPING_ANON) != 0;
 }
 
+static __always_inline int __PageMovable(struct page *page)
+{
+	return ((unsigned long)page->mapping & PAGE_MAPPING_FLAGS) ==
+				PAGE_MAPPING_MOVABLE;
+}
+
 #ifdef CONFIG_KSM
 /*
  * A KSM page is one of those write-protected "shared pages" or "merged pages"
@@ -394,7 +405,7 @@ static __always_inline int PageKsm(struct page *page)
 {
 	page = compound_head(page);
 	return ((unsigned long)page->mapping & PAGE_MAPPING_FLAGS) ==
-				(PAGE_MAPPING_ANON | PAGE_MAPPING_KSM);
+				PAGE_MAPPING_KSM;
 }
 #else
 TESTPAGEFLAG_FALSE(Ksm)
@@ -624,6 +635,8 @@ static inline void __ClearPageBalloon(struct page *page)
 	atomic_set(&page->_mapcount, -1);
 }
 
+__PAGEFLAG(Isolated, isolated, PF_ANY);
+
 /*
  * If network-based swap is enabled, sl*b must keep track of whether pages
  * were allocated from pfmemalloc reserves.
diff --git a/mm/compaction.c b/mm/compaction.c
index 2f31c3769a8e..01789ebc4b10 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -740,21 +740,6 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 		}
 
 		/*
-		 * Check may be lockless but that's ok as we recheck later.
-		 * It's possible to migrate LRU pages and balloon pages
-		 * Skip any other type of page
-		 */
-		is_lru = PageLRU(page);
-		if (!is_lru) {
-			if (unlikely(balloon_page_movable(page))) {
-				if (balloon_page_isolate(page)) {
-					/* Successfully isolated */
-					goto isolate_success;
-				}
-			}
-		}
-
-		/*
 		 * Regardless of being on LRU, compound pages such as THP and
 		 * hugetlbfs are not to be compacted. We can potentially save
 		 * a lot of iterations if we skip them at once. The check is
@@ -770,8 +755,38 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 			goto isolate_fail;
 		}
 
-		if (!is_lru)
+		/*
+		 * Check may be lockless but that's ok as we recheck later.
+		 * It's possible to migrate LRU and non-lru movable pages.
+		 * Skip any other type of page
+		 */
+		is_lru = PageLRU(page);
+		if (!is_lru) {
+			if (unlikely(balloon_page_movable(page))) {
+				if (balloon_page_isolate(page)) {
+					/* Successfully isolated */
+					goto isolate_success;
+				}
+			}
+
+			/*
+			 * __PageMovable can return false positive so we need
+			 * to verify it under page_lock.
+			 */
+			if (unlikely(__PageMovable(page)) &&
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
+
 			goto isolate_fail;
+		}
 
 		/*
 		 * Migration will fail if an anonymous page is pinned in memory,
diff --git a/mm/ksm.c b/mm/ksm.c
index 3dee82e3f59a..647c3a446d35 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -658,8 +658,8 @@ static struct page *get_ksm_page(struct stable_node *stable_node, bool lock_it)
 	void *expected_mapping;
 	unsigned long kpfn;
 
-	expected_mapping = (void *)stable_node +
-				(PAGE_MAPPING_ANON | PAGE_MAPPING_KSM);
+	expected_mapping = (void *)((unsigned long)stable_node |
+					PAGE_MAPPING_KSM);
 again:
 	kpfn = READ_ONCE(stable_node->kpfn);
 	page = pfn_to_page(kpfn);
diff --git a/mm/migrate.c b/mm/migrate.c
index 7880f30d1d3d..b2ababa21440 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -48,6 +48,38 @@
 
 #include "internal.h"
 
+int PageMovable(struct page *page)
+{
+	struct address_space *mapping;
+
+	WARN_ON(!PageLocked(page));
+	if (!__PageMovable(page))
+		goto out;
+
+	mapping = page_mapping(page);
+	if (mapping && mapping->a_ops && mapping->a_ops->isolate_page)
+		return 1;
+out:
+	return 0;
+}
+
+void __SetPageMovable(struct page *page, struct address_space *mapping)
+{
+	VM_BUG_ON_PAGE(!PageLocked(page), page);
+	VM_BUG_ON_PAGE((unsigned long)mapping & PAGE_MAPPING_MOVABLE, page);
+	page->mapping = (void *)((unsigned long)mapping | PAGE_MAPPING_MOVABLE);
+}
+
+void __ClearPageMovable(struct page *page)
+{
+	VM_BUG_ON_PAGE(!PageLocked(page), page);
+	VM_BUG_ON_PAGE(!PageMovable(page), page);
+	VM_BUG_ON_PAGE(!((unsigned long)page->mapping & PAGE_MAPPING_MOVABLE),
+				page);
+	page->mapping = (void *)((unsigned long)page->mapping &
+				PAGE_MAPPING_MOVABLE);
+}
+
 /*
  * migrate_prep() needs to be called before we start compiling a list of pages
  * to be migrated using isolate_lru_page(). If scheduling work on other CPUs is
@@ -74,6 +106,79 @@ int migrate_prep_local(void)
 	return 0;
 }
 
+bool isolate_movable_page(struct page *page, isolate_mode_t mode)
+{
+	struct address_space *mapping;
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
+	 * Check PageMovable before holding a PG_lock because page's owner
+	 * assumes anybody doesn't touch PG_lock of newly allocated page
+	 * so unconditionally grapping the lock ruins page's owner side.
+	 */
+	if (unlikely(!__PageMovable(page)))
+		goto out_putpage;
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
+	mapping = page_mapping(page);
+	if (!mapping->a_ops->isolate_page(page, mode))
+		goto out_no_isolated;
+
+	/* Driver shouldn't use PG_isolated bit of page->flags */
+	WARN_ON_ONCE(PageIsolated(page));
+	__SetPageIsolated(page);
+	unlock_page(page);
+
+	return true;
+
+out_no_isolated:
+	unlock_page(page);
+out_putpage:
+	put_page(page);
+out:
+	return false;
+}
+
+/* It should be called on page which is PG_movable */
+void putback_movable_page(struct page *page)
+{
+	struct address_space *mapping;
+
+	VM_BUG_ON_PAGE(!PageLocked(page), page);
+	VM_BUG_ON_PAGE(!PageMovable(page), page);
+	VM_BUG_ON_PAGE(!PageIsolated(page), page);
+
+	mapping = page_mapping(page);
+	mapping->a_ops->putback_page(page);
+	__ClearPageIsolated(page);
+}
+
 /*
  * Put previously isolated pages back onto the appropriate lists
  * from where they were once taken off for compaction/migration.
@@ -95,10 +200,25 @@ void putback_movable_pages(struct list_head *l)
 		list_del(&page->lru);
 		dec_zone_page_state(page, NR_ISOLATED_ANON +
 				page_is_file_cache(page));
-		if (unlikely(isolated_balloon_page(page)))
+		if (unlikely(isolated_balloon_page(page))) {
 			balloon_page_putback(page);
-		else
+		/*
+		 * We isolated non-lru movable page so here we can use
+		 * __PageMovable because LRU page's mapping cannot have
+		 * PAGE_MAPPING_MOVABLE.
+		 */
+		} else if (unlikely(__PageMovable(page))) {
+			VM_BUG_ON_PAGE(!PageIsolated(page), page);
+			lock_page(page);
+			if (PageMovable(page))
+				putback_movable_page(page);
+			else
+				__ClearPageIsolated(page);
+			unlock_page(page);
+			put_page(page);
+		} else {
 			putback_lru_page(page);
+		}
 	}
 }
 
@@ -601,7 +721,7 @@ void migrate_page_copy(struct page *newpage, struct page *page)
  ***********************************************************/
 
 /*
- * Common logic to directly migrate a single page suitable for
+ * Common logic to directly migrate a single LRU page suitable for
  * pages that do not use PagePrivate/PagePrivate2.
  *
  * Pages are locked upon entry and exit.
@@ -764,33 +884,69 @@ static int move_to_new_page(struct page *newpage, struct page *page,
 				enum migrate_mode mode)
 {
 	struct address_space *mapping;
-	int rc;
+	int rc = -EAGAIN;
+	bool is_lru = !__PageMovable(page);
 
 	VM_BUG_ON_PAGE(!PageLocked(page), page);
 	VM_BUG_ON_PAGE(!PageLocked(newpage), newpage);
 
 	mapping = page_mapping(page);
-	if (!mapping)
-		rc = migrate_page(mapping, newpage, page, mode);
-	else if (mapping->a_ops->migratepage)
-		/*
-		 * Most pages have a mapping and most filesystems provide a
-		 * migratepage callback. Anonymous pages are part of swap
-		 * space which also has its own migratepage callback. This
-		 * is the most common path for page migration.
-		 */
-		rc = mapping->a_ops->migratepage(mapping, newpage, page, mode);
-	else
-		rc = fallback_migrate_page(mapping, newpage, page, mode);
+	/*
+	 * In case of non-lru page, it could be released after
+	 * isolation step. In that case, we shouldn't try
+	 * fallback migration which is designed for LRU pages.
+	 */
+	if (unlikely(!is_lru)) {
+		VM_BUG_ON_PAGE(!PageIsolated(page), page);
+		if (!PageMovable(page)) {
+			rc = MIGRATEPAGE_SUCCESS;
+			__ClearPageIsolated(page);
+			goto out;
+		}
+	}
+
+	if (likely(is_lru)) {
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
+		rc = mapping->a_ops->migratepage(mapping, newpage,
+						page, mode);
+		WARN_ON_ONCE(rc == MIGRATEPAGE_SUCCESS &&
+			!PageIsolated(page));
+	}
 
 	/*
 	 * When successful, old pagecache page->mapping must be cleared before
 	 * page is freed; but stats require that PageAnon be left as PageAnon.
 	 */
 	if (rc == MIGRATEPAGE_SUCCESS) {
-		if (!PageAnon(page))
+		if (__PageMovable(page)) {
+			VM_BUG_ON_PAGE(!PageIsolated(page), page);
+
+			/*
+			 * We clear PG_movable under page_lock so any compactor
+			 * cannot try to migrate this page.
+			 */
+			__ClearPageIsolated(page);
+		}
+
+		if (!((unsigned long)page->mapping & PAGE_MAPPING_FLAGS))
 			page->mapping = NULL;
 	}
+out:
 	return rc;
 }
 
@@ -800,6 +956,7 @@ static int __unmap_and_move(struct page *page, struct page *newpage,
 	int rc = -EAGAIN;
 	int page_was_mapped = 0;
 	struct anon_vma *anon_vma = NULL;
+	bool is_lru = !__PageMovable(page);
 
 	if (!trylock_page(page)) {
 		if (!force || mode == MIGRATE_ASYNC)
@@ -891,6 +1048,11 @@ static int __unmap_and_move(struct page *page, struct page *newpage,
 		goto out_unlock_both;
 	}
 
+	if (unlikely(!is_lru)) {
+		rc = move_to_new_page(newpage, page, mode);
+		goto out_unlock_both;
+	}
+
 	/*
 	 * Corner case handling:
 	 * 1. When a new swap-cache page is read into, it is added to the LRU
@@ -940,7 +1102,8 @@ static int __unmap_and_move(struct page *page, struct page *newpage,
 	 * list in here.
 	 */
 	if (rc == MIGRATEPAGE_SUCCESS) {
-		if (unlikely(__is_movable_balloon_page(newpage)))
+		if (unlikely(__is_movable_balloon_page(newpage) ||
+				__PageMovable(newpage)))
 			put_page(newpage);
 		else
 			putback_lru_page(newpage);
@@ -986,6 +1149,12 @@ static ICE_noinline int unmap_and_move(new_page_t get_new_page,
 		/* page was freed from under us. So we are done. */
 		ClearPageActive(page);
 		ClearPageUnevictable(page);
+		if (unlikely(__PageMovable(page))) {
+			lock_page(page);
+			if (!PageMovable(page))
+				__ClearPageIsolated(page);
+			unlock_page(page);
+		}
 		if (put_new_page)
 			put_new_page(newpage, private);
 		else
@@ -1035,8 +1204,21 @@ static ICE_noinline int unmap_and_move(new_page_t get_new_page,
 				num_poisoned_pages_inc();
 		}
 	} else {
-		if (rc != -EAGAIN)
-			putback_lru_page(page);
+		if (rc != -EAGAIN) {
+			if (likely(!__PageMovable(page))) {
+				putback_lru_page(page);
+				goto put_new;
+			}
+
+			lock_page(page);
+			if (PageMovable(page))
+				putback_movable_page(page);
+			else
+				__ClearPageIsolated(page);
+			unlock_page(page);
+			put_page(page);
+		}
+put_new:
 		if (put_new_page)
 			put_new_page(newpage, private);
 		else
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 226db261215a..4af78fa1e665 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1034,8 +1034,10 @@ static bool free_pages_prepare(struct page *page, unsigned int order)
 	kmemcheck_free_shadow(page, order);
 	kasan_poison_free_pages(page, order);
 
-	if (PageAnon(page))
+	/* If PageAnon or __PageMovable is true, clear page->mapping */
+	if ((unsigned long)page->mapping & PAGE_MAPPING_FLAGS)
 		page->mapping = NULL;
+
 	bad += free_pages_check(page);
 	for (i = 1; i < (1 << order); i++) {
 		if (compound)
diff --git a/mm/util.c b/mm/util.c
index 23025c8ad31f..732cf3c74646 100644
--- a/mm/util.c
+++ b/mm/util.c
@@ -398,10 +398,12 @@ struct address_space *page_mapping(struct page *page)
 	}
 
 	mapping = page->mapping;
-	if ((unsigned long)mapping & PAGE_MAPPING_FLAGS)
+	if ((unsigned long)mapping & PAGE_MAPPING_ANON)
 		return NULL;
-	return mapping;
+
+	return (void *)((unsigned long)mapping & ~PAGE_MAPPING_FLAGS);
 }
+EXPORT_SYMBOL(page_mapping);
 
 /* Slow path of page_mapcount() for compound pages */
 int __page_mapcount(struct page *page)
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
