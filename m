Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f53.google.com (mail-oi0-f53.google.com [209.85.218.53])
	by kanga.kvack.org (Postfix) with ESMTP id A05CA6B0253
	for <linux-mm@kvack.org>; Tue, 10 Nov 2015 20:43:15 -0500 (EST)
Received: by oiww189 with SMTP id w189so8632749oiw.3
        for <linux-mm@kvack.org>; Tue, 10 Nov 2015 17:43:15 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id jb4si2871252obb.59.2015.11.10.17.43.13
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Nov 2015 17:43:14 -0800 (PST)
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
	by aserp1040.oracle.com (Sentrion-MTA-4.3.2/Sentrion-MTA-4.3.2) with ESMTP id tAB1hDIo027457
	(version=TLSv1 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-mm@kvack.org>; Wed, 11 Nov 2015 01:43:13 GMT
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by aserv0022.oracle.com (8.13.8/8.13.8) with ESMTP id tAB1hDFD008451
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <linux-mm@kvack.org>; Wed, 11 Nov 2015 01:43:13 GMT
Received: from abhmp0009.oracle.com (abhmp0009.oracle.com [141.146.116.15])
	by userv0122.oracle.com (8.13.8/8.13.8) with ESMTP id tAB1hCnT020923
	for <linux-mm@kvack.org>; Wed, 11 Nov 2015 01:43:12 GMT
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [PATCH v2] mm/hugetlbfs Fix bugs in fallocate hole punch of areas with holes
Date: Tue, 10 Nov 2015 17:38:01 -0800
Message-Id: <1447205881-11629-1-git-send-email-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lnux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Davidlohr Bueso <dave@stgolabs.net>, Mike Kravetz <mike.kravetz@oracle.com>

This is against linux-stable 4.3.  Will send to stable@vger.kernel.org
when Ack'ed here.

Hugh Dickins pointed out problems with the new hugetlbfs fallocate
hole punch code.  These problems are in the routine remove_inode_hugepages
and mostly occur in the case where there are holes in the range of
pages to be removed.  These holes could be the result of a previous hole
punch or simply sparse allocation.

remove_inode_hugepages handles both hole punch and truncate operations.
Page index handling was fixed/cleaned up so that the loop index always
matches the page being processed.  The code now only makes a single pass
through the range of pages as it was determined page faults could not
race with truncate.  A cond_resched() was added after removing up to
PAGEVEC_SIZE pages.

Some totally unnecessary code in hugetlbfs_fallocate() that remained from
early development was also removed.

v2:
  Make remove_inode_hugepages simpler after verifying truncate can not
  race with page faults here.

Fixes: b5cec28d36f5 ("hugetlbfs: truncate_hugepages() takes a range of pages")
Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
---
 fs/hugetlbfs/inode.c | 57 ++++++++++++++++++++++++++--------------------------
 1 file changed, 29 insertions(+), 28 deletions(-)

diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index 316adb9..8290f39 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -332,12 +332,15 @@ static void remove_huge_page(struct page *page)
  * truncation is indicated by end of range being LLONG_MAX
  *	In this case, we first scan the range and release found pages.
  *	After releasing pages, hugetlb_unreserve_pages cleans up region/reserv
- *	maps and global counts.
+ *	maps and global counts.  Page faults can not race with truncation
+ *	in this routine.  hugetlb_no_page() prevents page faults in the
+ *	truncated range.
  * hole punch is indicated if end is not LLONG_MAX
  *	In the hole punch case we scan the range and release found pages.
  *	Only when releasing a page is the associated region/reserv map
  *	deleted.  The region/reserv map for ranges without associated
- *	pages are not modified.
+ *	pages are not modified.  Page faults can race with hole punch.
+ *	This is indicated if we find a mapped page.
  * Note: If the passed end of range value is beyond the end of file, but
  * not LLONG_MAX this routine still performs a hole punch operation.
  */
@@ -361,44 +364,38 @@ static void remove_inode_hugepages(struct inode *inode, loff_t lstart,
 	next = start;
 	while (next < end) {
 		/*
-		 * Make sure to never grab more pages that we
-		 * might possibly need.
+		 * Don't grab more pages than the number left in the range.
 		 */
 		if (end - next < lookup_nr)
 			lookup_nr = end - next;
 
 		/*
-		 * This pagevec_lookup() may return pages past 'end',
-		 * so we must check for page->index > end.
+		 * When no more pages are found, we are done.
 		 */
-		if (!pagevec_lookup(&pvec, mapping, next, lookup_nr)) {
-			if (next == start)
-				break;
-			next = start;
-			continue;
-		}
+		if (!pagevec_lookup(&pvec, mapping, next, lookup_nr))
+			break;
 
 		for (i = 0; i < pagevec_count(&pvec); ++i) {
 			struct page *page = pvec.pages[i];
 			u32 hash;
 
+			/*
+			 * The page (index) could be beyond end.  This is
+			 * only possible in the punch hole case as end is
+			 * max page offset in the truncate case.
+			 */
+			next = page->index;
+			if (next >= end)
+				break;
+
 			hash = hugetlb_fault_mutex_hash(h, current->mm,
 							&pseudo_vma,
 							mapping, next, 0);
 			mutex_lock(&hugetlb_fault_mutex_table[hash]);
 
 			lock_page(page);
-			if (page->index >= end) {
-				unlock_page(page);
-				mutex_unlock(&hugetlb_fault_mutex_table[hash]);
-				next = end;	/* we are done */
-				break;
-			}
-
 			/*
-			 * If page is mapped, it was faulted in after being
-			 * unmapped.  Do nothing in this race case.  In the
-			 * normal case page is not mapped.
+			 * In the normal case the page is not mapped.
 			 */
 			if (!page_mapped(page)) {
 				bool rsv_on_error = !PagePrivate(page);
@@ -421,17 +418,24 @@ static void remove_inode_hugepages(struct inode *inode, loff_t lstart,
 						hugetlb_fix_reserve_counts(
 							inode, rsv_on_error);
 				}
+			} else {
+				/*
+				 * If page is mapped, it was faulted in after
+				 * being unmapped.  It indicates a race between
+				 * hole punch and page fault.  Do nothing in
+				 * this case.  Getting here in a truncate
+				 * operation is a bug.
+				 */
+				BUG_ON(truncate_op);
 			}
 
-			if (page->index > next)
-				next = page->index;
-
 			++next;
 			unlock_page(page);
 
 			mutex_unlock(&hugetlb_fault_mutex_table[hash]);
 		}
 		huge_pagevec_release(&pvec);
+		cond_resched();
 	}
 
 	if (truncate_op)
@@ -647,9 +651,6 @@ static long hugetlbfs_fallocate(struct file *file, int mode, loff_t offset,
 	if (!(mode & FALLOC_FL_KEEP_SIZE) && offset + len > inode->i_size)
 		i_size_write(inode, offset + len);
 	inode->i_ctime = CURRENT_TIME;
-	spin_lock(&inode->i_lock);
-	inode->i_private = NULL;
-	spin_unlock(&inode->i_lock);
 out:
 	mutex_unlock(&inode->i_mutex);
 	return error;
-- 
2.4.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
