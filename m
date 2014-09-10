Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f46.google.com (mail-oa0-f46.google.com [209.85.219.46])
	by kanga.kvack.org (Postfix) with ESMTP id 733B46B0044
	for <linux-mm@kvack.org>; Wed, 10 Sep 2014 14:34:17 -0400 (EDT)
Received: by mail-oa0-f46.google.com with SMTP id eb12so4310579oac.19
        for <linux-mm@kvack.org>; Wed, 10 Sep 2014 11:34:16 -0700 (PDT)
Received: from mail-oi0-x24a.google.com (mail-oi0-x24a.google.com [2607:f8b0:4003:c06::24a])
        by mx.google.com with ESMTPS id cf5si23460806obc.10.2014.09.10.11.34.16
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 10 Sep 2014 11:34:16 -0700 (PDT)
Received: by mail-oi0-f74.google.com with SMTP id e131so1287948oig.5
        for <linux-mm@kvack.org>; Wed, 10 Sep 2014 11:34:16 -0700 (PDT)
From: Peter Feiner <pfeiner@google.com>
Subject: [PATCH] mm: softdirty: addresses before VMAs in PTE holes aren't softdirty
Date: Wed, 10 Sep 2014 11:34:10 -0700
Message-Id: <1410374050-13074-1-git-send-email-pfeiner@google.com>
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
 fs/proc/task_mmu.c | 22 ++++++++++++++++------
 1 file changed, 16 insertions(+), 6 deletions(-)

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index dfc791c..256dbe9 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -931,16 +931,26 @@ static int pagemap_pte_hole(unsigned long start, unsigned long end,
 	while (addr < end) {
 		struct vm_area_struct *vma = find_vma(walk->mm, addr);
 		pagemap_entry_t pme = make_pme(PM_NOT_PRESENT(pm->v2));
-		unsigned long vm_end;
+		unsigned long vm_start = end;
+		unsigned long vm_end = end;
+		unsigned long vm_flags = 0;
 
-		if (!vma) {
-			vm_end = end;
-		} else {
+		if (vma) {
+			vm_start = min(end, vma->vm_start);
 			vm_end = min(end, vma->vm_end);
-			if (vma->vm_flags & VM_SOFTDIRTY)
-				pme.pme |= PM_STATUS2(pm->v2, __PM_SOFT_DIRTY);
+			vm_flags = vma->vm_flags;
+		}
+
+		/* Addresses before the VMA. */
+		for (; addr < vm_start; addr += PAGE_SIZE) {
+			err = add_to_pagemap(addr, &pme, pm);
+			if (err)
+				goto out;
 		}
 
+		/* Addresses in the VMA. */
+		if (vm_flags & VM_SOFTDIRTY)
+			pme.pme |= PM_STATUS2(pm->v2, __PM_SOFT_DIRTY);
 		for (; addr < vm_end; addr += PAGE_SIZE) {
 			err = add_to_pagemap(addr, &pme, pm);
 			if (err)
-- 
2.1.0.rc2.206.gedb03e5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
