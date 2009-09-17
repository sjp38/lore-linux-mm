Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 0F9696B004F
	for <linux-mm@kvack.org>; Wed, 16 Sep 2009 23:11:56 -0400 (EDT)
Date: Thu, 17 Sep 2009 11:27:37 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: [PATCH 6/8] memcg: migrate charge of shmem
Message-Id: <20090917112737.57fc2fba.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20090917112304.6cd4e6f6.nishimura@mxp.nes.nec.co.jp>
References: <20090917112304.6cd4e6f6.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm <linux-mm@kvack.org>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

This patch adds some checks to enable migration charge of shmem(and mmapd tmpfs file).

Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
---
 mm/memcontrol.c |   10 ++++++++--
 1 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 830fa71..f46fd19 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2844,6 +2844,7 @@ static int mem_cgroup_swappiness_write(struct cgroup *cgrp, struct cftype *cft,
 
 enum migrate_charge_type {
 	MIGRATE_CHARGE_ANON,
+	MIGRATE_CHARGE_SHMEM,
 	NR_MIGRATE_CHARGE_TYPE,
 };
 
@@ -3210,6 +3211,8 @@ static int migrate_charge_prepare_pte_range(pmd_t *pmd,
 	pte_t *pte, ptent;
 	spinlock_t *ptl;
 	bool move_anon = (mc->to->migrate_charge & (1 << MIGRATE_CHARGE_ANON));
+	bool move_shmem = (mc->to->migrate_charge &
+					(1 << MIGRATE_CHARGE_SHMEM));
 
 	lru_add_drain_all();
 	pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
@@ -3226,6 +3229,8 @@ static int migrate_charge_prepare_pte_range(pmd_t *pmd,
 
 		if (PageAnon(page) && move_anon)
 			;
+		else if (!PageAnon(page) && PageSwapBacked(page) && move_shmem)
+			;
 		else
 			continue;
 
@@ -3281,6 +3286,8 @@ static int migrate_charge_prepare(void)
 	int ret = 0;
 	struct mm_struct *mm;
 	struct vm_area_struct *vma;
+	bool move_shmem = (mc->to->migrate_charge &
+					(1 << MIGRATE_CHARGE_SHMEM));
 
 	mm = get_task_mm(mc->tsk);
 	if (!mm)
@@ -3299,8 +3306,7 @@ static int migrate_charge_prepare(void)
 		}
 		if (is_vm_hugetlb_page(vma))
 			continue;
-		/* We migrate charge of private pages for now */
-		if (vma->vm_flags & (VM_SHARED | VM_MAYSHARE))
+		if (vma->vm_flags & (VM_SHARED | VM_MAYSHARE) && !move_shmem)
 			continue;
 		if (mc->to->migrate_charge) {
 			ret = walk_page_range(vma->vm_start, vma->vm_end,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
