Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f43.google.com (mail-la0-f43.google.com [209.85.215.43])
	by kanga.kvack.org (Postfix) with ESMTP id 042E56B0266
	for <linux-mm@kvack.org>; Fri, 18 Sep 2015 11:43:38 -0400 (EDT)
Received: by lagj9 with SMTP id j9so33334169lag.2
        for <linux-mm@kvack.org>; Fri, 18 Sep 2015 08:43:37 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id vv3si6411554lbb.102.2015.09.18.08.43.36
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Sep 2015 08:43:36 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm] mm/khugepaged: fix scan not aborted on SCAN_EXCEED_SWAP_PTE
Date: Fri, 18 Sep 2015 18:43:23 +0300
Message-ID: <1442591003-4880-1-git-send-email-vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Ebru Akagunduz <ebru.akagunduz@gmail.com>, Rik van Riel <riel@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

This patch fixes a typo in khugepaged_scan_pmd(): instead of setting
"result" to SCAN_EXCEED_SWAP_PTE we set "ret". Setting "ret" results in
an attempt to collapse a huge page although we meant aborting the scan.
As a result, we can call khugepaged_find_target_node() with all entries
in the khugepaged_node_load array being zeros. The latter is not ready
for that and might return an offline node on such input. This leads to a
warning followed by kernel panic:

  WARNING: CPU: 1 PID: 40 at include/linux/gfp.h:314 khugepaged_alloc_page+0xd4/0xf0()
  CPU: 1 PID: 40 Comm: khugepaged Not tainted 4.3.0-rc1-mm1+ #102
   000000000000013a ffff88010ae77b58 ffffffff813270d4 ffffffff818cda31
   0000000000000000 ffff88010ae77b98 ffffffff8107c9f5 dead000000000100
   ffff88010ae77e70 0000000000c752da 0000000000000001 0000000000000000
  Call Trace:
   [<ffffffff813270d4>] dump_stack+0x48/0x64
   [<ffffffff8107c9f5>] warn_slowpath_common+0x95/0xe0
   [<ffffffff8107ca5a>] warn_slowpath_null+0x1a/0x20
   [<ffffffff811ec124>] khugepaged_alloc_page+0xd4/0xf0
   [<ffffffff811f15c8>] collapse_huge_page+0x58/0x550
   [<ffffffff810b38e6>] ? account_entity_dequeue+0xb6/0xd0
   [<ffffffff810b5289>] ? idle_balance+0x79/0x2b0
   [<ffffffff811f1f5e>] khugepaged_scan_pmd+0x49e/0x710
   [<ffffffff810e1f3a>] ? lock_timer_base+0x5a/0x80
   [<ffffffff810e1fbb>] ? try_to_del_timer_sync+0x5b/0x70
   [<ffffffff810e214c>] ? del_timer_sync+0x4c/0x60
   [<ffffffff8168242f>] ? schedule_timeout+0x11f/0x200
   [<ffffffff811f2330>] khugepaged_scan_mm_slot+0x160/0x2a0
   [<ffffffff811f255f>] khugepaged_do_scan+0xef/0x160
   [<ffffffff810bcdb0>] ? wait_woken+0x80/0x80
   [<ffffffff811f25d0>] ? khugepaged_do_scan+0x160/0x160
   [<ffffffff811f25f8>] khugepaged+0x28/0x80
   [<ffffffff8109ab1c>] kthread+0xcc/0xf0
   [<ffffffff810a667e>] ? schedule_tail+0x1e/0xc0
   [<ffffffff8109aa50>] ? kthread_freezable_should_stop+0x70/0x70
   [<ffffffff8168371f>] ret_from_fork+0x3f/0x70
   [<ffffffff8109aa50>] ? kthread_freezable_should_stop+0x70/0x70

  BUG: unable to handle kernel paging request at 0000000000014028
  IP: [<ffffffff81185eb2>] __alloc_pages_nodemask+0xc2/0x2c0
  PGD aaac7067 PUD aaac6067 PMD 0
  Oops: 0000 [#1] SMP
  CPU: 1 PID: 40 Comm: khugepaged Tainted: G        W       4.3.0-rc1-mm1+ #102
  task: ffff88010ae16400 ti: ffff88010ae74000 task.ti: ffff88010ae74000
  RIP: 0010:[<ffffffff81185eb2>]  [<ffffffff81185eb2>] __alloc_pages_nodemask+0xc2/0x2c0
  RSP: 0018:ffff88010ae77ad8  EFLAGS: 00010246
  RAX: 0000000000000000 RBX: 0000000000014020 RCX: 0000000000000014
  RDX: 0000000000000000 RSI: 0000000000000009 RDI: 0000000000c752da
  RBP: ffff88010ae77ba8 R08: 0000000000000000 R09: 0000000000000001
  R10: 0000000000000000 R11: 0000000000000297 R12: 0000000000000000
  R13: 0000000000000001 R14: 0000000000000000 R15: 0000000000c752da
  FS:  0000000000000000(0000) GS:ffff88010be40000(0000) knlGS:0000000000000000
  CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
  CR2: 0000000000014028 CR3: 00000000aaac4000 CR4: 00000000000006e0
  Stack:
   ffff88010ae77ae8 ffffffff810d0b3b ffff88010ae77b48 ffffffff81179e73
   0000000000000010 ffff88010ae77b58 ffff88010ae77b18 ffffffff811ec124
   ffff88010ae77b38 00000009a6e3aff4 0000000000000000 0000000000000000
  Call Trace:
   [<ffffffff810d0b3b>] ? vprintk_default+0x2b/0x40
   [<ffffffff81179e73>] ? printk+0x46/0x48
   [<ffffffff811ec124>] ? khugepaged_alloc_page+0xd4/0xf0
   [<ffffffff8107ca04>] ? warn_slowpath_common+0xa4/0xe0
   [<ffffffff811ec0cd>] khugepaged_alloc_page+0x7d/0xf0
   [<ffffffff811f15c8>] collapse_huge_page+0x58/0x550
   [<ffffffff810b38e6>] ? account_entity_dequeue+0xb6/0xd0
   [<ffffffff810b5289>] ? idle_balance+0x79/0x2b0
   [<ffffffff811f1f5e>] khugepaged_scan_pmd+0x49e/0x710
   [<ffffffff810e1f3a>] ? lock_timer_base+0x5a/0x80
   [<ffffffff810e1fbb>] ? try_to_del_timer_sync+0x5b/0x70
   [<ffffffff810e214c>] ? del_timer_sync+0x4c/0x60
   [<ffffffff8168242f>] ? schedule_timeout+0x11f/0x200
   [<ffffffff811f2330>] khugepaged_scan_mm_slot+0x160/0x2a0
   [<ffffffff811f255f>] khugepaged_do_scan+0xef/0x160
   [<ffffffff810bcdb0>] ? wait_woken+0x80/0x80
   [<ffffffff811f25d0>] ? khugepaged_do_scan+0x160/0x160
   [<ffffffff811f25f8>] khugepaged+0x28/0x80
   [<ffffffff8109ab1c>] kthread+0xcc/0xf0
   [<ffffffff810a667e>] ? schedule_tail+0x1e/0xc0
   [<ffffffff8109aa50>] ? kthread_freezable_should_stop+0x70/0x70
   [<ffffffff8168371f>] ret_from_fork+0x3f/0x70
   [<ffffffff8109aa50>] ? kthread_freezable_should_stop+0x70/0x70
  RIP  [<ffffffff81185eb2>] __alloc_pages_nodemask+0xc2/0x2c0
   RSP <ffff88010ae77ad8>
  CR2: 0000000000014028

Fixes: acc067d59a1f9 ("mm: make optimistic check for swapin readahead")
Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 mm/huge_memory.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 4b057abd8615..ffbe2b74f047 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2848,7 +2848,7 @@ static int khugepaged_scan_pmd(struct mm_struct *mm,
 			if (++unmapped <= khugepaged_max_ptes_swap) {
 				continue;
 			} else {
-				ret = SCAN_EXCEED_SWAP_PTE;
+				result = SCAN_EXCEED_SWAP_PTE;
 				goto out_unmap;
 			}
 		}
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
