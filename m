Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 571956B0266
	for <linux-mm@kvack.org>; Wed, 23 May 2018 21:00:34 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id l85-v6so13883846pfb.18
        for <linux-mm@kvack.org>; Wed, 23 May 2018 18:00:34 -0700 (PDT)
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id 203-v6si19885295pfz.160.2018.05.23.18.00.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 May 2018 18:00:33 -0700 (PDT)
From: "Huang, Ying" <ying.huang@intel.com>
Subject: [PATCH -V2 -mm 2/4] mm, huge page: Copy target sub-page last when copy huge page
Date: Thu, 24 May 2018 08:58:49 +0800
Message-Id: <20180524005851.4079-3-ying.huang@intel.com>
In-Reply-To: <20180524005851.4079-1-ying.huang@intel.com>
References: <20180524005851.4079-1-ying.huang@intel.com>
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

If the cache contention is heavy when copying the huge page, and we
copy the huge page from the begin to the end, it is possible that the
begin of huge page is evicted from the cache after we finishing
copying the end of the huge page.  And it is possible for the
application to access the begin of the huge page after copying the
huge page.

In commit c79b57e462b5d ("mm: hugetlb: clear target sub-page last when
clearing huge page"), to keep the cache lines of the target subpage
hot, the order to clear the subpages in the huge page in
clear_huge_page() is changed to clearing the subpage which is furthest
from the target subpage firstly, and the target subpage last.  The
similar order changing helps huge page copying too.  That is
implemented in this patch.  Because we have put the order algorithm
into a separate function, the implementation is quite simple.

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
 mm/memory.c        | 30 +++++++++++++++++++++++-------
 3 files changed, 27 insertions(+), 9 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 7cdd8b7f62e5..d227aadaa964 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2734,7 +2734,8 @@ extern void clear_huge_page(struct page *page,
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
index e9177363fe2e..1b7fd9bda1dc 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1328,7 +1328,8 @@ int do_huge_pmd_wp_page(struct vm_fault *vmf, pmd_t orig_pmd)
 	if (!page)
 		clear_huge_page(new_page, vmf->address, HPAGE_PMD_NR);
 	else
-		copy_user_huge_page(new_page, page, haddr, vma, HPAGE_PMD_NR);
+		copy_user_huge_page(new_page, page, vmf->address,
+				    vma, HPAGE_PMD_NR);
 	__SetPageUptodate(new_page);
 
 	mmun_start = haddr;
diff --git a/mm/memory.c b/mm/memory.c
index b9f573a81bbd..5d432f833d19 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -4675,11 +4675,31 @@ static void copy_user_gigantic_page(struct page *dst, struct page *src,
 	}
 }
 
+struct copy_subpage_arg {
+	struct page *dst;
+	struct page *src;
+	struct vm_area_struct *vma;
+};
+
+static void copy_subpage(unsigned long addr, int idx, void *arg)
+{
+	struct copy_subpage_arg *copy_arg = arg;
+
+	copy_user_highpage(copy_arg->dst + idx, copy_arg->src + idx,
+			   addr, copy_arg->vma);
+}
+
 void copy_user_huge_page(struct page *dst, struct page *src,
-			 unsigned long addr, struct vm_area_struct *vma,
+			 unsigned long addr_hint, struct vm_area_struct *vma,
 			 unsigned int pages_per_huge_page)
 {
-	int i;
+	unsigned long addr = addr_hint &
+		~(((unsigned long)pages_per_huge_page << PAGE_SHIFT) - 1);
+	struct copy_subpage_arg arg = {
+		.dst = dst,
+		.src = src,
+		.vma = vma,
+	};
 
 	if (unlikely(pages_per_huge_page > MAX_ORDER_NR_PAGES)) {
 		copy_user_gigantic_page(dst, src, addr, vma,
@@ -4687,11 +4707,7 @@ void copy_user_huge_page(struct page *dst, struct page *src,
 		return;
 	}
 
-	might_sleep();
-	for (i = 0; i < pages_per_huge_page; i++) {
-		cond_resched();
-		copy_user_highpage(dst + i, src + i, addr + i*PAGE_SIZE, vma);
-	}
+	process_huge_page(addr_hint, pages_per_huge_page, copy_subpage, &arg);
 }
 
 long copy_huge_page_from_user(struct page *dst_page,
-- 
2.16.1
