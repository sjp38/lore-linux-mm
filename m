Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id D88928E00E5
	for <linux-mm@kvack.org>; Wed, 12 Dec 2018 20:15:11 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id t2so329907pfj.15
        for <linux-mm@kvack.org>; Wed, 12 Dec 2018 17:15:11 -0800 (PST)
Received: from out30-130.freemail.mail.aliyun.com (out30-130.freemail.mail.aliyun.com. [115.124.30.130])
        by mx.google.com with ESMTPS id m20si320583pgk.323.2018.12.12.17.15.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Dec 2018 17:15:10 -0800 (PST)
Subject: Re: WARNING: locking bug in lock_downgrade
References: <00000000000043ae20057b974f14@google.com>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <f0acc6af-cdd5-0e46-bca5-2e2a9a4c983e@linux.alibaba.com>
Date: Wed, 12 Dec 2018 17:14:59 -0800
MIME-Version: 1.0
In-Reply-To: <00000000000043ae20057b974f14@google.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: syzbot <syzbot+53383ae265fb161ef488@syzkaller.appspotmail.com>, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux@dominikbrodowski.net, mhocko@suse.com, rientjes@google.com, syzkaller-bugs@googlegroups.com, vbabka@suse.cz, Waiman Long <longman@redhat.com>, peterz@infradead.org, "mingo@redhat.com" <mingo@redhat.com>, boqun.feng@gmail.com

Cc'ed Peter, Ingo and Waiman.


It took me a few days to look into this warning, but I got lost in 
lockdep code.


The problem is the commit dd2283f2605e ("mm: mmap: zap pages with read 
mmap_sem in munmap") does an optimization for munmap by downgrading 
write mmap_sem to read before zapping pages. But, lockdep reports 
downgrading a read lock.


I'm pretty sure mmap_sem is held as write before downgrade_write() is 
called in the patch. And, there are 4 places which may downgrade a mmap_sem:

     - munmap

     - mremap

     - brk

     - clear_refs_write (fs/proc/task_mmu.c)


The first three come from my patches, and they just do: 
down_write_killable() -> .. -> downgrade_write().

But the last one is a little bit more complicated, it does down_read() 
->.. -> up_read() ->.. -> down_write_killable() ->.. -> downgrade_write().

And, the last one may be called from any process to touch the other 
processes' mmap_sem.


By looking into lockdep code, I'm not sure if lockdep may get confused 
by such sequence or not?


Any hint is appreciated.


Regards,

Yang



On 11/26/18 12:38 PM, syzbot wrote:
> Hello,
>
> syzbot found the following crash on:
>
> HEAD commit:    e195ca6cb6f2 Merge branch 'for-linus' of 
> git://git.kernel...
> git tree:       upstream
> console output: https://syzkaller.appspot.com/x/log.txt?x=12336ed5400000
> kernel config: https://syzkaller.appspot.com/x/.config?x=73e2bc0cb6463446
> dashboard link: 
> https://syzkaller.appspot.com/bug?extid=53383ae265fb161ef488
> compiler:       gcc (GCC) 8.0.1 20180413 (experimental)
>
> Unfortunately, I don't have any reproducer for this crash yet.
>
> IMPORTANT: if you fix the bug, please add the following tag to the 
> commit:
> Reported-by: syzbot+53383ae265fb161ef488@syzkaller.appspotmail.com
>
>
> ------------[ cut here ]------------
> downgrading a read lock
> WARNING: CPU: 0 PID: 26202 at kernel/locking/lockdep.c:3556 
> __lock_downgrade kernel/locking/lockdep.c:3556 [inline]
> WARNING: CPU: 0 PID: 26202 at kernel/locking/lockdep.c:3556 
> lock_downgrade+0x4d7/0x900 kernel/locking/lockdep.c:3819
> Kernel panic - not syncing: panic_on_warn set ...
> CPU: 0 PID: 26202 Comm: blkid Not tainted 4.20.0-rc3+ #127
> Hardware name: Google Google Compute Engine/Google Compute Engine, 
> BIOS Google 01/01/2011
> Call Trace:
>  __dump_stack lib/dump_stack.c:77 [inline]
>  dump_stack+0x244/0x39d lib/dump_stack.c:113
>  panic+0x2ad/0x55c kernel/panic.c:188
>  __warn.cold.8+0x20/0x45 kernel/panic.c:540
>  report_bug+0x254/0x2d0 lib/bug.c:186
>  fixup_bug arch/x86/kernel/traps.c:178 [inline]
>  do_error_trap+0x11b/0x200 arch/x86/kernel/traps.c:271
>  do_invalid_op+0x36/0x40 arch/x86/kernel/traps.c:290
>  invalid_op+0x14/0x20 arch/x86/entry/entry_64.S:969
> RIP: 0010:__lock_downgrade kernel/locking/lockdep.c:3556 [inline]
> RIP: 0010:lock_downgrade+0x4d7/0x900 kernel/locking/lockdep.c:3819
> Code: 00 00 fc ff df 41 c6 44 05 00 f8 e9 1b ff ff ff 48 c7 c7 60 68 
> 2b 88 4c 89 9d 58 ff ff ff 48 89 85 60 ff ff ff e8 d9 1f e7 ff <0f> 0b 
> 48 8b 85 60 ff ff ff 4c 8d 4d d8 4c 89 e9 48 ba 00 00 00 00
> RSP: 0018:ffff8881ba547b70 EFLAGS: 00010086
> RAX: 0000000000000000 RBX: 1ffff110374a8f74 RCX: 0000000000000000
> RDX: 0000000000000000 RSI: ffffffff8165eaf5 RDI: 0000000000000006
> RBP: ffff8881ba547c28 R08: ffff88817c0b2400 R09: fffffbfff12b2254
> R10: fffffbfff12b2254 R11: ffffffff895912a3 R12: ffffffff8b0f67a0
> R13: ffff8881ba547bc0 R14: 0000000000000001 R15: ffff88817c0b2400
>  downgrade_write+0x76/0x270 kernel/locking/rwsem.c:147
>  __do_munmap+0xcd8/0xf80 mm/mmap.c:2812
>  __vm_munmap+0x138/0x1f0 mm/mmap.c:2837
>  __do_sys_munmap mm/mmap.c:2862 [inline]
>  __se_sys_munmap mm/mmap.c:2859 [inline]
>  __x64_sys_munmap+0x65/0x80 mm/mmap.c:2859
>  do_syscall_64+0x1b9/0x820 arch/x86/entry/common.c:290
>  entry_SYSCALL_64_after_hwframe+0x49/0xbe
> RIP: 0033:0x7f237e5ce417
> Code: f0 ff ff 73 01 c3 48 8d 0d 8a ad 20 00 31 d2 48 29 c2 89 11 48 
> 83 c8 ff eb eb 90 90 90 90 90 90 90 90 90 b8 0b 00 00 00 0f 05 <48> 3d 
> 01 f0 ff ff 73 01 c3 48 8d 0d 5d ad 20 00 31 d2 48 29 c2 89
> RSP: 002b:00007ffe61bed9d8 EFLAGS: 00000203 ORIG_RAX: 000000000000000b
> RAX: ffffffffffffffda RBX: 00007f237e7d91c8 RCX: 00007f237e5ce417
> RDX: 000000000224ff00 RSI: 00000000000033ef RDI: 00007f237e7d1000
> RBP: 00007ffe61bedb40 R08: 0000000000000001 R09: 0000000000000007
> R10: 00007f237e5c8a0b R11: 0000000000000203 R12: 00000000b1f97d00
> R13: 000004b2b1f97d00 R14: 000004b2afd5fdeb R15: 00007f237e7ce740
> Kernel Offset: disabled
> Rebooting in 86400 seconds..
>
>
> ---
> This bug is generated by a bot. It may contain errors.
> See https://goo.gl/tpsmEJ for more information about syzbot.
> syzbot engineers can be reached at syzkaller@googlegroups.com.
>
> syzbot will keep track of this bug report. See:
> https://goo.gl/tpsmEJ#bug-status-tracking for how to communicate with 
> syzbot.
