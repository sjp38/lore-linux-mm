Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id DFADD62008C
	for <linux-mm@kvack.org>; Wed,  7 Apr 2010 22:57:10 -0400 (EDT)
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 26 of 67] split_huge_page paging
Message-Id: <a4d31c2cb2b6e0ad41e9.1270691469@v2.random>
In-Reply-To: <patchbomb.1270691443@v2.random>
References: <patchbomb.1270691443@v2.random>
Date: Thu, 08 Apr 2010 03:51:09 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Chris Mason <chris.mason@oracle.com>
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

diff --git a/mm/memory-failure.c b/mm/memory-failure.c
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -379,6 +379,8 @@ static void collect_procs_anon(struct pa
 	struct task_struct *tsk;
 	struct anon_vma *av;
 
+	if (unlikely(split_huge_page(page)))
+		return;
 	read_lock(&tasklist_lock);
 	av = page_lock_anon_vma(page);
 	if (av == NULL)	/* Not actually mapped anymore */
diff --git a/mm/rmap.c b/mm/rmap.c
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1285,6 +1285,7 @@ int try_to_unmap(struct page *page, enum
 	int ret;
 
 	BUG_ON(!PageLocked(page));
+	BUG_ON(PageTransHuge(page));
 
 	if (unlikely(PageKsm(page)))
 		ret = try_to_unmap_ksm(page, flags);
diff --git a/mm/swap_state.c b/mm/swap_state.c
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -157,6 +157,12 @@ int add_to_swap(struct page *page)
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
diff --git a/mm/swapfile.c b/mm/swapfile.c
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -937,6 +937,8 @@ static inline int unuse_pmd_range(struct
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
