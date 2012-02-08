Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id 9D2386B13F3
	for <linux-mm@kvack.org>; Wed,  8 Feb 2012 10:52:48 -0500 (EST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH 5/6] introduce pmd_to_pte_t()
Date: Wed,  8 Feb 2012 10:51:41 -0500
Message-Id: <1328716302-16871-6-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1328716302-16871-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1328716302-16871-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Andi Kleen <andi@firstfloor.org>, Wu Fengguang <fengguang.wu@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

Casting pmd into pte_t to handle thp is strongly architecture dependent.
This patch introduces a new function to separate this dependency from
independent part.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

Changes since v4:
  - Rename thp_ptep_get() to pmd_to_pte_t()
---
 arch/x86/include/asm/pgtable.h |    5 +++++
 fs/proc/task_mmu.c             |    4 ++--
 include/asm-generic/pgtable.h  |    4 ++++
 3 files changed, 11 insertions(+), 2 deletions(-)

diff --git 3.3-rc2.orig/arch/x86/include/asm/pgtable.h 3.3-rc2/arch/x86/include/asm/pgtable.h
index 49afb3f..0058358 100644
--- 3.3-rc2.orig/arch/x86/include/asm/pgtable.h
+++ 3.3-rc2/arch/x86/include/asm/pgtable.h
@@ -165,6 +165,11 @@ static inline int has_transparent_hugepage(void)
 {
 	return cpu_has_pse;
 }
+/* Caller must confirm that a given pmd points to a hugepage. */
+static inline pte_t pmd_to_pte_t(pmd_t *pmd)
+{
+	return *(pte_t *)pmd;
+}
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
 
 static inline pte_t pte_set_flags(pte_t pte, pteval_t set)
diff --git 3.3-rc2.orig/fs/proc/task_mmu.c 3.3-rc2/fs/proc/task_mmu.c
index 9ff102a..de94384 100644
--- 3.3-rc2.orig/fs/proc/task_mmu.c
+++ 3.3-rc2/fs/proc/task_mmu.c
@@ -395,7 +395,7 @@ static int smaps_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
 	spinlock_t *ptl;
 
 	if (pmd_trans_huge_lock(pmd, vma)) {
-		smaps_pte_entry(*(pte_t *)pmd, addr, HPAGE_PMD_SIZE, walk);
+		smaps_pte_entry(pmd_to_pte_t(pmd), addr, HPAGE_PMD_SIZE, walk);
 		spin_unlock(&walk->mm->page_table_lock);
 		mss->anonymous_thp += HPAGE_PMD_SIZE;
 		return 0;
@@ -967,7 +967,7 @@ static int gather_pte_stats(pmd_t *pmd, unsigned long addr,
 	md = walk->private;
 
 	if (pmd_trans_huge_lock(pmd, md->vma)) {
-		pte_t huge_pte = *(pte_t *)pmd;
+		pte_t huge_pte = pmd_to_pte_t(pmd);
 		struct page *page;
 
 		page = can_gather_numa_stats(huge_pte, md->vma, addr);
diff --git 3.3-rc2.orig/include/asm-generic/pgtable.h 3.3-rc2/include/asm-generic/pgtable.h
index 76bff2b..45160c7 100644
--- 3.3-rc2.orig/include/asm-generic/pgtable.h
+++ 3.3-rc2/include/asm-generic/pgtable.h
@@ -434,6 +434,10 @@ static inline int pmd_trans_splitting(pmd_t pmd)
 {
 	return 0;
 }
+static inline pte_t pmd_to_pte_t(pmd_t *pmd)
+{
+	return 0;
+}
 #ifndef __HAVE_ARCH_PMD_WRITE
 static inline int pmd_write(pmd_t pmd)
 {
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
