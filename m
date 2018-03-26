Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id F3DF66B000A
	for <linux-mm@kvack.org>; Mon, 26 Mar 2018 17:30:16 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id m188so12654669qkd.15
        for <linux-mm@kvack.org>; Mon, 26 Mar 2018 14:30:16 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id p42si1095929qtc.74.2018.03.26.14.30.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Mar 2018 14:30:16 -0700 (PDT)
From: jglisse@redhat.com
Subject: [PATCH 1/2] mm/hmm: do not ignore specific pte fault flag in hmm_vma_fault()
Date: Mon, 26 Mar 2018 17:30:08 -0400
Message-Id: <20180326213009.2460-2-jglisse@redhat.com>
In-Reply-To: <20180326213009.2460-1-jglisse@redhat.com>
References: <20180326213009.2460-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Ralph Campbell <rcampbell@nvidia.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Evgeny Baskakov <ebaskakov@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, John Hubbard <jhubbard@nvidia.com>

From: Ralph Campbell <rcampbell@nvidia.com>

Save requested fault flags from caller supplied pfns array before
overwriting it with the special none value. Without this we would
not fault on all cases requested by caller, leading to caller calling
us in a loop unless something else did change the CPU page table.

Signed-off-by: Ralph Campbell <rcampbell@nvidia.com>
Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Cc: Evgeny Baskakov <ebaskakov@nvidia.com>
Cc: Mark Hairgrove <mhairgrove@nvidia.com>
Cc: John Hubbard <jhubbard@nvidia.com>
---
 mm/hmm.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/mm/hmm.c b/mm/hmm.c
index e4742f6f1e05..ba912da1c1a1 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -498,10 +498,11 @@ static int hmm_vma_handle_pte(struct mm_walk *walk, unsigned long addr,
 	bool fault, write_fault;
 	uint64_t cpu_flags;
 	pte_t pte = *ptep;
+	uint64_t orig_pfn = *pfn;
 
 	*pfn = range->values[HMM_PFN_NONE];
 	cpu_flags = pte_to_hmm_pfn_flags(range, pte);
-	hmm_pte_need_fault(hmm_vma_walk, *pfn, cpu_flags,
+	hmm_pte_need_fault(hmm_vma_walk, orig_pfn, cpu_flags,
 			   &fault, &write_fault);
 
 	if (pte_none(pte)) {
@@ -528,7 +529,7 @@ static int hmm_vma_handle_pte(struct mm_walk *walk, unsigned long addr,
 				range->flags[HMM_PFN_DEVICE_PRIVATE];
 			cpu_flags |= is_write_device_private_entry(entry) ?
 				range->flags[HMM_PFN_WRITE] : 0;
-			hmm_pte_need_fault(hmm_vma_walk, *pfn, cpu_flags,
+			hmm_pte_need_fault(hmm_vma_walk, orig_pfn, cpu_flags,
 					   &fault, &write_fault);
 			if (fault || write_fault)
 				goto fault;
-- 
2.14.3
