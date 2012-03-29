Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id 6583A6B0044
	for <linux-mm@kvack.org>; Thu, 29 Mar 2012 05:26:36 -0400 (EDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH] pagemap: fix order of pmd_trans_unstable() and pmd_trans_huge_lock()
Date: Thu, 29 Mar 2012 04:41:41 -0400
Message-Id: <1333010501-31218-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Sasha Levin <levinsasha928@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

pmd_trans_unstable() in pagemap_pte_range() comes before pmd_trans_huge_lock()
now, which means that pagewalk kicked by reading /proc/pid/pagemap does not
run over thp. This patch fixes it.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 fs/proc/task_mmu.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git linux-3.3.0-6658a6991ce.orig/fs/proc/task_mmu.c linux-3.3.0-6658a6991ce/fs/proc/task_mmu.c
index 06d2b70..0105ba1 100644
--- linux-3.3.0-6658a6991ce.orig/fs/proc/task_mmu.c
+++ linux-3.3.0-6658a6991ce/fs/proc/task_mmu.c
@@ -781,9 +781,6 @@ static int pagemap_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
 	int err = 0;
 	pagemap_entry_t pme = make_pme(PM_NOT_PRESENT);
 
-	if (pmd_trans_unstable(pmd))
-		return 0;
-
 	/* find the first VMA at or above 'addr' */
 	vma = find_vma(walk->mm, addr);
 	if (pmd_trans_huge_lock(pmd, vma) == 1) {
@@ -801,6 +798,9 @@ static int pagemap_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
 		return err;
 	}
 
+	if (pmd_trans_unstable(pmd))
+		return 0;
+
 	for (; addr != end; addr += PAGE_SIZE) {
 
 		/* check to see if we've left 'vma' behind
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
