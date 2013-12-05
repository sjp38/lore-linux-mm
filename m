Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f180.google.com (mail-ea0-f180.google.com [209.85.215.180])
	by kanga.kvack.org (Postfix) with ESMTP id 8F58F6B0031
	for <linux-mm@kvack.org>; Thu,  5 Dec 2013 14:54:58 -0500 (EST)
Received: by mail-ea0-f180.google.com with SMTP id f15so11448898eak.25
        for <linux-mm@kvack.org>; Thu, 05 Dec 2013 11:54:58 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTP id p9si47580963eew.13.2013.12.05.11.54.57
        for <linux-mm@kvack.org>;
        Thu, 05 Dec 2013 11:54:57 -0800 (PST)
Date: Thu, 5 Dec 2013 19:54:46 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 14/15] mm: numa: Flush TLB if NUMA hinting faults race
 with PTE scan update
Message-ID: <20131205195446.GI11295@suse.de>
References: <1386060721-3794-1-git-send-email-mgorman@suse.de>
 <1386060721-3794-15-git-send-email-mgorman@suse.de>
 <529E641A.7040804@redhat.com>
 <20131203234637.GS11295@suse.de>
 <529F3D51.1090203@redhat.com>
 <20131204160741.GC11295@suse.de>
 <20131205104015.716ed0fe@annuminas.surriel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20131205104015.716ed0fe@annuminas.surriel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Alex Thorlton <athorlton@sgi.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, hhuang@redhat.com

On Thu, Dec 05, 2013 at 10:40:15AM -0500, Rik van Riel wrote:
> On Wed, 4 Dec 2013 16:07:41 +0000
> Mel Gorman <mgorman@suse.de> wrote:
> 
> > Because I found it impossible to segfault processes under any level of
> > scanning and numa hinting fault stress after it was applied
>  
> I think I still managed to trigger the bug, by setting numa page
> scanning to ludicrous speed, and running two large specjbb2005
> processes on a 4 node system in an infinite loop :)
> 
> I believe the reason is your patch flushes the TLB too late,
> after the page contents have been migrated over to the new
> page.
> 
> The changelog below should explain how the race works, and
> how this patch supposedly fixes it. If it doesn't, let me
> know and I'll go back to the drawing board :)
> 

I think that's a better fit and a neater fix. Thanks! I think it barriers
more than it needs to (definite cost vs maybe cost), the flush can be
deferred until we are definitely trying to migrate and the pte case is
not guaranteed to be flushed before migration due to pte_mknonnuma causing
a flush in ptep_clear_flush to be avoided later. Mashing the two patches
together yields this.

---8<---
mm,numa: fix memory corrupter race between THP NUMA unmap and migrate

There is a subtle race between THP NUMA migration, and the NUMA
unmapping code.

The NUMA unmapping code does a permission change on pages, which
is done with a batched (deferred) TLB flush. This is normally safe,
because the pages stay in the same place, and having other CPUs
continue to access them until the TLB flush is indistinguishable
from having other CPUs do those same accesses before the PTE
permission change.

The THP NUMA migration code normally does not do a remote TLB flush,
because the PTE is marked inaccessible, meaning no other CPUs should
have cached TLB entries that allow them to access the memory.

However, the following race is possible:

CPU A			CPU B			CPU C

						load TLB entry
make entry PMD_NUMA
			fault on entry
						write to page
			start migrating page
						write to page
			change PMD to new page
flush TLB
						reload TLB from new entry
						lose data

The obvious fix is to flush remote TLB entries from the numa
migrate code on CPU B, while CPU A is making PTE changes, and
has the TLB flush batched up for later.

The migration for 4kB pages is currently fine, because it calls
mk_ptenonnuma before migrating the page, which causes the migration
code to always do a remote TLB flush.  We should probably optimize
that at some point...

Signed-off-by: Rik van Riel <riel@redhat.com>
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/linux/migrate.h  |  6 ++++--
 include/linux/mm_types.h |  3 +++
 kernel/sched/core.c      |  1 +
 kernel/sched/fair.c      |  6 ++++++
 mm/memory.c              |  2 +-
 mm/migrate.c             | 30 +++++++++++++++++++++++++-----
 6 files changed, 40 insertions(+), 8 deletions(-)

diff --git a/include/linux/migrate.h b/include/linux/migrate.h
index 804651c..5c60606 100644
--- a/include/linux/migrate.h
+++ b/include/linux/migrate.h
@@ -92,7 +92,8 @@ static inline int migrate_huge_page_move_mapping(struct address_space *mapping,
 #ifdef CONFIG_NUMA_BALANCING
 extern bool pmd_trans_migrating(pmd_t pmd);
 extern void wait_migrate_huge_page(struct anon_vma *anon_vma, pmd_t *pmd);
-extern int migrate_misplaced_page(struct page *page, int node);
+extern int migrate_misplaced_page(struct vm_area_struct *vma, struct page *page,
+				  unsigned long addr, int node);
 extern bool migrate_ratelimited(int node);
 #else
 static inline bool pmd_trans_migrating(pmd_t pmd)
@@ -102,7 +103,8 @@ static inline bool pmd_trans_migrating(pmd_t pmd)
 static inline void wait_migrate_huge_page(struct anon_vma *anon_vma, pmd_t *pmd)
 {
 }
-static inline int migrate_misplaced_page(struct page *page, int node)
+static inline int migrate_misplaced_page(struct vm_area_struct *vma,
+			struct page *page, unsigned long addr, int node)
 {
 	return -EAGAIN; /* can't migrate now */
 }
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index d9851ee..5e5fa017 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -429,6 +429,9 @@ struct mm_struct {
 	/* numa_scan_seq prevents two threads setting pte_numa */
 	int numa_scan_seq;
 
+	/* task_numa_work is unmapping pages, with deferred TLB flush */
+	bool numa_tlb_lazy;
+
 	/*
 	 * The first node a task was scheduled on. If a task runs on
 	 * a different node than Make PTE Scan Go Now.
diff --git a/kernel/sched/core.c b/kernel/sched/core.c
index 5ac63c9..f436736 100644
--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -1622,6 +1622,7 @@ static void __sched_fork(struct task_struct *p)
 		p->mm->numa_next_scan = jiffies;
 		p->mm->numa_next_reset = jiffies;
 		p->mm->numa_scan_seq = 0;
+		p->mm->numa_tlb_lazy = false;
 	}
 
 	p->node_stamp = 0ULL;
diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index 40d8ea3..57d44a1 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -966,6 +966,9 @@ void task_numa_work(struct callback_head *work)
 		start = 0;
 		vma = mm->mmap;
 	}
+
+	wmb(); /* with do_huge_pmd_numa_page */
+	mm->numa_tlb_lazy = true;
 	for (; vma; vma = vma->vm_next) {
 		if (!vma_migratable(vma))
 			continue;
@@ -994,6 +997,9 @@ void task_numa_work(struct callback_head *work)
 	}
 
 out:
+	wmb(); /* with do_huge_pmd_numa_page */
+	mm->numa_tlb_lazy = false;
+
 	/*
 	 * It is possible to reach the end of the VMA list but the last few VMAs are
 	 * not guaranteed to the vma_migratable. If they are not, we would find the
diff --git a/mm/memory.c b/mm/memory.c
index f453384..c077c9d 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3576,7 +3576,7 @@ int do_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	}
 
 	/* Migrate to the requested node */
-	migrated = migrate_misplaced_page(page, target_nid);
+	migrated = migrate_misplaced_page(vma, page, addr, target_nid);
 	if (migrated)
 		page_nid = target_nid;
 
diff --git a/mm/migrate.c b/mm/migrate.c
index 5dfd552..344c084 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1607,9 +1607,11 @@ bool numamigrate_update_ratelimit(pg_data_t *pgdat, unsigned long nr_pages)
 	return rate_limited;
 }
 
-int numamigrate_isolate_page(pg_data_t *pgdat, struct page *page)
+int numamigrate_isolate_page(pg_data_t *pgdat, struct vm_area_struct *vma,
+				struct page *page, unsigned long addr)
 {
 	int page_lru;
+	unsigned long nr_pages;
 
 	VM_BUG_ON(compound_order(page) && !PageTransHuge(page));
 
@@ -1633,8 +1635,25 @@ int numamigrate_isolate_page(pg_data_t *pgdat, struct page *page)
 	}
 
 	page_lru = page_is_file_cache(page);
+	nr_pages = hpage_nr_pages(page);
 	mod_zone_page_state(page_zone(page), NR_ISOLATED_ANON + page_lru,
-				hpage_nr_pages(page));
+				nr_pages);
+
+	/*
+	 * At the time this is called, another CPU is potentially turning ptes
+	 * of this process into NUMA ptes. That permission change batches the
+	 * TLB flush, so other CPUs may still have valid TLB entries pointing
+	 * to the address. These need to be flushed before migration.
+	 */
+	rmb();
+	if (vma->vm_mm->numa_tlb_lazy) {
+		if (nr_pages == 1) {
+			flush_tlb_page(vma, addr);
+		} else {
+			flush_tlb_range(vma, addr, addr +
+					(nr_pages << PAGE_SHIFT));
+		}
+	}
 
 	/*
 	 * Isolating the page has taken another reference, so the
@@ -1667,7 +1686,8 @@ void wait_migrate_huge_page(struct anon_vma *anon_vma, pmd_t *pmd)
  * node. Caller is expected to have an elevated reference count on
  * the page that will be dropped by this function before returning.
  */
-int migrate_misplaced_page(struct page *page, int node)
+int migrate_misplaced_page(struct vm_area_struct *vma, struct page *page,
+			   unsigned long addr, int node)
 {
 	pg_data_t *pgdat = NODE_DATA(node);
 	int isolated;
@@ -1689,7 +1709,7 @@ int migrate_misplaced_page(struct page *page, int node)
 	if (numamigrate_update_ratelimit(pgdat, 1))
 		goto out;
 
-	isolated = numamigrate_isolate_page(pgdat, page);
+	isolated = numamigrate_isolate_page(pgdat, vma, page, addr);
 	if (!isolated)
 		goto out;
 
@@ -1752,7 +1772,7 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
 
 	page_nid_xchg_last(new_page, page_nid_last(page));
 
-	isolated = numamigrate_isolate_page(pgdat, page);
+	isolated = numamigrate_isolate_page(pgdat, vma, page, mmun_start);
 	if (!isolated) {
 		put_page(new_page);
 		goto out_fail;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
