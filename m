Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f42.google.com (mail-oi0-f42.google.com [209.85.218.42])
	by kanga.kvack.org (Postfix) with ESMTP id 4CF3E82F64
	for <linux-mm@kvack.org>; Fri, 30 Oct 2015 19:40:48 -0400 (EDT)
Received: by oiao187 with SMTP id o187so68273499oia.3
        for <linux-mm@kvack.org>; Fri, 30 Oct 2015 16:40:48 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id o82si5644697oif.96.2015.10.30.16.40.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 30 Oct 2015 16:40:47 -0700 (PDT)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [PATCH] mm/hugetlbfs Fix bugs in fallocate hole punch of areas with holes
Date: Fri, 30 Oct 2015 16:32:12 -0700
Message-Id: <1446247932-11348-1-git-send-email-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Davidlohr Bueso <dave@stgolabs.net>, Mike Kravetz <mike.kravetz@oracle.com>

Hugh Dickins pointed out problems with the new hugetlbfs fallocate
hole punch code.  These problems are in the routine remove_inode_hugepages
and mostly occur in the case where there are holes in the range of
pages to be removed.  These holes could be the result of a previous hole
punch or simply sparse allocation.

remove_inode_hugepages handles both hole punch and truncate operations.
Page index handling was fixed/cleaned up so that holes are properly
handled.  In addition, code was changed to ensure multiple passes of the
address range only happens in the truncate case.  More comments were added
to explain the different actions in each case.  A cond_resched() was added
after removing up to PAGEVEC_SIZE pages.

Some totally unnecessary code in hugetlbfs_fallocate() that remained from
early development was also removed.

Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
---
 fs/hugetlbfs/inode.c | 44 +++++++++++++++++++++++++++++---------------
 1 file changed, 29 insertions(+), 15 deletions(-)

diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index 316adb9..30cf534 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -368,10 +368,25 @@ static void remove_inode_hugepages(struct inode *inode, loff_t lstart,
 			lookup_nr = end - next;
 
 		/*
-		 * This pagevec_lookup() may return pages past 'end',
-		 * so we must check for page->index > end.
+		 * When no more pages are found, take different action for
+		 * hole punch and truncate.
+		 *
+		 * For hole punch, this indicates we have removed each page
+		 * within the range and are done.  Note that pages may have
+		 * been faulted in after being removed in the hole punch case.
+		 * This is OK as long as each page in the range was removed
+		 * once.
+		 *
+		 * For truncate, we need to make sure all pages within the
+		 * range are removed when exiting this routine.  We could
+		 * have raced with a fault that brought in a page after it
+		 * was first removed.  Check the range again until no pages
+		 * are found.
 		 */
 		if (!pagevec_lookup(&pvec, mapping, next, lookup_nr)) {
+			if (!truncate_op)
+				break;
+
 			if (next == start)
 				break;
 			next = start;
@@ -382,19 +397,23 @@ static void remove_inode_hugepages(struct inode *inode, loff_t lstart,
 			struct page *page = pvec.pages[i];
 			u32 hash;
 
+			/*
+			 * The page (index) could be beyond end.  This is
+			 * only possible in the punch hole case as end is
+			 * LLONG_MAX for truncate.
+			 */
+			if (page->index >= end) {
+				next = end;	/* we are done */
+				break;
+			}
+			next = page->index;
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
 			 * If page is mapped, it was faulted in after being
 			 * unmapped.  Do nothing in this race case.  In the
@@ -423,15 +442,13 @@ static void remove_inode_hugepages(struct inode *inode, loff_t lstart,
 				}
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
@@ -647,9 +664,6 @@ static long hugetlbfs_fallocate(struct file *file, int mode, loff_t offset,
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
