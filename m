Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 068089000BD
	for <linux-mm@kvack.org>; Tue, 27 Sep 2011 20:49:34 -0400 (EDT)
Received: from wpaz33.hot.corp.google.com (wpaz33.hot.corp.google.com [172.24.198.97])
	by smtp-out.google.com with ESMTP id p8S0nWqu020673
	for <linux-mm@kvack.org>; Tue, 27 Sep 2011 17:49:32 -0700
Received: from iabn5 (iabn5.prod.google.com [10.12.90.5])
	by wpaz33.hot.corp.google.com with ESMTP id p8S0nT0a008041
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 27 Sep 2011 17:49:31 -0700
Received: by iabn5 with SMTP id n5so7054535iab.38
        for <linux-mm@kvack.org>; Tue, 27 Sep 2011 17:49:31 -0700 (PDT)
From: Michel Lespinasse <walken@google.com>
Subject: [PATCH 3/9] kstaled: page_referenced_kstaled() and supporting infrastructure.
Date: Tue, 27 Sep 2011 17:49:01 -0700
Message-Id: <1317170947-17074-4-git-send-email-walken@google.com>
In-Reply-To: <1317170947-17074-1-git-send-email-walken@google.com>
References: <1317170947-17074-1-git-send-email-walken@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Balbir Singh <bsingharora@gmail.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Michael Wolf <mjwolf@us.ibm.com>

Add a new page_referenced_kstaled() interface. The desired behavior
is that page_referenced() returns page references since the last
page_referenced() call, and page_referenced_kstaled() returns page
references since the last page_referenced_kstaled() call, but they
are both independent of each other and do not influence each other.

The following events are counted as kstaled page references:
- CPU data access to the page (as noticed through pte_young());
- mark_page_accessed() calls;
- page being freed / reallocated.


Signed-off-by: Michel Lespinasse <walken@google.com>
---
 include/linux/page-flags.h |   35 ++++++++++++++++++++++
 include/linux/rmap.h       |   68 +++++++++++++++++++++++++++++++++++++++----
 mm/rmap.c                  |   62 ++++++++++++++++++++++++++++-----------
 mm/swap.c                  |    1 +
 4 files changed, 141 insertions(+), 25 deletions(-)

diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index 6081493..e964d98 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -51,6 +51,13 @@
  * PG_hwpoison indicates that a page got corrupted in hardware and contains
  * data with incorrect ECC bits that triggered a machine check. Accessing is
  * not safe since it may cause another machine check. Don't touch!
+ *
+ * PG_young indicates that kstaled cleared the young bit on some PTEs pointing
+ * to that page. In order to avoid interacting with the LRU algorithm, we want
+ * the next page_referenced() call to still consider the page young.
+ *
+ * PG_idle indicates that the page has not been referenced since the last time
+ * kstaled scanned it.
  */
 
 /*
@@ -107,6 +114,10 @@ enum pageflags {
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 	PG_compound_lock,
 #endif
+#ifdef CONFIG_KSTALED
+	PG_young,		/* kstaled cleared pte_young */
+	PG_idle,		/* idle since start of kstaled interval */
+#endif
 	__NR_PAGEFLAGS,
 
 	/* Filesystems */
@@ -278,6 +289,30 @@ PAGEFLAG_FALSE(HWPoison)
 #define __PG_HWPOISON 0
 #endif
 
+#ifdef CONFIG_KSTALED
+
+PAGEFLAG(Young, young)
+PAGEFLAG(Idle, idle)
+
+static inline void set_page_young(struct page *page)
+{
+	if (!PageYoung(page))
+		SetPageYoung(page);
+}
+
+static inline void clear_page_idle(struct page *page)
+{
+	if (PageIdle(page))
+		ClearPageIdle(page);
+}
+
+#else /* !CONFIG_KSTALED */
+
+static inline void set_page_young(struct page *page) {}
+static inline void clear_page_idle(struct page *page) {}
+
+#endif /* CONFIG_KSTALED */
+
 u64 stable_page_flags(struct page *page);
 
 static inline int PageUptodate(struct page *page)
diff --git a/include/linux/rmap.h b/include/linux/rmap.h
index 82fef42..88a0b85 100644
--- a/include/linux/rmap.h
+++ b/include/linux/rmap.h
@@ -74,6 +74,8 @@ struct page_referenced_info {
 	unsigned long vm_flags;
 	unsigned int pr_flags;
 #define PR_REFERENCED  1
+#define PR_DIRTY       2
+#define PR_FOR_KSTALED 4
 };
 
 #ifdef CONFIG_MMU
@@ -165,8 +167,8 @@ static inline void page_dup_rmap(struct page *page)
 /*
  * Called from mm/vmscan.c to handle paging out
  */
-void page_referenced(struct page *, int is_locked, struct mem_cgroup *cnt,
-		     struct page_referenced_info *info);
+void __page_referenced(struct page *, int is_locked, struct mem_cgroup *cnt,
+		       struct page_referenced_info *info);
 void page_referenced_one(struct page *, struct vm_area_struct *,
 			 unsigned long address, unsigned int *mapcount,
 			 struct page_referenced_info *info);
@@ -244,12 +246,10 @@ int rmap_walk(struct page *page, int (*rmap_one)(struct page *,
 #define anon_vma_prepare(vma)	(0)
 #define anon_vma_link(vma)	do {} while (0)
 
-static inline void page_referenced(struct page *page, int is_locked,
-				   struct mem_cgroup *cnt,
-				   struct page_referenced_info *info)
+static inline void __page_referenced(struct page *page, int is_locked,
+				     struct mem_cgroup *cnt,
+				     struct page_referenced_info *info)
 {
-	info->vm_flags = 0;
-	info->pr_flags = 0;
 }
 
 #define try_to_unmap(page, refs) SWAP_FAIL
@@ -262,6 +262,60 @@ static inline int page_mkclean(struct page *page)
 
 #endif	/* CONFIG_MMU */
 
+/**
+ * page_referenced - test if the page was referenced
+ * @page: the page to test
+ * @is_locked: caller holds lock on the page
+ * @mem_cont: target memory controller
+ * @vm_flags: collect encountered vma->vm_flags who actually referenced the page
+ *
+ * Quick test_and_clear_referenced for all mappings to a page,
+ * returns the number of ptes which referenced the page.
+ */
+static inline void page_referenced(struct page *page,
+				   int is_locked,
+				   struct mem_cgroup *mem_cont,
+				   struct page_referenced_info *info)
+{
+	info->vm_flags = 0;
+	info->pr_flags = 0;
+
+#ifdef CONFIG_KSTALED
+	/*
+	 * Always clear PageYoung at the start of a scanning interval. It will
+	 * get get set if kstaled clears a young bit in a pte reference,
+	 * so that vmscan will still see the page as referenced.
+	 */
+	if (PageYoung(page)) {
+		ClearPageYoung(page);
+		info->pr_flags |= PR_REFERENCED;
+	}
+#endif
+
+	__page_referenced(page, is_locked, mem_cont, info);
+}
+
+#ifdef CONFIG_KSTALED
+static inline void page_referenced_kstaled(struct page *page, bool is_locked,
+					   struct page_referenced_info *info)
+{
+	info->vm_flags = 0;
+	info->pr_flags = PR_FOR_KSTALED;
+
+	/*
+	 * Always set PageIdle at the start of a scanning interval. It will
+	 * get cleared if a young page reference is encountered; otherwise
+	 * the page will be counted as idle at the next kstaled scan cycle.
+	 */
+	if (!PageIdle(page)) {
+		SetPageIdle(page);
+		info->pr_flags |= PR_REFERENCED;
+	}
+
+	__page_referenced(page, is_locked, NULL, info);
+}
+#endif
+
 /*
  * Return values of try_to_unmap
  */
diff --git a/mm/rmap.c b/mm/rmap.c
index f87afd0..fa8440e 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -670,6 +670,8 @@ void page_referenced_one(struct page *page, struct vm_area_struct *vma,
 			return;
 		}
 
+		info->pr_flags |= PR_DIRTY;
+
 		if (vma->vm_flags & VM_LOCKED) {
 			spin_unlock(&mm->page_table_lock);
 			*mapcount = 0;	/* break early from loop */
@@ -678,8 +680,17 @@ void page_referenced_one(struct page *page, struct vm_area_struct *vma,
 		}
 
 		/* go ahead even if the pmd is pmd_trans_splitting() */
-		if (pmdp_clear_flush_young_notify(vma, address, pmd))
-			referenced = true;
+		if (!(info->pr_flags & PR_FOR_KSTALED)) {
+			if (pmdp_clear_flush_young_notify(vma, address, pmd)) {
+				referenced = true;
+				clear_page_idle(page);
+			}
+		} else {
+			if (pmdp_test_and_clear_young(vma, address, pmd)) {
+				referenced = true;
+				set_page_young(page);
+			}
+		}
 		spin_unlock(&mm->page_table_lock);
 	} else {
 		pte_t *pte;
@@ -693,6 +704,9 @@ void page_referenced_one(struct page *page, struct vm_area_struct *vma,
 		if (!pte)
 			return;
 
+		if (pte_dirty(*pte))
+			info->pr_flags |= PR_DIRTY;
+
 		if (vma->vm_flags & VM_LOCKED) {
 			pte_unmap_unlock(pte, ptl);
 			*mapcount = 0;	/* break early from loop */
@@ -700,23 +714,38 @@ void page_referenced_one(struct page *page, struct vm_area_struct *vma,
 			return;
 		}
 
-		if (ptep_clear_flush_young_notify(vma, address, pte)) {
+		if (!(info->pr_flags & PR_FOR_KSTALED)) {
+			if (ptep_clear_flush_young_notify(vma, address, pte)) {
+				/*
+				 * Don't treat a reference through a
+				 * sequentially read mapping as such.
+				 * If the page has been used in another
+				 * mapping, we will catch it; if this other
+				 * mapping is already gone, the unmap path
+				 * will have set PG_referenced or activated
+				 * the page.
+				 */
+				if (likely(!VM_SequentialReadHint(vma)))
+					referenced = true;
+				clear_page_idle(page);
+			}
+		} else {
 			/*
-			 * Don't treat a reference through a sequentially read
-			 * mapping as such.  If the page has been used in
-			 * another mapping, we will catch it; if this other
-			 * mapping is already gone, the unmap path will have
-			 * set PG_referenced or activated the page.
+			 * Within page_referenced_kstaled():
+			 * skip TLB shootdown & VM_SequentialReadHint heuristic
 			 */
-			if (likely(!VM_SequentialReadHint(vma)))
+			if (ptep_test_and_clear_young(vma, address, pte)) {
 				referenced = true;
+				set_page_young(page);
+			}
 		}
 		pte_unmap_unlock(pte, ptl);
 	}
 
 	/* Pretend the page is referenced if the task has the
 	   swap token and is in the middle of a page fault. */
-	if (mm != current->mm && has_swap_token(mm) &&
+	if (!(info->pr_flags & PR_FOR_KSTALED) &&
+			mm != current->mm && has_swap_token(mm) &&
 			rwsem_is_locked(&mm->mmap_sem))
 		referenced = true;
 
@@ -828,7 +857,7 @@ static void page_referenced_file(struct page *page,
 }
 
 /**
- * page_referenced - test if the page was referenced
+ * __page_referenced - test if the page was referenced
  * @page: the page to test
  * @is_locked: caller holds lock on the page
  * @mem_cont: target memory controller
@@ -838,16 +867,13 @@ static void page_referenced_file(struct page *page,
  * Quick test_and_clear_referenced for all mappings to a page,
  * returns the number of ptes which referenced the page.
  */
-void page_referenced(struct page *page,
-		     int is_locked,
-		     struct mem_cgroup *mem_cont,
-		     struct page_referenced_info *info)
+void __page_referenced(struct page *page,
+		       int is_locked,
+		       struct mem_cgroup *mem_cont,
+		       struct page_referenced_info *info)
 {
 	int we_locked = 0;
 
-	info->vm_flags = 0;
-	info->pr_flags = 0;
-
 	if (page_mapped(page) && page_rmapping(page)) {
 		if (!is_locked && (!PageAnon(page) || PageKsm(page))) {
 			we_locked = trylock_page(page);
diff --git a/mm/swap.c b/mm/swap.c
index 3a442f1..d65b69e 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -344,6 +344,7 @@ void mark_page_accessed(struct page *page)
 	} else if (!PageReferenced(page)) {
 		SetPageReferenced(page);
 	}
+	clear_page_idle(page);
 }
 
 EXPORT_SYMBOL(mark_page_accessed);
-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
