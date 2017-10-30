Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8DEB16B0038
	for <linux-mm@kvack.org>; Mon, 30 Oct 2017 15:15:32 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id f16so37032587ioe.1
        for <linux-mm@kvack.org>; Mon, 30 Oct 2017 12:15:32 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y94sor7678252ioi.247.2017.10.30.12.15.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 30 Oct 2017 12:15:30 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <94eb2c0433c8f42cac055cc86991@google.com>
References: <94eb2c0433c8f42cac055cc86991@google.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Mon, 30 Oct 2017 22:15:09 +0300
Message-ID: <CACT4Y+YtdzYFPZfs0gjDtuHqkkZdRNwKfe-zBJex_uXUevNtBg@mail.gmail.com>
Subject: Re: KASAN: use-after-free Read in __do_page_fault
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: syzbot <bot+6a5269ce759a7bb12754ed9622076dc93f65a1f6@syzkaller.appspotmail.com>
Cc: JBeulich@suse.com, "H. Peter Anvin" <hpa@zytor.com>, Josh Poimboeuf <jpoimboe@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, ldufour@linux.vnet.ibm.com, LKML <linux-kernel@vger.kernel.org>, Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@redhat.com>, syzkaller-bugs@googlegroups.com, Thomas Gleixner <tglx@linutronix.de>, the arch/x86 maintainers <x86@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org

On Mon, Oct 30, 2017 at 10:12 PM, syzbot
<bot+6a5269ce759a7bb12754ed9622076dc93f65a1f6@syzkaller.appspotmail.com>
wrote:
> Hello,
>
> syzkaller hit the following crash on
> 887c8ba753fbe809ba93fa3cfd0cc46db18d37d4
> git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/master
> compiler: gcc (GCC) 7.1.1 20170620
> .config is attached
> Raw console output is attached.
>
> syzkaller reproducer is attached. See https://goo.gl/kgGztJ
> for information about syzkaller reproducers
>
>
> BUG: KASAN: use-after-free in arch_local_irq_enable
> arch/x86/include/asm/paravirt.h:787 [inline]
> BUG: KASAN: use-after-free in __do_page_fault+0xc03/0xd60
> arch/x86/mm/fault.c:1357
> Read of size 8 at addr ffff8801cbfd3090 by task syz-executor7/3660
>
> CPU: 1 PID: 3660 Comm: syz-executor7 Not tainted 4.14.0-rc3+ #23
> Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS
> Google 01/01/2011
> Call Trace:
>  __dump_stack lib/dump_stack.c:16 [inline]
>  dump_stack+0x194/0x257 lib/dump_stack.c:52
>  print_address_description+0x73/0x250 mm/kasan/report.c:252
>  kasan_report_error mm/kasan/report.c:351 [inline]
>  kasan_report+0x25b/0x340 mm/kasan/report.c:409
>  __asan_report_load8_noabort+0x14/0x20 mm/kasan/report.c:430
>  arch_local_irq_enable arch/x86/include/asm/paravirt.h:787 [inline]
>  __do_page_fault+0xc03/0xd60 arch/x86/mm/fault.c:1357
>  do_page_fault+0xee/0x720 arch/x86/mm/fault.c:1520
>  page_fault+0x22/0x30 arch/x86/entry/entry_64.S:1066
> RIP: 0023:0x8073f4f
> RSP: 002b:00000000f7f89bd0 EFLAGS: 00010202
> RAX: 00000000f7f89c8c RBX: 0000000000000400 RCX: 000000000000000e
> RDX: 00000000f7f8aa88 RSI: 0000000020012fe0 RDI: 00000000f7f89c8c
> RBP: 0000000008128000 R08: 0000000000000000 R09: 0000000000000000
> R10: 0000000000000000 R11: 0000000000000292 R12: 0000000000000000
> R13: 0000000000000000 R14: 0000000000000000 R15: 0000000000000000
>
> Allocated by task 3660:
>  save_stack_trace+0x16/0x20 arch/x86/kernel/stacktrace.c:59
>  save_stack+0x43/0xd0 mm/kasan/kasan.c:447
>  set_track mm/kasan/kasan.c:459 [inline]
>  kasan_kmalloc+0xad/0xe0 mm/kasan/kasan.c:551
>  kasan_slab_alloc+0x12/0x20 mm/kasan/kasan.c:489
>  kmem_cache_alloc+0x12e/0x760 mm/slab.c:3561
>  kmem_cache_zalloc include/linux/slab.h:656 [inline]
>  mmap_region+0x7ee/0x15a0 mm/mmap.c:1658
>  do_mmap+0x6a1/0xd50 mm/mmap.c:1468
>  do_mmap_pgoff include/linux/mm.h:2150 [inline]
>  vm_mmap_pgoff+0x1de/0x280 mm/util.c:333
>  SYSC_mmap_pgoff mm/mmap.c:1518 [inline]
>  SyS_mmap_pgoff+0x23b/0x5f0 mm/mmap.c:1476
>  do_syscall_32_irqs_on arch/x86/entry/common.c:329 [inline]
>  do_fast_syscall_32+0x3f2/0xf05 arch/x86/entry/common.c:391
>  entry_SYSENTER_compat+0x51/0x60 arch/x86/entry/entry_64_compat.S:124
>
> Freed by task 3667:
>  save_stack_trace+0x16/0x20 arch/x86/kernel/stacktrace.c:59
>  save_stack+0x43/0xd0 mm/kasan/kasan.c:447
>  set_track mm/kasan/kasan.c:459 [inline]
>  kasan_slab_free+0x71/0xc0 mm/kasan/kasan.c:524
>  __cache_free mm/slab.c:3503 [inline]
>  kmem_cache_free+0x77/0x280 mm/slab.c:3763
>  remove_vma+0x162/0x1b0 mm/mmap.c:176
>  remove_vma_list mm/mmap.c:2475 [inline]
>  do_munmap+0x82a/0xdf0 mm/mmap.c:2714
>  mmap_region+0x59e/0x15a0 mm/mmap.c:1631
>  do_mmap+0x6a1/0xd50 mm/mmap.c:1468
>  do_mmap_pgoff include/linux/mm.h:2150 [inline]
>  vm_mmap_pgoff+0x1de/0x280 mm/util.c:333
>  SYSC_mmap_pgoff mm/mmap.c:1518 [inline]
>  SyS_mmap_pgoff+0x23b/0x5f0 mm/mmap.c:1476
>  do_syscall_32_irqs_on arch/x86/entry/common.c:329 [inline]
>  do_fast_syscall_32+0x3f2/0xf05 arch/x86/entry/common.c:391
>  entry_SYSENTER_compat+0x51/0x60 arch/x86/entry/entry_64_compat.S:124
>
> The buggy address belongs to the object at ffff8801cbfd3040
>  which belongs to the cache vm_area_struct of size 200
> The buggy address is located 80 bytes inside of
>  200-byte region [ffff8801cbfd3040, ffff8801cbfd3108)
> The buggy address belongs to the page:
> page:ffffea00072ff4c0 count:1 mapcount:0 mapping:ffff8801cbfd3040 index:0x0
> flags: 0x200000000000100(slab)
> raw: 0200000000000100 ffff8801cbfd3040 0000000000000000 000000010000000f
> raw: ffffea000730c7a0 ffffea00072ff7a0 ffff8801dae069c0 0000000000000000
> page dumped because: kasan: bad access detected
>
> Memory state around the buggy address:
>  ffff8801cbfd2f80: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
>  ffff8801cbfd3000: fc fc fc fc fc fc fc fc fb fb fb fb fb fb fb fb
>>
>> ffff8801cbfd3080: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
>
>                          ^
>  ffff8801cbfd3100: fb fc fc fc fc fc fc fc fc fb fb fb fb fb fb fb
>  ffff8801cbfd3180: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
> ==================================================================


I guess this is more related to mm rather than x86, so +mm maintainers.
This continues to happen, in particular on upstream
781402340475144bb360e32bb7437fa4b84cadc3 (Oct 28).


> ---
> This bug is generated by a dumb bot. It may contain errors.
> See https://goo.gl/tpsmEJ for details.
> Direct all questions to syzkaller@googlegroups.com.
>
> syzbot will keep track of this bug report.
> Once a fix for this bug is committed, please reply to this email with:
> #syz fix: exact-commit-title
> To mark this as a duplicate of another syzbot report, please reply with:
> #syz dup: exact-subject-of-another-report
> If it's a one-off invalid bug report, please reply with:
> #syz invalid
> Note: if the crash happens again, it will cause creation of a new bug
> report.
>
> --
> You received this message because you are subscribed to the Google Groups
> "syzkaller-bugs" group.
> To unsubscribe from this group and stop receiving emails from it, send an
> email to syzkaller-bugs+unsubscribe@googlegroups.com.
> To view this discussion on the web visit
> https://groups.google.com/d/msgid/syzkaller-bugs/94eb2c0433c8f42cac055cc86991%40google.com.
> For more options, visit https://groups.google.com/d/optout.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
