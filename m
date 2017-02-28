Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f198.google.com (mail-ua0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9C3756B0038
	for <linux-mm@kvack.org>; Tue, 28 Feb 2017 12:54:09 -0500 (EST)
Received: by mail-ua0-f198.google.com with SMTP id j56so15712171uaa.0
        for <linux-mm@kvack.org>; Tue, 28 Feb 2017 09:54:09 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id h21sor500061vkf.8.1969.12.31.16.00.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 28 Feb 2017 09:54:08 -0800 (PST)
MIME-Version: 1.0
From: Dmitry Vyukov <dvyukov@google.com>
Date: Tue, 28 Feb 2017 18:53:47 +0100
Message-ID: <CACT4Y+Y2fUC9PjPV0i6feksPCCCT51ApNRjZWRpD6U=aezOiGg@mail.gmail.com>
Subject: ipc: use-after-free in shm_get_unmapped_area
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, Michal Hocko <mhocko@suse.com>, Davidlohr Bueso <dave@stgolabs.net>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: syzkaller <syzkaller@googlegroups.com>

Hello,

I've got the following report on e5d56efc97f8240d0b5d66c03949382b6d7e5570:

BUG: KASAN: use-after-free in shm_get_unmapped_area+0xfd/0x120
ipc/shm.c:474 at addr ffff88004f5cc028
Read of size 8 by task syz-executor8/14324
CPU: 0 PID: 14324 Comm: syz-executor8 Not tainted 4.10.0-rc5+ #191
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
Call Trace:
 __asan_report_load8_noabort+0x3e/0x40 mm/kasan/report.c:328
 shm_get_unmapped_area+0xfd/0x120 ipc/shm.c:474
 get_unmapped_area+0x18d/0x300 mm/mmap.c:2077
 do_mmap+0x2aa/0xd40 mm/mmap.c:1346
 do_mmap_pgoff include/linux/mm.h:2031 [inline]
 SYSC_remap_file_pages mm/mmap.c:2782 [inline]
 SyS_remap_file_pages+0x8ec/0xbc0 mm/mmap.c:2698
RIP: 0033:0x445559
RSP: 002b:00007f618dda8b58 EFLAGS: 00000282 ORIG_RAX: 00000000000000d8
RAX: ffffffffffffffda RBX: 0000000020029000 RCX: 0000000000445559
RDX: 0000000000000000 RSI: 0000000000003000 RDI: 0000000020029000
RBP: 00000000006e04f0 R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000282 R12: 0000000000700150
R13: 0000000000000000 R14: 00007f618dda99c0 R15: 00007f618dda9700
Object at ffff88004f5cc000, in cache filp size: 440
Allocated:
PID = 14282
[<ffffffff81a5e5eb>] kmem_cache_zalloc include/linux/slab.h:626 [inline]
[<ffffffff81a5e5eb>] get_empty_filp+0xfb/0x4d0 fs/file_table.c:122
[<ffffffff81a5e9e0>] alloc_file+0x20/0x340 fs/file_table.c:163
[<ffffffff818fa807>] __shmem_file_setup+0x327/0x5a0 mm/shmem.c:4037
[<ffffffff81910baa>] shmem_kernel_file_setup+0x2a/0x40 mm/shmem.c:4063
[<ffffffff820232a3>] newseg+0x803/0xd00 ipc/shm.c:586
[<ffffffff820071da>] ipcget_new ipc/util.c:285 [inline]
[<ffffffff820071da>] ipcget+0x34a/0x7c0 ipc/util.c:639
[<ffffffff82025376>] SYSC_shmget ipc/shm.c:673 [inline]
[<ffffffff82025376>] SyS_shmget+0x166/0x240 ipc/shm.c:657
Freed:
PID = 14985
[<ffffffff81a0a5b1>] kmem_cache_free+0x71/0x240 mm/slab.c:3765
[<ffffffff81a5dabc>] file_free_rcu+0x5c/0x70 fs/file_table.c:49
[<ffffffff81608600>] __rcu_reclaim kernel/rcu/rcu.h:118 [inline]
[<ffffffff81608600>] rcu_do_batch.isra.70+0x9e0/0xdf0 kernel/rcu/tree.c:2780
[<ffffffff81608e82>] invoke_rcu_callbacks kernel/rcu/tree.c:3043 [inline]
[<ffffffff81608e82>] __rcu_process_callbacks kernel/rcu/tree.c:3010 [inline]
[<ffffffff81608e82>] rcu_process_callbacks+0x472/0xc70 kernel/rcu/tree.c:3027


It happened only once and is probably caused by a very tricky race
condition. Not reproducible. Triggered by the following syzkaller
program:

mmap(&(0x7f0000000000/0x4000)=nil, (0x4000), 0x3, 0x32, 0xffffffffffffffff, 0x0)
inotify_init1(0x80800)
r0 = shmget(0x0, (0x3000), 0x0, &(0x7f0000df4000/0x3000)=nil)
shmat(r0, &(0x7f0000029000/0x3000)=nil, 0x0)
r1 = openat$qat_adf_ctl(0xffffffffffffff9c,
&(0x7f0000001000)="2f6465762f7161745f6164665f63746c00", 0x14002, 0x0)
ioctl$DRM_IOCTL_SET_CLIENT_CAP(r1, 0x4010640d, &(0x7f0000029000)={0x0,
0xfffffffffffffffe})
socket(0x5, 0x80805, 0xffffffff)
shmctl(r0, 0x0, &(0x7f0000001000-0x48)={0x0, 0x0, 0x0, 0x0, 0x0, 0x0,
0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0})
ftruncate(r1, 0x4)
request_key(&(0x7f0000002000+0x841)="2f6465762f7161745f6164665f63746c00",
&(0x7f0000003000-0x11)="2f6465762f7161745f6164665f63746c00",
&(0x7f0000003000-0x11)="6e6f6465766c6f76626f786e6574307d00",
0xe9dd4d2436b8a74d)
remap_file_pages(&(0x7f0000029000/0x3000)=nil, (0x3000), 0x0, 0x0, 0x0)

Maybe you can spot some race condition in ipc code.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
