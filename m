Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 73CE86B0069
	for <linux-mm@kvack.org>; Sat, 10 Sep 2016 12:39:36 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id 128so28186733pfb.2
        for <linux-mm@kvack.org>; Sat, 10 Sep 2016 09:39:36 -0700 (PDT)
Received: from mail-pf0-x241.google.com (mail-pf0-x241.google.com. [2607:f8b0:400e:c00::241])
        by mx.google.com with ESMTPS id g84si10558617pfb.36.2016.09.10.09.39.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 10 Sep 2016 09:39:35 -0700 (PDT)
Received: by mail-pf0-x241.google.com with SMTP id x24so5610148pfa.3
        for <linux-mm@kvack.org>; Sat, 10 Sep 2016 09:39:34 -0700 (PDT)
From: cee1 <fykcee1@gmail.com>
Subject: [PATCH] mm: unmapped_area: visit left subtree more precisely
Date: Sun, 11 Sep 2016 00:39:23 +0800
Message-Id: <1473525563-20703-1-git-send-email-fykcee1@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, cee1 <fykcee1@gmail.com>

unmapped_area() tries to find an unmapped area between info.low_limit and
info.high_limit:

  info.low_limit                                 info.high_limit
       ^                                              ^
       |                                              |
  _____|______________________________________________|_______
 |_____|__1__|__________________________________|__2__|_______|
             |                                  |
             V                                  |
     low_limit = info.low_limit + length        V
                                   high_limit = info.high_limit - length

 The lowest possible unmapped_area is at 1)
 The highest possible unmapped_area us at 2)

unmapped_are() will first try to find any gap which is:
- gap_start <= high_limit
- gap_end >= low_limit
- big enough, i.e. gap_end - gap_start >= length

The search starts from the lowest gap, up to the highest gap, that means
a rbtree In-order traversal.

In the old logic, it visits left subtree if:
- it has gaps big enough
- "the highest gap_end" of the node >= low_limit

It will be more precise, if it uses "the highest gap_end" of
the left subtree, which is vma->vm_prev->vm_start.
---
 mm/mmap.c | 16 ++++++++++------
 1 file changed, 10 insertions(+), 6 deletions(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index ca9d91b..e65c04d 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1630,19 +1630,25 @@ unsigned long unmapped_area(struct vm_unmapped_area_info *info)
 
 	while (true) {
 		/* Visit left subtree if it looks promising */
-		gap_end = vma->vm_start;
-		if (gap_end >= low_limit && vma->vm_rb.rb_left) {
+		if (vma->vm_rb.rb_left) {
 			struct vm_area_struct *left =
 				rb_entry(vma->vm_rb.rb_left,
 					 struct vm_area_struct, vm_rb);
-			if (left->rb_subtree_gap >= length) {
+
+			VM_BUG_ON(!vma->vm_prev);
+			gap_end = vma->vm_prev->vm_start;
+
+			if (gap_end >= low_limit &&
+			    left->rb_subtree_gap >= length) {
 				vma = left;
 				continue;
 			}
 		}
 
-		gap_start = vma->vm_prev ? vma->vm_prev->vm_end : 0;
 check_current:
+		gap_start = vma->vm_prev ? vma->vm_prev->vm_end : 0;
+		gap_end = vma->vm_start;
+
 		/* Check if current node has a suitable gap */
 		if (gap_start > high_limit)
 			return -ENOMEM;
@@ -1668,8 +1674,6 @@ check_current:
 			vma = rb_entry(rb_parent(prev),
 				       struct vm_area_struct, vm_rb);
 			if (prev == vma->vm_rb.rb_left) {
-				gap_start = vma->vm_prev->vm_end;
-				gap_end = vma->vm_start;
 				goto check_current;
 			}
 		}
-- 
2.3.2 (Apple Git-55)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
