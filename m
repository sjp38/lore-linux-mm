Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f50.google.com (mail-qa0-f50.google.com [209.85.216.50])
	by kanga.kvack.org (Postfix) with ESMTP id 699876B0035
	for <linux-mm@kvack.org>; Thu, 31 Jul 2014 18:43:30 -0400 (EDT)
Received: by mail-qa0-f50.google.com with SMTP id s7so3053496qap.37
        for <linux-mm@kvack.org>; Thu, 31 Jul 2014 15:43:30 -0700 (PDT)
Received: from mail-qa0-x24a.google.com (mail-qa0-x24a.google.com [2607:f8b0:400d:c00::24a])
        by mx.google.com with ESMTPS id a3si12322742qcm.5.2014.07.31.15.43.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 31 Jul 2014 15:43:29 -0700 (PDT)
Received: by mail-qa0-f74.google.com with SMTP id j15so353100qaq.5
        for <linux-mm@kvack.org>; Thu, 31 Jul 2014 15:43:29 -0700 (PDT)
From: Peter Feiner <pfeiner@google.com>
Subject: [PATCH] mm: softdirty: respect VM_SOFTDIRTY in PTE holes
Date: Thu, 31 Jul 2014 18:43:25 -0400
Message-Id: <1406846605-12176-1-git-send-email-pfeiner@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Peter Feiner <pfeiner@google.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Pavel Emelyanov <xemul@parallels.com>, Hugh Dickins <hughd@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andrew Morton <akpm@linux-foundation.org>

After a VMA is created with the VM_SOFTDIRTY flag set,
/proc/pid/pagemap should report that the VMA's virtual pages are
soft-dirty until VM_SOFTDIRTY is cleared (i.e., by the next write of
"4" to /proc/pid/clear_refs). However, pagemap ignores the
VM_SOFTDIRTY flag for virtual addresses that fall in PTE holes (i.e.,
virtual addresses that don't have a PMD, PUD, or PGD allocated yet).

To observe this bug, use mmap to create a VMA large enough such that
there's a good chance that the VMA will occupy an unused PMD, then
test the soft-dirty bit on its pages. In practice, I found that a VMA
that covered a PMD's worth of address space was big enough.

This patch adds the necessary VMA lookup to the PTE hole callback in
/proc/pid/pagemap's page walk and sets soft-dirty according to the
VMAs' VM_SOFTDIRTY flag.

Signed-off-by: Peter Feiner <pfeiner@google.com>
---
 fs/proc/task_mmu.c | 27 +++++++++++++++++++++------
 1 file changed, 21 insertions(+), 6 deletions(-)

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index cfa63ee..dfc791c 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -925,15 +925,30 @@ static int pagemap_pte_hole(unsigned long start, unsigned long end,
 				struct mm_walk *walk)
 {
 	struct pagemapread *pm = walk->private;
-	unsigned long addr;
+	unsigned long addr = start;
 	int err = 0;
-	pagemap_entry_t pme = make_pme(PM_NOT_PRESENT(pm->v2));
 
-	for (addr = start; addr < end; addr += PAGE_SIZE) {
-		err = add_to_pagemap(addr, &pme, pm);
-		if (err)
-			break;
+	while (addr < end) {
+		struct vm_area_struct *vma = find_vma(walk->mm, addr);
+		pagemap_entry_t pme = make_pme(PM_NOT_PRESENT(pm->v2));
+		unsigned long vm_end;
+
+		if (!vma) {
+			vm_end = end;
+		} else {
+			vm_end = min(end, vma->vm_end);
+			if (vma->vm_flags & VM_SOFTDIRTY)
+				pme.pme |= PM_STATUS2(pm->v2, __PM_SOFT_DIRTY);
+		}
+
+		for (; addr < vm_end; addr += PAGE_SIZE) {
+			err = add_to_pagemap(addr, &pme, pm);
+			if (err)
+				goto out;
+		}
 	}
+
+out:
 	return err;
 }
 
-- 
2.0.0.526.g5318336

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
