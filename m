Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 0F7836B0032
	for <linux-mm@kvack.org>; Tue, 17 Feb 2015 00:25:11 -0500 (EST)
Received: by paceu11 with SMTP id eu11so3642799pac.10
        for <linux-mm@kvack.org>; Mon, 16 Feb 2015 21:25:10 -0800 (PST)
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com. [209.85.220.49])
        by mx.google.com with ESMTPS id z3si1161108pas.111.2015.02.16.21.25.10
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Feb 2015 21:25:10 -0800 (PST)
Received: by paceu11 with SMTP id eu11so3642736pac.10
        for <linux-mm@kvack.org>; Mon, 16 Feb 2015 21:25:10 -0800 (PST)
From: Joonsoo Kim <js1304@gmail.com>
Subject: [PATCH] mm/memcontrol: fix NULL pointer dereference when use_hierarchy is 0
Date: Tue, 17 Feb 2015 14:24:59 +0900
Message-Id: <1424150699-5395-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

It can be possible to return NULL in parent_mem_cgroup()
if use_hierarchy is 0. So, we need to check NULL in the loop on
mem_cgroup_low(). Without it, following NULL pointer dereference happens.

[   33.607531] BUG: unable to handle kernel NULL pointer dereference at 00000000000000b0
[   33.608008] IP: [<ffffffff811dcf60>] mem_cgroup_low+0x40/0x90
[   33.608008] PGD 1d893067 PUD 1cf41067 PMD 0
[   33.608008] Oops: 0000 [#12] SMP
[   33.608008] Modules linked in:
[   33.608008] CPU: 1 PID: 3936 Comm: as Tainted: G      D         3.19.0-next-20150216 #156
[   33.608008] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
[   33.608008] task: ffff88001d9c8000 ti: ffff88000cb14000 task.ti: ffff88000cb14000
[   33.608008] RIP: 0010:[<ffffffff811dcf60>]  [<ffffffff811dcf60>] mem_cgroup_low+0x40/0x90
[   33.608008] RSP: 0000:ffff88000cb17a88  EFLAGS: 00010286
[   33.608008] RAX: 0000000000000000 RBX: ffff88000cb17bc0 RCX: 0000000000000000
[   33.608008] RDX: ffff88001f491400 RSI: 0000000000000000 RDI: 0000000000000000
[   33.608008] RBP: ffff88000cb17a88 R08: 0000000000000160 R09: 0000000000000000
[   33.608008] R10: 0000000000000000 R11: 0000000002b8c101 R12: 0000000000000000
[   33.608008] R13: 0000000000000000 R14: ffff88001fff9e08 R15: ffff88001da95800
[   33.608008] FS:  00002b7a12715380(0000) GS:ffff88001fa40000(0000) knlGS:0000000000000000
[   33.608008] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   33.608008] CR2: 00000000000000b0 CR3: 000000000762f000 CR4: 00000000000007e0
[   33.608008] Stack:
[   33.608008]  ffff88000cb17b18 ffffffff811838ec ffff88000cb17cd8 0000000000000000
[   33.608008]  0000000000000000 0001000000000000 000280da00000000 ffff88001fff8780
[   33.608008]  ffff88000cb17af8 ffffffff810e1d7e ffff88001fff8780 000000030000000c
[   33.608008] Call Trace:
[   33.608008]  [<ffffffff811838ec>] shrink_zone+0xac/0x2d0
[   33.608008]  [<ffffffff810e1d7e>] ? ktime_get+0x3e/0xa0
[   33.608008]  [<ffffffff81183e94>] do_try_to_free_pages+0x174/0x440
[   33.608008]  [<ffffffff8117f1a8>] ? throttle_direct_reclaim+0x98/0x250
[   33.608008]  [<ffffffff8118421a>] try_to_free_pages+0xba/0x150
[   33.608008]  [<ffffffff81176d10>] __alloc_pages_nodemask+0x5a0/0x950
[   33.608008]  [<ffffffff811c09ff>] alloc_pages_vma+0xaf/0x200
[   33.608008]  [<ffffffff811a0717>] handle_mm_fault+0x1287/0x17e0
[   33.608008]  [<ffffffff81059e9e>] ? kvm_clock_read+0x1e/0x20
[   33.608008]  [<ffffffff81059e9e>] ? kvm_clock_read+0x1e/0x20
[   33.608008]  [<ffffffff8101e6a9>] ? sched_clock+0x9/0x10
[   33.608008]  [<ffffffff810605f1>] __do_page_fault+0x191/0x440
[   33.608008]  [<ffffffff81060955>] trace_do_page_fault+0x45/0x100
[   33.608008]  [<ffffffff8105968e>] do_async_page_fault+0x1e/0xd0
[   33.608008]  [<ffffffff8176f628>] async_page_fault+0x28/0x30
[   33.608008] Code: 48 8b 15 cc 21 b4 00 48 39 d6 74 53 48 8b 8e b0 00 00 00 48 39 8e 28 01 00 00 72 43 31 c9 48 39 fe 75 1d eb 35 66 0f 1f 44 00 00 <48> 8b 86 b0 00 00 00 48 39 86 28 01 00 00 72 30 48 39 f7 74 1a
[   33.608008] RIP  [<ffffffff811dcf60>] mem_cgroup_low+0x40/0x90
[   33.608008]  RSP <ffff88000cb17a88>
[   33.608008] CR2: 00000000000000b0
[   33.608008] BUG: unable to handle kernel [   33.653499] ---[ end trace e264a32717ffda51 ]---

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/memcontrol.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index d18d3a6..507cfea 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -5431,6 +5431,8 @@ bool mem_cgroup_low(struct mem_cgroup *root, struct mem_cgroup *memcg)
 
 	while (memcg != root) {
 		memcg = parent_mem_cgroup(memcg);
+		if (!memcg)
+			break;
 
 		if (memcg == root_mem_cgroup)
 			break;
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
