Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 29BCB280260
	for <linux-mm@kvack.org>; Fri,  3 Jul 2015 10:08:19 -0400 (EDT)
Received: by pdjd13 with SMTP id d13so64555646pdj.0
        for <linux-mm@kvack.org>; Fri, 03 Jul 2015 07:08:18 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id pw17si14514646pab.125.2015.07.03.07.08.17
        for <linux-mm@kvack.org>;
        Fri, 03 Jul 2015 07:08:18 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH] mm: avoid setting up anonymous pages into file mapping
Date: Fri,  3 Jul 2015 17:07:27 +0300
Message-Id: <1435932447-84377-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>
Cc: Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Reading page fault handler code I've noticed that under right
circumstances kernel would map anonymous pages into file mappings:
if the VMA doesn't have vm_ops->fault() and the VMA wasn't fully
populated on ->mmap(), kernel would handle page fault to not populated
pte with do_anonymous_page().

There's chance that it was done intentionally, but I don't see good
justification for this. We just hide bugs in broken drivers.

Let's change page fault handler to use do_anonymous_page() only on
anonymous VMA (->vm_ops == NULL).

For file mappings without vm_ops->fault() page fault on pte_none() entry
would lead to SIGBUS.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/memory.c | 15 +++++++++------
 1 file changed, 9 insertions(+), 6 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index 8a2fc9945b46..f3ee782059e3 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3115,6 +3115,9 @@ static int do_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 			- vma->vm_start) >> PAGE_SHIFT) + vma->vm_pgoff;
 
 	pte_unmap(page_table);
+
+	if (unlikely(!vma->vm_ops->fault))
+		return VM_FAULT_SIGBUS;
 	if (!(flags & FAULT_FLAG_WRITE))
 		return do_read_fault(mm, vma, address, pmd, pgoff, flags,
 				orig_pte);
@@ -3260,13 +3263,13 @@ static int handle_pte_fault(struct mm_struct *mm,
 	barrier();
 	if (!pte_present(entry)) {
 		if (pte_none(entry)) {
-			if (vma->vm_ops) {
-				if (likely(vma->vm_ops->fault))
-					return do_fault(mm, vma, address, pte,
-							pmd, flags, entry);
+			if (!vma->vm_ops) {
+				return do_anonymous_page(mm, vma, address, pte,
+						pmd, flags);
+			} else {
+				return do_fault(mm, vma, address, pte, pmd,
+						flags, entry);
 			}
-			return do_anonymous_page(mm, vma, address,
-						 pte, pmd, flags);
 		}
 		return do_swap_page(mm, vma, address,
 					pte, pmd, flags, entry);
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
