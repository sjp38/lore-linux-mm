Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id A2D946B00A3
	for <linux-mm@kvack.org>; Fri,  6 Jun 2014 18:59:05 -0400 (EDT)
Received: by mail-wi0-f173.google.com with SMTP id bs8so1755042wib.6
        for <linux-mm@kvack.org>; Fri, 06 Jun 2014 15:59:04 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id yx7si19776907wjc.120.2014.06.06.15.59.03
        for <linux-mm@kvack.org>;
        Fri, 06 Jun 2014 15:59:04 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH 4/7] memcg: separate mem_cgroup_move_charge_pte_range()
Date: Fri,  6 Jun 2014 18:58:37 -0400
Message-Id: <1402095520-10109-5-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1402095520-10109-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1402095520-10109-1-git-send-email-n-horiguchi@ah.jp.nec.com>
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
 mm/memcontrol.c | 128 +++++++++++++++++++++++++++++---------------------------
 1 file changed, 66 insertions(+), 62 deletions(-)

diff --git v3.15-rc8-mmots-2014-06-03-16-28.orig/mm/memcontrol.c v3.15-rc8-mmots-2014-06-03-16-28/mm/memcontrol.c
index aeab82bce739..3b1692d2bca3 100644
--- v3.15-rc8-mmots-2014-06-03-16-28.orig/mm/memcontrol.c
+++ v3.15-rc8-mmots-2014-06-03-16-28/mm/memcontrol.c
@@ -6880,14 +6880,72 @@ static void mem_cgroup_cancel_attach(struct cgroup_subsys_state *css,
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
@@ -6923,71 +6981,17 @@ static int mem_cgroup_move_charge_pte_range(pmd_t *pmd,
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
-	}
-
-	return ret;
+	} else
+		walk->control = PTWALK_DOWN;
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
