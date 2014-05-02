Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id C5C4C6B0036
	for <linux-mm@kvack.org>; Fri,  2 May 2014 10:31:16 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id lf10so5441569pab.13
        for <linux-mm@kvack.org>; Fri, 02 May 2014 07:31:16 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id sr9si24350513pab.448.2014.05.02.07.31.15
        for <linux-mm@kvack.org>;
        Fri, 02 May 2014 07:31:15 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH] rmap: make page_referenced_one() and try_to_unmap_one() static
Date: Fri,  2 May 2014 17:31:05 +0300
Message-Id: <1399041065-13073-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

KSM was converted to use rmap_walk() and now nobody uses these functions
outside mm/rmap.c.

Let's covert them back to static.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/rmap.h | 4 ----
 mm/rmap.c            | 4 ++--
 2 files changed, 2 insertions(+), 6 deletions(-)

diff --git a/include/linux/rmap.h b/include/linux/rmap.h
index b66c2110cb1f..9be55c7617da 100644
--- a/include/linux/rmap.h
+++ b/include/linux/rmap.h
@@ -183,14 +183,10 @@ static inline void page_dup_rmap(struct page *page)
  */
 int page_referenced(struct page *, int is_locked,
 			struct mem_cgroup *memcg, unsigned long *vm_flags);
-int page_referenced_one(struct page *, struct vm_area_struct *,
-	unsigned long address, void *arg);
 
 #define TTU_ACTION(x) ((x) & TTU_ACTION_MASK)
 
 int try_to_unmap(struct page *, enum ttu_flags flags);
-int try_to_unmap_one(struct page *, struct vm_area_struct *,
-			unsigned long address, void *arg);
 
 /*
  * Called from mm/filemap_xip.c to unmap empty zero page
diff --git a/mm/rmap.c b/mm/rmap.c
index 9c3e77396d1a..d8e1a7e7fbe8 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -669,7 +669,7 @@ struct page_referenced_arg {
 /*
  * arg: page_referenced_arg will be passed
  */
-int page_referenced_one(struct page *page, struct vm_area_struct *vma,
+static int page_referenced_one(struct page *page, struct vm_area_struct *vma,
 			unsigned long address, void *arg)
 {
 	struct mm_struct *mm = vma->vm_mm;
@@ -1112,7 +1112,7 @@ out:
 /*
  * @arg: enum ttu_flags will be passed to this argument
  */
-int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
+static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 		     unsigned long address, void *arg)
 {
 	struct mm_struct *mm = vma->vm_mm;
-- 
2.0.0.rc0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
