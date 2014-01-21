Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f173.google.com (mail-ie0-f173.google.com [209.85.223.173])
	by kanga.kvack.org (Postfix) with ESMTP id A91036B00AC
	for <linux-mm@kvack.org>; Tue, 21 Jan 2014 18:08:04 -0500 (EST)
Received: by mail-ie0-f173.google.com with SMTP id e14so10703891iej.4
        for <linux-mm@kvack.org>; Tue, 21 Jan 2014 15:08:04 -0800 (PST)
Received: from relay.sgi.com (relay3.sgi.com. [192.48.152.1])
        by mx.google.com with ESMTP id oc7si10456014igb.71.2014.01.21.15.08.02
        for <linux-mm@kvack.org>;
        Tue, 21 Jan 2014 15:08:03 -0800 (PST)
From: Alex Thorlton <athorlton@sgi.com>
Subject: [BUG] mm: thp: hugepage_vma_check has a blind spot
Date: Tue, 21 Jan 2014 17:07:49 -0600
Message-Id: <1390345671-136133-1-git-send-email-athorlton@sgi.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Alex Thorlton <athorlton@sgi.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, linux-mm@kvack.org

hugepage_vma_check is called during khugepaged_scan_mm_slot to ensure
that khugepaged doesn't try to allocate THPs in vmas where they are
disallowed, either due to THPs being disabled system-wide, or through
MADV_NOHUGEPAGE.

The logic that hugepage_vma_check uses doesn't seem to cover all cases,
in my opinion.  Looking at the original code:

       if ((!(vma->vm_flags & VM_HUGEPAGE) && !khugepaged_always()) ||
	   (vma->vm_flags & VM_NOHUGEPAGE))

We can see that it's possible to have THP disabled system-wide, but still
receive THPs in this vma.  It seems that it's assumed that just because
khugepaged_always == false, TRANSPARENT_HUGEPAGE_REQ_MADV_FLAG must be
set, which is not the case.  We could have VM_HUGEPAGE set, but have THP
set to "never" system-wide, in which case, the condition presented in the
if will evaluate to false, and (provided the other checks pass) we can
end up giving out a THP even though the behavior is set to "never."

While we do properly check these flags in khugepaged_has_work, it looks
like it's possible to sleep after we check khugepaged_hask_work, but
before hugepage_vma_check, during which time, hugepages could have been
disabled system-wide, in which case, we could hand out THPs when we
shouldn't be.

This small fix makes hugepage_vma_check work more like
transparent_hugepage_enabled, checking if THPs are set to "always"
system-wide, then checking if THPs are set to "madvise," as well as
making sure that VM_HUGEPAGE is set for this vma.

Signed-off-by: Alex Thorlton <athorlton@sgi.com>
Reported-by: Alex Thorlton <athorlton@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org> 
Cc: Mel Gorman <mgorman@suse.de> 
Cc: Rik van Riel <riel@redhat.com> 
Cc: Ingo Molnar <mingo@kernel.org> 
Cc: Peter Zijlstra <peterz@infradead.org> 
Cc: linux-mm@kvack.org 
Cc: linux-kernel@vger.kernel.org 

---
 mm/huge_memory.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 95d1acb..f62fba9 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2394,7 +2394,8 @@ static struct page
 
 static bool hugepage_vma_check(struct vm_area_struct *vma)
 {
-	if ((!(vma->vm_flags & VM_HUGEPAGE) && !khugepaged_always()) ||
+	if ((!khugepaged_always() ||
+	     (!(vma->vm_flags & VM_HUGEPAGE) && !khugepaged_req_madv())) ||
 	    (vma->vm_flags & VM_NOHUGEPAGE))
 		return false;
 
-- 
1.7.12.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
