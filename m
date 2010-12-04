Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 9065E6B009D
	for <linux-mm@kvack.org>; Sat,  4 Dec 2010 01:48:14 -0500 (EST)
Date: Sat, 4 Dec 2010 01:48:10 -0500 (EST)
From: caiqian@redhat.com
Message-ID: <1072296184.6551291445290387.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
In-Reply-To: <1879358423.6531291445002308.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
Subject: mmotm-2010-11-23 panic at __init_waitqueue_head+0xd/0x1d
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm <linux-mm@kvack.org>
Cc: james toy <toyj@union.edu>
List-ID: <linux-mm.kvack.org>

I have actually met a NULL pointer dereference at init_waitqueue_head, and bisected to 33f46f26c6fe6e06f808c160e33106bc97e45914.

commit 33f46f26c6fe6e06f808c160e33106bc97e45914
Author: james toy <toyj@union.edu>
Date:   Tue Nov 23 23:19:22 2010 +0100

    GIT c239aa98a4d58c79abbd975e846a4f2497b6a942 git+ssh://master.kernel.org/pub/scm/linux/kernel/git/sfr/linux-next.git

However, I could not find a way to bisect further in mmtom as this was a giant huge single commit there. I have also tried to test the latest linux-next and use that commit as the HEAD, and there were no such problem. It looks like some integration problem only reproducible with mmtom and linux-tree trees merged.

[    3.994848] BUG: unable to handle kernel NULL pointer dereference at 0000000000000330
[    3.995824] IP: [<ffffffff81069bdd>] __init_waitqueue_head+0xd/0x1d
[    3.995824] PGD 0 
[    3.995824] Oops: 0002 [#1] SMP 
[    3.995824] last sysfs file: 
[    3.995824] CPU 3 
[    3.995824] Modules linked in:
[    3.995824] 
[    3.995824] Pid: 1, comm: swapper Not tainted 2.6.37-rc3-next-20101123+ #35 0M860N/OptiPlex 760                 
[    3.995824] RIP: 0010:[<ffffffff81069bdd>]  [<ffffffff81069bdd>] __init_waitqueue_head+0xd/0x1d
[    4.068250] RSP: 0018:ffff88022b4e1e60  EFLAGS: 00010246
[    4.068250] RAX: 0000000000000338 RBX: 0000000000000000 RCX: 0000000000003973
[    4.068250] RDX: ffff88022b753f60 RSI: ffffffff81d9c8b0 RDI: 0000000000000330
[    4.068250] RBP: ffff88022b4e1e60 R08: 0000000000000100 R09: ffff88022b71a3a8
[    4.068250] R10: ffff88022b753e10 R11: 0000000000000000 R12: 0000000000000000
[    4.068250] R13: 0000000000000000 R14: 0000000000000100 R15: 0000000000000000
[    4.068250] FS:  0000000000000000(0000) GS:ffff8800bfac0000(0000) knlGS:0000000000000000
[    4.068250] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[    4.068250] CR2: 0000000000000330 CR3: 0000000001a03000 CR4: 00000000000406e0
[    4.068250] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[    4.068250] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[    4.068250] Process swapper (pid: 1, threadinfo ffff88022b4e0000, task ffff88022b4d8000)
[    4.068250] Stack:
[    4.068250]  ffff88022b4e1ea0 ffffffff81b8f002 0000000000000000 ffffffff81c1b3d0
[    4.068250]  ffffffff81b8ef96 0000000000000000 0000000000000100 0000000000000000
[    4.068250]  ffff88022b4e1ed0 ffffffff8100219b ffffffff81c1b3d0 ffffffff81b356a0
[    4.068250] Call Trace:
[    4.068250]  [<ffffffff81b8f002>] sep_init+0x6c/0x3a5
[    4.068250]  [<ffffffff81b8ef96>] ? sep_init+0x0/0x3a5
[    4.068250]  [<ffffffff8100219b>] do_one_initcall+0x7f/0x138
[    4.068250]  [<ffffffff81b53db9>] kernel_init+0x17d/0x20b
[    4.068250]  [<ffffffff8100aa64>] kernel_thread_helper+0x4/0x10
[    4.068250]  [<ffffffff81b53c3c>] ? kernel_init+0x0/0x20b
[    4.068250]  [<ffffffff8100aa60>] ? kernel_thread_helper+0x0/0x10
[    4.068250] Code: 8b 2d e8 fa 9a 00 49 81 fd a0 96 a1 81 75 96 66 ff 05 28 f0 c2 00 e9 58 ff ff ff 90 90 90 55 48 89 e5 0f 1f 44 00 00 48 8d 47 08 <c7> 0 
[    4.068250] RIP  [<ffffffff81069bdd>] __init_waitqueue_head+0xd/0x1d
[    4.068250]  RSP <ffff88022b4e1e60>
[    4.068250] CR2: 0000000000000330
[    4.272399] ---[ end trace 6233ae78c1aa3f59 ]---
[    4.277115] Kernel panic - not syncing: Attempted to kill init!
[    4.283124] Pid: 1, comm: swapper Tainted: G      D     2.6.37-rc3-next-20101123+ #35
[    4.291113] Call Trace:
[    4.372943]  [<ffffffff81461637>] panic+0x91/0x19f
[    4.382552]  [<ffffffff810ce579>] ? perf_event_exit_task+0xb8/0x1c7
[    4.435526]  [<ffffffff81052407>] do_exit+0x7a/0x70a
[    4.440582]  [<ffffffff814635bf>] ? _raw_spin_unlock_irqrestore+0x17/0x19
[    4.447455]  [<ffffffff810505a7>] ? kmsg_dump+0x123/0x140
[    4.452942]  [<ffffffff8146496c>] oops_end+0xbf/0xc7
[    4.458021]  [<ffffffff81033288>] no_context+0x1f9/0x208
[    4.463422]  [<ffffffff81033429>] __bad_area_nosemaphore+0x192/0x1b5
[    4.469861]  [<ffffffff8103345f>] bad_area_nosemaphore+0x13/0x15
[    4.475956]  [<ffffffff81466b3b>] do_page_fault+0x187/0x35a
[    4.481631]  [<ffffffff8121b091>] ? ida_get_new_above+0xf9/0x19e
[    4.487728]  [<ffffffff8103dab8>] ? should_resched+0xe/0x2e
[    4.500350]  [<ffffffff8110ae6e>] ? kmem_cache_alloc+0x73/0xe3
[    4.506275]  [<ffffffff81170370>] ? sysfs_find_dirent+0x3f/0x58
[    4.512287]  [<ffffffff81170269>] ? sysfs_addrm_finish+0x2f/0xb9
[    4.518380]  [<ffffffff81463dd5>] page_fault+0x25/0x30
[    4.523607]  [<ffffffff81069bdd>] ? __init_waitqueue_head+0xd/0x1d
[    4.529875]  [<ffffffff81b8f002>] sep_init+0x6c/0x3a5
[    4.535022]  [<ffffffff81b8ef96>] ? sep_init+0x0/0x3a5
[    4.540250]  [<ffffffff8100219b>] do_one_initcall+0x7f/0x138
[    4.545997]  [<ffffffff81b53db9>] kernel_init+0x17d/0x20b
[    4.551498]  [<ffffffff8100aa64>] kernel_thread_helper+0x4/0x10
[    4.557505]  [<ffffffff81b53c3c>] ? kernel_init+0x0/0x20b
[    4.564887]  [<ffffffff8100aa60>] ? kernel_thread_helper+0x0/0x10

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
