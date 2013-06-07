Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id DEE0F6B0031
	for <linux-mm@kvack.org>; Fri,  7 Jun 2013 16:23:22 -0400 (EDT)
Received: by mail-lb0-f177.google.com with SMTP id 10so4222243lbf.36
        for <linux-mm@kvack.org>; Fri, 07 Jun 2013 13:23:20 -0700 (PDT)
From: Artem Savkov <artem.savkov@gmail.com>
Subject: [PATCH] non-swapcache pages in end_swap_bio_read()
Date: Sat,  8 Jun 2013 00:23:18 +0400
Message-Id: <1370636598-5405-1-git-send-email-artem.savkov@gmail.com>
In-Reply-To: <20130607152653.GA3586@blaptop>
References: <20130607152653.GA3586@blaptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: minchan.kernel.2@gmail.com
Cc: dan.magenheimer@oracle.com, akpm@linux-foundation.org, rjw@sisk.pl, linux-mm@kvack.org, linux-pm@vger.kernel.org, linux-kernel@vger.kernel.org, Artem Savkov <artem.savkov@gmail.com>

There is no guarantee that page in end_swap_bio_read is in swapcache so we need
to check it before calling page_swap_info(). Otherwise kernel hits a bug on
like the one below.
Introduced in "mm: remove compressed copy from zram in-memory"

kernel BUG at mm/swapfile.c:2361!
invalid opcode: 0000 [#1] SMP
Modules linked in:
CPU: 1 PID: 0 Comm: swapper/1 Not tainted 3.10.0-rc4-next-20130607+ #61
Hardware name: Bochs Bochs, BIOS Bochs 01/01/2007
task: ffff88001e5ccfc0 ti: ffff88001e5ea000 task.ti: ffff88001e5ea000
RIP: 0010:[<ffffffff811462eb>]  [<ffffffff811462eb>] page_swap_info+0xab/0xb0
RSP: 0000:ffff88001ec03c78  EFLAGS: 00010246
RAX: 0100000000000009 RBX: ffffea0000794780 RCX: 0000000000000c0b
RDX: 0000000000000046 RSI: 0000000000000000 RDI: 0000000000000000
RBP: ffff88001ec03c88 R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000000 R12: 0000000000000000
R13: 0000000000000001 R14: ffff88001e7f6200 R15: 0000000000001000
FS:  0000000000000000(0000) GS:ffff88001ec00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 0000000000000000 CR3: 000000000240b000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Stack:
ffffea0000794780 ffff88001e7f6200 ffff88001ec03cb8 ffffffff81145486
ffff88001e5cd5c0 ffff88001c02cd20 0000000000001000 0000000000000000
ffff88001ec03cc8 ffffffff81199518 ffff88001ec03d28 ffffffff81518ec3
Call Trace:
<IRQ>
[<ffffffff81145486>] end_swap_bio_read+0x96/0x130
[<ffffffff81199518>] bio_endio+0x18/0x40
[<ffffffff81518ec3>] blk_update_request+0x213/0x540
[<ffffffff81518fa0>] ? blk_update_request+0x2f0/0x540
[<ffffffff817986a6>] ? ata_hsm_qc_complete+0x46/0x130
[<ffffffff81519212>] blk_update_bidi_request+0x22/0x90
[<ffffffff8151b9ea>] blk_end_bidi_request+0x2a/0x80
[<ffffffff8151ba8b>] blk_end_request+0xb/0x10
[<ffffffff817693aa>] scsi_io_completion+0xaa/0x6b0
[<ffffffff817608d8>] scsi_finish_command+0xc8/0x130
[<ffffffff81769aff>] scsi_softirq_done+0x13f/0x160
[<ffffffff81521ebc>] blk_done_softirq+0x7c/0x90
[<ffffffff81049030>] __do_softirq+0x130/0x3f0
[<ffffffff810d454e>] ? handle_irq_event+0x4e/0x70
[<ffffffff81049405>] irq_exit+0xa5/0xb0
[<ffffffff81003cb1>] do_IRQ+0x61/0xe0
[<ffffffff81c2832f>] common_interrupt+0x6f/0x6f
<EOI>
[<ffffffff8107ebff>] ? local_clock+0x4f/0x60
[<ffffffff81c27f85>] ? _raw_spin_unlock_irq+0x35/0x50
[<ffffffff81c27f7b>] ? _raw_spin_unlock_irq+0x2b/0x50
[<ffffffff81078bd0>] finish_task_switch+0x80/0x110
[<ffffffff81078b93>] ? finish_task_switch+0x43/0x110
[<ffffffff81c2525c>] __schedule+0x32c/0x8c0
[<ffffffff81c2c010>] ? notifier_call_chain+0x150/0x150
[<ffffffff81c259d4>] schedule+0x24/0x70
[<ffffffff81c25d42>] schedule_preempt_disabled+0x22/0x30
[<ffffffff81093645>] cpu_startup_entry+0x335/0x380
[<ffffffff81c1ed7e>] start_secondary+0x217/0x219
Code: 69 bc 16 82 48 c7 c7 77 bc 16 82 31 c0 49 c1 ec 39 49 c1 e9 10 41 83 e1 01 e8 6c d2 ad 00 5b 4a 8b 04 e5 e0 bf 14 83 41 5c c9 c3 <0f> 0b eb fe 90 48 8b 07 55 48 89 e5 a9 00 00 01 00 74 12 e8 3d
RIP  [<ffffffff811462eb>] page_swap_info+0xab/0xb0
RSP <ffff88001ec03c78>

Signed-off-by: Artem Savkov <artem.savkov@gmail.com>
---
 mm/page_io.c | 68 +++++++++++++++++++++++++++++++++---------------------------
 1 file changed, 38 insertions(+), 30 deletions(-)

diff --git a/mm/page_io.c b/mm/page_io.c
index 1897abb..2b76ac7 100644
--- a/mm/page_io.c
+++ b/mm/page_io.c
@@ -82,38 +82,46 @@ void end_swap_bio_read(struct bio *bio, int err)
 				iminor(bio->bi_bdev->bd_inode),
 				(unsigned long long)bio->bi_sector);
 	} else {
-		struct swap_info_struct *sis;
-
 		SetPageUptodate(page);
-		sis = page_swap_info(page);
-		if (sis->flags & SWP_BLKDEV) {
-			/*
-			 * The swap subsystem performs lazy swap slot freeing,
-			 * expecting that the page will be swapped out again.
-			 * So we can avoid an unnecessary write if the page
-			 * isn't redirtied.
-			 * This is good for real swap storage because we can
-			 * reduce unnecessary I/O and enhance wear-leveling
-			 * if an SSD is used as the as swap device.
-			 * But if in-memory swap device (eg zram) is used,
-			 * this causes a duplicated copy between uncompressed
-			 * data in VM-owned memory and compressed data in
-			 * zram-owned memory.  So let's free zram-owned memory
-			 * and make the VM-owned decompressed page *dirty*,
-			 * so the page should be swapped out somewhere again if
-			 * we again wish to reclaim it.
-			 */
-			struct gendisk *disk = sis->bdev->bd_disk;
-			if (disk->fops->swap_slot_free_notify) {
-				swp_entry_t entry;
-				unsigned long offset;
 
-				entry.val = page_private(page);
-				offset = swp_offset(entry);
-
-				SetPageDirty(page);
-				disk->fops->swap_slot_free_notify(sis->bdev,
-						offset);
+		/*
+		 * There is no guarantee that the page is in swap cache, so
+		 * we need to check PG_swapcache before proceeding with this
+		 * optimization.
+		 */
+		if (unlikely(PageSwapCache(page))) {
+			struct swap_info_struct *sis;
+
+			sis = page_swap_info(page);
+			if (sis->flags & SWP_BLKDEV) {
+				/*
+				 * The swap subsystem performs lazy swap slot freeing,
+				 * expecting that the page will be swapped out again.
+				 * So we can avoid an unnecessary write if the page
+				 * isn't redirtied.
+				 * This is good for real swap storage because we can
+				 * reduce unnecessary I/O and enhance wear-leveling
+				 * if an SSD is used as the as swap device.
+				 * But if in-memory swap device (eg zram) is used,
+				 * this causes a duplicated copy between uncompressed
+				 * data in VM-owned memory and compressed data in
+				 * zram-owned memory.  So let's free zram-owned memory
+				 * and make the VM-owned decompressed page *dirty*,
+				 * so the page should be swapped out somewhere again if
+				 * we again wish to reclaim it.
+				 */
+				struct gendisk *disk = sis->bdev->bd_disk;
+				if (disk->fops->swap_slot_free_notify) {
+					swp_entry_t entry;
+					unsigned long offset;
+
+					entry.val = page_private(page);
+					offset = swp_offset(entry);
+
+					SetPageDirty(page);
+					disk->fops->swap_slot_free_notify(sis->bdev,
+							offset);
+				}
 			}
 		}
 	}
-- 
1.8.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
