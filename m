Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9E3DE6B0266
	for <linux-mm@kvack.org>; Wed, 21 Sep 2016 17:15:28 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id o68so151749116qkf.0
        for <linux-mm@kvack.org>; Wed, 21 Sep 2016 14:15:28 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o186si15108010ybb.295.2016.09.21.14.15.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Sep 2016 14:15:25 -0700 (PDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 3/4] mm: vma_merge: correct false positive from __vma_unlink->validate_mm_rb
Date: Wed, 21 Sep 2016 23:15:21 +0200
Message-Id: <1474492522-2261-4-git-send-email-aarcange@redhat.com>
In-Reply-To: <1474492522-2261-1-git-send-email-aarcange@redhat.com>
References: <1474492522-2261-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@techsingularity.net>

The old code was always doing:

   vma->vm_end = next->vm_end
   vma_rb_erase(next) // in __vma_unlink
   vma->vm_next = next->vm_next // in __vma_unlink
   next = vma->vm_next
   vma_gap_update(next)

The new code still does the above for remove_next == 1 and 2, but for
remove_next == 3 it has been changed and it does:

   next->vm_start = vma->vm_start
   vma_rb_erase(vma) // in __vma_unlink
   vma_gap_update(next)

In the latter case, while unlinking "vma", validate_mm_rb() is told to
ignore "vma" that is being removed, but next->vm_start was reduced
instead. So for the new case, to avoid the false positive from
validate_mm_rb, it should be "next" that is ignored when "vma" is
being unlinked.

"vma" and "next" in the above comment, considered pre-swap().

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 mm/mmap.c | 59 +++++++++++++++++++++++++++++++++++++++++------------------
 1 file changed, 41 insertions(+), 18 deletions(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index 1b88754..57b1eaf 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -398,15 +398,9 @@ static inline void vma_rb_insert(struct vm_area_struct *vma,
 	rb_insert_augmented(&vma->vm_rb, root, &vma_gap_callbacks);
 }
 
-static void vma_rb_erase(struct vm_area_struct *vma, struct rb_root *root)
+static void __vma_rb_erase(struct vm_area_struct *vma, struct rb_root *root)
 {
 	/*
-	 * All rb_subtree_gap values must be consistent prior to erase,
-	 * with the possible exception of the vma being erased.
-	 */
-	validate_mm_rb(root, vma);
-
-	/*
 	 * Note rb_erase_augmented is a fairly large inline function,
 	 * so make sure we instantiate it only once with our desired
 	 * augmented rbtree callbacks.
@@ -414,6 +408,32 @@ static void vma_rb_erase(struct vm_area_struct *vma, struct rb_root *root)
 	rb_erase_augmented(&vma->vm_rb, root, &vma_gap_callbacks);
 }
 
+static __always_inline void vma_rb_erase_ignore(struct vm_area_struct *vma,
+						struct rb_root *root,
+						struct vm_area_struct *ignore)
+{
+	/*
+	 * All rb_subtree_gap values must be consistent prior to erase,
+	 * with the possible exception of the "next" vma being erased if
+	 * next->vm_start was reduced.
+	 */
+	validate_mm_rb(root, ignore);
+
+	__vma_rb_erase(vma, root);
+}
+
+static __always_inline void vma_rb_erase(struct vm_area_struct *vma,
+					 struct rb_root *root)
+{
+	/*
+	 * All rb_subtree_gap values must be consistent prior to erase,
+	 * with the possible exception of the vma being erased.
+	 */
+	validate_mm_rb(root, vma);
+
+	__vma_rb_erase(vma, root);
+}
+
 /*
  * vma has some anon_vma assigned, and is already inserted on that
  * anon_vma's interval trees.
@@ -600,11 +620,12 @@ static void __insert_vm_struct(struct mm_struct *mm, struct vm_area_struct *vma)
 static __always_inline void __vma_unlink_common(struct mm_struct *mm,
 						struct vm_area_struct *vma,
 						struct vm_area_struct *prev,
-						bool has_prev)
+						bool has_prev,
+						struct vm_area_struct *ignore)
 {
 	struct vm_area_struct *next;
 
-	vma_rb_erase(vma, &mm->mm_rb);
+	vma_rb_erase_ignore(vma, &mm->mm_rb, ignore);
 	next = vma->vm_next;
 	if (has_prev)
 		prev->vm_next = next;
@@ -626,13 +647,7 @@ static inline void __vma_unlink_prev(struct mm_struct *mm,
 				     struct vm_area_struct *vma,
 				     struct vm_area_struct *prev)
 {
-	__vma_unlink_common(mm, vma, prev, true);
-}
-
-static inline void __vma_unlink(struct mm_struct *mm,
-				struct vm_area_struct *vma)
-{
-	__vma_unlink_common(mm, vma, NULL, false);
+	__vma_unlink_common(mm, vma, prev, true, vma);
 }
 
 /*
@@ -811,8 +826,16 @@ again:
 		if (remove_next != 3)
 			__vma_unlink_prev(mm, next, vma);
 		else
-			/* vma is not before next if they've been swapped */
-			__vma_unlink(mm, next);
+			/*
+			 * vma is not before next if they've been
+			 * swapped.
+			 *
+			 * pre-swap() next->vm_start was reduced so
+			 * tell validate_mm_rb to ignore pre-swap()
+			 * "next" (which is stored in post-swap()
+			 * "vma").
+			 */
+			__vma_unlink_common(mm, next, NULL, false, vma);
 		if (file)
 			__remove_shared_vm_struct(next, file, mapping);
 	} else if (insert) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
