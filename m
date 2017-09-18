Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id D13C26B0253
	for <linux-mm@kvack.org>; Mon, 18 Sep 2017 08:14:26 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id d6so274908wrd.7
        for <linux-mm@kvack.org>; Mon, 18 Sep 2017 05:14:26 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m184sor1804765wme.33.2017.09.18.05.14.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 18 Sep 2017 05:14:25 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 2/3] mm, page_alloc: add scheduling point to memmap_init_zone
Date: Mon, 18 Sep 2017 14:14:09 +0200
Message-Id: <20170918121410.24466-3-mhocko@kernel.org>
In-Reply-To: <20170918121410.24466-1-mhocko@kernel.org>
References: <20170918121410.24466-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dan Williams <dan.j.williams@gmail.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Michal Hocko <mhocko@suse.com>, Johannes Thumshirn <jthumshirn@suse.de>

From: Michal Hocko <mhocko@suse.com>

memmap_init_zone gets a pfn range to intialize and it can be really
large resulting in a soft lockup on non-preemptible kernels

[   65.585596] NMI watchdog: BUG: soft lockup - CPU#31 stuck for 23s! [kworker/u642:5:1720]
[...]
[   65.585818] task: ffff88ecd7e902c0 ti: ffff88eca4e50000 task.ti: ffff88eca4e50000
[   65.585819] RIP: 0010:[<ffffffff815ff545>]  [<ffffffff815ff545>] move_pfn_range_to_zone+0x185/0x1d0
[...]
[   65.585843] Call Trace:
[   65.585853]  [<ffffffff8118b657>] devm_memremap_pages+0x2c7/0x430
[   65.585862]  [<ffffffffa02d650d>] pmem_attach_disk+0x2fd/0x3f0 [nd_pmem]
[   65.585893]  [<ffffffffa14bb984>] nvdimm_bus_probe+0x64/0x110 [libnvdimm]
[   65.585904]  [<ffffffff8146b257>] driver_probe_device+0x1f7/0x420
[   65.585910]  [<ffffffff81469212>] bus_for_each_drv+0x52/0x80
[   65.585913]  [<ffffffff8146af40>] __device_attach+0xb0/0x130
[   65.585916]  [<ffffffff8146a367>] bus_probe_device+0x87/0xa0
[   65.585919]  [<ffffffff814682fc>] device_add+0x3fc/0x5f0
[   65.585924]  [<ffffffffa14baffe>] nd_async_device_register+0xe/0x40 [libnvdimm]
[   65.585927]  [<ffffffff8109e413>] async_run_entry_fn+0x43/0x150
[   65.585933]  [<ffffffff81095b8e>] process_one_work+0x14e/0x410
[   65.585937]  [<ffffffff810963f6>] worker_thread+0x116/0x490
[   65.585939]  [<ffffffff8109b8c7>] kthread+0xc7/0xe0
[   65.585943]  [<ffffffff8160a57f>] ret_from_fork+0x3f/0x70

Fix this by adding a scheduling point once per page block.

Reported-by: Johannes Thumshirn <jthumshirn@suse.de>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/page_alloc.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index fc36755a21cf..41e93dfc702e 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5320,6 +5320,7 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
 
 			__init_single_page(page, pfn, zone, nid);
 			set_pageblock_migratetype(page, MIGRATE_MOVABLE);
+			cond_resched();
 		} else {
 			__init_single_pfn(pfn, zone, nid);
 		}
-- 
2.14.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
