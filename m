Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 5C15A6B006C
	for <linux-mm@kvack.org>; Fri, 30 Jan 2015 19:36:49 -0500 (EST)
Received: by mail-pa0-f51.google.com with SMTP id fb1so58558079pad.10
        for <linux-mm@kvack.org>; Fri, 30 Jan 2015 16:36:49 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id d8si15601061pas.50.2015.01.30.16.36.48
        for <linux-mm@kvack.org>;
        Fri, 30 Jan 2015 16:36:48 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH] mm: do not use mm->nr_pmds on !MMU configurations
Date: Sat, 31 Jan 2015 02:36:16 +0200
Message-Id: <1422664576-220960-1-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1422629008-13689-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1422629008-13689-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Guenter Roeck <linux@roeck-us.net>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

mm->nr_pmds doesn't make sense on !MMU configurations

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 This patch should probably go before the series.
---
 include/linux/mm.h | 9 ++++++++-
 kernel/fork.c      | 4 +---
 2 files changed, 9 insertions(+), 4 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index d782617c11de..a09837f3f4b7 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1454,13 +1454,15 @@ static inline int __pud_alloc(struct mm_struct *mm, pgd_t *pgd,
 int __pud_alloc(struct mm_struct *mm, pgd_t *pgd, unsigned long address);
 #endif
 
-#ifdef __PAGETABLE_PMD_FOLDED
+#if defined(__PAGETABLE_PMD_FOLDED) || !defined(CONFIG_MMU)
 static inline int __pmd_alloc(struct mm_struct *mm, pud_t *pud,
 						unsigned long address)
 {
 	return 0;
 }
 
+static inline void mm_nr_pmds_init(struct mm_struct *mm) {}
+
 static inline unsigned long mm_nr_pmds(struct mm_struct *mm)
 {
 	return 0;
@@ -1472,6 +1474,11 @@ static inline void mm_dec_nr_pmds(struct mm_struct *mm) {}
 #else
 int __pmd_alloc(struct mm_struct *mm, pud_t *pud, unsigned long address);
 
+static inline void mm_nr_pmds_init(struct mm_struct *mm)
+{
+	atomic_long_set(&mm->nr_pmds, 0);
+}
+
 static inline unsigned long mm_nr_pmds(struct mm_struct *mm)
 {
 	return atomic_long_read(&mm->nr_pmds);
diff --git a/kernel/fork.c b/kernel/fork.c
index 76d6f292274c..56b82deb6457 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -555,9 +555,7 @@ static struct mm_struct *mm_init(struct mm_struct *mm, struct task_struct *p)
 	INIT_LIST_HEAD(&mm->mmlist);
 	mm->core_state = NULL;
 	atomic_long_set(&mm->nr_ptes, 0);
-#ifndef __PAGETABLE_PMD_FOLDED
-	atomic_long_set(&mm->nr_pmds, 0);
-#endif
+	mm_nr_pmds_init(mm);
 	mm->map_count = 0;
 	mm->locked_vm = 0;
 	mm->pinned_vm = 0;
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
