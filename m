Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 5D26A6B0253
	for <linux-mm@kvack.org>; Mon, 27 Jul 2015 14:55:30 -0400 (EDT)
Received: by padck2 with SMTP id ck2so55741063pad.0
        for <linux-mm@kvack.org>; Mon, 27 Jul 2015 11:55:30 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id an7si46112765pad.131.2015.07.27.11.55.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Jul 2015 11:55:29 -0700 (PDT)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [PATCH-mmotm] mmotm: build fix hugetlbfs fallocate if not CONFIG_NUMA
Date: Mon, 27 Jul 2015 11:54:49 -0700
Message-Id: <1438023289-28208-1-git-send-email-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org, Mike Kravetz <mike.kravetz@oracle.com>

Commit 56bb4d795 introduced a build error if CONFIG_NUMA is not
defined.  When fallocate preallocation allocates pages, it will
use the defined numa policy.  However, if numa is not defined
there is no such policy and no code should reference numa policy.
Create wrappers to isolate policy manipulation code that are a
NOOP in the non-NUMA case.

Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
---
 fs/hugetlbfs/inode.c | 39 ++++++++++++++++++++++++++++++---------
 1 file changed, 30 insertions(+), 9 deletions(-)

diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index d977cae..316adb9 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -85,6 +85,29 @@ static const match_table_t tokens = {
 	{Opt_err,	NULL},
 };
 
+#ifdef CONFIG_NUMA
+static inline void hugetlb_set_vma_policy(struct vm_area_struct *vma,
+					struct inode *inode, pgoff_t index)
+{
+	vma->vm_policy = mpol_shared_policy_lookup(&HUGETLBFS_I(inode)->policy,
+							index);
+}
+
+static inline void hugetlb_drop_vma_policy(struct vm_area_struct *vma)
+{
+	mpol_cond_put(vma->vm_policy);
+}
+#else
+static inline void hugetlb_set_vma_policy(struct vm_area_struct *vma,
+					struct inode *inode, pgoff_t index)
+{
+}
+
+static inline void hugetlb_drop_vma_policy(struct vm_area_struct *vma)
+{
+}
+#endif
+
 static void huge_pagevec_release(struct pagevec *pvec)
 {
 	int i;
@@ -546,9 +569,9 @@ static long hugetlbfs_fallocate(struct file *file, int mode, loff_t offset,
 		goto out;
 
 	/*
-	 * Initialize a pseudo vma that just contains the policy used
-	 * when allocating the huge pages.  The actual policy field
-	 * (vm_policy) is determined based on the index in the loop below.
+	 * Initialize a pseudo vma as this is required by the huge page
+	 * allocation routines.  If NUMA is configured, use page index
+	 * as input to create an allocation policy.
 	 */
 	memset(&pseudo_vma, 0, sizeof(struct vm_area_struct));
 	pseudo_vma.vm_flags = (VM_HUGETLB | VM_MAYSHARE | VM_SHARED);
@@ -574,10 +597,8 @@ static long hugetlbfs_fallocate(struct file *file, int mode, loff_t offset,
 			break;
 		}
 
-		/* Get policy based on index */
-		pseudo_vma.vm_policy =
-			mpol_shared_policy_lookup(&HUGETLBFS_I(inode)->policy,
-							index);
+		/* Set numa allocation policy based on index */
+		hugetlb_set_vma_policy(&pseudo_vma, inode, index);
 
 		/* addr is the offset within the file (zero based) */
 		addr = index * hpage_size;
@@ -592,13 +613,13 @@ static long hugetlbfs_fallocate(struct file *file, int mode, loff_t offset,
 		if (page) {
 			put_page(page);
 			mutex_unlock(&hugetlb_fault_mutex_table[hash]);
-			mpol_cond_put(pseudo_vma.vm_policy);
+			hugetlb_drop_vma_policy(&pseudo_vma);
 			continue;
 		}
 
 		/* Allocate page and add to page cache */
 		page = alloc_huge_page(&pseudo_vma, addr, avoid_reserve);
-		mpol_cond_put(pseudo_vma.vm_policy);
+		hugetlb_drop_vma_policy(&pseudo_vma);
 		if (IS_ERR(page)) {
 			mutex_unlock(&hugetlb_fault_mutex_table[hash]);
 			error = PTR_ERR(page);
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
