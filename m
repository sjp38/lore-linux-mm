Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id DA04A6B0033
	for <linux-mm@kvack.org>; Tue,  9 Jan 2018 10:39:23 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id g1so7691877wmd.0
        for <linux-mm@kvack.org>; Tue, 09 Jan 2018 07:39:23 -0800 (PST)
Received: from techadventures.net (techadventures.net. [62.201.165.239])
        by mx.google.com with ESMTP id u205si9543019wmu.15.2018.01.09.07.39.21
        for <linux-mm@kvack.org>;
        Tue, 09 Jan 2018 07:39:22 -0800 (PST)
Date: Tue, 9 Jan 2018 16:39:21 +0100
From: Oscar Salvador <osalvador@techadventures.net>
Subject: [PATCH] mm/page_owner: Remove drain_all_pages from
 init_early_allocated_pages
Message-ID: <20180109153921.GA13070@techadventures.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: vbabka@suse.cz, mhocko@suse.com, akpm@linux-foundation.org, ayush.m@samsung.com

When setting page_owner = on, the following warning can be seen in the boot log:

 WARNING: CPU: 0 PID: 0 at mm/page_alloc.c:2537 drain_all_pages+0x171/0x1a0
 Modules linked in:
 CPU: 0 PID: 0 Comm: swapper/0 Not tainted 4.15.0-rc7-next-20180109-1-default+ #7
 Hardware name: Dell Inc. Latitude E7470/0T6HHJ, BIOS 1.11.3 11/09/2016
 RIP: 0010:drain_all_pages+0x171/0x1a0
 RSP: 0000:ffffffff82003ea8 EFLAGS: 00010246
 RAX: 000000000000000f RBX: ffffffffffffffff RCX: ffffffff8205b388
 RDX: 0000000000000001 RSI: 0000000000000096 RDI: 0000000000000202
 RBP: 0000000000000000 R08: 0000000000000000 R09: 00000000000000af
 R10: 0000000000000004 R11: 00000000000000ae R12: ffff88024dfdcec0
 R13: ffffffff82530740 R14: 0000000000000000 R15: 00000000a8831448
 FS:  0000000000000000(0000) GS:ffff88024dc00000(0000) knlGS:0000000000000000
 CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
 CR2: ffff88024dfff000 CR3: 000000000200a001 CR4: 00000000000606b0
 DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
 DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
 Call Trace:
  init_page_owner+0x4e/0x260
  start_kernel+0x3e6/0x4a6
  ? set_init_arg+0x55/0x55
  secondary_startup_64+0xa5/0xb0
 Code: c5 ed ff 89 df 48 c7 c6 20 3b 71 82 e8 f9 4b 52 00 3b 05 d7 0b f8 00 89 c3 72 d5 5b 5d 41 5
 ---[ end trace 45da7f0cb4aef07b ]---

This warning is showed because we are calling drain_all_pages() in
init_early_allocated_pages(), but mm_percpu_wq is not up yet,
it is being set up later on in kernel_init_freeable() -> init_mm_internals().

Signed-off-by: Oscar Salvador <osalvador@techadventures.net>
---
 mm/page_owner.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/mm/page_owner.c b/mm/page_owner.c
index 8602fb41b293..69f83fc763bb 100644
--- a/mm/page_owner.c
+++ b/mm/page_owner.c
@@ -616,7 +616,6 @@ static void init_early_allocated_pages(void)
 {
 	pg_data_t *pgdat;
 
-	drain_all_pages(NULL);
 	for_each_online_pgdat(pgdat)
 		init_zones_in_node(pgdat);
 }
-- 
2.13.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
