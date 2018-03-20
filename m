Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7EC796B0011
	for <linux-mm@kvack.org>; Mon, 19 Mar 2018 22:00:47 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id z83so50309qka.7
        for <linux-mm@kvack.org>; Mon, 19 Mar 2018 19:00:47 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id r11si1634478qkk.72.2018.03.19.19.00.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Mar 2018 19:00:45 -0700 (PDT)
From: jglisse@redhat.com
Subject: [PATCH 07/15] mm/hmm: remove HMM_PFN_READ flag and ignore peculiar architecture v2
Date: Mon, 19 Mar 2018 22:00:29 -0400
Message-Id: <20180320020038.3360-8-jglisse@redhat.com>
In-Reply-To: <20180320020038.3360-1-jglisse@redhat.com>
References: <20180320020038.3360-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Evgeny Baskakov <ebaskakov@nvidia.com>, Ralph Campbell <rcampbell@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>

From: JA(C)rA'me Glisse <jglisse@redhat.com>

Only peculiar architecture allow write without read thus assume that
any valid pfn do allow for read. Note we do not care for write only
because it does make sense with thing like atomic compare and exchange
or any other operations that allow you to get the memory value through
them.

Changed since v1:
  - Fail early on vma without read permission and return an error
  - Improve comments

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Reviewed-by: John Hubbard <jhubbard@nvidia.com>
Cc: Evgeny Baskakov <ebaskakov@nvidia.com>
Cc: Ralph Campbell <rcampbell@nvidia.com>
Cc: Mark Hairgrove <mhairgrove@nvidia.com>
---
 include/linux/hmm.h | 16 +++++++---------
 mm/hmm.c            | 44 ++++++++++++++++++++++++++++++++++----------
 2 files changed, 41 insertions(+), 19 deletions(-)

diff --git a/include/linux/hmm.h b/include/linux/hmm.h
index d0d6760cdada..dd907f614dfe 100644
--- a/include/linux/hmm.h
+++ b/include/linux/hmm.h
@@ -83,8 +83,7 @@ struct hmm;
  * hmm_pfn_t - HMM uses its own pfn type to keep several flags per page
  *
  * Flags:
- * HMM_PFN_VALID: pfn is valid
- * HMM_PFN_READ:  CPU page table has read permission set
+ * HMM_PFN_VALID: pfn is valid. It has, at least, read permission.
  * HMM_PFN_WRITE: CPU page table has write permission set
  * HMM_PFN_ERROR: corresponding CPU page table entry points to poisoned memory
  * HMM_PFN_EMPTY: corresponding CPU page table entry is pte_none()
@@ -97,13 +96,12 @@ struct hmm;
 typedef unsigned long hmm_pfn_t;
 
 #define HMM_PFN_VALID (1 << 0)
-#define HMM_PFN_READ (1 << 1)
-#define HMM_PFN_WRITE (1 << 2)
-#define HMM_PFN_ERROR (1 << 3)
-#define HMM_PFN_EMPTY (1 << 4)
-#define HMM_PFN_SPECIAL (1 << 5)
-#define HMM_PFN_DEVICE_UNADDRESSABLE (1 << 6)
-#define HMM_PFN_SHIFT 7
+#define HMM_PFN_WRITE (1 << 1)
+#define HMM_PFN_ERROR (1 << 2)
+#define HMM_PFN_EMPTY (1 << 3)
+#define HMM_PFN_SPECIAL (1 << 4)
+#define HMM_PFN_DEVICE_UNADDRESSABLE (1 << 5)
+#define HMM_PFN_SHIFT 6
 
 /*
  * hmm_pfn_t_to_page() - return struct page pointed to by a valid hmm_pfn_t
diff --git a/mm/hmm.c b/mm/hmm.c
index 73d4b33d787f..3e61c5af1f98 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -393,11 +393,9 @@ static int hmm_vma_walk_pmd(pmd_t *pmdp,
 	hmm_pfn_t *pfns = range->pfns;
 	unsigned long addr = start, i;
 	bool write_fault;
-	hmm_pfn_t flag;
 	pte_t *ptep;
 
 	i = (addr - range->start) >> PAGE_SHIFT;
-	flag = vma->vm_flags & VM_READ ? HMM_PFN_READ : 0;
 	write_fault = hmm_vma_walk->fault & hmm_vma_walk->write;
 
 again:
@@ -409,6 +407,7 @@ static int hmm_vma_walk_pmd(pmd_t *pmdp,
 
 	if (pmd_devmap(*pmdp) || pmd_trans_huge(*pmdp)) {
 		unsigned long pfn;
+		hmm_pfn_t flag = 0;
 		pmd_t pmd;
 
 		/*
@@ -473,7 +472,6 @@ static int hmm_vma_walk_pmd(pmd_t *pmdp,
 				} else if (write_fault)
 					goto fault;
 				pfns[i] |= HMM_PFN_DEVICE_UNADDRESSABLE;
-				pfns[i] |= flag;
 			} else if (is_migration_entry(entry)) {
 				if (hmm_vma_walk->fault) {
 					pte_unmap(ptep);
@@ -493,7 +491,7 @@ static int hmm_vma_walk_pmd(pmd_t *pmdp,
 		if (write_fault && !pte_write(pte))
 			goto fault;
 
-		pfns[i] = hmm_pfn_t_from_pfn(pte_pfn(pte)) | flag;
+		pfns[i] = hmm_pfn_t_from_pfn(pte_pfn(pte));
 		pfns[i] |= pte_write(pte) ? HMM_PFN_WRITE : 0;
 		continue;
 
@@ -510,7 +508,8 @@ static int hmm_vma_walk_pmd(pmd_t *pmdp,
 /*
  * hmm_vma_get_pfns() - snapshot CPU page table for a range of virtual addresses
  * @range: range being snapshotted
- * Returns: -EINVAL if invalid argument, -ENOMEM out of memory, 0 success
+ * Returns: -EINVAL if invalid argument, -ENOMEM out of memory, -EPERM invalid
+ *          vma permission, 0 success
  *
  * This snapshots the CPU page table for a range of virtual addresses. Snapshot
  * validity is tracked by range struct. See hmm_vma_range_done() for further
@@ -549,6 +548,17 @@ int hmm_vma_get_pfns(struct hmm_range *range)
 	if (!hmm->mmu_notifier.ops)
 		return -EINVAL;
 
+	if (!(vma->vm_flags & VM_READ)) {
+		/*
+		 * If vma do not allow read access, then assume that it does
+		 * not allow write access, either. Architecture that allow
+		 * write without read access are not supported by HMM, because
+		 * operations such has atomic access would not work.
+		 */
+		hmm_pfns_clear(range->pfns, range->start, range->end);
+		return -EPERM;
+	}
+
 	/* Initialize range to track CPU page table update */
 	spin_lock(&hmm->lock);
 	range->valid = true;
@@ -662,6 +672,9 @@ EXPORT_SYMBOL(hmm_vma_range_done);
  *     goto retry;
  *   case 0:
  *     break;
+ *   case -ENOMEM:
+ *   case -EINVAL:
+ *   case -EPERM:
  *   default:
  *     // Handle error !
  *     up_read(&mm->mmap_sem)
@@ -703,11 +716,16 @@ int hmm_vma_fault(struct hmm_range *range, bool write, bool block)
 	if (!hmm->mmu_notifier.ops)
 		return -EINVAL;
 
-	/* Initialize range to track CPU page table update */
-	spin_lock(&hmm->lock);
-	range->valid = true;
-	list_add_rcu(&range->list, &hmm->ranges);
-	spin_unlock(&hmm->lock);
+	if (!(vma->vm_flags & VM_READ)) {
+		/*
+		 * If vma do not allow read access, then assume that it does
+		 * not allow write access, either. Architecture that allow
+		 * write without read access are not supported by HMM, because
+		 * operations such has atomic access would not work.
+		 */
+		hmm_pfns_clear(range->pfns, range->start, range->end);
+		return -EPERM;
+	}
 
 	/* FIXME support hugetlb fs */
 	if (is_vm_hugetlb_page(vma) || (vma->vm_flags & VM_SPECIAL)) {
@@ -715,6 +733,12 @@ int hmm_vma_fault(struct hmm_range *range, bool write, bool block)
 		return 0;
 	}
 
+	/* Initialize range to track CPU page table update */
+	spin_lock(&hmm->lock);
+	range->valid = true;
+	list_add_rcu(&range->list, &hmm->ranges);
+	spin_unlock(&hmm->lock);
+
 	hmm_vma_walk.fault = true;
 	hmm_vma_walk.write = write;
 	hmm_vma_walk.block = block;
-- 
2.14.3
