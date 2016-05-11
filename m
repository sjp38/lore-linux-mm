Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id DD03C6B0005
	for <linux-mm@kvack.org>; Wed, 11 May 2016 09:19:29 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id k129so90786691iof.0
        for <linux-mm@kvack.org>; Wed, 11 May 2016 06:19:29 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id z65si8773991iof.100.2016.05.11.06.19.28
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 11 May 2016 06:19:28 -0700 (PDT)
Subject: Re: x86_64 Question: Are concurrent IPI requests safe?
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201605061958.HHG48967.JVFtSLFQOFOOMH@I-love.SAKURA.ne.jp>
	<201605092354.AHF82313.FtQFOMVOFJLOSH@I-love.SAKURA.ne.jp>
	<alpine.DEB.2.11.1605091853130.3540@nanos>
In-Reply-To: <alpine.DEB.2.11.1605091853130.3540@nanos>
Message-Id: <201605112219.HEB64012.FLQOFMJOVOtFHS@I-love.SAKURA.ne.jp>
Date: Wed, 11 May 2016 22:19:16 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tglx@linutronix.de
Cc: peterz@infradead.org, mingo@kernel.org, akpm@linux-foundation.org, mgorman@techsingularity.net, mhocko@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Thomas Gleixner wrote:
> On Mon, 9 May 2016, Tetsuo Handa wrote:
> > 
> > It seems to me that APIC_BASE APIC_ICR APIC_ICR_BUSY are all constant
> > regardless of calling cpu. Thus, native_apic_mem_read() and
> > native_apic_mem_write() are using globally shared constant memory
> > address and __xapic_wait_icr_idle() is making decision based on
> > globally shared constant memory address. Am I right?
> 
> No. The APIC address space is per cpu. It's the same address but it's always
> accessing the local APIC of the cpu on which it is called.

Same address but per CPU magic. I see.

Now, I'm trying with CONFIG_TRACE_IRQFLAGS=y and I can observe that
irq event stamp shows that hardirqs are disabled for two CPUs when I hit
this bug. It seems to me that this bug is triggered when two CPUs are
concurrently calling smp_call_function_many() with wait == true.

(Complete log is at http://I-love.SAKURA.ne.jp/tmp/serial-20160511.txt.xz .)
----------------------------------------
[  180.434620] NMI watchdog: BUG: soft lockup - CPU#2 stuck for 23s! [tgid=13646:13646]
[  180.434622] NMI watchdog: BUG: soft lockup - CPU#3 stuck for 23s! [kswapd0:60]
[  180.434646] Modules linked in: ip6t_rpfilter ip6t_REJECT nf_reject_ipv6 nf_conntrack_ipv6 nf_defrag_ipv6 ipt_REJECT nf_reject_ipv4 nf_conntrack_ipv4 nf_defrag_ipv4 xt_conntrack nf_conntrack ebtable_nat ebtable_broute bridge stp llc ebtable_filter ebtables ip6table_mangle ip6table_raw ip6table_filter ip6_tables iptable_mangle iptable_raw iptable_filter coretemp pcspkr sg vmw_vmci i2c_piix4 ip_tables sd_mod ata_generic pata_acpi serio_raw mptspi scsi_transport_spi mptscsih vmwgfx drm_kms_helper syscopyarea sysfillrect sysimgblt fb_sys_fops mptbase ttm drm ahci e1000 libahci i2c_core ata_piix libata
[  180.434646] irq event stamp: 5324978
[  180.434649] hardirqs last  enabled at (5324977): [<ffff88007860f990>] 0xffff88007860f990
[  180.434650] hardirqs last disabled at (5324978): [<ffff88007860f990>] 0xffff88007860f990
[  180.434655] softirqs last  enabled at (5324976): [<ffffffff8107484a>] __do_softirq+0x21a/0x5a0
[  180.434656] softirqs last disabled at (5324971): [<ffffffff81074ee5>] irq_exit+0x105/0x120
[  180.434658] CPU: 3 PID: 60 Comm: kswapd0 Not tainted 4.6.0-rc7-next-20160511 #426
[  180.434659] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/31/2013
[  180.434659] task: ffff88007a046440 ti: ffff88007860c000 task.ti: ffff88007860c000
[  180.434665] RIP: 0010:[<ffffffff811105bf>]  [<ffffffff811105bf>] smp_call_function_many+0x21f/0x2c0
[  180.434666] RSP: 0000:ffff88007860f950  EFLAGS: 00000202
[  180.434667] RAX: 0000000000000000 RBX: ffff88007f8d8880 RCX: ffff88007f81d8f8
[  180.434667] RDX: 0000000000000000 RSI: 0000000000000008 RDI: ffff88007f8d8888
[  180.434667] RBP: ffff88007860f990 R08: 0000000000000005 R09: 0000000000000000
[  180.434668] R10: 0000000000000001 R11: ffff88007a046cb0 R12: 0000000000000000
[  180.434668] R13: 0000000000000008 R14: ffffffff8105b3e0 R15: ffff88007860f9a8
[  180.434669] FS:  0000000000000000(0000) GS:ffff88007f8c0000(0000) knlGS:0000000000000000
[  180.434682] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  180.434687] CR2: 00005558fa8a7643 CR3: 000000007aed0000 CR4: 00000000001406e0
[  180.434697] Stack:
[  180.434699]  0000000000018840 0100000000000001 ffff88007f8d8888 ffffffffffffffff
[  180.434700]  0000000000000000 0000000000000000 ffff88007a047688 00000000ffffffff
[  180.434701]  ffff88007860f9f0 ffffffff8105bdcf ffffea0001ad3640 0000000000000000
[  180.434702] Call Trace:
[  180.434706]  [<ffffffff8105bdcf>] native_flush_tlb_others+0x1cf/0x360
[  180.434709]  [<ffffffff811c87f4>] try_to_unmap_flush+0xb4/0x2a0
[  180.434712]  [<ffffffff8119adac>] shrink_page_list+0x4fc/0xb00
[  180.434714]  [<ffffffff8119bae2>] shrink_inactive_list+0x202/0x630
[  180.434715]  [<ffffffff8119c858>] shrink_zone_memcg+0x5a8/0x720
[  180.434718]  [<ffffffff810c9f00>] ? match_held_lock+0x180/0x1d0
[  180.434719]  [<ffffffff8119caa4>] shrink_zone+0xd4/0x2f0
[  180.434720]  [<ffffffff8119e486>] kswapd+0x4e6/0xb30
[  180.434722]  [<ffffffff8119dfa0>] ? mem_cgroup_shrink_node_zone+0x3e0/0x3e0
[  180.434724]  [<ffffffff81093a7e>] kthread+0xee/0x110
[  180.434727]  [<ffffffff8172ae3f>] ret_from_fork+0x1f/0x40
[  180.434729]  [<ffffffff81093990>] ? kthread_create_on_node+0x220/0x220
[  180.434741] Code: d2 e8 26 33 2b 00 3b 05 a4 26 be 00 41 89 c4 0f 8d 6b fe ff ff 48 63 d0 48 8b 0b 48 03 0c d5 20 14 cf 81 f6 41 18 01 74 08 f3 90 <f6> 41 18 01 75 f8 83 f8 ff 74 ba 83 f8 07 76 b5 80 3d 70 76 bc 
[  180.532771] Modules linked in: ip6t_rpfilter ip6t_REJECT nf_reject_ipv6 nf_conntrack_ipv6 nf_defrag_ipv6 ipt_REJECT nf_reject_ipv4 nf_conntrack_ipv4 nf_defrag_ipv4 xt_conntrack nf_conntrack ebtable_nat ebtable_broute bridge stp llc ebtable_filter ebtables ip6table_mangle ip6table_raw ip6table_filter ip6_tables iptable_mangle iptable_raw iptable_filter coretemp pcspkr sg vmw_vmci i2c_piix4 ip_tables sd_mod ata_generic pata_acpi serio_raw mptspi scsi_transport_spi mptscsih vmwgfx drm_kms_helper syscopyarea sysfillrect sysimgblt fb_sys_fops mptbase ttm drm ahci e1000 libahci i2c_core ata_piix libata
[  180.547386] irq event stamp: 601148
[  180.548951] hardirqs last  enabled at (601147): [<ffff880078cffa00>] 0xffff880078cffa00
[  180.551359] hardirqs last disabled at (601148): [<ffff880078cffa00>] 0xffff880078cffa00
[  180.553738] softirqs last  enabled at (601146): [<ffffffff8107484a>] __do_softirq+0x21a/0x5a0
[  180.556190] softirqs last disabled at (601141): [<ffffffff81074ee5>] irq_exit+0x105/0x120
[  180.558547] CPU: 2 PID: 13646 Comm: tgid=13646 Tainted: G             L  4.6.0-rc7-next-20160511 #426
[  180.561046] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/31/2013
[  180.563802] task: ffff880077ad1940 ti: ffff880078cfc000 task.ti: ffff880078cfc000
[  180.565984] RIP: 0010:[<ffffffff811105bf>]  [<ffffffff811105bf>] smp_call_function_many+0x21f/0x2c0
[  180.568517] RSP: 0000:ffff880078cff9c0  EFLAGS: 00000202
[  180.570338] RAX: 0000000000000000 RBX: ffff88007f898880 RCX: ffff88007f81d8d8
[  180.572500] RDX: 0000000000000000 RSI: 0000000000000008 RDI: ffff88007f898888
[  180.574628] RBP: ffff880078cffa00 R08: 0000000000000009 R09: 0000000000000000
[  180.576818] R10: 0000000000000001 R11: 0000000000000000 R12: 0000000000000000
[  180.578907] R13: 0000000000000008 R14: ffffffff81188420 R15: 0000000000000000
[  180.581040] FS:  00007f497770a740(0000) GS:ffff88007f880000(0000) knlGS:0000000000000000
[  180.583320] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  180.585188] CR2: 00007f49772ac8b5 CR3: 0000000078523000 CR4: 00000000001406e0
[  180.587333] Stack:
[  180.588536]  0000000000018840 0100000000000001 ffff88007f898888 ffffffff82b50168
[  180.590831]  0000000000000002 ffffffff81188420 0000000000000000 0000000000000001
[  180.593136]  ffff880078cffa38 ffffffff8111079d 0000000000000008 0000000000000000
[  180.595487] Call Trace:
[  180.596782]  [<ffffffff81188420>] ? page_alloc_cpu_notify+0x40/0x40
[  180.598761]  [<ffffffff8111079d>] on_each_cpu_mask+0x3d/0xc0
[  180.600609]  [<ffffffff81189234>] drain_all_pages+0xf4/0x130
[  180.602480]  [<ffffffff8118b88b>] __alloc_pages_nodemask+0x8ab/0xe80
[  180.604450]  [<ffffffff811e0c82>] alloc_pages_current+0x92/0x190
[  180.606376]  [<ffffffff8117eef6>] __page_cache_alloc+0x146/0x180
[  180.608279]  [<ffffffff81192061>] __do_page_cache_readahead+0x111/0x380
[  180.610292]  [<ffffffff811920ba>] ? __do_page_cache_readahead+0x16a/0x380
[  180.612333]  [<ffffffff811809f7>] ? pagecache_get_page+0x27/0x280
[  180.614268]  [<ffffffff81182bb3>] filemap_fault+0x2f3/0x680
[  180.616104]  [<ffffffff8130dccd>] ? xfs_filemap_fault+0x5d/0x1f0
[  180.618008]  [<ffffffff810c7c6d>] ? down_read_nested+0x2d/0x50
[  180.619884]  [<ffffffff8131e7c2>] ? xfs_ilock+0x1e2/0x2d0
[  180.621691]  [<ffffffff8130dcd8>] xfs_filemap_fault+0x68/0x1f0
[  180.623567]  [<ffffffff811b8f1b>] __do_fault+0x6b/0x110
[  180.625352]  [<ffffffff811be802>] handle_mm_fault+0x1252/0x1980
[  180.627272]  [<ffffffff811bd5f8>] ? handle_mm_fault+0x48/0x1980
[  180.629175]  [<ffffffff8105432a>] __do_page_fault+0x1aa/0x530
[  180.631072]  [<ffffffff810546d1>] do_page_fault+0x21/0x70
[  180.632852]  [<ffffffff8172cb52>] page_fault+0x22/0x30
[  180.634550] Code: d2 e8 26 33 2b 00 3b 05 a4 26 be 00 41 89 c4 0f 8d 6b fe ff ff 48 63 d0 48 8b 0b 48 03 0c d5 20 14 cf 81 f6 41 18 01 74 08 f3 90 <f6> 41 18 01 75 f8 83 f8 ff 74 ba 83 f8 07 76 b5 80 3d 70 76 bc 
----------------------------------------

Since hardirqs last enabled / disabled points to the value of RBP register,
I can't identify the location where hardirqs are disabled.
But why cannot report the location hardirqs are last disabled?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
