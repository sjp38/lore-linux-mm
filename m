Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f69.google.com (mail-vk0-f69.google.com [209.85.213.69])
	by kanga.kvack.org (Postfix) with ESMTP id 308476B0038
	for <linux-mm@kvack.org>; Thu, 14 Dec 2017 20:30:24 -0500 (EST)
Received: by mail-vk0-f69.google.com with SMTP id b62so3614480vke.23
        for <linux-mm@kvack.org>; Thu, 14 Dec 2017 17:30:24 -0800 (PST)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id t184si2083542vka.161.2017.12.14.17.30.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Dec 2017 17:30:23 -0800 (PST)
From: Nitin Gupta <nitin.m.gupta@oracle.com>
Subject: [PATCH] mm: Reduce memory bloat with THP
Date: Thu, 14 Dec 2017 17:28:52 -0800
Message-Id: <1513301359-117568-1-git-send-email-nitin.m.gupta@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: steven.sistare@oracle.com, Nitin Gupta <nitin.m.gupta@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Mel Gorman <mgorman@suse.de>, Nadav Amit <namit@vmware.com>, Minchan Kim <minchan@kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Vegard Nossum <vegard.nossum@oracle.com>, "Levin, Alexander (Sasha Levin)" <alexander.levin@verizon.com>, Michal Hocko <mhocko@suse.com>, David Rientjes <rientjes@google.com>, Vlastimil Babka <vbabka@suse.cz>, SeongJae Park <sj38.park@gmail.com>, Shaohua Li <shli@fb.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Jan Kara <jack@suse.cz>, Dave Jiang <dave.jiang@intel.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Matthew Wilcox <willy@linux.intel.com>, Hugh Dickins <hughd@google.com>, Tobin C Harding <me@tobin.cc>, open list <linux-kernel@vger.kernel.org>

Currently, if the THP enabled policy is "always", or the mode
is "madvise" and a region is marked as MADV_HUGEPAGE, a hugepage
is allocated on a page fault if the pud or pmd is empty.  This
yields the best VA translation performance, but increases memory
consumption if some small page ranges within the huge page are
never accessed.

An alternate behavior for such page faults is to install a
hugepage only when a region is actually found to be (almost)
fully mapped and active.  This is a compromise between
translation performance and memory consumption.  Currently there
is no way for an application to choose this compromise for the
page fault conditions above.

With this change, when an application issues MADV_DONTNEED on a
memory region, the region is marked as "space-efficient". For
such regions, a hugepage is not immediately allocated on first
write.  Instead, it is left to the khugepaged thread to do
delayed hugepage promotion depending on whether the region is
actually mapped and active. When application issues
MADV_HUGEPAGE, the region is marked again as non-space-efficient
wherein hugepage is allocated on first touch.

Orabug: 26910556

Reviewed-by: Steve Sistare <steven.sistare@oracle.com>
Signed-off-by: Nitin Gupta <nitin.m.gupta@oracle.com>
---
 include/linux/mm_types.h | 1 +
 mm/khugepaged.c          | 1 +
 mm/madvise.c             | 1 +
 mm/memory.c              | 6 ++++--
 4 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index cfd0ac4..6d0783a 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -339,6 +339,7 @@ struct vm_area_struct {
 	struct mempolicy *vm_policy;	/* NUMA policy for the VMA */
 #endif
 	struct vm_userfaultfd_ctx vm_userfaultfd_ctx;
+	bool space_efficient;
 } __randomize_layout;
 
 struct core_thread {
diff --git a/mm/khugepaged.c b/mm/khugepaged.c
index ea4ff25..2f4037a 100644
--- a/mm/khugepaged.c
+++ b/mm/khugepaged.c
@@ -319,6 +319,7 @@ int hugepage_madvise(struct vm_area_struct *vma,
 #endif
 		*vm_flags &= ~VM_NOHUGEPAGE;
 		*vm_flags |= VM_HUGEPAGE;
+		vma->space_efficient = false;
 		/*
 		 * If the vma become good for khugepaged to scan,
 		 * register it here without waiting a page fault that
diff --git a/mm/madvise.c b/mm/madvise.c
index 751e97a..b2ec07b 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -508,6 +508,7 @@ static long madvise_dontneed_single_vma(struct vm_area_struct *vma,
 					unsigned long start, unsigned long end)
 {
 	zap_page_range(vma, start, end - start);
+	vma->space_efficient = true;
 	return 0;
 }
 
diff --git a/mm/memory.c b/mm/memory.c
index 5eb3d25..6485014 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -4001,7 +4001,8 @@ static int __handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
 	vmf.pud = pud_alloc(mm, p4d, address);
 	if (!vmf.pud)
 		return VM_FAULT_OOM;
-	if (pud_none(*vmf.pud) && transparent_hugepage_enabled(vma)) {
+	if (pud_none(*vmf.pud) && transparent_hugepage_enabled(vma)
+		&& !vma->space_efficient) {
 		ret = create_huge_pud(&vmf);
 		if (!(ret & VM_FAULT_FALLBACK))
 			return ret;
@@ -4027,7 +4028,8 @@ static int __handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
 	vmf.pmd = pmd_alloc(mm, vmf.pud, address);
 	if (!vmf.pmd)
 		return VM_FAULT_OOM;
-	if (pmd_none(*vmf.pmd) && transparent_hugepage_enabled(vma)) {
+	if (pmd_none(*vmf.pmd) && transparent_hugepage_enabled(vma)
+		&& !vma->space_efficient) {
 		ret = create_huge_pmd(&vmf);
 		if (!(ret & VM_FAULT_FALLBACK))
 			return ret;
-- 
2.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
