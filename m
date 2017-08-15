Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id D8C6B6B0292
	for <linux-mm@kvack.org>; Mon, 14 Aug 2017 21:47:41 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id l30so21193812pgc.15
        for <linux-mm@kvack.org>; Mon, 14 Aug 2017 18:47:41 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id g59si5341630plb.470.2017.08.14.18.47.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Aug 2017 18:47:40 -0700 (PDT)
From: "Huang, Ying" <ying.huang@intel.com>
Subject: [PATCH -mm -v2] mm: Clear to access sub-page last when clearing huge page
Date: Tue, 15 Aug 2017 09:46:18 +0800
Message-Id: <20170815014618.15842-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Nadia Yvette Chambers <nyc@holomorphy.com>, Michal Hocko <mhocko@suse.com>, Matthew Wilcox <mawilcox@microsoft.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Shaohua Li <shli@fb.com>, Christopher Lameter <cl@linux.com>, Mike Kravetz <mike.kravetz@oracle.com>

From: Huang Ying <ying.huang@intel.com>

Huge page helps to reduce TLB miss rate, but it has higher cache
footprint, sometimes this may cause some issue.  For example, when
clearing huge page on x86_64 platform, the cache footprint is 2M.  But
on a Xeon E5 v3 2699 CPU, there are 18 cores, 36 threads, and only 45M
LLC (last level cache).  That is, in average, there are 2.5M LLC for
each core and 1.25M LLC for each thread.  If the cache pressure is
heavy when clearing the huge page, and we clear the huge page from the
begin to the end, it is possible that the begin of huge page is
evicted from the cache after we finishing clearing the end of the huge
page.  And it is possible for the application to access the begin of
the huge page after clearing the huge page.

To help the above situation, in this patch, when we clear a huge page,
the order to clear sub-pages is changed.  In quite some situation, we
can get the address that the application will access after we clear
the huge page, for example, in a page fault handler.  Instead of
clearing the huge page from begin to end, we will clear the sub-pages
farthest from the the sub-page to access firstly, and clear the
sub-page to access last.  This will make the sub-page to access most
cache-hot and sub-pages around it more cache-hot too.  If we cannot
know the address the application will access, the begin of the huge
page is assumed to be the the address the application will access.

With this patch, the throughput increases ~28.3% in vm-scalability
anon-w-seq test case with 72 processes on a 2 socket Xeon E5 v3 2699
system (36 cores, 72 threads).  The test case creates 72 processes,
each process mmap a big anonymous memory area and writes to it from
the begin to the end.  For each process, other processes could be seen
as other workload which generates heavy cache pressure.  At the same
time, the cache miss rate reduced from ~33.4% to ~31.7%, the
IPC (instruction per cycle) increased from 0.56 to 0.74, and the time
spent in user space is reduced ~7.9%

Christopher Lameter suggests to clear bytes inside a sub-page from end
to begin too.  But tests show no visible performance difference in the
tests.  May because the size of page is small compared with the cache
size.

Thanks Andi Kleen to propose to use address to access to determine the
order of sub-pages to clear.

The hugetlbfs access address could be improved, will do that in
another patch.

[Use address to access information]
Suggested-by: Andi Kleen <andi.kleen@intel.com>
Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
Acked-by: Jan Kara <jack@suse.cz>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Nadia Yvette Chambers <nyc@holomorphy.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Matthew Wilcox <mawilcox@microsoft.com>
Cc: Hugh Dickins <hughd@google.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Shaohua Li <shli@fb.com>
Cc: Christopher Lameter <cl@linux.com>
Cc: Mike Kravetz <mike.kravetz@oracle.com>
---
 include/linux/mm.h |  2 +-
 mm/huge_memory.c   |  4 ++--
 mm/memory.c        | 39 +++++++++++++++++++++++++++++++++++----
 3 files changed, 38 insertions(+), 7 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 9fee3213a75e..b77bcbddde20 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2508,7 +2508,7 @@ enum mf_action_page_type {
 
 #if defined(CONFIG_TRANSPARENT_HUGEPAGE) || defined(CONFIG_HUGETLBFS)
 extern void clear_huge_page(struct page *page,
-			    unsigned long addr,
+			    unsigned long addr_hint,
 			    unsigned int pages_per_huge_page);
 extern void copy_user_huge_page(struct page *dst, struct page *src,
 				unsigned long addr, struct vm_area_struct *vma,
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index fd3ad6c88c8a..4b19a233392e 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -566,7 +566,7 @@ static int __do_huge_pmd_anonymous_page(struct vm_fault *vmf, struct page *page,
 		return VM_FAULT_OOM;
 	}
 
-	clear_huge_page(page, haddr, HPAGE_PMD_NR);
+	clear_huge_page(page, vmf->address, HPAGE_PMD_NR);
 	/*
 	 * The memory barrier inside __SetPageUptodate makes sure that
 	 * clear_huge_page writes become visible before the set_pmd_at()
@@ -1310,7 +1310,7 @@ int do_huge_pmd_wp_page(struct vm_fault *vmf, pmd_t orig_pmd)
 	count_vm_event(THP_FAULT_ALLOC);
 
 	if (!page)
-		clear_huge_page(new_page, haddr, HPAGE_PMD_NR);
+		clear_huge_page(new_page, vmf->address, HPAGE_PMD_NR);
 	else
 		copy_user_huge_page(new_page, page, haddr, vma, HPAGE_PMD_NR);
 	__SetPageUptodate(new_page);
diff --git a/mm/memory.c b/mm/memory.c
index edabf6f03447..c939cfc38bcf 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -4364,19 +4364,50 @@ static void clear_gigantic_page(struct page *page,
 	}
 }
 void clear_huge_page(struct page *page,
-		     unsigned long addr, unsigned int pages_per_huge_page)
+		     unsigned long addr_hint, unsigned int pages_per_huge_page)
 {
-	int i;
+	int i, n, base, l;
+	unsigned long addr = addr_hint &
+		~(((unsigned long)pages_per_huge_page << PAGE_SHIFT) - 1);
 
 	if (unlikely(pages_per_huge_page > MAX_ORDER_NR_PAGES)) {
 		clear_gigantic_page(page, addr, pages_per_huge_page);
 		return;
 	}
 
+	/* Clear sub-page to access last to keep its cache lines hot */
 	might_sleep();
-	for (i = 0; i < pages_per_huge_page; i++) {
+	n = (addr_hint - addr) / PAGE_SIZE;
+	if (2 * n <= pages_per_huge_page) {
+		/* If sub-page to access in first half of huge page */
+		base = 0;
+		l = n;
+		/* Clear sub-pages at the end of huge page */
+		for (i = pages_per_huge_page - 1; i >= 2 * n; i--) {
+			cond_resched();
+			clear_user_highpage(page + i, addr + i * PAGE_SIZE);
+		}
+	} else {
+		/* If sub-page to access in second half of huge page */
+		base = pages_per_huge_page - 2 * (pages_per_huge_page - n);
+		l = pages_per_huge_page - n;
+		/* Clear sub-pages at the begin of huge page */
+		for (i = 0; i < base; i++) {
+			cond_resched();
+			clear_user_highpage(page + i, addr + i * PAGE_SIZE);
+		}
+	}
+	/*
+	 * Clear remaining sub-pages in left-right-left-right pattern
+	 * towards the sub-page to access
+	 */
+	for (i = 0; i < l; i++) {
+		cond_resched();
+		clear_user_highpage(page + base + i,
+				    addr + (base + i) * PAGE_SIZE);
 		cond_resched();
-		clear_user_highpage(page + i, addr + i * PAGE_SIZE);
+		clear_user_highpage(page + base + 2 * l - 1 - i,
+				    addr + (base + 2 * l - 1 - i) * PAGE_SIZE);
 	}
 }
 
-- 
2.13.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
