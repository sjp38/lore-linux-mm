Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3634C6B0033
	for <linux-mm@kvack.org>; Thu,  2 Nov 2017 06:01:05 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id 198so2663686wmg.6
        for <linux-mm@kvack.org>; Thu, 02 Nov 2017 03:01:05 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id x16si701303eda.255.2017.11.02.03.01.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Nov 2017 03:01:03 -0700 (PDT)
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id vA2A0a4u076429
	for <linux-mm@kvack.org>; Thu, 2 Nov 2017 06:01:02 -0400
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2e005gu8sy-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 02 Nov 2017 06:00:56 -0400
Received: from localhost
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Thu, 2 Nov 2017 10:00:32 -0000
Subject: Re: KASAN: use-after-free Read in __do_page_fault
References: <94eb2c0433c8f42cac055cc86991@google.com>
 <CACT4Y+YtdzYFPZfs0gjDtuHqkkZdRNwKfe-zBJex_uXUevNtBg@mail.gmail.com>
 <b9c543d1-27f9-8db7-238e-7c1305b1bff5@suse.cz>
 <CACT4Y+ZzrcHAUSG25HSi7ybKJd8gxDtimXHE_6UsowOT3wcT5g@mail.gmail.com>
 <8e92c891-a9e0-efed-f0b9-9bf567d8fbcd@suse.cz>
 <4bc852be-7ef3-0b60-6dbb-81139d25a817@suse.cz>
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Date: Thu, 2 Nov 2017 11:00:25 +0100
MIME-Version: 1.0
In-Reply-To: <4bc852be-7ef3-0b60-6dbb-81139d25a817@suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Message-Id: <b16de9a3-12d8-52a2-0edf-686dc5bd8f4c@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, Dmitry Vyukov <dvyukov@google.com>
Cc: syzbot <bot+6a5269ce759a7bb12754ed9622076dc93f65a1f6@syzkaller.appspotmail.com>, Jan Beulich <JBeulich@suse.com>, "H. Peter Anvin" <hpa@zytor.com>, Josh Poimboeuf <jpoimboe@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, LKML <linux-kernel@vger.kernel.org>, Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@redhat.com>, syzkaller-bugs@googlegroups.com, Thomas Gleixner <tglx@linutronix.de>, the arch/x86 maintainers <x86@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thorsten Leemhuis <regressions@leemhuis.info>

Hi Vlastimil,

Sorry for the late answer I got a few day off.

On 31/10/2017 14:57, Vlastimil Babka wrote:
> +CC Andrea, Thorsten, Linus
> 
> On 10/31/2017 02:20 PM, Vlastimil Babka wrote:
>> On 10/31/2017 01:42 PM, Dmitry Vyukov wrote:
>>>> My vm_area_struct is 192 bytes, could be your layout is different due to
>>>> .config. At offset 80 I have vma->vm_flags. That is checked by
>>>> __do_page_fault(), but only after vma->vm_start (offset 0). Of course,
>>>> reordering is possible.
>>>
>>>
>>> It seems that compiler over-optimizes things and messes debug info.
>>> I just re-reproduced this on upstream
>>> 15f859ae5c43c7f0a064ed92d33f7a5bc5de6de0 and got the same report:
>>>
>>> ==================================================================
>>> BUG: KASAN: use-after-free in arch_local_irq_enable
>>> arch/x86/include/asm/paravirt.h:787 [inline]
>>> BUG: KASAN: use-after-free in __do_page_fault+0xc03/0xd60
>>> arch/x86/mm/fault.c:1357
>>> Read of size 8 at addr ffff880064d19aa0 by task syz-executor/8001
>>>
>>> CPU: 0 PID: 8001 Comm: syz-executor Not tainted 4.14.0-rc6+ #12
>>> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
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
>>>  do_async_page_fault+0x82/0x110 arch/x86/kernel/kvm.c:273
>>>  async_page_fault+0x22/0x30 arch/x86/entry/entry_64.S:1069
>>> RIP: 0033:0x441bd0
>>> RSP: 002b:00007f2ed8229798 EFLAGS: 00010202
>>> RAX: 00007f2ed82297c0 RBX: 0000000000000000 RCX: 000000000000000e
>>> RDX: 0000000000000400 RSI: 0000000020012fe0 RDI: 00007f2ed82297c0
>>> RBP: 0000000000748020 R08: 0000000000000400 R09: 0000000000000000
>>> R10: 0000000020012fee R11: 0000000000000246 R12: 00000000ffffffff
>>> R13: 0000000000008430 R14: 00000000006ec4d0 R15: 00007f2ed822a700
>>>
>>> Allocated by task 8001:
>>>  save_stack_trace+0x16/0x20 arch/x86/kernel/stacktrace.c:59
>>>  save_stack+0x43/0xd0 mm/kasan/kasan.c:447
>>>  set_track mm/kasan/kasan.c:459 [inline]
>>>  kasan_kmalloc+0xad/0xe0 mm/kasan/kasan.c:551
>>>  kasan_slab_alloc+0x12/0x20 mm/kasan/kasan.c:489
>>>  kmem_cache_alloc+0x12e/0x760 mm/slab.c:3561
>>>  kmem_cache_zalloc include/linux/slab.h:656 [inline]
>>>  mmap_region+0x7ee/0x15a0 mm/mmap.c:1658
>>>  do_mmap+0x69b/0xd40 mm/mmap.c:1468
>>>  do_mmap_pgoff include/linux/mm.h:2150 [inline]
>>>  vm_mmap_pgoff+0x1de/0x280 mm/util.c:333
>>>  SYSC_mmap_pgoff mm/mmap.c:1518 [inline]
>>>  SyS_mmap_pgoff+0x23b/0x5f0 mm/mmap.c:1476
>>>  SYSC_mmap arch/x86/kernel/sys_x86_64.c:99 [inline]
>>>  SyS_mmap+0x16/0x20 arch/x86/kernel/sys_x86_64.c:90
>>>  entry_SYSCALL_64_fastpath+0x1f/0xbe
>>>
>>> Freed by task 8007:
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
>>>  do_mmap+0x69b/0xd40 mm/mmap.c:1468
>>>  do_mmap_pgoff include/linux/mm.h:2150 [inline]
>>>  vm_mmap_pgoff+0x1de/0x280 mm/util.c:333
>>>  SYSC_mmap_pgoff mm/mmap.c:1518 [inline]
>>>  SyS_mmap_pgoff+0x23b/0x5f0 mm/mmap.c:1476
>>>  SYSC_mmap arch/x86/kernel/sys_x86_64.c:99 [inline]
>>>  SyS_mmap+0x16/0x20 arch/x86/kernel/sys_x86_64.c:90
>>>  entry_SYSCALL_64_fastpath+0x1f/0xbe
>>>
>>> The buggy address belongs to the object at ffff880064d19a50
>>>  which belongs to the cache vm_area_struct of size 200
>>> The buggy address is located 80 bytes inside of
>>>  200-byte region [ffff880064d19a50, ffff880064d19b18)
>>> The buggy address belongs to the page:
>>> page:ffffea0001934640 count:1 mapcount:0 mapping:ffff880064d19000 index:0x0
>>> flags: 0x100000000000100(slab)
>>> raw: 0100000000000100 ffff880064d19000 0000000000000000 000000010000000f
>>> raw: ffffea00018a3a60 ffffea0001940be0 ffff88006c5f79c0 0000000000000000
>>> page dumped because: kasan: bad access detected
>>>
>>> Memory state around the buggy address:
>>>  ffff880064d19980: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
>>>  ffff880064d19a00: fb fb fc fc fc fc fc fc fc fc fb fb fb fb fb fb
>>>> ffff880064d19a80: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
>>>                                ^
>>>  ffff880064d19b00: fb fb fb fc fc fc fc fc fc fc fc fb fb fb fb fb
>>>  ffff880064d19b80: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
>>> ==================================================================
>>>
>>>
>>> Here is disasm of the function:
>>> https://gist.githubusercontent.com/dvyukov/5a56c66ce605168c951a321d94df6e3a/raw/538d4ce72ceb5631dfcc866ccde46c74543de1cf/gistfile1.txt
>>>
>>> Seems to be vma->vm_flags at offset 80.
>>
>> You can see it from the disasm? I can't make much of it, unfortunately,
>> the added kasan calls obscure it a lot for me. But I suspect it might be
>> the vma_pkey() thing which reads from vma->vm_flags. What happens when
>> CONFIG_X86_INTEL_MEMORY_PROTECTION_KEYS is disabled? (or is it already?)
> 
> OK, so I opened the google groups link in the report's signature and
> looked at the attached config there, which says protkeys are enabled.
> Also looked at the repro.txt attachment:
> #{Threaded:true Collide:true Repeat:true Procs:8 Sandbox:none Fault:false FaultCall:-1 FaultNth:0 EnableTun:true UseTmpDir:true HandleSegv:true WaitRepeat:true Debug:false Repro:false}
> mmap(&(0x7f0000000000/0xfff000)=nil, 0xfff000, 0x3, 0x32, 0xffffffffffffffff, 0x0)
> mmap(&(0x7f0000011000/0x3000)=nil, 0x3000, 0x1, 0x32, 0xffffffffffffffff, 0x0)
> r0 = userfaultfd(0x0)
> ioctl$UFFDIO_API(r0, 0xc018aa3f, &(0x7f0000002000-0x18)={0xaa, 0x0, 0x0})
> ioctl$UFFDIO_REGISTER(r0, 0xc020aa00, &(0x7f0000019000)={{&(0x7f0000012000/0x2000)=nil, 0x2000}, 0x1, 0x0})
> r1 = gettid()
> syz_open_dev$evdev(&(0x7f0000013000-0x12)="2f6465762f696e7075742f6576656e742300", 0x0, 0x0)
> tkill(r1, 0x7)
> 
> The userfaultfd() caught my attention so I checked handle_userfault()
> which seems to do up_read(&mm->mmap_sem); and in some cases later
> followed by down_read(&mm->mmap_sem); return VM_FAULT_NOPAGE.
> However, __do_page_fault() only expects that mmap_sem to be released
> when handle_mm_fault() returns with VM_FAULT_RETRY. It doesn't expect it
> to be released and then acquired again, because then vma can be indeed
> gone. It seems vma hasn't been touched after that point until the
> vma_pkey() was added by commit a3c4fb7c9c2e ("x86/mm: Fix fault error
> path using unsafe vma pointer") in rc3. Which tried to fix a similar
> problem, but run into this corner case?
> 
> So I suspect a3c4fb7c9c2e is the culprit and thus a regression.

Yes that's my mistake.

My patch was removing the use of vma once mmap_sem is released but it was
mainly done in the error path and I moved the read of the vma's pkey before
releasing the mmap_sem, but in the no-error path also, leading to the use
after free you seen.

As suggested and done later in this thread, reading the vma's key value
before calling handle_mm_fault() will solve this issue. This is safe since
the vma's pkey can't be changed once the mmap_sem is held.

Thanks,
Laurent.

> 
>> Also did you try the vmacache shortcut test suggested in my previous mail?
>>
>>> I think the size of 200 reported by slab is OK as it can do some rounding.
>>> Everything points to a vma object.
>>>
>>>
>>>>>> The buggy address belongs to the page:
>>>>>> page:ffffea00072ff4c0 count:1 mapcount:0 mapping:ffff8801cbfd3040 index:0x0
>>>>>> flags: 0x200000000000100(slab)
>>>>>> raw: 0200000000000100 ffff8801cbfd3040 0000000000000000 000000010000000f
>>>>>> raw: ffffea000730c7a0 ffffea00072ff7a0 ffff8801dae069c0 0000000000000000
>>>>>> page dumped because: kasan: bad access detected
>>>>>>
>>>>>> Memory state around the buggy address:
>>>>>>  ffff8801cbfd2f80: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
>>>>>>  ffff8801cbfd3000: fc fc fc fc fc fc fc fc fb fb fb fb fb fb fb fb
>>>>>>>
>>>>>>> ffff8801cbfd3080: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
>>>>>>
>>>>>>                          ^
>>>>>>  ffff8801cbfd3100: fb fc fc fc fc fc fc fc fc fb fb fb fb fb fb fb
>>>>>>  ffff8801cbfd3180: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
>>>>>> ==================================================================
>>>>>
>>>>>
>>>>> I guess this is more related to mm rather than x86, so +mm maintainers.
>>>>> This continues to happen, in particular on upstream
>>>>> 781402340475144bb360e32bb7437fa4b84cadc3 (Oct 28).
>>>>>
>>>>>
>>>>>> ---
>>>>>> This bug is generated by a dumb bot. It may contain errors.
>>>>>> See https://goo.gl/tpsmEJ for details.
>>>>>> Direct all questions to syzkaller@googlegroups.com.
>>>>>>
>>>>>> syzbot will keep track of this bug report.
>>>>>> Once a fix for this bug is committed, please reply to this email with:
>>>>>> #syz fix: exact-commit-title
>>>>>> To mark this as a duplicate of another syzbot report, please reply with:
>>>>>> #syz dup: exact-subject-of-another-report
>>>>>> If it's a one-off invalid bug report, please reply with:
>>>>>> #syz invalid
>>>>>> Note: if the crash happens again, it will cause creation of a new bug
>>>>>> report.
>>>>>>
>>>>>> --
>>>>>> You received this message because you are subscribed to the Google Groups
>>>>>> "syzkaller-bugs" group.
>>>>>> To unsubscribe from this group and stop receiving emails from it, send an
>>>>>> email to syzkaller-bugs+unsubscribe@googlegroups.com.
>>>>>> To view this discussion on the web visit
>>>>>> https://groups.google.com/d/msgid/syzkaller-bugs/94eb2c0433c8f42cac055cc86991%40google.com.
>>>>>> For more options, visit https://groups.google.com/d/optout.
>>>>>
>>>>> --
>>>>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>>>>> the body to majordomo@kvack.org.  For more info on Linux MM,
>>>>> see: http://www.linux-mm.org/ .
>>>>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>>>>>
>>>>
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
