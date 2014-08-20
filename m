Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f44.google.com (mail-qg0-f44.google.com [209.85.192.44])
	by kanga.kvack.org (Postfix) with ESMTP id 98D2C6B0035
	for <linux-mm@kvack.org>; Wed, 20 Aug 2014 17:46:26 -0400 (EDT)
Received: by mail-qg0-f44.google.com with SMTP id e89so8013245qgf.17
        for <linux-mm@kvack.org>; Wed, 20 Aug 2014 14:46:26 -0700 (PDT)
Received: from mail-qc0-x24a.google.com (mail-qc0-x24a.google.com [2607:f8b0:400d:c01::24a])
        by mx.google.com with ESMTPS id s6si35957476qas.106.2014.08.20.14.46.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 20 Aug 2014 14:46:26 -0700 (PDT)
Received: by mail-qc0-f202.google.com with SMTP id r5so1022772qcx.3
        for <linux-mm@kvack.org>; Wed, 20 Aug 2014 14:46:26 -0700 (PDT)
From: Peter Feiner <pfeiner@google.com>
Subject: [PATCH] mm: softdirty: write protect PTEs created for read faults after VM_SOFTDIRTY cleared
Date: Wed, 20 Aug 2014 17:46:22 -0400
Message-Id: <1408571182-28750-1-git-send-email-pfeiner@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Peter Feiner <pfeiner@google.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Pavel Emelyanov <xemul@parallels.com>, Jamie Liu <jamieliu@google.com>, Hugh Dickins <hughd@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andrew Morton <akpm@linux-foundation.org>

In readable+writable+shared VMAs, PTEs created for read faults have
their write bit set. If the read fault happens after VM_SOFTDIRTY is
cleared, then the PTE's softdirty bit will remain clear after
subsequent writes.

Here's a simple code snippet to demonstrate the bug:

  char* m = mmap(NULL, getpagesize(), PROT_READ | PROT_WRITE,
                 MAP_ANONYMOUS | MAP_SHARED, -1, 0);
  system("echo 4 > /proc/$PPID/clear_refs"); /* clear VM_SOFTDIRTY */
  assert(*m == '\0');     /* new PTE allows write access */
  assert(!soft_dirty(x));
  *m = 'x';               /* should dirty the page */
  assert(soft_dirty(x));  /* fails */

With this patch, new PTEs created for read faults are write protected
if the VMA has VM_SOFTDIRTY clear.

Signed-off-by: Peter Feiner <pfeiner@google.com>
---
 mm/memory.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/mm/memory.c b/mm/memory.c
index ab3537b..282a959 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2755,6 +2755,8 @@ void do_set_pte(struct vm_area_struct *vma, unsigned long address,
 		entry = maybe_mkwrite(pte_mkdirty(entry), vma);
 	else if (pte_file(*pte) && pte_file_soft_dirty(*pte))
 		entry = pte_mksoft_dirty(entry);
+	else if (!(vma->vm_flags & VM_SOFTDIRTY))
+		entry = pte_wrprotect(entry);
 	if (anon) {
 		inc_mm_counter_fast(vma->vm_mm, MM_ANONPAGES);
 		page_add_new_anon_rmap(page, vma, address);
-- 
2.1.0.rc2.206.gedb03e5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
