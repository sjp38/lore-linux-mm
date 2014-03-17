Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f178.google.com (mail-we0-f178.google.com [74.125.82.178])
	by kanga.kvack.org (Postfix) with ESMTP id 3FD9E6B0082
	for <linux-mm@kvack.org>; Mon, 17 Mar 2014 05:51:44 -0400 (EDT)
Received: by mail-we0-f178.google.com with SMTP id u56so4215858wes.23
        for <linux-mm@kvack.org>; Mon, 17 Mar 2014 02:51:43 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ba5si9273654wjb.51.2014.03.17.02.51.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 17 Mar 2014 02:51:42 -0700 (PDT)
Date: Mon, 17 Mar 2014 10:51:41 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: kmemcheck: OS boot failed because NMI handlers access the memory
 tracked by kmemcheck
Message-ID: <20140317095141.GA4777@dhcp22.suse.cz>
References: <5326BE25.9090201@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5326BE25.9090201@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, vegard.nossum@oracle.com, Pekka Enberg <penberg@kernel.org>, Peter Zijlstra <peterz@infradead.org>, David Rientjes <rientjes@google.com>, Vegard Nossum <vegard.nossum@gmail.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Li Zefan <lizefan@huawei.com>

On Mon 17-03-14 17:19:33, Xishi Qiu wrote:
> OS boot failed when set cmdline kmemcheck=1. The reason is that
> NMI handlers will access the memory from kmalloc(), this will cause
> page fault, because memory from kmalloc() is tracked by kmemcheck.
> 
> watchdog_nmi_enable()
> 	perf_event_create_kernel_counter()
> 		perf_event_alloc()
> 			event = kzalloc(sizeof(*event), GFP_KERNEL);

Where is this path called from an NMI context?

Your trace bellow points at something else and it doesn't seem to
allocate any memory either. It looks more like x86_perf_event_update
sees an invalid perf_event or something like that...

> Now we don't support page faults in NMI context is that we
> may already be handling an existing fault (or trap) when the NMI hits.
> So that would mess up kmemcheck's working state.
> 
> Here is the failed log:
> [    1.731052] WARNING: CPU: 0 PID: 1 at arch/x86/mm/kmemcheck/kmemcheck.c:634 k
> memcheck_fault+0xb1/0xc0()
> [    1.731053] Modules linked in:
> [    1.731056] CPU: 0 PID: 1 Comm: swapper/0 Not tainted 3.14.0-rc3-0.1-default+
>  #1
> [    1.731057] Hardware name: Huawei Technologies Co., Ltd. Tecal RH2285
>   /BC11BTSA              , BIOS CTSAV036 04/27/2011
> [    1.731061]  000000000000027a ffff880c39c07678 ffffffff814ca491 ffff880c39c07
> 6b8
> [    1.731063]  ffffffff8104ce97 0000000000000000 ffff880c39c07838 ffff880c21028
> 1d4
> [    1.731065]  0000000000000000 0000000000000000 ffff880c210281d4 ffff880c39c07
> 6c8
> [    1.731065] Call Trace:
> [    1.731073]  <NMI>  [<ffffffff814ca491>] dump_stack+0x6a/0x79
> [    1.731077]  [<ffffffff8104ce97>] warn_slowpath_common+0x87/0xb0
> [    1.731079]  [<ffffffff8104ced5>] warn_slowpath_null+0x15/0x20
> [    1.731081]  [<ffffffff810452c1>] kmemcheck_fault+0xb1/0xc0
> [    1.731087]  [<ffffffff814d262b>] __do_page_fault+0x39b/0x4c0
> [    1.731092]  [<ffffffff81272cd2>] ? put_dec+0x72/0x90
> [    1.731093]  [<ffffffff812730ba>] ? number+0x33a/0x360
> [    1.731096]  [<ffffffff814d2829>] do_page_fault+0x9/0x10
> [    1.731098]  [<ffffffff814cf222>] page_fault+0x22/0x30
> [    1.731104]  [<ffffffff81348b4c>] ? vt_console_print+0x8c/0x400
> [    1.731106]  [<ffffffff81348b2c>] ? vt_console_print+0x6c/0x400
> [    1.731111]  [<ffffffff8109cd9b>] ? msg_print_text+0x18b/0x1f0
> [    1.731113]  [<ffffffff8109bed1>] call_console_drivers+0xc1/0xe0
> [    1.731115]  [<ffffffff8109d746>] console_unlock+0x236/0x280
> [    1.731117]  [<ffffffff8109e095>] vprintk_emit+0x2b5/0x450
> [    1.731119]  [<ffffffff810452c1>] ? kmemcheck_fault+0xb1/0xc0
> [    1.731120]  [<ffffffff814ca3f7>] printk+0x4a/0x4c
> [    1.731122]  [<ffffffff810452c1>] ? kmemcheck_fault+0xb1/0xc0
> [    1.731124]  [<ffffffff8104ce4e>] warn_slowpath_common+0x3e/0xb0
> [    1.731126]  [<ffffffff8104ced5>] warn_slowpath_null+0x15/0x20
> [    1.731128]  [<ffffffff810452c1>] kmemcheck_fault+0xb1/0xc0
> [    1.731130]  [<ffffffff814d262b>] __do_page_fault+0x39b/0x4c0
> [    1.731132]  [<ffffffff814d2829>] do_page_fault+0x9/0x10
> [    1.731134]  [<ffffffff814cf222>] page_fault+0x22/0x30
> [    1.731138]  [<ffffffff81015b52>] ? x86_perf_event_update+0x2/0x70
> [    1.731142]  [<ffffffff8101de21>] ? intel_pmu_save_and_restart+0x11/0x50
> [    1.731144]  [<ffffffff8101eb02>] intel_pmu_handle_irq+0x142/0x3a0
> [    1.731146]  [<ffffffff814d0655>] perf_event_nmi_handler+0x35/0x60
> [    1.731148]  [<ffffffff814cfe83>] nmi_handle+0x63/0x150
> [    1.731150]  [<ffffffff814cffd3>] default_do_nmi+0x63/0x290
> [    1.731151]  [<ffffffff814d02a8>] do_nmi+0xa8/0xe0
> 
> Another NMI handler which from CONFIG_ACPI_APEI_GHES=y, has the same problem too.
> ghes_probe()
> 	register_nmi_handler(NMI_LOCAL, ghes_notify_nmi, 0, "ghes");
> 
> I find it is not easy to change, because:
> e.g.
> ghes_ioremap_init()
> 	ghes_ioremap_area = __get_vm_area() -> it will call kmalloc() at last, and we 
> 						can not change the general interface. 
> 
> And we can not use kmem_cache_alloc()(create a new slab with SLAB_NOTRACK) instead of 
> kmalloc() when the size is variable.
> 
> Thanks,
> Xishi Qiu
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
