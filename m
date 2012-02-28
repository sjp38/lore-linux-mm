Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id 2194D6B004A
	for <linux-mm@kvack.org>; Tue, 28 Feb 2012 16:14:01 -0500 (EST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [RFC][PATCH] memcg: avoid THP split in task migration
Date: Tue, 28 Feb 2012 16:12:32 -0500
Message-Id: <1330463552-18473-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Hillf Danton <dhillf@gmail.com>, linux-kernel@vger.kernel.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

Currently we can't do task migration among memory cgroups without THP split,
which means processes heavily using THP experience large overhead in task
migration. This patch introduce the code for moving charge of THP and makes
THP more valuable.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Hillf Danton <dhillf@gmail.com>
---
 mm/memcontrol.c |   76 ++++++++++++++++++++++++++++++++++++++++++++++++++----
 1 files changed, 70 insertions(+), 6 deletions(-)

diff --git linux-next-20120228.orig/mm/memcontrol.c linux-next-20120228/mm/memcontrol.c
index c83aeb5..e97c041 100644
--- linux-next-20120228.orig/mm/memcontrol.c
+++ linux-next-20120228/mm/memcontrol.c
@@ -5211,6 +5211,42 @@ static int is_target_pte_for_mc(struct vm_area_struct *vma,
 	return ret;
 }
 
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+/*
+ * We don't consider swapping or file mapped pages because THP does not
+ * support them for now.
+ */
+static int is_target_huge_pmd_for_mc(struct vm_area_struct *vma,
+		unsigned long addr, pmd_t pmd, union mc_target *target)
+{
+	struct page *page = NULL;
+	struct page_cgroup *pc;
+	int ret = 0;
+
+	if (pmd_present(pmd))
+		page = pmd_page(pmd);
+	if (!page)
+		return 0;
+	VM_BUG_ON(!PageHead(page));
+	get_page(page);
+	pc = lookup_page_cgroup(page);
+	if (PageCgroupUsed(pc) && pc->mem_cgroup == mc.from) {
+		ret = MC_TARGET_PAGE;
+		if (target)
+			target->page = page;
+	}
+	if (!ret || !target)
+		put_page(page);
+	return ret;
+}
+#else
+static inline int is_target_huge_pmd_for_mc(struct vm_area_struct *vma,
+		unsigned long addr, pmd_t pmd, union mc_target *target)
+{
+	return 0;
+}
+#endif
+
 static int mem_cgroup_count_precharge_pte_range(pmd_t *pmd,
 					unsigned long addr, unsigned long end,
 					struct mm_walk *walk)
@@ -5219,7 +5255,13 @@ static int mem_cgroup_count_precharge_pte_range(pmd_t *pmd,
 	pte_t *pte;
 	spinlock_t *ptl;
 
-	split_huge_page_pmd(walk->mm, pmd);
+	if (pmd_trans_huge_lock(pmd, vma) == 1) {
+		if (is_target_huge_pmd_for_mc(vma, addr, *pmd, NULL))
+			mc.precharge += HPAGE_PMD_NR;
+		spin_unlock(&walk->mm->page_table_lock);
+		cond_resched();
+		return 0;
+	}
 
 	pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
 	for (; addr != end; pte++, addr += PAGE_SIZE)
@@ -5378,16 +5420,38 @@ static int mem_cgroup_move_charge_pte_range(pmd_t *pmd,
 	struct vm_area_struct *vma = walk->private;
 	pte_t *pte;
 	spinlock_t *ptl;
+	int type;
+	union mc_target target;
+	struct page *page;
+	struct page_cgroup *pc;
+
+	if (pmd_trans_huge_lock(pmd, vma) == 1) {
+		if (!mc.precharge)
+			return 0;
+		type = is_target_huge_pmd_for_mc(vma, addr, *pmd, &target);
+		if (type == MC_TARGET_PAGE) {
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
+		spin_unlock(&walk->mm->page_table_lock);
+		cond_resched();
+		return 0;
+	}
 
-	split_huge_page_pmd(walk->mm, pmd);
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
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
