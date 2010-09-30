Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 1354C6B007D
	for <linux-mm@kvack.org>; Wed, 29 Sep 2010 23:50:49 -0400 (EDT)
Received: by mail-iw0-f169.google.com with SMTP id 33so2614800iwn.14
        for <linux-mm@kvack.org>; Wed, 29 Sep 2010 20:50:48 -0700 (PDT)
From: Namhyung Kim <namhyung@gmail.com>
Subject: [PATCH 07/12] rmap: wrap page_check_address() using __cond_lock()
Date: Thu, 30 Sep 2010 12:50:16 +0900
Message-Id: <1285818621-29890-8-git-send-email-namhyung@gmail.com>
In-Reply-To: <1285818621-29890-1-git-send-email-namhyung@gmail.com>
References: <1285818621-29890-1-git-send-email-namhyung@gmail.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

The page_check_address() conditionally grabs *@ptlp in case of returning
non-NULL. Rename and wrap it using __cond_lock() removes following
warnings from sparse:

 mm/rmap.c:472:9: warning: context imbalance in 'page_mapped_in_vma' - unexpected unlock
 mm/rmap.c:524:9: warning: context imbalance in 'page_referenced_one' - unexpected unlock
 mm/rmap.c:706:9: warning: context imbalance in 'page_mkclean_one' - unexpected unlock
 mm/rmap.c:1066:9: warning: context imbalance in 'try_to_unmap_one' - unexpected unlock

Signed-off-by: Namhyung Kim <namhyung@gmail.com>
---
 include/linux/rmap.h |   13 ++++++++++++-
 mm/rmap.c            |    2 +-
 2 files changed, 13 insertions(+), 2 deletions(-)

diff --git a/include/linux/rmap.h b/include/linux/rmap.h
index 0fa7769..490206c 100644
--- a/include/linux/rmap.h
+++ b/include/linux/rmap.h
@@ -205,9 +205,20 @@ int try_to_unmap_one(struct page *, struct vm_area_struct *,
 /*
  * Called from mm/filemap_xip.c to unmap empty zero page
  */
-pte_t *page_check_address(struct page *, struct mm_struct *,
+pte_t *__page_check_address(struct page *, struct mm_struct *,
 				unsigned long, spinlock_t **, int);
 
+static inline pte_t *page_check_address(struct page *page, struct mm_struct *mm,
+					unsigned long address,
+					spinlock_t **ptlp, int sync)
+{
+	pte_t *ptep;
+
+	__cond_lock(*ptlp, ptep = __page_check_address(page, mm, address,
+						       ptlp, sync));
+	return ptep;
+}
+
 /*
  * Used by swapoff to help locate where page is expected in vma.
  */
diff --git a/mm/rmap.c b/mm/rmap.c
index 244ff06..9c900dd 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -403,7 +403,7 @@ unsigned long page_address_in_vma(struct page *page, struct vm_area_struct *vma)
  *
  * On success returns with pte mapped and locked.
  */
-pte_t *page_check_address(struct page *page, struct mm_struct *mm,
+pte_t *__page_check_address(struct page *page, struct mm_struct *mm,
 			  unsigned long address, spinlock_t **ptlp, int sync)
 {
 	pgd_t *pgd;
-- 
1.7.2.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
