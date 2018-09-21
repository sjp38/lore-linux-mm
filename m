Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua1-f71.google.com (mail-ua1-f71.google.com [209.85.222.71])
	by kanga.kvack.org (Postfix) with ESMTP id 62A348E0001
	for <linux-mm@kvack.org>; Fri, 21 Sep 2018 15:30:57 -0400 (EDT)
Received: by mail-ua1-f71.google.com with SMTP id g19-v6so3505359uah.10
        for <linux-mm@kvack.org>; Fri, 21 Sep 2018 12:30:57 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 133-v6sor11078052vkr.46.2018.09.21.12.30.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 21 Sep 2018 12:30:56 -0700 (PDT)
MIME-Version: 1.0
References: <000000000000c691670575803b0c@google.com>
In-Reply-To: <000000000000c691670575803b0c@google.com>
From: =?UTF-8?Q?Ya=C4=9Fmur_Oymak?= <yagmur.oymak@gmail.com>
Date: Fri, 21 Sep 2018 22:30:29 +0300
Message-ID: <CAJpGMOtgrzdESgu9Je4iMQSDgDfuYbnrysrPrD4EiN3Po8X0mg@mail.gmail.com>
Subject: Re: BUG: Bad page map (3)
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: akpm@linux-foundation.org, christian.koenig@amd.com, dan.j.williams@intel.com, dave@stgolabs.net, dwmw@amazon.co.uk, linux@dominikbrodowski.net, mhocko@suse.com, rientjes@google.com, syzkaller-bugs@googlegroups.com

Hello,
I see that syzbot found the following crash.
syzbot <syzbot+0b10582e8ee2a6253de7@syzkaller.appspotmail.com> wrote:
> BUG: Bad page map in process syz-executor3  pte:ffffffff8901f947
> pmd:18d73f067
> addr:000000006b20cb06 vm_flags:180400fb anon_vma:          (null)
> mapping:000000007878cb6c index:b7
> file:kcov fault:          (null) mmap:kcov_mmap readpage:          (null)
> CPU: 0 PID: 19022 Comm: syz-executor3 Not tainted 4.19.0-rc2+ #4
> Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS
> Google 01/01/2011
> Call Trace:
>   __dump_stack lib/dump_stack.c:77 [inline]
>   dump_stack+0x1c4/0x2b4 lib/dump_stack.c:113
>   print_bad_pte.cold.111+0x1e6/0x24b mm/memory.c:773
>   _vm_normal_page+0x248/0x3c0 mm/memory.c:859
>   zap_pte_range mm/memory.c:1311 [inline]
>   zap_pmd_range mm/memory.c:1440 [inline]
>   zap_pud_range mm/memory.c:1469 [inline]
>   zap_p4d_range mm/memory.c:1490 [inline]
>   unmap_page_range+0x9a5/0x2000 mm/memory.c:1511
>   unmap_single_vma+0x19b/0x310 mm/memory.c:1556
>   unmap_vmas+0x125/0x200 mm/memory.c:1586
>   exit_mmap+0x2be/0x590 mm/mmap.c:3093
>   __mmput kernel/fork.c:1001 [inline]
>   mmput+0x247/0x610 kernel/fork.c:1022
>   exit_mm kernel/exit.c:545 [inline]
>   do_exit+0xe6f/0x2610 kernel/exit.c:854
>   do_group_exit+0x177/0x440 kernel/exit.c:970
>   get_signal+0x8b0/0x1980 kernel/signal.c:2513
>   do_signal+0x9c/0x21e0 arch/x86/kernel/signal.c:816
>   exit_to_usermode_loop+0x2e5/0x380 arch/x86/entry/common.c:162
>   prepare_exit_to_usermode arch/x86/entry/common.c:197 [inline]
>   syscall_return_slowpath arch/x86/entry/common.c:268 [inline]
>   do_syscall_64+0x6be/0x820 arch/x86/entry/common.c:293
>   entry_SYSCALL_64_after_hwframe+0x49/0xbe
> RIP: 0033:0x457099
> Code: Bad RIP value.
> RSP: 002b:00007f9decd04cf8 EFLAGS: 00000246 ORIG_RAX: 00000000000000ca
> RAX: fffffffffffffe00 RBX: 00000000009300a8 RCX: 0000000000457099
> RDX: 0000000000000000 RSI: 0000000000000080 RDI: 00000000009300a8
> RBP: 00000000009300a0 R08: 0000000000000000 R09: 0000000000000000
> R10: 0000000000000000 R11: 0000000000000246 R12: 00000000009300ac
> R13: 00007ffe4545d67f R14: 00007f9decd059c0 R15: 0000000000000000

I'm running the 4.18.8 kernel on Fedora (uname -r is
4.18.8-200.fc28.x86_64). Suddenly, my computer freezed completely.
After a reboot, I've found the following in the logs:
swap_info_get: Bad swap offset entry 1ffffffffffff
BUG: Bad page map in process gdbus  pte:400000000000000 pmd:a9ed2067
addr:00000000bd2fe465 vm_flags:08000070 anon_vma:          (null) map>
file:libgvfsdbus.so fault:ext4_filemap_fault mmap:ext4_file_mmap read>
CPU: 2 PID: 21057 Comm: gdbus Tainted: G    B      OE     4.18.8-200.>
Hardware name: ASUS All Series/Z97-K, BIOS 2305 10/09/2014
Call Trace:
 dump_stack+0x5c/0x80
 print_bad_pte.cold.102+0x9a/0xc4
 ? __swap_info_get.cold.49+0x2f/0x4b
 unmap_page_range+0x85d/0xba0
 unmap_vmas+0x7a/0xb0
 exit_mmap+0xaa/0x190
 mmput+0x5f/0x130
 do_exit+0x280/0xae0
 do_group_exit+0x3a/0xa0
 get_signal+0x276/0x590
 do_signal+0x36/0x610
 exit_to_usermode_loop+0x71/0xd0
 do_syscall_64+0x14d/0x160
 entry_SYSCALL_64_after_hwframe+0x44/0xa9
RIP: 0033:0x7f02c71f93e9
Code: Bad RIP value.
RSP: 002b:00007f02bf7fdce0 EFLAGS: 00000293 ORIG_RAX: 0000000000000007
RAX: fffffffffffffdfc RBX: 00007f02c001f950 RCX: 00007f02c71f93e9
RDX: 00000000ffffffff RSI: 0000000000000001 RDI: 00007f02c001f950
RBP: 0000000000000001 R08: 0000000000000000 R09: 00007f02c001d898
R10: 00007f02c0005280 R11: 0000000000000293 R12: 00000000ffffffff
R13: 00007f02c7b85520 R14: 00000000ffffffff R15: 0000000000000002
BUG: Bad rss-counter state mm:000000003b7d4ec4 idx:2 val:-1

The bug reported by syzbot is very recent and the stack trace looks
like the one I encountered, so I decided to post here.
Unfortunately, I'm running a distribution kernel and my kernel is
tainted (WireGuard module). I will try to reproduce it with a vanilla
kernel and without any out-of-tree modules, if having a human
reproducer would be of any help.

Thanks,
Yagmur Oymak
