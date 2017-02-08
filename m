Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f199.google.com (mail-ua0-f199.google.com [209.85.217.199])
	by kanga.kvack.org (Postfix) with ESMTP id EF7F76B0033
	for <linux-mm@kvack.org>; Wed,  8 Feb 2017 04:55:49 -0500 (EST)
Received: by mail-ua0-f199.google.com with SMTP id f2so74521869uaf.2
        for <linux-mm@kvack.org>; Wed, 08 Feb 2017 01:55:49 -0800 (PST)
Received: from mail-ua0-x22f.google.com (mail-ua0-x22f.google.com. [2607:f8b0:400c:c08::22f])
        by mx.google.com with ESMTPS id 64si2160575uap.118.2017.02.08.01.55.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Feb 2017 01:55:49 -0800 (PST)
Received: by mail-ua0-x22f.google.com with SMTP id i68so105263940uad.0
        for <linux-mm@kvack.org>; Wed, 08 Feb 2017 01:55:48 -0800 (PST)
MIME-Version: 1.0
From: Dmitry Vyukov <dvyukov@google.com>
Date: Wed, 8 Feb 2017 10:55:28 +0100
Message-ID: <CACT4Y+ZsX1gQHdr7+tqhhB6CeKHBU=4VTMDj-meNbZ=uEPLKWA@mail.gmail.com>
Subject: mm: double-free in cgwb_bdi_init
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Jens Axboe <axboe@fb.com>, Tejun Heo <tj@kernel.org>, xiakaixu@huawei.com, Vlastimil Babka <vbabka@suse.cz>, Joe Perches <joe@perches.com>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@suse.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
Cc: syzkaller <syzkaller@googlegroups.com>

Hello,

syzkaller hit the following report on linux-next
eb60f01302b24ce93108414e2c4c673cb7cd6e05:

BUG: Double free or freeing an invalid pointer
CPU: 0 PID: 15931 Comm: syz-executor2 Not tainted 4.10.0-rc7-next-20170207 #1
Hardware name: Google Google Compute Engine/Google Compute Engine,
BIOS Google 01/01/2011

Call Trace:
 kfree+0xd3/0x250 mm/slab.c:3819
 cgwb_bdi_init mm/backing-dev.c:764 [inline]
 bdi_init+0xbf5/0xed0 mm/backing-dev.c:788
 bdi_setup_and_register+0x70/0x100 mm/backing-dev.c:929
 v9fs_session_init+0x17b/0x1a00 fs/9p/v9fs.c:335
 v9fs_mount+0x81/0x830 fs/9p/vfs_super.c:130
 mount_fs+0x97/0x2e0 fs/super.c:1223
 vfs_kern_mount.part.24+0xc6/0x430 fs/namespace.c:976
 vfs_kern_mount fs/namespace.c:2509 [inline]
 do_new_mount fs/namespace.c:2512 [inline]
 do_mount+0x426/0x2ec0 fs/namespace.c:2834
 SYSC_mount fs/namespace.c:3050 [inline]
 SyS_mount+0xab/0x120 fs/namespace.c:3027
 entry_SYSCALL_64_fastpath+0x1f/0xc2

Object at ffff8801d1c30340, in cache kmalloc-32 size: 32
Allocated:
PID = 15931
[<ffffffff8193e1d6>] kzalloc include/linux/slab.h:638 [inline]
[<ffffffff8193e1d6>] cgwb_bdi_init mm/backing-dev.c:758 [inline]
[<ffffffff8193e1d6>] bdi_init+0x346/0xed0 mm/backing-dev.c:788
[<ffffffff8193f5e0>] bdi_setup_and_register+0x70/0x100 mm/backing-dev.c:929
[<ffffffff8209815b>] v9fs_session_init+0x17b/0x1a00 fs/9p/v9fs.c:335
[<ffffffff82086101>] v9fs_mount+0x81/0x830 fs/9p/vfs_super.c:130
[<ffffffff81a92ff7>] mount_fs+0x97/0x2e0 fs/super.c:1223
[<ffffffff81b0c036>] vfs_kern_mount.part.24+0xc6/0x430 fs/namespace.c:976
[<ffffffff81b16c56>] vfs_kern_mount fs/namespace.c:2509 [inline]
[<ffffffff81b16c56>] do_new_mount fs/namespace.c:2512 [inline]
[<ffffffff81b16c56>] do_mount+0x426/0x2ec0 fs/namespace.c:2834
[<ffffffff81b1a23b>] SYSC_mount fs/namespace.c:3050 [inline]
[<ffffffff81b1a23b>] SyS_mount+0xab/0x120 fs/namespace.c:3027

Freed:
PID = 15931
[<ffffffff81a360d3>] kfree+0xd3/0x250 mm/slab.c:3819
[<ffffffff8193ea97>] wb_congested_put include/linux/backing-dev.h:440 [inline]
[<ffffffff8193ea97>] wb_init mm/backing-dev.c:337 [inline]
[<ffffffff8193ea97>] cgwb_bdi_init mm/backing-dev.c:762 [inline]
[<ffffffff8193ea97>] bdi_init+0xc07/0xed0 mm/backing-dev.c:788
[<ffffffff8193f5e0>] bdi_setup_and_register+0x70/0x100 mm/backing-dev.c:929
[<ffffffff8209815b>] v9fs_session_init+0x17b/0x1a00 fs/9p/v9fs.c:335
[<ffffffff82086101>] v9fs_mount+0x81/0x830 fs/9p/vfs_super.c:130
[<ffffffff81a92ff7>] mount_fs+0x97/0x2e0 fs/super.c:1223
[<ffffffff81b0c036>] vfs_kern_mount.part.24+0xc6/0x430 fs/namespace.c:976
[<ffffffff81b16c56>] vfs_kern_mount fs/namespace.c:2509 [inline]
[<ffffffff81b16c56>] do_new_mount fs/namespace.c:2512 [inline]
[<ffffffff81b16c56>] do_mount+0x426/0x2ec0 fs/namespace.c:2834
[<ffffffff81b1a23b>] SYSC_mount fs/namespace.c:3050 [inline]
[<ffffffff81b1a23b>] SyS_mount+0xab/0x120 fs/namespace.c:3027
[<ffffffff844ca541>] entry_SYSCALL_64_fastpath+0x1f/0xc2


It all happens in the context on a single syscall. Also right before
that there was a bunch of allocation failures:

https://gist.githubusercontent.com/dvyukov/a840e280871136fc9654833e59970342/raw/385864d7584a4575ca5b9e2cc70815b9516b6598/gistfile1.txt

So this looks like a straight double-free on error path.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
