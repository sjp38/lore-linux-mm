Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id 39ACD6B0031
	for <linux-mm@kvack.org>; Fri,  4 Apr 2014 12:13:28 -0400 (EDT)
Received: by mail-wi0-f171.google.com with SMTP id q5so1618397wiv.4
        for <linux-mm@kvack.org>; Fri, 04 Apr 2014 09:13:27 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id ge12si1109343wic.74.2014.04.04.09.13.24
        for <linux-mm@kvack.org>;
        Fri, 04 Apr 2014 09:13:26 -0700 (PDT)
Date: Fri, 04 Apr 2014 12:13:15 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <533eda26.0cbdb40a.0382.ffffef9dSMTPIN_ADDED_BROKEN@mx.google.com>
In-Reply-To: <533D6D66.7030402@oracle.com>
References: <533D6D66.7030402@oracle.com>
Subject: [PATCH -mm] mm/pagewalk.c: move pte null check (Re: mm: BUG in
 __phys_addr called from __walk_page_range)
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: sasha.levin@oracle.com
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org

Hi Sasha,

On Thu, Apr 03, 2014 at 10:17:10AM -0400, Sasha Levin wrote:
> Hi all,
> 
> While fuzzing with trinity inside a KVM tools guest running the latest
> -next kernel I've stumbled on the following:
> 
> [  942.869226] kernel BUG at arch/x86/mm/physaddr.c:26!
> [  942.871710] invalid opcode: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
> [  942.871710] Dumping ftrace buffer:
> [  942.871710]    (ftrace buffer empty)
> [  942.871710] Modules linked in:
> [  942.871710] CPU: 16 PID: 17165 Comm: trinity-c55 Tainted: G        W     3.14.0-next-20140402-sasha-00013-g0cfaf7e-dirty #367
> [  942.871710] task: ffff8801de603000 ti: ffff8801e7b4c000 task.ti: ffff8801e7b4c000
> [  942.871710] RIP: __phys_addr (arch/x86/mm/physaddr.c:26 (discriminator 1))
> [  942.871710] RSP: 0000:ffff8801e7b4daf8  EFLAGS: 00010287
> [  942.871710] RAX: 0000780000000000 RBX: 00007f11fb000000 RCX: 0000000000000009
> [  942.871710] RDX: 0000000080000000 RSI: 00007f11fae00000 RDI: 0000000000000000
> [  942.871710] RBP: ffff8801e7b4daf8 R08: 0000000000000000 R09: 0000000008640070
> [  942.871710] R10: 00007f11fae00000 R11: 00007f123ae00000 R12: ffffffffb54b2140
> [  942.871710] R13: 0000000000200000 R14: 00007f11fae00000 R15: ffff8801e7b4dc00
> [  942.871710] FS:  00007f123eb21700(0000) GS:ffff88046cc00000(0000) knlGS:0000000000000000
> [  942.871710] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> [  942.871710] CR2: 0000000000000000 CR3: 00000001de6bc000 CR4: 00000000000006a0
> [  942.871710] DR0: 0000000000696000 DR1: 0000000000696000 DR2: 0000000000000000
> [  942.871710] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 000000000057060a
> [  942.871710] Stack:
> [  942.871710]  ffff8801e7b4db98 ffffffffae2c1651 ffff8801e7b4db38 0000000000000000
> [  942.871710]  ffff8801debf40b0 0000000040000000 ffff880767bb4000 00007f11fadfffff
> [  942.871710]  00007f11fadfffff 000000003fffffff 00007f11fae00000 ffff8801eb8c7000
> [  942.871710] Call Trace:
> [  942.871710] __walk_page_range (include/linux/mm.h:1525 include/linux/mm.h:1530 include/linux/hugetlb.h:403 include/linux/hugetlb.h:451 mm/pagewalk.c:196 mm/pagewalk.c:254)
> [  942.871710] walk_page_range (mm/pagewalk.c:333)
> [  942.871710] queue_pages_range (mm/mempolicy.c:653)
> [  942.871710] ? queue_pages_hugetlb (mm/mempolicy.c:492)
> [  942.871710] ? queue_pages_range (mm/mempolicy.c:521)
> [  942.871710] ? change_prot_numa (mm/mempolicy.c:588)
> [  942.871710] migrate_to_node (mm/mempolicy.c:988)
> [  942.871710] ? preempt_count_sub (kernel/sched/core.c:2527)
> [  942.871710] do_migrate_pages (mm/mempolicy.c:1095)
> [  942.871710] SYSC_migrate_pages (mm/mempolicy.c:1445)
> [  942.871710] ? SYSC_migrate_pages (include/linux/rcupdate.h:800 mm/mempolicy.c:1391)
> [  942.871710] SyS_migrate_pages (mm/mempolicy.c:1365)
> [  942.871710] ia32_do_call (arch/x86/ia32/ia32entry.S:430)
> [  942.871710] Code: 0f 0b 0f 1f 44 00 00 48 b8 00 00 00 00 00 78 00 00 48 01 f8 48 39 c2 72 12 0f b6 0d 10 0f fe 05 48 89 c2 48 d3 ea 48 85 d2 74 0c <0f> 0b 66 2e 0f 1f 84 00 00 00 00 00 5d c3 66 2e 0f 1f 84 00 00
> [  942.871710] RIP __phys_addr (arch/x86/mm/physaddr.c:26 (discriminator 1))
> [  942.871710]  RSP <ffff8801e7b4daf8>

Thanks for reporting. this bug shows that huge_pte_offset() returned NULL
and we tried to take page table lock of the NULL entry. This is a bug in
my patch and the following should fix it.

Thanks,
Naoya
---
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Date: Fri, 4 Apr 2014 11:37:57 -0400
Subject: [PATCH -mm] mm/pagewalk.c: move pte null check

huge_pte_offset() can return NULL, so we need check it before trying to
take page table lock to avoid a crash.

This patch would be fold into "pagewalk: update page table walker core"
in latest linux-mm.

Reported-by: Sasha Levin <sasha.levin@oracle.com>
Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 mm/pagewalk.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/mm/pagewalk.c b/mm/pagewalk.c
index a834f4deb527..b2a075ffb96e 100644
--- a/mm/pagewalk.c
+++ b/mm/pagewalk.c
@@ -193,12 +193,14 @@ static int walk_hugetlb_range(unsigned long addr, unsigned long end,
 	do {
 		next = hugetlb_entry_end(h, addr, end);
 		pte = huge_pte_offset(walk->mm, addr & hmask);
+		if (!pte)
+			continue;
 		ptl = huge_pte_lock(h, mm, pte);
 		/*
 		 * Callers should have their own way to handle swap entries
 		 * in walk->hugetlb_entry().
 		 */
-		if (pte && walk->hugetlb_entry)
+		if (walk->hugetlb_entry)
 			err = walk->hugetlb_entry(pte, addr, next, walk);
 		spin_unlock(ptl);
 		if (err)
-- 
1.9.0




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
