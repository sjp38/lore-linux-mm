Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id ADEC46B0031
	for <linux-mm@kvack.org>; Wed,  4 Dec 2013 09:00:15 -0500 (EST)
Received: by mail-pd0-f176.google.com with SMTP id w10so22313446pde.21
        for <linux-mm@kvack.org>; Wed, 04 Dec 2013 06:00:13 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id ph10si20019278pbb.349.2013.12.04.06.00.11
        for <linux-mm@kvack.org>;
        Wed, 04 Dec 2013 06:00:12 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <CANaxB-y0A8x3tJn16EByc3Rw8+8WqQXXFhOcqnVsgDncpwaLTw@mail.gmail.com>
References: <CANaxB-y0A8x3tJn16EByc3Rw8+8WqQXXFhOcqnVsgDncpwaLTw@mail.gmail.com>
Subject: RE: BUG at include/linux/mm.h:1443!
Content-Transfer-Encoding: 7bit
Message-Id: <20131204135950.E459CE0090@blue.fi.intel.com>
Date: Wed,  4 Dec 2013 15:59:50 +0200 (EET)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Wagin <avagin@gmail.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org

Andrey Wagin wrote:
> Hi Kirill,
> 
> I have a test server, which executes CRIU tests. It crashed today. I
> don't know how to reproduce this bug. If these information will be not
> enough, I will try to get more.

...

> [174344.225025] Call Trace:
> [174344.225025]  [<ffffffff8119427f>] free_pgd_range+0x2bf/0x410
> [174344.225025]  [<ffffffff8119449e>] free_pgtables+0xce/0x120
> [174344.225025]  [<ffffffff8119b900>] unmap_region+0xe0/0x120
> [174344.225025]  [<ffffffff811a0036>] ? move_page_tables+0x526/0x6b0
> [174344.225025]  [<ffffffff8119d6a9>] do_munmap+0x249/0x360
> [174344.225025]  [<ffffffff811a0304>] move_vma+0x144/0x270
> [174344.225025]  [<ffffffff811a07e9>] SyS_mremap+0x3b9/0x510
> [174344.225025]  [<ffffffff8172d512>] system_call_fastpath+0x16/0x1b
> [174344.225025] Code: 83 7c 24 20 00 75 24 4c 89 e7 e8 bd b7 14 00 4c
> 89 e6 48 89 df e8 82 b9 14 00 85 c0 75 08 48 89 df e8 36 c9 14 00 5b
> 41 5c c9 c3 <0f> 0b eb fe 90 90 90 90 90 90 90 90 90 90 90 90 90 55 48
> 89 e5
> [174344.225025] RIP  [<ffffffff81046f7f>] ___pmd_free_tlb+0x6f/0x80
> [174344.225025]  RSP <ffff88008f267c28>

I see. We need to move page->pmd_huge_pte to new struct page.
Could you test the patch below?

I only build-tested it [from my vacation].

It suppose to work on x86-64, but it will require more work to get it
right for sparc and other archs with custom pgtable_trans_huge_deposit()
and pgtable_trans_huge_withdraw(). I'll prepare this a bit later.

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index bccd5a628ea6..546c30193235 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1481,8 +1481,22 @@ int move_huge_pmd(struct vm_area_struct *vma, struct vm_area_struct *new_vma,
 		pmd = pmdp_get_and_clear(mm, old_addr, old_pmd);
 		VM_BUG_ON(!pmd_none(*new_pmd));
 		set_pmd_at(mm, new_addr, new_pmd, pmd_mksoft_dirty(pmd));
-		if (new_ptl != old_ptl)
+		if (new_ptl != old_ptl) {
+			pgtable_t old_pte = pmd_huge_pte(mm, old_pmd);
+			pgtable_t new_pte = pmd_huge_pte(mm, new_pmd);
+
+			/*
+			 * Move page->pmd_huge_pmd if new_pmd is on different
+			 * page table.
+			 */
+			if (new_pte)
+				list_splice(&old_pte->lru, &new_pte->lru);
+			else
+				pmd_huge_pte(mm, new_pmd) = old_pte;
+			pmd_huge_pte(mm, old_pmd) = NULL;
+
 			spin_unlock(new_ptl);
+		}
 		spin_unlock(old_ptl);
 	}
 out:
-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
