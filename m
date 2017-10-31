Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id D2DBF6B0268
	for <linux-mm@kvack.org>; Tue, 31 Oct 2017 08:42:29 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id k9so43349031iok.4
        for <linux-mm@kvack.org>; Tue, 31 Oct 2017 05:42:29 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w129sor931143ith.3.2017.10.31.05.42.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 31 Oct 2017 05:42:28 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <b9c543d1-27f9-8db7-238e-7c1305b1bff5@suse.cz>
References: <94eb2c0433c8f42cac055cc86991@google.com> <CACT4Y+YtdzYFPZfs0gjDtuHqkkZdRNwKfe-zBJex_uXUevNtBg@mail.gmail.com>
 <b9c543d1-27f9-8db7-238e-7c1305b1bff5@suse.cz>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Tue, 31 Oct 2017 15:42:07 +0300
Message-ID: <CACT4Y+ZzrcHAUSG25HSi7ybKJd8gxDtimXHE_6UsowOT3wcT5g@mail.gmail.com>
Subject: Re: KASAN: use-after-free Read in __do_page_fault
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: syzbot <bot+6a5269ce759a7bb12754ed9622076dc93f65a1f6@syzkaller.appspotmail.com>, Jan Beulich <JBeulich@suse.com>, "H. Peter Anvin" <hpa@zytor.com>, Josh Poimboeuf <jpoimboe@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, ldufour@linux.vnet.ibm.com, LKML <linux-kernel@vger.kernel.org>, Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@redhat.com>, syzkaller-bugs@googlegroups.com, Thomas Gleixner <tglx@linutronix.de>, the arch/x86 maintainers <x86@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org

On Tue, Oct 31, 2017 at 3:00 PM, Vlastimil Babka <vbabka@suse.cz> wrote:
> On 10/30/2017 08:15 PM, Dmitry Vyukov wrote:
>> On Mon, Oct 30, 2017 at 10:12 PM, syzbot
>> <bot+6a5269ce759a7bb12754ed9622076dc93f65a1f6@syzkaller.appspotmail.com>
>> wrote:
>>> Hello,
>>>
>>> syzkaller hit the following crash on
>>> 887c8ba753fbe809ba93fa3cfd0cc46db18d37d4
>>> git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/master
>>> compiler: gcc (GCC) 7.1.1 20170620
>>> .config is attached
>>> Raw console output is attached.
>>>
>>> syzkaller reproducer is attached. See https://goo.gl/kgGztJ
>>> for information about syzkaller reproducers
>>>
>>>
>>> BUG: KASAN: use-after-free in arch_local_irq_enable
>>> arch/x86/include/asm/paravirt.h:787 [inline]
>>> BUG: KASAN: use-after-free in __do_page_fault+0xc03/0xd60
>>> arch/x86/mm/fault.c:1357
>>> Read of size 8 at addr ffff8801cbfd3090 by task syz-executor7/3660
>
> Why would local_irq_enable() touch a vma object? Is the stack unwinder
> confused or what?
> arch/x86/mm/fault.c:1357 means the "else" path of if (user_mode(regs)),
> but the page fault's RIP is userspace? Strange.
>
>>> CPU: 1 PID: 3660 Comm: syz-executor7 Not tainted 4.14.0-rc3+ #23
>>> Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS
>>> Google 01/01/2011
>>> Call Trace:
>>>  __dump_stack lib/dump_stack.c:16 [inline]
>>>  dump_stack+0x194/0x257 lib/dump_stack.c:52
>>>  print_address_description+0x73/0x250 mm/kasan/report.c:252
>>>  kasan_report_error mm/kasan/report.c:351 [inline]
>>>  kasan_report+0x25b/0x340 mm/kasan/report.c:409
>>>  __asan_report_load8_noabort+0x14/0x20 mm/kasan/report.c:430
>>>  arch_local_irq_enable arch/x86/include/asm/paravirt.h:787 [inline]
>>>  __do_page_fault+0xc03/0xd60 arch/x86/mm/fault.c:1357
>>>  do_page_fault+0xee/0x720 arch/x86/mm/fault.c:1520
>>>  page_fault+0x22/0x30 arch/x86/entry/entry_64.S:1066
>>> RIP: 0023:0x8073f4f
>>> RSP: 002b:00000000f7f89bd0 EFLAGS: 00010202
>>> RAX: 00000000f7f89c8c RBX: 0000000000000400 RCX: 000000000000000e
>>> RDX: 00000000f7f8aa88 RSI: 0000000020012fe0 RDI: 00000000f7f89c8c
>>> RBP: 0000000008128000 R08: 0000000000000000 R09: 0000000000000000
>>> R10: 0000000000000000 R11: 0000000000000292 R12: 0000000000000000
>>> R13: 0000000000000000 R14: 0000000000000000 R15: 0000000000000000
>>>
>>> Allocated by task 3660:
>>>  save_stack_trace+0x16/0x20 arch/x86/kernel/stacktrace.c:59
>>>  save_stack+0x43/0xd0 mm/kasan/kasan.c:447
>>>  set_track mm/kasan/kasan.c:459 [inline]
>>>  kasan_kmalloc+0xad/0xe0 mm/kasan/kasan.c:551
>>>  kasan_slab_alloc+0x12/0x20 mm/kasan/kasan.c:489
>>>  kmem_cache_alloc+0x12e/0x760 mm/slab.c:3561
>>>  kmem_cache_zalloc include/linux/slab.h:656 [inline]
>>>  mmap_region+0x7ee/0x15a0 mm/mmap.c:1658
>>>  do_mmap+0x6a1/0xd50 mm/mmap.c:1468
>>>  do_mmap_pgoff include/linux/mm.h:2150 [inline]
>>>  vm_mmap_pgoff+0x1de/0x280 mm/util.c:333
>>>  SYSC_mmap_pgoff mm/mmap.c:1518 [inline]
>>>  SyS_mmap_pgoff+0x23b/0x5f0 mm/mmap.c:1476
>>>  do_syscall_32_irqs_on arch/x86/entry/common.c:329 [inline]
>>>  do_fast_syscall_32+0x3f2/0xf05 arch/x86/entry/common.c:391
>>>  entry_SYSENTER_compat+0x51/0x60 arch/x86/entry/entry_64_compat.S:124
>>>
>>> Freed by task 3667:
>>>  save_stack_trace+0x16/0x20 arch/x86/kernel/stacktrace.c:59
>>>  save_stack+0x43/0xd0 mm/kasan/kasan.c:447
>>>  set_track mm/kasan/kasan.c:459 [inline]
>>>  kasan_slab_free+0x71/0xc0 mm/kasan/kasan.c:524
>>>  __cache_free mm/slab.c:3503 [inline]
>>>  kmem_cache_free+0x77/0x280 mm/slab.c:3763
>>>  remove_vma+0x162/0x1b0 mm/mmap.c:176
>>>  remove_vma_list mm/mmap.c:2475 [inline]
>>>  do_munmap+0x82a/0xdf0 mm/mmap.c:2714
>>>  mmap_region+0x59e/0x15a0 mm/mmap.c:1631
>>>  do_mmap+0x6a1/0xd50 mm/mmap.c:1468
>>>  do_mmap_pgoff include/linux/mm.h:2150 [inline]
>>>  vm_mmap_pgoff+0x1de/0x280 mm/util.c:333
>>>  SYSC_mmap_pgoff mm/mmap.c:1518 [inline]
>>>  SyS_mmap_pgoff+0x23b/0x5f0 mm/mmap.c:1476
>>>  do_syscall_32_irqs_on arch/x86/entry/common.c:329 [inline]
>>>  do_fast_syscall_32+0x3f2/0xf05 arch/x86/entry/common.c:391
>>>  entry_SYSENTER_compat+0x51/0x60 arch/x86/entry/entry_64_compat.S:124
>
> This would mean that mmap_sem is not doing its job and we raced with a
> vma removal. Or the rbtree is broken and contains a vma that has been
> freed. Hmm, or the vmacache is broken? You could try removing the 3
> lines starting with vmacache_find() in find_vma().
>
>>> The buggy address belongs to the object at ffff8801cbfd3040
>>>  which belongs to the cache vm_area_struct of size 200
>>> The buggy address is located 80 bytes inside of
>>>  200-byte region [ffff8801cbfd3040, ffff8801cbfd3108)
>
> My vm_area_struct is 192 bytes, could be your layout is different due to
> .config. At offset 80 I have vma->vm_flags. That is checked by
> __do_page_fault(), but only after vma->vm_start (offset 0). Of course,
> reordering is possible.


It seems that compiler over-optimizes things and messes debug info.
I just re-reproduced this on upstream
15f859ae5c43c7f0a064ed92d33f7a5bc5de6de0 and got the same report:

==================================================================
BUG: KASAN: use-after-free in arch_local_irq_enable
arch/x86/include/asm/paravirt.h:787 [inline]
BUG: KASAN: use-after-free in __do_page_fault+0xc03/0xd60
arch/x86/mm/fault.c:1357
Read of size 8 at addr ffff880064d19aa0 by task syz-executor/8001

CPU: 0 PID: 8001 Comm: syz-executor Not tainted 4.14.0-rc6+ #12
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
Call Trace:
 __dump_stack lib/dump_stack.c:16 [inline]
 dump_stack+0x194/0x257 lib/dump_stack.c:52
 print_address_description+0x73/0x250 mm/kasan/report.c:252
 kasan_report_error mm/kasan/report.c:351 [inline]
 kasan_report+0x25b/0x340 mm/kasan/report.c:409
 __asan_report_load8_noabort+0x14/0x20 mm/kasan/report.c:430
 arch_local_irq_enable arch/x86/include/asm/paravirt.h:787 [inline]
 __do_page_fault+0xc03/0xd60 arch/x86/mm/fault.c:1357
 do_page_fault+0xee/0x720 arch/x86/mm/fault.c:1520
 do_async_page_fault+0x82/0x110 arch/x86/kernel/kvm.c:273
 async_page_fault+0x22/0x30 arch/x86/entry/entry_64.S:1069
RIP: 0033:0x441bd0
RSP: 002b:00007f2ed8229798 EFLAGS: 00010202
RAX: 00007f2ed82297c0 RBX: 0000000000000000 RCX: 000000000000000e
RDX: 0000000000000400 RSI: 0000000020012fe0 RDI: 00007f2ed82297c0
RBP: 0000000000748020 R08: 0000000000000400 R09: 0000000000000000
R10: 0000000020012fee R11: 0000000000000246 R12: 00000000ffffffff
R13: 0000000000008430 R14: 00000000006ec4d0 R15: 00007f2ed822a700

Allocated by task 8001:
 save_stack_trace+0x16/0x20 arch/x86/kernel/stacktrace.c:59
 save_stack+0x43/0xd0 mm/kasan/kasan.c:447
 set_track mm/kasan/kasan.c:459 [inline]
 kasan_kmalloc+0xad/0xe0 mm/kasan/kasan.c:551
 kasan_slab_alloc+0x12/0x20 mm/kasan/kasan.c:489
 kmem_cache_alloc+0x12e/0x760 mm/slab.c:3561
 kmem_cache_zalloc include/linux/slab.h:656 [inline]
 mmap_region+0x7ee/0x15a0 mm/mmap.c:1658
 do_mmap+0x69b/0xd40 mm/mmap.c:1468
 do_mmap_pgoff include/linux/mm.h:2150 [inline]
 vm_mmap_pgoff+0x1de/0x280 mm/util.c:333
 SYSC_mmap_pgoff mm/mmap.c:1518 [inline]
 SyS_mmap_pgoff+0x23b/0x5f0 mm/mmap.c:1476
 SYSC_mmap arch/x86/kernel/sys_x86_64.c:99 [inline]
 SyS_mmap+0x16/0x20 arch/x86/kernel/sys_x86_64.c:90
 entry_SYSCALL_64_fastpath+0x1f/0xbe

Freed by task 8007:
 save_stack_trace+0x16/0x20 arch/x86/kernel/stacktrace.c:59
 save_stack+0x43/0xd0 mm/kasan/kasan.c:447
 set_track mm/kasan/kasan.c:459 [inline]
 kasan_slab_free+0x71/0xc0 mm/kasan/kasan.c:524
 __cache_free mm/slab.c:3503 [inline]
 kmem_cache_free+0x77/0x280 mm/slab.c:3763
 remove_vma+0x162/0x1b0 mm/mmap.c:176
 remove_vma_list mm/mmap.c:2475 [inline]
 do_munmap+0x82a/0xdf0 mm/mmap.c:2714
 mmap_region+0x59e/0x15a0 mm/mmap.c:1631
 do_mmap+0x69b/0xd40 mm/mmap.c:1468
 do_mmap_pgoff include/linux/mm.h:2150 [inline]
 vm_mmap_pgoff+0x1de/0x280 mm/util.c:333
 SYSC_mmap_pgoff mm/mmap.c:1518 [inline]
 SyS_mmap_pgoff+0x23b/0x5f0 mm/mmap.c:1476
 SYSC_mmap arch/x86/kernel/sys_x86_64.c:99 [inline]
 SyS_mmap+0x16/0x20 arch/x86/kernel/sys_x86_64.c:90
 entry_SYSCALL_64_fastpath+0x1f/0xbe

The buggy address belongs to the object at ffff880064d19a50
 which belongs to the cache vm_area_struct of size 200
The buggy address is located 80 bytes inside of
 200-byte region [ffff880064d19a50, ffff880064d19b18)
The buggy address belongs to the page:
page:ffffea0001934640 count:1 mapcount:0 mapping:ffff880064d19000 index:0x0
flags: 0x100000000000100(slab)
raw: 0100000000000100 ffff880064d19000 0000000000000000 000000010000000f
raw: ffffea00018a3a60 ffffea0001940be0 ffff88006c5f79c0 0000000000000000
page dumped because: kasan: bad access detected

Memory state around the buggy address:
 ffff880064d19980: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
 ffff880064d19a00: fb fb fc fc fc fc fc fc fc fc fb fb fb fb fb fb
>ffff880064d19a80: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
                               ^
 ffff880064d19b00: fb fb fb fc fc fc fc fc fc fc fc fb fb fb fb fb
 ffff880064d19b80: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
==================================================================


Here is disasm of the function:
https://gist.githubusercontent.com/dvyukov/5a56c66ce605168c951a321d94df6e3a/raw/538d4ce72ceb5631dfcc866ccde46c74543de1cf/gistfile1.txt

Seems to be vma->vm_flags at offset 80.

I think the size of 200 reported by slab is OK as it can do some rounding.
Everything points to a vma object.


>>> The buggy address belongs to the page:
>>> page:ffffea00072ff4c0 count:1 mapcount:0 mapping:ffff8801cbfd3040 index:0x0
>>> flags: 0x200000000000100(slab)
>>> raw: 0200000000000100 ffff8801cbfd3040 0000000000000000 000000010000000f
>>> raw: ffffea000730c7a0 ffffea00072ff7a0 ffff8801dae069c0 0000000000000000
>>> page dumped because: kasan: bad access detected
>>>
>>> Memory state around the buggy address:
>>>  ffff8801cbfd2f80: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
>>>  ffff8801cbfd3000: fc fc fc fc fc fc fc fc fb fb fb fb fb fb fb fb
>>>>
>>>> ffff8801cbfd3080: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
>>>
>>>                          ^
>>>  ffff8801cbfd3100: fb fc fc fc fc fc fc fc fc fb fb fb fb fb fb fb
>>>  ffff8801cbfd3180: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
>>> ==================================================================
>>
>>
>> I guess this is more related to mm rather than x86, so +mm maintainers.
>> This continues to happen, in particular on upstream
>> 781402340475144bb360e32bb7437fa4b84cadc3 (Oct 28).
>>
>>
>>> ---
>>> This bug is generated by a dumb bot. It may contain errors.
>>> See https://goo.gl/tpsmEJ for details.
>>> Direct all questions to syzkaller@googlegroups.com.
>>>
>>> syzbot will keep track of this bug report.
>>> Once a fix for this bug is committed, please reply to this email with:
>>> #syz fix: exact-commit-title
>>> To mark this as a duplicate of another syzbot report, please reply with:
>>> #syz dup: exact-subject-of-another-report
>>> If it's a one-off invalid bug report, please reply with:
>>> #syz invalid
>>> Note: if the crash happens again, it will cause creation of a new bug
>>> report.
>>>
>>> --
>>> You received this message because you are subscribed to the Google Groups
>>> "syzkaller-bugs" group.
>>> To unsubscribe from this group and stop receiving emails from it, send an
>>> email to syzkaller-bugs+unsubscribe@googlegroups.com.
>>> To view this discussion on the web visit
>>> https://groups.google.com/d/msgid/syzkaller-bugs/94eb2c0433c8f42cac055cc86991%40google.com.
>>> For more options, visit https://groups.google.com/d/optout.
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
