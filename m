Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 13F9F6B0260
	for <linux-mm@kvack.org>; Wed, 12 Oct 2016 12:15:52 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id kc8so48132472pab.2
        for <linux-mm@kvack.org>; Wed, 12 Oct 2016 09:15:52 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id x73si10045068pfd.44.2016.10.12.09.15.50
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 12 Oct 2016 09:15:51 -0700 (PDT)
From: Andi Kleen <andi@firstfloor.org>
Subject: [PATCH] Don't touch single threaded PTEs which are on the right node
Date: Wed, 12 Oct 2016 09:15:49 -0700
Message-Id: <1476288949-20970-1-git-send-email-andi@firstfloor.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: peterz@infradead.org
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, mgorman@suse.de, linux-kernel@vger.kernel.org, Andi Kleen <ak@linux.intel.com>

From: Andi Kleen <ak@linux.intel.com>

We had some problems with pages getting unmapped in single threaded
affinitized processes. It was tracked down to NUMA scanning.

In this case it doesn't make any sense to unmap pages if the
process is single threaded and the page is already on the
node the process is running on.

Add a check for this case into the numa protection code,
and skip unmapping if true.

In theory the process could be migrated later, but we
will eventually rescan and unmap and migrate then.

In theory this could be made more fancy: remembering this
state per process or even whole mm. However that would
need extra tracking and be more complicated, and the
simple check seems to work fine so far.

v2: Only do it for private VMAs. Move most of check out of
loop.
Signed-off-by: Andi Kleen <ak@linux.intel.com>
---
 mm/mprotect.c | 13 +++++++++++++
 1 file changed, 13 insertions(+)

diff --git a/mm/mprotect.c b/mm/mprotect.c
index a4830f0325fe..e9473e7e1468 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -68,11 +68,17 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
 	pte_t *pte, oldpte;
 	spinlock_t *ptl;
 	unsigned long pages = 0;
+	int target_node = -1;
 
 	pte = lock_pte_protection(vma, pmd, addr, prot_numa, &ptl);
 	if (!pte)
 		return 0;
 
+	if (prot_numa &&
+	    !(vma->vm_flags & VM_SHARED) &&
+	    atomic_read(&vma->vm_mm->mm_users) == 1)
+	    target_node = cpu_to_node(raw_smp_processor_id());
+
 	arch_enter_lazy_mmu_mode();
 	do {
 		oldpte = *pte;
@@ -94,6 +100,13 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
 				/* Avoid TLB flush if possible */
 				if (pte_protnone(oldpte))
 					continue;
+
+				/*
+				 * Don't mess with PTEs if page is already on the node
+				 * a single-threaded process is running on.
+				 */
+				if (target_node == page_to_nid(page))
+					continue;
 			}
 
 			ptent = ptep_modify_prot_start(mm, addr, pte);
-- 
2.5.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
