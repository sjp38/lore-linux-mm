Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 4B1906B00CB
	for <linux-mm@kvack.org>; Mon,  5 May 2014 18:13:40 -0400 (EDT)
Received: by mail-pd0-f172.google.com with SMTP id g10so8610566pdj.31
        for <linux-mm@kvack.org>; Mon, 05 May 2014 15:13:39 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id pq7si9888648pac.358.2014.05.05.15.13.38
        for <linux-mm@kvack.org>;
        Mon, 05 May 2014 15:13:39 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH] mm, thp: close race between mremap() and split_huge_page()
Date: Tue,  6 May 2014 01:13:31 +0300
Message-Id: <1399328011-15317-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, Dave Jones <davej@redhat.com>, stable@vger.kernel.org

It's critical for split_huge_page() (and migration) to catch and freeze
all PMDs on rmap walk. It gets tricky if there's concurrent fork() or
mremap() since usually we copy/move page table entries on dup_mm() or
move_page_tables() without rmap lock taken. To get it work we rely on
rmap walk order to not miss any entry. We expect to see destination VMA
after source one to work correctly.

But after switching rmap implementation to interval tree it's not always
possible to preserve expected walk order.

It works fine for dup_mm() since new VMA has the same vma_start_pgoff()
/ vma_last_pgoff() and explicitly insert dst VMA after src one with
vma_interval_tree_insert_after().

But on move_vma() destination VMA can be merged into adjacent one and as
result shifted left in interval tree. Fortunately, we can detect the
situation and prevent race with rmap walk by moving page table entries
under rmap lock. See commit 38a76013ad80.

Problem is that we miss the lock when we move transhuge PMD. Most likely
this bug caused the crash[1].

[1] http://thread.gmane.org/gmane.linux.kernel.mm/96473

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Michel Lespinasse <walken@google.com>
Cc: Dave Jones <davej@redhat.com>
Cc: <stable@vger.kernel.org>        [3.7+]
Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/mremap.c | 9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/mm/mremap.c b/mm/mremap.c
index 0843feb66f3d..05f1180e9f21 100644
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -194,10 +194,17 @@ unsigned long move_page_tables(struct vm_area_struct *vma,
 			break;
 		if (pmd_trans_huge(*old_pmd)) {
 			int err = 0;
-			if (extent == HPAGE_PMD_SIZE)
+			if (extent == HPAGE_PMD_SIZE) {
+				VM_BUG_ON(vma->vm_file || !vma->anon_vma);
+				/* See comment in move_ptes() */
+				if (need_rmap_locks)
+					anon_vma_lock_write(vma->anon_vma);
 				err = move_huge_pmd(vma, new_vma, old_addr,
 						    new_addr, old_end,
 						    old_pmd, new_pmd);
+				if (need_rmap_locks)
+					anon_vma_unlock_write(vma->anon_vma);
+			}
 			if (err > 0) {
 				need_flush = true;
 				continue;
-- 
2.0.0.rc0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
