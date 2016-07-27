Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5D5C86B025F
	for <linux-mm@kvack.org>; Wed, 27 Jul 2016 09:14:32 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id pp5so36846369pac.3
        for <linux-mm@kvack.org>; Wed, 27 Jul 2016 06:14:32 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id x6si6469858pac.8.2016.07.27.06.14.31
        for <linux-mm@kvack.org>;
        Wed, 27 Jul 2016 06:14:31 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH] mm: fix use-after-free if memory allocation failed in vma_adjust()
Date: Wed, 27 Jul 2016 16:14:15 +0300
Message-Id: <1469625255-126641-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, Vegard Nossum <vegard.nossum@oracle.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

There's one case when vma_adjust() expands the vma, overlapping with
*two* next vma. See case 6 of mprotect, described in the comment to
vma_merge().

To handle this (and only this) situation we iterate twice over main part
of the function. See "goto again".

Vegard reported[1] that he sees out-of-bounds access complain from
KASAN, if anon_vma_clone() on the *second* iteration fails.

This happens because we free 'next' vma by the end of first iteration
and don't have a way to undo this if anon_vma_clone() fails on the
second iteration.

The solution is to do all required allocations upfront, before we touch
vmas.

The allocation on the second iteration is only required if first two
vmas don't have anon_vma, but third does. So we need, in total, one
anon_vma_clone() call.

It's easy to adjust 'exporter' to the third vma for such case.

[1] http://lkml.kernel.org/r/1469514843-23778-1-git-send-email-vegard.nossum@oracle.com

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Reported-by: Vegard Nossum <vegard.nossum@oracle.com>
---
 mm/mmap.c | 20 +++++++++++++++-----
 1 file changed, 15 insertions(+), 5 deletions(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index a384c10c7657..ca9d91bca0d6 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -621,7 +621,6 @@ int vma_adjust(struct vm_area_struct *vma, unsigned long start,
 {
 	struct mm_struct *mm = vma->vm_mm;
 	struct vm_area_struct *next = vma->vm_next;
-	struct vm_area_struct *importer = NULL;
 	struct address_space *mapping = NULL;
 	struct rb_root *root = NULL;
 	struct anon_vma *anon_vma = NULL;
@@ -631,17 +630,25 @@ int vma_adjust(struct vm_area_struct *vma, unsigned long start,
 	int remove_next = 0;
 
 	if (next && !insert) {
-		struct vm_area_struct *exporter = NULL;
+		struct vm_area_struct *exporter = NULL, *importer = NULL;
 
 		if (end >= next->vm_end) {
 			/*
 			 * vma expands, overlapping all the next, and
 			 * perhaps the one after too (mprotect case 6).
 			 */
-again:			remove_next = 1 + (end > next->vm_end);
+			remove_next = 1 + (end > next->vm_end);
 			end = next->vm_end;
 			exporter = next;
 			importer = vma;
+
+			/*
+			 * If next doesn't have anon_vma, import from vma after
+			 * next, if the vma overlaps with it.
+			 */
+			if (remove_next == 2 && next && !next->anon_vma)
+				exporter = next->vm_next;
+
 		} else if (end > next->vm_start) {
 			/*
 			 * vma expands, overlapping part of the next:
@@ -675,7 +682,7 @@ again:			remove_next = 1 + (end > next->vm_end);
 				return error;
 		}
 	}
-
+again:
 	vma_adjust_trans_huge(vma, start, end, adjust_next);
 
 	if (file) {
@@ -796,8 +803,11 @@ again:			remove_next = 1 + (end > next->vm_end);
 		 * up the code too much to do both in one go.
 		 */
 		next = vma->vm_next;
-		if (remove_next == 2)
+		if (remove_next == 2) {
+			remove_next = 1;
+			end = next->vm_end;
 			goto again;
+		}
 		else if (next)
 			vma_gap_update(next);
 		else
-- 
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
