Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 660A36B0038
	for <linux-mm@kvack.org>; Thu, 18 Jan 2018 18:36:11 -0500 (EST)
Received: by mail-io0-f200.google.com with SMTP id w17so251382iow.23
        for <linux-mm@kvack.org>; Thu, 18 Jan 2018 15:36:11 -0800 (PST)
Received: from ngdesktop.us.oracle.com (hqdc-proxy-mwg016-o.oracle.com. [148.87.23.19])
        by mx.google.com with ESMTP id 186si6958224iow.155.2018.01.18.15.36.09
        for <linux-mm@kvack.org>;
        Thu, 18 Jan 2018 15:36:10 -0800 (PST)
From: Nitin Gupta <nitingupta910@gmail.com>
Subject: [PATCH v2] mm: Reduce memory bloat with THP
Date: Thu, 18 Jan 2018 15:33:16 -0800
Message-Id: <1516318444-30868-1-git-send-email-nitingupta910@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: steven.sistare@oracle.com
Cc: Nitin Gupta <nitin.m.gupta@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Mel Gorman <mgorman@suse.de>, Nadav Amit <namit@vmware.com>, Minchan Kim <minchan@kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Vegard Nossum <vegard.nossum@oracle.com>, "Levin, Alexander (Sasha Levin)" <alexander.levin@verizon.com>, Michal Hocko <mhocko@suse.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Shaohua Li <shli@fb.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, Jan Kara <jack@suse.cz>, Dave Jiang <dave.jiang@intel.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Matthew Wilcox <willy@linux.intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Hugh Dickins <hughd@google.com>, Tobin C Harding <me@tobin.cc>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

From: Nitin Gupta <nitin.m.gupta@oracle.com>

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

With this change, whenever an application issues MADV_DONTNEED on a
memory region, the region is marked as "space-efficient". For such
regions, a hugepage is not immediately allocated on first write.
Instead, it is left to the khugepaged thread to do delayed hugepage
promotion depending on whether the region is actually mapped and
active. When application issues MADV_HUGEPAGE, the region is marked
again as non-space-efficient wherein hugepage is allocated on first
touch.

Testing:

Wrote a test program which mmaps 128G area and writes to a random
address in a loop. Together with writes, madvise(MADV_DONTNEED) are
issued at another random addresses. Writes are issued with 70%
probability and DONTNEED with 30%. With this test, I'm trying to
emulate workload of a large in-memory hash-table.

With the patch, I see that memory bloat is much less severe as the
memory usage increases gradually. Eventually, only the memory actually
found by khugepaged to be active is collapsed to hugepages.

THP was set to 'always' mode in both cases but the result would be the
same if madvise mode was used instead.

All testing done on x86_64.

Changes since v1:
 - Acquire mmap_sem write lock for MADV_DONTNEED calls to safely
   change space_efficient flag of VMA.
 - Fix clearing of space_efficient flag when MADV_HUGEPAGE is called
   on a region.

Reviewed-by: Steve Sistare <steven.sistare@oracle.com>
Signed-off-by: Nitin Gupta <nitin.m.gupta@oracle.com>
---
 include/linux/mm_types.h | 1 +
 mm/madvise.c             | 6 +++++-
 mm/memory.c              | 6 ++++--
 3 files changed, 10 insertions(+), 3 deletions(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index cfd0ac4e5e0e..6d0783acf1e2 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -339,6 +339,7 @@ struct vm_area_struct {
 	struct mempolicy *vm_policy;	/* NUMA policy for the VMA */
 #endif
 	struct vm_userfaultfd_ctx vm_userfaultfd_ctx;
+	bool space_efficient;
 } __randomize_layout;
 
 struct core_thread {
diff --git a/mm/madvise.c b/mm/madvise.c
index 751e97aa2210..6019cfe05832 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -39,7 +39,6 @@ static int madvise_need_mmap_write(int behavior)
 	switch (behavior) {
 	case MADV_REMOVE:
 	case MADV_WILLNEED:
-	case MADV_DONTNEED:
 	case MADV_FREE:
 		return 0;
 	default:
@@ -60,6 +59,7 @@ static long madvise_behavior(struct vm_area_struct *vma,
 	int error = 0;
 	pgoff_t pgoff;
 	unsigned long new_flags = vma->vm_flags;
+	bool space_efficient = vma->space_efficient;
 
 	switch (behavior) {
 	case MADV_NORMAL:
@@ -116,6 +116,7 @@ static long madvise_behavior(struct vm_area_struct *vma,
 		}
 		break;
 	case MADV_HUGEPAGE:
+		space_efficient = false;
 	case MADV_NOHUGEPAGE:
 		error = hugepage_madvise(vma, &new_flags, behavior);
 		if (error) {
@@ -132,6 +133,7 @@ static long madvise_behavior(struct vm_area_struct *vma,
 
 	if (new_flags == vma->vm_flags) {
 		*prev = vma;
+		vma->space_efficient = space_efficient;
 		goto out;
 	}
 
@@ -185,6 +187,7 @@ static long madvise_behavior(struct vm_area_struct *vma,
 	 * vm_flags is protected by the mmap_sem held in write mode.
 	 */
 	vma->vm_flags = new_flags;
+	vma->space_efficient = space_efficient;
 out:
 	return error;
 }
@@ -508,6 +511,7 @@ static long madvise_dontneed_single_vma(struct vm_area_struct *vma,
 					unsigned long start, unsigned long end)
 {
 	zap_page_range(vma, start, end - start);
+	vma->space_efficient = true;
 	return 0;
 }
 
diff --git a/mm/memory.c b/mm/memory.c
index ca5674cbaff2..95311f25cd23 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -4002,7 +4002,8 @@ static int __handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
 	vmf.pud = pud_alloc(mm, p4d, address);
 	if (!vmf.pud)
 		return VM_FAULT_OOM;
-	if (pud_none(*vmf.pud) && transparent_hugepage_enabled(vma)) {
+	if (pud_none(*vmf.pud) && transparent_hugepage_enabled(vma)
+		&& !vma->space_efficient) {
 		ret = create_huge_pud(&vmf);
 		if (!(ret & VM_FAULT_FALLBACK))
 			return ret;
@@ -4028,7 +4029,8 @@ static int __handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
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
2.13.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
