Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id CAC6C6B0036
	for <linux-mm@kvack.org>; Thu, 31 Oct 2013 05:51:51 -0400 (EDT)
Received: by mail-pd0-f177.google.com with SMTP id p10so2142365pdj.22
        for <linux-mm@kvack.org>; Thu, 31 Oct 2013 02:51:51 -0700 (PDT)
Received: from psmtp.com ([74.125.245.128])
        by mx.google.com with SMTP id rr7si1373416pbc.75.2013.10.31.02.51.48
        for <linux-mm@kvack.org>;
        Thu, 31 Oct 2013 02:51:50 -0700 (PDT)
Received: by mail-ea0-f176.google.com with SMTP id q16so1234235ead.7
        for <linux-mm@kvack.org>; Thu, 31 Oct 2013 02:51:46 -0700 (PDT)
Date: Thu, 31 Oct 2013 10:51:44 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: [RFC GIT PULL] NUMA-balancing memory corruption fixes
Message-ID: <20131031095143.GA9692@gmail.com>
References: <1381141781-10992-1-git-send-email-mgorman@suse.de>
 <20131024122646.GB2402@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131024122646.GB2402@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Tom Weber <l_linux-kernel@mail2news.4t2.com>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>


Linus,

* Mel Gorman <mgorman@suse.de> wrote:

> Hi Ingo,
> 
> Off-list we talked with Peter about the fact that automatic NUMA 
> balancing as merged in 3.10, 3.11 and 3.12 shortly may corrupt 
> userspace memory. [...]

So these fixes are definitely not something I'd like to sit on, but 
as I said to you at the KS the timing is quite tight, with Linus 
planning v3.12-final within a week.

Fedora-19 is affected:

 comet:~> grep NUMA_BALANCING /boot/config-3.11.3-201.fc19.x86_64 

 CONFIG_ARCH_SUPPORTS_NUMA_BALANCING=y
 CONFIG_NUMA_BALANCING_DEFAULT_ENABLED=y
 CONFIG_NUMA_BALANCING=y

AFAICS Ubuntu will be affected as well, once it updates the kernel:

 hubble:~> grep NUMA_BALANCING /boot/config-3.8.0-32-generic 

 CONFIG_ARCH_SUPPORTS_NUMA_BALANCING=y
 CONFIG_NUMA_BALANCING_DEFAULT_ENABLED=y
 CONFIG_NUMA_BALANCING=y

Linus, please consider pulling the latest core-urgent-for-linus git 
tree from:

   git://git.kernel.org/pub/scm/linux/kernel/git/tip/tip.git core-urgent-for-linus

   # HEAD: 0255d491848032f6c601b6410c3b8ebded3a37b1 mm: Account for a THP NUMA hinting update as one PTE update

These 6 commits are a minimalized set of cherry-picks needed to fix 
the memory corruption bugs. All commits are fixes, except "mm: numa: 
Sanitize task_numa_fault() callsites" which is a cleanup that made 
two followup fixes simpler.

I've done targeted testing with just this SHA1 to try to make sure 
there are no cherry-picking artifacts. The original 
non-cherry-picked set of fixes were exposed to linux-next for a 
couple of weeks.

( If you think this is too dangerous for too little benefit then
  I'll drop this separate tree and will send the original commits in 
  the merge window. )

 Thanks,

	Ingo

------------------>
Mel Gorman (6):
      mm: numa: Do not account for a hinting fault if we raced
      mm: Wait for THP migrations to complete during NUMA hinting faults
      mm: Prevent parallel splits during THP migration
      mm: numa: Sanitize task_numa_fault() callsites
      mm: Close races between THP migration and PMD numa clearing
      mm: Account for a THP NUMA hinting update as one PTE update


 mm/huge_memory.c | 70 ++++++++++++++++++++++++++++++++++++++------------------
 mm/memory.c      | 53 +++++++++++++++++-------------------------
 mm/migrate.c     | 19 ++++++++-------
 mm/mprotect.c    |  2 +-
 4 files changed, 81 insertions(+), 63 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 610e3df..cca80d9 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1278,64 +1278,90 @@ out:
 int do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 				unsigned long addr, pmd_t pmd, pmd_t *pmdp)
 {
+	struct anon_vma *anon_vma = NULL;
 	struct page *page;
 	unsigned long haddr = addr & HPAGE_PMD_MASK;
+	int page_nid = -1, this_nid = numa_node_id();
 	int target_nid;
-	int current_nid = -1;
-	bool migrated;
+	bool page_locked;
+	bool migrated = false;
 
 	spin_lock(&mm->page_table_lock);
 	if (unlikely(!pmd_same(pmd, *pmdp)))
 		goto out_unlock;
 
 	page = pmd_page(pmd);
-	get_page(page);
-	current_nid = page_to_nid(page);
+	page_nid = page_to_nid(page);
 	count_vm_numa_event(NUMA_HINT_FAULTS);
-	if (current_nid == numa_node_id())
+	if (page_nid == this_nid)
 		count_vm_numa_event(NUMA_HINT_FAULTS_LOCAL);
 
+	/*
+	 * Acquire the page lock to serialise THP migrations but avoid dropping
+	 * page_table_lock if at all possible
+	 */
+	page_locked = trylock_page(page);
 	target_nid = mpol_misplaced(page, vma, haddr);
 	if (target_nid == -1) {
-		put_page(page);
-		goto clear_pmdnuma;
+		/* If the page was locked, there are no parallel migrations */
+		if (page_locked)
+			goto clear_pmdnuma;
+
+		/*
+		 * Otherwise wait for potential migrations and retry. We do
+		 * relock and check_same as the page may no longer be mapped.
+		 * As the fault is being retried, do not account for it.
+		 */
+		spin_unlock(&mm->page_table_lock);
+		wait_on_page_locked(page);
+		page_nid = -1;
+		goto out;
 	}
 
-	/* Acquire the page lock to serialise THP migrations */
+	/* Page is misplaced, serialise migrations and parallel THP splits */
+	get_page(page);
 	spin_unlock(&mm->page_table_lock);
-	lock_page(page);
+	if (!page_locked)
+		lock_page(page);
+	anon_vma = page_lock_anon_vma_read(page);
 
 	/* Confirm the PTE did not while locked */
 	spin_lock(&mm->page_table_lock);
 	if (unlikely(!pmd_same(pmd, *pmdp))) {
 		unlock_page(page);
 		put_page(page);
+		page_nid = -1;
 		goto out_unlock;
 	}
-	spin_unlock(&mm->page_table_lock);
 
-	/* Migrate the THP to the requested node */
+	/*
+	 * Migrate the THP to the requested node, returns with page unlocked
+	 * and pmd_numa cleared.
+	 */
+	spin_unlock(&mm->page_table_lock);
 	migrated = migrate_misplaced_transhuge_page(mm, vma,
 				pmdp, pmd, addr, page, target_nid);
-	if (!migrated)
-		goto check_same;
-
-	task_numa_fault(target_nid, HPAGE_PMD_NR, true);
-	return 0;
+	if (migrated)
+		page_nid = target_nid;
 
-check_same:
-	spin_lock(&mm->page_table_lock);
-	if (unlikely(!pmd_same(pmd, *pmdp)))
-		goto out_unlock;
+	goto out;
 clear_pmdnuma:
+	BUG_ON(!PageLocked(page));
 	pmd = pmd_mknonnuma(pmd);
 	set_pmd_at(mm, haddr, pmdp, pmd);
 	VM_BUG_ON(pmd_numa(*pmdp));
 	update_mmu_cache_pmd(vma, addr, pmdp);
+	unlock_page(page);
 out_unlock:
 	spin_unlock(&mm->page_table_lock);
-	if (current_nid != -1)
-		task_numa_fault(current_nid, HPAGE_PMD_NR, false);
+
+out:
+	if (anon_vma)
+		page_unlock_anon_vma_read(anon_vma);
+
+	if (page_nid != -1)
+		task_numa_fault(page_nid, HPAGE_PMD_NR, migrated);
+
 	return 0;
 }
 
diff --git a/mm/memory.c b/mm/memory.c
index 1311f26..d176154 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3521,12 +3521,12 @@ static int do_nonlinear_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 }
 
 int numa_migrate_prep(struct page *page, struct vm_area_struct *vma,
-				unsigned long addr, int current_nid)
+				unsigned long addr, int page_nid)
 {
 	get_page(page);
 
 	count_vm_numa_event(NUMA_HINT_FAULTS);
-	if (current_nid == numa_node_id())
+	if (page_nid == numa_node_id())
 		count_vm_numa_event(NUMA_HINT_FAULTS_LOCAL);
 
 	return mpol_misplaced(page, vma, addr);
@@ -3537,7 +3537,7 @@ int do_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 {
 	struct page *page = NULL;
 	spinlock_t *ptl;
-	int current_nid = -1;
+	int page_nid = -1;
 	int target_nid;
 	bool migrated = false;
 
@@ -3567,15 +3567,10 @@ int do_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		return 0;
 	}
 
-	current_nid = page_to_nid(page);
-	target_nid = numa_migrate_prep(page, vma, addr, current_nid);
+	page_nid = page_to_nid(page);
+	target_nid = numa_migrate_prep(page, vma, addr, page_nid);
 	pte_unmap_unlock(ptep, ptl);
 	if (target_nid == -1) {
-		/*
-		 * Account for the fault against the current node if it not
-		 * being replaced regardless of where the page is located.
-		 */
-		current_nid = numa_node_id();
 		put_page(page);
 		goto out;
 	}
@@ -3583,11 +3578,11 @@ int do_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	/* Migrate to the requested node */
 	migrated = migrate_misplaced_page(page, target_nid);
 	if (migrated)
-		current_nid = target_nid;
+		page_nid = target_nid;
 
 out:
-	if (current_nid != -1)
-		task_numa_fault(current_nid, 1, migrated);
+	if (page_nid != -1)
+		task_numa_fault(page_nid, 1, migrated);
 	return 0;
 }
 
@@ -3602,7 +3597,6 @@ static int do_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	unsigned long offset;
 	spinlock_t *ptl;
 	bool numa = false;
-	int local_nid = numa_node_id();
 
 	spin_lock(&mm->page_table_lock);
 	pmd = *pmdp;
@@ -3625,9 +3619,10 @@ static int do_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	for (addr = _addr + offset; addr < _addr + PMD_SIZE; pte++, addr += PAGE_SIZE) {
 		pte_t pteval = *pte;
 		struct page *page;
-		int curr_nid = local_nid;
+		int page_nid = -1;
 		int target_nid;
-		bool migrated;
+		bool migrated = false;
+
 		if (!pte_present(pteval))
 			continue;
 		if (!pte_numa(pteval))
@@ -3649,25 +3644,19 @@ static int do_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		if (unlikely(page_mapcount(page) != 1))
 			continue;
 
-		/*
-		 * Note that the NUMA fault is later accounted to either
-		 * the node that is currently running or where the page is
-		 * migrated to.
-		 */
-		curr_nid = local_nid;
-		target_nid = numa_migrate_prep(page, vma, addr,
-					       page_to_nid(page));
-		if (target_nid == -1) {
+		page_nid = page_to_nid(page);
+		target_nid = numa_migrate_prep(page, vma, addr, page_nid);
+		pte_unmap_unlock(pte, ptl);
+		if (target_nid != -1) {
+			migrated = migrate_misplaced_page(page, target_nid);
+			if (migrated)
+				page_nid = target_nid;
+		} else {
 			put_page(page);
-			continue;
 		}
 
-		/* Migrate to the requested node */
-		pte_unmap_unlock(pte, ptl);
-		migrated = migrate_misplaced_page(page, target_nid);
-		if (migrated)
-			curr_nid = target_nid;
-		task_numa_fault(curr_nid, 1, migrated);
+		if (page_nid != -1)
+			task_numa_fault(page_nid, 1, migrated);
 
 		pte = pte_offset_map_lock(mm, pmdp, addr, &ptl);
 	}
diff --git a/mm/migrate.c b/mm/migrate.c
index 7a7325e..c046927 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1715,12 +1715,12 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
 		unlock_page(new_page);
 		put_page(new_page);		/* Free it */
 
-		unlock_page(page);
+		/* Retake the callers reference and putback on LRU */
+		get_page(page);
 		putback_lru_page(page);
-
-		count_vm_events(PGMIGRATE_FAIL, HPAGE_PMD_NR);
-		isolated = 0;
-		goto out;
+		mod_zone_page_state(page_zone(page),
+			 NR_ISOLATED_ANON + page_lru, -HPAGE_PMD_NR);
+		goto out_fail;
 	}
 
 	/*
@@ -1737,9 +1737,9 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
 	entry = maybe_pmd_mkwrite(pmd_mkdirty(entry), vma);
 	entry = pmd_mkhuge(entry);
 
-	page_add_new_anon_rmap(new_page, vma, haddr);
-
+	pmdp_clear_flush(vma, haddr, pmd);
 	set_pmd_at(mm, haddr, pmd, entry);
+	page_add_new_anon_rmap(new_page, vma, haddr);
 	update_mmu_cache_pmd(vma, address, &entry);
 	page_remove_rmap(page);
 	/*
@@ -1758,7 +1758,6 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
 	count_vm_events(PGMIGRATE_SUCCESS, HPAGE_PMD_NR);
 	count_vm_numa_events(NUMA_PAGE_MIGRATE, HPAGE_PMD_NR);
 
-out:
 	mod_zone_page_state(page_zone(page),
 			NR_ISOLATED_ANON + page_lru,
 			-HPAGE_PMD_NR);
@@ -1767,6 +1766,10 @@ out:
 out_fail:
 	count_vm_events(PGMIGRATE_FAIL, HPAGE_PMD_NR);
 out_dropref:
+	entry = pmd_mknonnuma(entry);
+	set_pmd_at(mm, haddr, pmd, entry);
+	update_mmu_cache_pmd(vma, address, &entry);
+
 	unlock_page(page);
 	put_page(page);
 	return 0;
diff --git a/mm/mprotect.c b/mm/mprotect.c
index a3af058..412ba2b 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -148,7 +148,7 @@ static inline unsigned long change_pmd_range(struct vm_area_struct *vma,
 				split_huge_page_pmd(vma, addr, pmd);
 			else if (change_huge_pmd(vma, pmd, addr, newprot,
 						 prot_numa)) {
-				pages += HPAGE_PMD_NR;
+				pages++;
 				continue;
 			}
 			/* fall through */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
