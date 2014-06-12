Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f176.google.com (mail-we0-f176.google.com [74.125.82.176])
	by kanga.kvack.org (Postfix) with ESMTP id 23BEE6B006C
	for <linux-mm@kvack.org>; Thu, 12 Jun 2014 17:48:42 -0400 (EDT)
Received: by mail-we0-f176.google.com with SMTP id u56so1868912wes.7
        for <linux-mm@kvack.org>; Thu, 12 Jun 2014 14:48:41 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id gr5si3692194wjc.118.2014.06.12.14.48.39
        for <linux-mm@kvack.org>;
        Thu, 12 Jun 2014 14:48:40 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH -mm v2 09/11] fs/proc/task_mmu.c: refactor smaps
Date: Thu, 12 Jun 2014 17:48:09 -0400
Message-Id: <1402609691-13950-10-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1402609691-13950-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1402609691-13950-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Dave Hansen <dave.hansen@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-kernel@vger.kernel.org

smaps_(pte|pmd)() are almost the same, so let's clean them up to a single
function.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 fs/proc/task_mmu.c | 17 ++++++-----------
 1 file changed, 6 insertions(+), 11 deletions(-)

diff --git mmotm-2014-05-21-16-57.orig/fs/proc/task_mmu.c mmotm-2014-05-21-16-57/fs/proc/task_mmu.c
index a750d0842875..1f2eab58ae14 100644
--- mmotm-2014-05-21-16-57.orig/fs/proc/task_mmu.c
+++ mmotm-2014-05-21-16-57/fs/proc/task_mmu.c
@@ -437,7 +437,7 @@ struct mem_size_stats {
 	u64 pss;
 };
 
-static int smaps_pte(void *entry, unsigned long addr, unsigned long end,
+static int smaps_entry(void *entry, unsigned long addr, unsigned long end,
 			struct mm_walk *walk)
 {
 	pte_t *pte = entry;
@@ -490,15 +490,10 @@ static int smaps_pte(void *entry, unsigned long addr, unsigned long end,
 			mss->private_clean += ptent_size;
 		mss->pss += (ptent_size << PSS_SHIFT);
 	}
-	return 0;
-}
 
-static int smaps_pmd(void *entry, unsigned long addr, unsigned long end,
-			struct mm_walk *walk)
-{
-	struct mem_size_stats *mss = walk->private;
-	smaps_pte(entry, addr, end, walk);
-	mss->anonymous_thp += HPAGE_PMD_SIZE;
+	if (walk->size == PMD_SIZE)
+		mss->anonymous_thp += HPAGE_PMD_SIZE;
+
 	return 0;
 }
 
@@ -563,8 +558,8 @@ static int show_smap(struct seq_file *m, void *v, int is_pid)
 	struct vm_area_struct *vma = v;
 	struct mem_size_stats mss;
 	struct mm_walk smaps_walk = {
-		.pmd_entry = smaps_pmd,
-		.pte_entry = smaps_pte,
+		.pmd_entry = smaps_entry,
+		.pte_entry = smaps_entry,
 		.mm = vma->vm_mm,
 		.vma = vma,
 		.private = &mss,
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
