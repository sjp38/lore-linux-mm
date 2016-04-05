Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f177.google.com (mail-pf0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 89A9B828DF
	for <linux-mm@kvack.org>; Tue,  5 Apr 2016 17:44:11 -0400 (EDT)
Received: by mail-pf0-f177.google.com with SMTP id e128so18749583pfe.3
        for <linux-mm@kvack.org>; Tue, 05 Apr 2016 14:44:11 -0700 (PDT)
Received: from mail-pf0-x22f.google.com (mail-pf0-x22f.google.com. [2607:f8b0:400e:c00::22f])
        by mx.google.com with ESMTPS id h17si9614626pfj.143.2016.04.05.14.44.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Apr 2016 14:44:10 -0700 (PDT)
Received: by mail-pf0-x22f.google.com with SMTP id e128so18749385pfe.3
        for <linux-mm@kvack.org>; Tue, 05 Apr 2016 14:44:10 -0700 (PDT)
Date: Tue, 5 Apr 2016 14:44:07 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 18/31] huge tmpfs: mem_cgroup move charge on shmem huge
 pages
In-Reply-To: <alpine.LSU.2.11.1604051403210.5965@eggly.anvils>
Message-ID: <alpine.LSU.2.11.1604051441190.5965@eggly.anvils>
References: <alpine.LSU.2.11.1604051403210.5965@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andres Lagar-Cavilla <andreslc@google.com>, Yang Shi <yang.shi@linaro.org>, Ning Qu <quning@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Early on, for simplicity, we disabled moving huge tmpfs pages from
one memcg to another (nowadays only required when moving a task into a
memcg having move_charge_at_immigrate exceptionally set).  We're about
to add a couple of memcg stats for huge tmpfs, and will need to confront
how to handle moving those stats, so better enable moving the pages now.

Although they're discovered by the pmd's get_mctgt_type_thp(), they
have to be considered page by page, in what's usually the pte scan:
because although the common case is for each member of the team to be
owned by the same memcg, nowhere is that enforced - perhaps one day
we shall need to enforce such a limitation, but not so far.

Signed-off-by: Hugh Dickins <hughd@google.com>
---
 mm/memcontrol.c |  103 +++++++++++++++++++++++++---------------------
 1 file changed, 58 insertions(+), 45 deletions(-)

--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -4332,6 +4332,7 @@ static int mem_cgroup_do_precharge(unsig
  *   2(MC_TARGET_SWAP): if the swap entry corresponding to this pte is a
  *     target for charge migration. if @target is not NULL, the entry is stored
  *     in target->ent.
+ *   3(MC_TARGET_TEAM): if pmd entry is not an anon THP: check it page by page
  *
  * Called with pte lock held.
  */
@@ -4344,6 +4345,7 @@ enum mc_target_type {
 	MC_TARGET_NONE = 0,
 	MC_TARGET_PAGE,
 	MC_TARGET_SWAP,
+	MC_TARGET_TEAM,
 };
 
 static struct page *mc_handle_present_pte(struct vm_area_struct *vma,
@@ -4565,19 +4567,22 @@ static enum mc_target_type get_mctgt_typ
 
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 /*
- * We don't consider swapping or file mapped pages because THP does not
- * support them for now.
  * Caller should make sure that pmd_trans_huge(pmd) is true.
  */
-static enum mc_target_type get_mctgt_type_thp(struct vm_area_struct *vma,
-		unsigned long addr, pmd_t pmd, union mc_target *target)
+static enum mc_target_type get_mctgt_type_thp(pmd_t pmd,
+		union mc_target *target, unsigned long *pfn)
 {
-	struct page *page = NULL;
+	struct page *page;
 	enum mc_target_type ret = MC_TARGET_NONE;
 
 	page = pmd_page(pmd);
-	/* Don't attempt to move huge tmpfs pages yet: can be enabled later */
-	if (!(mc.flags & MOVE_ANON) || !PageAnon(page))
+	if (!PageAnon(page)) {
+		if (!(mc.flags & MOVE_FILE))
+			return ret;
+		*pfn = page_to_pfn(page);
+		return MC_TARGET_TEAM;
+	}
+	if (!(mc.flags & MOVE_ANON))
 		return ret;
 	if (page->mem_cgroup == mc.from) {
 		ret = MC_TARGET_PAGE;
@@ -4589,8 +4594,8 @@ static enum mc_target_type get_mctgt_typ
 	return ret;
 }
 #else
-static inline enum mc_target_type get_mctgt_type_thp(struct vm_area_struct *vma,
-		unsigned long addr, pmd_t pmd, union mc_target *target)
+static inline enum mc_target_type get_mctgt_type_thp(pmd_t pmd,
+		union mc_target *target, unsigned long *pfn)
 {
 	return MC_TARGET_NONE;
 }
@@ -4601,24 +4606,33 @@ static int mem_cgroup_count_precharge_pt
 					struct mm_walk *walk)
 {
 	struct vm_area_struct *vma = walk->vma;
-	pte_t *pte;
+	enum mc_target_type target_type;
+	unsigned long uninitialized_var(pfn);
+	pte_t ptent;
+	pte_t *pte = NULL;
 	spinlock_t *ptl;
 
 	ptl = pmd_trans_huge_lock(pmd, vma);
 	if (ptl) {
-		if (get_mctgt_type_thp(vma, addr, *pmd, NULL) == MC_TARGET_PAGE)
+		target_type = get_mctgt_type_thp(*pmd, NULL, &pfn);
+		if (target_type == MC_TARGET_PAGE)
 			mc.precharge += HPAGE_PMD_NR;
-		spin_unlock(ptl);
-		return 0;
+		if (target_type != MC_TARGET_TEAM)
+			goto unlock;
+	} else {
+		if (pmd_trans_unstable(pmd))
+			return 0;
+		pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
 	}
-
-	if (pmd_trans_unstable(pmd))
-		return 0;
-	pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
-	for (; addr != end; pte++, addr += PAGE_SIZE)
-		if (get_mctgt_type(vma, addr, *pte, NULL))
+	for (; addr != end; addr += PAGE_SIZE) {
+		ptent = pte ? *(pte++) : pfn_pte(pfn++, vma->vm_page_prot);
+		if (get_mctgt_type(vma, addr, ptent, NULL))
 			mc.precharge++;	/* increment precharge temporarily */
-	pte_unmap_unlock(pte - 1, ptl);
+	}
+	if (pte)
+		pte_unmap(pte - 1);
+unlock:
+	spin_unlock(ptl);
 	cond_resched();
 
 	return 0;
@@ -4787,22 +4801,21 @@ static int mem_cgroup_move_charge_pte_ra
 {
 	int ret = 0;
 	struct vm_area_struct *vma = walk->vma;
-	pte_t *pte;
+	unsigned long uninitialized_var(pfn);
+	pte_t ptent;
+	pte_t *pte = NULL;
 	spinlock_t *ptl;
 	enum mc_target_type target_type;
 	union mc_target target;
 	struct page *page;
-
+retry:
 	ptl = pmd_trans_huge_lock(pmd, vma);
 	if (ptl) {
-		if (mc.precharge < HPAGE_PMD_NR) {
-			spin_unlock(ptl);
-			return 0;
-		}
-		target_type = get_mctgt_type_thp(vma, addr, *pmd, &target);
+		target_type = get_mctgt_type_thp(*pmd, &target, &pfn);
 		if (target_type == MC_TARGET_PAGE) {
 			page = target.page;
-			if (!isolate_lru_page(page)) {
+			if (mc.precharge >= HPAGE_PMD_NR &&
+			    !isolate_lru_page(page)) {
 				if (!mem_cgroup_move_account(page, true,
 							     mc.from, mc.to)) {
 					mc.precharge -= HPAGE_PMD_NR;
@@ -4811,22 +4824,19 @@ static int mem_cgroup_move_charge_pte_ra
 				putback_lru_page(page);
 			}
 			put_page(page);
+			addr = end;
 		}
-		spin_unlock(ptl);
-		return 0;
+		if (target_type != MC_TARGET_TEAM)
+			goto unlock;
+		/* addr is not aligned when retrying after precharge ran out */
+		pfn += (addr & (HPAGE_PMD_SIZE-1)) >> PAGE_SHIFT;
+	} else {
+		if (pmd_trans_unstable(pmd))
+			return 0;
+		pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
 	}
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
+	for (; addr != end && mc.precharge; addr += PAGE_SIZE) {
+		ptent = pte ? *(pte++) : pfn_pte(pfn++, vma->vm_page_prot);
 		switch (get_mctgt_type(vma, addr, ptent, &target)) {
 		case MC_TARGET_PAGE:
 			page = target.page;
@@ -4851,8 +4861,8 @@ put:			/* get_mctgt_type() gets the page
 			put_page(page);
 			break;
 		case MC_TARGET_SWAP:
-			ent = target.ent;
-			if (!mem_cgroup_move_swap_account(ent, mc.from, mc.to)) {
+			if (!mem_cgroup_move_swap_account(target.ent,
+							  mc.from, mc.to)) {
 				mc.precharge--;
 				/* we fixup refcnts and charges later. */
 				mc.moved_swap++;
@@ -4862,7 +4872,10 @@ put:			/* get_mctgt_type() gets the page
 			break;
 		}
 	}
-	pte_unmap_unlock(pte - 1, ptl);
+	if (pte)
+		pte_unmap(pte - 1);
+unlock:
+	spin_unlock(ptl);
 	cond_resched();
 
 	if (addr != end) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
