Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1832C6B0038
	for <linux-mm@kvack.org>; Thu, 24 Nov 2016 09:23:48 -0500 (EST)
Received: by mail-lf0-f69.google.com with SMTP id o141so15262034lff.7
        for <linux-mm@kvack.org>; Thu, 24 Nov 2016 06:23:48 -0800 (PST)
Received: from mail-lf0-x22f.google.com (mail-lf0-x22f.google.com. [2a00:1450:4010:c07::22f])
        by mx.google.com with ESMTPS id 65si17483517ljb.31.2016.11.24.06.23.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Nov 2016 06:23:46 -0800 (PST)
Received: by mail-lf0-x22f.google.com with SMTP id o141so29927895lff.1
        for <linux-mm@kvack.org>; Thu, 24 Nov 2016 06:23:46 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <f8963cc3-69a8-a1ca-9b56-205d919eac41@suse.cz>
References: <CACT4Y+Z0QqeO-fpc_tuStBGPWMwcK-gT-2q+tPmDpQDCkqYUiQ@mail.gmail.com>
 <f8963cc3-69a8-a1ca-9b56-205d919eac41@suse.cz>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Thu, 24 Nov 2016 15:23:25 +0100
Message-ID: <CACT4Y+Z0f51iJjwTLxqwY2PZObLQpF+GujKQ34enBA3fBp8QiQ@mail.gmail.com>
Subject: Re: mm: BUG in pgtable_pmd_page_dtor
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Ingo Molnar <mingo@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, syzkaller <syzkaller@googlegroups.com>

On Thu, Nov 24, 2016 at 2:49 PM, Vlastimil Babka <vbabka@suse.cz> wrote:
> On 11/18/2016 11:19 AM, Dmitry Vyukov wrote:
>>
>> Hello,
>>
>> I've got the following BUG while running syzkaller on
>> a25f0944ba9b1d8a6813fd6f1a86f1bd59ac25a6 (4.9-rc5). Unfortunately it's
>> not reproducible.
>>
>> kernel BUG at ./include/linux/mm.h:1743!
>> invalid opcode: 0000 [#1] SMP DEBUG_PAGEALLOC KASAN
>
>
> Shouldn't there be also dump_page() output? Since you've hit this:
> VM_BUG_ON_PAGE(page->pmd_huge_pte, page);

Here it is:

[  250.326131] page:ffffea0000e196c0 count:1 mapcount:0 mapping:
   (null) index:0x0
[  250.343393] flags: 0x1fffc0000000000()
[  250.345328] page dumped because: VM_BUG_ON_PAGE(page->pmd_huge_pte)
[  250.346780] ------------[ cut here ]------------
[  250.347742] kernel BUG at ./include/linux/mm.h:1743!


> Anyway the output wouldn't contain the value of pmd_huge_pte or stuff that's
> in union with it. I'd suggest adding a local patch that prints this in the
> error case, in case the fuzzer hits it again.
>
> Heck, it might even make sense to print raw contents of struct page in
> dump_page() as a catch-all solution? Should I send a patch?

Yes, please send.
We are moving towards continuous build without local patches.



>> Dumping ftrace buffer:
>>    (ftrace buffer empty)
>> Modules linked in:
>> CPU: 3 PID: 4049 Comm: syz-fuzzer Not tainted 4.9.0-rc5+ #43
>> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs
>> 01/01/2011
>> task: ffff88006ad028c0 task.stack: ffff8800667e0000
>> RIP: 0010:[<ffffffff8130e2ab>]  [<     inline     >]
>> pgtable_pmd_page_dtor include/linux/mm.h:1743
>> RIP: 0010:[<ffffffff8130e2ab>]  [<ffffffff8130e2ab>]
>> ___pmd_free_tlb+0x3db/0x5a0 arch/x86/mm/pgtable.c:74
>> RSP: 0018:ffff8800667e6908  EFLAGS: 00010292
>> RAX: 0000000000000000 RBX: 1ffff1000ccfcd25 RCX: 0000000000000000
>> RDX: 0000000000000000 RSI: 0000000000000001 RDI: ffffed000ccfcd10
>> RBP: ffff8800667e6a70 R08: 0000000000000001 R09: 0000000000000000
>> R10: dffffc0000000000 R11: 0000000000000001 R12: ffff8800667e6ef8
>> R13: ffff8800667e6a48 R14: ffffea0000e196c0 R15: 000000000003865b
>> FS:  00007f152a530700(0000) GS:ffff88006d100000(0000)
>> knlGS:0000000000000000
>> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
>> CR2: 00007f1514bff9d0 CR3: 0000000009821000 CR4: 00000000000006e0
>> DR0: 0000000000000400 DR1: 0000000000000400 DR2: 0000000000000000
>> DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000600
>> Stack:
>>  0000000000000000 ffff88006ad030e0 ffff88006ad030b8 dffffc0000000000
>>  0000000041b58ab3 ffffffff894db568 ffffffff8130ded0 ffffffff8156b2a0
>>  0000000000000082 ffff88006ad030e0 1ffff1000ccfcd30 1ffff1000ccfcd38
>> Call Trace:
>>  [<     inline     >] __pmd_free_tlb arch/x86/include/asm/pgalloc.h:110
>>  [<     inline     >] free_pmd_range mm/memory.c:443
>>  [<     inline     >] free_pud_range mm/memory.c:461
>>  [<ffffffff81946458>] free_pgd_range+0xb98/0x1270 mm/memory.c:537
>>  [<ffffffff81946da5>] free_pgtables+0x275/0x340 mm/memory.c:569
>>  [<ffffffff81972761>] exit_mmap+0x281/0x4e0 mm/mmap.c:2942
>>  [<     inline     >] __mmput kernel/fork.c:866
>>  [<ffffffff813f24ce>] mmput+0x20e/0x4c0 kernel/fork.c:888
>>  [<     inline     >] exit_mm kernel/exit.c:512
>>  [<ffffffff814119a0>] do_exit+0x960/0x2640 kernel/exit.c:815
>>  [<ffffffff8141383e>] do_group_exit+0x14e/0x420 kernel/exit.c:931
>>  [<ffffffff814429d3>] get_signal+0x663/0x1880 kernel/signal.c:2307
>>  [<ffffffff81239b45>] do_signal+0xc5/0x2190 arch/x86/kernel/signal.c:807
>>  [<ffffffff8100666a>] exit_to_usermode_loop+0x1ea/0x2d0
>> arch/x86/entry/common.c:156
>>  [<     inline     >] prepare_exit_to_usermode arch/x86/entry/common.c:190
>>  [<ffffffff81009693>] syscall_return_slowpath+0x4d3/0x570
>> arch/x86/entry/common.c:259
>>  [<ffffffff881479a6>] entry_SYSCALL_64_fastpath+0xc4/0xc6
>> Code: 10 00 00 4c 89 e7 e8 25 6c 63 00 e9 9b fd ff ff e8 0b 9e 3d 00
>> 0f 0b e8 04 9e 3d 00 48 c7 c6 00 ac 27 88 4c 89 f7 e8 85 9e 62 00 <0f>
>> 0b e8 9e 2d 6e 00 e9 1a fe ff ff 48 89 cf 48 89 8d b0 fe ff
>> RIP  [<     inline     >] pgtable_pmd_page_dtor include/linux/mm.h:1743
>> RIP  [<ffffffff8130e2ab>] ___pmd_free_tlb+0x3db/0x5a0
>> arch/x86/mm/pgtable.c:74
>>  RSP <ffff8800667e6908>
>> ---[ end trace 4ef4b70d88f62f8a ]---
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
