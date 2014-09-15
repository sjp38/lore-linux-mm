Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f173.google.com (mail-ie0-f173.google.com [209.85.223.173])
	by kanga.kvack.org (Postfix) with ESMTP id 6A50F6B0036
	for <linux-mm@kvack.org>; Mon, 15 Sep 2014 15:19:32 -0400 (EDT)
Received: by mail-ie0-f173.google.com with SMTP id x19so5242726ier.18
        for <linux-mm@kvack.org>; Mon, 15 Sep 2014 12:19:32 -0700 (PDT)
Received: from mail-ie0-x24a.google.com (mail-ie0-x24a.google.com [2607:f8b0:4001:c03::24a])
        by mx.google.com with ESMTPS id qo6si10461380igb.23.2014.09.15.12.19.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 15 Sep 2014 12:19:31 -0700 (PDT)
Received: by mail-ie0-f202.google.com with SMTP id rl12so682877iec.1
        for <linux-mm@kvack.org>; Mon, 15 Sep 2014 12:19:31 -0700 (PDT)
From: Peter Feiner <pfeiner@google.com>
Subject: [PATCH v2] mm: softdirty: addresses before VMAs in PTE holes aren't softdirty
Date: Mon, 15 Sep 2014 12:19:27 -0700
Message-Id: <1410808767-9047-1-git-send-email-pfeiner@google.com>
In-Reply-To: <1410374050-13074-1-git-send-email-pfeiner@google.com>
References: <1410374050-13074-1-git-send-email-pfeiner@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Peter Feiner <pfeiner@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Cyrill Gorcunov <gorcunov@openvz.org>, Pavel Emelyanov <xemul@parallels.com>, Jamie Liu <jamieliu@google.com>, Hugh Dickins <hughd@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andrew Morton <akpm@linux-foundation.org>

In PTE holes that contain VM_SOFTDIRTY VMAs, unmapped addresses before
VM_SOFTDIRTY VMAs are reported as softdirty by /proc/pid/pagemap. This
bug was introduced in 68b5a652485682f67eacdee3deae640fb7845b63. The
aforementioned patch made /proc/pid/pagemap look at VM_SOFTDIRTY in PTE
holes but neglected to observe the start of VMAs returned by find_vma.

Tested:
  Wrote a selftest that creates a PMD-sized VMA then unmaps the first
  page and asserts that the page is not softdirty. I'm going to send the
  pagemap selftest in a later commit.

Signed-off-by: Peter Feiner <pfeiner@google.com>

---

v1 -> v2:
	Rewrote to make logic easier to follow.
---
 fs/proc/task_mmu.c | 27 ++++++++++++++++++---------
 1 file changed, 18 insertions(+), 9 deletions(-)

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index dfc791c..c341568 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -931,23 +931,32 @@ static int pagemap_pte_hole(unsigned long start, unsigned long end,
 	while (addr < end) {
 		struct vm_area_struct *vma = find_vma(walk->mm, addr);
 		pagemap_entry_t pme = make_pme(PM_NOT_PRESENT(pm->v2));
-		unsigned long vm_end;
+		/* End of address space hole, which we mark as non-present. */
+		unsigned long hole_end;
 
-		if (!vma) {
-			vm_end = end;
-		} else {
-			vm_end = min(end, vma->vm_end);
-			if (vma->vm_flags & VM_SOFTDIRTY)
-				pme.pme |= PM_STATUS2(pm->v2, __PM_SOFT_DIRTY);
+		if (vma)
+			hole_end = min(end, vma->vm_start);
+		else
+			hole_end = end;
+
+		for (; addr < hole_end; addr += PAGE_SIZE) {
+			err = add_to_pagemap(addr, &pme, pm);
+			if (err)
+				goto out;
 		}
 
-		for (; addr < vm_end; addr += PAGE_SIZE) {
+		if (!vma)
+			break;
+
+		/* Addresses in the VMA. */
+		if (vma->vm_flags & VM_SOFTDIRTY)
+			pme.pme |= PM_STATUS2(pm->v2, __PM_SOFT_DIRTY);
+		for (; addr < min(end, vma->vm_end); addr += PAGE_SIZE) {
 			err = add_to_pagemap(addr, &pme, pm);
 			if (err)
 				goto out;
 		}
 	}
-
 out:
 	return err;
 }
-- 
2.1.0.rc2.206.gedb03e5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
