Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id F1D516B0396
	for <linux-mm@kvack.org>; Wed, 15 Mar 2017 01:25:05 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id o126so14371702pfb.2
        for <linux-mm@kvack.org>; Tue, 14 Mar 2017 22:25:05 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id h3si981610pld.13.2017.03.14.22.24.59
        for <linux-mm@kvack.org>;
        Tue, 14 Mar 2017 22:24:59 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v2 07/10] mm: make ttu's return boolean
Date: Wed, 15 Mar 2017 14:24:50 +0900
Message-ID: <1489555493-14659-8-git-send-email-minchan@kernel.org>
In-Reply-To: <1489555493-14659-1-git-send-email-minchan@kernel.org>
References: <1489555493-14659-1-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-team@lge.com, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Minchan Kim <minchan@kernel.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

try_to_unmap returns SWAP_SUCCESS or SWAP_FAIL so it's suitable for
boolean return. This patch changes it.

Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 include/linux/rmap.h |  4 ++--
 mm/huge_memory.c     |  6 +++---
 mm/memory-failure.c  | 26 ++++++++++++--------------
 mm/rmap.c            |  8 +++-----
 mm/vmscan.c          |  7 +------
 5 files changed, 21 insertions(+), 30 deletions(-)

diff --git a/include/linux/rmap.h b/include/linux/rmap.h
index 3630d4d..6028c38 100644
--- a/include/linux/rmap.h
+++ b/include/linux/rmap.h
@@ -191,7 +191,7 @@ static inline void page_dup_rmap(struct page *page, bool compound)
 int page_referenced(struct page *, int is_locked,
 			struct mem_cgroup *memcg, unsigned long *vm_flags);
 
-int try_to_unmap(struct page *, enum ttu_flags flags);
+bool try_to_unmap(struct page *, enum ttu_flags flags);
 
 /* Avoid racy checks */
 #define PVMW_SYNC		(1 << 0)
@@ -281,7 +281,7 @@ static inline int page_referenced(struct page *page, int is_locked,
 	return 0;
 }
 
-#define try_to_unmap(page, refs) SWAP_FAIL
+#define try_to_unmap(page, refs) false
 
 static inline int page_mkclean(struct page *page)
 {
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 2b4120f..033ccee 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2139,15 +2139,15 @@ static void freeze_page(struct page *page)
 {
 	enum ttu_flags ttu_flags = TTU_IGNORE_MLOCK | TTU_IGNORE_ACCESS |
 		TTU_RMAP_LOCKED | TTU_SPLIT_HUGE_PMD;
-	int ret;
+	bool unmap_success;
 
 	VM_BUG_ON_PAGE(!PageHead(page), page);
 
 	if (PageAnon(page))
 		ttu_flags |= TTU_MIGRATION;
 
-	ret = try_to_unmap(page, ttu_flags);
-	VM_BUG_ON_PAGE(ret, page);
+	unmap_success = try_to_unmap(page, ttu_flags);
+	VM_BUG_ON_PAGE(!unmap_success, page);
 }
 
 static void unfreeze_page(struct page *page)
diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index f85adfe5..3d3cf6a 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -322,7 +322,7 @@ static void add_to_kill(struct task_struct *tsk, struct page *p,
  * wrong earlier.
  */
 static void kill_procs(struct list_head *to_kill, int forcekill, int trapno,
-			  int fail, struct page *page, unsigned long pfn,
+			  bool fail, struct page *page, unsigned long pfn,
 			  int flags)
 {
 	struct to_kill *tk, *next;
@@ -904,13 +904,13 @@ EXPORT_SYMBOL_GPL(get_hwpoison_page);
  * Do all that is necessary to remove user space mappings. Unmap
  * the pages and send SIGBUS to the processes if the data was dirty.
  */
-static int hwpoison_user_mappings(struct page *p, unsigned long pfn,
+static bool hwpoison_user_mappings(struct page *p, unsigned long pfn,
 				  int trapno, int flags, struct page **hpagep)
 {
 	enum ttu_flags ttu = TTU_IGNORE_MLOCK | TTU_IGNORE_ACCESS;
 	struct address_space *mapping;
 	LIST_HEAD(tokill);
-	int ret;
+	bool unmap_success;
 	int kill = 1, forcekill;
 	struct page *hpage = *hpagep;
 
@@ -919,20 +919,20 @@ static int hwpoison_user_mappings(struct page *p, unsigned long pfn,
 	 * other types of pages.
 	 */
 	if (PageReserved(p) || PageSlab(p))
-		return SWAP_SUCCESS;
+		return true;
 	if (!(PageLRU(hpage) || PageHuge(p)))
-		return SWAP_SUCCESS;
+		return true;
 
 	/*
 	 * This check implies we don't kill processes if their pages
 	 * are in the swap cache early. Those are always late kills.
 	 */
 	if (!page_mapped(hpage))
-		return SWAP_SUCCESS;
+		return true;
 
 	if (PageKsm(p)) {
 		pr_err("Memory failure: %#lx: can't handle KSM pages.\n", pfn);
-		return SWAP_FAIL;
+		return false;
 	}
 
 	if (PageSwapCache(p)) {
@@ -971,8 +971,8 @@ static int hwpoison_user_mappings(struct page *p, unsigned long pfn,
 	if (kill)
 		collect_procs(hpage, &tokill, flags & MF_ACTION_REQUIRED);
 
-	ret = try_to_unmap(hpage, ttu);
-	if (ret != SWAP_SUCCESS)
+	unmap_success = try_to_unmap(hpage, ttu);
+	if (!unmap_success)
 		pr_err("Memory failure: %#lx: failed to unmap page (mapcount=%d)\n",
 		       pfn, page_mapcount(hpage));
 
@@ -987,10 +987,9 @@ static int hwpoison_user_mappings(struct page *p, unsigned long pfn,
 	 * any accesses to the poisoned memory.
 	 */
 	forcekill = PageDirty(hpage) || (flags & MF_MUST_KILL);
-	kill_procs(&tokill, forcekill, trapno,
-		      ret != SWAP_SUCCESS, p, pfn, flags);
+	kill_procs(&tokill, forcekill, trapno, !unmap_success, p, pfn, flags);
 
-	return ret;
+	return unmap_success;
 }
 
 static void set_page_hwpoison_huge_page(struct page *hpage)
@@ -1230,8 +1229,7 @@ int memory_failure(unsigned long pfn, int trapno, int flags)
 	 * When the raw error page is thp tail page, hpage points to the raw
 	 * page after thp split.
 	 */
-	if (hwpoison_user_mappings(p, pfn, trapno, flags, &hpage)
-	    != SWAP_SUCCESS) {
+	if (!hwpoison_user_mappings(p, pfn, trapno, flags, &hpage)) {
 		action_result(pfn, MF_MSG_UNMAP_FAILED, MF_IGNORED);
 		res = -EBUSY;
 		goto out;
diff --git a/mm/rmap.c b/mm/rmap.c
index 612682c..04d5355 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1496,12 +1496,10 @@ static int page_mapcount_is_zero(struct page *page)
  *
  * Tries to remove all the page table entries which are mapping this
  * page, used in the pageout path.  Caller must hold the page lock.
- * Return values are:
  *
- * SWAP_SUCCESS	- we succeeded in removing all mappings
- * SWAP_FAIL	- the page is unswappable
+ * If unmap is successful, return true. Otherwise, false.
  */
-int try_to_unmap(struct page *page, enum ttu_flags flags)
+bool try_to_unmap(struct page *page, enum ttu_flags flags)
 {
 	struct rmap_walk_control rwc = {
 		.rmap_one = try_to_unmap_one,
@@ -1526,7 +1524,7 @@ int try_to_unmap(struct page *page, enum ttu_flags flags)
 	else
 		rmap_walk(page, &rwc);
 
-	return !page_mapcount(page) ? SWAP_SUCCESS : SWAP_FAIL;
+	return !page_mapcount(page) ? true : false;
 }
 
 static int page_not_mapped(struct page *page)
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 7727fbe..beffe79 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -967,7 +967,6 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		int may_enter_fs;
 		enum page_references references = PAGEREF_RECLAIM_CLEAN;
 		bool dirty, writeback;
-		int ret = SWAP_SUCCESS;
 
 		cond_resched();
 
@@ -1140,13 +1139,9 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		 * processes. Try to unmap it here.
 		 */
 		if (page_mapped(page)) {
-			switch (ret = try_to_unmap(page,
-				ttu_flags | TTU_BATCH_FLUSH)) {
-			case SWAP_FAIL:
+			if (!try_to_unmap(page, ttu_flags | TTU_BATCH_FLUSH)) {
 				nr_unmap_fail++;
 				goto activate_locked;
-			case SWAP_SUCCESS:
-				; /* try to free the page below */
 			}
 		}
 
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
