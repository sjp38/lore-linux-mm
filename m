Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 222576B030B
	for <linux-mm@kvack.org>; Wed,  3 Jan 2018 03:46:05 -0500 (EST)
Received: by mail-pl0-f70.google.com with SMTP id a12so538835pll.21
        for <linux-mm@kvack.org>; Wed, 03 Jan 2018 00:46:05 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id h1sor136056pfa.31.2018.01.03.00.46.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 03 Jan 2018 00:46:03 -0800 (PST)
Date: Wed, 3 Jan 2018 00:46:00 -0800
From: Benjamin Gilbert <benjamin.gilbert@coreos.com>
Subject: "bad pmd" errors + oops with KPTI on 4.14.11 after loading X.509
 certs
Message-ID: <20180103084600.GA31648@trogon.sfo.coreos.systems>
References: <CAD3VwcrHs8W_kMXKyDjKnjNDkkK57-0qFS5ATJYCphJHU0V3ow@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAD3VwcrHs8W_kMXKyDjKnjNDkkK57-0qFS5ATJYCphJHU0V3ow@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: stable@vger.kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>

[resending with less web]

Hi all,

In our regression tests on kernel 4.14.11, we're occasionally seeing a run
of "bad pmd" messages during boot, followed by a "BUG: unable to handle
kernel paging request".  This happens on no more than a couple percent of
boots, but we've seen it on AWS HVM, GCE, Oracle Cloud VMs, and local QEMU
instances.  It always happens immediately after "Loading compiled-in X.509
certificates".  I can't reproduce it on 4.14.10, nor, so far, on 4.14.11
with pti=off.  Here's a sample backtrace:

[    4.762964] Loading compiled-in X.509 certificates
[    4.765620] ../source/mm/pgtable-generic.c:40: bad pmd ffff8b39bf7ee000(800000007d6000e3)
[    4.769099] ../source/mm/pgtable-generic.c:40: bad pmd ffff8b39bf7ee008(800000007d8000e3)
[    4.772479] ../source/mm/pgtable-generic.c:40: bad pmd ffff8b39bf7ee010(800000007da000e3)
[    4.775919] ../source/mm/pgtable-generic.c:40: bad pmd ffff8b39bf7ee018(800000007dc000e3)
[    4.779251] ../source/mm/pgtable-generic.c:40: bad pmd ffff8b39bf7ee020(800000007de000e3)
[    4.782558] ../source/mm/pgtable-generic.c:40: bad pmd ffff8b39bf7ee028(800000007e0000e3)
[    4.794160] ../source/mm/pgtable-generic.c:40: bad pmd ffff8b39bf7ee030(800000007e2000e3)
[    4.797525] ../source/mm/pgtable-generic.c:40: bad pmd ffff8b39bf7ee038(800000007e4000e3)
[    4.800776] ../source/mm/pgtable-generic.c:40: bad pmd ffff8b39bf7ee040(800000007e6000e3)
[    4.804100] ../source/mm/pgtable-generic.c:40: bad pmd ffff8b39bf7ee048(800000007e8000e3)
[    4.807437] ../source/mm/pgtable-generic.c:40: bad pmd ffff8b39bf7ee050(800000007ea000e3)
[    4.810729] ../source/mm/pgtable-generic.c:40: bad pmd ffff8b39bf7ee058(800000007ec000e3)
[    4.813989] ../source/mm/pgtable-generic.c:40: bad pmd ffff8b39bf7ee060(800000007ee000e3)
[    4.817294] ../source/mm/pgtable-generic.c:40: bad pmd ffff8b39bf7ee068(800000007f0000e3)
[    4.820713] ../source/mm/pgtable-generic.c:40: bad pmd ffff8b39bf7ee070(800000007f2000e3)
[    4.823943] ../source/mm/pgtable-generic.c:40: bad pmd ffff8b39bf7ee078(800000007f4000e3)
[    4.827311] BUG: unable to handle kernel paging request at fffffe27c1fdfba0
[    4.830109] IP: free_page_and_swap_cache+0x6/0xa0
[    4.831999] PGD 7f7ef067 P4D 7f7ef067 PUD 0
[    4.833779] Oops: 0000 [#1] SMP PTI
[    4.835197] Modules linked in:
[    4.836450] CPU: 0 PID: 45 Comm: modprobe Not tainted 4.14.11-coreos #1
[    4.839009] Hardware name: Xen HVM domU, BIOS 4.2.amazon 08/24/2006
[    4.841551] task: ffff8b39b5a71e40 task.stack: ffffb92580558000
[    4.844062] RIP: 0010:free_page_and_swap_cache+0x6/0xa0
[    4.846238] RSP: 0018:ffffb9258055bc98 EFLAGS: 00010297
[    4.848300] RAX: 0000000000000000 RBX: fffffe27c0001000 RCX: ffff8b39bf7ef4f8
[    4.851184] RDX: 000000000007f7ee RSI: fffffe27c1fdfb80 RDI: fffffe27c1fdfb80
[    4.854090] RBP: ffff8b39bf7ee000 R08: 0000000000000000 R09: 0000000000000162
[    4.856946] R10: ffffffffffffff90 R11: 0000000000000161 R12: fffffe27ffe00000
[    4.859777] R13: ffff8b39bf7ef000 R14: fffffe2800000000 R15: ffffb9258055bd60
[    4.862602] FS:  0000000000000000(0000) GS:ffff8b39bd200000(0000) knlGS:0000000000000000
[    4.865860] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[    4.868175] CR2: fffffe27c1fdfba0 CR3: 000000002d00a001 CR4: 00000000001606f0
[    4.871162] Call Trace:
[    4.872188]  free_pgd_range+0x3a5/0x5b0
[    4.873781]  free_ldt_pgtables.part.2+0x60/0xa0
[    4.875679]  ? arch_tlb_finish_mmu+0x42/0x70
[    4.877476]  ? tlb_finish_mmu+0x1f/0x30
[    4.878999]  exit_mmap+0x5b/0x1a0
[    4.880327]  ? dput+0xb8/0x1e0
[    4.881575]  ? hrtimer_try_to_cancel+0x25/0x110
[    4.883388]  mmput+0x52/0x110
[    4.884620]  do_exit+0x330/0xb10
[    4.886044]  ? task_work_run+0x6b/0xa0
[    4.887544]  do_group_exit+0x3c/0xa0
[    4.889012]  SyS_exit_group+0x10/0x10
[    4.890473]  entry_SYSCALL_64_fastpath+0x1a/0x7d
[    4.892364] RIP: 0033:0x7f4a41d4ded9
[    4.893812] RSP: 002b:00007ffe25d85708 EFLAGS: 00000246 ORIG_RAX: 00000000000000e7
[    4.896974] RAX: ffffffffffffffda RBX: 00005601b3c9e2e0 RCX: 00007f4a41d4ded9
[    4.899830] RDX: 0000000000000000 RSI: 0000000000000001 RDI: 0000000000000001
[    4.902647] RBP: 00005601b3c9d0e8 R08: 000000000000003c R09: 00000000000000e7
[    4.905743] R10: ffffffffffffff90 R11: 0000000000000246 R12: 00005601b3c9d090
[    4.908659] R13: 0000000000000004 R14: 0000000000000001 R15: 00007ffe25d85828
[    4.911495] Code: e0 01 48 83 f8 01 19 c0 25 01 fe ff ff 05 00 02 00 00 3e 29 43 1c 5b 5d 41 5c c3 66 2e 0f 1f 84 00 00 00 00 00 0f 1f 44 00 00 53 <48> 8b 57 20 48 89 fb 48 8d 42 ff 83 e2 01 48 0f 44 c7 48 8b 48
[    4.919014] RIP: free_page_and_swap_cache+0x6/0xa0 RSP: ffffb9258055bc98
[    4.921801] CR2: fffffe27c1fdfba0
[    4.923232] ---[ end trace e79ccb938bf80a4e ]---
[    4.925166] Kernel panic - not syncing: Fatal exception
[    4.927390] Kernel Offset: 0x1c000000 from 0xffffffff81000000 (relocation range: 0xffffffff80000000-0xffffffffbfffffff)

Traces were obtained via virtual serial port.  The backtrace varies a bit,
as does the comm.

The kernel config and a collection of backtraces are attached.  Our diff on
top of vanilla 4.14.11 (unchanged from 4.14.10, and containing nothing
especially relevant):

https://github.com/coreos/linux/compare/v4.14.11...coreos:v4.14.11-coreos

I'm happy to try test builds, etc.  For ease of reproduction if needed, an
affected OS image:

https://storage.googleapis.com/builds.developer.core-os.net/boards/amd64-usr/1632.0.0%2Bjenkins2-master%2Blocal-999/coreos_production_qemu_image.img.bz2

and a wrapper script to start it with QEMU:

https://storage.googleapis.com/builds.developer.core-os.net/boards/amd64-usr/1632.0.0%2Bjenkins2-master%2Blocal-999/coreos_production_qemu.sh

Get in with "ssh -p 2222 core@localhost".  Corresponding debug symbols:

https://storage.googleapis.com/builds.developer.core-os.net/boards/amd64-usr/1632.0.0%2Bjenkins2-master%2Blocal-999/pkgs/sys-kernel/coreos-kernel-4.14.11.tbz2
https://storage.googleapis.com/builds.developer.core-os.net/boards/amd64-usr/1632.0.0%2Bjenkins2-master%2Blocal-999/pkgs/sys-kernel/coreos-modules-4.14.11.tbz2

--Benjamin Gilbert

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
