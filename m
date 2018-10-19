Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 68CD96B0266
	for <linux-mm@kvack.org>; Fri, 19 Oct 2018 12:04:54 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id n188-v6so35846022qke.6
        for <linux-mm@kvack.org>; Fri, 19 Oct 2018 09:04:54 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n52-v6si8648903qtf.91.2018.10.19.09.04.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Oct 2018 09:04:53 -0700 (PDT)
From: jglisse@redhat.com
Subject: [PATCH 4/6] mm/hmm: properly handle migration pmd v3
Date: Fri, 19 Oct 2018 12:04:40 -0400
Message-Id: <20181019160442.18723-5-jglisse@redhat.com>
In-Reply-To: <20181019160442.18723-1-jglisse@redhat.com>
References: <20181019160442.18723-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.ibm.com>, Zi Yan <zi.yan@cs.rutgers.edu>, Michal Hocko <mhocko@kernel.org>, Ralph Campbell <rcampbell@nvidia.com>, John Hubbard <jhubbard@nvidia.com>

From: JA(C)rA'me Glisse <jglisse@redhat.com>

Before this patch migration pmd entry (!pmd_present()) would have
been treated as a bad entry (pmd_bad() returns true on migration
pmd entry). The outcome was that device driver would believe that
the range covered by the pmd was bad and would either SIGBUS or
simply kill all the device's threads (each device driver decide
how to react when the device tries to access poisonnous or invalid
range of memory).

This patch explicitly handle the case of migration pmd entry which
are non present pmd entry and either wait for the migration to
finish or report empty range (when device is just trying to pre-
fill a range of virtual address and thus do not want to wait or
trigger page fault).

Changed since v1:
  - use is_pmd_migration_entry() instead of open coding the
    equivalent.
Changed since v2:
  - protect is_pmd_migration_entry() with thp_migration_supported()

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Cc: Zi Yan <zi.yan@cs.rutgers.edu>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Ralph Campbell <rcampbell@nvidia.com>
Cc: John Hubbard <jhubbard@nvidia.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
---
 mm/hmm.c | 40 ++++++++++++++++++++++++++++++++++------
 1 file changed, 34 insertions(+), 6 deletions(-)

diff --git a/mm/hmm.c b/mm/hmm.c
index a16678d08127..a7aff319bc5a 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -577,22 +577,42 @@ static int hmm_vma_walk_pmd(pmd_t *pmdp,
 {
 	struct hmm_vma_walk *hmm_vma_walk = walk->private;
 	struct hmm_range *range = hmm_vma_walk->range;
+	struct vm_area_struct *vma = walk->vma;
 	uint64_t *pfns = range->pfns;
 	unsigned long addr = start, i;
 	pte_t *ptep;
+	pmd_t pmd;
 
-	i = (addr - range->start) >> PAGE_SHIFT;
 
 again:
-	if (pmd_none(*pmdp))
+	pmd = READ_ONCE(*pmdp);
+	if (pmd_none(pmd))
 		return hmm_vma_walk_hole(start, end, walk);
 
-	if (pmd_huge(*pmdp) && (range->vma->vm_flags & VM_HUGETLB))
+	if (pmd_huge(pmd) && (range->vma->vm_flags & VM_HUGETLB))
 		return hmm_pfns_bad(start, end, walk);
 
-	if (pmd_devmap(*pmdp) || pmd_trans_huge(*pmdp)) {
-		pmd_t pmd;
+	if (thp_migration_supported() && is_pmd_migration_entry(pmd)) {
+		bool fault, write_fault;
+		unsigned long npages;
+		uint64_t *pfns;
+
+		i = (addr - range->start) >> PAGE_SHIFT;
+		npages = (end - addr) >> PAGE_SHIFT;
+		pfns = &range->pfns[i];
+
+		hmm_range_need_fault(hmm_vma_walk, pfns, npages,
+				     0, &fault, &write_fault);
+		if (fault || write_fault) {
+			hmm_vma_walk->last = addr;
+			pmd_migration_entry_wait(vma->vm_mm, pmdp);
+			return -EAGAIN;
+		}
+		return 0;
+	} else if (!pmd_present(pmd))
+		return hmm_pfns_bad(start, end, walk);
 
+	if (pmd_devmap(pmd) || pmd_trans_huge(pmd)) {
 		/*
 		 * No need to take pmd_lock here, even if some other threads
 		 * is splitting the huge pmd we will get that event through
@@ -607,13 +627,21 @@ static int hmm_vma_walk_pmd(pmd_t *pmdp,
 		if (!pmd_devmap(pmd) && !pmd_trans_huge(pmd))
 			goto again;
 
+		i = (addr - range->start) >> PAGE_SHIFT;
 		return hmm_vma_handle_pmd(walk, addr, end, &pfns[i], pmd);
 	}
 
-	if (pmd_bad(*pmdp))
+	/*
+	 * We have handled all the valid case above ie either none, migration,
+	 * huge or transparent huge. At this point either it is a valid pmd
+	 * entry pointing to pte directory or it is a bad pmd that will not
+	 * recover.
+	 */
+	if (pmd_bad(pmd))
 		return hmm_pfns_bad(start, end, walk);
 
 	ptep = pte_offset_map(pmdp, addr);
+	i = (addr - range->start) >> PAGE_SHIFT;
 	for (; addr < end; addr += PAGE_SIZE, ptep++, i++) {
 		int r;
 
-- 
2.17.2
