Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id ABF996B0098
	for <linux-mm@kvack.org>; Mon, 28 Sep 2009 12:08:51 -0400 (EDT)
Received: by ywh39 with SMTP id 39so4905147ywh.12
        for <linux-mm@kvack.org>; Mon, 28 Sep 2009 02:03:16 -0700 (PDT)
From: Huang Shijie <shijie8@gmail.com>
Subject: [PATCH] rmap : tidy the code
Date: Mon, 28 Sep 2009 17:03:10 +0800
Message-Id: <1254128590-27826-1-git-send-email-shijie8@gmail.com>
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: hugh.dickins@tiscali.co.uk, linux-mm@kvack.org, Huang Shijie <shijie8@gmail.com>
List-ID: <linux-mm.kvack.org>

Introduce is_page_mapped_in_vma() to merge the vma_address() and
page_check_address().

Make the rmap codes more simple.

Signed-off-by: Huang Shijie <shijie8@gmail.com>
---
 mm/rmap.c |   59 ++++++++++++++++++++++++++++-------------------------------
 1 files changed, 28 insertions(+), 31 deletions(-)

diff --git a/mm/rmap.c b/mm/rmap.c
index 28aafe2..69e7314 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -307,6 +307,27 @@ pte_t *page_check_address(struct page *page, struct mm_struct *mm,
 	return NULL;
 }
 
+/*
+ * This helper function checks whether a page is mapped in a VMA.
+ * On success returns 1 with pte mapped and locked.
+ */
+static inline bool
+is_page_mapped_in_vma(struct page *page, struct vm_area_struct *vma,
+		unsigned long *addr, pte_t **ptep, spinlock_t **ptlp, int sync)
+{
+	unsigned long address;
+
+	address = vma_address(page, vma);
+	if (address == -EFAULT)
+		return 0;
+	*ptep = page_check_address(page, vma->vm_mm, address, ptlp, sync);
+	if (!(*ptep))
+		return 0;
+
+	*addr = address;
+	return 1;
+}
+
 /**
  * page_mapped_in_vma - check whether a page is really mapped in a VMA
  * @page: the page to test
@@ -322,14 +343,9 @@ int page_mapped_in_vma(struct page *page, struct vm_area_struct *vma)
 	pte_t *pte;
 	spinlock_t *ptl;
 
-	address = vma_address(page, vma);
-	if (address == -EFAULT)		/* out of vma range */
-		return 0;
-	pte = page_check_address(page, vma->vm_mm, address, &ptl, 1);
-	if (!pte)			/* the page is not in this mm */
+	if (!is_page_mapped_in_vma(page, vma, &address, &pte, &ptl, 1))
 		return 0;
 	pte_unmap_unlock(pte, ptl);
-
 	return 1;
 }
 
@@ -348,14 +364,8 @@ static int page_referenced_one(struct page *page,
 	spinlock_t *ptl;
 	int referenced = 0;
 
-	address = vma_address(page, vma);
-	if (address == -EFAULT)
-		goto out;
-
-	pte = page_check_address(page, mm, address, &ptl, 0);
-	if (!pte)
-		goto out;
-
+	if (!is_page_mapped_in_vma(page, vma, &address, &pte, &ptl, 0))
+		return 0;
 	/*
 	 * Don't want to elevate referenced for mlocked page that gets this far,
 	 * in order that it progresses to try_to_unmap and is moved to the
@@ -388,7 +398,6 @@ static int page_referenced_one(struct page *page,
 out_unmap:
 	(*mapcount)--;
 	pte_unmap_unlock(pte, ptl);
-out:
 	if (referenced)
 		*vm_flags |= vma->vm_flags;
 	return referenced;
@@ -543,13 +552,8 @@ static int page_mkclean_one(struct page *page, struct vm_area_struct *vma)
 	spinlock_t *ptl;
 	int ret = 0;
 
-	address = vma_address(page, vma);
-	if (address == -EFAULT)
-		goto out;
-
-	pte = page_check_address(page, mm, address, &ptl, 1);
-	if (!pte)
-		goto out;
+	if (!is_page_mapped_in_vma(page, vma, &address, &pte, &ptl, 1))
+		return 0;
 
 	if (pte_dirty(*pte) || pte_write(*pte)) {
 		pte_t entry;
@@ -563,7 +567,6 @@ static int page_mkclean_one(struct page *page, struct vm_area_struct *vma)
 	}
 
 	pte_unmap_unlock(pte, ptl);
-out:
 	return ret;
 }
 
@@ -770,13 +773,8 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 	spinlock_t *ptl;
 	int ret = SWAP_AGAIN;
 
-	address = vma_address(page, vma);
-	if (address == -EFAULT)
-		goto out;
-
-	pte = page_check_address(page, mm, address, &ptl, 0);
-	if (!pte)
-		goto out;
+	if (!is_page_mapped_in_vma(page, vma, &address, &pte, &ptl, 0))
+		return 0;
 
 	/*
 	 * If the page is mlock()d, we cannot swap it out.
@@ -855,7 +853,6 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 
 out_unmap:
 	pte_unmap_unlock(pte, ptl);
-out:
 	return ret;
 }
 
-- 
1.6.0.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
