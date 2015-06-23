Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id F04606B006E
	for <linux-mm@kvack.org>; Mon, 22 Jun 2015 20:39:40 -0400 (EDT)
Received: by pabvl15 with SMTP id vl15so98345068pab.1
        for <linux-mm@kvack.org>; Mon, 22 Jun 2015 17:39:40 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id v1si5556051pdr.166.2015.06.22.17.39.36
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Jun 2015 17:39:37 -0700 (PDT)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [RFC v5 PATCH 2/9] mm/hugetlb: expose hugetlb fault mutex for use by fallocate
Date: Mon, 22 Jun 2015 17:38:32 -0700
Message-Id: <1435019919-29225-3-git-send-email-mike.kravetz@oracle.com>
In-Reply-To: <1435019919-29225-1-git-send-email-mike.kravetz@oracle.com>
References: <1435019919-29225-1-git-send-email-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <dave@stgolabs.net>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Christoph Hellwig <hch@infradead.org>, Mike Kravetz <mike.kravetz@oracle.com>

hugetlb page faults are currently synchronized by the table of
mutexes (htlb_fault_mutex_table).  fallocate code will need to
synchronize with the page fault code when it allocates or
deletes pages.  Expose interfaces so that fallocate operations
can be synchronized with page faults.  Minor name changes to
be more consistent with other global hugetlb symbols.

Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
---
 include/linux/hugetlb.h |  5 +++++
 mm/hugetlb.c            | 20 ++++++++++----------
 2 files changed, 15 insertions(+), 10 deletions(-)

diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index 2050261..33c6b32 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -85,6 +85,11 @@ int dequeue_hwpoisoned_huge_page(struct page *page);
 bool isolate_huge_page(struct page *page, struct list_head *list);
 void putback_active_hugepage(struct page *page);
 void free_huge_page(struct page *page);
+extern struct mutex *hugetlb_fault_mutex_table;
+u32 hugetlb_fault_mutex_hash(struct hstate *h, struct mm_struct *mm,
+				struct vm_area_struct *vma,
+				struct address_space *mapping,
+				pgoff_t idx, unsigned long address);
 
 #ifdef CONFIG_ARCH_WANT_HUGE_PMD_SHARE
 pte_t *huge_pmd_share(struct mm_struct *mm, unsigned long addr, pud_t *pud);
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 3fc2359..9657cca 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -64,7 +64,7 @@ DEFINE_SPINLOCK(hugetlb_lock);
  * prevent spurious OOMs when the hugepage pool is fully utilized.
  */
 static int num_fault_mutexes;
-static struct mutex *htlb_fault_mutex_table ____cacheline_aligned_in_smp;
+struct mutex *hugetlb_fault_mutex_table ____cacheline_aligned_in_smp;
 
 /* Forward declaration */
 static int hugetlb_acct_memory(struct hstate *h, long delta);
@@ -2347,7 +2347,7 @@ static void __exit hugetlb_exit(void)
 	}
 
 	kobject_put(hugepages_kobj);
-	kfree(htlb_fault_mutex_table);
+	kfree(hugetlb_fault_mutex_table);
 }
 module_exit(hugetlb_exit);
 
@@ -2380,12 +2380,12 @@ static int __init hugetlb_init(void)
 #else
 	num_fault_mutexes = 1;
 #endif
-	htlb_fault_mutex_table =
+	hugetlb_fault_mutex_table =
 		kmalloc(sizeof(struct mutex) * num_fault_mutexes, GFP_KERNEL);
-	BUG_ON(!htlb_fault_mutex_table);
+	BUG_ON(!hugetlb_fault_mutex_table);
 
 	for (i = 0; i < num_fault_mutexes; i++)
-		mutex_init(&htlb_fault_mutex_table[i]);
+		mutex_init(&hugetlb_fault_mutex_table[i]);
 	return 0;
 }
 module_init(hugetlb_init);
@@ -3316,7 +3316,7 @@ backout_unlocked:
 }
 
 #ifdef CONFIG_SMP
-static u32 fault_mutex_hash(struct hstate *h, struct mm_struct *mm,
+u32 hugetlb_fault_mutex_hash(struct hstate *h, struct mm_struct *mm,
 			    struct vm_area_struct *vma,
 			    struct address_space *mapping,
 			    pgoff_t idx, unsigned long address)
@@ -3341,7 +3341,7 @@ static u32 fault_mutex_hash(struct hstate *h, struct mm_struct *mm,
  * For uniprocesor systems we always use a single mutex, so just
  * return 0 and avoid the hashing overhead.
  */
-static u32 fault_mutex_hash(struct hstate *h, struct mm_struct *mm,
+u32 hugetlb_fault_mutex_hash(struct hstate *h, struct mm_struct *mm,
 			    struct vm_area_struct *vma,
 			    struct address_space *mapping,
 			    pgoff_t idx, unsigned long address)
@@ -3389,8 +3389,8 @@ int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	 * get spurious allocation failures if two CPUs race to instantiate
 	 * the same page in the page cache.
 	 */
-	hash = fault_mutex_hash(h, mm, vma, mapping, idx, address);
-	mutex_lock(&htlb_fault_mutex_table[hash]);
+	hash = hugetlb_fault_mutex_hash(h, mm, vma, mapping, idx, address);
+	mutex_lock(&hugetlb_fault_mutex_table[hash]);
 
 	entry = huge_ptep_get(ptep);
 	if (huge_pte_none(entry)) {
@@ -3473,7 +3473,7 @@ out_ptl:
 		put_page(pagecache_page);
 	}
 out_mutex:
-	mutex_unlock(&htlb_fault_mutex_table[hash]);
+	mutex_unlock(&hugetlb_fault_mutex_table[hash]);
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
