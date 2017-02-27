Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f199.google.com (mail-ua0-f199.google.com [209.85.217.199])
	by kanga.kvack.org (Postfix) with ESMTP id 56D706B0038
	for <linux-mm@kvack.org>; Mon, 27 Feb 2017 12:11:33 -0500 (EST)
Received: by mail-ua0-f199.google.com with SMTP id v33so30094973uaf.2
        for <linux-mm@kvack.org>; Mon, 27 Feb 2017 09:11:33 -0800 (PST)
Received: from mail-ua0-x229.google.com (mail-ua0-x229.google.com. [2607:f8b0:400c:c08::229])
        by mx.google.com with ESMTPS id k130si5459566vke.64.2017.02.27.09.11.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Feb 2017 09:11:32 -0800 (PST)
Received: by mail-ua0-x229.google.com with SMTP id f54so33103967uaa.1
        for <linux-mm@kvack.org>; Mon, 27 Feb 2017 09:11:32 -0800 (PST)
MIME-Version: 1.0
From: Dmitry Vyukov <dvyukov@google.com>
Date: Mon, 27 Feb 2017 18:11:11 +0100
Message-ID: <CACT4Y+bAF0Udejr0v7YAXhs753yDdyNtoQbORQ55yEWZ+4Wu5g@mail.gmail.com>
Subject: mm: GPF in bdi_put
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Al Viro <viro@zeniv.linux.org.uk>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Jens Axboe <axboe@fb.com>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Jan Kara <jack@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: syzkaller <syzkaller@googlegroups.com>

Hello,

The following program triggers GPF in bdi_put:
https://gist.githubusercontent.com/dvyukov/15b3e211f937ff6abc558724369066ce/raw/cc017edf57963e30175a6a6fe2b8d917f6e92899/gistfile1.txt

general protection fault: 0000 [#1] SMP KASAN
Modules linked in:
CPU: 0 PID: 2952 Comm: a.out Not tainted 4.10.0+ #229
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
task: ffff880063e72180 task.stack: ffff880064a78000
RIP: 0010:__read_once_size include/linux/compiler.h:247 [inline]
RIP: 0010:atomic_read arch/x86/include/asm/atomic.h:26 [inline]
RIP: 0010:refcount_sub_and_test include/linux/refcount.h:156 [inline]
RIP: 0010:refcount_dec_and_test include/linux/refcount.h:181 [inline]
RIP: 0010:kref_put include/linux/kref.h:71 [inline]
RIP: 0010:bdi_put+0x8b/0x1d0 mm/backing-dev.c:914
RSP: 0018:ffff880064a7f0b0 EFLAGS: 00010202
RAX: 0000000000000007 RBX: 0000000000000000 RCX: 0000000000000000
RDX: ffff880064a7f118 RSI: 0000000000000001 RDI: 0000000000000000
RBP: ffff880064a7f140 R08: ffff880065603280 R09: 0000000000000001
R10: 0000000000000000 R11: 0000000000000001 R12: dffffc0000000000
R13: 0000000000000038 R14: 1ffff1000c94fe17 R15: ffff880064a7f218
FS:  0000000000eb5880(0000) GS:ffff88006d000000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 0000000020914ffa CR3: 000000006bc37000 CR4: 00000000001426f0
Call Trace:
 bdev_evict_inode+0x203/0x3a0 fs/block_dev.c:888
 evict+0x46e/0x980 fs/inode.c:553
 iput_final fs/inode.c:1515 [inline]
 iput+0x589/0xb20 fs/inode.c:1542
 dentry_unlink_inode+0x43b/0x600 fs/dcache.c:343
 __dentry_kill+0x34d/0x740 fs/dcache.c:538
 dentry_kill fs/dcache.c:579 [inline]
 dput.part.27+0x5ce/0x7c0 fs/dcache.c:791
 dput fs/dcache.c:753 [inline]
 do_one_tree+0x43/0x50 fs/dcache.c:1454
 shrink_dcache_for_umount+0xbb/0x2b0 fs/dcache.c:1468
 generic_shutdown_super+0xcd/0x4c0 fs/super.c:421
 kill_anon_super+0x3c/0x50 fs/super.c:988
 deactivate_locked_super+0x88/0xd0 fs/super.c:309
 deactivate_super+0x155/0x1b0 fs/super.c:340
 cleanup_mnt+0xb2/0x160 fs/namespace.c:1112
 __cleanup_mnt+0x16/0x20 fs/namespace.c:1119
 task_work_run+0x18a/0x260 kernel/task_work.c:116
 tracehook_notify_resume include/linux/tracehook.h:191 [inline]
 exit_to_usermode_loop+0x23b/0x2a0 arch/x86/entry/common.c:160
 prepare_exit_to_usermode arch/x86/entry/common.c:190 [inline]
 syscall_return_slowpath+0x4d3/0x570 arch/x86/entry/common.c:259
 entry_SYSCALL_64_fastpath+0xc0/0xc2
RIP: 0033:0x435e19
RSP: 002b:00007ffc9d7f2748 EFLAGS: 00000246 ORIG_RAX: 00000000000000a5
RAX: ffffffffffffffea RBX: 0100000000000000 RCX: 0000000000435e19
RDX: 0000000020063000 RSI: 0000000020914ffa RDI: 0000000020037000
RBP: 00007ffc9d7f2fe0 R08: 0000000020039000 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000246 R12: 0000000000000000
R13: 0000000000402b70 R14: 0000000000402c00 R15: 0000000000000000
Code: 04 f2 f2 f2 c7 40 08 f3 f3 f3 f3 e8 f0 ec de ff 48 8d 45 98 48
8b 95 70 ff ff ff 48 c1 e8 03 42 c6 04 20 04 4c 89 e8 48 c1 e8 03 <42>
0f b6 0c 20 4c 89 e8 83 e0 07 83 c0 03 38 c8 7c 08 84 c9 0f
RIP: __read_once_size include/linux/compiler.h:247 [inline] RSP:
ffff880064a7f0b0
RIP: atomic_read arch/x86/include/asm/atomic.h:26 [inline] RSP: ffff880064a7f0b0
RIP: refcount_sub_and_test include/linux/refcount.h:156 [inline] RSP:
ffff880064a7f0b0
RIP: refcount_dec_and_test include/linux/refcount.h:181 [inline] RSP:
ffff880064a7f0b0
RIP: kref_put include/linux/kref.h:71 [inline] RSP: ffff880064a7f0b0
RIP: bdi_put+0x8b/0x1d0 mm/backing-dev.c:914 RSP: ffff880064a7f0b0
---[ end trace 8991b3d16ac9bf93 ]---

On commit e5d56efc97f8240d0b5d66c03949382b6d7e5570.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
