Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id 65B146B0032
	for <linux-mm@kvack.org>; Fri,  7 Jun 2013 08:59:20 -0400 (EDT)
Received: by mail-we0-f170.google.com with SMTP id w57so3081744wes.15
        for <linux-mm@kvack.org>; Fri, 07 Jun 2013 05:59:18 -0700 (PDT)
Date: Fri, 7 Jun 2013 16:59:09 +0400
From: Artem Savkov <artem.savkov@gmail.com>
Subject: [BUG] non-swapcache page in end_swap_bio_read()
Message-ID: <20130607125908.GB9282@cpv436-motbuntu>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Dan Magenheimer <dan.magenheimer@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, "Rafael J. Wysocki" <rjw@sisk.pl>, linux-mm@kvack.org, linux-pm@vger.kernel.org, linux-kernel@vger.kernel.org

Hello all,

I'm hitting the following BUG_ON during boot when
CONFIG_PM_STD_PARTITION or "resume" kernel boot option are set. Looks
like this issue was introduced in (or brought up to light by)
"mm: remove compressed copy from zram in-memory"
(84e5bb4f06e6d6f0c4dfc033b4700702ed8aaccc in linux-next.git)
What happens is that during swsusp_check() bio is created with
bio_end_io set to end_swap_bio_read(), but the page is not in swap
cache.
Not sure how to handle this the right way, but proceeding with the
optimization in end_swap_bio_read() only after checking PageSwapCache
flag does help.

[    2.065206] kernel BUG at mm/swapfile.c:2361!
[    2.065469] invalid opcode: 0000 [#1] SMP 
[    2.065469] Modules linked in:
[    2.065469] CPU: 1 PID: 0 Comm: swapper/1 Not tainted 3.10.0-rc4-next-20130607+ #61
[    2.065469] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2007
[    2.065469] task: ffff88001e5ccfc0 ti: ffff88001e5ea000 task.ti: ffff88001e5ea000
[    2.065469] RIP: 0010:[<ffffffff811462eb>]  [<ffffffff811462eb>] page_swap_info+0xab/0xb0
[    2.065469] RSP: 0000:ffff88001ec03c78  EFLAGS: 00010246
[    2.065469] RAX: 0100000000000009 RBX: ffffea0000794780 RCX: 0000000000000c0b
[    2.065469] RDX: 0000000000000046 RSI: 0000000000000000 RDI: 0000000000000000
[    2.065469] RBP: ffff88001ec03c88 R08: 0000000000000000 R09: 0000000000000000
[    2.065469] R10: 0000000000000000 R11: 0000000000000000 R12: 0000000000000000
[    2.065469] R13: 0000000000000001 R14: ffff88001e7f6200 R15: 0000000000001000
[    2.065469] FS:  0000000000000000(0000) GS:ffff88001ec00000(0000) knlGS:0000000000000000
[    2.065469] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[    2.065469] CR2: 0000000000000000 CR3: 000000000240b000 CR4: 00000000000006e0
[    2.065469] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[    2.065469] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[    2.065469] Stack:
[    2.065469]  ffffea0000794780 ffff88001e7f6200 ffff88001ec03cb8 ffffffff81145486
[    2.065469]  ffff88001e5cd5c0 ffff88001c02cd20 0000000000001000 0000000000000000
[    2.065469]  ffff88001ec03cc8 ffffffff81199518 ffff88001ec03d28 ffffffff81518ec3
[    2.065469] Call Trace:
[    2.065469]  <IRQ> 
[    2.065469]  [<ffffffff81145486>] end_swap_bio_read+0x96/0x130
[    2.065469]  [<ffffffff81199518>] bio_endio+0x18/0x40
[    2.065469]  [<ffffffff81518ec3>] blk_update_request+0x213/0x540
[    2.065469]  [<ffffffff81518fa0>] ? blk_update_request+0x2f0/0x540
[    2.065469]  [<ffffffff817986a6>] ? ata_hsm_qc_complete+0x46/0x130
[    2.065469]  [<ffffffff81519212>] blk_update_bidi_request+0x22/0x90
[    2.065469]  [<ffffffff8151b9ea>] blk_end_bidi_request+0x2a/0x80
[    2.065469]  [<ffffffff8151ba8b>] blk_end_request+0xb/0x10
[    2.065469]  [<ffffffff817693aa>] scsi_io_completion+0xaa/0x6b0
[    2.065469]  [<ffffffff817608d8>] scsi_finish_command+0xc8/0x130
[    2.065469]  [<ffffffff81769aff>] scsi_softirq_done+0x13f/0x160
[    2.065469]  [<ffffffff81521ebc>] blk_done_softirq+0x7c/0x90
[    2.065469]  [<ffffffff81049030>] __do_softirq+0x130/0x3f0
[    2.065469]  [<ffffffff810d454e>] ? handle_irq_event+0x4e/0x70
[    2.065469]  [<ffffffff81049405>] irq_exit+0xa5/0xb0
[    2.065469]  [<ffffffff81003cb1>] do_IRQ+0x61/0xe0
[    2.065469]  [<ffffffff81c2832f>] common_interrupt+0x6f/0x6f
[    2.065469]  <EOI> 
[    2.065469]  [<ffffffff8107ebff>] ? local_clock+0x4f/0x60
[    2.065469]  [<ffffffff81c27f85>] ? _raw_spin_unlock_irq+0x35/0x50
[    2.065469]  [<ffffffff81c27f7b>] ? _raw_spin_unlock_irq+0x2b/0x50
[    2.065469]  [<ffffffff81078bd0>] finish_task_switch+0x80/0x110
[    2.065469]  [<ffffffff81078b93>] ? finish_task_switch+0x43/0x110
[    2.065469]  [<ffffffff81c2525c>] __schedule+0x32c/0x8c0
[    2.065469]  [<ffffffff81c2c010>] ? notifier_call_chain+0x150/0x150
[    2.065469]  [<ffffffff81c259d4>] schedule+0x24/0x70
[    2.065469]  [<ffffffff81c25d42>] schedule_preempt_disabled+0x22/0x30
[    2.065469]  [<ffffffff81093645>] cpu_startup_entry+0x335/0x380
[    2.065469]  [<ffffffff81c1ed7e>] start_secondary+0x217/0x219
[    2.065469] Code: 69 bc 16 82 48 c7 c7 77 bc 16 82 31 c0 49 c1 ec 39 49 c1 e9 10 41 83 e1 01 e8 6c d2 ad 00 5b 4a 8b 04 e5 e0 bf 14 83 41 5c c9 c3 <0f> 0b eb fe 90 48 8b 07 55 48 89 e5 a9 00 00 01 00 74 12 e8 3d 
[    2.065469] RIP  [<ffffffff811462eb>] page_swap_info+0xab/0xb0
[    2.065469]  RSP <ffff88001ec03c78>

-- 
Regards,
    Artem

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
