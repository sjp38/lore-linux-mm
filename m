Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f47.google.com (mail-wg0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 774296B0081
	for <linux-mm@kvack.org>; Wed, 26 Feb 2014 23:39:58 -0500 (EST)
Received: by mail-wg0-f47.google.com with SMTP id n12so2413578wgh.18
        for <linux-mm@kvack.org>; Wed, 26 Feb 2014 20:39:57 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id s13si11802712wiv.5.2014.02.26.20.39.56
        for <linux-mm@kvack.org>;
        Wed, 26 Feb 2014 20:39:56 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH 2/3] mm, hugetlbfs: fix rmapping for anonymous hugepages with page_pgoff()
Date: Wed, 26 Feb 2014 23:39:36 -0500
Message-Id: <1393475977-3381-3-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1393475977-3381-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1393475977-3381-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

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

Reported-by: Sasha Levin <sasha.levin@oracle.com> # if the reported problem is fixed
Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: stable@vger.kernel.org # 3.12+
---
 include/linux/pagemap.h | 13 +++++++++++++
 mm/huge_memory.c        |  2 +-
 mm/hugetlb.c            |  5 +++++
 mm/memory-failure.c     |  4 ++--
 mm/rmap.c               |  8 ++------
 5 files changed, 23 insertions(+), 9 deletions(-)

diff --git next-20140220.orig/include/linux/pagemap.h next-20140220/include/linux/pagemap.h
index 4f591df66778..a8bd14f42032 100644
--- next-20140220.orig/include/linux/pagemap.h
+++ next-20140220/include/linux/pagemap.h
@@ -316,6 +316,19 @@ static inline loff_t page_file_offset(struct page *page)
 	return ((loff_t)page_file_index(page)) << PAGE_CACHE_SHIFT;
 }
 
+extern pgoff_t hugepage_pgoff(struct page *page);
+
+/*
+ * page->index stores pagecache index whose unit is not always PAGE_SIZE.
+ * This function converts it into PAGE_SIZE offset.
+ */
+#define page_pgoff(page)					\
+({								\
+	unlikely(PageHuge(page)) ?				\
+		hugepage_pgoff(page) :				\
+		page->index >> (PAGE_CACHE_SHIFT - PAGE_SHIFT);	\
+})
+
 extern pgoff_t linear_hugepage_index(struct vm_area_struct *vma,
 				     unsigned long address);
 
diff --git next-20140220.orig/mm/huge_memory.c next-20140220/mm/huge_memory.c
index 6ac89e9f82ef..ef96763a6abf 100644
--- next-20140220.orig/mm/huge_memory.c
+++ next-20140220/mm/huge_memory.c
@@ -1800,7 +1800,7 @@ static void __split_huge_page(struct page *page,
 			      struct list_head *list)
 {
 	int mapcount, mapcount2;
-	pgoff_t pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
+	pgoff_t pgoff = page_pgoff(page);
 	struct anon_vma_chain *avc;
 
 	BUG_ON(!PageHead(page));
diff --git next-20140220.orig/mm/hugetlb.c next-20140220/mm/hugetlb.c
index 2252cacf98e8..e159e593d99f 100644
--- next-20140220.orig/mm/hugetlb.c
+++ next-20140220/mm/hugetlb.c
@@ -764,6 +764,11 @@ pgoff_t __basepage_index(struct page *page)
 	return (index << compound_order(page_head)) + compound_idx;
 }
 
+pgoff_t hugepage_pgoff(struct page *page)
+{
+	return page->index << huge_page_order(page_hstate(page));
+}
+
 static struct page *alloc_fresh_huge_page_node(struct hstate *h, int nid)
 {
 	struct page *page;
diff --git next-20140220.orig/mm/memory-failure.c next-20140220/mm/memory-failure.c
index 35ef28acf137..5d85a4afb22c 100644
--- next-20140220.orig/mm/memory-failure.c
+++ next-20140220/mm/memory-failure.c
@@ -404,7 +404,7 @@ static void collect_procs_anon(struct page *page, struct list_head *to_kill,
 	if (av == NULL)	/* Not actually mapped anymore */
 		return;
 
-	pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
+	pgoff = page_pgoff(page);
 	read_lock(&tasklist_lock);
 	for_each_process (tsk) {
 		struct anon_vma_chain *vmac;
@@ -437,7 +437,7 @@ static void collect_procs_file(struct page *page, struct list_head *to_kill,
 	mutex_lock(&mapping->i_mmap_mutex);
 	read_lock(&tasklist_lock);
 	for_each_process(tsk) {
-		pgoff_t pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
+		pgoff_t pgoff = page_pgoff(page);
 
 		if (!task_early_kill(tsk))
 			continue;
diff --git next-20140220.orig/mm/rmap.c next-20140220/mm/rmap.c
index 9056a1f00b87..78405051474a 100644
--- next-20140220.orig/mm/rmap.c
+++ next-20140220/mm/rmap.c
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
 
@@ -1598,7 +1594,7 @@ static struct anon_vma *rmap_walk_anon_lock(struct page *page,
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
