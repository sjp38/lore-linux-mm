Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 1C2266B02BC
	for <linux-mm@kvack.org>; Sun, 27 Dec 2015 18:34:12 -0500 (EST)
Received: by mail-pa0-f46.google.com with SMTP id cy9so101500642pac.0
        for <linux-mm@kvack.org>; Sun, 27 Dec 2015 15:34:12 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTPS id x21si1981893pfi.99.2015.12.27.15.34.10
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sun, 27 Dec 2015 15:34:11 -0800 (PST)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH 2/2] virtio_balloon: fix race between migration and ballooning
Date: Mon, 28 Dec 2015 08:35:13 +0900
Message-Id: <1451259313-26353-2-git-send-email-minchan@kernel.org>
In-Reply-To: <1451259313-26353-1-git-send-email-minchan@kernel.org>
References: <1451259313-26353-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Michael S. Tsirkin" <mst@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, Konstantin Khlebnikov <koct9i@gmail.com>, Rafael Aquini <aquini@redhat.com>, Minchan Kim <minchan@kernel.org>, stable@vger.kernel.org

In balloon_page_dequeue, pages_lock should cover the loop
(ie, list_for_each_entry_safe). Otherwise, the cursor page could
be isolated by compaction and then list_del by isolation could
poison the page->lru.{prev,next} so the loop finally could
access wrong address like this. This patch fixes the bug.

general protection fault: 0000 [#1] SMP
Dumping ftrace buffer:
   (ftrace buffer empty)
Modules linked in:
CPU: 2 PID: 82 Comm: vballoon Not tainted 4.4.0-rc5-mm1-access_bit+ #1906
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
task: ffff8800a7ff0000 ti: ffff8800a7fec000 task.ti: ffff8800a7fec000
RIP: 0010:[<ffffffff8115e754>]  [<ffffffff8115e754>] balloon_page_dequeue+0x54/0x130
RSP: 0018:ffff8800a7fefdc0  EFLAGS: 00010246
RAX: ffff88013fff9a70 RBX: ffffea000056fe00 RCX: 0000000000002b7d
RDX: ffff88013fff9a70 RSI: ffffea000056fe00 RDI: ffff88013fff9a68
RBP: ffff8800a7fefde8 R08: ffffea000056fda0 R09: 0000000000000000
R10: ffff8800a7fefd90 R11: 0000000000000001 R12: dead0000000000e0
R13: ffffea000056fe20 R14: ffff880138809070 R15: ffff880138809060
FS:  0000000000000000(0000) GS:ffff88013fc40000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 00007f229c10e000 CR3: 00000000b8b53000 CR4: 00000000000006a0
Stack:
 0000000000000100 ffff880138809088 ffff880138809000 ffff880138809060
 0000000000000046 ffff8800a7fefe28 ffffffff812c86d3 ffff880138809020
 ffff880138809000 fffffffffff91900 0000000000000100 ffff880138809060
Call Trace:
 [<ffffffff812c86d3>] leak_balloon+0x93/0x1a0
 [<ffffffff812c8bc7>] balloon+0x217/0x2a0
 [<ffffffff8143739e>] ? __schedule+0x31e/0x8b0
 [<ffffffff81078160>] ? abort_exclusive_wait+0xb0/0xb0
 [<ffffffff812c89b0>] ? update_balloon_stats+0xf0/0xf0
 [<ffffffff8105b6e9>] kthread+0xc9/0xe0
 [<ffffffff8105b620>] ? kthread_park+0x60/0x60
 [<ffffffff8143b4af>] ret_from_fork+0x3f/0x70
 [<ffffffff8105b620>] ? kthread_park+0x60/0x60
Code: 8d 60 e0 0f 84 af 00 00 00 48 8b 43 20 a8 01 75 3b 48 89 d8 f0 0f ba 28 00 72 10 48 8b 03 f6 c4 08 75 2f 48 89 df e8 8c 83 f9 ff <49> 8b 44 24 20 4d 8d 6c 24 20 48 83 e8 20 4d 39 f5 74 7a 4c 89
RIP  [<ffffffff8115e754>] balloon_page_dequeue+0x54/0x130
 RSP <ffff8800a7fefdc0>
---[ end trace 43cf28060d708d5f ]---
Kernel panic - not syncing: Fatal exception
Dumping ftrace buffer:
   (ftrace buffer empty)
Kernel Offset: disabled

Cc: <stable@vger.kernel.org>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/balloon_compaction.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/balloon_compaction.c b/mm/balloon_compaction.c
index d3116be5a00f..300117f1a08f 100644
--- a/mm/balloon_compaction.c
+++ b/mm/balloon_compaction.c
@@ -61,6 +61,7 @@ struct page *balloon_page_dequeue(struct balloon_dev_info *b_dev_info)
 	bool dequeued_page;
 
 	dequeued_page = false;
+	spin_lock_irqsave(&b_dev_info->pages_lock, flags);
 	list_for_each_entry_safe(page, tmp, &b_dev_info->pages, lru) {
 		/*
 		 * Block others from accessing the 'page' while we get around
@@ -75,15 +76,14 @@ struct page *balloon_page_dequeue(struct balloon_dev_info *b_dev_info)
 				continue;
 			}
 #endif
-			spin_lock_irqsave(&b_dev_info->pages_lock, flags);
 			balloon_page_delete(page);
 			__count_vm_event(BALLOON_DEFLATE);
-			spin_unlock_irqrestore(&b_dev_info->pages_lock, flags);
 			unlock_page(page);
 			dequeued_page = true;
 			break;
 		}
 	}
+	spin_unlock_irqrestore(&b_dev_info->pages_lock, flags);
 
 	if (!dequeued_page) {
 		/*
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
