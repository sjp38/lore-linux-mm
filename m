Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id 6F32A6B0081
	for <linux-mm@kvack.org>; Thu, 25 Oct 2012 09:10:24 -0400 (EDT)
Message-Id: <20121025124834.801088972@chello.nl>
Date: Thu, 25 Oct 2012 14:16:48 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 31/31] sched, numa, mm: Add memcg support to do_huge_pmd_numa_page()
References: <20121025121617.617683848@chello.nl>
Content-Disposition: inline; filename=0031-sched-numa-mm-Add-memcg-support.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ingo Molnar <mingo@kernel.org>

From: Johannes Weiner <hannes@cmpxchg.org>

[ Turned email suggestions into patch plus fixes. ]
Signed-off-by: Ingo Molnar <mingo@kernel.org>
---
 mm/huge_memory.c |   10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

Index: tip/mm/huge_memory.c
===================================================================
--- tip.orig/mm/huge_memory.c
+++ tip/mm/huge_memory.c
@@ -742,6 +742,7 @@ void do_huge_pmd_numa_page(struct mm_str
 			   unsigned int flags, pmd_t entry)
 {
 	unsigned long haddr = address & HPAGE_PMD_MASK;
+	struct mem_cgroup *memcg = NULL;
 	struct page *new_page = NULL;
 	struct page *page = NULL;
 	int node, lru;
@@ -800,6 +801,8 @@ migrate:
 	if (!new_page)
 		goto alloc_fail;
 
+	mem_cgroup_prepare_migration(page, new_page, &memcg);
+
 	lru = PageLRU(page);
 
 	if (lru && isolate_lru_page(page)) /* does an implicit get_page() */
@@ -852,14 +855,19 @@ migrate:
 		put_page(page);		/* drop the LRU isolation reference */
 
 	unlock_page(new_page);
+
+	mem_cgroup_end_migration(memcg, page, new_page, true);
+
 	unlock_page(page);
 	put_page(page);			/* Drop the local reference */
 
 	return;
 
 alloc_fail:
-	if (new_page)
+	if (new_page) {
+		mem_cgroup_end_migration(memcg, page, new_page, false);
 		put_page(new_page);
+	}
 
 	unlock_page(page);
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
