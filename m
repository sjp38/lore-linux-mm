Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f198.google.com (mail-ua0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4FE836B0038
	for <linux-mm@kvack.org>; Tue, 28 Feb 2017 12:56:17 -0500 (EST)
Received: by mail-ua0-f198.google.com with SMTP id j56so15744216uaa.0
        for <linux-mm@kvack.org>; Tue, 28 Feb 2017 09:56:17 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id d143sor502836vkf.24.1969.12.31.16.00.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 28 Feb 2017 09:56:16 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20170227182755.GR29622@ZenIV.linux.org.uk>
References: <CACT4Y+bAF0Udejr0v7YAXhs753yDdyNtoQbORQ55yEWZ+4Wu5g@mail.gmail.com>
 <20170227182755.GR29622@ZenIV.linux.org.uk>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Tue, 28 Feb 2017 18:55:55 +0100
Message-ID: <CACT4Y+aOOc3AKsm80y4Rr7rChB=BUmfBvy+Kud2C_8EGnAZ2hg@mail.gmail.com>
Subject: Re: mm: GPF in bdi_put
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Al Viro <viro@zeniv.linux.org.uk>
Cc: "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Jens Axboe <axboe@fb.com>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Jan Kara <jack@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, syzkaller <syzkaller@googlegroups.com>

On Mon, Feb 27, 2017 at 7:27 PM, Al Viro <viro@zeniv.linux.org.uk> wrote:
> On Mon, Feb 27, 2017 at 06:11:11PM +0100, Dmitry Vyukov wrote:
>> Hello,
>>
>> The following program triggers GPF in bdi_put:
>> https://gist.githubusercontent.com/dvyukov/15b3e211f937ff6abc558724369066ce/raw/cc017edf57963e30175a6a6fe2b8d917f6e92899/gistfile1.txt
>
> What happens is
>         * attempt of, essentially, mount -t bdev ..., calls mount_pseudo()
> and then promptly destroys the new instance it has created.
>         * the only inode created on that sucker (root directory, that
> is) gets evicted.
>         * most of ->evict_inode() is harmless, until it gets to
>         if (bdev->bd_bdi != &noop_backing_dev_info)
>                 bdi_put(bdev->bd_bdi);
>
> added there by "block: Make blk_get_backing_dev_info() safe without open bdev".
> Since ->bd_bdi hadn't been initialized for that sucker (the same patch has
> placed initialization into bdget()), we step into shit of varying nastiness,
> depending on phase of moon, etc.
>
> Could somebody explain WTF do we have those two lines in bdev_evict_inode(),
> anyway?  We set ->bd_bdi to something other than noop_backing_dev_info only
> in __blkdev_get() when ->bd_openers goes from zero to positive, so why is
> the matching bdi_put() not in __blkdev_put()?  Jan?


I am also seeing the following crashes on
linux-next/8d01c069486aca75b8f6018a759215b0ed0c91f0. Do you think it's
the same underlying issue?

kasan: GPF could be caused by NULL-ptr deref or user memory access
general protection fault: 0000 [#1] SMP KASAN
Dumping ftrace buffer:
   (ftrace buffer empty)
Modules linked in:
CPU: 0 PID: 19552 Comm: syz-executor2 Not tainted 4.10.0-next-20170228+ #2
Hardware name: Google Google Compute Engine/Google Compute Engine,
BIOS Google 01/01/2011
task: ffff8801c16ae400 task.stack: ffff880154c98000
RIP: 0010:__read_once_size include/linux/compiler.h:254 [inline]
RIP: 0010:atomic_read arch/x86/include/asm/atomic.h:26 [inline]
RIP: 0010:refcount_sub_and_test+0x82/0x1f0 lib/refcount.c:120
RSP: 0018:ffff880154c9f078 EFLAGS: 00010202
RAX: 0000000000000007 RBX: dffffc0000000000 RCX: ffffc90001a8f000
RDX: 0000000000000740 RSI: ffffffff8246160f RDI: 0000000000000001
RBP: ffff880154c9f110 R08: ffffe8ffffc29a28 R09: 0000000000000001
R10: 1ffff1002a993dcc R11: 0000000000000001 R12: 0000000000000038
R13: 0000000000000001 R14: ffff880154c9f0e8 R15: 1ffff1002a993e11
FS:  00007f0335223700(0000) GS:ffff8801dbe00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 0000000020fd3ff8 CR3: 00000001c4580000 CR4: 00000000001406f0
DR0: 0000000020000000 DR1: 0000000020001000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000600
Call Trace:
 refcount_dec_and_test+0x1a/0x20 lib/refcount.c:153
 kref_put include/linux/kref.h:71 [inline]
 bdi_put+0x19/0x40 mm/backing-dev.c:914
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
RIP: 0033:0x44fb79
RSP: 002b:00007f0335222b58 EFLAGS: 00000212 ORIG_RAX: 00000000000000a5
RAX: ffffffffffffffea RBX: 0000000000708150 RCX: 000000000044fb79
RDX: 000000002064e000 RSI: 00000000208f8ff8 RDI: 0000000020b28ff8
RBP: 00000000000002f7 R08: 0000000000000000 R09: 0000000000000000
R10: 8000000000000001 R11: 0000000000000212 R12: 0000000020b28ff8
R13: 00000000208f8ff8 R14: 000000002064e000 R15: 0000000000000000
Code: 00 f1 f1 f1 f1 c7 40 04 04 f2 f2 f2 c7 40 08 f3 f3 f3 f3 e8 71
02 2d ff 48 8d 45 98 48 c1 e8 03 c6 04 18 04 4c 89 e0 48 c1 e8 03 <0f>
b6 14 18 4c 89 e0 83 e0 07 83 c0 03 38 d0 7c 08 84 d2 0f 85
RIP: __read_once_size include/linux/compiler.h:254 [inline] RSP:
ffff880154c9f078
RIP: atomic_read arch/x86/include/asm/atomic.h:26 [inline] RSP: ffff880154c9f078
RIP: refcount_sub_and_test+0x82/0x1f0 lib/refcount.c:120 RSP: ffff880154c9f078
---[ end trace 3457479bd0ed5045 ]---

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
