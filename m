Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 013AA6B0011
	for <linux-mm@kvack.org>; Mon, 19 Mar 2018 22:00:48 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id f13so46494qtg.15
        for <linux-mm@kvack.org>; Mon, 19 Mar 2018 19:00:47 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id 49si744289qtq.25.2018.03.19.19.00.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Mar 2018 19:00:47 -0700 (PDT)
From: jglisse@redhat.com
Subject: [PATCH 09/15] mm/hmm: cleanup special vma handling (VM_SPECIAL)
Date: Mon, 19 Mar 2018 22:00:31 -0400
Message-Id: <20180320020038.3360-10-jglisse@redhat.com>
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

Special vma (one with any of the VM_SPECIAL flags) can not be access by
device because there is no consistent model across device drivers on
those vma and their backing memory.

This patch directly use hmm_range struct for hmm_pfns_special() argument
as it is always affecting the whole vma and thus the whole range.

It also make behavior consistent after this patch both hmm_vma_fault()
and hmm_vma_get_pfns() returns -EINVAL when facing such vma. Previously
hmm_vma_fault() returned 0 and hmm_vma_get_pfns() return -EINVAL but
both were filling the HMM pfn array with special entry.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Reviewed-by: John Hubbard <jhubbard@nvidia.com>
Cc: Evgeny Baskakov <ebaskakov@nvidia.com>
Cc: Ralph Campbell <rcampbell@nvidia.com>
Cc: Mark Hairgrove <mhairgrove@nvidia.com>
---
 mm/hmm.c | 40 ++++++++++++++++++++--------------------
 1 file changed, 20 insertions(+), 20 deletions(-)

diff --git a/mm/hmm.c b/mm/hmm.c
index b4db0b1b709a..2df69a95c5ab 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -300,14 +300,6 @@ static int hmm_vma_do_fault(struct mm_walk *walk,
 	return -EAGAIN;
 }
 
-static void hmm_pfns_special(uint64_t *pfns,
-			     unsigned long addr,
-			     unsigned long end)
-{
-	for (; addr < end; addr += PAGE_SIZE, pfns++)
-		*pfns = HMM_PFN_SPECIAL;
-}
-
 static int hmm_pfns_bad(unsigned long addr,
 			unsigned long end,
 			struct mm_walk *walk)
@@ -505,6 +497,14 @@ static int hmm_vma_walk_pmd(pmd_t *pmdp,
 	return 0;
 }
 
+static void hmm_pfns_special(struct hmm_range *range)
+{
+	unsigned long addr = range->start, i = 0;
+
+	for (; addr < range->end; addr += PAGE_SIZE, i++)
+		range->pfns[i] = HMM_PFN_SPECIAL;
+}
+
 /*
  * hmm_vma_get_pfns() - snapshot CPU page table for a range of virtual addresses
  * @range: range being snapshotted
@@ -529,12 +529,6 @@ int hmm_vma_get_pfns(struct hmm_range *range)
 	struct mm_walk mm_walk;
 	struct hmm *hmm;
 
-	/* FIXME support hugetlb fs */
-	if (is_vm_hugetlb_page(vma) || (vma->vm_flags & VM_SPECIAL)) {
-		hmm_pfns_special(range->pfns, range->start, range->end);
-		return -EINVAL;
-	}
-
 	/* Sanity check, this really should not happen ! */
 	if (range->start < vma->vm_start || range->start >= vma->vm_end)
 		return -EINVAL;
@@ -548,6 +542,12 @@ int hmm_vma_get_pfns(struct hmm_range *range)
 	if (!hmm->mmu_notifier.ops)
 		return -EINVAL;
 
+	/* FIXME support hugetlb fs */
+	if (is_vm_hugetlb_page(vma) || (vma->vm_flags & VM_SPECIAL)) {
+		hmm_pfns_special(range);
+		return -EINVAL;
+	}
+
 	if (!(vma->vm_flags & VM_READ)) {
 		/*
 		 * If vma do not allow read access, then assume that it does
@@ -716,6 +716,12 @@ int hmm_vma_fault(struct hmm_range *range, bool write, bool block)
 	if (!hmm->mmu_notifier.ops)
 		return -EINVAL;
 
+	/* FIXME support hugetlb fs */
+	if (is_vm_hugetlb_page(vma) || (vma->vm_flags & VM_SPECIAL)) {
+		hmm_pfns_special(range);
+		return -EINVAL;
+	}
+
 	if (!(vma->vm_flags & VM_READ)) {
 		/*
 		 * If vma do not allow read access, then assume that it does
@@ -727,12 +733,6 @@ int hmm_vma_fault(struct hmm_range *range, bool write, bool block)
 		return -EPERM;
 	}
 
-	/* FIXME support hugetlb fs */
-	if (is_vm_hugetlb_page(vma) || (vma->vm_flags & VM_SPECIAL)) {
-		hmm_pfns_special(range->pfns, range->start, range->end);
-		return 0;
-	}
-
 	/* Initialize range to track CPU page table update */
 	spin_lock(&hmm->lock);
 	range->valid = true;
-- 
2.14.3
