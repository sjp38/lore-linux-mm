Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id A87486B000C
	for <linux-mm@kvack.org>; Fri, 16 Mar 2018 15:14:23 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id h62so3457933qkc.20
        for <linux-mm@kvack.org>; Fri, 16 Mar 2018 12:14:23 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id o6si4184974qtm.138.2018.03.16.12.14.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Mar 2018 12:14:22 -0700 (PDT)
From: jglisse@redhat.com
Subject: [PATCH 06/14] mm/hmm: remove HMM_PFN_READ flag and ignore peculiar architecture
Date: Fri, 16 Mar 2018 15:14:11 -0400
Message-Id: <20180316191414.3223-7-jglisse@redhat.com>
In-Reply-To: <20180316191414.3223-1-jglisse@redhat.com>
References: <20180316191414.3223-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Evgeny Baskakov <ebaskakov@nvidia.com>, Ralph Campbell <rcampbell@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, John Hubbard <jhubbard@nvidia.com>

From: JA(C)rA'me Glisse <jglisse@redhat.com>

Only peculiar architecture allow write without read thus assume that
any valid pfn do allow for read. Note we do not care for write only
because it does make sense with thing like atomic compare and exchange
or any other operations that allow you to get the memory value through
them.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Cc: Evgeny Baskakov <ebaskakov@nvidia.com>
Cc: Ralph Campbell <rcampbell@nvidia.com>
Cc: Mark Hairgrove <mhairgrove@nvidia.com>
Cc: John Hubbard <jhubbard@nvidia.com>
---
 include/linux/hmm.h | 14 ++++++--------
 mm/hmm.c            | 28 ++++++++++++++++++++++++----
 2 files changed, 30 insertions(+), 12 deletions(-)

diff --git a/include/linux/hmm.h b/include/linux/hmm.h
index b65e527dd120..4bdc58ffe9f3 100644
--- a/include/linux/hmm.h
+++ b/include/linux/hmm.h
@@ -84,7 +84,6 @@ struct hmm;
  *
  * Flags:
  * HMM_PFN_VALID: pfn is valid
- * HMM_PFN_READ:  CPU page table has read permission set
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
index 49f0f6b337ed..fa3c605c4b96 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -374,11 +374,9 @@ static int hmm_vma_walk_pmd(pmd_t *pmdp,
 	hmm_pfn_t *pfns = range->pfns;
 	unsigned long addr = start, i;
 	bool write_fault;
-	hmm_pfn_t flag;
 	pte_t *ptep;
 
 	i = (addr - range->start) >> PAGE_SHIFT;
-	flag = vma->vm_flags & VM_READ ? HMM_PFN_READ : 0;
 	write_fault = hmm_vma_walk->fault & hmm_vma_walk->write;
 
 again:
@@ -390,6 +388,7 @@ static int hmm_vma_walk_pmd(pmd_t *pmdp,
 
 	if (pmd_devmap(*pmdp) || pmd_trans_huge(*pmdp)) {
 		unsigned long pfn;
+		hmm_pfn_t flag = 0;
 		pmd_t pmd;
 
 		/*
@@ -454,7 +453,6 @@ static int hmm_vma_walk_pmd(pmd_t *pmdp,
 				} else if (write_fault)
 					goto fault;
 				pfns[i] |= HMM_PFN_DEVICE_UNADDRESSABLE;
-				pfns[i] |= flag;
 			} else if (is_migration_entry(entry)) {
 				if (hmm_vma_walk->fault) {
 					pte_unmap(ptep);
@@ -474,7 +472,7 @@ static int hmm_vma_walk_pmd(pmd_t *pmdp,
 		if (write_fault && !pte_write(pte))
 			goto fault;
 
-		pfns[i] = hmm_pfn_t_from_pfn(pte_pfn(pte)) | flag;
+		pfns[i] = hmm_pfn_t_from_pfn(pte_pfn(pte));
 		pfns[i] |= pte_write(pte) ? HMM_PFN_WRITE : 0;
 		continue;
 
@@ -536,6 +534,17 @@ int hmm_vma_get_pfns(struct hmm_range *range)
 	list_add_rcu(&range->list, &hmm->ranges);
 	spin_unlock(&hmm->lock);
 
+	if (!(vma->vm_flags & VM_READ)) {
+		/*
+		 * If vma do not allow read assume it does not allow write as
+		 * only peculiar architecture allow write without read and this
+		 * is not a case we care about (some operation like atomic no
+		 * longer make sense).
+		 */
+		hmm_pfns_clear(range->pfns, range->start, range->end);
+		return 0;
+	}
+
 	hmm_vma_walk.fault = false;
 	hmm_vma_walk.range = range;
 	mm_walk.private = &hmm_vma_walk;
@@ -690,6 +699,17 @@ int hmm_vma_fault(struct hmm_range *range, bool write, bool block)
 	list_add_rcu(&range->list, &hmm->ranges);
 	spin_unlock(&hmm->lock);
 
+	if (!(vma->vm_flags & VM_READ)) {
+		/*
+		 * If vma do not allow read assume it does not allow write as
+		 * only peculiar architecture allow write without read and this
+		 * is not a case we care about (some operation like atomic no
+		 * longer make sense).
+		 */
+		hmm_pfns_clear(range->pfns, range->start, range->end);
+		return 0;
+	}
+
 	/* FIXME support hugetlb fs */
 	if (is_vm_hugetlb_page(vma) || (vma->vm_flags & VM_SPECIAL)) {
 		hmm_pfns_special(range->pfns, range->start, range->end);
-- 
2.14.3
