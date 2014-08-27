Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f176.google.com (mail-we0-f176.google.com [74.125.82.176])
	by kanga.kvack.org (Postfix) with ESMTP id D9EBF6B0035
	for <linux-mm@kvack.org>; Wed, 27 Aug 2014 09:06:35 -0400 (EDT)
Received: by mail-we0-f176.google.com with SMTP id q58so190396wes.7
        for <linux-mm@kvack.org>; Wed, 27 Aug 2014 06:06:35 -0700 (PDT)
Received: from smtp5-g21.free.fr (smtp5-g21.free.fr. [212.27.42.5])
        by mx.google.com with ESMTPS id ic4si458801wjb.124.2014.08.27.06.06.28
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Aug 2014 06:06:28 -0700 (PDT)
Date: Wed, 27 Aug 2014 15:06:22 +0200
From: Sabrina Dubroca <sd@queasysnail.net>
Subject: BUG: sleeping function called from invalid context at
 arch/x86/mm/fault.c:1177
Message-ID: <20140827130622.GA31728@kria>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, linux-nfs@vger.kernel.org, davej@redhat.com

Hello,

While fuzzing with trinity on next-20140827, I ran into this:

[ 2059.161014] BUG: sleeping function called from invalid context at arch/x86/mm/fault.c:1177
[ 2059.162968] in_atomic(): 0, irqs_disabled(): 1, pid: 3225, name: trinity-c0
[ 2059.163142] INFO: lockdep is turned off.
[ 2059.163142] irq event stamp: 0
[ 2059.163142] CPU: 0 PID: 3225 Comm: trinity-c0 Not tainted 3.17.0-rc2-next-20140827 #112
[ 2059.163142] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.7.5-20140617_173321-var-lib-archbuild-testing-x86_64-tobias 04/01/2014
[ 2059.173190] Call Trace:
[ 2059.173190]  [<ffffffff815caba9>] dump_stack+0x4e/0x7a
[ 2059.173190]  [<ffffffff810a5b52>] __might_sleep+0x182/0x2b0
[ 2059.173190]  [<ffffffff81068a04>] __do_page_fault+0x114/0x680
[ 2059.173190]  [<ffffffff81191bbb>] ? __alloc_pages_nodemask+0x1eb/0xcf0
[ 2059.173190]  [<ffffffff81327523>] ? __radix_tree_preload+0x63/0xf0
[ 2059.173190]  [<ffffffff81068ff5>] trace_do_page_fault+0x45/0x270
[ 2059.173190]  [<ffffffff8106063b>] do_async_page_fault+0x5b/0x90
[ 2059.173190]  [<ffffffff815d6d58>] async_page_fault+0x28/0x30
[ 2059.173190]  [<ffffffff8106ebf2>] ? gup_pte_range+0xb2/0x170
[ 2059.173190]  [<ffffffff8106ede8>] gup_pud_range+0x138/0x210
[ 2059.173190]  [<ffffffff8106f11a>] get_user_pages_fast+0xba/0x1d0
[ 2059.173190]  [<ffffffff811e95ae>] ? __kmalloc+0x2e/0x3c0
[ 2059.173190]  [<ffffffff811b50e2>] iov_iter_get_pages_alloc+0xb2/0x1c0
[ 2059.173190]  [<ffffffffa02f6dac>] nfs_direct_read_schedule_iovec+0xbc/0x2e0 [nfs]
[ 2059.173190]  [<ffffffffa02f1b5f>] ? nfs_get_lock_context+0x4f/0x120 [nfs]
[ 2059.173190]  [<ffffffffa02f77a6>] nfs_file_direct_read+0x1d6/0x2b0 [nfs]
[ 2059.173190]  [<ffffffff8120ada0>] ? do_sync_readv_writev+0x80/0x80
[ 2059.173190]  [<ffffffffa02edbf6>] nfs_file_read+0x56/0x90 [nfs]
[ 2059.173190]  [<ffffffff8120af62>] do_iter_readv_writev+0x62/0x90
[ 2059.173190]  [<ffffffff8120b837>] compat_do_readv_writev+0xd7/0x260
[ 2059.173190]  [<ffffffffa02edba0>] ? nfs_file_release+0x30/0x30 [nfs]
[ 2059.173190]  [<ffffffff810c9b2d>] ? trace_hardirqs_on+0xd/0x10
[ 2059.173190]  [<ffffffff815cff65>] ? mutex_lock_nested+0x2e5/0x620
[ 2059.173190]  [<ffffffff8122d479>] ? __fdget_pos+0x49/0x50
[ 2059.173190]  [<ffffffff810c9b2d>] ? trace_hardirqs_on+0xd/0x10
[ 2059.173190]  [<ffffffff8116507c>] ? perf_syscall_enter+0x1c/0x1d0
[ 2059.173190]  [<ffffffff810f98b7>] ? do_setitimer+0x137/0x2f0
[ 2059.173190]  [<ffffffff8120ba13>] compat_readv+0x53/0x70
[ 2059.173190]  [<ffffffff8120cba9>] compat_SyS_readv+0x49/0xb0
[ 2059.173190]  [<ffffffff815d7989>] ia32_do_call+0x13/0x13
[ 2059.173190] BUG: unable to handle kernel NULL pointer dereference at 0000000000000010
[ 2059.173190] IP: [<ffffffff8106ebf2>] gup_pte_range+0xb2/0x170
[ 2059.173190] PGD 79409067 PUD 74b5c067 PMD 0 
[ 2059.173190] Oops: 0002 [#1] PREEMPT SMP DEBUG_PAGEALLOC
[ 2059.173190] Modules linked in: sctp crc32c_generic libcrc32c ipx p8023 psnap p8022 llc auth_rpcgss nfsv4 9p netconsole e1000 cirrus syscopyarea sysfillrect ppdev sysimgblt drm_kms_helper ttm drm psmouse evdev microcode i2c_piix4 parport_pc serio_raw parport intel_agp button intel_gtt processor pcspkr nfs lockd sunrpc ipv6 ext4 crc16 mbcache jbd2 sd_mod sr_mod cdrom ata_generic pata_acpi ata_piix 9pnet_virtio libata 9pnet scsi_mod
[ 2059.173190] CPU: 0 PID: 3225 Comm: trinity-c0 Not tainted 3.17.0-rc2-next-20140827 #112
[ 2059.173190] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.7.5-20140617_173321-var-lib-archbuild-testing-x86_64-tobias 04/01/2014
[ 2059.173190] task: ffff88007a5d4350 ti: ffff880004f28000 task.ti: ffff880004f28000
[ 2059.173190] RIP: 0010:[<ffffffff8106ebf2>]  [<ffffffff8106ebf2>] gup_pte_range+0xb2/0x170
[ 2059.173190] RSP: 0000:ffff880004f2ba98  EFLAGS: 00010086
[ 2059.173190] RAX: 0000000000000000 RBX: ffffea0001e2ffc0 RCX: 0000000000000207
[ 2059.173190] RDX: 000000004085a000 RSI: ffffea0000000000 RDI: 8000000078bff067
[ 2059.173190] RBP: ffff880004f2bae8 R08: 0000000000000010 R09: ffff880004f2bb94
[ 2059.173190] R10: 0000000040a00000 R11: 0000000080000000 R12: ffff880004e8e2d8
[ 2059.173190] R13: 000000004085b000 R14: 0000000000000007 R15: 00003ffffffff000
[ 2059.173190] FS:  00007f6133060700(0000) GS:ffff88007f600000(0000) knlGS:0000000000000000
[ 2059.173190] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[ 2059.173190] CR2: 0000000000000010 CR3: 000000003ab44000 CR4: 00000000001407f0
[ 2059.173190] Stack:
[ 2059.173190]  ffff88007cc00618 ffff88007cc00650 ffffea0001e4d6a0 0000000100140010
[ 2059.173190]  0000000180140011 ffff880004ebf020 0000000040859fff 000000004085a000
[ 2059.173190]  000000004085a000 ffff880004f2bb94 ffff880004f2bb58 ffffffff8106ede8
[ 2059.173190] Call Trace:
[ 2059.173190]  [<ffffffff8106ede8>] gup_pud_range+0x138/0x210
[ 2059.173190]  [<ffffffff8106f11a>] get_user_pages_fast+0xba/0x1d0
[ 2059.173190]  [<ffffffff811e95ae>] ? __kmalloc+0x2e/0x3c0
[ 2059.173190]  [<ffffffff811b50e2>] iov_iter_get_pages_alloc+0xb2/0x1c0
[ 2059.173190]  [<ffffffffa02f6dac>] nfs_direct_read_schedule_iovec+0xbc/0x2e0 [nfs]
[ 2059.173190]  [<ffffffffa02f1b5f>] ? nfs_get_lock_context+0x4f/0x120 [nfs]
[ 2059.173190]  [<ffffffffa02f77a6>] nfs_file_direct_read+0x1d6/0x2b0 [nfs]
[ 2059.173190]  [<ffffffff8120ada0>] ? do_sync_readv_writev+0x80/0x80
[ 2059.173190]  [<ffffffffa02edbf6>] nfs_file_read+0x56/0x90 [nfs]
[ 2059.173190]  [<ffffffff8120af62>] do_iter_readv_writev+0x62/0x90
[ 2059.173190]  [<ffffffff8120b837>] compat_do_readv_writev+0xd7/0x260
[ 2059.173190]  [<ffffffffa02edba0>] ? nfs_file_release+0x30/0x30 [nfs]
[ 2059.173190]  [<ffffffff810c9b2d>] ? trace_hardirqs_on+0xd/0x10
[ 2059.173190]  [<ffffffff815cff65>] ? mutex_lock_nested+0x2e5/0x620
[ 2059.173190]  [<ffffffff8122d479>] ? __fdget_pos+0x49/0x50
[ 2059.173190]  [<ffffffff810c9b2d>] ? trace_hardirqs_on+0xd/0x10
[ 2059.173190]  [<ffffffff8116507c>] ? perf_syscall_enter+0x1c/0x1d0
[ 2059.173190]  [<ffffffff810f98b7>] ? do_setitimer+0x137/0x2f0
[ 2059.173190]  [<ffffffff8120ba13>] compat_readv+0x53/0x70
[ 2059.173190]  [<ffffffff8120cba9>] compat_SyS_readv+0x49/0xb0
[ 2059.173190]  [<ffffffff815d7989>] ia32_do_call+0x13/0x13
[ 2059.173190] Code: 4c 21 f8 48 89 c3 48 c1 eb 06 48 01 f3 48 8b 03 f6 c4 80 75 54 f0 ff 43 1c f0 80 0b 04 49 63 01 49 81 c5 00 10 00 00 49 83 c4 08 <49> 89 1c c0 41 83 01 01 49 39 d5 0f 84 85 00 00 00 49 8b 3c 24 
[ 2059.173190] RIP  [<ffffffff8106ebf2>] gup_pte_range+0xb2/0x170
[ 2059.173190]  RSP <ffff880004f2ba98>
[ 2059.173190] CR2: 0000000000000010
[ 2059.173190] ---[ end trace 97335fea424ce4de ]---

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
