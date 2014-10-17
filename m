Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id C2F306B0071
	for <linux-mm@kvack.org>; Fri, 17 Oct 2014 10:10:12 -0400 (EDT)
Received: by mail-wi0-f182.google.com with SMTP id n3so1372381wiv.3
        for <linux-mm@kvack.org>; Fri, 17 Oct 2014 07:10:12 -0700 (PDT)
Received: from e06smtp17.uk.ibm.com (e06smtp17.uk.ibm.com. [195.75.94.113])
        by mx.google.com with ESMTPS id wo4si1687032wjb.23.2014.10.17.07.10.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 17 Oct 2014 07:10:10 -0700 (PDT)
Received: from /spool/local
	by e06smtp17.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dingel@linux.vnet.ibm.com>;
	Fri, 17 Oct 2014 15:10:09 +0100
Received: from b06cxnps4075.portsmouth.uk.ibm.com (d06relay12.portsmouth.uk.ibm.com [9.149.109.197])
	by d06dlp02.portsmouth.uk.ibm.com (Postfix) with ESMTP id 820A92190046
	for <linux-mm@kvack.org>; Fri, 17 Oct 2014 15:09:42 +0100 (BST)
Received: from d06av07.portsmouth.uk.ibm.com (d06av07.portsmouth.uk.ibm.com [9.149.37.248])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id s9HEA55M1376680
	for <linux-mm@kvack.org>; Fri, 17 Oct 2014 14:10:05 GMT
Received: from d06av07.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av07.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s9HEA48q031967
	for <linux-mm@kvack.org>; Fri, 17 Oct 2014 10:10:05 -0400
From: Dominik Dingel <dingel@linux.vnet.ibm.com>
Subject: [PATCH 2/4] mm: introduce new VM_NOZEROPAGE flag
Date: Fri, 17 Oct 2014 16:09:48 +0200
Message-Id: <1413554990-48512-3-git-send-email-dingel@linux.vnet.ibm.com>
In-Reply-To: <1413554990-48512-1-git-send-email-dingel@linux.vnet.ibm.com>
References: <1413554990-48512-1-git-send-email-dingel@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Rik van Riel <riel@redhat.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andy Lutomirski <luto@amacapital.net>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Bob Liu <lliubbo@gmail.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Cornelia Huck <cornelia.huck@de.ibm.com>, Gleb Natapov <gleb@kernel.org>, Heiko Carstens <heiko.carstens@de.ibm.com>, "H. Peter Anvin" <hpa@linux.intel.com>, Hugh Dickins <hughd@google.com>, Ingo Molnar <mingo@kernel.org>, Jianyu Zhan <nasa4836@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Konstantin Weitz <konstantin.weitz@gmail.com>, kvm@vger.kernel.org, linux390@de.ibm.com, linux-kernel@vger.kernel.org, linux-s390@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Paolo Bonzini <pbonzini@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Sasha Levin <sasha.levin@oracle.com>, Dominik Dingel <dingel@linux.vnet.ibm.com>

Add a new vma flag to allow an architecture to disable the backing
of non-present, anonymous pages with the read-only empty zero page.

Signed-off-by: Dominik Dingel <dingel@linux.vnet.ibm.com>
Acked-by: Christian Borntraeger <borntraeger@de.ibm.com>
Signed-off-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
---
 include/linux/mm.h | 13 +++++++++++--
 mm/huge_memory.c   |  2 +-
 mm/memory.c        |  2 +-
 3 files changed, 13 insertions(+), 4 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index cd33ae2..8f09c91 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -113,7 +113,7 @@ extern unsigned int kobjsize(const void *objp);
 #define VM_GROWSDOWN	0x00000100	/* general info on the segment */
 #define VM_PFNMAP	0x00000400	/* Page-ranges managed without "struct page", just pure PFN */
 #define VM_DENYWRITE	0x00000800	/* ETXTBSY on write attempts.. */
-
+#define VM_NOZEROPAGE	0x00001000	/* forbid new zero page mappings */
 #define VM_LOCKED	0x00002000
 #define VM_IO           0x00004000	/* Memory mapped I/O or similar */
 
@@ -179,7 +179,7 @@ extern unsigned int kobjsize(const void *objp);
 #define VM_SPECIAL (VM_IO | VM_DONTEXPAND | VM_PFNMAP | VM_MIXEDMAP)
 
 /* This mask defines which mm->def_flags a process can inherit its parent */
-#define VM_INIT_DEF_MASK	VM_NOHUGEPAGE
+#define VM_INIT_DEF_MASK	(VM_NOHUGEPAGE | VM_NOZEROPAGE)
 
 /*
  * mapping from the currently active vm_flags protection bits (the
@@ -1293,6 +1293,15 @@ static inline int stack_guard_page_end(struct vm_area_struct *vma,
 		!vma_growsup(vma->vm_next, addr);
 }
 
+static inline int vma_forbids_zeropage(struct vm_area_struct *vma)
+{
+#ifdef CONFIG_NOZEROPAGE
+	return vma->vm_flags & VM_NOZEROPAGE;
+#else
+	return 0;
+#endif
+}
+
 extern struct task_struct *task_of_stack(struct task_struct *task,
 				struct vm_area_struct *vma, bool in_group);
 
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index de98415..c271265 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -805,7 +805,7 @@ int do_huge_pmd_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		return VM_FAULT_OOM;
 	if (unlikely(khugepaged_enter(vma, vma->vm_flags)))
 		return VM_FAULT_OOM;
-	if (!(flags & FAULT_FLAG_WRITE) &&
+	if (!(flags & FAULT_FLAG_WRITE) && !vma_forbids_zeropage(vma) &&
 			transparent_hugepage_use_zero_page()) {
 		spinlock_t *ptl;
 		pgtable_t pgtable;
diff --git a/mm/memory.c b/mm/memory.c
index 64f82aa..1859b2b 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2640,7 +2640,7 @@ static int do_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		return VM_FAULT_SIGBUS;
 
 	/* Use the zero-page for reads */
-	if (!(flags & FAULT_FLAG_WRITE)) {
+	if (!(flags & FAULT_FLAG_WRITE) && !vma_forbids_zeropage(vma)) {
 		entry = pte_mkspecial(pfn_pte(my_zero_pfn(address),
 						vma->vm_page_prot));
 		page_table = pte_offset_map_lock(mm, pmd, address, &ptl);
-- 
1.8.5.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
