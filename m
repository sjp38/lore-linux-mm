Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 210776B0033
	for <linux-mm@kvack.org>; Tue, 31 Jan 2017 16:33:49 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id d123so281071831pfd.0
        for <linux-mm@kvack.org>; Tue, 31 Jan 2017 13:33:49 -0800 (PST)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id a79si17078392pfc.236.2017.01.31.13.33.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 31 Jan 2017 13:33:48 -0800 (PST)
Subject: [PATCH] mm,
 dax: clear PMD or PUD size flags when in fall through path
From: Dave Jiang <dave.jiang@intel.com>
Date: Tue, 31 Jan 2017 14:33:47 -0700
Message-ID: <148589842696.5820.16078080610311444794.stgit@djiang5-desk3.ch.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mawilcox@microsoft.com, linux-nvdimm@lists.01.org, dave.hansen@linux.intel.com, linux-xfs@vger.kernel.org, linux-mm@kvack.org, kirill.shutemov@linux.intel.com, jack@suse.com, dan.j.williams@intel.com, linux-ext4@vger.kernel.org, ross.zwisler@linux.intel.com, vbabka@suse.cz

Ross reported that:
Running xfstests generic/030 with XFS + DAX gives me the following kernel BUG,
which I bisected to this commit: mm,fs,dax: Change ->pmd_fault to ->huge_fault

[  370.086205] ------------[ cut here ]------------
[  370.087182] kernel BUG at arch/x86/mm/fault.c:1038!
[  370.088336] invalid opcode: 0000 [#3] PREEMPT SMP
[  370.089073] Modules linked in: dax_pmem nd_pmem dax nd_btt nd_e820 libnvdimm
[  370.090212] CPU: 0 PID: 12415 Comm: xfs_io Tainted: G      D         4.10.0-rc5-mm1-00202-g7e90fc0 #10
[  370.091648] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.9.1-1.fc24 04/01/2014
[  370.092946] task: ffff8800ac4f8000 task.stack: ffffc9001148c000
[  370.093769] RIP: 0010:mm_fault_error+0x15e/0x190
[  370.094410] RSP: 0000:ffffc9001148fe60 EFLAGS: 00010246
[  370.095135] RAX: 0000000000000000 RBX: 0000000000000006 RCX: ffff8800ac4f8000
[  370.096107] RDX: 00007f111c8e6400 RSI: 0000000000000006 RDI: ffffc9001148ff58
[  370.097087] RBP: ffffc9001148fe88 R08: 0000000000000000 R09: ffff880510bd3300
[  370.098072] R10: ffff8800ac4f8000 R11: 0000000000000000 R12: 00007f111c8e6400
[  370.099057] R13: 00007f111c8e6400 R14: ffff880510bd3300 R15: 0000000000000055
[  370.100135] FS:  00007f111d95e700(0000) GS:ffff880514800000(0000) knlGS:0000000000000000
[  370.101238] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  370.102021] CR2: 00007f111c8e6400 CR3: 00000000add00000 CR4: 00000000001406f0
[  370.103189] Call Trace:
[  370.103537]  __do_page_fault+0x54e/0x590
[  370.104090]  trace_do_page_fault+0x58/0x2c0
[  370.104675]  do_async_page_fault+0x2c/0x90
[  370.105342]  async_page_fault+0x28/0x30
[  370.106044] RIP: 0033:0x405e9a
[  370.106470] RSP: 002b:00007fffb7f30590 EFLAGS: 00010287
[  370.107185] RAX: 00000000004e6400 RBX: 0000000000000057 RCX: 00000000004e7000
[  370.108155] RDX: 00007f111c400000 RSI: 00000000004e7000 RDI: 0000000001c35080
[  370.109157] RBP: 00000000004e6400 R08: 0000000000000014 R09: 1999999999999999
[  370.110158] R10: 00007f111d2dc200 R11: 0000000000000000 R12: 0000000001c32fc0
[  370.111165] R13: 0000000000000000 R14: 0000000000000c00 R15: 0000000000000005
[  370.112171] Code: 07 00 00 00 e8 a4 ee ff ff e9 11 ff ff ff 4c 89 ea 48 89 de 45 31 c0 31 c9 e8 8f f7 ff ff 48 83 c4 08 5b 41 5c 41 5d 41 5e 5d c3 <0f> 0b 41 8b 94 24 80 04 00 00 49 8d b4 24 b0 06 00 00 4c 89 e9
[  370.114823] RIP: mm_fault_error+0x15e/0x190 RSP: ffffc9001148fe60
[  370.115722] ---[ end trace 2ce10d930638254d ]---

It appears that there are 2 issues. First, the size bits used for vm_fault
needs to be shifted over. Otherwise, FAULT_FLAG_SIZE_PMD is clobbering
FAULT_FLAG_INSTRUCTION. Second issue, after create_huge_pmd() is being
called and is falling back to the pte fault handler, the FAULT_FLAG_SIZE_PMD
flag remains and that causes the dax fault handler to go towards the pmd
fault handler instead of the pte fault handler. Fixes are made for the pud
and pmd fall through paths.

Reported-by: Ross Zwisler <ross.zwisler@linux.intel.com>
Signed-off-by: Dave Jiang <dave.jiang@intel.com>
---
 include/linux/mm.h |    8 ++++----
 mm/memory.c        |    4 ++++
 2 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index f50e730..6194aeb 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -285,10 +285,10 @@ extern pgprot_t protection_map[16];
 #define FAULT_FLAG_REMOTE	0x80	/* faulting for non current tsk/mm */
 #define FAULT_FLAG_INSTRUCTION  0x100	/* The fault was during an instruction fetch */
 
-#define FAULT_FLAG_SIZE_MASK	0x700	/* Support up to 8-level page tables */
-#define FAULT_FLAG_SIZE_PTE	0x000	/* First level (eg 4k) */
-#define FAULT_FLAG_SIZE_PMD	0x100	/* Second level (eg 2MB) */
-#define FAULT_FLAG_SIZE_PUD	0x200	/* Third level (eg 1GB) */
+#define FAULT_FLAG_SIZE_MASK	0x7000	/* Support up to 8-level page tables */
+#define FAULT_FLAG_SIZE_PTE	0x0000	/* First level (eg 4k) */
+#define FAULT_FLAG_SIZE_PMD	0x1000	/* Second level (eg 2MB) */
+#define FAULT_FLAG_SIZE_PUD	0x2000	/* Third level (eg 1GB) */
 
 #define FAULT_FLAG_TRACE \
 	{ FAULT_FLAG_WRITE,		"WRITE" }, \
diff --git a/mm/memory.c b/mm/memory.c
index d465806..bdf1661 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3663,6 +3663,8 @@ static int __handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
 		ret = create_huge_pud(&vmf);
 		if (!(ret & VM_FAULT_FALLBACK))
 			return ret;
+		/* fall through path, remove PUD flag */
+		vmf.flags &= ~FAULT_FLAG_SIZE_PUD;
 	} else {
 		pud_t orig_pud = *vmf.pud;
 
@@ -3693,6 +3695,8 @@ static int __handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
 		ret = create_huge_pmd(&vmf);
 		if (!(ret & VM_FAULT_FALLBACK))
 			return ret;
+		/* fall through path, remove PMD flag */
+		vmf.flags &= ~FAULT_FLAG_SIZE_PMD;
 	} else {
 		pmd_t orig_pmd = *vmf.pmd;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
