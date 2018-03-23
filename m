Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3528B6B0068
	for <linux-mm@kvack.org>; Thu, 22 Mar 2018 20:55:54 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id 19so6645636qkk.13
        for <linux-mm@kvack.org>; Thu, 22 Mar 2018 17:55:54 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id n40si6520542qtc.334.2018.03.22.17.55.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Mar 2018 17:55:53 -0700 (PDT)
From: jglisse@redhat.com
Subject: [PATCH 09/15] mm/hmm: cleanup special vma handling (VM_SPECIAL)
Date: Thu, 22 Mar 2018 20:55:21 -0400
Message-Id: <20180323005527.758-10-jglisse@redhat.com>
In-Reply-To: <20180323005527.758-1-jglisse@redhat.com>
References: <20180323005527.758-1-jglisse@redhat.com>
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
index b69f30fc064b..a93c1e35df91 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -324,14 +324,6 @@ static int hmm_vma_do_fault(struct mm_walk *walk,
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
@@ -529,6 +521,14 @@ static int hmm_vma_walk_pmd(pmd_t *pmdp,
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
@@ -553,12 +553,6 @@ int hmm_vma_get_pfns(struct hmm_range *range)
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
@@ -572,6 +566,12 @@ int hmm_vma_get_pfns(struct hmm_range *range)
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
@@ -740,6 +740,12 @@ int hmm_vma_fault(struct hmm_range *range, bool write, bool block)
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
@@ -751,12 +757,6 @@ int hmm_vma_fault(struct hmm_range *range, bool write, bool block)
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
