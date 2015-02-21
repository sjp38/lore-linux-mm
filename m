Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 7BE0D6B0032
	for <linux-mm@kvack.org>; Fri, 20 Feb 2015 23:07:58 -0500 (EST)
Received: by paceu11 with SMTP id eu11so12856373pac.7
        for <linux-mm@kvack.org>; Fri, 20 Feb 2015 20:07:58 -0800 (PST)
Received: from mail-pd0-x22b.google.com (mail-pd0-x22b.google.com. [2607:f8b0:400e:c02::22b])
        by mx.google.com with ESMTPS id gv5si7924137pac.200.2015.02.20.20.07.57
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Feb 2015 20:07:57 -0800 (PST)
Received: by pdev10 with SMTP id v10so12035645pde.7
        for <linux-mm@kvack.org>; Fri, 20 Feb 2015 20:07:57 -0800 (PST)
Date: Fri, 20 Feb 2015 20:07:55 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 10/24] huge tmpfs: avoid team pages in a few places
In-Reply-To: <alpine.LSU.2.11.1502201941340.14414@eggly.anvils>
Message-ID: <alpine.LSU.2.11.1502202006310.14414@eggly.anvils>
References: <alpine.LSU.2.11.1502201941340.14414@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Ning Qu <quning@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

A few functions outside of mm/shmem.c must take care not to damage a
team accidentally.  In particular, although huge tmpfs will make its
own use of page migration, we don't want compaction or other users
of page migration to stomp on teams by mistake: a backstop check
in unmap_and_move() secures most cases, and an earlier check in
isolate_migratepages_block() saves compaction from wasting time.

These checks are certainly too strong: we shall want NUMA mempolicy
and balancing, and memory hot-remove, and soft-offline of failing
memory, to work with team pages; but defer those to a later series,
probably to be implemented along with rebanding disbanded teams (to
recover their original performance once memory pressure is relieved).

However, a PageTeam test is often not sufficient: because PG_team
is shared with PG_compound_lock, there's a danger that a momentarily
compound-locked page will look as if PageTeam.  (And places in shmem.c
where we check PageTeam(head) when that head might already be freed
and reused for a smaller compound page.)

Mostly use !PageAnon to check for this: !PageHead can also work, but
there's an instant in __split_huge_page_refcount() when PageHead is
cleared before the compound_unlock() - the durability of PageAnon is
easier to think about.

Hoist the declaration of PageAnon (and its associated definitions) in
linux/mm.h up before the declaration of __compound_tail_refcounted()
to facilitate this: compound tail refcounting (and compound locking)
is only necessary if the head is perhaps anonymous THP, so PageAnon.

Of course, the danger of confusion between PG_compound_lock and
PG_team could more easily be addressed by assigning a separate page
flag bit for PageTeam; but I'm reluctant to ask for that, and in the
longer term hopeful that PG_compound_lock can be removed altogether.

Signed-off-by: Hugh Dickins <hughd@google.com>
---
 include/linux/mm.h |   92 +++++++++++++++++++++----------------------
 mm/compaction.c    |    6 ++
 mm/memcontrol.c    |    4 -
 mm/migrate.c       |   12 +++++
 mm/truncate.c      |    2 
 mm/vmscan.c        |    2 
 6 files changed, 68 insertions(+), 50 deletions(-)

--- thpfs.orig/include/linux/mm.h	2015-02-08 18:54:22.000000000 -0800
+++ thpfs/include/linux/mm.h	2015-02-20 19:34:11.231993296 -0800
@@ -473,6 +473,48 @@ static inline int page_count(struct page
 	return atomic_read(&compound_head(page)->_count);
 }
 
+/*
+ * On an anonymous page mapped into a user virtual memory area,
+ * page->mapping points to its anon_vma, not to a struct address_space;
+ * with the PAGE_MAPPING_ANON bit set to distinguish it.  See rmap.h.
+ *
+ * On an anonymous page in a VM_MERGEABLE area, if CONFIG_KSM is enabled,
+ * the PAGE_MAPPING_KSM bit may be set along with the PAGE_MAPPING_ANON bit;
+ * and then page->mapping points, not to an anon_vma, but to a private
+ * structure which KSM associates with that merged page.  See ksm.h.
+ *
+ * PAGE_MAPPING_KSM without PAGE_MAPPING_ANON is currently never used.
+ *
+ * Please note that, confusingly, "page_mapping" refers to the inode
+ * address_space which maps the page from disk; whereas "page_mapped"
+ * refers to user virtual address space into which the page is mapped.
+ */
+#define PAGE_MAPPING_ANON	1
+#define PAGE_MAPPING_KSM	2
+#define PAGE_MAPPING_FLAGS	(PAGE_MAPPING_ANON | PAGE_MAPPING_KSM)
+
+extern struct address_space *page_mapping(struct page *page);
+
+/* Neutral page->mapping pointer to address_space or anon_vma or other */
+static inline void *page_rmapping(struct page *page)
+{
+	return (void *)((unsigned long)page->mapping & ~PAGE_MAPPING_FLAGS);
+}
+
+extern struct address_space *__page_file_mapping(struct page *);
+
+static inline struct address_space *page_file_mapping(struct page *page)
+{
+	if (unlikely(PageSwapCache(page)))
+		return __page_file_mapping(page);
+	return page->mapping;
+}
+
+static inline int PageAnon(struct page *page)
+{
+	return ((unsigned long)page->mapping & PAGE_MAPPING_ANON) != 0;
+}
+
 #ifdef CONFIG_HUGETLB_PAGE
 extern int PageHeadHuge(struct page *page_head);
 #else /* CONFIG_HUGETLB_PAGE */
@@ -484,15 +526,15 @@ static inline int PageHeadHuge(struct pa
 
 static inline bool __compound_tail_refcounted(struct page *page)
 {
-	return !PageSlab(page) && !PageHeadHuge(page);
+	return PageAnon(page) && !PageSlab(page) && !PageHeadHuge(page);
 }
 
 /*
  * This takes a head page as parameter and tells if the
  * tail page reference counting can be skipped.
  *
- * For this to be safe, PageSlab and PageHeadHuge must remain true on
- * any given page where they return true here, until all tail pins
+ * For this to be safe, PageAnon and PageSlab and PageHeadHuge must remain
+ * true on any given page where they return true here, until all tail pins
  * have been released.
  */
 static inline bool compound_tail_refcounted(struct page *page)
@@ -980,50 +1022,6 @@ void page_address_init(void);
 #endif
 
 /*
- * On an anonymous page mapped into a user virtual memory area,
- * page->mapping points to its anon_vma, not to a struct address_space;
- * with the PAGE_MAPPING_ANON bit set to distinguish it.  See rmap.h.
- *
- * On an anonymous page in a VM_MERGEABLE area, if CONFIG_KSM is enabled,
- * the PAGE_MAPPING_KSM bit may be set along with the PAGE_MAPPING_ANON bit;
- * and then page->mapping points, not to an anon_vma, but to a private
- * structure which KSM associates with that merged page.  See ksm.h.
- *
- * PAGE_MAPPING_KSM without PAGE_MAPPING_ANON is currently never used.
- *
- * Please note that, confusingly, "page_mapping" refers to the inode
- * address_space which maps the page from disk; whereas "page_mapped"
- * refers to user virtual address space into which the page is mapped.
- */
-#define PAGE_MAPPING_ANON	1
-#define PAGE_MAPPING_KSM	2
-#define PAGE_MAPPING_FLAGS	(PAGE_MAPPING_ANON | PAGE_MAPPING_KSM)
-
-extern struct address_space *page_mapping(struct page *page);
-
-/* Neutral page->mapping pointer to address_space or anon_vma or other */
-static inline void *page_rmapping(struct page *page)
-{
-	return (void *)((unsigned long)page->mapping & ~PAGE_MAPPING_FLAGS);
-}
-
-extern struct address_space *__page_file_mapping(struct page *);
-
-static inline
-struct address_space *page_file_mapping(struct page *page)
-{
-	if (unlikely(PageSwapCache(page)))
-		return __page_file_mapping(page);
-
-	return page->mapping;
-}
-
-static inline int PageAnon(struct page *page)
-{
-	return ((unsigned long)page->mapping & PAGE_MAPPING_ANON) != 0;
-}
-
-/*
  * Return the pagecache index of the passed page.  Regular pagecache pages
  * use ->index whereas swapcache pages use ->private
  */
--- thpfs.orig/mm/compaction.c	2015-02-08 18:54:22.000000000 -0800
+++ thpfs/mm/compaction.c	2015-02-20 19:34:11.231993296 -0800
@@ -676,6 +676,12 @@ isolate_migratepages_block(struct compac
 			continue;
 		}
 
+		/* Team bit == compound_lock bit: racy check before skipping */
+		if (PageTeam(page) && !PageAnon(page)) {
+			low_pfn = round_up(low_pfn + 1, HPAGE_PMD_NR) - 1;
+			continue;
+		}
+
 		/*
 		 * Migration will fail if an anonymous page is pinned in memory,
 		 * so avoid taking lru_lock and isolating it unnecessarily in an
--- thpfs.orig/mm/memcontrol.c	2015-02-20 19:33:31.052085168 -0800
+++ thpfs/mm/memcontrol.c	2015-02-20 19:34:11.231993296 -0800
@@ -5021,8 +5021,8 @@ static enum mc_target_type get_mctgt_typ
 	enum mc_target_type ret = MC_TARGET_NONE;
 
 	page = pmd_page(pmd);
-	VM_BUG_ON_PAGE(!page || !PageHead(page), page);
-	if (!move_anon())
+	/* Don't attempt to move huge tmpfs pages: could be enabled later */
+	if (!move_anon() || !PageAnon(page))
 		return ret;
 	if (page->mem_cgroup == mc.from) {
 		ret = MC_TARGET_PAGE;
--- thpfs.orig/mm/migrate.c	2015-02-20 19:33:40.876062705 -0800
+++ thpfs/mm/migrate.c	2015-02-20 19:34:11.235993287 -0800
@@ -937,6 +937,10 @@ static int unmap_and_move(new_page_t get
 	int *result = NULL;
 	struct page *newpage;
 
+	/* Team bit == compound_lock bit: racy check before refusing */
+	if (PageTeam(page) && !PageAnon(page))
+		return -EBUSY;
+
 	newpage = get_new_page(page, private, &result);
 	if (!newpage)
 		return -ENOMEM;
@@ -1770,6 +1774,14 @@ int migrate_misplaced_transhuge_page(str
 	pmd_t orig_entry;
 
 	/*
+	 * Leave support for NUMA balancing on huge tmpfs pages to the future.
+	 * The pmd marking up to this point should work okay, but from here on
+	 * there is work to be done: e.g. anon page->mapping assumption below.
+	 */
+	if (!PageAnon(page))
+		goto out_dropref;
+
+	/*
 	 * Rate-limit the amount of data that is being migrated to a node.
 	 * Optimal placement is no good if the memory bus is saturated and
 	 * all the time is being spent migrating!
--- thpfs.orig/mm/truncate.c	2014-12-07 14:21:05.000000000 -0800
+++ thpfs/mm/truncate.c	2015-02-20 19:34:11.235993287 -0800
@@ -542,7 +542,7 @@ invalidate_complete_page2(struct address
 		return 0;
 
 	spin_lock_irq(&mapping->tree_lock);
-	if (PageDirty(page))
+	if (PageDirty(page) || PageTeam(page))
 		goto failed;
 
 	BUG_ON(page_has_private(page));
--- thpfs.orig/mm/vmscan.c	2015-02-20 19:33:56.532026908 -0800
+++ thpfs/mm/vmscan.c	2015-02-20 19:34:11.235993287 -0800
@@ -567,6 +567,8 @@ static int __remove_mapping(struct addre
 	 * Note that if SetPageDirty is always performed via set_page_dirty,
 	 * and thus under tree_lock, then this ordering is not required.
 	 */
+	if (unlikely(PageTeam(page)))
+		goto cannot_free;
 	if (!page_freeze_refs(page, 2))
 		goto cannot_free;
 	/* note: atomic_cmpxchg in page_freeze_refs provides the smp_rmb */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
