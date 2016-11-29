Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id EBFF16B0261
	for <linux-mm@kvack.org>; Tue, 29 Nov 2016 00:27:34 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id y71so405423231pgd.0
        for <linux-mm@kvack.org>; Mon, 28 Nov 2016 21:27:34 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id b62si58441346pfl.65.2016.11.28.21.27.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Nov 2016 21:27:34 -0800 (PST)
Subject: [PATCH update] mremap: move_ptes: check pte dirty after its removal
References: <026b73f6-ca1d-e7bb-766c-4aaeb7071ce6@intel.com>
 <CA+55aFzHfpZckv8ck19fZSFK+3TmR5eF=BsDzhwVGKrbyEBjEw@mail.gmail.com>
 <c160bc18-7c1b-2d54-8af1-7c5bfcbcefe8@intel.com>
 <20161128083715.GA21738@aaronlu.sh.intel.com>
 <20161128084012.GC21738@aaronlu.sh.intel.com>
 <CA+55aFwm8MgLi3pDMOQr2gvmjRKXeSjsmV2kLYSYZHFiUa_0fQ@mail.gmail.com>
 <977b6c8b-2df3-5f4b-0d6c-fe766cf3fae0@intel.com>
 <CA+55aFx_vOfab=WNHd=OR7vng2V_UqrEdx_xZBsKv_ohE65f8w@mail.gmail.com>
From: Aaron Lu <aaron.lu@intel.com>
Message-ID: <ccf33e20-5126-15c5-a036-918d7a94344b@intel.com>
Date: Tue, 29 Nov 2016 13:27:31 +0800
MIME-Version: 1.0
In-Reply-To: <CA+55aFx_vOfab=WNHd=OR7vng2V_UqrEdx_xZBsKv_ohE65f8w@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Dave Hansen <dave.hansen@intel.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Huang Ying <ying.huang@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

Linus found there still is a race in mremap after commit 5d1904204c99
("mremap: fix race between mremap() and page cleanning").

As described by Linus:
the issue is that another thread might make the pte be dirty (in
the hardware walker, so no locking of ours make any difference)
*after* we checked whether it was dirty, but *before* we removed it
from the page tables.

Fix it by moving the check after we removed it from the page table.

Suggested-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Aaron Lu <aaron.lu@intel.com>
---
 mm/huge_memory.c | 4 ++--
 mm/mremap.c      | 8 ++++++--
 2 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index eff3de359d50..d4a6e4001512 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1456,9 +1456,9 @@ bool move_huge_pmd(struct vm_area_struct *vma, unsigned long old_addr,
 		new_ptl = pmd_lockptr(mm, new_pmd);
 		if (new_ptl != old_ptl)
 			spin_lock_nested(new_ptl, SINGLE_DEPTH_NESTING);
-		if (pmd_present(*old_pmd) && pmd_dirty(*old_pmd))
-			force_flush = true;
 		pmd = pmdp_huge_get_and_clear(mm, old_addr, old_pmd);
+		if (pmd_present(pmd) && pmd_dirty(pmd))
+			force_flush = true;
 		VM_BUG_ON(!pmd_none(*new_pmd));
 
 		if (pmd_move_must_withdraw(new_ptl, old_ptl) &&
diff --git a/mm/mremap.c b/mm/mremap.c
index 6ccecc03f56a..53df7ec8d2ba 100644
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -149,14 +149,18 @@ static void move_ptes(struct vm_area_struct *vma, pmd_t *old_pmd,
 		if (pte_none(*old_pte))
 			continue;
 
+		pte = ptep_get_and_clear(mm, old_addr, old_pte);
 		/*
 		 * We are remapping a dirty PTE, make sure to
 		 * flush TLB before we drop the PTL for the
 		 * old PTE or we may race with page_mkclean().
+		 *
+		 * This check has to be done after we removed the
+		 * old PTE from page tables or another thread may
+		 * dirty it after the check and before the removal.
 		 */
-		if (pte_present(*old_pte) && pte_dirty(*old_pte))
+		if (pte_present(pte) && pte_dirty(pte))
 			force_flush = true;
-		pte = ptep_get_and_clear(mm, old_addr, old_pte);
 		pte = move_pte(pte, new_vma->vm_page_prot, old_addr, new_addr);
 		pte = move_soft_dirty_pte(pte);
 		set_pte_at(mm, new_addr, new_pte, pte);
-- 
2.5.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
