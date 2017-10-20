Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 625ED6B0253
	for <linux-mm@kvack.org>; Fri, 20 Oct 2017 04:44:14 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id e64so9350506pfk.0
        for <linux-mm@kvack.org>; Fri, 20 Oct 2017 01:44:14 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id f88si483420pfk.57.2017.10.20.01.44.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Oct 2017 01:44:12 -0700 (PDT)
From: changbin.du@intel.com
Subject: [PATCH v2 2/2] mm: rename page dtor functions to {compound,huge,transhuge}_page__dtor
Date: Fri, 20 Oct 2017 16:36:28 +0800
Message-Id: <1508488588-23539-3-git-send-email-changbin.du@intel.com>
In-Reply-To: <1508488588-23539-1-git-send-email-changbin.du@intel.com>
References: <1508488588-23539-1-git-send-email-changbin.du@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, corbet@lwn.net, hughd@google.com
Cc: linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, khandual@linux.vnet.ibm.com, kirill@shutemov.name, Changbin Du <changbin.du@intel.com>

From: Changbin Du <changbin.du@intel.com>

The current name free_{huge,transhuge}_page are paired with
alloc_{huge,transhuge}_page functions, but the actual page free
function is still free_page() which will indirectly call
free_{huge,transhuge}_page.

So this patch removes this confusion by renaming all the
compound page dtors to {compound,huge,transhuge}_page__dtor.
And since we already have a typedef compound_page_dtor,
rename it to compound_page_dtor_t to avoid name conflict.

Signed-off-by: Changbin Du <changbin.du@intel.com>

---
v2: Improve commit message.
---
 Documentation/vm/hugetlbfs_reserv.txt |  4 ++--
 include/linux/huge_mm.h               |  2 +-
 include/linux/hugetlb.h               |  2 +-
 include/linux/mm.h                    |  8 ++++----
 mm/huge_memory.c                      |  4 ++--
 mm/hugetlb.c                          | 14 +++++++-------
 mm/page_alloc.c                       | 10 +++++-----
 mm/swap.c                             |  2 +-
 mm/userfaultfd.c                      |  2 +-
 9 files changed, 24 insertions(+), 24 deletions(-)

diff --git a/Documentation/vm/hugetlbfs_reserv.txt b/Documentation/vm/hugetlbfs_reserv.txt
index 9aca09a..b3ffa3e 100644
--- a/Documentation/vm/hugetlbfs_reserv.txt
+++ b/Documentation/vm/hugetlbfs_reserv.txt
@@ -238,7 +238,7 @@ to the global reservation count (resv_huge_pages).
 
 Freeing Huge Pages
 ------------------
-Huge page freeing is performed by the routine free_huge_page().  This routine
+Huge page freeing is performed by the routine huge_page_dtor().  This routine
 is the destructor for hugetlbfs compound pages.  As a result, it is only
 passed a pointer to the page struct.  When a huge page is freed, reservation
 accounting may need to be performed.  This would be the case if the page was
@@ -468,7 +468,7 @@ However, there are several instances where errors are encountered after a huge
 page is allocated but before it is instantiated.  In this case, the page
 allocation has consumed the reservation and made the appropriate subpool,
 reservation map and global count adjustments.  If the page is freed at this
-time (before instantiation and clearing of PagePrivate), then free_huge_page
+time (before instantiation and clearing of PagePrivate), then huge_page_dtor
 will increment the global reservation count.  However, the reservation map
 indicates the reservation was consumed.  This resulting inconsistent state
 will cause the 'leak' of a reserved huge page.  The global reserve count will
diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index 184eb38..bd05bc7 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -130,7 +130,7 @@ extern unsigned long thp_get_unmapped_area(struct file *filp,
 		unsigned long addr, unsigned long len, unsigned long pgoff,
 		unsigned long flags);
 
-extern void free_transhuge_page(struct page *page);
+extern void transhuge_page_dtor(struct page *page);
 
 extern struct page *alloc_transhuge_page_vma(gfp_t gfp_mask,
 		struct vm_area_struct *vma, unsigned long addr);
diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index 8bbbd37..24492c5 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -118,7 +118,7 @@ long hugetlb_unreserve_pages(struct inode *inode, long start, long end,
 						long freed);
 bool isolate_huge_page(struct page *page, struct list_head *list);
 void putback_active_hugepage(struct page *page);
-void free_huge_page(struct page *page);
+void huge_page_dtor(struct page *page);
 void hugetlb_fix_reserve_counts(struct inode *inode);
 extern struct mutex *hugetlb_fault_mutex_table;
 u32 hugetlb_fault_mutex_hash(struct hstate *h, struct mm_struct *mm,
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 065d99d..adfa906 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -616,7 +616,7 @@ void split_page(struct page *page, unsigned int order);
  * prototype for that function and accessor functions.
  * These are _only_ valid on the head of a compound page.
  */
-typedef void compound_page_dtor(struct page *);
+typedef void compound_page_dtor_t(struct page *);
 
 /* Keep the enum in sync with compound_page_dtors array in mm/page_alloc.c */
 enum compound_dtor_id {
@@ -630,7 +630,7 @@ enum compound_dtor_id {
 #endif
 	NR_COMPOUND_DTORS,
 };
-extern compound_page_dtor * const compound_page_dtors[];
+extern compound_page_dtor_t * const compound_page_dtors[];
 
 static inline void set_compound_page_dtor(struct page *page,
 		enum compound_dtor_id compound_dtor)
@@ -639,7 +639,7 @@ static inline void set_compound_page_dtor(struct page *page,
 	page[1].compound_dtor = compound_dtor;
 }
 
-static inline compound_page_dtor *get_compound_page_dtor(struct page *page)
+static inline compound_page_dtor_t *get_compound_page_dtor(struct page *page)
 {
 	VM_BUG_ON_PAGE(page[1].compound_dtor >= NR_COMPOUND_DTORS, page);
 	return compound_page_dtors[page[1].compound_dtor];
@@ -657,7 +657,7 @@ static inline void set_compound_order(struct page *page, unsigned int order)
 	page[1].compound_order = order;
 }
 
-void free_compound_page(struct page *page);
+void compound_page_dtor(struct page *page);
 
 #ifdef CONFIG_MMU
 /*
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 2a960fc..692ea1e 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2715,7 +2715,7 @@ fail:		if (mapping)
 	return ret;
 }
 
-void free_transhuge_page(struct page *page)
+void transhuge_page_dtor(struct page *page)
 {
 	struct pglist_data *pgdata = NODE_DATA(page_to_nid(page));
 	unsigned long flags;
@@ -2726,7 +2726,7 @@ void free_transhuge_page(struct page *page)
 		list_del(page_deferred_list(page));
 	}
 	spin_unlock_irqrestore(&pgdata->split_queue_lock, flags);
-	free_compound_page(page);
+	compound_page_dtor(page);
 }
 
 void deferred_split_huge_page(struct page *page)
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 424b0ef..1af2c4e7 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1250,7 +1250,7 @@ static void clear_page_huge_active(struct page *page)
 	ClearPagePrivate(&page[1]);
 }
 
-void free_huge_page(struct page *page)
+void huge_page_dtor(struct page *page)
 {
 	/*
 	 * Can't pass hstate in here because it is called from the
@@ -1363,7 +1363,7 @@ int PageHeadHuge(struct page *page_head)
 	if (!PageHead(page_head))
 		return 0;
 
-	return get_compound_page_dtor(page_head) == free_huge_page;
+	return get_compound_page_dtor(page_head) == huge_page_dtor;
 }
 
 pgoff_t __basepage_index(struct page *page)
@@ -1932,11 +1932,11 @@ static long vma_add_reservation(struct hstate *h,
  * specific error paths, a huge page was allocated (via alloc_huge_page)
  * and is about to be freed.  If a reservation for the page existed,
  * alloc_huge_page would have consumed the reservation and set PagePrivate
- * in the newly allocated page.  When the page is freed via free_huge_page,
+ * in the newly allocated page.  When the page is freed via huge_page_dtor,
  * the global reservation count will be incremented if PagePrivate is set.
- * However, free_huge_page can not adjust the reserve map.  Adjust the
+ * However, huge_page_dtor can not adjust the reserve map.  Adjust the
  * reserve map here to be consistent with global reserve count adjustments
- * to be made by free_huge_page.
+ * to be made by huge_page_dtor.
  */
 static void restore_reserve_on_error(struct hstate *h,
 			struct vm_area_struct *vma, unsigned long address,
@@ -1950,7 +1950,7 @@ static void restore_reserve_on_error(struct hstate *h,
 			 * Rare out of memory condition in reserve map
 			 * manipulation.  Clear PagePrivate so that
 			 * global reserve count will not be incremented
-			 * by free_huge_page.  This will make it appear
+			 * by huge_page_dtor.  This will make it appear
 			 * as though the reservation for this page was
 			 * consumed.  This may prevent the task from
 			 * faulting in the page at a later time.  This
@@ -2304,7 +2304,7 @@ static unsigned long set_max_huge_pages(struct hstate *h, unsigned long count,
 	while (count > persistent_huge_pages(h)) {
 		/*
 		 * If this allocation races such that we no longer need the
-		 * page, free_huge_page will handle it by freeing the page
+		 * page, huge_page_dtor will handle it by freeing the page
 		 * and reducing the surplus.
 		 */
 		spin_unlock(&hugetlb_lock);
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 77e4d3c..b31205c 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -248,14 +248,14 @@ char * const migratetype_names[MIGRATE_TYPES] = {
 #endif
 };
 
-compound_page_dtor * const compound_page_dtors[] = {
+compound_page_dtor_t * const compound_page_dtors[] = {
 	NULL,
-	free_compound_page,
+	compound_page_dtor,
 #ifdef CONFIG_HUGETLB_PAGE
-	free_huge_page,
+	huge_page_dtor,
 #endif
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
-	free_transhuge_page,
+	transhuge_page_dtor,
 #endif
 };
 
@@ -586,7 +586,7 @@ static void bad_page(struct page *page, const char *reason,
  * This usage means that zero-order pages may not be compound.
  */
 
-void free_compound_page(struct page *page)
+void compound_page_dtor(struct page *page)
 {
 	__free_pages_ok(page, compound_order(page));
 }
diff --git a/mm/swap.c b/mm/swap.c
index a77d68f..8f98caf 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -81,7 +81,7 @@ static void __put_single_page(struct page *page)
 
 static void __put_compound_page(struct page *page)
 {
-	compound_page_dtor *dtor;
+	compound_page_dtor_t *dtor;
 
 	/*
 	 * __page_cache_release() is supposed to be called for thp, not for
diff --git a/mm/userfaultfd.c b/mm/userfaultfd.c
index 8119270..91d9045 100644
--- a/mm/userfaultfd.c
+++ b/mm/userfaultfd.c
@@ -323,7 +323,7 @@ static __always_inline ssize_t __mcopy_atomic_hugetlb(struct mm_struct *dst_mm,
 		 * map of a private mapping, the map was modified to indicate
 		 * the reservation was consumed when the page was allocated.
 		 * We clear the PagePrivate flag now so that the global
-		 * reserve count will not be incremented in free_huge_page.
+		 * reserve count will not be incremented in huge_page_dtor.
 		 * The reservation map will still indicate the reservation
 		 * was consumed and possibly prevent later page allocation.
 		 * This is better than leaking a global reservation.  If no
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
