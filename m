Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 89802280274
	for <linux-mm@kvack.org>; Sun, 25 Sep 2016 22:40:21 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id 21so362037085pfy.3
        for <linux-mm@kvack.org>; Sun, 25 Sep 2016 19:40:21 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id v70si22531064pfa.220.2016.09.25.19.40.19
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 25 Sep 2016 19:40:20 -0700 (PDT)
From: zhongjiang <zhongjiang@huawei.com>
Subject: [PATCH] mm: remove unnecessary condition in remove_inode_hugepages
Date: Mon, 26 Sep 2016 10:34:13 +0800
Message-ID: <1474857253-35702-1-git-send-email-zhongjiang@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mike.kravetz@oracle.com, akpm@linux-foundation.org
Cc: mhocko@kernel.org, n-horiguchi@ah.jp.nec.com, linux-mm@kvack.org

From: zhong jiang <zhongjiang@huawei.com>

when the huge page is added to the page cahce (huge_add_to_page_cache),
the page private flag will be cleared. since this code
(remove_inode_hugepages) will only be called for pages in the
page cahce, PagePrivate(page) will always be false.

The patch remove the code without any functional change.

Signed-off-by: zhong jiang <zhongjiang@huawei.com>
---
 fs/hugetlbfs/inode.c    | 10 ++++------
 include/linux/hugetlb.h |  2 +-
 mm/hugetlb.c            |  4 ++--
 3 files changed, 7 insertions(+), 9 deletions(-)

diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index 4ea71eb..81f8bbf4 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -458,18 +458,16 @@ static void remove_inode_hugepages(struct inode *inode, loff_t lstart,
 			 * cache (remove_huge_page) BEFORE removing the
 			 * region/reserve map (hugetlb_unreserve_pages).  In
 			 * rare out of memory conditions, removal of the
-			 * region/reserve map could fail.  Before free'ing
-			 * the page, note PagePrivate which is used in case
-			 * of error.
+			 * region/reserve map could fail. Correspondingly,
+			 * the subpool and global reserve usage count can need
+			 * to be adjusted.
 			 */
-			rsv_on_error = !PagePrivate(page);
 			remove_huge_page(page);
 			freed++;
 			if (!truncate_op) {
 				if (unlikely(hugetlb_unreserve_pages(inode,
 							next, next + 1, 1)))
-					hugetlb_fix_reserve_counts(inode,
-								rsv_on_error);
+					hugetlb_fix_reserve_counts(inode);
 			}
 
 			unlock_page(page);
diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index c26d463..d2e0fc5 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -90,7 +90,7 @@ int dequeue_hwpoisoned_huge_page(struct page *page);
 bool isolate_huge_page(struct page *page, struct list_head *list);
 void putback_active_hugepage(struct page *page);
 void free_huge_page(struct page *page);
-void hugetlb_fix_reserve_counts(struct inode *inode, bool restore_reserve);
+void hugetlb_fix_reserve_counts(struct inode *inode);
 extern struct mutex *hugetlb_fault_mutex_table;
 u32 hugetlb_fault_mutex_hash(struct hstate *h, struct mm_struct *mm,
 				struct vm_area_struct *vma,
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 87e11d8..28a079a 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -567,13 +567,13 @@ retry:
  * appear as a "reserved" entry instead of simply dangling with incorrect
  * counts.
  */
-void hugetlb_fix_reserve_counts(struct inode *inode, bool restore_reserve)
+void hugetlb_fix_reserve_counts(struct inode *inode)
 {
 	struct hugepage_subpool *spool = subpool_inode(inode);
 	long rsv_adjust;
 
 	rsv_adjust = hugepage_subpool_get_pages(spool, 1);
-	if (restore_reserve && rsv_adjust) {
+	if (rsv_adjust) {
 		struct hstate *h = hstate_inode(inode);
 
 		hugetlb_acct_memory(h, 1);
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
