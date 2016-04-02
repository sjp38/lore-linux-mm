Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f175.google.com (mail-lb0-f175.google.com [209.85.217.175])
	by kanga.kvack.org (Postfix) with ESMTP id 03FF46B007E
	for <linux-mm@kvack.org>; Sat,  2 Apr 2016 11:37:51 -0400 (EDT)
Received: by mail-lb0-f175.google.com with SMTP id bc4so100866057lbc.2
        for <linux-mm@kvack.org>; Sat, 02 Apr 2016 08:37:50 -0700 (PDT)
Received: from mail-lb0-x236.google.com (mail-lb0-x236.google.com. [2a00:1450:4010:c04::236])
        by mx.google.com with ESMTPS id f184si11005354lfg.145.2016.04.02.08.37.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 02 Apr 2016 08:37:49 -0700 (PDT)
Received: by mail-lb0-x236.google.com with SMTP id qe11so100809977lbc.3
        for <linux-mm@kvack.org>; Sat, 02 Apr 2016 08:37:49 -0700 (PDT)
Subject: [PATCH] mm/huge_memory: replace VM_NO_THP VM_BUG_ON with actual VMA
 check
From: Konstantin Khlebnikov <koct9i@gmail.com>
Date: Sat, 02 Apr 2016 18:37:44 +0300
Message-ID: <145961146490.28194.16019687861681349309.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Dmitry Vyukov <dvyukov@google.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, stable <stable@vger.kernel.org>

Khugepaged detects own VMAs by checking vm_file and vm_ops but this
way it cannot distinguish private /dev/zero mappings from other special
mappings like /dev/hpet which has no vm_ops and popultes PTEs in mmap.

This fixes false-positive VM_BUG_ON and prevents installing THP where
they are not expected.

Signed-off-by: Konstantin Khlebnikov <koct9i@gmail.com>
Reported-by: Dmitry Vyukov <dvyukov@google.com>
Link: http://lkml.kernel.org/r/CACT4Y+ZmuZMV5CjSFOeXviwQdABAgT7T+StKfTqan9YDtgEi5g@mail.gmail.com
Fixes: 78f11a255749 ("mm: thp: fix /dev/zero MAP_PRIVATE and vm_flags cleanups")
Cc: stable <stable@vger.kernel.org>
---
 mm/huge_memory.c |    6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 86f9f8b82f8e..93de199ba0f1 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1960,10 +1960,9 @@ int khugepaged_enter_vma_merge(struct vm_area_struct *vma,
 		 * page fault if needed.
 		 */
 		return 0;
-	if (vma->vm_ops)
+	if (vma->vm_ops || (vm_flags & VM_NO_THP))
 		/* khugepaged not yet working on file or special mappings */
 		return 0;
-	VM_BUG_ON_VMA(vm_flags & VM_NO_THP, vma);
 	hstart = (vma->vm_start + ~HPAGE_PMD_MASK) & HPAGE_PMD_MASK;
 	hend = vma->vm_end & HPAGE_PMD_MASK;
 	if (hstart < hend)
@@ -2352,8 +2351,7 @@ static bool hugepage_vma_check(struct vm_area_struct *vma)
 		return false;
 	if (is_vma_temporary_stack(vma))
 		return false;
-	VM_BUG_ON_VMA(vma->vm_flags & VM_NO_THP, vma);
-	return true;
+	return !(vma->vm_flags & VM_NO_THP);
 }
 
 static void collapse_huge_page(struct mm_struct *mm,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
