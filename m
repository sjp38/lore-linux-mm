Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 25BF46B0069
	for <linux-mm@kvack.org>; Thu, 28 Dec 2017 09:09:55 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id f3so23822690pgv.21
        for <linux-mm@kvack.org>; Thu, 28 Dec 2017 06:09:55 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id s82sor9722077pfj.127.2017.12.28.06.09.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 28 Dec 2017 06:09:53 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <82d89066-7dd2-12fe-3cc0-c8d624fe0d51@I-love.SAKURA.ne.jp>
References: <001a11444d0e7bfd7f05609956c6@google.com> <82d89066-7dd2-12fe-3cc0-c8d624fe0d51@I-love.SAKURA.ne.jp>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Thu, 28 Dec 2017 15:09:32 +0100
Message-ID: <CACT4Y+baPvzHB7w8gv=Cger80qoiyOKWO-KPgBAd7mcMD9QNLA@mail.gmail.com>
Subject: Re: INFO: task hung in filemap_fault
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: syzbot <bot+980f5e5fc060c37505bd65abb49a963518b269d9@syzkaller.appspotmail.com>, Andi Kleen <ak@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, jlayton@redhat.com, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Mel Gorman <mgorman@techsingularity.net>, Ingo Molnar <mingo@kernel.org>, npiggin@gmail.com, rgoldwyn@suse.com, syzkaller-bugs@googlegroups.com, Jens Axboe <axboe@kernel.dk>, Ming Lei <tom.leiming@gmail.com>, Hannes Reinecke <hare@suse.de>, Omar Sandoval <osandov@fb.com>, shli@fb.com

On Mon, Dec 18, 2017 at 3:52 PM, Tetsuo Handa
<penguin-kernel@i-love.sakura.ne.jp> wrote:
> On 2017/12/18 17:43, syzbot wrote:
>> Hello,
>>
>> syzkaller hit the following crash on 6084b576dca2e898f5c101baef151f7bfdbb606d
>> git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git/master
>> compiler: gcc (GCC) 7.1.1 20170620
>> .config is attached
>> Raw console output is attached.
>>
>> Unfortunately, I don't have any reproducer for this bug yet.
>>
>
> This log has a lot of mmap() but also has Android's binder messages.
>
> r9 = syz_open_dev$binder(&(0x7f0000000000)='/dev/binder#\x00', 0x0, 0x800)
>
> [   49.200735] binder: 9749:9755 IncRefs 0 refcount change on invalid ref 2 ret -22
> [   49.221514] binder: 9749:9755 Acquire 1 refcount change on invalid ref 4 ret -22
> [   49.233325] binder: 9749:9755 Acquire 1 refcount change on invalid ref 0 ret -22
> [   49.241979] binder: binder_mmap: 9749 205a3000-205a7000 bad vm_flags failed -1
> [   49.256949] binder: 9749:9755 unknown command 0
> [   49.262470] binder: 9749:9755 ioctl c0306201 20000fd0 returned -22
> [   49.293365] binder: 9749:9755 IncRefs 0 refcount change on invalid ref 2 ret -22
> [   49.301297] binder: binder_mmap: 9749 205a3000-205a7000 bad vm_flags failed -1
> [   49.314146] binder: 9749:9755 Acquire 1 refcount change on invalid ref 4 ret -22
> [   49.322732] binder: 9749:9755 Acquire 1 refcount change on invalid ref 0 ret -22
> [   49.332063] binder: 9749:9755 Release 1 refcount change on invalid ref 1 ret -22
> [   49.340796] binder: 9749:9755 Acquire 1 refcount change on invalid ref 2 ret -22
> [   49.349457] binder: 9749:9755 BC_DEAD_BINDER_DONE 0000000000000001 not found
> [   49.349462] binder: 9749:9755 BC_DEAD_BINDER_DONE 0000000000000000 not found
>
> [  246.752088] INFO: task syz-executor7:10280 blocked for more than 120 seconds.
>
> Anything that hung after uptime > 46.75 can be reported at uptime = 246.75, can't it?
>
> Is it possible to reproduce this problem by running the same program?


Hi Tetsuo,

syzbot always re-runs the same workload on a new machine. If it
manages to reproduce the problem, it provides a reproducer. In this
case it didn't.

The program that triggered this is this one (number 7 matches task
syz-executor7):

2017/12/18 06:16:18 executing program 7:

It has only 2 mmaps. The first one is pretty standard, but the second
one mmaps loop device:

r7 = syz_open_dev$loop(&(0x7f0000e58000-0xb)='/dev/loop#\x00', 0x0, 0x4102)
mmap(&(0x7f0000e5b000/0x1000)=nil, 0x1000, 0x3, 0x2011, r7, 0x0)

We have a bunch of hangs around /dev/loop:

https://groups.google.com/forum/#!msg/syzkaller-bugs/qzz2v1M93O4/DjHEEvq5AQAJ
https://groups.google.com/forum/#!msg/syzkaller-bugs/jy-bXYbRh7c/a1dQYyD9CgAJ
https://groups.google.com/forum/#!msg/syzkaller-bugs/vjGYuMMspAU/K3oOF_eHCgAJ
https://groups.google.com/forum/#!msg/syzkaller-bugs/BwpEc6q6gFY/5kHDMGElAgAJ

Probably related to these ones.
+loop maintainers.



>> INFO: task syz-executor7:10280 blocked for more than 120 seconds.
>>       Not tainted 4.15.0-rc3-next-20171214+ #67
>> "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
>> syz-executor7   D    0 10280   3310 0x00000004
>> Call Trace:
>>  context_switch kernel/sched/core.c:2800 [inline]
>>  __schedule+0x30b/0xaf0 kernel/sched/core.c:3376
>>  schedule+0x2e/0x90 kernel/sched/core.c:3435
>>  io_schedule+0x11/0x40 kernel/sched/core.c:5043
>>  wait_on_page_bit_common mm/filemap.c:1099 [inline]
>>  wait_on_page_bit mm/filemap.c:1132 [inline]
>>  wait_on_page_locked include/linux/pagemap.h:530 [inline]
>>  __lock_page_or_retry+0x391/0x3e0 mm/filemap.c:1310
>>  lock_page_or_retry include/linux/pagemap.h:510 [inline]
>>  filemap_fault+0x61c/0xa70 mm/filemap.c:2532
>>  __do_fault+0x23/0xa4 mm/memory.c:3206
>>  do_read_fault mm/memory.c:3616 [inline]
>>  do_fault mm/memory.c:3716 [inline]
>>  handle_pte_fault mm/memory.c:3947 [inline]
>>  __handle_mm_fault+0x10b5/0x1930 mm/memory.c:4071
>>  handle_mm_fault+0x215/0x450 mm/memory.c:4108
>>  faultin_page mm/gup.c:502 [inline]
>>  __get_user_pages+0x1ff/0x980 mm/gup.c:699
>>  populate_vma_page_range+0xa1/0xb0 mm/gup.c:1200
>>  __mm_populate+0xcc/0x190 mm/gup.c:1250
>>  mm_populate include/linux/mm.h:2233 [inline]
>>  vm_mmap_pgoff+0x103/0x110 mm/util.c:338
>>  SYSC_mmap_pgoff mm/mmap.c:1533 [inline]
>>  SyS_mmap_pgoff+0x215/0x2c0 mm/mmap.c:1491
>>  SYSC_mmap arch/x86/kernel/sys_x86_64.c:100 [inline]
>>  SyS_mmap+0x16/0x20 arch/x86/kernel/sys_x86_64.c:91
>>  entry_SYSCALL_64_fastpath+0x1f/0x96
>> RIP: 0033:0x452a09
>> RSP: 002b:00007efce66dac58 EFLAGS: 00000212 ORIG_RAX: 0000000000000009
>> RAX: ffffffffffffffda RBX: 000000000071bea0 RCX: 0000000000452a09
>> RDX: 0000000000000003 RSI: 0000000000001000 RDI: 0000000020e5b000
>> RBP: 0000000000000033 R08: 0000000000000016 R09: 0000000000000000
>> R10: 0000000000002011 R11: 0000000000000212 R12: 00000000006ed568
>> R13: 00000000ffffffff R14: 00007efce66db6d4 R15: 0000000000000000
>
> --
> You received this message because you are subscribed to the Google Groups "syzkaller-bugs" group.
> To unsubscribe from this group and stop receiving emails from it, send an email to syzkaller-bugs+unsubscribe@googlegroups.com.
> To view this discussion on the web visit https://groups.google.com/d/msgid/syzkaller-bugs/82d89066-7dd2-12fe-3cc0-c8d624fe0d51%40I-love.SAKURA.ne.jp.
> For more options, visit https://groups.google.com/d/optout.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
