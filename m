Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f52.google.com (mail-la0-f52.google.com [209.85.215.52])
	by kanga.kvack.org (Postfix) with ESMTP id E07676B0032
	for <linux-mm@kvack.org>; Mon, 26 Jan 2015 09:52:18 -0500 (EST)
Received: by mail-la0-f52.google.com with SMTP id ge10so8030668lab.11
        for <linux-mm@kvack.org>; Mon, 26 Jan 2015 06:52:18 -0800 (PST)
Received: from forward-corp1m.cmail.yandex.net (forward-corp1m.cmail.yandex.net. [5.255.216.100])
        by mx.google.com with ESMTPS id e1si9156337laa.119.2015.01.26.06.52.16
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Jan 2015 06:52:17 -0800 (PST)
Subject: [PATCH] proc/pagemap: walk page tables under pte lock
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Date: Mon, 26 Jan 2015 17:52:14 +0300
Message-ID: <20150126145214.11053.5670.stgit@buzz>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: Andrey Ryabinin <a.ryabinin@samsung.com>, Stable <stable@vger.kernel.org>, Cyrill Gorcunov <gorcunov@openvz.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Peter Feiner <pfeiner@google.com>

Lockless access to pte in pagemap_pte_range() might race with page migration
and trigger BUG_ON(!PageLocked()) in migration_entry_to_page():

CPU A (pagemap)                           CPU B (migration)
                                          lock_page()
                                          try_to_unmap(page, TTU_MIGRATION...)
                                               make_migration_entry()
                                               set_pte_at()
<read *pte>
pte_to_pagemap_entry()
                                          remove_migration_ptes()
                                          unlock_page()
    if(is_migration_entry())
        migration_entry_to_page()
            BUG_ON(!PageLocked(page))

Also lockless read might be non-atomic if pte is larger than wordsize.
Other pte walkers (smaps, numa_maps, clear_refs) already lock ptes.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Reported-by: Andrey Ryabinin <a.ryabinin@samsung.com>
Fixes: 052fb0d635df ("proc: report file/anon bit in /proc/pid/pagemap")
Cc: Stable <stable@vger.kernel.org> (v3.5+)

---

------------[ cut here ]------------
kernel BUG at ../include/linux/swapops.h:131!
invalid opcode: 0000 [#1] PREEMPT SMP
Modules linked in:
CPU: 0 PID: 702 Comm: a.out Not tainted 3.19.0-rc1+ #16
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS
rel-1.7.5-0-ge51488c-20140602_164612-nilsson.home.kraxel.org
04/01/2014
task: ffff880001dc0dc0 ti: ffff88003dbd0000 task.ti: ffff88003dbd0000
RIP: pagemap_pte_range (include/linux/swapops.h:131 fs/proc/task_mmu.c:1136)
RSP: 0018:ffff88003dbd3d08  EFLAGS: 00010246
RAX: ffffea0000492b00 RBX: ffff88003dbd3e60 RCX: ffff880013bbe878
RDX: 0000000000000000 RSI: 000000000000001f RDI: 3e00000000000000
RBP: ffff88003dbd3d78 R08: 000000000024959f R09: ffff880001f5d000
R10: 0000000000000000 R11: 007fffffffffffff R12: 00007f6662000000
R13: ffff880001f5d000 R14: 00007f6661e8f000 R15: 0600000000000000
FS:  00007f666381d700(0000) GS:ffff88003fc00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00007f666333a520 CR3: 0000000013b7f000 CR4: 00000000000407b0
Stack:
0000000000000000 0000000062000000 ffff88003dbd3e78 ffff880013bbe878
007fffffffffffff 000000000003f65d ffffffff810d3710 0000000000000010
ffff88003dbd3d68 ffff88003dbd3e78 00007f6662000000 00007f6661e62000
Call Trace:
? find_vma (mm/mmap.c:2046)
walk_page_range (mm/pagewalk.c:51 mm/pagewalk.c:92 mm/pagewalk.c:241)
pagemap_read (fs/proc/task_mmu.c:1297)
? pid_maps_open (fs/proc/task_mmu.c:1068)
? m_stop (kernel/module.c:621)
__vfs_read (fs/read_write.c:430)
vfs_read (fs/read_write.c:455)
SyS_pread64 (fs/read_write.c:619 fs/read_write.c:606)
system_call_fastpath (arch/x86/kernel/entry_64.S:423)
Code: a0 4c 89 f6 48 8b 78 30 e8 a1 10 f9 ff 48 8b 4d b8 49 89 c4 e9
6d fc ff ff 0f 1f 44 00 00 49 39 ce 73 17 48 89 cf e9 7b fc ff ff <0f>
0b 4c 89 c7 e8 a9 bc f9 ff e9 ea fb ff ff 44 8b 55 9c 44 89
All code
========
   0:   a0 4c 89 f6 48 8b 78    movabs 0xe830788b48f6894c,%al
   7:   30 e8
   9:   a1 10 f9 ff 48 8b 4d    movabs 0x49b84d8b48fff910,%eax
  10:   b8 49
  12:   89 c4                   mov    %eax,%esp
  14:   e9 6d fc ff ff          jmpq   0xfffffffffffffc86
  19:   0f 1f 44 00 00          nopl   0x0(%rax,%rax,1)
  1e:   49 39 ce                cmp    %rcx,%r14
  21:   73 17                   jae    0x3a
  23:   48 89 cf                mov    %rcx,%rdi
  26:   e9 7b fc ff ff          jmpq   0xfffffffffffffca6
  2b:*  0f 0b                   ud2             <-- trapping instruction
  2d:   4c 89 c7                mov    %r8,%rdi
  30:   e8 a9 bc f9 ff          callq  0xfffffffffff9bcde
  35:   e9 ea fb ff ff          jmpq   0xfffffffffffffc24
  3a:   44 8b 55 9c             mov    -0x64(%rbp),%r10d
  3e:   44                      rex.R
  3f:   89                      .byte 0x89

Code starting with the faulting instruction
===========================================
   0:   0f 0b                   ud2
   2:   4c 89 c7                mov    %r8,%rdi
   5:   e8 a9 bc f9 ff          callq  0xfffffffffff9bcb3
   a:   e9 ea fb ff ff          jmpq   0xfffffffffffffbf9
   f:   44 8b 55 9c             mov    -0x64(%rbp),%r10d
  13:   44                      rex.R
  14:   89                      .byte 0x89
RIP pagemap_pte_range (include/linux/swapops.h:131 fs/proc/task_mmu.c:1136)
RSP <ffff88003dbd3d08>
------------[ cut here ]------------
---
 fs/proc/task_mmu.c |   14 +++++++++-----
 1 file changed, 9 insertions(+), 5 deletions(-)

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 2464367..ff65557 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -1070,7 +1070,7 @@ static int pagemap_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
 	struct vm_area_struct *vma;
 	struct pagemapread *pm = walk->private;
 	spinlock_t *ptl;
-	pte_t *pte;
+	pte_t *pte, *orig_pte;
 	int err = 0;
 
 	/* find the first VMA at or above 'addr' */
@@ -1131,15 +1131,19 @@ static int pagemap_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
 		BUG_ON(is_vm_hugetlb_page(vma));
 
 		/* Addresses in the VMA. */
-		for (; addr < min(end, vma->vm_end); addr += PAGE_SIZE) {
+		orig_pte = pte = pte_offset_map_lock(walk->mm, pmd, addr, &ptl);
+		for (; addr < min(end, vma->vm_end); pte++, addr += PAGE_SIZE) {
 			pagemap_entry_t pme;
-			pte = pte_offset_map(pmd, addr);
+
 			pte_to_pagemap_entry(&pme, pm, vma, addr, *pte);
-			pte_unmap(pte);
 			err = add_to_pagemap(addr, &pme, pm);
 			if (err)
-				return err;
+				break;
 		}
+		pte_unmap_unlock(orig_pte, ptl);
+
+		if (err)
+			return err;
 
 		if (addr == end)
 			break;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
