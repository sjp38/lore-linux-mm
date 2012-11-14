Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id 74E956B005D
	for <linux-mm@kvack.org>; Tue, 13 Nov 2012 21:27:52 -0500 (EST)
Received: by mail-ye0-f169.google.com with SMTP id q11so1670224yen.14
        for <linux-mm@kvack.org>; Tue, 13 Nov 2012 18:27:51 -0800 (PST)
Date: Tue, 13 Nov 2012 18:27:53 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 1/2] sched, numa, mm: Add memcg support to
 do_huge_pmd_numa_page()
In-Reply-To: <alpine.LNX.2.00.1211131759390.29612@eggly.anvils>
Message-ID: <alpine.LNX.2.00.1211131826090.29612@eggly.anvils>
References: <1352826834-11774-1-git-send-email-mingo@kernel.org> <1352826834-11774-22-git-send-email-mingo@kernel.org> <20121113184835.GH10092@cmpxchg.org> <alpine.LNX.2.00.1211131759390.29612@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Thomas Gleixner <tglx@linutronix.de>, Zhouping Liu <zliu@redhat.com>

From: Johannes Weiner <hannes@cmpxchg.org>

Add mem_cgroup_prepare_migration() and mem_cgroup_end_migration() calls
into do_huge_pmd_numa_page(), and fix mem_cgroup_prepare_migration() to
account for a Transparent Huge Page correctly without bugging.

Tested-by: Zhouping Liu <zliu@redhat.com>
Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Signed-off-by: Hugh Dickins <hughd@google.com>
---

 mm/huge_memory.c |   16 ++++++++++++++++
 mm/memcontrol.c  |    7 +++++--
 2 files changed, 21 insertions(+), 2 deletions(-)

--- mmotm/mm/huge_memory.c	2012-11-09 09:43:46.892046342 -0800
+++ linux/mm/huge_memory.c	2012-11-13 14:51:04.000321370 -0800
@@ -750,6 +750,7 @@ void do_huge_pmd_numa_page(struct mm_str
 			   unsigned int flags, pmd_t entry)
 {
 	unsigned long haddr = address & HPAGE_PMD_MASK;
+	struct mem_cgroup *memcg = NULL;
 	struct page *new_page = NULL;
 	struct page *page = NULL;
 	int node, lru;
@@ -840,6 +841,14 @@ migrate:
 
 		return;
 	}
+	/*
+	 * Traditional migration needs to prepare the memcg charge
+	 * transaction early to prevent the old page from being
+	 * uncharged when installing migration entries.  Here we can
+	 * save the potential rollback and start the charge transfer
+	 * only when migration is already known to end successfully.
+	 */
+	mem_cgroup_prepare_migration(page, new_page, &memcg);
 
 	entry = mk_pmd(new_page, vma->vm_page_prot);
 	entry = maybe_pmd_mkwrite(pmd_mkdirty(entry), vma);
@@ -850,6 +859,12 @@ migrate:
 	set_pmd_at(mm, haddr, pmd, entry);
 	update_mmu_cache_pmd(vma, address, entry);
 	page_remove_rmap(page);
+	/*
+	 * Finish the charge transaction under the page table lock to
+	 * prevent split_huge_page() from dividing up the charge
+	 * before it's fully transferred to the new page.
+	 */
+	mem_cgroup_end_migration(memcg, page, new_page, true);
 	spin_unlock(&mm->page_table_lock);
 
 	put_page(page);			/* Drop the rmap reference */
@@ -860,6 +875,7 @@ migrate:
 		put_page(page);		/* drop the LRU isolation reference */
 
 	unlock_page(new_page);
+
 	unlock_page(page);
 	put_page(page);			/* Drop the local reference */
 
--- mmotm/mm/memcontrol.c	2012-11-09 09:43:46.896046342 -0800
+++ linux/mm/memcontrol.c	2012-11-13 14:51:04.004321370 -0800
@@ -4186,15 +4186,18 @@ void mem_cgroup_prepare_migration(struct
 				  struct mem_cgroup **memcgp)
 {
 	struct mem_cgroup *memcg = NULL;
+	unsigned int nr_pages = 1;
 	struct page_cgroup *pc;
 	enum charge_type ctype;
 
 	*memcgp = NULL;
 
-	VM_BUG_ON(PageTransHuge(page));
 	if (mem_cgroup_disabled())
 		return;
 
+	if (PageTransHuge(page))
+		nr_pages <<= compound_order(page);
+
 	pc = lookup_page_cgroup(page);
 	lock_page_cgroup(pc);
 	if (PageCgroupUsed(pc)) {
@@ -4256,7 +4259,7 @@ void mem_cgroup_prepare_migration(struct
 	 * charged to the res_counter since we plan on replacing the
 	 * old one and only one page is going to be left afterwards.
 	 */
-	__mem_cgroup_commit_charge(memcg, newpage, 1, ctype, false);
+	__mem_cgroup_commit_charge(memcg, newpage, nr_pages, ctype, false);
 }
 
 /* remove redundant charge if migration failed*/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
