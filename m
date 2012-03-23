Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id 777CB6B004D
	for <linux-mm@kvack.org>; Fri, 23 Mar 2012 12:42:50 -0400 (EDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH] mm: thp: fixup pmd_trans_unstable() locations
Date: Fri, 23 Mar 2012 17:42:44 +0100
Message-Id: <1332520964-30491-2-git-send-email-aarcange@redhat.com>
In-Reply-To: <1332520964-30491-1-git-send-email-aarcange@redhat.com>
References: <1332520964-30491-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Larry Woodman <lwoodman@redhat.com>, Ulrich Obergfell <uobergfe@redhat.com>, Rik van Riel <riel@redhat.com>, Mark Salter <msalter@redhat.com>

pmd_trans_unstable shall be called before pmd_offset_map in the
locations where the mmap_sem is hold for reading.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 fs/proc/task_mmu.c |    5 ++---
 mm/memcontrol.c    |    4 ++++
 2 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 9694cc2..c283832 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -781,9 +781,6 @@ static int pagemap_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
 	int err = 0;
 	pagemap_entry_t pme = make_pme(PM_NOT_PRESENT);
 
-	if (pmd_trans_unstable(pmd))
-		return 0;
-
 	/* find the first VMA at or above 'addr' */
 	vma = find_vma(walk->mm, addr);
 	spin_lock(&walk->mm->page_table_lock);
@@ -802,6 +799,8 @@ static int pagemap_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
 		return err;
 	}
 
+	if (pmd_trans_unstable(pmd))
+		return 0;
 	for (; addr != end; addr += PAGE_SIZE) {
 
 		/* check to see if we've left 'vma' behind
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index b2ee6df..7d698df 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -5306,6 +5306,8 @@ static int mem_cgroup_count_precharge_pte_range(pmd_t *pmd,
 		return 0;
 	}
 
+	if (pmd_trans_unstable(pmd))
+		return 0;
 	pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
 	for (; addr != end; pte++, addr += PAGE_SIZE)
 		if (get_mctgt_type(vma, addr, *pte, NULL))
@@ -5502,6 +5504,8 @@ static int mem_cgroup_move_charge_pte_range(pmd_t *pmd,
 		return 0;
 	}
 
+	if (pmd_trans_unstable(pmd))
+		return 0;
 retry:
 	pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
 	for (; addr != end; addr += PAGE_SIZE) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
