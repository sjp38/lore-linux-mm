Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f49.google.com (mail-wg0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id A45A16B0095
	for <linux-mm@kvack.org>; Wed, 12 Mar 2014 06:36:07 -0400 (EDT)
Received: by mail-wg0-f49.google.com with SMTP id a1so6937634wgh.20
        for <linux-mm@kvack.org>; Wed, 12 Mar 2014 03:36:06 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s4si13377016wjq.83.2014.03.12.03.36.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 12 Mar 2014 03:36:05 -0700 (PDT)
Date: Wed, 12 Mar 2014 10:36:02 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH] mm: numa: Recheck for transhuge pages under lock during
 protection changes
Message-ID: <20140312103602.GN10663@suse.de>
References: <20140307140650.GA1931@suse.de>
 <20140307150923.GB1931@suse.de>
 <20140307182745.GD1931@suse.de>
 <20140311162845.GA30604@suse.de>
 <531F3F15.8050206@oracle.com>
 <531F4128.8020109@redhat.com>
 <531F48CC.303@oracle.com>
 <20140311180652.GM10663@suse.de>
 <531F616A.7060300@oracle.com>
 <20140311122859.fb6c1e772d82d9f4edd02f52@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20140311122859.fb6c1e772d82d9f4edd02f52@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Sasha Levin <sasha.levin@oracle.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, hhuang@redhat.com, knoel@redhat.com, aarcange@redhat.com, Davidlohr Bueso <davidlohr@hp.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Andrew, this should go with the patches 
mmnuma-reorganize-change_pmd_range.patch
mmnuma-reorganize-change_pmd_range-fix.patch
move-mmu-notifier-call-from-change_protection-to-change_pmd_range.patch
in mmotm please.

Thanks.

---8<---
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH] mm: numa: Recheck for transhuge pages under lock during protection changes

Sasha Levin reported the following bug using trinity

[  886.745765] kernel BUG at mm/mprotect.c:149!
[  886.746831] invalid opcode: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
[  886.748511] Dumping ftrace buffer:
[  886.749998]    (ftrace buffer empty)
[  886.750110] Modules linked in:
[  886.751396] CPU: 20 PID: 26219 Comm: trinity-c216 Tainted: G        W    3.14.0-rc5-next-20140305-sasha-00011-ge06f5f3-dirty #105
[  886.751396] task: ffff8800b6c80000 ti: ffff880228436000 task.ti: ffff880228436000
[  886.751396] RIP: 0010:[<ffffffff812aab33>]  [<ffffffff812aab33>] change_protection_range+0x3b3/0x500
[  886.751396] RSP: 0000:ffff880228437da8  EFLAGS: 00010282
[  886.751396] RAX: 8000000527c008e5 RBX: 00007f647916e000 RCX: 0000000000000000
[  886.751396] RDX: ffff8802ef488e40 RSI: 00007f6479000000 RDI: 8000000527c008e5
[  886.751396] RBP: ffff880228437e78 R08: 0000000000000000 R09: 0000000000000000
[  886.751396] R10: 0000000000000001 R11: 0000000000000000 R12: ffff8802ef488e40
[  886.751396] R13: 00007f6479000000 R14: 00007f647916e000 R15: 00007f646e34e000
[  886.751396] FS:  00007f64b28d4700(0000) GS:ffff88052ba00000(0000) knlGS:0000000000000000
[  886.751396] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[  886.751396] CR2: 00007f64aed83af8 CR3: 0000000206e52000 CR4: 00000000000006a0
[  886.751396] Stack:
[  886.751396]  ffff880200000001 ffffffff8447f152 ffff880228437dd8 ffff880228af3000
[  886.769142]  00007f646e34e000 00007f647916dfff 0000000000000000 00007f647916e000
[  886.769142]  ffff880206e527f0 00007f647916dfff 0000000000000000 0000000000000000
[  886.769142] Call Trace:
[  886.769142]  [<ffffffff8447f152>] ? preempt_count_sub+0xe2/0x120
[  886.769142]  [<ffffffff812aaca5>] change_protection+0x25/0x30
[  886.769142]  [<ffffffff812c3eeb>] change_prot_numa+0x1b/0x30
[  886.769142]  [<ffffffff8118df49>] task_numa_work+0x279/0x360
[  886.769142]  [<ffffffff8116c57e>] task_work_run+0xae/0xf0
[  886.769142]  [<ffffffff8106ffbe>] do_notify_resume+0x8e/0xe0
[  886.769142]  [<ffffffff8447a93b>] retint_signal+0x4d/0x92
[  886.769142] Code: 49 8b 3c 24 48 83 3d fc 2e ba 04 00 75 12 0f 0b 0f 1f 84 00 00 00 00 00 eb fe 66 0f 1f 44 00 00 48 89 f8 66 66 66 90 84 c0 79 0d <0f> 0b 0f 1f 00 eb fe 66 0f 1f 44 00 00 8b 4d 9c 44 8b 4d 98
+89
[  886.769142] RIP  [<ffffffff812aab33>] change_protection_range+0x3b3/0x500
[  886.769142]  RSP <ffff880228437da8>

The VM_BUG_ON was added by the patch "mm,numa: reorganize
change_pmd_range". The race existed without the patch but was just harder
to hit.

The problem is that a transhuge check is made without holding the PTL. It's
possible at the time of the check that a parallel fault clears the pmd
and inserts a new one which then triggers the VM_BUG_ON check.  This patch
removes the VM_BUG_ON but fixes the race by rechecking transhuge under the
PTL when marking page tables for NUMA hinting and bailing if a race occurred.
It is not a problem for calls to mprotect() as they hold mmap_sem for write.

Reported-by: Sasha Levin <sasha.levin@oracle.com>
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/mprotect.c | 14 +++++++++++++-
 1 file changed, 13 insertions(+), 1 deletion(-)

diff --git a/mm/mprotect.c b/mm/mprotect.c
index 2afc40e..72061a2 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -46,6 +46,17 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
 	unsigned long pages = 0;
 
 	pte = pte_offset_map_lock(mm, pmd, addr, &ptl);
+
+	/*
+	 * For a prot_numa update we only hold mmap_sem for read so there is a
+	 * potential race with faulting where a pmd was temporarily none so
+	 * recheck it under the lock and bail if we race
+	 */
+	if (prot_numa && unlikely(pmd_trans_huge(*pmd))) {
+		pte_unmap_unlock(pte, ptl);
+		return 0;
+	}
+
 	arch_enter_lazy_mmu_mode();
 	do {
 		oldpte = *pte;
@@ -141,12 +152,13 @@ static inline unsigned long change_pmd_range(struct vm_area_struct *vma,
 						pages += HPAGE_PMD_NR;
 						nr_huge_updates++;
 					}
+
+					/* huge pmd was handled */
 					continue;
 				}
 			}
 			/* fall through, the trans huge pmd just split */
 		}
-		VM_BUG_ON(pmd_trans_huge(*pmd));
 		this_pages = change_pte_range(vma, pmd, addr, next, newprot,
 				 dirty_accountable, prot_numa);
 		pages += this_pages;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
