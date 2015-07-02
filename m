Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f169.google.com (mail-ob0-f169.google.com [209.85.214.169])
	by kanga.kvack.org (Postfix) with ESMTP id 38ECB280246
	for <linux-mm@kvack.org>; Thu,  2 Jul 2015 11:39:36 -0400 (EDT)
Received: by obdbs4 with SMTP id bs4so52195980obd.3
        for <linux-mm@kvack.org>; Thu, 02 Jul 2015 08:39:36 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id u74si4768042oie.50.2015.07.02.08.39.33
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Jul 2015 08:39:33 -0700 (PDT)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [PATCH 03/10] mm/hugetlb: expose hugetlb fault mutex for use by fallocate
Date: Thu,  2 Jul 2015 08:38:39 -0700
Message-Id: <1435851526-4200-4-git-send-email-mike.kravetz@oracle.com>
In-Reply-To: <1435851526-4200-1-git-send-email-mike.kravetz@oracle.com>
References: <1435851526-4200-1-git-send-email-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org
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
index f9c8cb2..43e8511f 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -88,6 +88,11 @@ int dequeue_hwpoisoned_huge_page(struct page *page);
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
index e8c7f68..21e957b 100644
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
@@ -2481,7 +2481,7 @@ static void __exit hugetlb_exit(void)
 	}
 
 	kobject_put(hugepages_kobj);
-	kfree(htlb_fault_mutex_table);
+	kfree(hugetlb_fault_mutex_table);
 }
 module_exit(hugetlb_exit);
 
@@ -2514,12 +2514,12 @@ static int __init hugetlb_init(void)
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
@@ -3453,7 +3453,7 @@ backout_unlocked:
 }
 
 #ifdef CONFIG_SMP
-static u32 fault_mutex_hash(struct hstate *h, struct mm_struct *mm,
+u32 hugetlb_fault_mutex_hash(struct hstate *h, struct mm_struct *mm,
 			    struct vm_area_struct *vma,
 			    struct address_space *mapping,
 			    pgoff_t idx, unsigned long address)
@@ -3478,7 +3478,7 @@ static u32 fault_mutex_hash(struct hstate *h, struct mm_struct *mm,
  * For uniprocesor systems we always use a single mutex, so just
  * return 0 and avoid the hashing overhead.
  */
-static u32 fault_mutex_hash(struct hstate *h, struct mm_struct *mm,
+u32 hugetlb_fault_mutex_hash(struct hstate *h, struct mm_struct *mm,
 			    struct vm_area_struct *vma,
 			    struct address_space *mapping,
 			    pgoff_t idx, unsigned long address)
@@ -3526,8 +3526,8 @@ int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	 * get spurious allocation failures if two CPUs race to instantiate
 	 * the same page in the page cache.
 	 */
-	hash = fault_mutex_hash(h, mm, vma, mapping, idx, address);
-	mutex_lock(&htlb_fault_mutex_table[hash]);
+	hash = hugetlb_fault_mutex_hash(h, mm, vma, mapping, idx, address);
+	mutex_lock(&hugetlb_fault_mutex_table[hash]);
 
 	entry = huge_ptep_get(ptep);
 	if (huge_pte_none(entry)) {
@@ -3612,7 +3612,7 @@ out_ptl:
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
