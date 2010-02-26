Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id E50A96B009F
	for <linux-mm@kvack.org>; Fri, 26 Feb 2010 15:09:25 -0500 (EST)
Message-Id: <20100226200900.403307636@redhat.com>
Date: Fri, 26 Feb 2010 21:04:43 +0100
From: aarcange@redhat.com
Subject: [patch 10/35] export maybe_mkwrite
References: <20100226200433.516502198@redhat.com>
Content-Disposition: inline; filename=export_maybe_mkwrite
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

From: Andrea Arcangeli <aarcange@redhat.com>

huge_memory.c needs it too when it fallbacks in copying hugepages into regular
fragmented pages if hugepage allocation fails during COW.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
Acked-by: Rik van Riel <riel@redhat.com>
Acked-by: Mel Gorman <mel@csn.ul.ie>
---
 include/linux/mm.h |   13 +++++++++++++
 mm/memory.c        |   13 -------------
 2 files changed, 13 insertions(+), 13 deletions(-)

--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -389,6 +389,19 @@ static inline void set_compound_order(st
 }
 
 /*
+ * Do pte_mkwrite, but only if the vma says VM_WRITE.  We do this when
+ * servicing faults for write access.  In the normal case, do always want
+ * pte_mkwrite.  But get_user_pages can cause write faults for mappings
+ * that do not have writing enabled, when used by access_process_vm.
+ */
+static inline pte_t maybe_mkwrite(pte_t pte, struct vm_area_struct *vma)
+{
+	if (likely(vma->vm_flags & VM_WRITE))
+		pte = pte_mkwrite(pte);
+	return pte;
+}
+
+/*
  * Multiple processes may "see" the same page. E.g. for untouched
  * mappings of /dev/null, all processes see the same page full of
  * zeroes, and text pages of executables and shared libraries have
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2033,19 +2033,6 @@ static inline int pte_unmap_same(struct 
 	return same;
 }
 
-/*
- * Do pte_mkwrite, but only if the vma says VM_WRITE.  We do this when
- * servicing faults for write access.  In the normal case, do always want
- * pte_mkwrite.  But get_user_pages can cause write faults for mappings
- * that do not have writing enabled, when used by access_process_vm.
- */
-static inline pte_t maybe_mkwrite(pte_t pte, struct vm_area_struct *vma)
-{
-	if (likely(vma->vm_flags & VM_WRITE))
-		pte = pte_mkwrite(pte);
-	return pte;
-}
-
 static inline void cow_user_page(struct page *dst, struct page *src, unsigned long va, struct vm_area_struct *vma)
 {
 	/*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
