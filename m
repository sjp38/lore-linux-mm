Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f54.google.com (mail-ee0-f54.google.com [74.125.83.54])
	by kanga.kvack.org (Postfix) with ESMTP id 3929A6B0069
	for <linux-mm@kvack.org>; Fri, 28 Feb 2014 14:59:17 -0500 (EST)
Received: by mail-ee0-f54.google.com with SMTP id c41so2544057eek.27
        for <linux-mm@kvack.org>; Fri, 28 Feb 2014 11:59:16 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id n9si8342121eey.140.2014.02.28.11.59.09
        for <linux-mm@kvack.org>;
        Fri, 28 Feb 2014 11:59:12 -0800 (PST)
Date: Fri, 28 Feb 2014 14:59:02 -0500
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <5310ea90.894c0f0a.1752.ffffb609SMTPIN_ADDED_BROKEN@mx.google.com>
In-Reply-To: <530fb3ee.03cb0e0a.407a.ffffffbcSMTPIN_ADDED_BROKEN@mx.google.com>
References: <1393475977-3381-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1393475977-3381-3-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20140227131957.d81cf9a643f4d3fd6b8d8b16@linux-foundation.org>
 <530fb3ee.03cb0e0a.407a.ffffffbcSMTPIN_ADDED_BROKEN@mx.google.com>
Subject: [PATCH v2] mm, hugetlbfs: fix rmapping for anonymous hugepages with
 page_pgoff()
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: sasha.levin@oracle.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, riel@redhat.com

page->index stores pagecache index when the page is mapped into file mapping
region, and the index is in pagecache size unit, so it depends on the page
size. Some of users of reverse mapping obviously assumes that page->index
is in PAGE_CACHE_SHIFT unit, so they don't work for anonymous hugepage.

For example, consider that we have 3-hugepage vma and try to mbind the 2nd
hugepage to migrate to another node. Then the vma is split and migrate_page()
is called for the 2nd hugepage (belonging to the middle vma.)
In migrate operation, rmap_walk_anon() tries to find the relevant vma to
which the target hugepage belongs, but here we miscalculate pgoff.
So anon_vma_interval_tree_foreach() grabs invalid vma, which fires VM_BUG_ON.

This patch introduces a new API that is usable both for normal page and
hugepage to get PAGE_SIZE offset from page->index. Users should clearly
distinguish page_index for pagecache index and page_pgoff for page offset.

ChangeLog v2:
- fix wrong shift direction
- introduce page_size_order() and huge_page_size_order()
- move the declaration of PageHuge() to include/linux/hugetlb_inline.h
  to avoid macro definition.

Reported-by: Sasha Levin <sasha.levin@oracle.com> # if the reported problem is fixed
Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: stable@vger.kernel.org # 3.12+
---
 include/linux/hugetlb.h        |  7 -------
 include/linux/hugetlb_inline.h | 13 +++++++++++++
 include/linux/pagemap.h        | 16 ++++++++++++++++
 mm/huge_memory.c               |  2 +-
 mm/hugetlb.c                   |  6 ++++++
 mm/memory-failure.c            |  4 ++--
 mm/rmap.c                      |  8 ++------
 7 files changed, 40 insertions(+), 16 deletions(-)

diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index 8c43cc469d78..91fffa4fbc57 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -31,8 +31,6 @@ extern int hugetlb_max_hstate __read_mostly;
 struct hugepage_subpool *hugepage_new_subpool(long nr_blocks);
 void hugepage_put_subpool(struct hugepage_subpool *spool);
 
-int PageHuge(struct page *page);
-
 void reset_vma_resv_huge_pages(struct vm_area_struct *vma);
 int hugetlb_sysctl_handler(struct ctl_table *, int, void __user *, size_t *, loff_t *);
 int hugetlb_overcommit_handler(struct ctl_table *, int, void __user *, size_t *, loff_t *);
@@ -99,11 +97,6 @@ unsigned long hugetlb_change_protection(struct vm_area_struct *vma,
 
 #else /* !CONFIG_HUGETLB_PAGE */
 
-static inline int PageHuge(struct page *page)
-{
-	return 0;
-}
-
 static inline void reset_vma_resv_huge_pages(struct vm_area_struct *vma)
 {
 }
diff --git a/include/linux/hugetlb_inline.h b/include/linux/hugetlb_inline.h
index 2bb681fbeb35..e939975f0cba 100644
--- a/include/linux/hugetlb_inline.h
+++ b/include/linux/hugetlb_inline.h
@@ -10,6 +10,9 @@ static inline int is_vm_hugetlb_page(struct vm_area_struct *vma)
 	return !!(vma->vm_flags & VM_HUGETLB);
 }
 
+int PageHuge(struct page *page);
+unsigned int huge_page_size_order(struct page *page);
+
 #else
 
 static inline int is_vm_hugetlb_page(struct vm_area_struct *vma)
@@ -17,6 +20,16 @@ static inline int is_vm_hugetlb_page(struct vm_area_struct *vma)
 	return 0;
 }
 
+static inline int PageHuge(struct page *page)
+{
+	return 0;
+}
+
+static inline unsigned int huge_page_size_order(struct page *page)
+{
+	return 0;
+}
+
 #endif
 
 #endif
diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index f0ef8826acf1..4a01dd3c304d 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -307,6 +307,22 @@ static inline loff_t page_file_offset(struct page *page)
 	return ((loff_t)page_file_index(page)) << PAGE_CACHE_SHIFT;
 }
 
+static inline unsigned int page_size_order(struct page *page)
+{
+	return unlikely(PageHuge(page)) ?
+		huge_page_size_order(page) :
+		(PAGE_CACHE_SHIFT - PAGE_SHIFT);
+}
+
+/*
+ * page->index stores pagecache index whose unit is not always PAGE_SIZE.
+ * This function converts it into PAGE_SIZE offset.
+ */
+static inline pgoff_t page_pgoff(struct page *page)
+{
+        return page->index << page_size_order(page);
+}
+
 extern pgoff_t linear_hugepage_index(struct vm_area_struct *vma,
 				     unsigned long address);
 
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 82166bf974e1..12faa32f4d6d 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1877,7 +1877,7 @@ static void __split_huge_page(struct page *page,
 			      struct list_head *list)
 {
 	int mapcount, mapcount2;
-	pgoff_t pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
+	pgoff_t pgoff = page_pgoff(page);
 	struct anon_vma_chain *avc;
 
 	BUG_ON(!PageHead(page));
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index c01cb9fedb18..39d7461e9ba7 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -29,6 +29,7 @@
 
 #include <linux/io.h>
 #include <linux/hugetlb.h>
+#include <linux/hugetlb_inline.h>
 #include <linux/hugetlb_cgroup.h>
 #include <linux/node.h>
 #include "internal.h"
@@ -727,6 +728,11 @@ pgoff_t __basepage_index(struct page *page)
 	return (index << compound_order(page_head)) + compound_idx;
 }
 
+unsigned int huge_page_size_order(struct page *page)
+{
+	return huge_page_order(page_hstate(page));
+}
+
 static struct page *alloc_fresh_huge_page_node(struct hstate *h, int nid)
 {
 	struct page *page;
diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index 47e500c2f258..3be725304703 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -409,7 +409,7 @@ static void collect_procs_anon(struct page *page, struct list_head *to_kill,
 	if (av == NULL)	/* Not actually mapped anymore */
 		return;
 
-	pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
+	pgoff = page_pgoff(page);
 	read_lock(&tasklist_lock);
 	for_each_process (tsk) {
 		struct anon_vma_chain *vmac;
@@ -442,7 +442,7 @@ static void collect_procs_file(struct page *page, struct list_head *to_kill,
 	mutex_lock(&mapping->i_mmap_mutex);
 	read_lock(&tasklist_lock);
 	for_each_process(tsk) {
-		pgoff_t pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
+		pgoff_t pgoff = page_pgoff(page);
 
 		if (!task_early_kill(tsk))
 			continue;
diff --git a/mm/rmap.c b/mm/rmap.c
index d9d42316a99a..d3538a913285 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -515,11 +515,7 @@ void page_unlock_anon_vma_read(struct anon_vma *anon_vma)
 static inline unsigned long
 __vma_address(struct page *page, struct vm_area_struct *vma)
 {
-	pgoff_t pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
-
-	if (unlikely(is_vm_hugetlb_page(vma)))
-		pgoff = page->index << huge_page_order(page_hstate(page));
-
+	pgoff_t pgoff = page_pgoff(page);
 	return vma->vm_start + ((pgoff - vma->vm_pgoff) << PAGE_SHIFT);
 }
 
@@ -1588,7 +1584,7 @@ static struct anon_vma *rmap_walk_anon_lock(struct page *page,
 static int rmap_walk_anon(struct page *page, struct rmap_walk_control *rwc)
 {
 	struct anon_vma *anon_vma;
-	pgoff_t pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
+	pgoff_t pgoff = page_pgoff(page);
 	struct anon_vma_chain *avc;
 	int ret = SWAP_AGAIN;
 
-- 
1.8.5.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
