Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id A11D28E00F9
	for <linux-mm@kvack.org>; Sat,  5 Jan 2019 03:11:09 -0500 (EST)
Received: by mail-io1-f72.google.com with SMTP id h7so44178355iof.19
        for <linux-mm@kvack.org>; Sat, 05 Jan 2019 00:11:09 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r185sor5198050ita.21.2019.01.05.00.11.08
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 05 Jan 2019 00:11:08 -0800 (PST)
MIME-Version: 1.0
References: <000000000000d0ce25057e75e2da@google.com> <000000000000b65931057ea9cf82@google.com>
In-Reply-To: <000000000000b65931057ea9cf82@google.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Sat, 5 Jan 2019 09:10:56 +0100
Message-ID: <CACT4Y+ZsitqhD6RYxMRcwrhnevT48xgd+BU0EJo6uBc-gyT0+w@mail.gmail.com>
Subject: Re: WARNING in mem_cgroup_update_lru_size
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: syzbot <syzbot+c950a368703778078dc8@syzkaller.appspotmail.com>
Cc: cgroups@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Michal Hocko <mhocko@kernel.org>, netdev <netdev@vger.kernel.org>, syzkaller-bugs <syzkaller-bugs@googlegroups.com>, Vladimir Davydov <vdavydov.dev@gmail.com>

On Fri, Jan 4, 2019 at 11:58 PM syzbot
<syzbot+c950a368703778078dc8@syzkaller.appspotmail.com> wrote:
>
> syzbot has found a reproducer for the following crash on:
>
> HEAD commit:    96d4f267e40f Remove 'type' argument from access_ok() funct..
> git tree:       net
> console output: https://syzkaller.appspot.com/x/log.txt?x=160c9a80c00000
> kernel config:  https://syzkaller.appspot.com/x/.config?x=7308e68273924137
> dashboard link: https://syzkaller.appspot.com/bug?extid=c950a368703778078dc8
> compiler:       gcc (GCC) 9.0.0 20181231 (experimental)
> syz repro:      https://syzkaller.appspot.com/x/repro.syz?x=125376bb400000
> C reproducer:   https://syzkaller.appspot.com/x/repro.c?x=121d85ab400000
>
> IMPORTANT: if you fix the bug, please add the following tag to the commit:
> Reported-by: syzbot+c950a368703778078dc8@syzkaller.appspotmail.com

Based on the repro looks like another incarnation of:
#syz dup: kernel panic: stack is corrupted in udp4_lib_lookup2
https://syzkaller.appspot.com/bug?id=4821de869e3d78a255a034bf212a4e009f6125a7



> ------------[ cut here ]------------
> kasan: CONFIG_KASAN_INLINE enabled
> mem_cgroup_update_lru_size(00000000d6ca43c5, 1, 1): lru_size -2032898272
> kasan: GPF could be caused by NULL-ptr deref or user memory access
> WARNING: CPU: 0 PID: 11430 at mm/memcontrol.c:1160
> mem_cgroup_update_lru_size+0xb2/0xe0 mm/memcontrol.c:1160
> general protection fault: 0000 [#1] PREEMPT SMP KASAN
> Kernel panic - not syncing: panic_on_warn set ...
> CPU: 1 PID: 4 Comm:  Not tainted 4.20.0+ #8
> Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS
> Google 01/01/2011
> RIP: 0010:__read_once_size include/linux/compiler.h:191 [inline]
> RIP: 0010:get_running_cputimer include/linux/sched/cputime.h:85 [inline]
> RIP: 0010:account_group_system_time include/linux/sched/cputime.h:149
> [inline]
> RIP: 0010:account_system_index_time+0xe8/0x5f0 kernel/sched/cputime.c:168
> Code: 04 00 00 49 8b 84 24 00 07 00 00 48 ba 00 00 00 00 00 fc ff df 48 8d
> b8 40 01 00 00 48 8d 88 28 01 00 00 48 89 fe 48 c1 ee 03 <0f> b6 14 16 48
> 89 fe 83 e6 07 40 38 f2 7f 08 84 d2 0f 85 93 03 00
> RSP: 0018:ffff8880ae707a80 EFLAGS: 00010006
> RAX: 0000000041b58ab3 RBX: 1ffff11015ce0f54 RCX: 0000000041b58bdb
> RDX: dffffc0000000000 RSI: 000000000836b17e RDI: 0000000041b58bf3
> RBP: ffff8880ae707b48 R08: ffff8880ae71f5f0 R09: ffffffff8a9a805d
> R10: ffffffff8a9a8050 R11: 0000000000000001 R12: ffff8880a94bc440
> R13: 0000000000981859 R14: 0000000000000003 R15: ffff8880ae707b20
> FS:  0000000000000000(0000) GS:ffff8880ae700000(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> CR2: 00000000006dae70 CR3: 0000000086205000 CR4: 00000000001406e0
> DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
> Call Trace:
>   <IRQ>
>   irqtime_account_process_tick.isra.0+0x3a2/0x490 kernel/sched/cputime.c:380
>   account_process_tick+0x27f/0x350 kernel/sched/cputime.c:483
>   update_process_times+0x25/0x80 kernel/time/timer.c:1633
>   tick_sched_handle+0xa2/0x190 kernel/time/tick-sched.c:161
>   tick_sched_timer+0x47/0x130 kernel/time/tick-sched.c:1271
>   __run_hrtimer kernel/time/hrtimer.c:1389 [inline]
>   __hrtimer_run_queues+0x3a7/0x1050 kernel/time/hrtimer.c:1451
>   hrtimer_interrupt+0x314/0x770 kernel/time/hrtimer.c:1509
>   local_apic_timer_interrupt arch/x86/kernel/apic/apic.c:1035 [inline]
>   smp_apic_timer_interrupt+0x18d/0x760 arch/x86/kernel/apic/apic.c:1060
>   apic_timer_interrupt+0xf/0x20 arch/x86/entry/entry_64.S:807
>   </IRQ>
> Modules linked in:
> ---[ end trace 42848964955b563b ]---
> RIP: 0010:__read_once_size include/linux/compiler.h:191 [inline]
> RIP: 0010:get_running_cputimer include/linux/sched/cputime.h:85 [inline]
> RIP: 0010:account_group_system_time include/linux/sched/cputime.h:149
> [inline]
> RIP: 0010:account_system_index_time+0xe8/0x5f0 kernel/sched/cputime.c:168
> Code: 04 00 00 49 8b 84 24 00 07 00 00 48 ba 00 00 00 00 00 fc ff df 48 8d
> b8 40 01 00 00 48 8d 88 28 01 00 00 48 89 fe 48 c1 ee 03 <0f> b6 14 16 48
> 89 fe 83 e6 07 40 38 f2 7f 08 84 d2 0f 85 93 03 00
> RSP: 0018:ffff8880ae707a80 EFLAGS: 00010006
> RAX: 0000000041b58ab3 RBX: 1ffff11015ce0f54 RCX: 0000000041b58bdb
> RDX: dffffc0000000000 RSI: 000000000836b17e RDI: 0000000041b58bf3
> RBP: ffff8880ae707b48 R08: ffff8880ae71f5f0 R09: ffffffff8a9a805d
> R10: ffffffff8a9a8050 R11: 0000000000000001 R12: ffff8880a94bc440
> R13: 0000000000981859 R14: 0000000000000003 R15: ffff8880ae707b20
> FS:  0000000000000000(0000) GS:ffff8880ae700000(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> CR2: 00000000006dae70 CR3: 0000000086205000 CR4: 00000000001406e0
> DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
> Shutting down cpus with NMI
> Kernel Offset: disabled
> Rebooting in 86400 seconds..
>
> --
> You received this message because you are subscribed to the Google Groups "syzkaller-bugs" group.
> To unsubscribe from this group and stop receiving emails from it, send an email to syzkaller-bugs+unsubscribe@googlegroups.com.
> To view this discussion on the web visit https://groups.google.com/d/msgid/syzkaller-bugs/000000000000b65931057ea9cf82%40google.com.
> For more options, visit https://groups.google.com/d/optout.
