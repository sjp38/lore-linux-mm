Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 23E7C6B016F
	for <linux-mm@kvack.org>; Thu, 21 May 2015 11:48:56 -0400 (EDT)
Received: by pdea3 with SMTP id a3so112375107pde.2
        for <linux-mm@kvack.org>; Thu, 21 May 2015 08:48:55 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id iz4si32153299pbc.245.2015.05.21.08.48.50
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 May 2015 08:48:51 -0700 (PDT)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [RFC v3 PATCH 06/10] hugetlbfs: truncate_hugepages() takes a range of pages
Date: Thu, 21 May 2015 08:47:40 -0700
Message-Id: <1432223264-4414-7-git-send-email-mike.kravetz@oracle.com>
In-Reply-To: <1432223264-4414-1-git-send-email-mike.kravetz@oracle.com>
References: <1432223264-4414-1-git-send-email-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <dave@stgolabs.net>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Christoph Hellwig <hch@infradead.org>, Mike Kravetz <mike.kravetz@oracle.com>

Modify truncate_hugepages() to take a range of pages (start, end)
instead of simply start. If an end value of -1 is passed, the
current "truncate" functionality is maintained. Existing callers
are modified to pass -1 as end of range. By keying off end == -1,
the routine behaves differently for truncate and hole punch.
Page removal is now synchronized with page allocation via faults
by using the fault mutex table. The hole punch case can experience
the rare region_del error and must handle accordingly.

Since the routine handles more than just the truncate case, it is
renamed to remove_inode_hugepages().  To be consistent, the routine
truncate_huge_page() is renamed remove_huge_page().

Downstream of remove_inode_hugepages(), the routine
hugetlb_unreserve_pages() is also modified to take a range of pages.
hugetlb_unreserve_pages is modified to detect an error from
region_del and pass it back to the caller.

Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
---
 fs/hugetlbfs/inode.c    | 88 +++++++++++++++++++++++++++++++++++++++++++------
 include/linux/hugetlb.h |  3 +-
 mm/hugetlb.c            | 17 ++++++++--
 3 files changed, 94 insertions(+), 14 deletions(-)

diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index dda529c..dfa88a5 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -317,26 +317,53 @@ static int hugetlbfs_write_end(struct file *file, struct address_space *mapping,
 	return -EINVAL;
 }
 
-static void truncate_huge_page(struct page *page)
+static void remove_huge_page(struct page *page)
 {
 	cancel_dirty_page(page, /* No IO accounting for huge pages? */0);
 	ClearPageUptodate(page);
 	delete_from_page_cache(page);
 }
 
-static void truncate_hugepages(struct inode *inode, loff_t lstart)
+/*
+ * remove_inode_hugepages handles two distinct cases: truncation and hole punch
+ * truncation is indicated by end of range being -1
+ *	In this case, we first scan the range and release found pages.
+ *	After releasing pages, hugetlb_unreserve_pages cleans up region/reserv
+ *	maps and global counts.
+ * hole punch is indicated if end is not -1
+ *	In the hole punch case we scan the range and release found pages.
+ *	Only when releasing a page is the associated region/reserv map
+ *	deleted.  The region/reserv map for ranges without associated
+ *	pages are not modified.
+ */
+static void remove_inode_hugepages(struct inode *inode, loff_t lstart,
+				   loff_t lend)
 {
 	struct hstate *h = hstate_inode(inode);
 	struct address_space *mapping = &inode->i_data;
 	const pgoff_t start = lstart >> huge_page_shift(h);
+	const pgoff_t end = lend >> huge_page_shift(h);
 	struct pagevec pvec;
 	pgoff_t next;
 	int i, freed = 0;
+	long lookup_nr = PAGEVEC_SIZE;
+	bool truncate_op = (lend == -1);
 
 	pagevec_init(&pvec, 0);
 	next = start;
-	while (1) {
-		if (!pagevec_lookup(&pvec, mapping, next, PAGEVEC_SIZE)) {
+	while (next < end) {
+		/*
+		 * Make sure to never grab more pages that we
+		 * might possibly need.
+		 */
+		if (end - next < lookup_nr)
+			lookup_nr = end - next;
+
+		/*
+		 * This pagevec_lookup() may return pages past 'end',
+		 * so we must check for page->index > end.
+		 */
+		if (!pagevec_lookup(&pvec, mapping, next, lookup_nr)) {
 			if (next == start)
 				break;
 			next = start;
@@ -345,26 +372,67 @@ static void truncate_hugepages(struct inode *inode, loff_t lstart)
 
 		for (i = 0; i < pagevec_count(&pvec); ++i) {
 			struct page *page = pvec.pages[i];
+			u32 hash;
+
+			hash = hugetlb_fault_mutex_shared_hash(mapping, next);
+			hugetlb_fault_mutex_lock(hash);
 
 			lock_page(page);
+			if (page->index >= end) {
+				unlock_page(page);
+				hugetlb_fault_mutex_unlock(hash);
+				next = end;	/* we are done */
+				break;
+			}
+
+			/*
+			 * If page is mapped, it was faulted in after being
+			 * unmapped.  Do nothing in this race case.  In the
+			 * normal case page is not mapped.
+			 */
+			if (!page_mapped(page)) {
+				bool rsv_on_error = !PagePrivate(page);
+				/*
+				 * We must free the huge page and remove
+				 * from page cache (remove_huge_page) BEFORE
+				 * removing the region/reserve map
+				 * (hugetlb_unreserve_pages).  In rare out
+				 * of memory conditions, removal of the
+				 * region/reserve map could fail.  Before
+				 * free'ing the page, note PagePrivate which
+				 * is used in case of error.
+				 */
+				remove_huge_page(page);
+				freed++;
+				if (!truncate_op) {
+					if (unlikely(hugetlb_unreserve_pages(
+							inode, next,
+							next + 1, 1)))
+						hugetlb_fix_reserve_counts(
+							inode, rsv_on_error);
+				}
+			}
+
 			if (page->index > next)
 				next = page->index;
+
 			++next;
-			truncate_huge_page(page);
 			unlock_page(page);
-			freed++;
+
+			hugetlb_fault_mutex_unlock(hash);
 		}
 		huge_pagevec_release(&pvec);
 	}
-	BUG_ON(!lstart && mapping->nrpages);
-	hugetlb_unreserve_pages(inode, start, freed);
+
+	if (truncate_op)
+		(void)hugetlb_unreserve_pages(inode, start, end, freed);
 }
 
 static void hugetlbfs_evict_inode(struct inode *inode)
 {
 	struct resv_map *resv_map;
 
-	truncate_hugepages(inode, 0);
+	remove_inode_hugepages(inode, 0, -1);
 	resv_map = (struct resv_map *)inode->i_mapping->private_data;
 	/* root inode doesn't have the resv_map, so we should check it */
 	if (resv_map)
@@ -421,7 +489,7 @@ static int hugetlb_vmtruncate(struct inode *inode, loff_t offset)
 	if (!RB_EMPTY_ROOT(&mapping->i_mmap))
 		hugetlb_vmdelete_list(&mapping->i_mmap, pgoff, 0);
 	i_mmap_unlock_write(mapping);
-	truncate_hugepages(inode, offset);
+	remove_inode_hugepages(inode, offset, -1);
 	return 0;
 }
 
diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index d0d033e..4c2856e 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -75,7 +75,8 @@ int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 int hugetlb_reserve_pages(struct inode *inode, long from, long to,
 						struct vm_area_struct *vma,
 						vm_flags_t vm_flags);
-void hugetlb_unreserve_pages(struct inode *inode, long offset, long freed);
+long hugetlb_unreserve_pages(struct inode *inode, long start, long end,
+						long freed);
 int dequeue_hwpoisoned_huge_page(struct page *page);
 bool isolate_huge_page(struct page *page, struct list_head *list);
 void putback_active_hugepage(struct page *page);
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index df0d32a..0cf0622 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -3628,21 +3628,32 @@ out_err:
 	return ret;
 }
 
-void hugetlb_unreserve_pages(struct inode *inode, long offset, long freed)
+long hugetlb_unreserve_pages(struct inode *inode, long start, long end,
+								long freed)
 {
 	struct hstate *h = hstate_inode(inode);
 	struct resv_map *resv_map = inode_resv_map(inode);
 	long chg = 0;
 	struct hugepage_subpool *spool = subpool_inode(inode);
 
-	if (resv_map)
-		chg = region_del(resv_map, offset, -1);
+	if (resv_map) {
+		chg = region_del(resv_map, start, end);
+		/*
+		 * region_del() can fail in the rare case where a region
+		 * must be split and another region descriptor can not be
+		 * allocated.  If end == -1, it will not fail.
+		 */
+		if (chg < 0)
+			return chg;
+	}
 	spin_lock(&inode->i_lock);
 	inode->i_blocks -= (blocks_per_huge_page(h) * freed);
 	spin_unlock(&inode->i_lock);
 
 	hugepage_subpool_put_pages(spool, (chg - freed));
 	hugetlb_acct_memory(h, -(chg - freed));
+
+	return 0;
 }
 
 #ifdef CONFIG_ARCH_WANT_HUGE_PMD_SHARE
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
