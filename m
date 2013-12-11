Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f49.google.com (mail-ee0-f49.google.com [74.125.83.49])
	by kanga.kvack.org (Postfix) with ESMTP id 320D36B003A
	for <linux-mm@kvack.org>; Wed, 11 Dec 2013 17:09:59 -0500 (EST)
Received: by mail-ee0-f49.google.com with SMTP id c41so3176420eek.8
        for <linux-mm@kvack.org>; Wed, 11 Dec 2013 14:09:58 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id 5si21020197eei.249.2013.12.11.14.09.57
        for <linux-mm@kvack.org>;
        Wed, 11 Dec 2013 14:09:58 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH 07/11] memcg: redefine callback functions for page table walker
Date: Wed, 11 Dec 2013 17:09:03 -0500
Message-Id: <1386799747-31069-8-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1386799747-31069-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1386799747-31069-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Matt Mackall <mpm@selenic.com>, Cliff Wickman <cpw@sgi.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Pavel Emelyanov <xemul@parallels.com>, Rik van Riel <riel@redhat.com>, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org

Move code around pte loop in mem_cgroup_count_precharge_pte_range() into
mem_cgroup_count_precharge_pte() connected to pte_entry().

We don't change the callback mem_cgroup_move_charge_pte_range() for now,
because we can't do the same replacement easily due to 'goto retry'.

ChangeLog v2:
- rebase onto mmots

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 mm/memcontrol.c | 71 ++++++++++++++++++++++-----------------------------------
 1 file changed, 27 insertions(+), 44 deletions(-)

diff --git v3.13-rc3-mmots-2013-12-10-16-38.orig/mm/memcontrol.c v3.13-rc3-mmots-2013-12-10-16-38/mm/memcontrol.c
index cbac7219fa69..3ffc36c8db9e 100644
--- v3.13-rc3-mmots-2013-12-10-16-38.orig/mm/memcontrol.c
+++ v3.13-rc3-mmots-2013-12-10-16-38/mm/memcontrol.c
@@ -6915,30 +6915,29 @@ static inline enum mc_target_type get_mctgt_type_thp(struct vm_area_struct *vma,
 }
 #endif
 
-static int mem_cgroup_count_precharge_pte_range(pmd_t *pmd,
+static int mem_cgroup_count_precharge_pte(pte_t *pte,
 					unsigned long addr, unsigned long end,
 					struct mm_walk *walk)
 {
-	struct vm_area_struct *vma = walk->private;
-	pte_t *pte;
+	if (get_mctgt_type(walk->vma, addr, *pte, NULL))
+		mc.precharge++;	/* increment precharge temporarily */
+	return 0;
+}
+
+static int mem_cgroup_count_precharge_pmd(pmd_t *pmd,
+					unsigned long addr, unsigned long end,
+					struct mm_walk *walk)
+{
+	struct vm_area_struct *vma = walk->vma;
 	spinlock_t *ptl;
 
 	if (pmd_trans_huge_lock(pmd, vma, &ptl) == 1) {
 		if (get_mctgt_type_thp(vma, addr, *pmd, NULL) == MC_TARGET_PAGE)
 			mc.precharge += HPAGE_PMD_NR;
 		spin_unlock(ptl);
-		return 0;
+		/* don't call mem_cgroup_count_precharge_pte() */
+		walk->skip = 1;
 	}
-
-	if (pmd_trans_unstable(pmd))
-		return 0;
-	pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
-	for (; addr != end; pte++, addr += PAGE_SIZE)
-		if (get_mctgt_type(vma, addr, *pte, NULL))
-			mc.precharge++;	/* increment precharge temporarily */
-	pte_unmap_unlock(pte - 1, ptl);
-	cond_resched();
-
 	return 0;
 }
 
@@ -6947,18 +6946,14 @@ static unsigned long mem_cgroup_count_precharge(struct mm_struct *mm)
 	unsigned long precharge;
 	struct vm_area_struct *vma;
 
+	struct mm_walk mem_cgroup_count_precharge_walk = {
+		.pmd_entry = mem_cgroup_count_precharge_pmd,
+		.pte_entry = mem_cgroup_count_precharge_pte,
+		.mm = mm,
+	};
 	down_read(&mm->mmap_sem);
-	for (vma = mm->mmap; vma; vma = vma->vm_next) {
-		struct mm_walk mem_cgroup_count_precharge_walk = {
-			.pmd_entry = mem_cgroup_count_precharge_pte_range,
-			.mm = mm,
-			.private = vma,
-		};
-		if (is_vm_hugetlb_page(vma))
-			continue;
-		walk_page_range(vma->vm_start, vma->vm_end,
-					&mem_cgroup_count_precharge_walk);
-	}
+	for (vma = mm->mmap; vma; vma = vma->vm_next)
+		walk_page_vma(vma, &mem_cgroup_count_precharge_walk);
 	up_read(&mm->mmap_sem);
 
 	precharge = mc.precharge;
@@ -7097,7 +7092,7 @@ static int mem_cgroup_move_charge_pte_range(pmd_t *pmd,
 				struct mm_walk *walk)
 {
 	int ret = 0;
-	struct vm_area_struct *vma = walk->private;
+	struct vm_area_struct *vma = walk->vma;
 	pte_t *pte;
 	spinlock_t *ptl;
 	enum mc_target_type target_type;
@@ -7198,6 +7193,10 @@ put:			/* get_mctgt_type() gets the page */
 static void mem_cgroup_move_charge(struct mm_struct *mm)
 {
 	struct vm_area_struct *vma;
+	struct mm_walk mem_cgroup_move_charge_walk = {
+		.pmd_entry = mem_cgroup_move_charge_pte_range,
+		.mm = mm,
+	};
 
 	lru_add_drain_all();
 retry:
@@ -7213,24 +7212,8 @@ static void mem_cgroup_move_charge(struct mm_struct *mm)
 		cond_resched();
 		goto retry;
 	}
-	for (vma = mm->mmap; vma; vma = vma->vm_next) {
-		int ret;
-		struct mm_walk mem_cgroup_move_charge_walk = {
-			.pmd_entry = mem_cgroup_move_charge_pte_range,
-			.mm = mm,
-			.private = vma,
-		};
-		if (is_vm_hugetlb_page(vma))
-			continue;
-		ret = walk_page_range(vma->vm_start, vma->vm_end,
-						&mem_cgroup_move_charge_walk);
-		if (ret)
-			/*
-			 * means we have consumed all precharges and failed in
-			 * doing additional charge. Just abandon here.
-			 */
-			break;
-	}
+	for (vma = mm->mmap; vma; vma = vma->vm_next)
+		walk_page_vma(vma, &mem_cgroup_move_charge_walk);
 	up_read(&mm->mmap_sem);
 }
 
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
