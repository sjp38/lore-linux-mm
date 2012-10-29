Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id 32B6F6B006C
	for <linux-mm@kvack.org>; Mon, 29 Oct 2012 02:50:50 -0400 (EDT)
Received: by mail-ee0-f41.google.com with SMTP id c4so2409410eek.14
        for <linux-mm@kvack.org>; Sun, 28 Oct 2012 23:50:48 -0700 (PDT)
Date: Mon, 29 Oct 2012 07:50:44 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: [PATCH] sched, numa, mm: Add memcg support to do_huge_pmd_numa_page()
Message-ID: <20121029065044.GB14107@gmail.com>
References: <20121025121617.617683848@chello.nl>
 <508A52E1.8020203@redhat.com>
 <1351242480.12171.48.camel@twins>
 <20121028175615.GC29827@cmpxchg.org>
 <508DEDA2.9030503@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <508DEDA2.9030503@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhouping Liu <zliu@redhat.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org


* Zhouping Liu <zliu@redhat.com> wrote:

> Hi Johannes,
> 
> Tested the below patch, and I'm sure it has fixed the above 
> issue, thank you.

Thanks. Below is the folded up patch.

	Ingo

---------------------------->
Subject: sched, numa, mm: Add memcg support to do_huge_pmd_numa_page()
From: Johannes Weiner <hannes@cmpxchg.org>
Date: Thu Oct 25 12:49:51 CEST 2012

Add memory control group support to hugepage migration.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Tested-by: Zhouping Liu <zliu@redhat.com>
Link: http://lkml.kernel.org/n/tip-rDk9mgpoyhZlwh2xhlykvgnp@git.kernel.org
Signed-off-by: Ingo Molnar <mingo@kernel.org>
---
 mm/huge_memory.c |   15 +++++++++++++++
 1 file changed, 15 insertions(+)

Index: tip/mm/huge_memory.c
===================================================================
--- tip.orig/mm/huge_memory.c
+++ tip/mm/huge_memory.c
@@ -743,6 +743,7 @@ void do_huge_pmd_numa_page(struct mm_str
 			   unsigned int flags, pmd_t entry)
 {
 	unsigned long haddr = address & HPAGE_PMD_MASK;
+	struct mem_cgroup *memcg = NULL;
 	struct page *new_page = NULL;
 	struct page *page = NULL;
 	int node, lru;
@@ -833,6 +834,14 @@ migrate:
 
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
@@ -843,6 +852,12 @@ migrate:
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

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
