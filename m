Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id 16C5F6B0044
	for <linux-mm@kvack.org>; Thu, 15 Mar 2012 18:45:07 -0400 (EDT)
Date: Thu, 15 Mar 2012 15:45:04 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: thp: fix pmd_bad() triggering in code paths holding
 mmap_sem read mode
Message-Id: <20120315154504.0fe15f95.akpm@linux-foundation.org>
In-Reply-To: <1331822671-21508-1-git-send-email-aarcange@redhat.com>
References: <1331822671-21508-1-git-send-email-aarcange@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Ulrich Obergfell <uobergfe@redhat.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

On Thu, 15 Mar 2012 15:44:31 +0100
Andrea Arcangeli <aarcange@redhat.com> wrote:

>  arch/x86/kernel/vm86_32.c     |    2 +
>  fs/proc/task_mmu.c            |    9 ++++++
>  include/asm-generic/pgtable.h |   57 +++++++++++++++++++++++++++++++++++++++++
>  mm/memcontrol.c               |    4 +++
>  mm/memory.c                   |   14 ++++++++--
>  mm/mempolicy.c                |    2 +-
>  mm/mincore.c                  |    2 +-
>  mm/pagewalk.c                 |    2 +-
>  mm/swapfile.c                 |    4 +--
>  9 files changed, 87 insertions(+), 9 deletions(-)

Picking my way through all the damage this caused...

I think memcg-avoid-thp-split-in-task-migration.patch remvoes some of
this code again, because the split is avoided.

Or do we still need pdm_trans_unstable() checking in
mem_cgroup_count_precharge_pte_range() and
mem_cgroup_move_charge_pte_range()?

Reworked patch:

From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: memcg: avoid THP split in task migration

Currently we can't do task migration among memory cgroups without THP
split, which means processes heavily using THP experience large overhead
in task migration.  This patch introduces the code for moving charge of
THP and makes THP more valuable.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Acked-by: Hillf Danton <dhillf@gmail.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: David Rientjes <rientjes@google.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 mm/memcontrol.c |   85 +++++++++++++++++++++++++++++++++++++++++-----
 1 file changed, 77 insertions(+), 8 deletions(-)

diff -puN mm/memcontrol.c~memcg-avoid-thp-split-in-task-migration mm/memcontrol.c
--- a/mm/memcontrol.c~memcg-avoid-thp-split-in-task-migration
+++ a/mm/memcontrol.c
@@ -5256,6 +5256,41 @@ static enum mc_target_type get_mctgt_typ
 	return ret;
 }
 
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+/*
+ * We don't consider swapping or file mapped pages because THP does not
+ * support them for now.
+ * Caller should make sure that pmd_trans_huge(pmd) is true.
+ */
+static enum mc_target_type get_mctgt_type_thp(struct vm_area_struct *vma,
+		unsigned long addr, pmd_t pmd, union mc_target *target)
+{
+	struct page *page = NULL;
+	struct page_cgroup *pc;
+	enum mc_target_type ret = MC_TARGET_NONE;
+
+	page = pmd_page(pmd);
+	VM_BUG_ON(!page || !PageHead(page));
+	if (!move_anon())
+		return ret;
+	pc = lookup_page_cgroup(page);
+	if (PageCgroupUsed(pc) && pc->mem_cgroup == mc.from) {
+		ret = MC_TARGET_PAGE;
+		if (target) {
+			get_page(page);
+			target->page = page;
+		}
+	}
+	return ret;
+}
+#else
+static inline enum mc_target_type get_mctgt_type_thp(struct vm_area_struct *vma,
+		unsigned long addr, pmd_t pmd, union mc_target *target)
+{
+	return MC_TARGET_NONE;
+}
+#endif
+
 static int mem_cgroup_count_precharge_pte_range(pmd_t *pmd,
 					unsigned long addr, unsigned long end,
 					struct mm_walk *walk)
@@ -5264,9 +5299,12 @@ static int mem_cgroup_count_precharge_pt
 	pte_t *pte;
 	spinlock_t *ptl;
 
-	split_huge_page_pmd(walk->mm, pmd);
-	if (pmd_trans_unstable(pmd))
+	if (pmd_trans_huge_lock(pmd, vma) == 1) {
+		if (get_mctgt_type_thp(vma, addr, *pmd, NULL) == MC_TARGET_PAGE)
+			mc.precharge += HPAGE_PMD_NR;
+		spin_unlock(&vma->vm_mm->page_table_lock);
 		return 0;
+	}
 
 	pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
 	for (; addr != end; pte++, addr += PAGE_SIZE)
@@ -5425,18 +5463,49 @@ static int mem_cgroup_move_charge_pte_ra
 	struct vm_area_struct *vma = walk->private;
 	pte_t *pte;
 	spinlock_t *ptl;
+	enum mc_target_type target_type;
+	union mc_target target;
+	struct page *page;
+	struct page_cgroup *pc;
 
-	split_huge_page_pmd(walk->mm, pmd);
-	if (pmd_trans_unstable(pmd))
+	/*
+	 * We don't take compound_lock() here but no race with splitting thp
+	 * happens because:
+	 *  - if pmd_trans_huge_lock() returns 1, the relevant thp is not
+	 *    under splitting, which means there's no concurrent thp split,
+	 *  - if another thread runs into split_huge_page() just after we
+	 *    entered this if-block, the thread must wait for page table lock
+	 *    to be unlocked in __split_huge_page_splitting(), where the main
+	 *    part of thp split is not executed yet.
+	 */
+	if (pmd_trans_huge_lock(pmd, vma) == 1) {
+		if (!mc.precharge) {
+			spin_unlock(&vma->vm_mm->page_table_lock);
+			return 0;
+		}
+		target_type = get_mctgt_type_thp(vma, addr, *pmd, &target);
+		if (target_type == MC_TARGET_PAGE) {
+			page = target.page;
+			if (!isolate_lru_page(page)) {
+				pc = lookup_page_cgroup(page);
+				if (!mem_cgroup_move_account(page, HPAGE_PMD_NR,
+							     pc, mc.from, mc.to,
+							     false)) {
+					mc.precharge -= HPAGE_PMD_NR;
+					mc.moved_charge += HPAGE_PMD_NR;
+				}
+				putback_lru_page(page);
+			}
+			put_page(page);
+		}
+		spin_unlock(&vma->vm_mm->page_table_lock);
 		return 0;
+	}
+
 retry:
 	pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
 	for (; addr != end; addr += PAGE_SIZE) {
 		pte_t ptent = *(pte++);
-		union mc_target target;
-		int type;
-		struct page *page;
-		struct page_cgroup *pc;
 		swp_entry_t ent;
 
 		if (!mc.precharge)
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
