Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id EC2716B0253
	for <linux-mm@kvack.org>; Mon,  2 Nov 2015 07:42:47 -0500 (EST)
Received: by wikq8 with SMTP id q8so50610828wik.1
        for <linux-mm@kvack.org>; Mon, 02 Nov 2015 04:42:47 -0800 (PST)
Received: from mail-wi0-x229.google.com (mail-wi0-x229.google.com. [2a00:1450:400c:c05::229])
        by mx.google.com with ESMTPS id u4si26951060wjq.30.2015.11.02.04.42.46
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Nov 2015 04:42:46 -0800 (PST)
Received: by wikq8 with SMTP id q8so50610438wik.1
        for <linux-mm@kvack.org>; Mon, 02 Nov 2015 04:42:46 -0800 (PST)
Date: Mon, 2 Nov 2015 14:42:44 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: linux-next: Bug in rmap_walk?
Message-ID: <20151102124244.GA7473@node.shutemov.name>
References: <201511022131.IED52614.MJVOtOSFQFLOHF@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201511022131.IED52614.MJVOtOSFQFLOHF@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org

On Mon, Nov 02, 2015 at 09:31:59PM +0900, Tetsuo Handa wrote:
> As of linux-next-20151102, I can hit below bug using OOM stress test.
> I don't hit this bug as of linux-4.3, thus I think this is a new bug.

This is my fault: bug in compound refcounting rework patchset. I'm working
on the patch.

> 
> ----------
> struct anon_vma *page_lock_anon_vma_read(struct page *page)
> {
>         struct anon_vma *anon_vma = NULL;
>         struct anon_vma *root_anon_vma;
>         unsigned long anon_mapping;
> 
>         rcu_read_lock();
>         anon_mapping = (unsigned long)READ_ONCE(page->mapping);
>         if ((anon_mapping & PAGE_MAPPING_FLAGS) != PAGE_MAPPING_ANON)
>                 goto out;
>         if (!page_mapped(page))
>                 goto out;
> 
>         anon_vma = (struct anon_vma *) (anon_mapping - PAGE_MAPPING_ANON);
>         root_anon_vma = READ_ONCE(anon_vma->root);
>         if (down_read_trylock(&root_anon_vma->rwsem)) { /* BUG: root_anon_vma == NULL here. */
> ----------
> 
> ----------
> ffffffff810b8d30
> __down_read_trylock at ./arch/x86/include/asm/rwsem.h:83
>  (inlined by) down_read_trylock at kernel/locking/rwsem.c:34
> ffffffff81176896
> page_lock_anon_vma_read at mm/rmap.c:516
> ffffffff81176780
> page_lock_anon_vma_read at mm/rmap.c:502
> ffffffff81176d34
> rmap_walk_anon at mm/rmap.c:1651
>  (inlined by) rmap_walk at mm/rmap.c:1732
> ffffffff811773f3
> try_to_unmap at mm/rmap.c:1561
> ffffffff8119ce34
> constant_test_bit at ./arch/x86/include/asm/bitops.h:311
>  (inlined by) PageCompound at include/linux/page-flags.h:154
>  (inlined by) page_mapped at include/linux/mm.h:951
>  (inlined by) __unmap_and_move at mm/migrate.c:895
>  (inlined by) unmap_and_move at mm/migrate.c:954
>  (inlined by) migrate_pages at mm/migrate.c:1153
> ffffffff811619ad
> compact_zone at mm/compaction.c:1420
> ffffffff81161b76
> compact_zone_order at mm/compaction.c:1509
> ffffffff811627fc
> try_to_compact_pages at mm/compaction.c:1566
> ffffffff811b6404
> __alloc_pages_direct_compact at mm/page_alloc.c:2793
> ffffffff8114520c
> __alloc_pages_slowpath at mm/page_alloc.c:3106
>  (inlined by) __alloc_pages_nodemask at mm/page_alloc.c:3261
> ffffffff8118db15
> alloc_pages_vma at mm/mempolicy.c:2035
> ffffffff811a2681
> do_huge_pmd_anonymous_page at mm/huge_memory.c:953
> ffffffff8116c49b
> create_huge_pmd at mm/memory.c:3240
>  (inlined by) __handle_mm_fault at mm/memory.c:3359
>  (inlined by) handle_mm_fault at mm/memory.c:3435
> ----------
> 
> ----------
> [  511.059057] Out of memory: Kill process 15456 (exe) score 55 or sacrifice child
> [  511.061173] Killed process 15456 (exe) total-vm:1118284kB, anon-rss:98948kB, file-rss:4kB
> [  511.477148] BUG: unable to handle kernel NULL pointer dereference at 0000000000000008
> [  511.479817] IP: [<ffffffff810b8d30>] down_read_trylock+0x0/0x60
> [  511.481729] PGD 35eb8067 PUD 793b4067 PMD 0 
> [  511.483549] Oops: 0000 [#1] SMP 
> [  511.484981] Modules linked in: ip6t_rpfilter ip6t_REJECT nf_reject_ipv6 nf_conntrack_ipv6 nf_defrag_ipv6 ipt_REJECT nf_reject_ipv4 nf_conntrack_ipv4 nf_defrag_ipv4 xt_conntrack nf_conntrack ebtable_nat ebtable_broute bridge stp llc ebtable_filter ebtables ip6table_mangle ip6table_security ip6table_raw ip6table_filter ip6_tables iptable_mangle iptable_security iptable_raw iptable_filter ip_tables coretemp crct10dif_pclmul crc32_pclmul crc32c_intel aesni_intel glue_helper lrw gf128mul ablk_helper cryptd ppdev vmw_balloon serio_raw parport_pc pcspkr vmw_vmci parport shpchp i2c_piix4 sd_mod ata_generic pata_acpi vmwgfx drm_kms_helper syscopyarea sysfillrect sysimgblt fb_sys_fops ttm drm ahci ata_piix mptspi libahci scsi_transport_spi libata mptscsih e1000 mptbase i2c_core
> [  511.503846] CPU: 2 PID: 15407 Comm: exe Not tainted 4.3.0-rc7-next-20151102 #196
> [  511.506268] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/31/2013
> [  511.509211] task: ffff880035e15700 ti: ffff88007c274000 task.ti: ffff88007c274000
> [  511.511560] RIP: 0010:[<ffffffff810b8d30>]  [<ffffffff810b8d30>] down_read_trylock+0x0/0x60
> [  511.514116] RSP: 0000:ffff88007c277690  EFLAGS: 00010202
> [  511.516084] RAX: 0000000000000000 RBX: ffffea0000103fc0 RCX: 0000000000000001
> [  511.518379] RDX: 0000000000000001 RSI: 00000000002dc000 RDI: 0000000000000008
> [  511.520688] RBP: ffff88007c2776c0 R08: 0000000000000000 R09: 0000000000000000
> [  511.523210] R10: ffff880035e15700 R11: ffff880035e15e50 R12: ffff8800148b8739
> [  511.525506] R13: ffff8800148b8738 R14: 0000000000000008 R15: 0000000000000000
> [  511.527872] FS:  00007f6c6a7a5740(0000) GS:ffff88007fc80000(0000) knlGS:0000000000000000
> [  511.530340] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [  511.533038] CR2: 0000000000000008 CR3: 000000001c14c000 CR4: 00000000001406e0
> [  511.535424] Stack:
> [  511.536865]  ffffffff81176896 ffffffff81176780 ffffea0000103fc0 ffffea0001817500
> [  511.539295]  ffff88007c277728 ffffea0000103fc0 ffff88007c277718 ffffffff81176d34
> [  511.541768]  0000000000000246 ffffea0000103f80 ffffea0000103fc0 0000000100000000
> [  511.544161] Call Trace:
> [  511.545528]  [<ffffffff81176896>] ? page_lock_anon_vma_read+0x116/0x420
> [  511.547623]  [<ffffffff81176780>] ? page_get_anon_vma+0x2e0/0x2e0
> [  511.549663]  [<ffffffff81176d34>] rmap_walk+0x194/0x470
> [  511.551488]  [<ffffffff811773f3>] try_to_unmap+0x83/0x130
> [  511.553300]  [<ffffffff811757d0>] ? page_remove_rmap+0x1e0/0x1e0
> [  511.555228]  [<ffffffff811748a0>] ? invalid_migration_vma+0x30/0x30
> [  511.557193]  [<ffffffff81176780>] ? page_get_anon_vma+0x2e0/0x2e0
> [  511.559054]  [<ffffffff81174870>] ? invalid_mkclean_vma+0x20/0x20
> [  511.560912]  [<ffffffff8119ce34>] migrate_pages+0x5d4/0x9d0
> [  511.562677]  [<ffffffff81160a50>] ? pageblock_pfn_to_page+0xe0/0xe0
> [  511.564599]  [<ffffffff81162150>] ? isolate_freepages_block+0x3d0/0x3d0
> [  511.566529]  [<ffffffff811619ad>] compact_zone+0x48d/0x5e0
> [  511.568251]  [<ffffffff81161b76>] compact_zone_order+0x76/0xa0
> [  511.570046]  [<ffffffff811627fc>] try_to_compact_pages+0x12c/0x240
> [  511.571875]  [<ffffffff811b6404>] __alloc_pages_direct_compact+0x36/0xf4
> [  511.573844]  [<ffffffff8114520c>] __alloc_pages_nodemask+0x56c/0xb30
> [  511.575721]  [<ffffffff8118db15>] alloc_pages_vma+0x255/0x290
> [  511.577516]  [<ffffffff811a2681>] do_huge_pmd_anonymous_page+0x151/0x680
> [  511.579489]  [<ffffffff8116c49b>] handle_mm_fault+0xbab/0x15e0
> [  511.581291]  [<ffffffff8116b944>] ? handle_mm_fault+0x54/0x15e0
> [  511.583140]  [<ffffffff810b9ed9>] ? __lock_is_held+0x49/0x70
> [  511.584885]  [<ffffffff81059641>] __do_page_fault+0x1a1/0x440
> [  511.586637]  [<ffffffff81059910>] do_page_fault+0x30/0x80
> [  511.588390]  [<ffffffff816cc747>] ? native_iret+0x7/0x7
> [  511.590050]  [<ffffffff816cd818>] page_fault+0x28/0x30
> [  511.591663]  [<ffffffff81379a8d>] ? __clear_user+0x3d/0x70
> [  511.593373]  [<ffffffff8137e488>] iov_iter_zero+0x68/0x250
> [  511.594999]  [<ffffffff814587e8>] read_iter_zero+0x38/0xb0
> [  511.596595]  [<ffffffff811ba494>] __vfs_read+0xc4/0xf0
> [  511.598174]  [<ffffffff811bac4a>] vfs_read+0x7a/0x120
> [  511.599655]  [<ffffffff811bb973>] SyS_read+0x53/0xd0
> [  511.601118]  [<ffffffff816cbbb2>] entry_SYSCALL_64_fastpath+0x12/0x76
> [  511.602876] Code: e8 76 66 00 00 48 c7 43 58 00 00 00 00 ba ff ff ff ff 48 89 d8 f0 48 0f c1 10 79 05 e8 2a 0c 2c 00 5b 5d c3 0f 1f 80 00 00 00 00 <48> 8b 07 48 89 c2 48 83 c2 01 7e 07 f0 48 0f b1 17 75 f0 48 f7 
> [  511.609514] RIP  [<ffffffff810b8d30>] down_read_trylock+0x0/0x60
> [  511.611198]  RSP <ffff88007c277690>
> [  511.612398] CR2: 0000000000000008
> [  511.613556] ---[ end trace 0968d378b7781b82 ]---
> [  511.613559] BUG: unable to handle kernel NULL pointer dereference at 0000000000000008
> [  511.613563] IP: [<ffffffff810b8d30>] down_read_trylock+0x0/0x60
> [  511.613564] PGD ae52067 PUD af02067 PMD 0 
> [  511.613566] Oops: 0000 [#2] SMP 
> [  511.613594] Modules linked in: ip6t_rpfilter ip6t_REJECT nf_reject_ipv6 nf_conntrack_ipv6 nf_defrag_ipv6 ipt_REJECT nf_reject_ipv4 nf_conntrack_ipv4 nf_defrag_ipv4 xt_conntrack nf_conntrack ebtable_nat ebtable_broute bridge stp llc ebtable_filter ebtables ip6table_mangle ip6table_security ip6table_raw ip6table_filter ip6_tables iptable_mangle iptable_security iptable_raw iptable_filter ip_tables coretemp crct10dif_pclmul crc32_pclmul crc32c_intel aesni_intel glue_helper lrw gf128mul ablk_helper cryptd ppdev vmw_balloon serio_raw parport_pc pcspkr vmw_vmci parport shpchp i2c_piix4 sd_mod ata_generic pata_acpi vmwgfx drm_kms_helper syscopyarea sysfillrect sysimgblt fb_sys_fops ttm drm ahci ata_piix mptspi libahci scsi_transport_spi libata mptscsih e1000 mptbase i2c_core
> [  511.613596] CPU: 0 PID: 15387 Comm: exe Tainted: G      D         4.3.0-rc7-next-20151102 #196
> [  511.613597] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/31/2013
> [  511.613597] task: ffff880077ea8000 ti: ffff88007bd48000 task.ti: ffff88007bd48000
> [  511.613599] RIP: 0010:[<ffffffff810b8d30>]  [<ffffffff810b8d30>] down_read_trylock+0x0/0x60
> [  511.613600] RSP: 0000:ffff88007bd4b690  EFLAGS: 00010202
> [  511.613601] RAX: 0000000000000000 RBX: ffffea0000107fc0 RCX: 0000000000000001
> [  511.613601] RDX: 0000000000000000 RSI: 0000000000000000 RDI: 0000000000000008
> [  511.613602] RBP: ffff88007bd4b6c0 R08: 0000000000000000 R09: 0000000000000000
> [  511.613602] R10: ffff880077ea8000 R11: ffffffffffffffe2 R12: ffff8800148b8739
> [  511.613602] R13: ffff8800148b8738 R14: 0000000000000008 R15: 0000000000000000
> [  511.613603] FS:  00007f384992f740(0000) GS:ffff88007fc00000(0000) knlGS:0000000000000000
> [  511.613604] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [  511.613604] CR2: 0000000000000008 CR3: 000000007b8c0000 CR4: 00000000001406f0
> [  511.613633] Stack:
> [  511.613635]  ffffffff81176896 ffffffff81176780 ffffea0000107fc0 ffffea0001808840
> [  511.613636]  ffff88007bd4b728 ffffea0000107fc0 ffff88007bd4b718 ffffffff81176d34
> [  511.613637]  0000000000000246 ffffea0000107f80 ffffea0000107fc0 0000000000000000
> [  511.613637] Call Trace:
> [  511.613640]  [<ffffffff81176896>] ? page_lock_anon_vma_read+0x116/0x420
> [  511.613641]  [<ffffffff81176780>] ? page_get_anon_vma+0x2e0/0x2e0
> [  511.613643]  [<ffffffff81176d34>] rmap_walk+0x194/0x470
> [  511.613644]  [<ffffffff811773f3>] try_to_unmap+0x83/0x130
> [  511.613645]  [<ffffffff811757d0>] ? page_remove_rmap+0x1e0/0x1e0
> [  511.613646]  [<ffffffff811748a0>] ? invalid_migration_vma+0x30/0x30
> [  511.613647]  [<ffffffff81176780>] ? page_get_anon_vma+0x2e0/0x2e0
> [  511.613648]  [<ffffffff81174870>] ? invalid_mkclean_vma+0x20/0x20
> [  511.613650]  [<ffffffff8119ce34>] migrate_pages+0x5d4/0x9d0
> [  511.613652]  [<ffffffff81160a50>] ? pageblock_pfn_to_page+0xe0/0xe0
> [  511.613653]  [<ffffffff81162150>] ? isolate_freepages_block+0x3d0/0x3d0
> [  511.613654]  [<ffffffff811619ad>] compact_zone+0x48d/0x5e0
> [  511.613655]  [<ffffffff81161b76>] compact_zone_order+0x76/0xa0
> [  511.613657]  [<ffffffff811627fc>] try_to_compact_pages+0x12c/0x240
> [  511.613658]  [<ffffffff8115ae27>] ? zone_statistics+0x77/0x90
> [  511.613659]  [<ffffffff811b6404>] __alloc_pages_direct_compact+0x36/0xf4
> [  511.613662]  [<ffffffff8114520c>] __alloc_pages_nodemask+0x56c/0xb30
> [  511.613663]  [<ffffffff810bc600>] ? mark_held_locks+0x10/0x90
> [  511.613666]  [<ffffffff816cc6df>] ? retint_kernel+0x10/0x10
> [  511.613668]  [<ffffffff8118db15>] alloc_pages_vma+0x255/0x290
> [  511.613670]  [<ffffffff811a2681>] do_huge_pmd_anonymous_page+0x151/0x680
> [  511.613672]  [<ffffffff8116c49b>] handle_mm_fault+0xbab/0x15e0
> [  511.613674]  [<ffffffff8116b944>] ? handle_mm_fault+0x54/0x15e0
> [  511.613675]  [<ffffffff810b859f>] ? cpuacct_charge+0xaf/0x1a0
> [  511.613677]  [<ffffffff81059641>] __do_page_fault+0x1a1/0x440
> [  511.613678]  [<ffffffff810b9ed9>] ? __lock_is_held+0x49/0x70
> [  511.613679]  [<ffffffff81059910>] do_page_fault+0x30/0x80
> [  511.613680]  [<ffffffff816cc747>] ? native_iret+0x7/0x7
> [  511.613682]  [<ffffffff816cd818>] page_fault+0x28/0x30
> [  511.613684]  [<ffffffff81379a8d>] ? __clear_user+0x3d/0x70
> [  511.613685]  [<ffffffff8137e488>] iov_iter_zero+0x68/0x250
> [  511.613688]  [<ffffffff814587e8>] read_iter_zero+0x38/0xb0
> [  511.613690]  [<ffffffff811ba494>] __vfs_read+0xc4/0xf0
> [  511.613691]  [<ffffffff811bac4a>] vfs_read+0x7a/0x120
> [  511.613692]  [<ffffffff811bb973>] SyS_read+0x53/0xd0
> [  511.613693]  [<ffffffff816cbbb2>] entry_SYSCALL_64_fastpath+0x12/0x76
> [  511.613705] Code: e8 76 66 00 00 48 c7 43 58 00 00 00 00 ba ff ff ff ff 48 89 d8 f0 48 0f c1 10 79 05 e8 2a 0c 2c 00 5b 5d c3 0f 1f 80 00 00 00 00 <48> 8b 07 48 89 c2 48 83 c2 01 7e 07 f0 48 0f b1 17 75 f0 48 f7 
> [  511.613706] RIP  [<ffffffff810b8d30>] down_read_trylock+0x0/0x60
> [  511.613707]  RSP <ffff88007bd4b690>
> [  511.613707] CR2: 0000000000000008
> [  511.613709] ---[ end trace 0968d378b7781b83 ]---
> [  511.613711] BUG: sleeping function called from invalid context at include/linux/sched.h:2774
> [  511.613711] in_atomic(): 1, irqs_disabled(): 1, pid: 15387, name: exe
> [  511.613712] INFO: lockdep is turned off.
> [  511.613712] irq event stamp: 1198952
> [  511.613717] hardirqs last  enabled at (1198951): [<ffffffff816cc6df>] restore_regs_and_iret+0x0/0x1d
> [  511.613718] hardirqs last disabled at (1198952): [<ffffffff816cb1d8>] _raw_spin_lock_irq+0x18/0x50
> [  511.613721] softirqs last  enabled at (1198948): [<ffffffff8107334d>] __do_softirq+0x1bd/0x290
> [  511.613722] softirqs last disabled at (1198943): [<ffffffff8107374b>] irq_exit+0xeb/0x100
> [  511.613724] CPU: 0 PID: 15387 Comm: exe Tainted: G      D         4.3.0-rc7-next-20151102 #196
> [  511.613724] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/31/2013
> [  511.613726]  0000000000000000 00000000e557b5dd ffff88007bd4b380 ffffffff8136b873
> [  511.613727]  ffff880077ea8000 ffff88007bd4b3a8 ffffffff81094adb ffffffff819f2f2f
> [  511.613728]  0000000000000ad6 0000000000000000 ffff88007bd4b3d0 ffffffff81094c14
> [  511.613728] Call Trace:
> [  511.613730]  [<ffffffff8136b873>] dump_stack+0x4b/0x68
> [  511.613732]  [<ffffffff81094adb>] ___might_sleep+0x14b/0x240
> [  511.613733]  [<ffffffff81094c14>] __might_sleep+0x44/0x80
> [  511.613735]  [<ffffffff8107e52e>] exit_signals+0x2e/0x150
> [  511.613736]  [<ffffffff810908f1>] ? blocking_notifier_call_chain+0x11/0x20
> [  511.613737]  [<ffffffff81071c0f>] do_exit+0xbf/0xb20
> [  511.613740]  [<ffffffff8101297c>] oops_end+0x9c/0xd0
> [  511.613741]  [<ffffffff81058ff9>] no_context+0x159/0x3c0
> [  511.613743]  [<ffffffff81060200>] ? leave_mm+0x70/0x70
> [  511.613744]  [<ffffffff81059367>] __bad_area_nosemaphore+0x107/0x230
> [  511.613745]  [<ffffffff81060200>] ? leave_mm+0x70/0x70
> [  511.613746]  [<ffffffff8105949e>] bad_area_nosemaphore+0xe/0x10
> [  511.613746]  [<ffffffff81059785>] __do_page_fault+0x2e5/0x440
> [  511.613749]  [<ffffffff810f5059>] ? smp_call_function_many+0x219/0x240
> [  511.613750]  [<ffffffff81059910>] do_page_fault+0x30/0x80
> [  511.613751]  [<ffffffff816cc747>] ? native_iret+0x7/0x7
> [  511.613752]  [<ffffffff816cd818>] page_fault+0x28/0x30
> [  511.613754]  [<ffffffff810b8d30>] ? up_write+0x40/0x40
> [  511.613755]  [<ffffffff81176896>] ? page_lock_anon_vma_read+0x116/0x420
> [  511.613756]  [<ffffffff81176780>] ? page_get_anon_vma+0x2e0/0x2e0
> [  511.613757]  [<ffffffff81176d34>] rmap_walk+0x194/0x470
> [  511.613758]  [<ffffffff811773f3>] try_to_unmap+0x83/0x130
> [  511.613759]  [<ffffffff811757d0>] ? page_remove_rmap+0x1e0/0x1e0
> [  511.613760]  [<ffffffff811748a0>] ? invalid_migration_vma+0x30/0x30
> [  511.613761]  [<ffffffff81176780>] ? page_get_anon_vma+0x2e0/0x2e0
> [  511.613762]  [<ffffffff81174870>] ? invalid_mkclean_vma+0x20/0x20
> [  511.613764]  [<ffffffff8119ce34>] migrate_pages+0x5d4/0x9d0
> [  511.613765]  [<ffffffff81160a50>] ? pageblock_pfn_to_page+0xe0/0xe0
> [  511.613766]  [<ffffffff81162150>] ? isolate_freepages_block+0x3d0/0x3d0
> [  511.613767]  [<ffffffff811619ad>] compact_zone+0x48d/0x5e0
> [  511.613768]  [<ffffffff81161b76>] compact_zone_order+0x76/0xa0
> [  511.613770]  [<ffffffff811627fc>] try_to_compact_pages+0x12c/0x240
> [  511.613771]  [<ffffffff8115ae27>] ? zone_statistics+0x77/0x90
> [  511.613772]  [<ffffffff811b6404>] __alloc_pages_direct_compact+0x36/0xf4
> [  511.613773]  [<ffffffff8114520c>] __alloc_pages_nodemask+0x56c/0xb30
> [  511.613774]  [<ffffffff810bc600>] ? mark_held_locks+0x10/0x90
> [  511.613775]  [<ffffffff816cc6df>] ? retint_kernel+0x10/0x10
> [  511.613777]  [<ffffffff8118db15>] alloc_pages_vma+0x255/0x290
> [  511.613778]  [<ffffffff811a2681>] do_huge_pmd_anonymous_page+0x151/0x680
> [  511.613780]  [<ffffffff8116c49b>] handle_mm_fault+0xbab/0x15e0
> [  511.613781]  [<ffffffff8116b944>] ? handle_mm_fault+0x54/0x15e0
> [  511.613783]  [<ffffffff810b859f>] ? cpuacct_charge+0xaf/0x1a0
> [  511.613784]  [<ffffffff81059641>] __do_page_fault+0x1a1/0x440
> [  511.613785]  [<ffffffff810b9ed9>] ? __lock_is_held+0x49/0x70
> [  511.613786]  [<ffffffff81059910>] do_page_fault+0x30/0x80
> [  511.613787]  [<ffffffff816cc747>] ? native_iret+0x7/0x7
> [  511.613788]  [<ffffffff816cd818>] page_fault+0x28/0x30
> [  511.613789]  [<ffffffff81379a8d>] ? __clear_user+0x3d/0x70
> [  511.613790]  [<ffffffff8137e488>] iov_iter_zero+0x68/0x250
> [  511.613792]  [<ffffffff814587e8>] read_iter_zero+0x38/0xb0
> [  511.613793]  [<ffffffff811ba494>] __vfs_read+0xc4/0xf0
> [  511.613795]  [<ffffffff811bac4a>] vfs_read+0x7a/0x120
> [  511.613796]  [<ffffffff811bb973>] SyS_read+0x53/0xd0
> [  511.613797]  [<ffffffff816cbbb2>] entry_SYSCALL_64_fastpath+0x12/0x76
> [  511.613799] note: exe[15387] exited with preempt_count 1
> [  511.857138] note: exe[15407] exited with preempt_count 1
> ----------
> 
> ---------- OOM stress tester ----------
> #include <stdio.h>
> #include <stdlib.h>
> #include <unistd.h>
> #include <sys/types.h>
> #include <sys/stat.h>
> #include <signal.h>
> #include <fcntl.h>
> 
> static void child(void)
> {
> 	char *buf = NULL;
> 	unsigned long size = 0;
> 	const int fd = open("/dev/zero", O_RDONLY);
> 	for (size = 1048576; size < 512UL * (1 << 30); size <<= 1) {
> 		char *cp = realloc(buf, size);
> 		if (!cp) {
> 			size >>= 1;
> 			break;
> 		}
> 		buf = cp;
> 	}
> 	read(fd, buf, size); /* Will cause OOM due to overcommit */
> }
> 
> int main(int argc, char *argv[])
> {
> 	if (argc > 1) {
> 		child();
> 		return 0;
> 	}
> 	signal(SIGCLD, SIG_IGN);
> 	while (1) {
> 		switch (fork()) {
> 		case 0:
> 			execl("/proc/self/exe", "/proc/self/exe", "1", NULL);
> 			_exit(0);
> 		case -1:
> 			sleep(1);
> 		}
> 	}
> 	return 0;
> }
> ---------- OOM stress tester ----------
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
