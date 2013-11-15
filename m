Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f50.google.com (mail-pb0-f50.google.com [209.85.160.50])
	by kanga.kvack.org (Postfix) with ESMTP id 028AF6B0037
	for <linux-mm@kvack.org>; Thu, 14 Nov 2013 19:09:09 -0500 (EST)
Received: by mail-pb0-f50.google.com with SMTP id xb12so2776340pbc.9
        for <linux-mm@kvack.org>; Thu, 14 Nov 2013 16:09:09 -0800 (PST)
Received: from psmtp.com ([74.125.245.179])
        by mx.google.com with SMTP id rw4si191402pac.120.2013.11.14.16.09.06
        for <linux-mm@kvack.org>;
        Thu, 14 Nov 2013 16:09:08 -0800 (PST)
Date: Fri, 15 Nov 2013 00:09:01 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: BUG: mm, numa: test segfaults, only when NUMA balancing is on
Message-ID: <20131115000901.GB26002@suse.de>
References: <20131016155429.GP25735@sgi.com>
 <20131104145828.GA1218@suse.de>
 <20131104200346.GA3066@sgi.com>
 <20131106131048.GC4877@suse.de>
 <20131107214838.GY3066@sgi.com>
 <20131108112054.GB5040@suse.de>
 <20131108221329.GD4236@sgi.com>
 <20131112212902.GA4725@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20131112212902.GA4725@sgi.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alex Thorlton <athorlton@sgi.com>
Cc: Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Nov 12, 2013 at 03:29:02PM -0600, Alex Thorlton wrote:
> On Fri, Nov 08, 2013 at 04:13:29PM -0600, Alex Thorlton wrote:
> > On Fri, Nov 08, 2013 at 11:20:54AM +0000, Mel Gorman wrote:
> > > On Thu, Nov 07, 2013 at 03:48:38PM -0600, Alex Thorlton wrote:
> > > > > Try the following patch on top of 3.12. It's a patch that is expected to
> > > > > be merged for 3.13. On its own it'll hurt automatic NUMA balancing in
> > > > > -stable but corruption trumps performance and the full series is not
> > > > > going to be considered acceptable for -stable
> > > > 
> > > > I gave this patch a shot, and it didn't seem to solve the problem.
> > > > Actually I'm running into what appear to be *worse* problems on the 3.12
> > > > kernel.  Here're a couple stack traces of what I get when I run the test
> > > > on 3.12, 512 cores:
> > > > 
> > > 
> > > Ok, so there are two issues at least. Whatever is causing your
> > > corruption (which I still cannot reproduce) and the fact that 3.12 is
> > > worse. The largest machine I've tested with is 40 cores. I'm trying to
> > > get time on a 60 core machine to see if has a better chance. I will not
> > > be able to get access to anything resembling 512 cores.
> > 
> > At this point, the smallest machine I've been able to recreate this
> > issue on has been a 128 core, but it's rare on a machine that small.
> > I'll kick off a really long run on a 64 core over the weekend and see if
> > I can hit it on there at all, but I haven't been able to previously.
> 
> Just a quick update, I ran this test 500 times on 64 cores, allocating
> 512m per core, and every single test completed successfully.  At this
> point, it looks like you definitely need at least 128 cores to reproduce
> the issue.
> 

Awesome. I checked behind the couch but did not find a 128 core machine there
so it took a while to do this the harder way instead. Try the following
patch against 3.12 on top of the pmd batch handling backport and the scan
rate fix please. The scan rate fix is optional because it should make the
bug easier to trigger but it's very important that the pmd batch handling
removal patch is applied.

Thanks.

---8<---
mm: numa: Serialise parallel get_user_page against THP migration

Base pages are unmapped and flushed from cache and TLB during normal page
migration and replaced with a migration entry that causes any parallel or
gup to block until migration completes. THP does not unmap pages due to
a lack of support for migration entries at a PMD level. This allows races
with get_user_pages and get_user_pages_fast which commit 3f926ab94 ("mm:
Close races between THP migration and PMD numa clearing") made worse by
introducing a pmd_clear_flush().

This patch forces get_user_page (fast and normal) on a pmd_numa page to
go through the slow get_user_page path where it will serialise against
THP migration and properly account for the NUMA hinting fault. On the
migration side, the TLB is flushed after the page table update and the
page table lock taken for each update. A barrier is introduced to guarantee
the page table update is visible when waiters on THP migration wake up.

---
 arch/x86/mm/gup.c |  7 +++++++
 mm/huge_memory.c  | 30 +++++++++++++++++++++---------
 mm/migrate.c      | 42 +++++++++++++++++++++++++++++++++---------
 mm/mprotect.c     |  2 +-
 4 files changed, 62 insertions(+), 19 deletions(-)

diff --git a/arch/x86/mm/gup.c b/arch/x86/mm/gup.c
index dd74e46..4b36edb 100644
--- a/arch/x86/mm/gup.c
+++ b/arch/x86/mm/gup.c
@@ -167,6 +167,13 @@ static int gup_pmd_range(pud_t pud, unsigned long addr, unsigned long end,
 		if (pmd_none(pmd) || pmd_trans_splitting(pmd))
 			return 0;
 		if (unlikely(pmd_large(pmd))) {
+			/*
+			 * NUMA hinting faults need to be handled in the GUP
+			 * slowpath for accounting purposes and so that they
+			 * can be serialised against THP migration.
+			 */
+			if (pmd_numa(pmd))
+				return 0;
 			if (!gup_huge_pmd(pmd, addr, next, write, pages, nr))
 				return 0;
 		} else {
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index cca80d9..7f91be1 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1240,6 +1240,10 @@ struct page *follow_trans_huge_pmd(struct vm_area_struct *vma,
 	if ((flags & FOLL_DUMP) && is_huge_zero_pmd(*pmd))
 		return ERR_PTR(-EFAULT);
 
+	/* Full NUMA hinting faults to serialise migration in fault paths */
+	if ((flags & FOLL_NUMA) && pmd_numa(*pmd))
+		goto out;
+
 	page = pmd_page(*pmd);
 	VM_BUG_ON(!PageHead(page));
 	if (flags & FOLL_TOUCH) {
@@ -1306,26 +1310,33 @@ int do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		/* If the page was locked, there are no parallel migrations */
 		if (page_locked)
 			goto clear_pmdnuma;
+	}
 
-		/*
-		 * Otherwise wait for potential migrations and retry. We do
-		 * relock and check_same as the page may no longer be mapped.
-		 * As the fault is being retried, do not account for it.
-		 */
+	/*
+	 * If there are potential migrations, wait for completion and retry. We
+	 * do not relock and check_same as the page may no longer be mapped.
+	 * Furtermore, even if the page is currently misplaced, there is no
+	 * guarantee it is still misplaced after the migration completes.
+	 */
+	if (!page_locked) {
 		spin_unlock(&mm->page_table_lock);
 		wait_on_page_locked(page);
 		page_nid = -1;
+
+		/* Matches barrier in migrate_misplaced_transhuge_page */
+		smp_rmb();
 		goto out;
 	}
 
-	/* Page is misplaced, serialise migrations and parallel THP splits */
+	/*
+	 * Page is misplaced. Page lock serialises migrations. Acquire anon_vma
+	 * to serialises splits
+	 */
 	get_page(page);
 	spin_unlock(&mm->page_table_lock);
-	if (!page_locked)
-		lock_page(page);
 	anon_vma = page_lock_anon_vma_read(page);
 
-	/* Confirm the PTE did not while locked */
+	/* Confirm the PTE did not change while unlocked */
 	spin_lock(&mm->page_table_lock);
 	if (unlikely(!pmd_same(pmd, *pmdp))) {
 		unlock_page(page);
@@ -1350,6 +1361,7 @@ clear_pmdnuma:
 	pmd = pmd_mknonnuma(pmd);
 	set_pmd_at(mm, haddr, pmdp, pmd);
 	VM_BUG_ON(pmd_numa(*pmdp));
+	flush_tlb_range(vma, haddr, haddr + HPAGE_PMD_SIZE);
 	update_mmu_cache_pmd(vma, addr, pmdp);
 	unlock_page(page);
 out_unlock:
diff --git a/mm/migrate.c b/mm/migrate.c
index c4f9819..535212b 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1703,9 +1703,13 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
 	migrate_page_copy(new_page, page);
 	WARN_ON(PageLRU(new_page));
 
-	/* Recheck the target PMD */
+	/*
+	 * Recheck the target PMD. A parallel GUP should be impossible due to
+	 * it going through handle_mm_fault, stalling on the page lock and
+	 * retrying. Catch the situation and warn if it happens
+	 */
 	spin_lock(&mm->page_table_lock);
-	if (unlikely(!pmd_same(*pmd, entry))) {
+	if (!pmd_same(*pmd, entry) || WARN_ON_ONCE(page_count(page) != 2)) {
 		spin_unlock(&mm->page_table_lock);
 
 		/* Reverse changes made by migrate_page_copy() */
@@ -1736,15 +1740,23 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
 	mem_cgroup_prepare_migration(page, new_page, &memcg);
 
 	entry = mk_pmd(new_page, vma->vm_page_prot);
-	entry = pmd_mknonnuma(entry);
-	entry = maybe_pmd_mkwrite(pmd_mkdirty(entry), vma);
 	entry = pmd_mkhuge(entry);
+	entry = maybe_pmd_mkwrite(pmd_mkdirty(entry), vma);
 
-	pmdp_clear_flush(vma, haddr, pmd);
-	set_pmd_at(mm, haddr, pmd, entry);
+	/*
+	 * Clear the old entry under pagetable lock and establish the new PTE.
+	 * Any parallel GUP will either observe the old page blocking on the
+	 * page lock, block on the page table lock or observe the new page.
+	 * The SetPageUptodate on the new page and page_add_new_anon_rmap
+	 * guarantee the copy is visible before the pagetable update.
+	 */
+	flush_cache_range(vma, haddr, haddr + HPAGE_PMD_SIZE);
 	page_add_new_anon_rmap(new_page, vma, haddr);
+	set_pmd_at(mm, haddr, pmd, entry);
+	flush_tlb_range(vma, haddr, haddr + HPAGE_PMD_SIZE);
 	update_mmu_cache_pmd(vma, address, &entry);
 	page_remove_rmap(page);
+
 	/*
 	 * Finish the charge transaction under the page table lock to
 	 * prevent split_huge_page() from dividing up the charge
@@ -1753,6 +1765,13 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
 	mem_cgroup_end_migration(memcg, page, new_page, true);
 	spin_unlock(&mm->page_table_lock);
 
+	/*
+	 * unlock_page is not a barrier. Guarantee that the page table update
+	 * is visible to any process waiting on the page lock. Matches the
+	 * smp_rmb in do_huge_pmd_numa_page.
+	 */
+	smp_wmb();
+
 	unlock_page(new_page);
 	unlock_page(page);
 	put_page(page);			/* Drop the rmap reference */
@@ -1769,9 +1788,14 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
 out_fail:
 	count_vm_events(PGMIGRATE_FAIL, HPAGE_PMD_NR);
 out_dropref:
-	entry = pmd_mknonnuma(entry);
-	set_pmd_at(mm, haddr, pmd, entry);
-	update_mmu_cache_pmd(vma, address, &entry);
+	spin_lock(&mm->page_table_lock);
+	if (pmd_same(*pmd, entry)) {
+		entry = pmd_mknonnuma(entry);
+		set_pmd_at(mm, haddr, pmd, entry);
+		flush_tlb_range(vma, haddr, haddr + HPAGE_PMD_SIZE);
+		update_mmu_cache_pmd(vma, address, &entry);
+	}
+	spin_unlock(&mm->page_table_lock);
 
 	unlock_page(page);
 	put_page(page);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
