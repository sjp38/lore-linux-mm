Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f181.google.com (mail-ig0-f181.google.com [209.85.213.181])
	by kanga.kvack.org (Postfix) with ESMTP id 4C63F6B0036
	for <linux-mm@kvack.org>; Fri, 31 Jan 2014 13:24:07 -0500 (EST)
Received: by mail-ig0-f181.google.com with SMTP id j1so10020758iga.2
        for <linux-mm@kvack.org>; Fri, 31 Jan 2014 10:24:07 -0800 (PST)
Received: from relay.sgi.com (relay1.sgi.com. [192.48.179.29])
        by mx.google.com with ESMTP id o19si9573187igt.17.2014.01.31.10.23.55
        for <linux-mm@kvack.org>;
        Fri, 31 Jan 2014 10:23:55 -0800 (PST)
From: Alex Thorlton <athorlton@sgi.com>
Subject: [PATCH 1/3] Revert "thp: make MADV_HUGEPAGE check for mm->def_flags"
Date: Fri, 31 Jan 2014 12:23:43 -0600
Message-Id: <1391192628-113858-3-git-send-email-athorlton@sgi.com>
In-Reply-To: <1391192628-113858-1-git-send-email-athorlton@sgi.com>
References: <1391192628-113858-1-git-send-email-athorlton@sgi.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Alex Thorlton <athorlton@sgi.com>, Oleg Nesterov <oleg@redhat.com>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Paolo Bonzini <pbonzini@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Sasha Levin <sasha.levin@oracle.com>, linux390@de.ibm.com, linux-s390@vger.kernel.org, linux-mm@kvack.org

This reverts commit 8e72033f2a489b6c98c4e3c7cc281b1afd6cb85cm, and adds
in code to fix up any issues caused by the revert.

The revert is necessary because hugepage_madvise would return -EINVAL
when VM_NOHUGEPAGE is set, which will break subsequent chunks of this
patch set.

Signed-off-by: Alex Thorlton <athorlton@sgi.com>
Suggested-by: Oleg Nesterov <oleg@redhat.com>
Cc: Oleg Nesterov <oleg@redhat.com>
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
Cc: Sasha Levin <sasha.levin@oracle.com>
Cc: linux390@de.ibm.com
Cc: linux-s390@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org

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
