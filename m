Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id F2F238E004D
	for <linux-mm@kvack.org>; Tue, 11 Dec 2018 03:46:20 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id o9so9363699pgv.19
        for <linux-mm@kvack.org>; Tue, 11 Dec 2018 00:46:20 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id d2si12797074pfe.159.2018.12.11.00.46.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Dec 2018 00:46:19 -0800 (PST)
From: Huang Ying <ying.huang@intel.com>
Subject: [PATCH 1/2] swap: Fix general protection fault when swapoff
Date: Tue, 11 Dec 2018 16:46:08 +0800
Message-Id: <20181211084609.19553-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, Vineeth Remanan Pillai <vpillai@digitalocean.com>, Kelley Nielsen <kelleynnn@gmail.com>, Rik van Riel <riel@surriel.com>, Matthew Wilcox <willy@infradead.org>, Hugh Dickins <hughd@google.com>

When VMA based swap readahead is used, which is default if all swap
devices are SSD, swapoff will trigger general protection fault as
follow, because vmf->pmd isn't initialized when calling
swapin_readahead().  This fix could be folded into the patch: mm,
swap: rid swapoff of quadratic complexity in -mm patchset.

general protection fault: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
CPU: 3 PID: 352 Comm: swapoff Not tainted 4.20.0-rc5-mm1-kvm+ #535
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.11.0-1.fc28 04/01/2014
RIP: 0010:swapin_readahead+0xb7/0x39b
Code: ff 01 00 00 40 f6 c7 80 49 0f 45 d0 48 21 d7 48 ba 00 00 00 00 80 88 ff ff 48 8d 14 f2 48 01 d7 48 ba ff ff ff ff ff ff ff ef <48> 39 17 0f 87 5d 01 00 00 49 8b 95 b0 00 00 00 48 85 d2 75 05 ba
RSP: 0018:ffffc900004c3ca0 EFLAGS: 00010207
RAX: 000055de5d252000 RBX: 000000055de5d252 RCX: 0000000000000003
RDX: efffffffffffffff RSI: 0000000000000052 RDI: 000f0bc11c600290
RBP: ffffc900004c3d30 R08: 000fffffffe00000 R09: ffffc900004c3ea0
R10: ffffc900004c3d50 R11: 0000000000000002 R12: ffffc900004c3da8
R13: ffff88803b71d780 R14: 0000000000000001 R15: ffff88803b71d780
FS:  00007f87c20e02c0(0000) GS:ffff88803e800000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 000055a439825398 CR3: 000000003b49a004 CR4: 0000000000360ea0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
Call Trace:
 ? list_add_tail_rcu+0x19/0x31
 ? __lock_acquire+0xd61/0xe1c
 ? find_held_lock+0x2b/0x6e
 ? unuse_pte_range+0xe9/0x429
 unuse_pte_range+0xe9/0x429
 ? find_held_lock+0x2b/0x6e
 ? __lock_is_held+0x40/0x71
 try_to_unuse+0x311/0x54b
 __do_sys_swapoff+0x254/0x625
 ? lockdep_hardirqs_off+0x29/0x86
 ? do_syscall_64+0x12/0x65
 do_syscall_64+0x57/0x65
 entry_SYSCALL_64_after_hwframe+0x49/0xbe

Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
Cc: Vineeth Remanan Pillai <vpillai@digitalocean.com>
Cc: Kelley Nielsen <kelleynnn@gmail.com>
Cc: Rik van Riel <riel@surriel.com>
Cc: Matthew Wilcox <willy@infradead.org>
Cc: Hugh Dickins <hughd@google.com>
---
 mm/swapfile.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/swapfile.c b/mm/swapfile.c
index 9ca162cc45dc..7464d0a92869 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -1904,6 +1904,7 @@ static int unuse_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
 		swap_map = &si->swap_map[offset];
 		vmf.vma = vma;
 		vmf.address = addr;
+		vmf.pmd = pmd;
 		page = swapin_readahead(entry, GFP_HIGHUSER_MOVABLE, &vmf);
 		if (!page) {
 			if (*swap_map == 0 || *swap_map == SWAP_MAP_BAD)
-- 
2.18.1
