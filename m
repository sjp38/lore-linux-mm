Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 1B94F6B0081
	for <linux-mm@kvack.org>; Thu, 23 Apr 2015 18:14:08 -0400 (EDT)
Received: by pdea3 with SMTP id a3so30028172pde.3
        for <linux-mm@kvack.org>; Thu, 23 Apr 2015 15:14:07 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id gl1si1009665pbc.104.2015.04.23.15.14.06
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Apr 2015 15:14:07 -0700 (PDT)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [RFC v2 PATCH 1/5] hugetlbfs: truncate_hugepages() takes a range of pages
Date: Thu, 23 Apr 2015 15:13:13 -0700
Message-Id: <1429827197-677-2-git-send-email-mike.kravetz@oracle.com>
In-Reply-To: <1429827197-677-1-git-send-email-mike.kravetz@oracle.com>
References: <1429827197-677-1-git-send-email-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <dave@stgolabs.net>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Christoph Hellwig <hch@infradead.org>, Mike Kravetz <mike.kravetz@oracle.com>

Modify truncate_hugepages() to take a range of pages (start, end)
instead of simply start.  If the value of end is -1, this indicates
the end of the range is the end of the file.  This functionality
will be used for fallocate hole punching.

Downstream of truncate_hugepages, the routines hugetlb_unreserve_pages
must also be modified to accept a range of pages.

A new region tracking/resv_map routine region_del() is added to delete
a range of regions within the reserve maps.  As in truncate_hugepages,
a range end value of -1 indicates all regions after the starting value
should be deleted.

Based-on code-by: Dave Hansen <dave.hansen@linux.intel.com>
Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
---
 fs/hugetlbfs/inode.c    | 31 +++++++++++++++-----
 include/linux/hugetlb.h |  3 +-
 mm/hugetlb.c            | 76 +++++++++++++++++++++++++++++++++++++++++++++++--
 3 files changed, 100 insertions(+), 10 deletions(-)

diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index c274aca..2faf2c4 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -324,19 +324,32 @@ static void truncate_huge_page(struct page *page)
 	delete_from_page_cache(page);
 }
 
-static void truncate_hugepages(struct inode *inode, loff_t lstart)
+static void truncate_hugepages(struct inode *inode, loff_t lstart, loff_t lend)
 {
 	struct hstate *h = hstate_inode(inode);
 	struct address_space *mapping = &inode->i_data;
 	const pgoff_t start = lstart >> huge_page_shift(h);
+	const pgoff_t end = lend >> huge_page_shift(h);
 	struct pagevec pvec;
 	pgoff_t next;
 	int i, freed = 0;
+	long lookup_nr = PAGEVEC_SIZE;
 
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
@@ -347,6 +360,11 @@ static void truncate_hugepages(struct inode *inode, loff_t lstart)
 			struct page *page = pvec.pages[i];
 
 			lock_page(page);
+			if (page->index >= end) {
+				unlock_page(page);
+				next = end;	/* we are done */
+				break;
+			}
 			if (page->index > next)
 				next = page->index;
 			++next;
@@ -356,15 +374,14 @@ static void truncate_hugepages(struct inode *inode, loff_t lstart)
 		}
 		huge_pagevec_release(&pvec);
 	}
-	BUG_ON(!lstart && mapping->nrpages);
-	hugetlb_unreserve_pages(inode, start, freed);
+	hugetlb_unreserve_pages(inode, start, end, freed);
 }
 
 static void hugetlbfs_evict_inode(struct inode *inode)
 {
 	struct resv_map *resv_map;
 
-	truncate_hugepages(inode, 0);
+	truncate_hugepages(inode, 0, -1);
 	resv_map = (struct resv_map *)inode->i_mapping->private_data;
 	/* root inode doesn't have the resv_map, so we should check it */
 	if (resv_map)
@@ -410,7 +427,7 @@ static int hugetlb_vmtruncate(struct inode *inode, loff_t offset)
 	if (!RB_EMPTY_ROOT(&mapping->i_mmap))
 		hugetlb_vmtruncate_list(&mapping->i_mmap, pgoff);
 	i_mmap_unlock_write(mapping);
-	truncate_hugepages(inode, offset);
+	truncate_hugepages(inode, offset, -1);
 	return 0;
 }
 
diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index 7b57850..de39705 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -75,7 +75,8 @@ int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 int hugetlb_reserve_pages(struct inode *inode, long from, long to,
 						struct vm_area_struct *vma,
 						vm_flags_t vm_flags);
-void hugetlb_unreserve_pages(struct inode *inode, long offset, long freed);
+void hugetlb_unreserve_pages(struct inode *inode, long start, long end,
+						long freed);
 int dequeue_hwpoisoned_huge_page(struct page *page);
 bool isolate_huge_page(struct page *page, struct list_head *list);
 void putback_active_hugepage(struct page *page);
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index c41b2a0..31e36cd 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -257,6 +257,77 @@ out_nrg:
 	return chg;
 }
 
+static long region_del(struct resv_map *resv, long f, long t)
+{
+	struct list_head *head = &resv->regions;
+	struct file_region *rg, *trg;
+	struct file_region *nrg = NULL;
+	long chg = 0;
+
+	/*
+	 * Locate segments we overlap and etiher split, remove or
+	 * trim the existing regions.  The end of region (t) == -1
+	 * indicates all remaining regions.  Special case t == -1 as
+	 * all comparisons are signed.
+	 */
+	if (t == -1)
+		t = LONG_MAX;
+retry:
+	spin_lock(&resv->lock);
+	list_for_each_entry_safe(rg, trg, head, link) {
+		if (rg->to <= f)
+			continue;
+		if (rg->from >= t)
+			break;
+
+		if (f > rg->from && t < rg->to) { /* must split region */
+			if (!nrg) {
+				spin_unlock(&resv->lock);
+				nrg = kmalloc(sizeof(*nrg),
+						GFP_KERNEL |  __GFP_REPEAT);
+				if (!nrg) {
+					/* FIXME FIXME FIXME FIXME */
+					return -ENOMEM;
+				}
+				goto retry;
+			}
+
+			chg += t - f;
+
+			/* new entry for end of split region */
+			nrg->from = t;
+			nrg->to = rg->to;
+			INIT_LIST_HEAD(&nrg->link);
+
+			/* original entry is trimmed */
+			rg->to = f;
+
+			list_add(&nrg->link, &rg->link);
+			nrg = NULL;
+			break;
+		}
+
+		if (f <= rg->from && t >= rg->to) { /* remove entire region */
+			chg += rg->to - rg->from;
+			list_del(&rg->link);
+			kfree(rg);
+			continue;
+		}
+
+		if (f <= rg->from) {	/* trim beginning of region */
+			chg += t - rg->from;
+			rg->from = t;
+		} else {		/* trim end of region */
+			chg += rg->to - f;
+			rg->to = f;
+		}
+	}
+
+	spin_unlock(&resv->lock);
+	kfree(nrg);
+	return chg;
+}
+
 static long region_truncate(struct resv_map *resv, long end)
 {
 	struct list_head *head = &resv->regions;
@@ -3510,7 +3581,8 @@ out_err:
 	return ret;
 }
 
-void hugetlb_unreserve_pages(struct inode *inode, long offset, long freed)
+void hugetlb_unreserve_pages(struct inode *inode, long start, long end,
+								long freed)
 {
 	struct hstate *h = hstate_inode(inode);
 	struct resv_map *resv_map = inode_resv_map(inode);
@@ -3518,7 +3590,7 @@ void hugetlb_unreserve_pages(struct inode *inode, long offset, long freed)
 	struct hugepage_subpool *spool = subpool_inode(inode);
 
 	if (resv_map)
-		chg = region_truncate(resv_map, offset);
+		chg = region_del(resv_map, start, end);
 	spin_lock(&inode->i_lock);
 	inode->i_blocks -= (blocks_per_huge_page(h) * freed);
 	spin_unlock(&inode->i_lock);
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
