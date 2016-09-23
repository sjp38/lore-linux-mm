Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f198.google.com (mail-yw0-f198.google.com [209.85.161.198])
	by kanga.kvack.org (Postfix) with ESMTP id CB9AD28025D
	for <linux-mm@kvack.org>; Thu, 22 Sep 2016 21:57:25 -0400 (EDT)
Received: by mail-yw0-f198.google.com with SMTP id u82so204739685ywc.0
        for <linux-mm@kvack.org>; Thu, 22 Sep 2016 18:57:25 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id o65si1894955ywb.360.2016.09.22.18.57.22
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 22 Sep 2016 18:57:25 -0700 (PDT)
Message-ID: <57E48B30.2000303@huawei.com>
Date: Fri, 23 Sep 2016 09:53:52 +0800
From: zhong jiang <zhongjiang@huawei.com>
MIME-Version: 1.0
Subject: [RFC] remove unnecessary condition in remove_inode_hugepages
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>, Michal Hocko <mhocko@kernel.org>, David Rientjes <rientjes@google.com>, Vlastimil Babka <vbabka@suse.cz>, Hugh Dickins <hughd@google.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>


At present, we need to call hugetlb_fix_reserve_count when hugetlb_unrserve_pages fails,
and PagePrivate will decide hugetlb reserves counts.

we obtain the page from page cache. and use page both lock_page and mutex_lock.
alloc_huge_page add page to page chace always hold lock page, then bail out clearpageprivate
before unlock page. 

but I' m not sure  it is right  or I miss the points.


diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index 4ea71eb..010723b 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -462,14 +462,12 @@ static void remove_inode_hugepages(struct inode *inode, loff_t lstart,
                         * the page, note PagePrivate which is used in case
                         * of error.
                         */
-                       rsv_on_error = !PagePrivate(page);
                        remove_huge_page(page);
                        freed++;
                        if (!truncate_op) {
                                if (unlikely(hugetlb_unreserve_pages(inode,
                                                        next, next + 1, 1)))
-                                       hugetlb_fix_reserve_counts(inode,
-                                                               rsv_on_error);
+                                       hugetlb_fix_reserve_counts(inode)
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
-       if (restore_reserve && rsv_adjust) {
+       if (rsv_adjust) {
                struct hstate *h = hstate_inode(inode);

                hugetlb_acct_memory(h, 1);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
