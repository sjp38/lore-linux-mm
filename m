Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f52.google.com (mail-oi0-f52.google.com [209.85.218.52])
	by kanga.kvack.org (Postfix) with ESMTP id 9B9EE6B006E
	for <linux-mm@kvack.org>; Thu, 11 Jun 2015 17:02:24 -0400 (EDT)
Received: by oiha141 with SMTP id a141so10463935oih.0
        for <linux-mm@kvack.org>; Thu, 11 Jun 2015 14:02:24 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id w206si1211713oib.41.2015.06.11.14.02.22
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Jun 2015 14:02:22 -0700 (PDT)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [RFC v4 PATCH 2/9] mm/hugetlb: expose hugetlb fault mutex for use by fallocate
Date: Thu, 11 Jun 2015 14:01:33 -0700
Message-Id: <1434056500-2434-3-git-send-email-mike.kravetz@oracle.com>
In-Reply-To: <1434056500-2434-1-git-send-email-mike.kravetz@oracle.com>
References: <1434056500-2434-1-git-send-email-mike.kravetz@oracle.com>
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
 include/linux/hugetlb.h | 10 ++++++++++
 mm/hugetlb.c            | 20 ++++++++++++++++----
 2 files changed, 26 insertions(+), 4 deletions(-)

diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index 2050261..bbd072e 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -85,6 +85,16 @@ int dequeue_hwpoisoned_huge_page(struct page *page);
 bool isolate_huge_page(struct page *page, struct list_head *list);
 void putback_active_hugepage(struct page *page);
 void free_huge_page(struct page *page);
+u32 hugetlb_fault_mutex_shared_hash(struct address_space *mapping, pgoff_t idx);
+extern struct mutex *htlb_fault_mutex_table;
+static inline void hugetlb_fault_mutex_lock(u32 hash)
+{
+	mutex_lock(&htlb_fault_mutex_table[hash]);
+}
+static inline void hugetlb_fault_mutex_unlock(u32 hash)
+{
+	mutex_unlock(&htlb_fault_mutex_table[hash]);
+}
 
 #ifdef CONFIG_ARCH_WANT_HUGE_PMD_SHARE
 pte_t *huge_pmd_share(struct mm_struct *mm, unsigned long addr, pud_t *pud);
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 3fc2359..f617cb6 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -64,7 +64,7 @@ DEFINE_SPINLOCK(hugetlb_lock);
  * prevent spurious OOMs when the hugepage pool is fully utilized.
  */
 static int num_fault_mutexes;
-static struct mutex *htlb_fault_mutex_table ____cacheline_aligned_in_smp;
+struct mutex *htlb_fault_mutex_table ____cacheline_aligned_in_smp;
 
 /* Forward declaration */
 static int hugetlb_acct_memory(struct hstate *h, long delta);
@@ -3324,7 +3324,8 @@ static u32 fault_mutex_hash(struct hstate *h, struct mm_struct *mm,
 	unsigned long key[2];
 	u32 hash;
 
-	if (vma->vm_flags & VM_SHARED) {
+	/* !vma implies this was called from hugetlbfs fallocate code */
+	if (!vma || vma->vm_flags & VM_SHARED) {
 		key[0] = (unsigned long) mapping;
 		key[1] = idx;
 	} else {
@@ -3350,6 +3351,17 @@ static u32 fault_mutex_hash(struct hstate *h, struct mm_struct *mm,
 }
 #endif
 
+/*
+ * Interface for use by hugetlbfs fallocate code.  Faults must be
+ * synchronized with page adds or deletes by fallocate.  fallocate
+ * only deals with shared mappings.  See also hugetlb_fault_mutex_lock
+ * and hugetlb_fault_mutex_unlock.
+ */
+u32 hugetlb_fault_mutex_shared_hash(struct address_space *mapping, pgoff_t idx)
+{
+	return fault_mutex_hash(NULL, NULL, NULL, mapping, idx, 0);
+}
+
 int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 			unsigned long address, unsigned int flags)
 {
@@ -3390,7 +3402,7 @@ int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	 * the same page in the page cache.
 	 */
 	hash = fault_mutex_hash(h, mm, vma, mapping, idx, address);
-	mutex_lock(&htlb_fault_mutex_table[hash]);
+	hugetlb_fault_mutex_lock(hash);
 
 	entry = huge_ptep_get(ptep);
 	if (huge_pte_none(entry)) {
@@ -3473,7 +3485,7 @@ out_ptl:
 		put_page(pagecache_page);
 	}
 out_mutex:
-	mutex_unlock(&htlb_fault_mutex_table[hash]);
+	hugetlb_fault_mutex_unlock(hash);
 	/*
 	 * Generally it's safe to hold refcount during waiting page lock. But
 	 * here we just wait to defer the next page fault to avoid busy loop and
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
