Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f51.google.com (mail-vk0-f51.google.com [209.85.213.51])
	by kanga.kvack.org (Postfix) with ESMTP id C08986B0253
	for <linux-mm@kvack.org>; Thu, 12 Nov 2015 09:27:18 -0500 (EST)
Received: by vkas68 with SMTP id s68so11124069vka.2
        for <linux-mm@kvack.org>; Thu, 12 Nov 2015 06:27:18 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k12si2666915vkd.185.2015.11.12.06.27.17
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Nov 2015 06:27:17 -0800 (PST)
Date: Thu, 12 Nov 2015 15:27:11 +0100
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH V3 1/2] slub: fix kmem cgroup bug in
 kmem_cache_alloc_bulk
Message-ID: <20151112152711.78c66db0@redhat.com>
In-Reply-To: <20151111185648.GY31308@esperanza>
References: <20151109181604.8231.22983.stgit@firesoul>
	<20151109181703.8231.66384.stgit@firesoul>
	<20151109191335.GM31308@esperanza>
	<20151109212522.6b38988c@redhat.com>
	<20151110084633.GT31308@esperanza>
	<20151110165534.6154082e@redhat.com>
	<20151110183246.GV31308@esperanza>
	<20151111162820.49fa8350@redhat.com>
	<20151111193059.5a9f5283@redhat.com>
	<20151111185648.GY31308@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, brouer@redhat.com

On Wed, 11 Nov 2015 21:56:48 +0300
Vladimir Davydov <vdavydov@virtuozzo.com> wrote:

> On Wed, Nov 11, 2015 at 07:30:59PM +0100, Jesper Dangaard Brouer wrote:
> ...
> > The problem was related to CONFIG_KMEMCHECK.  It was causing the system
> > to not boot (I have not look into why yet, don't have full console
> > output, but I can see it complains about PCI and ACPI init and then
> > dies in x86_perf_event_update+0x15, thus it could be system/HW specific).
> 
> AFAIK kmemcheck is rarely used nowadays, because kasan does practically
> the same and does it better, so failures are expected.

For the record, I've look at the early console output that caused the
CONFIG_KMEMCHECK enabled kernel to crash (general protection fault:
077b) in x86_perf_event_update+0x15.

It seems kmemcheck gets called while in NMI context, and that is likely
cause of the issue, when perf_event_nmi_handler gets activated.  

I don't know kmemcheck, but judging from the WARN_ON_ONCE(in_nmi()) in
kmemcheck_fault (which gets activated) it does have some issue with NMI.

Before crashing the warning appears:
 WARNING: CPU: 0 PID: 1 at arch/x86/mm/kmemcheck/kmemcheck.c:640 kmemcheck_fault+0x91/0xa0()

I've going to compile without CONFIG_KMEMCHECK, and just assume it is
broken (... that is I'm not going to fix this kmemcheck issue).

- - 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer

[   24.537699] WARNING: CPU: 0 PID: 1 at arch/x86/mm/kmemcheck/kmemcheck.c:640 kmemcheck_fault+0x91/0xa0()
[   24.537699] Modules linked in:
[   24.537700] CPU: 0 PID: 1 Comm: swapper/0 Not tainted 4.3.0-rc6-net-next-MM-rx-hacks+ #595
[   24.537701] Hardware name: To Be Filled By O.E.M. To Be Filled By O.E.M./Z97 Extreme4, BIOS P2.10 05/12/2015
[   24.537702]  ffffffff8180f3c8 ffff88041dc05740 ffffffff812e39cf 0000000000000000
[   24.537702]  ffff88041dc05778 ffffffff81056ae8 ffff88041dc05828 ffff88041d0401c4
[   24.537703]  0000000000000000 0000000000000000 ffff880419eb0000 ffff88041dc05788
[   24.537703] Call Trace:
[   24.537706]  <NMI>  [<ffffffff812e39cf>] dump_stack+0x44/0x55
[   24.537708]  [<ffffffff81056ae8>] warn_slowpath_common+0x78/0xb0
[   24.537708]  [<ffffffff81056bd5>] warn_slowpath_null+0x15/0x20
[   24.537709]  [<ffffffff8104adc1>] kmemcheck_fault+0x91/0xa0
[   24.537711]  [<ffffffff81043b45>] __do_page_fault+0x2a5/0x3f0
[   24.537712]  [<ffffffff812ede6a>] ? number.isra.14+0x2aa/0x2d0
[   24.537713]  [<ffffffff81043c9c>] do_page_fault+0xc/0x10
[   24.537714]  [<ffffffff81607522>] page_fault+0x22/0x30
[   24.537717]  [<ffffffff813a34d0>] ? lf+0x80/0x80
[   24.537718]  [<ffffffff813a356e>] ? vt_console_print+0x9e/0x3b0
[   24.537719]  [<ffffffff813a3511>] ? vt_console_print+0x41/0x3b0
[   24.537720]  [<ffffffff810914e3>] ? print_prefix+0xd3/0x1c0
[   24.537722]  [<ffffffff8109140a>] call_console_drivers.constprop.27+0xaa/0xb0
[   24.537723]  [<ffffffff81091fdc>] console_unlock+0x2ec/0x510
[   24.537724]  [<ffffffff81092aac>] vprintk_emit+0x2bc/0x510
[   24.537724]  [<ffffffff8104adc1>] ? kmemcheck_fault+0x91/0xa0
[   24.537725]  [<ffffffff81092e44>] vprintk_default+0x24/0x40
[   24.537727]  [<ffffffff810ed65a>] printk+0x43/0x4b
[   24.537728]  [<ffffffff8104adc1>] ? kmemcheck_fault+0x91/0xa0
[   24.537728]  [<ffffffff81056a98>] warn_slowpath_common+0x28/0xb0
[   24.537729]  [<ffffffff81056bd5>] warn_slowpath_null+0x15/0x20
[   24.537730]  [<ffffffff8104adc1>] kmemcheck_fault+0x91/0xa0
[   24.537731]  [<ffffffff81043b45>] __do_page_fault+0x2a5/0x3f0
[   24.537732]  [<ffffffff81043c9c>] do_page_fault+0xc/0x10
[   24.537732]  [<ffffffff81607522>] page_fault+0x22/0x30
[   24.537734]  [<ffffffff81014eae>] ? x86_perf_event_update+0xe/0x70
[   24.537735]  [<ffffffff8101cfcd>] ? intel_pmu_save_and_restart+0xd/0x50
[   24.537736]  [<ffffffff8101d165>] intel_pmu_handle_irq+0x155/0x3e0
[   24.537738]  [<ffffffff81014d36>] perf_event_nmi_handler+0x26/0x40
[   24.537739]  [<ffffffff810064d0>] nmi_handle+0x60/0xb0
[   24.537740]  [<ffffffff812e5262>] ? ida_pre_get+0x62/0xd0
[   24.537741]  [<ffffffff8100695b>] default_do_nmi+0x3b/0xf0
[   24.537741]  [<ffffffff81006ae6>] do_nmi+0xd6/0x120
[   24.537742]  [<ffffffff81607827>] end_repeat_nmi+0x1a/0x1e
[   24.537743]  [<ffffffff812e5262>] ? ida_pre_get+0x62/0xd0
[   24.537743]  [<ffffffff8104aa35>] ? kmemcheck_hide+0x25/0x140
[   24.537744]  [<ffffffff8104aa35>] ? kmemcheck_hide+0x25/0x140
[   24.537745]  [<ffffffff8104aa35>] ? kmemcheck_hide+0x25/0x140
[   24.537746]  <<EOE>>  <#DB>  [<ffffffff812e5262>] ? ida_pre_get+0x62/0xd0
[   24.537747]  [<ffffffff8104adef>] kmemcheck_trap+0x1f/0x30
[   24.537748]  [<ffffffff81004149>] do_debug+0x69/0x1a0
[   24.537749]  [<ffffffff8160740f>] debug+0x2f/0x60
[   24.537750]  [<ffffffff812e5262>] ? ida_pre_get+0x62/0xd0
[   24.537751]  [<ffffffff812f0ab9>] ? memset_erms+0x9/0x10
[   24.537753]  <<EOE>>  [<ffffffff8113de04>] ? kmem_cache_alloc+0x184/0x1d0
[   24.537754]  [<ffffffff812e5262>] ida_pre_get+0x62/0xd0
[   24.537754]  [<ffffffff812e5312>] ida_simple_get+0x42/0xe0
[   24.537755]  [<ffffffff8113dd31>] ? kmem_cache_alloc+0xb1/0x1d0
[   24.537757]  [<ffffffff811bcb1a>] __kernfs_new_node+0x5a/0xc0
[   24.537758]  [<ffffffff811bda91>] kernfs_new_node+0x21/0x40
[   24.537759]  [<ffffffff811bf217>] __kernfs_create_file+0x27/0x90
[   24.537761]  [<ffffffff811bfa04>] sysfs_add_file_mode_ns+0x94/0x180
[   24.537762]  [<ffffffff811bfb15>] sysfs_create_file_ns+0x25/0x30
[   24.537764]  [<ffffffff813d5a9d>] device_create_file+0x3d/0x90
[   24.537766]  [<ffffffff81350419>] acpi_device_setup_files+0x10e/0x209
[   24.537766]  [<ffffffff813530b2>] acpi_device_add+0x230/0x28f
[   24.537767]  [<ffffffff813532a4>] ? acpi_free_pnp_ids+0x4b/0x4b
[   24.537768]  [<ffffffff81353c8c>] acpi_add_single_object+0x4cc/0x525
[   24.537769]  [<ffffffff8134f421>] ? acpi_evaluate_integer+0x2f/0x4e
[   24.537769]  [<ffffffff8134ef76>] ? acpi_os_signal_semaphore+0x27/0x33
[   24.537770]  [<ffffffff81353da3>] acpi_bus_check_add+0xbe/0x16d
[   24.537772]  [<ffffffff8136e6dd>] acpi_ns_walk_namespace+0xdc/0x18e
[   24.537772]  [<ffffffff81353ce5>] ? acpi_add_single_object+0x525/0x525
[   24.537773]  [<ffffffff81353ce5>] ? acpi_add_single_object+0x525/0x525
[   24.537773]  [<ffffffff8136ebaf>] acpi_walk_namespace+0x97/0xcb
[   24.537774]  [<ffffffff81a1b0d7>] ? acpi_sleep_init+0xbb/0xbb
[   24.537775]  [<ffffffff81354097>] acpi_bus_scan+0x43/0x62
[   24.537775]  [<ffffffff81a1b514>] acpi_scan_init+0x5b/0x189
[   24.537776]  [<ffffffff81a1b333>] acpi_init+0x25c/0x274
[   24.537777]  [<ffffffff810002e6>] do_one_initcall+0xa6/0x1c0
[   24.537778]  [<ffffffff8106ff4a>] ? parse_args+0x26a/0x490
[   24.537780]  [<ffffffff819eb04c>] kernel_init_freeable+0x16a/0x1f5
[   24.537781]  [<ffffffff815fb030>] ? rest_init+0x80/0x80
[   24.537782]  [<ffffffff815fb039>] kernel_init+0x9/0xd0
[   24.537783]  [<ffffffff8160616f>] ret_from_fork+0x3f/0x70
[   24.537784]  [<ffffffff815fb030>] ? rest_init+0x80/0x80
[   24.537785] ---[ end trace ef72f67e8e798002 ]---


[   25.485937] general protection fault: 077b [#1] SMP 
[   25.491290] Modules linked in:
[   25.494618] CPU: 0 PID: 1 Comm: swapper/0 Tainted: G        W       4.3.0-rc6-net-next-MM-rx-hacks+ #595
[   25.504659] Hardware name: To Be Filled By O.E.M. To Be Filled By O.E.M./Z97 Extreme4, BIOS P2.10 05/12/2015
[   25.515062] task: ffff880419eb0000 ti: ffff880419e5c000 task.ti: ffff880419e5c000
[   25.523040] RIP: 0010:[<ffffffff81014eb5>]  [<ffffffff81014eb5>] x86_perf_event_update+0x15/0x70
[   25.532417] RSP: 0000:ffff88041dc05c18  EFLAGS: 00010283
[   25.538041] RAX: 0000000000000021 RBX: ffff880419975400 RCX: 0000000000000021
[   25.545556] RDX: 00000000ffffffff RSI: 0000000000000040 RDI: ffff880419975400
[   25.553065] RBP: ffff88041dc05c30 R08: ffff88041dc17f60 R09: 0000000000000010
[   25.560579] R10: ffff880419e5fb40 R11: 000000005254535f R12: ffff88041dc0b160
[   25.568088] R13: ffff88041dc0af60 R14: ffff880419975400 R15: 0000000000000021
[   25.575601] FS:  0000000000000000(0000) GS:ffff88041dc00000(0000) knlGS:0000000000000000
[   25.584207] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   25.590278] CR2: ffff88041d0401fc CR3: 00000000018f3000 CR4: 00000000001406f0
[   25.597790] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[   25.605303] DR3: 0000000000000000 DR6: 00000000ffff4ff0 DR7: 0000000000000400
[   25.612814] Stack:
[   25.615019]  ffff88041dc05c30 ffffffff8101cfcd 0000000000000001 ffff88041dc05e40
[   25.623072]  ffffffff8101d165 0000000000000000 0000000000000000 0000000000000000
[   25.631122]  0000000000000000 ffff88041dc0b8b0 0000006400000000 ffff88041dc05ef8
[   25.639171] Call Trace:
[   25.641825]  <NMI> 
[   25.643846]  [<ffffffff8101cfcd>] ? intel_pmu_save_and_restart+0xd/0x50
[   25.651135]  [<ffffffff8101d165>] intel_pmu_handle_irq+0x155/0x3e0
[   25.657658]  [<ffffffff81014d36>] perf_event_nmi_handler+0x26/0x40
[   25.664183]  [<ffffffff810064d0>] nmi_handle+0x60/0xb0
[   25.669628]  [<ffffffff812e5262>] ? ida_pre_get+0x62/0xd0
[   25.675338]  [<ffffffff8100695b>] default_do_nmi+0x3b/0xf0
[   25.681138]  [<ffffffff81006ae6>] do_nmi+0xd6/0x120
[   25.686313]  [<ffffffff81607827>] end_repeat_nmi+0x1a/0x1e
[   25.692115]  [<ffffffff812e5262>] ? ida_pre_get+0x62/0xd0
[   25.697830]  [<ffffffff8104aa35>] ? kmemcheck_hide+0x25/0x140
[   25.703902]  [<ffffffff8104aa35>] ? kmemcheck_hide+0x25/0x140
[   25.709974]  [<ffffffff8104aa35>] ? kmemcheck_hide+0x25/0x140
[   25.716047]  <<EOE>> 
[   25.718249]  <#DB> [   25.720584]  [<ffffffff812e5262>] ? ida_pre_get+0x62/0xd0
[   25.726404]  [<ffffffff8104adef>] kmemcheck_trap+0x1f/0x30
[   25.732203]  [<ffffffff81004149>] do_debug+0x69/0x1a0
[   25.737560]  [<ffffffff8160740f>] debug+0x2f/0x60
[   25.742553]  [<ffffffff812e5262>] ? ida_pre_get+0x62/0xd0
[   25.748265]  [<ffffffff812f0ab9>] ? memset_erms+0x9/0x10
[   25.753884]  <<EOE>> 
[   25.756086]  [<ffffffff8113de04>] ? kmem_cache_alloc+0x184/0x1d0
[   25.762740]  [<ffffffff812e5262>] ida_pre_get+0x62/0xd0
[   25.768272]  [<ffffffff812e5312>] ida_simple_get+0x42/0xe0
[   25.774079]  [<ffffffff8113dd31>] ? kmem_cache_alloc+0xb1/0x1d0
[   25.780332]  [<ffffffff811bcb1a>] __kernfs_new_node+0x5a/0xc0
[   25.786408]  [<ffffffff811bda91>] kernfs_new_node+0x21/0x40
[   25.792303]  [<ffffffff811bf217>] __kernfs_create_file+0x27/0x90
[   25.798645]  [<ffffffff811bfa04>] sysfs_add_file_mode_ns+0x94/0x180
[   25.805255]  [<ffffffff811bfb15>] sysfs_create_file_ns+0x25/0x30
[   25.811596]  [<ffffffff813d5a9d>] device_create_file+0x3d/0x90
[   25.817760]  [<ffffffff81350419>] acpi_device_setup_files+0x10e/0x209
[   25.824549]  [<ffffffff813530b2>] acpi_device_add+0x230/0x28f
[   25.830622]  [<ffffffff813532a4>] ? acpi_free_pnp_ids+0x4b/0x4b
[   25.836876]  [<ffffffff81353c8c>] acpi_add_single_object+0x4cc/0x525
[   25.843581]  [<ffffffff8134f421>] ? acpi_evaluate_integer+0x2f/0x4e
[   25.850197]  [<ffffffff8134ef76>] ? acpi_os_signal_semaphore+0x27/0x33
[   25.857078]  [<ffffffff81353da3>] acpi_bus_check_add+0xbe/0x16d
[   25.863326]  [<ffffffff8136e6dd>] acpi_ns_walk_namespace+0xdc/0x18e
[   25.869942]  [<ffffffff81353ce5>] ? acpi_add_single_object+0x525/0x525
[   25.876822]  [<ffffffff81353ce5>] ? acpi_add_single_object+0x525/0x525
[   25.883702]  [<ffffffff8136ebaf>] acpi_walk_namespace+0x97/0xcb
[   25.889952]  [<ffffffff81a1b0d7>] ? acpi_sleep_init+0xbb/0xbb
[   25.896027]  [<ffffffff81354097>] acpi_bus_scan+0x43/0x62
[   25.901741]  [<ffffffff81a1b514>] acpi_scan_init+0x5b/0x189
[   25.907630]  [<ffffffff81a1b333>] acpi_init+0x25c/0x274
[   25.913164]  [<ffffffff810002e6>] do_one_initcall+0xa6/0x1c0
[   25.919150]  [<ffffffff8106ff4a>] ? parse_args+0x26a/0x490
[   25.924956]  [<ffffffff819eb04c>] kernel_init_freeable+0x16a/0x1f5
[   25.931482]  [<ffffffff815fb030>] ? rest_init+0x80/0x80
[   25.937015]  [<ffffffff815fb039>] kernel_init+0x9/0xd0
[   25.942462]  [<ffffffff8160616f>] ret_from_fork+0x3f/0x70
[   25.948173]  [<ffffffff815fb030>] ? rest_init+0x80/0x80
[   25.953702] Code: 8b 12 00 48 89 df e8 9b 8b 12 00 eb e5 66 0f 1f 84 00 00 00 00 00 41 b9 40 00 00 00 44 2b 0d a 
[   25.976301] RIP  [<ffffffff81014eb5>] x86_perf_event_update+0x15/0x70
[   25.983135]  RSP <ffff88041dc05c18>
[   25.986872] ---[ end trace ef72f67e8e798004 ]---
[   25.991775] Kernel panic - not syncing: Fatal exception in interrupt
[   25.998480] ---[ end Kernel panic - not syncing: Fatal exception in interrupt



[

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
