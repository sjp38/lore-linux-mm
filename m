Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f48.google.com (mail-wg0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id AF4306B0062
	for <linux-mm@kvack.org>; Fri, 20 Jun 2014 16:12:12 -0400 (EDT)
Received: by mail-wg0-f48.google.com with SMTP id n12so4207287wgh.7
        for <linux-mm@kvack.org>; Fri, 20 Jun 2014 13:12:12 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m19si3922823wij.84.2014.06.20.13.12.08
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Jun 2014 13:12:09 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH v3 09/13] memcg: apply walk_page_vma()
Date: Fri, 20 Jun 2014 16:11:35 -0400
Message-Id: <1403295099-6407-10-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1403295099-6407-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1403295099-6407-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Hugh Dickins <hughd@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

pagewalk.c can handle vma in itself, so we don't have to pass vma via
walk->private. And both of mem_cgroup_count_precharge() and
mem_cgroup_move_charge() walk over all vmas (not interested in outside vma,)
so using walk_page_vma() is preferable.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 mm/memcontrol.c | 36 ++++++++++++++----------------------
 1 file changed, 14 insertions(+), 22 deletions(-)

diff --git v3.16-rc1.orig/mm/memcontrol.c v3.16-rc1/mm/memcontrol.c
index a2c7bcb0e6eb..24c2cc8ff451 100644
--- v3.16-rc1.orig/mm/memcontrol.c
+++ v3.16-rc1/mm/memcontrol.c
@@ -6654,7 +6654,7 @@ static int mem_cgroup_count_precharge_pte_range(pmd_t *pmd,
 					unsigned long addr, unsigned long end,
 					struct mm_walk *walk)
 {
-	struct vm_area_struct *vma = walk->private;
+	struct vm_area_struct *vma = walk->vma;
 	pte_t *pte;
 	spinlock_t *ptl;
 
@@ -6682,18 +6682,13 @@ static unsigned long mem_cgroup_count_precharge(struct mm_struct *mm)
 	unsigned long precharge;
 	struct vm_area_struct *vma;
 
+	struct mm_walk mem_cgroup_count_precharge_walk = {
+		.pmd_entry = mem_cgroup_count_precharge_pte_range,
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
@@ -6832,7 +6827,7 @@ static int mem_cgroup_move_charge_pte_range(pmd_t *pmd,
 				struct mm_walk *walk)
 {
 	int ret = 0;
-	struct vm_area_struct *vma = walk->private;
+	struct vm_area_struct *vma = walk->vma;
 	pte_t *pte;
 	spinlock_t *ptl;
 	enum mc_target_type target_type;
@@ -6933,6 +6928,10 @@ put:			/* get_mctgt_type() gets the page */
 static void mem_cgroup_move_charge(struct mm_struct *mm)
 {
 	struct vm_area_struct *vma;
+	struct mm_walk mem_cgroup_move_charge_walk = {
+		.pmd_entry = mem_cgroup_move_charge_pte_range,
+		.mm = mm,
+	};
 
 	lru_add_drain_all();
 retry:
@@ -6950,15 +6949,8 @@ static void mem_cgroup_move_charge(struct mm_struct *mm)
 	}
 	for (vma = mm->mmap; vma; vma = vma->vm_next) {
 		int ret;
-		struct mm_walk mem_cgroup_move_charge_walk = {
-			.pmd_entry = mem_cgroup_move_charge_pte_range,
-			.mm = mm,
-			.private = vma,
-		};
-		if (is_vm_hugetlb_page(vma))
-			continue;
-		ret = walk_page_range(vma->vm_start, vma->vm_end,
-						&mem_cgroup_move_charge_walk);
+
+		ret = walk_page_vma(vma, &mem_cgroup_move_charge_walk);
 		if (ret)
 			/*
 			 * means we have consumed all precharges and failed in
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
