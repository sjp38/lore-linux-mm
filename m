Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f179.google.com (mail-lb0-f179.google.com [209.85.217.179])
	by kanga.kvack.org (Postfix) with ESMTP id F07186B0069
	for <linux-mm@kvack.org>; Sun,  5 Oct 2014 14:41:20 -0400 (EDT)
Received: by mail-lb0-f179.google.com with SMTP id l4so3220685lbv.10
        for <linux-mm@kvack.org>; Sun, 05 Oct 2014 11:41:20 -0700 (PDT)
Received: from jenni1.inet.fi (mta-out1.inet.fi. [62.71.2.197])
        by mx.google.com with ESMTP id be20si20881280lab.17.2014.10.05.11.41.19
        for <linux-mm@kvack.org>;
        Sun, 05 Oct 2014 11:41:19 -0700 (PDT)
Date: Sun, 5 Oct 2014 21:41:15 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [patch for-3.17] mm, thp: fix collapsing of hugepages on madvise
Message-ID: <20141005184115.GA21713@node.dhcp.inet.fi>
References: <alpine.DEB.2.02.1410041947080.7055@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1410041947080.7055@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Suleiman Souhlal <suleiman@google.com>, stable@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sat, Oct 04, 2014 at 07:48:04PM -0700, David Rientjes wrote:
> If an anonymous mapping is not allowed to fault thp memory and then
> madvise(MADV_HUGEPAGE) is used after fault, khugepaged will never
> collapse this memory into thp memory.
> 
> This occurs because the madvise(2) handler for thp, hugepage_advise(),
> clears VM_NOHUGEPAGE on the stack and it isn't stored in vma->vm_flags
> until the final action of madvise_behavior().  This causes the
> khugepaged_enter_vma_merge() to be a no-op in hugepage_advise() when the
> vma had previously had VM_NOHUGEPAGE set.
> 
> Fix this by passing the correct vma flags to the khugepaged mm slot
> handler.  There's no chance khugepaged can run on this vma until after
> madvise_behavior() returns since we hold mm->mmap_sem.
> 
> It would be possible to clear VM_NOHUGEPAGE directly from vma->vm_flags
> in hugepage_advise(), but I didn't want to introduce special case
> behavior into madvise_behavior().  I think it's best to just let it
> always set vma->vm_flags itself.
> 
> Cc: <stable@vger.kernel.org>
> Reported-by: Suleiman Souhlal <suleiman@google.com>
> Signed-off-by: David Rientjes <rientjes@google.com>

Look like rather complex fix for a not that complex bug.
What about untested patch below?

From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Date: Sun, 5 Oct 2014 21:22:43 +0300
Subject: [PATCH] thp: fix registering VMA into khugepaged on
 madvise(MADV_HUGEPAGE)

hugepage_madvise() tries to register VMA into khugepaged with
khugepaged_enter_vma_merge() on madvise(MADV_HUGEPAGE). Unfortunately
it's effectevely nop, since khugepaged_enter_vma_merge() rely on
vma->vm_flags which has not yet updated by the time of
hugepage_madvise().

Let's move khugepaged_enter_vma_merge() to the end of madvise_behavior().
Now we also have chance to catch VMAs which become good for THP after
vma_merge().

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/huge_memory.c | 8 +++-----
 mm/madvise.c     | 6 ++++++
 2 files changed, 9 insertions(+), 5 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index f8ffd9412ec5..f84d52158a66 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1966,12 +1966,10 @@ int hugepage_madvise(struct vm_area_struct *vma,
 		*vm_flags &= ~VM_NOHUGEPAGE;
 		*vm_flags |= VM_HUGEPAGE;
 		/*
-		 * If the vma become good for khugepaged to scan,
-		 * register it here without waiting a page fault that
-		 * may not happen any time soon.
+		 * vma->vm_flags is not yet updated here. madvise_behavior()
+		 * will take care to register it in khugepaged once flags
+		 * updated.
 		 */
-		if (unlikely(khugepaged_enter_vma_merge(vma)))
-			return -ENOMEM;
 		break;
 	case MADV_NOHUGEPAGE:
 		/*
diff --git a/mm/madvise.c b/mm/madvise.c
index 0938b30da4ab..60effd2c5e9c 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -128,6 +128,12 @@ success:
 	 */
 	vma->vm_flags = new_flags;
 
+	/*
+	 * If the vma become good for khugepaged to scan, register it here
+	 * without waiting a page fault that may not happen any time soon.
+	 */
+	if (unlikely(khugepaged_enter_vma_merge(vma)))
+		error = -ENOMEM;
 out:
 	if (error == -ENOMEM)
 		error = -EAGAIN;
-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
