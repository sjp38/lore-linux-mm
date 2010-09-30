Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 890E46B007D
	for <linux-mm@kvack.org>; Wed, 29 Sep 2010 23:50:38 -0400 (EDT)
Received: by mail-iw0-f169.google.com with SMTP id 33so2614800iwn.14
        for <linux-mm@kvack.org>; Wed, 29 Sep 2010 20:50:37 -0700 (PDT)
From: Namhyung Kim <namhyung@gmail.com>
Subject: [PATCH 03/12] mm: wrap get_locked_pte() using __cond_lock()
Date: Thu, 30 Sep 2010 12:50:12 +0900
Message-Id: <1285818621-29890-4-git-send-email-namhyung@gmail.com>
In-Reply-To: <1285818621-29890-1-git-send-email-namhyung@gmail.com>
References: <1285818621-29890-1-git-send-email-namhyung@gmail.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

The get_locked_pte() conditionally grabs 'ptl' in case of returning
non-NULL. This leads sparse to complain about context imbalance.
Rename and wrap it using __cond_lock() to make sparse happy.

Signed-off-by: Namhyung Kim <namhyung@gmail.com>
---
 include/linux/mm.h |   10 +++++++++-
 mm/memory.c        |    2 +-
 2 files changed, 10 insertions(+), 2 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 74949fb..e48616d 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1023,7 +1023,15 @@ extern void unregister_shrinker(struct shrinker *);
 
 int vma_wants_writenotify(struct vm_area_struct *vma);
 
-extern pte_t *get_locked_pte(struct mm_struct *mm, unsigned long addr, spinlock_t **ptl);
+extern pte_t *__get_locked_pte(struct mm_struct *mm, unsigned long addr,
+			       spinlock_t **ptl);
+static inline pte_t *get_locked_pte(struct mm_struct *mm, unsigned long addr,
+				    spinlock_t **ptl)
+{
+	pte_t *ptep;
+	__cond_lock(*ptl, ptep = __get_locked_pte(mm, addr, ptl));
+	return ptep;
+}
 
 #ifdef __PAGETABLE_PUD_FOLDED
 static inline int __pud_alloc(struct mm_struct *mm, pgd_t *pgd,
diff --git a/mm/memory.c b/mm/memory.c
index 0e18b4d..219b50a 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1590,7 +1590,7 @@ struct page *get_dump_page(unsigned long addr)
 }
 #endif /* CONFIG_ELF_CORE */
 
-pte_t *get_locked_pte(struct mm_struct *mm, unsigned long addr,
+pte_t *__get_locked_pte(struct mm_struct *mm, unsigned long addr,
 			spinlock_t **ptl)
 {
 	pgd_t * pgd = pgd_offset(mm, addr);
-- 
1.7.2.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
