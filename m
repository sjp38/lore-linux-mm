Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 30651280324
	for <linux-mm@kvack.org>; Fri, 17 Jul 2015 07:53:29 -0400 (EDT)
Received: by pdbqm3 with SMTP id qm3so60933410pdb.0
        for <linux-mm@kvack.org>; Fri, 17 Jul 2015 04:53:28 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id dv2si18245302pbc.200.2015.07.17.04.53.23
        for <linux-mm@kvack.org>;
        Fri, 17 Jul 2015 04:53:24 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2 4/6] mm: make sure all file VMAs have ->vm_ops set
Date: Fri, 17 Jul 2015 14:53:11 +0300
Message-Id: <1437133993-91885-5-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1437133993-91885-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1437133993-91885-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Oleg Nesterov <oleg@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

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
index 2e98784d5b7c..a82a02853cbc 100644
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
@@ -1636,6 +1638,12 @@ unsigned long mmap_region(struct file *file, unsigned long addr,
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
