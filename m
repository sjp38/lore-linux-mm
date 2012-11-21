Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id A865E6B0078
	for <linux-mm@kvack.org>; Tue, 20 Nov 2012 23:10:28 -0500 (EST)
Received: by mail-gh0-f177.google.com with SMTP id g22so1333948ghb.8
        for <linux-mm@kvack.org>; Tue, 20 Nov 2012 20:10:27 -0800 (PST)
Date: Tue, 20 Nov 2012 20:10:23 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: numa/core regressions fixed - more testers wanted
In-Reply-To: <50AC4912.7040503@redhat.com>
Message-ID: <alpine.LNX.2.00.1211201947510.985@eggly.anvils>
References: <1353291284-2998-1-git-send-email-mingo@kernel.org>  <20121119162909.GL8218@suse.de> <20121119191339.GA11701@gmail.com>  <20121119211804.GM8218@suse.de> <20121119223604.GA13470@gmail.com>  <CA+55aFzQYH4qW_Cw3aHPT0bxsiC_Q_ggy4YtfvapiMG7bR=FsA@mail.gmail.com>
  <20121120071704.GA14199@gmail.com> <20121120152933.GA17996@gmail.com>  <20121120175647.GA23532@gmail.com> <1353462853.31820.93.camel@oc6622382223.ibm.com> <50AC4912.7040503@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: habanero@linux.vnet.ibm.com, Ingo Molnar <mingo@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>

On Tue, 20 Nov 2012, Rik van Riel wrote:
> On 11/20/2012 08:54 PM, Andrew Theurer wrote:
> 
> > I can confirm single JVM JBB is working well for me.  I see a 30%
> > improvement over autoNUMA.  What I can't make sense of is some perf
> > stats (taken at 80 warehouses on 4 x WST-EX, 512GB memory):
> 
> AutoNUMA does not have native THP migration, that may explain some
> of the difference.

When I made some fixes to the sched/numa native THP migration,
I did also try porting that (with Hannes's memcg fixes) to AutoNUMA.

Here's the patch below: it appeared to be working just fine, but
you might find that it doesn't quite apply to whatever tree you're
using.  I started from 3.6 autonuma28fast in aa.git, but had folded
in some of the equally applicable TLB flush optimizations too.

There's also a little "Hack, remove after THP native migration"
retuning in mm/huge_memory.c which should probably be removed too.

No signoffs, but it's from work by Peter and Ingo and Hannes and Hugh.
---

 include/linux/huge_mm.h |    4 -
 mm/autonuma.c           |   59 +++++-----------
 mm/huge_memory.c        |  140 +++++++++++++++++++++++++++++++++-----
 mm/internal.h           |    5 -
 mm/memcontrol.c         |    7 +
 mm/memory.c             |    4 -
 mm/migrate.c            |    2 
 7 files changed, 158 insertions(+), 63 deletions(-)

--- 306aa/include/linux/huge_mm.h	2012-11-04 10:21:30.965548793 -0800
+++ 306AA/include/linux/huge_mm.h	2012-11-04 17:14:32.232651475 -0800
@@ -11,8 +11,8 @@ extern int copy_huge_pmd(struct mm_struc
 extern int do_huge_pmd_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 			       unsigned long address, pmd_t *pmd,
 			       pmd_t orig_pmd);
-extern int huge_pmd_numa_fixup(struct mm_struct *mm, unsigned long addr,
-			       pmd_t pmd, pmd_t *pmdp);
+extern int huge_pmd_numa_fixup(struct mm_struct *mm, struct vm_area_struct *vma,
+			     unsigned long address, pmd_t *pmd, pmd_t orig_pmd);
 extern pgtable_t get_pmd_huge_pte(struct mm_struct *mm);
 extern struct page *follow_trans_huge_pmd(struct mm_struct *mm,
 					  unsigned long addr,
--- 306aa/mm/autonuma.c	2012-11-04 10:22:13.993549816 -0800
+++ 306AA/mm/autonuma.c	2012-11-04 21:24:43.045622669 -0800
@@ -77,8 +77,7 @@ void autonuma_migrate_split_huge_page(st
 
 static int sync_isolate_migratepages(struct list_head *migratepages,
 				     struct page *page,
-				     struct pglist_data *pgdat,
-				     bool *migrated)
+				     struct pglist_data *pgdat)
 {
 	struct zone *zone;
 	struct lruvec *lruvec;
@@ -129,19 +128,9 @@ static int sync_isolate_migratepages(str
 	 * __isolate_lru_page successd, the page could be freed and
 	 * reallocated out from under us. Thus our previous checks on
 	 * the page, and the split_huge_page, would be worthless.
-	 *
-	 * We really only need to do this if "ret > 0" but it doesn't
-	 * hurt to do it unconditionally as nobody can reference
-	 * "page" anymore after this and so we can avoid an "if (ret >
-	 * 0)" branch here.
 	 */
-	put_page(page);
-	/*
-	 * Tell the caller we already released its pin, to avoid a
-	 * double free.
-	 */
-	*migrated = true;
-
+	if (ret > 0)
+		put_page(page);
 out:
 	return ret;
 }
@@ -215,13 +204,12 @@ static inline void autonuma_migrate_unlo
 	spin_unlock(&NODE_DATA(nid)->autonuma_migrate_lock);
 }
 
-static bool autonuma_migrate_page(struct page *page, int dst_nid,
-				  int page_nid, bool *migrated)
+static bool autonuma_migrate_page(struct page *page, int dst_nid, int page_nid,
+				  int nr_pages)
 {
 	int isolated = 0;
 	LIST_HEAD(migratepages);
 	struct pglist_data *pgdat = NODE_DATA(dst_nid);
-	int nr_pages = hpage_nr_pages(page);
 	unsigned long autonuma_migrate_nr_pages = 0;
 
 	autonuma_migrate_lock(dst_nid);
@@ -242,11 +230,12 @@ static bool autonuma_migrate_page(struct
 		autonuma_printk("migrated %lu pages to node %d\n",
 				autonuma_migrate_nr_pages, dst_nid);
 
-	if (autonuma_balance_pgdat(pgdat, nr_pages))
+	if (autonuma_balance_pgdat(pgdat, nr_pages)) {
+		if (nr_pages > 1)
+			return true;
 		isolated = sync_isolate_migratepages(&migratepages,
-						     page, pgdat,
-						     migrated);
-
+						     page, pgdat);
+	}
 	if (isolated) {
 		int err;
 		trace_numa_migratepages_begin(current, &migratepages,
@@ -381,15 +370,14 @@ static bool should_migrate_page(struct t
 static int numa_hinting_fault_memory_follow_cpu(struct task_struct *p,
 						struct page *page,
 						int this_nid, int page_nid,
-						bool *migrated)
+						int numpages)
 {
 	if (!should_migrate_page(p, page, this_nid, page_nid))
 		goto out;
 	if (!PageLRU(page))
 		goto out;
 	if (this_nid != page_nid) {
-		if (autonuma_migrate_page(page, this_nid, page_nid,
-					  migrated))
+		if (autonuma_migrate_page(page, this_nid, page_nid, numpages))
 			return this_nid;
 	}
 out:
@@ -418,14 +406,17 @@ bool numa_hinting_fault(struct page *pag
 		VM_BUG_ON(this_nid < 0);
 		VM_BUG_ON(this_nid >= MAX_NUMNODES);
 		access_nid = numa_hinting_fault_memory_follow_cpu(p, page,
-								  this_nid,
-								  page_nid,
-								  &migrated);
-		/* "page" has been already freed if "migrated" is true */
+						this_nid, page_nid, numpages);
 		numa_hinting_fault_cpu_follow_memory(p, access_nid, numpages);
+		migrated = access_nid != page_nid;
 	}
 
-	return migrated;
+	/* small page was already freed if migrated */
+	if (!migrated) {
+		put_page(page);
+		return false;
+	}
+	return true;
 }
 
 /* NUMA hinting page fault entry point for ptes */
@@ -434,7 +425,6 @@ int pte_numa_fixup(struct mm_struct *mm,
 {
 	struct page *page;
 	spinlock_t *ptl;
-	bool migrated;
 
 	/*
 	 * The "pte" at this point cannot be used safely without
@@ -455,9 +445,7 @@ int pte_numa_fixup(struct mm_struct *mm,
 	get_page(page);
 	pte_unmap_unlock(ptep, ptl);
 
-	migrated = numa_hinting_fault(page, 1);
-	if (!migrated)
-		put_page(page);
+	numa_hinting_fault(page, 1);
 out:
 	return 0;
 
@@ -476,7 +464,6 @@ int pmd_numa_fixup(struct mm_struct *mm,
 	spinlock_t *ptl;
 	bool numa = false;
 	struct vm_area_struct *vma;
-	bool migrated;
 
 	spin_lock(&mm->page_table_lock);
 	pmd = *pmdp;
@@ -521,9 +508,7 @@ int pmd_numa_fixup(struct mm_struct *mm,
 		get_page(page);
 		pte_unmap_unlock(pte, ptl);
 
-		migrated = numa_hinting_fault(page, 1);
-		if (!migrated)
-			put_page(page);
+		numa_hinting_fault(page, 1);
 
 		pte = pte_offset_map_lock(mm, pmdp, addr, &ptl);
 	}
--- 306aa/mm/huge_memory.c	2012-11-04 15:32:28.512793096 -0800
+++ 306AA/mm/huge_memory.c	2012-11-04 22:21:14.112450390 -0800
@@ -17,6 +17,7 @@
 #include <linux/khugepaged.h>
 #include <linux/freezer.h>
 #include <linux/mman.h>
+#include <linux/migrate.h>
 #include <linux/autonuma.h>
 #include <asm/tlb.h>
 #include <asm/pgalloc.h>
@@ -1037,35 +1038,140 @@ out:
 
 #ifdef CONFIG_AUTONUMA
 /* NUMA hinting page fault entry point for trans huge pmds */
-int huge_pmd_numa_fixup(struct mm_struct *mm, unsigned long addr,
-			pmd_t pmd, pmd_t *pmdp)
+int huge_pmd_numa_fixup(struct mm_struct *mm, struct vm_area_struct *vma,
+			unsigned long address, pmd_t *pmd, pmd_t entry)
 {
+	unsigned long haddr = address & HPAGE_PMD_MASK;
+	struct mem_cgroup *memcg = NULL;
+	struct page *new_page;
 	struct page *page;
-	bool migrated;
 
 	spin_lock(&mm->page_table_lock);
-	if (unlikely(!pmd_same(pmd, *pmdp)))
-		goto out_unlock;
+	if (unlikely(!pmd_same(entry, *pmd)))
+		goto unlock;
 
-	page = pmd_page(pmd);
-	pmd = pmd_mknonnuma(pmd);
-	set_pmd_at(mm, addr & HPAGE_PMD_MASK, pmdp, pmd);
-	VM_BUG_ON(pmd_numa(*pmdp));
-	if (unlikely(page_mapcount(page) != 1))
-		goto out_unlock;
+	page = pmd_page(entry);
+	/*
+	 * Do not migrate this page if it is mapped anywhere else.
+	 * Do not migrate this page if its count has been raised.
+	 * Our caller's down_read of mmap_sem excludes fork raising
+	 * mapcount; but recheck page count below whenever we take
+	 * page_table_lock - although it's unclear what pin we are
+	 * protecting against, since get_user_pages() or GUP fast
+	 * would have to fault it present before they could proceed.
+	 */
+	if (unlikely(page_count(page) != 1))
+		goto fixup;
 	get_page(page);
 	spin_unlock(&mm->page_table_lock);
 
-	migrated = numa_hinting_fault(page, HPAGE_PMD_NR);
-	if (!migrated)
-		put_page(page);
+	if (numa_hinting_fault(page, HPAGE_PMD_NR))
+		goto migrate;
 
-out:
+	spin_lock(&mm->page_table_lock);
+	if (unlikely(!pmd_same(entry, *pmd)))
+		goto unlock;
+fixup:
+	entry = pmd_mknonnuma(entry);
+	set_pmd_at(mm, haddr, pmd, entry);
+	VM_BUG_ON(pmd_numa(*pmd));
+	update_mmu_cache(vma, address, entry);
+
+unlock:
+	spin_unlock(&mm->page_table_lock);
 	return 0;
 
-out_unlock:
+migrate:
+	lock_page(page);
+	spin_lock(&mm->page_table_lock);
+	if (unlikely(!pmd_same(*pmd, entry) || page_count(page) != 2)) {
+		spin_unlock(&mm->page_table_lock);
+		unlock_page(page);
+		put_page(page);
+		return 0;
+	}
 	spin_unlock(&mm->page_table_lock);
-	goto out;
+
+	new_page = alloc_pages_node(numa_node_id(),
+	    (GFP_TRANSHUGE | GFP_THISNODE) & ~__GFP_WAIT, HPAGE_PMD_ORDER);
+	if (!new_page)
+		goto alloc_fail;
+
+	if (isolate_lru_page(page)) {	/* Does an implicit get_page() */
+		put_page(new_page);
+		goto alloc_fail;
+	}
+
+	__set_page_locked(new_page);
+	SetPageSwapBacked(new_page);
+
+	/* anon mapping, we can simply copy page->mapping to the new page: */
+	new_page->mapping = page->mapping;
+	new_page->index = page->index;
+
+	migrate_page_copy(new_page, page);
+
+	WARN_ON(PageLRU(new_page));
+
+	spin_lock(&mm->page_table_lock);
+	if (unlikely(!pmd_same(*pmd, entry) || page_count(page) != 3)) {
+		spin_unlock(&mm->page_table_lock);
+
+		/* Reverse changes made by migrate_page_copy() */
+		if (TestClearPageActive(new_page))
+			SetPageActive(page);
+		if (TestClearPageUnevictable(new_page))
+			SetPageUnevictable(page);
+		mlock_migrate_page(page, new_page);
+
+		unlock_page(new_page);
+		put_page(new_page);		/* Free it */
+
+		unlock_page(page);
+		putback_lru_page(page);
+		put_page(page);			/* Drop the local reference */
+		return 0;
+	}
+	/*
+	 * Traditional migration needs to prepare the memcg charge
+	 * transaction early to prevent the old page from being
+	 * uncharged when installing migration entries.  Here we can
+	 * save the potential rollback and start the charge transfer
+	 * only when migration is already known to end successfully.
+	 */
+	mem_cgroup_prepare_migration(page, new_page, &memcg);
+
+	entry = mk_pmd(new_page, vma->vm_page_prot);
+	entry = maybe_pmd_mkwrite(pmd_mkdirty(entry), vma);
+	entry = pmd_mkhuge(entry);
+
+	page_add_new_anon_rmap(new_page, vma, haddr);
+
+	set_pmd_at(mm, haddr, pmd, entry);
+	update_mmu_cache(vma, address, entry);
+	page_remove_rmap(page);
+	/*
+	 * Finish the charge transaction under the page table lock to
+	 * prevent split_huge_page() from dividing up the charge
+	 * before it's fully transferred to the new page.
+	 */
+	mem_cgroup_end_migration(memcg, page, new_page, true);
+	spin_unlock(&mm->page_table_lock);
+
+	unlock_page(new_page);
+	unlock_page(page);
+	put_page(page);			/* Drop the rmap reference */
+	put_page(page);			/* Drop the LRU isolation reference */
+	put_page(page);			/* Drop the local reference */
+	return 0;
+
+alloc_fail:
+	unlock_page(page);
+	put_page(page);
+	spin_lock(&mm->page_table_lock);
+	if (unlikely(!pmd_same(*pmd, entry)))
+		goto unlock;
+	goto fixup;
 }
 #endif
 
--- 306aa/mm/internal.h	2012-09-30 16:47:46.000000000 -0700
+++ 306AA/mm/internal.h	2012-11-04 16:16:21.760439246 -0800
@@ -216,11 +216,12 @@ static inline void mlock_migrate_page(st
 {
 	if (TestClearPageMlocked(page)) {
 		unsigned long flags;
+		int nr_pages = hpage_nr_pages(page);
 
 		local_irq_save(flags);
-		__dec_zone_page_state(page, NR_MLOCK);
+		__mod_zone_page_state(page_zone(page), NR_MLOCK, -nr_pages);
 		SetPageMlocked(newpage);
-		__inc_zone_page_state(newpage, NR_MLOCK);
+		__mod_zone_page_state(page_zone(newpage), NR_MLOCK, nr_pages);
 		local_irq_restore(flags);
 	}
 }
--- 306aa/mm/memcontrol.c	2012-09-30 16:47:46.000000000 -0700
+++ 306AA/mm/memcontrol.c	2012-11-04 16:15:55.264437693 -0800
@@ -3261,15 +3261,18 @@ void mem_cgroup_prepare_migration(struct
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
@@ -3331,7 +3334,7 @@ void mem_cgroup_prepare_migration(struct
 	 * charged to the res_counter since we plan on replacing the
 	 * old one and only one page is going to be left afterwards.
 	 */
-	__mem_cgroup_commit_charge(memcg, newpage, 1, ctype, false);
+	__mem_cgroup_commit_charge(memcg, newpage, nr_pages, ctype, false);
 }
 
 /* remove redundant charge if migration failed*/
--- 306aa/mm/memory.c	2012-11-04 10:21:34.181548869 -0800
+++ 306AA/mm/memory.c	2012-11-04 17:06:11.400620099 -0800
@@ -3546,8 +3546,8 @@ retry:
 		barrier();
 		if (pmd_trans_huge(orig_pmd)) {
 			if (pmd_numa(*pmd))
-				return huge_pmd_numa_fixup(mm, address,
-							   orig_pmd, pmd);
+				return huge_pmd_numa_fixup(mm, vma, address,
+							   pmd, orig_pmd);
 			if (flags & FAULT_FLAG_WRITE &&
 			    !pmd_write(orig_pmd) &&
 			    !pmd_trans_splitting(orig_pmd)) {
--- 306aa/mm/migrate.c	2012-09-30 16:47:46.000000000 -0700
+++ 306AA/mm/migrate.c	2012-11-04 17:10:13.084633509 -0800
@@ -407,7 +407,7 @@ int migrate_huge_page_move_mapping(struc
  */
 void migrate_page_copy(struct page *newpage, struct page *page)
 {
-	if (PageHuge(page))
+	if (PageHuge(page) || PageTransHuge(page))
 		copy_huge_page(newpage, page);
 	else
 		copy_highpage(newpage, page);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
