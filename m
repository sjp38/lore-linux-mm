Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id D123C8E0002
	for <linux-mm@kvack.org>; Wed,  2 Jan 2019 16:13:38 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id r9so33502363pfb.13
        for <linux-mm@kvack.org>; Wed, 02 Jan 2019 13:13:38 -0800 (PST)
Received: from ipmail01.adl2.internode.on.net (ipmail01.adl2.internode.on.net. [150.101.137.133])
        by mx.google.com with ESMTP id 101si52743774pld.22.2019.01.02.13.13.35
        for <linux-mm@kvack.org>;
        Wed, 02 Jan 2019 13:13:36 -0800 (PST)
Date: Thu, 3 Jan 2019 08:13:32 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: [BUG, TOT] xfs w/ dax failure in __follow_pte_pmd()
Message-ID: <20190102211332.GL4205@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-xfs@vger.kernel.org
Cc: linux-mm@kvack.org, Matthew Wilcox <willy@infradead.org>, Dan Williams <dan.j.williams@intel.com>

Hi folks,

An overnight test run on a current TOT kernel failed generic/413
with the following dmesg output:

[ 9486.521975] run fstests generic/413 at 2019-01-02 16:50:14
[ 9486.664868] XFS (pmem0): Mounting V5 Filesystem
[ 9486.669103] XFS (pmem0): Ending clean mount
[ 9486.892718] XFS (pmem1): Unmounting Filesystem
[ 9486.932496] XFS (pmem1): DAX enabled. Warning: EXPERIMENTAL, use at your own risk
[ 9486.935203] XFS (pmem1): Mounting V4 Filesystem
[ 9486.938639] XFS (pmem1): Ending clean mount
[ 9486.980640] XFS (pmem1): Unmounting Filesystem
[ 9487.060934] XFS (pmem0): Unmounting Filesystem
[ 9487.073078] XFS (pmem0): Mounting V5 Filesystem
[ 9487.077239] XFS (pmem0): Ending clean mount
[ 9487.093628] XFS (pmem1): DAX enabled. Warning: EXPERIMENTAL, use at your own risk
[ 9487.096252] XFS (pmem1): Mounting V4 Filesystem
[ 9487.099734] XFS (pmem1): Ending clean mount
[ 9487.262308] BUG: unable to handle kernel paging request at fffffffff3ff842c
[ 9487.264682] #PF error: [normal kernel read fault]
[ 9487.266540] PGD 2410067 P4D 2410067 PUD 2412067 PMD 0
[ 9487.268734] Oops: 0000 [#1] PREEMPT SMP
[ 9487.270551] CPU: 10 PID: 6118 Comm: t_mmap_dio Not tainted 4.20.0-dgc+ #920
[ 9487.273603] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.11.1-1 04/01/2014
[ 9487.276402] RIP: 0010:__follow_pte_pmd+0x22d/0x340
[ 9487.278034] Code: 12 01 00 00 4d 85 e4 0f 84 b7 00 00 00 48 89 d8 48 25 00 f0 ff ff 49 89 44 24 08 48 05 00 10 00 00 49 89 44 24 10 49 8b 04 24 <48> 83 b8 30 04 00 00 00 74 0e 41 c69
[ 9487.284301] RSP: 0018:ffffc9000282fc60 EFLAGS: 00010206
[ 9487.286068] RAX: fffffffff3ff7ffc RBX: 00007f5e53501000 RCX: fff0000000000fff
[ 9487.288451] RDX: 000000033b5d1067 RSI: 0000000000000000 RDI: 0000000000000001
[ 9487.290845] RBP: ffff8882e4af94d0 R08: ffffc9000282fca8 R09: ffffc9000282fcb0
[ 9487.293232] R10: 00000002e4af9000 R11: ffff8880000004d0 R12: ffffc9000282fcb8
[ 9487.295614] R13: ffff88833f9b4500 R14: ffffc9000282fcb0 R15: ffffc9000282fca8
[ 9487.298011] FS:  00007f5e528e3740(0000) GS:ffff88833fd00000(0000) knlGS:0000000000000000
[ 9487.300722] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[ 9487.302666] CR2: fffffffff3ff842c CR3: 0000000338f95001 CR4: 0000000000060ee0
[ 9487.305065] Call Trace:
[ 9487.307310]  dax_entry_mkclean+0xbb/0x1f0
[ 9487.309096]  ? xas_store+0x29/0x530
[ 9487.310307]  dax_writeback_mapping_range+0x1c2/0x560
[ 9487.311986]  do_writepages+0x3e/0xe0
[ 9487.315335]  ? __sb_end_write+0x39/0x60
[ 9487.316648]  ? touch_atime+0xd1/0xe0
[ 9487.317886]  __filemap_fdatawrite_range+0x81/0xb0
[ 9487.323525]  file_write_and_wait_range+0x4c/0xa0
[ 9487.325466]  xfs_file_fsync+0x5d/0x260
[ 9487.329938]  __x64_sys_msync+0x181/0x200
[ 9487.331416]  do_syscall_64+0x54/0x170
[ 9487.332671]  entry_SYSCALL_64_after_hwframe+0x49/0xbe
[ 9487.334408] RIP: 0033:0x7f5e530c2ba1
[ 9487.335625] Code: 00 48 8b 15 21 a4 00 00 f7 d8 64 89 02 48 c7 c0 ff ff ff ff c3 0f 1f 40 00 8b 05 6a e8 00 00 85 c0 75 16 b8 1a 00 00 00 0f 05 <48> 3d 00 f0 ff ff 77 57 f3 c3 0f 1f3
[ 9487.341909] RSP: 002b:00007ffeaaf9fcd8 EFLAGS: 00000246 ORIG_RAX: 000000000000001a
[ 9487.344435] RAX: ffffffffffffffda RBX: 0000000000000400 RCX: 00007f5e530c2ba1
[ 9487.346809] RDX: 0000000000000004 RSI: 0000000000000400 RDI: 00007f5e53501000
[ 9487.349204] RBP: 00007ffeaafa1ab3 R08: 0000000000000003 R09: 0000000000000000
[ 9487.351591] R10: 0000000000000103 R11: 0000000000000246 R12: 0000000000000004
[ 9487.353987] R13: 0000000000000003 R14: 00007ffeaafa1a9c R15: 00007f5e53501000
[ 9487.356376] CR2: fffffffff3ff842c
[ 9487.357519] ---[ end trace 40e0c04119f18109 ]---
[ 9487.359076] RIP: 0010:__follow_pte_pmd+0x22d/0x340
[ 9487.360693] Code: 12 01 00 00 4d 85 e4 0f 84 b7 00 00 00 48 89 d8 48 25 00 f0 ff ff 49 89 44 24 08 48 05 00 10 00 00 49 89 44 24 10 49 8b 04 24 <48> 83 b8 30 04 00 00 00 74 0e 41 c69
[ 9487.366924] RSP: 0018:ffffc9000282fc60 EFLAGS: 00010206
[ 9487.368676] RAX: fffffffff3ff7ffc RBX: 00007f5e53501000 RCX: fff0000000000fff
[ 9487.371055] RDX: 000000033b5d1067 RSI: 0000000000000000 RDI: 0000000000000001
[ 9487.373439] RBP: ffff8882e4af94d0 R08: ffffc9000282fca8 R09: ffffc9000282fcb0
[ 9487.375812] R10: 00000002e4af9000 R11: ffff8880000004d0 R12: ffffc9000282fcb8
[ 9487.378200] R13: ffff88833f9b4500 R14: ffffc9000282fcb0 R15: ffffc9000282fca8
[ 9487.380581] FS:  00007f5e528e3740(0000) GS:ffff88833fd00000(0000) knlGS:0000000000000000
[ 9487.383288] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[ 9487.385227] CR2: fffffffff3ff842c CR3: 0000000338f95001 CR4: 0000000000060ee0
[ 9487.387616] BUG: sleeping function called from invalid context at include/linux/percpu-rwsem.h:34
[ 9487.390580] in_atomic(): 0, irqs_disabled(): 1, pid: 6118, name: t_mmap_dio
[ 9487.392916] CPU: 10 PID: 6118 Comm: t_mmap_dio Tainted: G      D           4.20.0-dgc+ #920
[ 9487.395716] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.11.1-1 04/01/2014
[ 9487.398512] Call Trace:
[ 9487.399391]  dump_stack+0x67/0x90
[ 9487.400539]  ___might_sleep.cold.83+0x80/0x8d
[ 9487.413519]  exit_signals+0x30/0x230
[ 9487.421507]  do_exit+0xb4/0xbe0
[ 9487.423081]  ? __x64_sys_msync+0x181/0x200
[ 9487.424613]  rewind_stack_do_exit+0x17/0x20

This is with MKFS_OPTIONS="-m crc=0". No idea if it is reproducable,
but I've never seen this before so my initial thoughts is that it is
a merge window regression. Looks like a DAX or Xarray issue, and
it's reproducable (reboot and rerun g/413 immediately reproduced
it).

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
