Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id D233F6B0005
	for <linux-mm@kvack.org>; Thu, 19 May 2016 18:40:32 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id 77so183579786pfz.3
        for <linux-mm@kvack.org>; Thu, 19 May 2016 15:40:32 -0700 (PDT)
Received: from mail-pf0-x22e.google.com (mail-pf0-x22e.google.com. [2607:f8b0:400e:c00::22e])
        by mx.google.com with ESMTPS id ad12si22855885pac.234.2016.05.19.15.40.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 May 2016 15:40:31 -0700 (PDT)
Received: by mail-pf0-x22e.google.com with SMTP id 206so34666944pfu.0
        for <linux-mm@kvack.org>; Thu, 19 May 2016 15:40:31 -0700 (PDT)
From: Yang Shi <yang.shi@linaro.org>
Subject: [v2 PATCH] mm: move page_ext_init after all struct pages are initialized
Date: Thu, 19 May 2016 15:13:26 -0700
Message-Id: <1463696006-31360-1-git-send-email-yang.shi@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, iamjoonsoo.kim@lge.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linaro-kernel@lists.linaro.org, yang.shi@linaro.org

When DEFERRED_STRUCT_PAGE_INIT is enabled, just a subset of memmap at boot
are initialized, then the rest are initialized in parallel by starting one-off
"pgdatinitX" kernel thread for each node X.

If page_ext_init is called before it, some pages will not have valid extension,
this may lead the below kernel oops when booting up kernel:

BUG: unable to handle kernel NULL pointer dereference at           (null)
IP: [<ffffffff8118d982>] free_pcppages_bulk+0x2d2/0x8d0
PGD 0
Oops: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
Modules linked in:
CPU: 11 PID: 106 Comm: pgdatinit1 Not tainted 4.6.0-rc5-next-20160427 #26
Hardware name: Intel Corporation S5520HC/S5520HC, BIOS S5500.86B.01.10.0025.030220091519 03/02/2009
task: ffff88017c080040 ti: ffff88017c084000 task.ti: ffff88017c084000
RIP: 0010:[<ffffffff8118d982>]  [<ffffffff8118d982>] free_pcppages_bulk+0x2d2/0x8d0
RSP: 0000:ffff88017c087c48  EFLAGS: 00010046
RAX: 0000000000000000 RBX: 0000000000000000 RCX: 0000000000000001
RDX: 0000000000000980 RSI: 0000000000000080 RDI: 0000000000660401
RBP: ffff88017c087cd0 R08: 0000000000000401 R09: 0000000000000009
R10: ffff88017c080040 R11: 000000000000000a R12: 0000000000000400
R13: ffffea0019810000 R14: ffffea0019810040 R15: ffff88066cfe6080
FS:  0000000000000000(0000) GS:ffff88066cd40000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 0000000000000000 CR3: 0000000002406000 CR4: 00000000000006e0
Stack:
 ffff88066cd5bbd8 ffff88066cfe6640 0000000000000000 0000000000000000
 0000001f0000001f ffff88066cd5bbe8 ffffea0019810000 000000008118f53e
 0000000000000009 0000000000000401 ffffffff0000000a 0000000000000001
Call Trace:
 [<ffffffff8118f602>] free_hot_cold_page+0x192/0x1d0
 [<ffffffff8118f69c>] __free_pages+0x5c/0x90
 [<ffffffff8262a676>] __free_pages_boot_core+0x11a/0x14e
 [<ffffffff8262a6fa>] deferred_free_range+0x50/0x62
 [<ffffffff8262aa46>] deferred_init_memmap+0x220/0x3c3
 [<ffffffff8262a826>] ? setup_per_cpu_pageset+0x35/0x35
 [<ffffffff8108b1f8>] kthread+0xf8/0x110
 [<ffffffff81c1b732>] ret_from_fork+0x22/0x40
 [<ffffffff8108b100>] ? kthread_create_on_node+0x200/0x200
Code: 49 89 d4 48 c1 e0 06 49 01 c5 e9 de fe ff ff 4c 89 f7 44 89 4d b8 4c 89 45 c0 44 89 5d c8 48 89 4d d0 e8 62 c7 07 00 48 8b 4d d0 <48> 8b 00 44 8b 5d c8 4c 8b 45 c0 44 8b 4d b8 a8 02 0f 84 05 ff
RIP  [<ffffffff8118d982>] free_pcppages_bulk+0x2d2/0x8d0
 RSP <ffff88017c087c48>
CR2: 0000000000000000

Move page_ext_init() after page_alloc_init_late() to make sure page extension
is setup for all pages.

CC: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Signed-off-by: Yang Shi <yang.shi@linaro.org>
---
Changelog v1 --> v2:
 Added bug description in the commit log per Andrew's comment

 init/main.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/init/main.c b/init/main.c
index b3c6e36..2075faf 100644
--- a/init/main.c
+++ b/init/main.c
@@ -606,7 +606,6 @@ asmlinkage __visible void __init start_kernel(void)
 		initrd_start = 0;
 	}
 #endif
-	page_ext_init();
 	debug_objects_mem_init();
 	kmemleak_init();
 	setup_per_cpu_pageset();
@@ -1004,6 +1003,8 @@ static noinline void __init kernel_init_freeable(void)
 	sched_init_smp();
 
 	page_alloc_init_late();
+	/* Initialize page ext after all struct pages are initializaed */
+	page_ext_init();
 
 	do_basic_setup();
 
-- 
2.0.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
