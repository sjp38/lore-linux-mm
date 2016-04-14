Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id ED66A6B0005
	for <linux-mm@kvack.org>; Wed, 13 Apr 2016 23:32:06 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id e190so106890191pfe.3
        for <linux-mm@kvack.org>; Wed, 13 Apr 2016 20:32:06 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id xd4si1795056pab.110.2016.04.13.20.32.04
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 13 Apr 2016 20:32:06 -0700 (PDT)
Message-ID: <570F0DDB.9070003@huawei.com>
Date: Thu, 14 Apr 2016 11:26:19 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: [RFC] kmemcheck: warning during boot
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Wang
 Nan <wangnan0@huawei.com>, Hanjun Guo <guohanjun@huawei.com>, zhong jiang <zhongjiang@huawei.com>

There is a warning during boot. It exist in v4.1 stable too.
kmemcheck_fault()
	WARN_ON_ONCE(in_nmi());

Shall we use kmem_cache_create(__GFP_NOTRACK) to create a special slab,
then use kmem_cache_alloc() to alloc the memory of "struct perf_event"?

I think use kmalloc(__GFP_NOTRACK) will not help, because maybe some slabs
have already in the slab-list, right?

Thanks,
Xishi Qiu

[    4.515083] ------------[ cut here ]------------
[    4.524000] WARNING: CPU: 0 PID: 1 at arch/x86/mm/kmemcheck/kmemcheck.c:640 kmemcheck_fault+0xa7/0xb0
[    4.541808] Modules linked in:
[    4.549079] CPU: 0 PID: 1 Comm: swapper/0 Not tainted 4.6.0-rc3-0.27-default+ #1
[    4.564941] Hardware name: Huawei Technologies Co., Ltd. Tecal XH620           /BC21THSA              , BIOS TTSAV020 12/02/2011
[    4.585297]  ffffffff817a36c0 ffff881faf2069a8 ffffffff8128d2b1 0000000000000001
[    4.601271]  0000000000000000 ffffffff817a36c0 0000000000000000 ffff881faf2069e8
[    4.617237]  ffffffff8105eaf6 0000000900000000 ffff881faf206af8 ffff881f962b9d64
[    4.633204] Call Trace:
[    4.639802]  <NMI>  [<ffffffff8128d2b1>] dump_stack+0x75/0x94
[    4.649949]  [<ffffffff8105eaf6>] __warn+0x106/0x110
[    4.659231]  [<ffffffff8105eb18>] warn_slowpath_null+0x18/0x20
[    4.669438]  [<ffffffff810572d7>] kmemcheck_fault+0xa7/0xb0
[    4.679352]  [<ffffffff8104ef46>] __do_page_fault+0x406/0x5a0
[    4.689458]  [<ffffffff8104f0ec>] do_page_fault+0xc/0x10
[    4.699106]  [<ffffffff81506642>] page_fault+0x22/0x30
[    4.708569]  [<ffffffff8100380b>] ? x86_perf_event_update+0xb/0x80
[    4.719142]  [<ffffffff8100a441>] intel_pmu_save_and_restart+0x11/0x50
[    4.730091]  [<ffffffff8100adaa>] intel_pmu_handle_irq+0x16a/0x450
[    4.740666]  [<ffffffff81003dd8>] perf_event_nmi_handler+0x38/0x60
[    4.751243]  [<ffffffff8101fbb6>] nmi_handle+0x66/0xb0
[    4.760709]  [<ffffffff8101fe19>] default_do_nmi+0x49/0x110
[    4.770631]  [<ffffffff8101ffb7>] do_nmi+0xd7/0x130
[    4.779820]  [<ffffffff81506947>] end_repeat_nmi+0x1a/0x1e
[    4.789653]  [<ffffffff81506620>] ? general_protection+0x30/0x30
[    4.800044]  [<ffffffff81506620>] ? general_protection+0x30/0x30
[    4.810437]  [<ffffffff81506620>] ? general_protection+0x30/0x30
[    4.820828]  <<EOE>>  [<ffffffff811f712a>] ? kernfs_get+0x1a/0x40
[    4.831340]  [<ffffffff811f7841>] kernfs_new_node+0x31/0x40
[    4.841296]  [<ffffffff811f9bf7>] __kernfs_create_file+0x37/0xb0
[    4.851682]  [<ffffffff811fa600>] sysfs_add_file_mode_ns+0x60/0x1a0
[    4.862352]  [<ffffffff811fa803>] sysfs_add_file+0x13/0x20
[    4.872178]  [<ffffffff811fb36a>] sysfs_merge_group+0x4a/0xa0
[    4.882284]  [<ffffffff813ab53b>] dpm_sysfs_add+0xbb/0xf0
[    4.892027]  [<ffffffff813a0154>] device_add+0x2e4/0x540
[    4.901672]  [<ffffffff8139f653>] ? device_initialize+0xb3/0xe0
[    4.911960]  [<ffffffff813a03c9>] device_register+0x19/0x20
[    4.921887]  [<ffffffff813b7733>] init_memory_block+0xe3/0x100
[    4.932086]  [<ffffffff81b2df97>] memory_dev_init+0xd7/0x13d
[    4.942106]  [<ffffffff81b2db9f>] driver_init+0x2f/0x37
[    4.951667]  [<ffffffff81af09b5>] do_basic_setup+0x24/0xd8
[    4.961498]  [<ffffffff811388e5>] ? next_zone+0x25/0x30
[    4.971047]  [<ffffffff81af0c7f>] kernel_init_freeable+0x216/0x29f
[    4.981626]  [<ffffffff814f96d9>] kernel_init+0x9/0x100
[    4.991176]  [<ffffffff81505252>] ret_from_fork+0x22/0x40
[    5.000907]  [<ffffffff814f96d0>] ? rest_init+0x80/0x80
[    5.010457] ---[ end trace 9f39e67f551c7ccb ]---
[    5.019387] INFO: NMI handler (perf_event_nmi_handler) took too long to run: 504.303 msecs
[    5.036175] perf: interrupt took too long (3939857 > 2500), lowering kernel.perf_event_max_sample_rate to 250
[    5.204303] PM: Registering ACPI NVS region [mem 0xbf79e000-0xbf7cffff] (204800 bytes)
[    5.247432] clocksource: jiffies: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 7645041785100000 ns
[    5.305758] RTC time:  4:04:20, date: 04/14/16
[    5.341968] NET: Registered protocol family 16

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
