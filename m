Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 6E7DB6B009C
	for <linux-mm@kvack.org>; Fri, 26 Feb 2010 15:09:30 -0500 (EST)
Message-Id: <20100226200902.435524500@redhat.com>
Date: Fri, 26 Feb 2010 21:04:55 +0100
From: aarcange@redhat.com
Subject: [patch 22/35] split_huge_page paging
References: <20100226200433.516502198@redhat.com>
Content-Disposition: inline; filename=split_huge_page_unmap_swap
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

From: Andrea Arcangeli <aarcange@redhat.com>

Paging logic that splits the page before it is unmapped and added to swap to
ensure backwards compatibility with the legacy swap code. Eventually swap
should natively pageout the hugepages to increase performance and decrease
seeking and fragmentation of swap space. swapoff can just skip over huge pmd as
they cannot be part of swap yet. In add_to_swap be careful to split the page
only if we got a valid swap entry so we don't split hugepages with a full swap.

In theory we could split pages before isolating them during the lru scan, but
for khugepaged to be safe, I'm relying on either mmap_sem write mode, or
PG_lock taken, so split_huge_page has to run either with mmap_sem read/write
mode or PG_lock taken. Calling it from isolate_lru_page would make locking more
complicated, in addition to that split_huge_page would deadlock if called by
__isolate_lru_page because it has to take the lru lock to add the tail pages.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
Acked-by: Mel Gorman <mel@csn.ul.ie>
Acked-by: Rik van Riel <riel@redhat.com>
---
 mm/memory-failure.c |    2 ++
 mm/rmap.c           |    1 +
 mm/swap_state.c     |    6 ++++++
 mm/swapfile.c       |    2 ++
 4 files changed, 11 insertions(+)

--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -378,6 +378,8 @@ static void collect_procs_anon(struct pa
 	struct task_struct *tsk;
 	struct anon_vma *av;
 
+	if (unlikely(split_huge_page(page)))
+		return;
 	read_lock(&tasklist_lock);
 	av = page_lock_anon_vma(page);
 	if (av == NULL)	/* Not actually mapped anymore */
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1287,6 +1287,7 @@ int try_to_unmap(struct page *page, enum
 	int ret;
 
 	BUG_ON(!PageLocked(page));
+	BUG_ON(PageTransHuge(page));
 
 	if (unlikely(PageKsm(page)))
 		ret = try_to_unmap_ksm(page, flags);
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -156,6 +156,12 @@ int add_to_swap(struct page *page)
 	if (!entry.val)
 		return 0;
 
+	if (unlikely(PageTransHuge(page)))
+		if (unlikely(split_huge_page(page))) {
+			swapcache_free(entry, NULL);
+			return 0;
+		}
+
 	/*
 	 * Radix-tree node allocations from PF_MEMALLOC contexts could
 	 * completely exhaust the page allocator. __GFP_NOMEMALLOC
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -941,6 +941,8 @@ static inline int unuse_pmd_range(struct
 	pmd = pmd_offset(pud, addr);
 	do {
 		next = pmd_addr_end(addr, end);
+		if (unlikely(pmd_trans_huge(*pmd)))
+			continue;
 		if (pmd_none_or_clear_bad(pmd))
 			continue;
 		ret = unuse_pte_range(vma, pmd, addr, next, entry, page);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
