Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id E85746B0257
	for <linux-mm@kvack.org>; Mon, 13 Jul 2015 06:54:23 -0400 (EDT)
Received: by pactm7 with SMTP id tm7so205676697pac.2
        for <linux-mm@kvack.org>; Mon, 13 Jul 2015 03:54:23 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id h14si27815232pdl.168.2015.07.13.03.54.17
        for <linux-mm@kvack.org>;
        Mon, 13 Jul 2015 03:54:17 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 3/5] mm: make sure all file VMAs have ->vm_ops set
Date: Mon, 13 Jul 2015 13:54:10 +0300
Message-Id: <1436784852-144369-4-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1436784852-144369-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1436784852-144369-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

We rely on vma->vm_ops == NULL to detect anonymous VMA: see
vma_is_anonymous(), but some drivers doesn't set ->vm_ops.

As result we can end up with anonymous page in private file mapping.
That's should not lead to serious misbehaviour, but nevertheless is
wrong.

Let's fix by setting up dummy ->vm_ops for file mmapping if f_op->mmap()
didn't set its own.

The patch also adds sanity check into __vma_link_rb(). It will help
catch broken VMAs which inserted directly into mm_struct via
insert_vm_struct().

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/mmap.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/mm/mmap.c b/mm/mmap.c
index 30904c16b7d3..4ce7a6f33db0 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -612,6 +612,8 @@ static unsigned long count_vma_pages_range(struct mm_struct *mm,
 void __vma_link_rb(struct mm_struct *mm, struct vm_area_struct *vma,
 		struct rb_node **rb_link, struct rb_node *rb_parent)
 {
+	WARN_ONCE(vma->vm_file && !vma->vm_ops, "missing vma->vm_ops");
+
 	/* Update tracking information for the gap following the new vma. */
 	if (vma->vm_next)
 		vma_gap_update(vma->vm_next);
@@ -1638,6 +1640,12 @@ unsigned long mmap_region(struct file *file, unsigned long addr,
 		 */
 		WARN_ON_ONCE(addr != vma->vm_start);
 
+		/* All file mapping must have ->vm_ops set */
+		if (!vma->vm_ops) {
+			static const struct vm_operations_struct dummy_ops = {};
+			vma->vm_ops = &dummy_ops;
+		}
+
 		addr = vma->vm_start;
 		vm_flags = vma->vm_flags;
 	} else if (vm_flags & VM_SHARED) {
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
