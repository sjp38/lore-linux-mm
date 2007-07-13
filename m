Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e3.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l6DECjhG031936
	for <linux-mm@kvack.org>; Fri, 13 Jul 2007 10:12:45 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l6DFGYnH523248
	for <linux-mm@kvack.org>; Fri, 13 Jul 2007 11:16:34 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l6DFGXW6002967
	for <linux-mm@kvack.org>; Fri, 13 Jul 2007 11:16:34 -0400
From: Adam Litke <agl@us.ibm.com>
Subject: [PATCH 1/5] [hugetlb] Introduce BASE_PAGES_PER_HPAGE constant
Date: Fri, 13 Jul 2007 08:16:31 -0700
Message-Id: <20070713151631.17750.44881.stgit@kernel>
In-Reply-To: <20070713151621.17750.58171.stgit@kernel>
References: <20070713151621.17750.58171.stgit@kernel>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Mel Gorman <mel@skynet.ie>, Andy Whitcroft <apw@shadowen.org>, William Lee Irwin III <wli@holomorphy.com>, Christoph Lameter <clameter@sgi.com>, Ken Chen <kenchen@google.com>, Adam Litke <agl@us.ibm.com>
List-ID: <linux-mm.kvack.org>

In many places throughout the kernel, the expression (HPAGE_SIZE/PAGE_SIZE) is
used to convert quantities in huge page units to a number of base pages.
Reduce redundancy and make the code more readable by introducing a constant
BASE_PAGES_PER_HPAGE whose name more clearly conveys the intended conversion.

Signed-off-by: Adam Litke <agl@us.ibm.com>
---

 arch/powerpc/mm/hugetlbpage.c |    2 +-
 arch/sparc64/mm/fault.c       |    2 +-
 include/linux/hugetlb.h       |    2 ++
 ipc/shm.c                     |    2 +-
 mm/hugetlb.c                  |   10 +++++-----
 mm/memory.c                   |    2 +-
 6 files changed, 11 insertions(+), 9 deletions(-)

diff --git a/arch/powerpc/mm/hugetlbpage.c b/arch/powerpc/mm/hugetlbpage.c
index 92a1b16..5e3414a 100644
--- a/arch/powerpc/mm/hugetlbpage.c
+++ b/arch/powerpc/mm/hugetlbpage.c
@@ -387,7 +387,7 @@ static unsigned int hash_huge_page_do_lazy_icache(unsigned long rflags,
 	/* page is dirty */
 	if (!test_bit(PG_arch_1, &page->flags) && !PageReserved(page)) {
 		if (trap == 0x400) {
-			for (i = 0; i < (HPAGE_SIZE / PAGE_SIZE); i++)
+			for (i = 0; i < BASE_PAGES_PER_HPAGE; i++)
 				__flush_dcache_icache(page_address(page+i));
 			set_bit(PG_arch_1, &page->flags);
 		} else {
diff --git a/arch/sparc64/mm/fault.c b/arch/sparc64/mm/fault.c
index b582024..4076003 100644
--- a/arch/sparc64/mm/fault.c
+++ b/arch/sparc64/mm/fault.c
@@ -434,7 +434,7 @@ good_area:
 
 	mm_rss = get_mm_rss(mm);
 #ifdef CONFIG_HUGETLB_PAGE
-	mm_rss -= (mm->context.huge_pte_count * (HPAGE_SIZE / PAGE_SIZE));
+	mm_rss -= (mm->context.huge_pte_count * BASE_PAGES_PER_HPAGE);
 #endif
 	if (unlikely(mm_rss >
 		     mm->context.tsb_block[MM_TSB_BASE].tsb_rss_limit))
diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index b4570b6..77021a3 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -128,6 +128,8 @@ static inline unsigned long hugetlb_total_pages(void)
 
 #endif /* !CONFIG_HUGETLB_PAGE */
 
+#define BASE_PAGES_PER_HPAGE (HPAGE_SIZE >> PAGE_SHIFT)
+
 #ifdef CONFIG_HUGETLBFS
 struct hugetlbfs_config {
 	uid_t   uid;
diff --git a/ipc/shm.c b/ipc/shm.c
index 4fefbad..fde409a 100644
--- a/ipc/shm.c
+++ b/ipc/shm.c
@@ -559,7 +559,7 @@ static void shm_get_stat(struct ipc_namespace *ns, unsigned long *rss,
 
 		if (is_file_hugepages(shp->shm_file)) {
 			struct address_space *mapping = inode->i_mapping;
-			*rss += (HPAGE_SIZE/PAGE_SIZE)*mapping->nrpages;
+			*rss += BASE_PAGES_PER_HPAGE * mapping->nrpages;
 		} else {
 			struct shmem_inode_info *info = SHMEM_I(inode);
 			spin_lock(&info->lock);
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index eb7180d..61a52b0 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -37,7 +37,7 @@ static void clear_huge_page(struct page *page, unsigned long addr)
 	int i;
 
 	might_sleep();
-	for (i = 0; i < (HPAGE_SIZE/PAGE_SIZE); i++) {
+	for (i = 0; i < BASE_PAGES_PER_HPAGE; i++) {
 		cond_resched();
 		clear_user_highpage(page + i, addr);
 	}
@@ -49,7 +49,7 @@ static void copy_huge_page(struct page *dst, struct page *src,
 	int i;
 
 	might_sleep();
-	for (i = 0; i < HPAGE_SIZE/PAGE_SIZE; i++) {
+	for (i = 0; i < BASE_PAGES_PER_HPAGE; i++) {
 		cond_resched();
 		copy_user_highpage(dst + i, src + i, addr + i*PAGE_SIZE, vma);
 	}
@@ -191,7 +191,7 @@ static void update_and_free_page(struct page *page)
 	int i;
 	nr_huge_pages--;
 	nr_huge_pages_node[page_to_nid(page)]--;
-	for (i = 0; i < (HPAGE_SIZE / PAGE_SIZE); i++) {
+	for (i = 0; i < BASE_PAGES_PER_HPAGE; i++) {
 		page[i].flags &= ~(1 << PG_locked | 1 << PG_error | 1 << PG_referenced |
 				1 << PG_dirty | 1 << PG_active | 1 << PG_reserved |
 				1 << PG_private | 1<< PG_writeback);
@@ -283,7 +283,7 @@ int hugetlb_report_node_meminfo(int nid, char *buf)
 /* Return the number pages of memory we physically have, in PAGE_SIZE units. */
 unsigned long hugetlb_total_pages(void)
 {
-	return nr_huge_pages * (HPAGE_SIZE / PAGE_SIZE);
+	return nr_huge_pages * BASE_PAGES_PER_HPAGE;
 }
 
 /*
@@ -642,7 +642,7 @@ same_page:
 		--remainder;
 		++i;
 		if (vaddr < vma->vm_end && remainder &&
-				pfn_offset < HPAGE_SIZE/PAGE_SIZE) {
+				pfn_offset < BASE_PAGES_PER_HPAGE) {
 			/*
 			 * We use pfn_offset to avoid touching the pageframes
 			 * of this compound page.
diff --git a/mm/memory.c b/mm/memory.c
index cb94488..bb8f7e8 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -842,7 +842,7 @@ unsigned long unmap_vmas(struct mmu_gather **tlbp,
 			if (unlikely(is_vm_hugetlb_page(vma))) {
 				unmap_hugepage_range(vma, start, end);
 				zap_work -= (end - start) /
-						(HPAGE_SIZE / PAGE_SIZE);
+						BASE_PAGES_PER_HPAGE;
 				start = end;
 			} else
 				start = unmap_page_range(*tlbp, vma,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
