Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id A2E366B0253
	for <linux-mm@kvack.org>; Sun, 26 Jun 2016 21:28:54 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id 143so372538090pfx.0
        for <linux-mm@kvack.org>; Sun, 26 Jun 2016 18:28:54 -0700 (PDT)
Received: from mail-pa0-x242.google.com (mail-pa0-x242.google.com. [2607:f8b0:400e:c03::242])
        by mx.google.com with ESMTPS id ap9si23020249pad.30.2016.06.26.18.28.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 26 Jun 2016 18:28:53 -0700 (PDT)
Received: by mail-pa0-x242.google.com with SMTP id hf6so13970191pac.2
        for <linux-mm@kvack.org>; Sun, 26 Jun 2016 18:28:53 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH v4 1/2] mm: thp: move pmd check inside ptl for freeze_page()
Date: Mon, 27 Jun 2016 10:28:48 +0900
Message-Id: <1466990929-7452-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@suse.cz>, Vlastimil Babka <vbabka@suse.cz>, linux-kernel@vger.kernel.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Naoya Horiguchi <nao.horiguchi@gmail.com>

I found a race condition triggering VM_BUG_ON() in freeze_page(), when running
a testcase with 3 processes:
  - process 1: keep writing thp,
  - process 2: keep clearing soft-dirty bits from virtual address of process 1
  - process 3: call migratepages for process 1,

The kernel message is like this:

  kernel BUG at /src/linux-dev/mm/huge_memory.c:3096!
  invalid opcode: 0000 [#1] SMP
  Modules linked in: cfg80211 rfkill crc32c_intel ppdev serio_raw pcspkr virtio_balloon virtio_console parport_pc parport pvpanic acpi_cpufreq tpm_tis tpm i2c_piix4 virtio_blk virtio_net ata_generic pata_acpi floppy virtio_pci virtio_ring virtio
  CPU: 0 PID: 28863 Comm: migratepages Not tainted 4.6.0-v4.6-160602-0827-+ #2
  Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
  task: ffff880037320000 ti: ffff88007cdd0000 task.ti: ffff88007cdd0000
  RIP: 0010:[<ffffffff811f8e06>]  [<ffffffff811f8e06>] split_huge_page_to_list+0x496/0x590
  RSP: 0018:ffff88007cdd3b70  EFLAGS: 00010202
  RAX: 0000000000000001 RBX: ffff88007c7b88c0 RCX: 0000000000000000
  RDX: 0000000000000000 RSI: 0000000700000200 RDI: ffffea0003188000
  RBP: ffff88007cdd3bb8 R08: 0000000000000001 R09: 00003ffffffff000
  R10: ffff880000000000 R11: ffffc000001fffff R12: ffffea0003188000
  R13: ffffea0003188000 R14: 0000000000000000 R15: 0400000000000080
  FS:  00007f8ec241d740(0000) GS:ffff88007dc00000(0000) knlGS:0000000000000000             CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
  CR2: 00007f8ec1f3ed20 CR3: 000000003707b000 CR4: 00000000000006f0
  Stack:
   ffffffff8139ef6d ffffea00031c6280 ffff88011ffec000 0000000000000000
   0000700000400000 0000700000200000 ffff88007cdd3d08 ffff8800dbbe3008
   0400000000000080 ffff88007cdd3c20 ffffffff811dd0b1 ffff88007cdd3d68
  Call Trace:
   [<ffffffff8139ef6d>] ? list_del+0xd/0x30
   [<ffffffff811dd0b1>] queue_pages_pte_range+0x4d1/0x590
   [<ffffffff811ca1a4>] __walk_page_range+0x204/0x4e0
   [<ffffffff811ca4f1>] walk_page_range+0x71/0xf0
   [<ffffffff811db935>] queue_pages_range+0x75/0x90
   [<ffffffff811dcbe0>] ? queue_pages_hugetlb+0x190/0x190
   [<ffffffff811dca50>] ? new_node_page+0xc0/0xc0
   [<ffffffff811ddac0>] ? change_prot_numa+0x40/0x40
   [<ffffffff811dc001>] migrate_to_node+0x71/0xd0
   [<ffffffff811ddd73>] do_migrate_pages+0x1c3/0x210
   [<ffffffff811de0b1>] SyS_migrate_pages+0x261/0x290
   [<ffffffff816f53f2>] entry_SYSCALL_64_fastpath+0x1a/0xa4
  Code: e8 b0 87 fb ff 0f 0b 48 c7 c6 30 32 9f 81 e8 a2 87 fb ff 0f 0b 48 c7 c6 b8 46 9f 81 e8 94 87 fb ff 0f 0b 85 c0 0f 84 3e fd ff ff <0f> 0b 85 c0 0f 85 a6 00 00 00 48 8b 75 c0 4c 89 f7 41 be f0 ff
  RIP  [<ffffffff811f8e06>] split_huge_page_to_list+0x496/0x590
   RSP <ffff88007cdd3b70>

I'm not sure of the full scenario of the reproduction, but my debug showed that
split_huge_pmd_address(freeze=true) returned without running main code of pmd
splitting because pmd_present(*pmd) in precheck somehow returned 0.
If this happens, the subsequent try_to_unmap() fails and returns non-zero
(because page_mapcount() still > 0), and finally VM_BUG_ON() fires.
This patch tries to fix it by prechecking pmd state inside ptl.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
Diff from v3:
- removed obsolete comment
- rebased to v4.7-rc4-mmotm-2016-06-23-16-33

Diff from v2:
- don't use separate function

Diff from v1:
- passed page to __split_huge_pmd()
- dropped unnecessary !pmd_present check
- removed pmd_none check in split_huge_pmd_address_freeze because it's
  effectively done in __split_huge_pmd() with ptl.
---
 include/linux/huge_mm.h |  4 ++--
 mm/huge_memory.c        | 31 ++++++++++++-------------------
 2 files changed, 14 insertions(+), 21 deletions(-)

diff --git v4.7-rc4-mmotm-2016-06-23-16-33/include/linux/huge_mm.h v4.7-rc4-mmotm-2016-06-23-16-33_patched/include/linux/huge_mm.h
index eb81081..92ce91c 100644
--- v4.7-rc4-mmotm-2016-06-23-16-33/include/linux/huge_mm.h
+++ v4.7-rc4-mmotm-2016-06-23-16-33_patched/include/linux/huge_mm.h
@@ -98,7 +98,7 @@ static inline int split_huge_page(struct page *page)
 void deferred_split_huge_page(struct page *page);
 
 void __split_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
-		unsigned long address, bool freeze);
+		unsigned long address, bool freeze, struct page *page);
 
 #define split_huge_pmd(__vma, __pmd, __address)				\
 	do {								\
@@ -106,7 +106,7 @@ void __split_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 		if (pmd_trans_huge(*____pmd)				\
 					|| pmd_devmap(*____pmd))	\
 			__split_huge_pmd(__vma, __pmd, __address,	\
-						false);			\
+						false, NULL);		\
 	}  while (0)
 
 
diff --git v4.7-rc4-mmotm-2016-06-23-16-33/mm/huge_memory.c v4.7-rc4-mmotm-2016-06-23-16-33_patched/mm/huge_memory.c
index 848c16c..63f4d9c 100644
--- v4.7-rc4-mmotm-2016-06-23-16-33/mm/huge_memory.c
+++ v4.7-rc4-mmotm-2016-06-23-16-33_patched/mm/huge_memory.c
@@ -1633,7 +1633,7 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
 }
 
 void __split_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
-		unsigned long address, bool freeze)
+		unsigned long address, bool freeze, struct page *page)
 {
 	spinlock_t *ptl;
 	struct mm_struct *mm = vma->vm_mm;
@@ -1641,8 +1641,17 @@ void __split_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 
 	mmu_notifier_invalidate_range_start(mm, haddr, haddr + HPAGE_PMD_SIZE);
 	ptl = pmd_lock(mm, pmd);
+
+	/*
+	 * If caller asks to setup a migration entries, we need a page to check
+	 * pmd against. Otherwise we can end up replacing wrong page.
+	 */
+	VM_BUG_ON(freeze && !page);
+	if (page && page != pmd_page(*pmd))
+	        goto out;
+
 	if (pmd_trans_huge(*pmd)) {
-		struct page *page = pmd_page(*pmd);
+		page = pmd_page(*pmd);
 		if (PageMlocked(page))
 			clear_page_mlock(page);
 	} else if (!pmd_devmap(*pmd))
@@ -1669,24 +1678,8 @@ void split_huge_pmd_address(struct vm_area_struct *vma, unsigned long address,
 		return;
 
 	pmd = pmd_offset(pud, address);
-	if (!pmd_present(*pmd) || (!pmd_trans_huge(*pmd) && !pmd_devmap(*pmd)))
-		return;
 
-	/*
-	 * If caller asks to setup a migration entries, we need a page to check
-	 * pmd against. Otherwise we can end up replacing wrong page.
-	 */
-	VM_BUG_ON(freeze && !page);
-	if (page && page != pmd_page(*pmd))
-		return;
-
-	/*
-	 * Caller holds the mmap_sem write mode or the anon_vma lock,
-	 * so a huge pmd cannot materialize from under us (khugepaged
-	 * holds both the mmap_sem write mode and the anon_vma lock
-	 * write mode).
-	 */
-	__split_huge_pmd(vma, pmd, address, freeze);
+	__split_huge_pmd(vma, pmd, address, freeze, page);
 }
 
 void vma_adjust_trans_huge(struct vm_area_struct *vma,
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
