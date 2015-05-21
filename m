Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 48F626B016A
	for <linux-mm@kvack.org>; Thu, 21 May 2015 11:48:49 -0400 (EDT)
Received: by pabru16 with SMTP id ru16so109445768pab.1
        for <linux-mm@kvack.org>; Thu, 21 May 2015 08:48:49 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id ez4si4428508pbc.196.2015.05.21.08.48.45
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 May 2015 08:48:47 -0700 (PDT)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [RFC v3 PATCH 04/10] mm/hugetlb: expose hugetlb fault mutex for use by fallocate
Date: Thu, 21 May 2015 08:47:38 -0700
Message-Id: <1432223264-4414-5-git-send-email-mike.kravetz@oracle.com>
In-Reply-To: <1432223264-4414-1-git-send-email-mike.kravetz@oracle.com>
References: <1432223264-4414-1-git-send-email-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <dave@stgolabs.net>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Christoph Hellwig <hch@infradead.org>, Mike Kravetz <mike.kravetz@oracle.com>

hugetlb page faults are currently synchronized by the table of
mutexes (htlb_fault_mutex_table).  fallocate code will need to
synchronize with the page fault code when it allocates or
deletes pages.  Expose interfaces so that fallocate operations
can be synchronized with page faults.

Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
---
 include/linux/hugetlb.h |  3 +++
 mm/hugetlb.c            | 23 ++++++++++++++++++++++-
 2 files changed, 25 insertions(+), 1 deletion(-)

diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index fd337f2..d0d033e 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -82,6 +82,9 @@ void putback_active_hugepage(struct page *page);
 bool is_hugepage_active(struct page *page);
 void free_huge_page(struct page *page);
 void hugetlb_fix_reserve_counts(struct inode *inode, bool restore_reserve);
+u32 hugetlb_fault_mutex_shared_hash(struct address_space *mapping, pgoff_t idx);
+void hugetlb_fault_mutex_lock(u32 hash);
+void hugetlb_fault_mutex_unlock(u32 hash);
 
 #ifdef CONFIG_ARCH_WANT_HUGE_PMD_SHARE
 pte_t *huge_pmd_share(struct mm_struct *mm, unsigned long addr, pud_t *pud);
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 620cc9e..df0d32a 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -3183,7 +3183,8 @@ static u32 fault_mutex_hash(struct hstate *h, struct mm_struct *mm,
 	unsigned long key[2];
 	u32 hash;
 
-	if (vma->vm_flags & VM_SHARED) {
+	/* !vma implies this was called from hugetlbfs fallocate code */
+	if (!vma || vma->vm_flags & VM_SHARED) {
 		key[0] = (unsigned long) mapping;
 		key[1] = idx;
 	} else {
@@ -3209,6 +3210,26 @@ static u32 fault_mutex_hash(struct hstate *h, struct mm_struct *mm,
 }
 #endif
 
+/*
+ * Interfaces to the fault mutex routines for use by hugetlbfs
+ * fallocate code.  Faults must be synchronized with page adds or
+ * deletes by fallocate.  fallocate only deals with shared mappings.
+ */
+u32 hugetlb_fault_mutex_shared_hash(struct address_space *mapping, pgoff_t idx)
+{
+	return fault_mutex_hash(NULL, NULL, NULL, mapping, idx, 0);
+}
+
+void hugetlb_fault_mutex_lock(u32 hash)
+{
+	mutex_lock(&htlb_fault_mutex_table[hash]);
+}
+
+void hugetlb_fault_mutex_unlock(u32 hash)
+{
+	mutex_unlock(&htlb_fault_mutex_table[hash]);
+}
+
 int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 			unsigned long address, unsigned int flags)
 {
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
