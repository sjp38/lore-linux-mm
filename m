Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id DE5BE6B0069
	for <linux-mm@kvack.org>; Thu, 13 Oct 2016 14:08:43 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id t25so83842612pfg.3
        for <linux-mm@kvack.org>; Thu, 13 Oct 2016 11:08:43 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id q17si11978016pgc.60.2016.10.13.11.08.40
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 13 Oct 2016 11:08:40 -0700 (PDT)
From: Andi Kleen <andi@firstfloor.org>
Subject: [PATCH] Don't touch single threaded PTEs which are on the right node
Date: Thu, 13 Oct 2016 11:08:37 -0700
Message-Id: <1476382117-5440-1-git-send-email-andi@firstfloor.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, peterz@infradead.org, mgorman@suse.de, linux-kernel@vger.kernel.org, Andi Kleen <ak@linux.intel.com>

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
v3: Minor updates from Mel. Change code layout.
Acked-by: Mel Gorman <mgorman@suse.de>
Signed-off-by: Andi Kleen <ak@linux.intel.com>
---
 mm/mprotect.c | 13 +++++++++++++
 1 file changed, 13 insertions(+)

diff --git a/mm/mprotect.c b/mm/mprotect.c
index a4830f0325fe..11b8857c3437 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -68,11 +68,17 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
 	pte_t *pte, oldpte;
 	spinlock_t *ptl;
 	unsigned long pages = 0;
+	int target_node = NUMA_NO_NODE;
 
 	pte = lock_pte_protection(vma, pmd, addr, prot_numa, &ptl);
 	if (!pte)
 		return 0;
 
+	/* Get target node for single threaded private VMAs */
+	if (prot_numa && !(vma->vm_flags & VM_SHARED) &&
+	    atomic_read(&vma->vm_mm->mm_users) == 1)
+		target_node = numa_node_id();
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
