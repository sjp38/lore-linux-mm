Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 44E086B0005
	for <linux-mm@kvack.org>; Fri, 22 Jan 2016 17:33:31 -0500 (EST)
Received: by mail-wm0-f46.google.com with SMTP id 123so1882522wmz.0
        for <linux-mm@kvack.org>; Fri, 22 Jan 2016 14:33:31 -0800 (PST)
Received: from mail-wm0-x235.google.com (mail-wm0-x235.google.com. [2a00:1450:400c:c09::235])
        by mx.google.com with ESMTPS id pg6si778978wjb.232.2016.01.22.14.33.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Jan 2016 14:33:30 -0800 (PST)
Received: by mail-wm0-x235.google.com with SMTP id 123so1882184wmz.0
        for <linux-mm@kvack.org>; Fri, 22 Jan 2016 14:33:29 -0800 (PST)
MIME-Version: 1.0
From: Dmitry Vyukov <dvyukov@google.com>
Date: Fri, 22 Jan 2016 23:33:09 +0100
Message-ID: <CACT4Y+YQBU5X2KVKmjR8F3YW2mY1aX6Y_yDzUamQgd2rAP2_AQ@mail.gmail.com>
Subject: fs: use-after-free in link_path_walk
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Viro <viro@zeniv.linux.org.uk>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Hugh Dickins <hughd@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: syzkaller <syzkaller@googlegroups.com>, Kostya Serebryany <kcc@google.com>, Alexander Potapenko <glider@google.com>, Sasha Levin <sasha.levin@oracle.com>, Eric Dumazet <edumazet@google.com>

Hello,

The following program triggers a use-after-free in link_path_walk:
https://gist.githubusercontent.com/dvyukov/fc0da4b914d607ba8129/raw/b761243c44106d74f2173745132c82d179cbdc58/gistfile1.txt

==================================================================
BUG: KASAN: use-after-free in link_path_walk+0xe13/0x1030 at addr
ffff88005f29d6e2
Read of size 1 by task syz-executor/29494
=============================================================================
BUG kmalloc-16 (Not tainted): kasan: bad access detected
-----------------------------------------------------------------------------

INFO: Allocated in shmem_symlink+0x18c/0x600 age=2 cpu=2 pid=29504
[<      none      >] __kmalloc_track_caller+0x28e/0x320 mm/slub.c:4068
[<      none      >] kmemdup+0x24/0x50 mm/util.c:113
[<      none      >] shmem_symlink+0x18c/0x600 mm/shmem.c:2548
[<      none      >] vfs_symlink+0x218/0x3a0 fs/namei.c:3997
[<     inline     >] SYSC_symlinkat fs/namei.c:4024
[<      none      >] SyS_symlinkat+0x1ab/0x230 fs/namei.c:4004
[<      none      >] entry_SYSCALL_64_fastpath+0x16/0x7a
arch/x86/entry/entry_64.S:185

INFO: Freed in shmem_evict_inode+0xa6/0x420 age=12 cpu=2 pid=29504
[<      none      >] kfree+0x2b7/0x2e0 mm/slub.c:3664
[<      none      >] shmem_evict_inode+0xa6/0x420 mm/shmem.c:705
[<      none      >] evict+0x22c/0x500 fs/inode.c:542
[<     inline     >] iput_final fs/inode.c:1477
[<      none      >] iput+0x45f/0x860 fs/inode.c:1504
[<      none      >] do_unlinkat+0x3c0/0x830 fs/namei.c:3939
[<     inline     >] SYSC_unlink fs/namei.c:3980
[<      none      >] SyS_unlink+0x1a/0x20 fs/namei.c:3978
[<      none      >] entry_SYSCALL_64_fastpath+0x16/0x7a
arch/x86/entry/entry_64.S:185

INFO: Slab 0xffffea00017ca700 objects=16 used=12 fp=0xffff88005f29d6e0
flags=0x5fffc0000004080
INFO: Object 0xffff88005f29d6e0 @offset=5856 fp=0xffff88005f29d310
CPU: 3 PID: 29494 Comm: syz-executor Tainted: G    B           4.4.0+ #276
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
 00000000ffffffff ffff88000056fa08 ffffffff82999e2d ffff88003e807900
 ffff88005f29d6e0 ffff88005f29c000 ffff88000056fa38 ffffffff81757354
 ffff88003e807900 ffffea00017ca700 ffff88005f29d6e0 ffff88005f29d6e2

Call Trace:
 [<ffffffff8176092e>] __asan_report_load1_noabort+0x3e/0x40
mm/kasan/report.c:292
 [<ffffffff817deb33>] link_path_walk+0xe13/0x1030 fs/namei.c:1913
 [<ffffffff817df049>] path_lookupat+0x1a9/0x450 fs/namei.c:2120
 [<ffffffff817e6aad>] filename_lookup+0x18d/0x370 fs/namei.c:2155
 [<ffffffff817e6dd0>] user_path_at_empty+0x40/0x50 fs/namei.c:2393
 [<     inline     >] user_path_at include/linux/namei.h:52
 [<ffffffff8185ab29>] do_utimes+0x209/0x280 fs/utimes.c:169
 [<     inline     >] SYSC_utimensat fs/utimes.c:200
 [<ffffffff8185ada3>] SyS_utimensat+0xd3/0x130 fs/utimes.c:185
 [<ffffffff86336c36>] entry_SYSCALL_64_fastpath+0x16/0x7a
arch/x86/entry/entry_64.S:185
==================================================================

On commit 30f05309bde49295e02e45c7e615f73aa4e0ccc2 (Jan 20).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
