Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5FD8F6B055A
	for <linux-mm@kvack.org>; Thu, 17 May 2018 23:03:56 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id d4-v6so4142563plr.17
        for <linux-mm@kvack.org>; Thu, 17 May 2018 20:03:56 -0700 (PDT)
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id w11-v6si5257213pgv.329.2018.05.17.20.03.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 May 2018 20:03:54 -0700 (PDT)
From: "Huang, Ying" <ying.huang@intel.com>
Subject: [PATCH -mm] mm, huge page: Copy to access sub-page last when copy huge page
Date: Fri, 18 May 2018 11:03:16 +0800
Message-Id: <20180518030316.31019-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, Andi Kleen <andi.kleen@intel.com>, Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@suse.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Matthew Wilcox <mawilcox@microsoft.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Shaohua Li <shli@fb.com>, Christopher Lameter <cl@linux.com>, Mike Kravetz <mike.kravetz@oracle.com>

From: Huang Ying <ying.huang@intel.com>

Huge page helps to reduce TLB miss rate, but it has higher cache
footprint, sometimes this may cause some issue.  For example, when
copying huge page on x86_64 platform, the cache footprint is 4M.  But
on a Xeon E5 v3 2699 CPU, there are 18 cores, 36 threads, and only 45M
LLC (last level cache).  That is, in average, there are 2.5M LLC for
each core and 1.25M LLC for each thread.

If the cache pressure is heavy when copying the huge page, and we copy
the huge page from the begin to the end, it is possible that the begin
of huge page is evicted from the cache after we finishing copying the
end of the huge page.  And it is possible for the application to access
the begin of the huge page after copying the huge page.

To help the above situation, in this patch, when we copy a huge page,
the order to copy sub-pages is changed.  In quite some situation, we
can get the address that the application will access after we copy the
huge page, for example, in a page fault handler.  Instead of copying
the huge page from begin to end, we will copy the sub-pages farthest
from the the sub-page to access firstly, and copy the sub-page to
access last.  This will make the sub-page to access most cache-hot and
sub-pages around it more cache-hot too.  If we cannot know the address
the application will access, the begin of the huge page is assumed to be
the the address the application will access.

The patch is a generic optimization which should benefit quite some
workloads, not for a specific use case.  To demonstrate the performance
benefit of the patch, we tested it with vm-scalability run on
transparent huge page.

With this patch, the throughput increases ~16.6% in vm-scalability
anon-cow-seq test case with 36 processes on a 2 socket Xeon E5 v3 2699
system (36 cores, 72 threads).  The test case set
/sys/kernel/mm/transparent_hugepage/enabled to be always, mmap() a big
anonymous memory area and populate it, then forked 36 child processes,
each writes to the anonymous memory area from the begin to the end, so
cause copy on write.  For each child process, other child processes
could be seen as other workloads which generate heavy cache pressure.
At the same time, the IPC (instruction per cycle) increased from 0.63
to 0.78, and the time spent in user space is reduced ~7.2%.

Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
Cc: Andi Kleen <andi.kleen@intel.com>
Cc: Jan Kara <jack@suse.cz>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Matthew Wilcox <mawilcox@microsoft.com>
Cc: Hugh Dickins <hughd@google.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Shaohua Li <shli@fb.com>
Cc: Christopher Lameter <cl@linux.com>
Cc: Mike Kravetz <mike.kravetz@oracle.com>
---
 include/linux/mm.h |  3 ++-
 mm/huge_memory.c   |  3 ++-
 mm/memory.c        | 43 +++++++++++++++++++++++++++++++++++++++----
 3 files changed, 43 insertions(+), 6 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 3fa3b1356c34..a5fae31988e6 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2732,7 +2732,8 @@ extern void clear_huge_page(struct page *page,
 			    unsigned long addr_hint,
 			    unsigned int pages_per_huge_page);
 extern void copy_user_huge_page(struct page *dst, struct page *src,
-				unsigned long addr, struct vm_area_struct *vma,
+				unsigned long addr_hint,
+				struct vm_area_struct *vma,
 				unsigned int pages_per_huge_page);
 extern long copy_huge_page_from_user(struct page *dst_page,
 				const void __user *usr_src,
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 323acdd14e6e..7e720e92fcd6 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1331,7 +1331,8 @@ int do_huge_pmd_wp_page(struct vm_fault *vmf, pmd_t orig_pmd)
 	if (!page)
 		clear_huge_page(new_page, vmf->address, HPAGE_PMD_NR);
 	else
-		copy_user_huge_page(new_page, page, haddr, vma, HPAGE_PMD_NR);
+		copy_user_huge_page(new_page, page, vmf->address,
+				    vma, HPAGE_PMD_NR);
 	__SetPageUptodate(new_page);
 
 	mmun_start = haddr;
diff --git a/mm/memory.c b/mm/memory.c
index 14578158ed20..f8868c94d6ab 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -4654,10 +4654,12 @@ static void copy_user_gigantic_page(struct page *dst, struct page *src,
 }
 
 void copy_user_huge_page(struct page *dst, struct page *src,
-			 unsigned long addr, struct vm_area_struct *vma,
+			 unsigned long addr_hint, struct vm_area_struct *vma,
 			 unsigned int pages_per_huge_page)
 {
-	int i;
+	int i, n, base, l;
+	unsigned long addr = addr_hint &
+		~(((unsigned long)pages_per_huge_page << PAGE_SHIFT) - 1);
 
 	if (unlikely(pages_per_huge_page > MAX_ORDER_NR_PAGES)) {
 		copy_user_gigantic_page(dst, src, addr, vma,
@@ -4665,10 +4667,43 @@ void copy_user_huge_page(struct page *dst, struct page *src,
 		return;
 	}
 
+	/* Copy sub-page to access last to keep its cache lines hot */
 	might_sleep();
-	for (i = 0; i < pages_per_huge_page; i++) {
+	n = (addr_hint - addr) / PAGE_SIZE;
+	if (2 * n <= pages_per_huge_page) {
+		/* If sub-page to access in first half of huge page */
+		base = 0;
+		l = n;
+		/* Copy sub-pages at the end of huge page */
+		for (i = pages_per_huge_page - 1; i >= 2 * n; i--) {
+			cond_resched();
+			copy_user_highpage(dst + i, src + i,
+					   addr + i * PAGE_SIZE, vma);
+		}
+	} else {
+		/* If sub-page to access in second half of huge page */
+		base = pages_per_huge_page - 2 * (pages_per_huge_page - n);
+		l = pages_per_huge_page - n;
+		/* Copy sub-pages at the begin of huge page */
+		for (i = 0; i < base; i++) {
+			cond_resched();
+			copy_user_highpage(dst + i, src + i,
+					   addr + i * PAGE_SIZE, vma);
+		}
+	}
+	/*
+	 * Copy remaining sub-pages in left-right-left-right pattern
+	 * towards the sub-page to access
+	 */
+	for (i = 0; i < l; i++) {
+		cond_resched();
+		copy_user_highpage(dst + base + i, src + base + i,
+				   addr + (base + i) * PAGE_SIZE, vma);
 		cond_resched();
-		copy_user_highpage(dst + i, src + i, addr + i*PAGE_SIZE, vma);
+		copy_user_highpage(dst + base + 2 * l - 1 - i,
+				   src + base + 2 * l - 1 - i,
+				   addr + (base + 2 * l - 1 - i) * PAGE_SIZE,
+				   vma);
 	}
 }
 
-- 
2.16.1
