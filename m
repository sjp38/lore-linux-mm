Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id 78AA76B003C
	for <linux-mm@kvack.org>; Thu, 12 Jun 2014 17:48:34 -0400 (EDT)
Received: by mail-wi0-f171.google.com with SMTP id n15so7744236wiw.16
        for <linux-mm@kvack.org>; Thu, 12 Jun 2014 14:48:34 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id by5si3694979wjc.114.2014.06.12.14.48.31
        for <linux-mm@kvack.org>;
        Thu, 12 Jun 2014 14:48:32 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH -mm v2 03/11] memcg: separate mem_cgroup_move_charge_pte_range()
Date: Thu, 12 Jun 2014 17:48:03 -0400
Message-Id: <1402609691-13950-4-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1402609691-13950-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1402609691-13950-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Dave Hansen <dave.hansen@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-kernel@vger.kernel.org

mem_cgroup_move_charge_pte_range() handles both pte and pmd, which is not
standardized, so let's cleanup it. One tricky part is the retry, which is
performed when we detect !mc.precharge. In such case we retry the same entry,
so we don't have to go outside the pte loop. With rewriting this retry in
the pte loop, we can separate pmd_entry() and pte_entry(), which is what
we need.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 mm/memcontrol.c | 127 +++++++++++++++++++++++++++++---------------------------
 1 file changed, 66 insertions(+), 61 deletions(-)

diff --git mmotm-2014-05-21-16-57.orig/mm/memcontrol.c mmotm-2014-05-21-16-57/mm/memcontrol.c
index 6970857ba0c8..01a66a208769 100644
--- mmotm-2014-05-21-16-57.orig/mm/memcontrol.c
+++ mmotm-2014-05-21-16-57/mm/memcontrol.c
@@ -6881,14 +6881,72 @@ static void mem_cgroup_cancel_attach(struct cgroup_subsys_state *css,
 	mem_cgroup_clear_mc();
 }
 
-static int mem_cgroup_move_charge_pte_range(pmd_t *pmd,
+static int mem_cgroup_move_charge_pte(pte_t *pte,
 				unsigned long addr, unsigned long end,
 				struct mm_walk *walk)
 {
 	int ret = 0;
 	struct vm_area_struct *vma = walk->vma;
-	pte_t *pte;
-	spinlock_t *ptl;
+	union mc_target target;
+	struct page *page;
+	struct page_cgroup *pc;
+	swp_entry_t ent;
+
+retry:
+	if (!mc.precharge) {
+		pte_t *orig_pte = pte - ((addr & (PMD_SIZE - 1)) >> PAGE_SHIFT);
+		pte_unmap_unlock(orig_pte, walk->ptl);
+		cond_resched();
+		/*
+		 * We have consumed all precharges we got in can_attach().
+		 * We try charge one by one, but don't do any additional
+		 * charges to mc.to if we have failed in charge once in attach()
+		 * phase.
+		 */
+		ret = mem_cgroup_do_precharge(1);
+		pte_offset_map(walk->pmd, addr & PMD_MASK);
+		spin_lock(walk->ptl);
+		if (!ret)
+			goto retry;
+		return ret;
+	}
+
+	switch (get_mctgt_type(vma, addr, *pte, &target)) {
+	case MC_TARGET_PAGE:
+		page = target.page;
+		if (isolate_lru_page(page))
+			goto put;
+		pc = lookup_page_cgroup(page);
+		if (!mem_cgroup_move_account(page, 1, pc,
+					     mc.from, mc.to)) {
+			mc.precharge--;
+			/* we uncharge from mc.from later. */
+			mc.moved_charge++;
+		}
+		putback_lru_page(page);
+put:		/* get_mctgt_type() gets the page */
+		put_page(page);
+		break;
+	case MC_TARGET_SWAP:
+		ent = target.ent;
+		if (!mem_cgroup_move_swap_account(ent, mc.from, mc.to)) {
+			mc.precharge--;
+			/* we fixup refcnts and charges later. */
+			mc.moved_swap++;
+		}
+		break;
+	default:
+		break;
+	}
+
+	return 0;
+}
+
+static int mem_cgroup_move_charge_pmd(pmd_t *pmd,
+				unsigned long addr, unsigned long end,
+				struct mm_walk *walk)
+{
+	struct vm_area_struct *vma = walk->vma;
 	enum mc_target_type target_type;
 	union mc_target target;
 	struct page *page;
@@ -6924,71 +6982,18 @@ static int mem_cgroup_move_charge_pte_range(pmd_t *pmd,
 			put_page(page);
 		}
 		spin_unlock(ptl);
-		return 0;
-	}
-
-	if (pmd_trans_unstable(pmd))
-		return 0;
-retry:
-	pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
-	for (; addr != end; addr += PAGE_SIZE) {
-		pte_t ptent = *(pte++);
-		swp_entry_t ent;
-
-		if (!mc.precharge)
-			break;
-
-		switch (get_mctgt_type(vma, addr, ptent, &target)) {
-		case MC_TARGET_PAGE:
-			page = target.page;
-			if (isolate_lru_page(page))
-				goto put;
-			pc = lookup_page_cgroup(page);
-			if (!mem_cgroup_move_account(page, 1, pc,
-						     mc.from, mc.to)) {
-				mc.precharge--;
-				/* we uncharge from mc.from later. */
-				mc.moved_charge++;
-			}
-			putback_lru_page(page);
-put:			/* get_mctgt_type() gets the page */
-			put_page(page);
-			break;
-		case MC_TARGET_SWAP:
-			ent = target.ent;
-			if (!mem_cgroup_move_swap_account(ent, mc.from, mc.to)) {
-				mc.precharge--;
-				/* we fixup refcnts and charges later. */
-				mc.moved_swap++;
-			}
-			break;
-		default:
-			break;
-		}
-	}
-	pte_unmap_unlock(pte - 1, ptl);
-	cond_resched();
-
-	if (addr != end) {
-		/*
-		 * We have consumed all precharges we got in can_attach().
-		 * We try charge one by one, but don't do any additional
-		 * charges to mc.to if we have failed in charge once in attach()
-		 * phase.
-		 */
-		ret = mem_cgroup_do_precharge(1);
-		if (!ret)
-			goto retry;
+		/* don't call mem_cgroup_move_charge_pte() */
+		walk->skip = 1;
 	}
-
-	return ret;
+	return 0;
 }
 
 static void mem_cgroup_move_charge(struct mm_struct *mm)
 {
 	struct vm_area_struct *vma;
 	struct mm_walk mem_cgroup_move_charge_walk = {
-		.pmd_entry = mem_cgroup_move_charge_pte_range,
+		.pmd_entry = mem_cgroup_move_charge_pmd,
+		.pte_entry = mem_cgroup_move_charge_pte,
 		.mm = mm,
 	};
 
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
