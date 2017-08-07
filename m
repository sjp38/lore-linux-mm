Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id D58AA6B02B4
	for <linux-mm@kvack.org>; Mon,  7 Aug 2017 03:22:07 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id p20so87307646pfj.2
        for <linux-mm@kvack.org>; Mon, 07 Aug 2017 00:22:07 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id o6si4315088pgn.290.2017.08.07.00.22.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Aug 2017 00:22:06 -0700 (PDT)
From: "Huang, Ying" <ying.huang@intel.com>
Subject: [PATCH -mm] mm: Clear to access sub-page last when clearing huge page
Date: Mon,  7 Aug 2017 15:21:31 +0800
Message-Id: <20170807072131.8343-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Nadia Yvette Chambers <nyc@holomorphy.com>, Michal Hocko <mhocko@suse.com>, Jan Kara <jack@suse.cz>, Matthew Wilcox <willy@linux.intel.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Shaohua Li <shli@fb.com>

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

Thanks Andi Kleen to propose to use address to access to determine the
order of sub-pages to clear.

The hugetlbfs access address could be improved, will do that in
another patch.

[Use address to access information]
Suggested-by: Andi Kleen <andi.kleen@intel.com>
Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Nadia Yvette Chambers <nyc@holomorphy.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Jan Kara <jack@suse.cz>
Cc: Matthew Wilcox <willy@linux.intel.com>
Cc: Hugh Dickins <hughd@google.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Shaohua Li <shli@fb.com>
---
 fs/hugetlbfs/inode.c |  2 +-
 include/linux/mm.h   |  3 ++-
 mm/huge_memory.c     | 10 ++++++----
 mm/hugetlb.c         |  2 +-
 mm/memory.c          | 32 +++++++++++++++++++++++++++-----
 5 files changed, 37 insertions(+), 12 deletions(-)

diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index 33961b35007b..1bbb38fcaa11 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -627,7 +627,7 @@ static long hugetlbfs_fallocate(struct file *file, int mode, loff_t offset,
 			error = PTR_ERR(page);
 			goto out;
 		}
-		clear_huge_page(page, addr, pages_per_huge_page(h));
+		clear_huge_page(page, addr, pages_per_huge_page(h), addr);
 		__SetPageUptodate(page);
 		error = huge_add_to_page_cache(page, mapping, index);
 		if (unlikely(error)) {
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 9fee3213a75e..a954f63a13c9 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2509,7 +2509,8 @@ enum mf_action_page_type {
 #if defined(CONFIG_TRANSPARENT_HUGEPAGE) || defined(CONFIG_HUGETLBFS)
 extern void clear_huge_page(struct page *page,
 			    unsigned long addr,
-			    unsigned int pages_per_huge_page);
+			    unsigned int pages_per_huge_page,
+			    unsigned long addr_hint);
 extern void copy_user_huge_page(struct page *dst, struct page *src,
 				unsigned long addr, struct vm_area_struct *vma,
 				unsigned int pages_per_huge_page);
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index fd3ad6c88c8a..b1e66df38661 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -549,7 +549,8 @@ static int __do_huge_pmd_anonymous_page(struct vm_fault *vmf, struct page *page,
 	struct vm_area_struct *vma = vmf->vma;
 	struct mem_cgroup *memcg;
 	pgtable_t pgtable;
-	unsigned long haddr = vmf->address & HPAGE_PMD_MASK;
+	unsigned long address = vmf->address;
+	unsigned long haddr = address & HPAGE_PMD_MASK;
 
 	VM_BUG_ON_PAGE(!PageCompound(page), page);
 
@@ -566,7 +567,7 @@ static int __do_huge_pmd_anonymous_page(struct vm_fault *vmf, struct page *page,
 		return VM_FAULT_OOM;
 	}
 
-	clear_huge_page(page, haddr, HPAGE_PMD_NR);
+	clear_huge_page(page, haddr, HPAGE_PMD_NR, address);
 	/*
 	 * The memory barrier inside __SetPageUptodate makes sure that
 	 * clear_huge_page writes become visible before the set_pmd_at()
@@ -1225,7 +1226,8 @@ int do_huge_pmd_wp_page(struct vm_fault *vmf, pmd_t orig_pmd)
 	struct vm_area_struct *vma = vmf->vma;
 	struct page *page = NULL, *new_page;
 	struct mem_cgroup *memcg;
-	unsigned long haddr = vmf->address & HPAGE_PMD_MASK;
+	unsigned long address = vmf->address;
+	unsigned long haddr = address & HPAGE_PMD_MASK;
 	unsigned long mmun_start;	/* For mmu_notifiers */
 	unsigned long mmun_end;		/* For mmu_notifiers */
 	gfp_t huge_gfp;			/* for allocation and charge */
@@ -1310,7 +1312,7 @@ int do_huge_pmd_wp_page(struct vm_fault *vmf, pmd_t orig_pmd)
 	count_vm_event(THP_FAULT_ALLOC);
 
 	if (!page)
-		clear_huge_page(new_page, haddr, HPAGE_PMD_NR);
+		clear_huge_page(new_page, haddr, HPAGE_PMD_NR, address);
 	else
 		copy_user_huge_page(new_page, page, haddr, vma, HPAGE_PMD_NR);
 	__SetPageUptodate(new_page);
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 5dae4fff368d..fb2ff230236a 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -3707,7 +3707,7 @@ static int hugetlb_no_page(struct mm_struct *mm, struct vm_area_struct *vma,
 				ret = VM_FAULT_SIGBUS;
 			goto out;
 		}
-		clear_huge_page(page, address, pages_per_huge_page(h));
+		clear_huge_page(page, address, pages_per_huge_page(h), address);
 		__SetPageUptodate(page);
 		set_page_huge_active(page);
 
diff --git a/mm/memory.c b/mm/memory.c
index edabf6f03447..d5bd7633a443 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -4363,10 +4363,10 @@ static void clear_gigantic_page(struct page *page,
 		clear_user_highpage(p, addr + i * PAGE_SIZE);
 	}
 }
-void clear_huge_page(struct page *page,
-		     unsigned long addr, unsigned int pages_per_huge_page)
+void clear_huge_page(struct page *page, unsigned long addr,
+		     unsigned int pages_per_huge_page, unsigned long addr_hint)
 {
-	int i;
+	int i, n, base, l;
 
 	if (unlikely(pages_per_huge_page > MAX_ORDER_NR_PAGES)) {
 		clear_gigantic_page(page, addr, pages_per_huge_page);
@@ -4374,9 +4374,31 @@ void clear_huge_page(struct page *page,
 	}
 
 	might_sleep();
-	for (i = 0; i < pages_per_huge_page; i++) {
+	VM_BUG_ON(clamp(addr_hint, addr, addr +
+			(pages_per_huge_page << PAGE_SHIFT)) != addr_hint);
+	n = (addr_hint - addr) / PAGE_SIZE;
+	if (2 * n <= pages_per_huge_page) {
+		base = 0;
+		l = n;
+		for (i = pages_per_huge_page - 1; i >= 2 * n; i--) {
+			cond_resched();
+			clear_user_highpage(page + i, addr + i * PAGE_SIZE);
+		}
+	} else {
+		base = 2 * n - pages_per_huge_page;
+		l = pages_per_huge_page - n;
+		for (i = 0; i < base; i++) {
+			cond_resched();
+			clear_user_highpage(page + i, addr + i * PAGE_SIZE);
+		}
+	}
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
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
