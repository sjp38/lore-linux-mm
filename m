Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id 00D3E6B0005
	for <linux-mm@kvack.org>; Tue,  2 Feb 2016 16:14:38 -0500 (EST)
Received: by mail-wm0-f54.google.com with SMTP id 128so137433145wmz.1
        for <linux-mm@kvack.org>; Tue, 02 Feb 2016 13:14:37 -0800 (PST)
Received: from mail-wm0-x231.google.com (mail-wm0-x231.google.com. [2a00:1450:400c:c09::231])
        by mx.google.com with ESMTPS id g10si4757661wjx.188.2016.02.02.13.14.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Feb 2016 13:14:36 -0800 (PST)
Received: by mail-wm0-x231.google.com with SMTP id l66so136086312wml.0
        for <linux-mm@kvack.org>; Tue, 02 Feb 2016 13:14:36 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.LNX.2.00.1602022204190.22727@cbobk.fhfr.pm>
References: <CACT4Y+ZqQte+9Uk2FsixfWw7sAR7E5rK_BBr8EJe1M+Sv-i_RQ@mail.gmail.com>
 <alpine.LNX.2.00.1602022204190.22727@cbobk.fhfr.pm>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Tue, 2 Feb 2016 22:14:16 +0100
Message-ID: <CACT4Y+YHX-P0X8Y8530FoG2weg39edujD=1JyXZf6c67FM_xzw@mail.gmail.com>
Subject: Re: mm: uninterruptable tasks hanged on mmap_sem
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiri Kosina <jikos@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Oleg Nesterov <oleg@redhat.com>, Konstantin Khlebnikov <koct9i@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Takashi Iwai <tiwai@suse.de>, syzkaller <syzkaller@googlegroups.com>, Kostya Serebryany <kcc@google.com>, Alexander Potapenko <glider@google.com>, Sasha Levin <sasha.levin@oracle.com>

On Tue, Feb 2, 2016 at 10:08 PM, Jiri Kosina <jikos@kernel.org> wrote:
> On Tue, 2 Feb 2016, Dmitry Vyukov wrote:
>
>> Hello,
>>
>> If the following program run in a parallel loop, eventually it leaves
>> hanged uninterruptable tasks on mmap_sem.
>>
>> [ 4074.740298] sysrq: SysRq : Show Locks Held
>> [ 4074.740780] Showing all locks held in the system:
>> ...
>> [ 4074.762133] 1 lock held by a.out/1276:
>> [ 4074.762427]  #0:  (&mm->mmap_sem){++++++}, at: [<ffffffff816df89c>]
>> __mm_populate+0x25c/0x350
>> [ 4074.763149] 1 lock held by a.out/1147:
>> [ 4074.763438]  #0:  (&mm->mmap_sem){++++++}, at: [<ffffffff816b3bbc>]
>> vm_mmap_pgoff+0x12c/0x1b0
>> [ 4074.764164] 1 lock held by a.out/1284:
>> [ 4074.764447]  #0:  (&mm->mmap_sem){++++++}, at: [<ffffffff816df89c>]
>> __mm_populate+0x25c/0x350
>> [ 4074.765287]
>>
>> They all look as follows:
>>
>> # cat /proc/1284/task/**/stack
>> [<ffffffff82c14d13>] call_rwsem_down_write_failed+0x13/0x20
>> [<ffffffff816b3bbc>] vm_mmap_pgoff+0x12c/0x1b0
>> [<ffffffff81700c58>] SyS_mmap_pgoff+0x208/0x580
>> [<ffffffff811aeeb6>] SyS_mmap+0x16/0x20
>> [<ffffffff86660276>] entry_SYSCALL_64_fastpath+0x16/0x7a
>> [<ffffffffffffffff>] 0xffffffffffffffff
>> [<ffffffff8164893e>] wait_on_page_bit+0x1de/0x210
>> [<ffffffff8165572b>] filemap_fault+0xfeb/0x14d0
>> [<ffffffff816e1972>] __do_fault+0x1b2/0x3e0
>> [<ffffffff816f080e>] handle_mm_fault+0x1b4e/0x49a0
>> [<ffffffff816ddae0>] __get_user_pages+0x2c0/0x11a0
>> [<ffffffff816df5a8>] populate_vma_page_range+0x198/0x230
>> [<ffffffff816df83b>] __mm_populate+0x1fb/0x350
>> [<ffffffff816f90c1>] do_mlock+0x291/0x360
>> [<ffffffff816f962b>] SyS_mlock2+0x4b/0x70
>> [<ffffffff86660276>] entry_SYSCALL_64_fastpath+0x16/0x7a
>> [<ffffffffffffffff>] 0xffffffffffffffff
>
> This stacktrace is odd.

Here it is with line numbers and inlined frames if it helps:

[<ffffffff82c14d13>] call_rwsem_down_write_failed+0x13/0x20
arch/x86/lib/rwsem.S:99
[<ffffffff816b3bbc>] vm_mmap_pgoff+0x12c/0x1b0 mm/util.c:327
[<     inline     >] SYSC_mmap_pgoff mm/mmap.c:1453
[<ffffffff81700c58>] SyS_mmap_pgoff+0x208/0x580 mm/mmap.c:1411
[<     inline     >] SYSC_mmap arch/x86/kernel/sys_x86_64.c:95
[<ffffffff811aeeb6>] SyS_mmap+0x16/0x20 arch/x86/kernel/sys_x86_64.c:86
[<ffffffff86660276>] entry_SYSCALL_64_fastpath+0x16/0x7a
arch/x86/entry/entry_64.S:185

[<ffffffff8164893e>] wait_on_page_bit+0x1de/0x210 mm/filemap.c:762
[<     inline     >] wait_on_page_locked include/linux/pagemap.h:526
[<ffffffff8165572b>] filemap_fault+0xfeb/0x14d0 mm/filemap.c:2118
[<ffffffff816e1972>] __do_fault+0x1b2/0x3e0 mm/memory.c:2778
[<     inline     >] do_cow_fault mm/memory.c:3008
[<     inline     >] do_fault mm/memory.c:3136
[<     inline     >] handle_pte_fault mm/memory.c:3308
[<     inline     >] __handle_mm_fault mm/memory.c:3418
[<ffffffff816f080e>] handle_mm_fault+0x1b4e/0x49a0 mm/memory.c:3447
[<     inline     >] faultin_page mm/gup.c:375
[<ffffffff816ddae0>] __get_user_pages+0x2c0/0x11a0 mm/gup.c:568
[<ffffffff816df5a8>] populate_vma_page_range+0x198/0x230 mm/gup.c:992
[<ffffffff816df83b>] __mm_populate+0x1fb/0x350 mm/gup.c:1042
[<ffffffff816f90c1>] do_mlock+0x291/0x360 mm/mlock.c:650
[<     inline     >] SYSC_mlock2 mm/mlock.c:671
[<ffffffff816f962b>] SyS_mlock2+0x4b/0x70 mm/mlock.c:661
[<ffffffff86660276>] entry_SYSCALL_64_fastpath+0x16/0x7a
arch/x86/entry/entry_64.S:185



>> # cat /proc/1284/status
>> Name: a.out
>> State: D (disk sleep)
>> Tgid: 1147
>> Ngid: 0
>> Pid: 1284
>> PPid: 28436
>> TracerPid: 0
>> Uid: 0 0 0 0
>> Gid: 0 0 0 0
>> FDSize: 64
>> Groups: 0
>> NStgid: 1147
>> NSpid: 1284
>> NSpgid: 28436
>> NSsid: 6529
>> VmPeak:   50356 kB
>> VmSize:   50356 kB
>> VmLck:      16 kB
>> VmPin:       0 kB
>> VmHWM:       8 kB
>> VmRSS:       8 kB
>> RssAnon:       8 kB
>> RssFile:       0 kB
>> RssShmem:       0 kB
>> VmData:   49348 kB
>> VmStk:     136 kB
>> VmExe:     828 kB
>> VmLib:       8 kB
>> VmPTE:      44 kB
>> VmPMD:      12 kB
>> VmSwap:       0 kB
>> HugetlbPages:       0 kB
>> Threads: 2
>> SigQ: 1/3189
>> SigPnd: 0000000000000100
>> ShdPnd: 0000000000000100
>> SigBlk: 0000000000000000
>> SigIgn: 0000000000000000
>> SigCgt: 0000000180000000
>> CapInh: 0000000000000000
>> CapPrm: 0000003fffffffff
>> CapEff: 0000003fffffffff
>> CapBnd: 0000003fffffffff
>> CapAmb: 0000000000000000
>> Seccomp: 0
>> Cpus_allowed: f
>> Cpus_allowed_list: 0-3
>> Mems_allowed: 00000000,00000003
>> Mems_allowed_list: 0-1
>> voluntary_ctxt_switches: 3
>> nonvoluntary_ctxt_switches: 1
>>
>>
>> There are no BUGs, WARNINGs, stalls on console.
>>
>> Not sure if its mm or floppy fault.
>
> <joke, but not really>I am pretty sure that it's floppy fault,
> even before I looked at the reproducer</joke>
>
>>
>>
>> // autogenerated by syzkaller (http://github.com/google/syzkaller)
>> #include <pthread.h>
>> #include <stdint.h>
>> #include <string.h>
>> #include <sys/syscall.h>
>> #include <unistd.h>
>>
>> #ifndef SYS_mlock2
>> #define SYS_mlock2 325
>> #endif
>>
>> long r[7];
>>
>> void* thr(void* arg)
>> {
>>   switch ((long)arg) {
>>   case 0:
>>     r[0] = syscall(SYS_mmap, 0x20000000ul, 0x1000ul, 0x3ul, 0x32ul,
>>                    0xfffffffffffffffful, 0x0ul);
>>     break;
>>   case 1:
>>     memcpy((void*)0x20000000, "\x2f\x64\x65\x76\x2f\x66\x64\x23", 8);
>>     r[2] = syscall(SYS_open, "/dev/fd0", 0x800ul, 0, 0, 0);
>
> Just to make sure -- I guess that this is a minimal testcase already,
> right? IOW, if you eliminate the open(/dev/fd0) call, the bug will vanish?
>
> I'll try to reproduce this later tonight or tomorrow.


I have not tried to remove it, but my gut feeling says that it is necessary :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
