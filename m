Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 00FBD6B007B
	for <linux-mm@kvack.org>; Tue, 26 Jan 2010 08:59:15 -0500 (EST)
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 22 of 31] split_huge_page paging
Message-Id: <3e6e5d853907eafd664a.1264513937@v2.random>
In-Reply-To: <patchbomb.1264513915@v2.random>
References: <patchbomb.1264513915@v2.random>
Date: Tue, 26 Jan 2010 14:52:17 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>, bpicco@redhat.com, Christoph Hellwig <chellwig@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

From: Andrea Arcangeli <aarcange@redhat.com>

Paging logic that splits the page before it is unmapped and added to swap to
ensure backwards compatibility with the legacy swap code. Eventually swap
should natively pageout the hugepages to increase performance and decrease
seeking and fragmentation of swap space. swapoff can just skip over huge pmd as
they cannot be part of swap yet. In add_to_swap be careful to split the page
only if we got a valid swap entry so we don't split hugepages with a full swap.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---

diff --git a/mm/memory-failure.c b/mm/memory-failure.c
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
diff --git a/mm/rmap.c b/mm/rmap.c
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1174,6 +1174,7 @@ int try_to_unmap(struct page *page, enum
 	int ret;
 
 	BUG_ON(!PageLocked(page));
+	BUG_ON(PageTransHuge(page));
 
 	if (unlikely(PageKsm(page)))
 		ret = try_to_unmap_ksm(page, flags);
diff --git a/mm/swap_state.c b/mm/swap_state.c
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
diff --git a/mm/swapfile.c b/mm/swapfile.c
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -905,6 +905,8 @@ static inline int unuse_pmd_range(struct
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
