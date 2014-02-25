Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f176.google.com (mail-ig0-f176.google.com [209.85.213.176])
	by kanga.kvack.org (Postfix) with ESMTP id 8AB606B00D5
	for <linux-mm@kvack.org>; Tue, 25 Feb 2014 14:21:38 -0500 (EST)
Received: by mail-ig0-f176.google.com with SMTP id uy17so233972igb.3
        for <linux-mm@kvack.org>; Tue, 25 Feb 2014 11:21:38 -0800 (PST)
Received: from relay.sgi.com (relay2.sgi.com. [192.48.179.30])
        by mx.google.com with ESMTP id x3si39844645igl.28.2014.02.25.11.21.37
        for <linux-mm@kvack.org>;
        Tue, 25 Feb 2014 11:21:37 -0800 (PST)
From: Alex Thorlton <athorlton@sgi.com>
Subject: [PATCH 1/3] Revert "thp: make MADV_HUGEPAGE check for mm->def_flags"
Date: Tue, 25 Feb 2014 13:21:00 -0600
Message-Id: <40ad55e4434df1e0b76c09b811c02a565a0b0025.1392009760.git.athorlton@sgi.com>
In-Reply-To: <cover.1392009759.git.athorlton@sgi.com>
References: <cover.1392009759.git.athorlton@sgi.com>
In-Reply-To: <cover.1392009759.git.athorlton@sgi.com>
References: <cover.1392009759.git.athorlton@sgi.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Alex Thorlton <athorlton@sgi.com>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Paolo Bonzini <pbonzini@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Bob Liu <lliubbo@gmail.com>, Jiang Liu <liuj97@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Oleg Nesterov <oleg@redhat.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Daeseok Youn <daeseok.youn@gmail.com>, Kent Overstreet <koverstreet@google.com>, Dario Faggioli <raistlin@linux.it>, John Stultz <johnstul@us.ibm.com>, Stephen Rothwell <sfr@canb.auug.org.au>, Alexander Viro <viro@zeniv.linux.org.uk>, linux390@de.ibm.com, linux-s390@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org

This reverts commit 8e72033f2a489b6c98c4e3c7cc281b1afd6cb85c, and adds
in code to fix up any issues caused by the revert.

The revert is necessary because hugepage_madvise would return -EINVAL
when VM_NOHUGEPAGE is set, which will break subsequent chunks of this
patch set.

Here's a snip of an e-mail from Gerald detailing the original purpose
of this code, and providing justification for the revert:

<snip>
The intent of 8e72033f2a48 was to guard against any future programming
errors that may result in an madvice(MADV_HUGEPAGE) on guest mappings,
which would crash the kernel.

Martin suggested adding the bit to arch/s390/mm/pgtable.c, if 8e72033f2a48
was to be reverted, because that check will also prevent a kernel crash
in the case described above, it will now send a SIGSEGV instead.

This would now also allow to do the madvise on other parts, if needed,
so it is a more flexible approach. One could also say that it would have
been better to do it this way right from the beginning... 
</snip>

Signed-off-by: Alex Thorlton <athorlton@sgi.com>
Suggested-by: Oleg Nesterov <oleg@redhat.com>
Cc: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: Christian Borntraeger <borntraeger@de.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Paolo Bonzini <pbonzini@redhat.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Rik van Riel <riel@redhat.com>
Cc: Ingo Molnar <mingo@kernel.org>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: Bob Liu <lliubbo@gmail.com>
Cc: Jiang Liu <liuj97@gmail.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Oleg Nesterov <oleg@redhat.com>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Daeseok Youn <daeseok.youn@gmail.com>
Cc: Kent Overstreet <koverstreet@google.com>
Cc: Dario Faggioli <raistlin@linux.it>
Cc: John Stultz <johnstul@us.ibm.com>
Cc: Stephen Rothwell <sfr@canb.auug.org.au>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: linux390@de.ibm.com
Cc: linux-s390@vger.kernel.org
Cc: linux-mm@kvack.org
Cc: linux-api@vger.kernel.org

---
 arch/s390/mm/pgtable.c | 3 +++
 mm/huge_memory.c       | 4 ----
 2 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/arch/s390/mm/pgtable.c b/arch/s390/mm/pgtable.c
index 3584ed9..a87cdb4 100644
--- a/arch/s390/mm/pgtable.c
+++ b/arch/s390/mm/pgtable.c
@@ -504,6 +504,9 @@ static int gmap_connect_pgtable(unsigned long address, unsigned long segment,
 	if (!pmd_present(*pmd) &&
 	    __pte_alloc(mm, vma, pmd, vmaddr))
 		return -ENOMEM;
+	/* large pmds cannot yet be handled */
+	if (pmd_large(*pmd))
+		return -EFAULT;
 	/* pmd now points to a valid segment table entry. */
 	rmap = kmalloc(sizeof(*rmap), GFP_KERNEL|__GFP_REPEAT);
 	if (!rmap)
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 82166bf..a4310a5 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1968,8 +1968,6 @@ out:
 int hugepage_madvise(struct vm_area_struct *vma,
 		     unsigned long *vm_flags, int advice)
 {
-	struct mm_struct *mm = vma->vm_mm;
-
 	switch (advice) {
 	case MADV_HUGEPAGE:
 		/*
@@ -1977,8 +1975,6 @@ int hugepage_madvise(struct vm_area_struct *vma,
 		 */
 		if (*vm_flags & (VM_HUGEPAGE | VM_NO_THP))
 			return -EINVAL;
-		if (mm->def_flags & VM_NOHUGEPAGE)
-			return -EINVAL;
 		*vm_flags &= ~VM_NOHUGEPAGE;
 		*vm_flags |= VM_HUGEPAGE;
 		/*
-- 
1.7.12.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
