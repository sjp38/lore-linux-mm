Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f172.google.com (mail-we0-f172.google.com [74.125.82.172])
	by kanga.kvack.org (Postfix) with ESMTP id D521C6B00F7
	for <linux-mm@kvack.org>; Tue, 18 Mar 2014 06:41:53 -0400 (EDT)
Received: by mail-we0-f172.google.com with SMTP id t61so5730109wes.31
        for <linux-mm@kvack.org>; Tue, 18 Mar 2014 03:41:53 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ax8si11815444wjc.157.2014.03.18.03.41.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 18 Mar 2014 03:41:51 -0700 (PDT)
Message-ID: <532822EE.2080607@suse.cz>
Date: Tue, 18 Mar 2014 11:41:50 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH 1/3] mm: munlock: fix a bug where THP tail page is encountered
References: <52AE07B4.4020203@oracle.com> <1387188856-21027-1-git-send-email-vbabka@suse.cz> <1387188856-21027-2-git-send-email-vbabka@suse.cz> <52AFA845.3060109@oracle.com> <52B04AD2.2070406@suse.cz> <532396E7.6000400@oracle.com> <5323C3B5.4060602@oracle.com> <5326ECD8.20107@suse.cz> <53276452.7040906@oracle.com> <53277549.5000008@suse.cz> <53277E06.6090905@oracle.com>
In-Reply-To: <53277E06.6090905@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>, Bob Liu <bob.liu@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, joern@logfs.org, Michel Lespinasse <walken@google.com>

On 03/17/2014 11:58 PM, Sasha Levin wrote:
> On 03/17/2014 06:20 PM, Vlastimil Babka wrote:
>> On 17.3.2014 22:08, Sasha Levin wrote:
>>> On 03/17/2014 08:38 AM, Vlastimil Babka wrote:
>>>> On 03/15/2014 04:06 AM, Sasha Levin wrote:
>>>>> On 03/14/2014 07:55 PM, Sasha Levin wrote:
>>>>>> On 12/17/2013 08:00 AM, Vlastimil Babka wrote:
>>>>>>> From: Vlastimil Babka<vbabka@suse.cz>
>>>>>>> Date: Fri, 13 Dec 2013 14:25:21 +0100
>>>>>>> Subject: [PATCH 1/3] mm: munlock: fix a bug where THP tail page is encountered
>>>>>>>
>>>>>>> Since commit ff6a6da60 ("mm: accelerate munlock() treatment of THP pages")
>>>>>>> munlock skips tail pages of a munlocked THP page. However, when the head page
>>>>>>> already has PageMlocked unset, it will not skip the tail pages.
>>>>>>>
>>>>>>> Commit 7225522bb ("mm: munlock: batch non-THP page isolation and
>>>>>>> munlock+putback using pagevec") has added a PageTransHuge() check which
>>>>>>> contains VM_BUG_ON(PageTail(page)). Sasha Levin found this triggered using
>>>>>>> trinity, on the first tail page of a THP page without PageMlocked flag.
>>>>>>>
>>>>>>> This patch fixes the issue by skipping tail pages also in the case when
>>>>>>> PageMlocked flag is unset. There is still a possibility of race with THP page
>>>>>>> split between clearing PageMlocked and determining how many pages to skip.
>>>>>>> The race might result in former tail pages not being skipped, which is however
>>>>>>> no longer a bug, as during the skip the PageTail flags are cleared.
>>>>>>>
>>>>>>> However this race also affects correctness of NR_MLOCK accounting, which is to
>>>>>>> be fixed in a separate patch.
>>>>>>
>>>>>> I've hit the same thing again, on the latest -next, this time with a different trace:
>>>>>>
>>>>>> [  539.199120] page:ffffea0013249a80 count:0 mapcount:1 mapping:          (null) index:0x0
>>>>>> [  539.200429] page flags: 0x12fffff80008000(tail)
>>>>>> [  539.201167] ------------[ cut here ]------------
>>>>>> [  539.201889] kernel BUG at include/linux/page-flags.h:415!
>>>>>> [  539.202859] invalid opcode: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
>>>>>> [  539.204588] Dumping ftrace buffer:
>>>>>> [  539.206415]    (ftrace buffer empty)
>>>>>> [  539.207022] Modules linked in:
>>>>>> [  539.207503] CPU: 3 PID: 18262 Comm: trinity-c228 Tainted: G        W 3.14.0-rc6-next-20140313-sasha-00010-gb8c1db1-dirty #217
>>>>>> [  539.209012] task: ffff880627b10000 ti: ffff8805a44c2000 task.ti: ffff8805a44c2000
>>>>>> [  539.209989] RIP:  munlock_vma_pages_range+0x93/0x1d0 (include/linux/page-flags.h:415 mm/mlock.c:494)
>>>>>> [  539.210263] RSP: 0000:ffff8805a44c3e08  EFLAGS: 00010246
>>>>>> [  539.210263] RAX: ffff88052ae126a0 RBX: 000000000006a000 RCX: 0000000000000099
>>>>>> [  539.210263] RDX: 0000000000000000 RSI: ffff880627b10cf0 RDI: 0000000004c926a0
>>>>>> [  539.210263] RBP: ffff8805a44c3ec8 R08: 0000000000000001 R09: 0000000000000001
>>>>>> [  539.210263] R10: 0000000000000001 R11: 0000000000000001 R12: ffffea0013249a80
>>>>>> [  539.210263] R13: ffff88039dc95a00 R14: 000000000006b000 R15: ffff8805a44c3e94
>>>>>> [  539.210263] FS:  00007fd6ce14a700(0000) GS:ffff88042b800000(0000) knlGS:0000000000000000
>>>>>> [  539.210263] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
>>>>>> [  539.210263] CR2: 00007fd6ce0ef6ac CR3: 00000006025cd000 CR4: 00000000000006a0
>>>>>> [  539.210263] DR0: 0000000000698000 DR1: 0000000000000000 DR2: 0000000000000000
>>>>>> [  539.210263] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000600
>>>>>> [  539.210263] Stack:
>>>>>> [  539.210263]  0000000000000000 0000000000000000 00018805a44c3e38 0000000000000000
>>>>>> [  539.210263]  0000000000000000 ffff88039dc95a00 00000000a44c3e88 0000000000000000
>>>>>> [  539.210263]  00ff8805a44c3e58 ffff880528f0a0f0 ffff8805a44c3eb8 ffff88039dc95a00
>>>>>> [  539.210263] Call Trace:
>>>>>> [  539.210263]  do_munmap+0x1d2/0x360 (mm/internal.h:168 mm/mmap.c:2547)
>>>>>> [  539.210263]  ? down_write+0xa6/0xc0 (kernel/locking/rwsem.c:51)
>>>>>> [  539.210263]  ? vm_munmap+0x46/0x80 (mm/mmap.c:2571)
>>>>>> [  539.210263]  vm_munmap+0x54/0x80 (mm/mmap.c:2572)
>>>>>> [  539.210263]  SyS_munmap+0x2c/0x40 (mm/mmap.c:2577)
>>>>>> [  539.210263]  tracesys+0xdd/0xe2 (arch/x86/kernel/entry_64.S:749)
>>>>>> [  539.210263] Code: ff 49 89 c4 48 85 c0 0f 84 f3 00 00 00 48 3d 00 f0 ff ff 0f 87 e7 00 00 00 48 8b 00 66 85 c0 79 17 31 f6 4c 89 e7 e8 4d d2 fc ff <0f> 0b 0f 1f 00 eb fe 66 0f 1f 44 00 00 49 8b 04 24 f6 c4 40 74
>>>>>> [  539.210263] RIP  munlock_vma_pages_range+0x93/0x1d0 (include/linux/page-flags.h:415 mm/mlock.c:494)
>>>>>> [  539.210263]  RSP <ffff8805a44c3e08>
>>>>>> [  539.236666] ---[ end trace 4e90dc9141579181 ]---
>>>>>>
>>>>>>
>>>>>> Thanks,
>>>>>> Sasha
>>>>>
>>>>> And another related trace:
>>>>>
>>>>> [  741.192502] kernel BUG at mm/mlock.c:528!
>>>>> [  741.193088] invalid opcode: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
>>>>> [  741.194177] Dumping ftrace buffer:
>>>>> [  741.194645]    (ftrace buffer empty)
>>>>> [  741.195109] Modules linked in:
>>>>> [  741.195728] CPU: 23 PID: 19908 Comm: trinity-c264 Tainted: G        W     3.14.0-rc6-next-20140314-sasha-00012-g5590866 #219
>>>>> [  741.197549] task: ffff88061fc2b000 ti: ffff8805decb8000 task.ti: ffff8805decb8000
>>>>> [  741.198548] RIP:  munlock_vma_pages_range+0x176/0x1d0 (mm/mlock.c:528)
>>>>> [  741.199754] RSP: 0018:ffff8805decb9e08  EFLAGS: 00010206
>>>>> [  741.200085] RAX: 00000000000001ff RBX: 0000000000111000 RCX: 0000000000000000
>>>>> [  741.200085] RDX: 0000000000000111 RSI: ffffffff81295fdd RDI: ffffffff84490705
>>>>> [  741.200085] RBP: ffff8805decb9ec8 R08: 0000000000000000 R09: 0000000000000000
>>>>> [  741.200085] R10: 0000000000000001 R11: 0000000000000000 R12: fffffffffffffff2
>>>>> [  741.200085] R13: ffff880221044e00 R14: 0000000000112000 R15: ffff8805decb9e94
>>>>> [  741.200085] FS:  00007f4bec6bc700(0000) GS:ffff88082ba00000(0000) knlGS:0000000000000000
>>>>> [  741.200085] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
>>>>> [  741.200085] CR2: 0000000003109a98 CR3: 00000005decaf000 CR4: 00000000000006a0
>>>>> [  741.200085] Stack:
>>>>> [  741.200085]  0000000000000000 0000000000000000 00018805decb9e38 0000000000000000
>>>>> [  741.200085]  0000000000000000 ffff880221044e00 00000000decb9e88 0000000000000000
>>>>> [  741.200085]  00ff8805decb9e58 ffff880ff376f450 ffff8805decb9eb8 ffff880221044e00
>>>>> [  741.200085] Call Trace:
>>>>> [  741.200085]  do_munmap+0x1d2/0x360 (mm/internal.h:168 mm/mmap.c:2547)
>>>>> [  741.200085]  ? down_write+0xa6/0xc0 (kernel/locking/rwsem.c:51)
>>>>> [  741.200085]  ? vm_munmap+0x46/0x80 (mm/mmap.c:2571)
>>>>> [  741.200085]  vm_munmap+0x54/0x80 (mm/mmap.c:2572)
>>>>> [  741.200085]  SyS_munmap+0x2c/0x40 (mm/mmap.c:2577)
>>>>> [  741.200085]  tracesys+0xdd/0xe2 (arch/x86/kernel/entry_64.S:749)
>>>>> [  741.200085] Code: fd ff ff 4c 89 e6 48 89 c3 48 8d bd 40 ff ff ff e8 80 fa ff ff eb 2f 66 0f 1f 44 00 00 8b 45 cc 48 89 da 48 c1 ea 0c 85 d0 74 12 <0f> 0b 0f 1f 84 00 00 00 00 00 eb fe 66 0f 1f 44 00 00 ff c0 48
>>>>> [  741.200085] RIP  munlock_vma_pages_range+0x176/0x1d0 (mm/mlock.c:528)
>>>>> [  741.200085]  RSP <ffff8805decb9e08>
>>>>
>>>> Sigh, again? I really wonder what is it this time :)
>>>> Please try this debug patch, hopefully we learn something:
>>>>
>>>> diff --git a/mm/mlock.c b/mm/mlock.c
>>>> index 4e1a6816..7094bac 100644
>>>> --- a/mm/mlock.c
>>>> +++ b/mm/mlock.c
>>>> @@ -469,12 +469,14 @@ static unsigned long __munlock_pagevec_fill(struct pagevec *pvec,
>>>>    void munlock_vma_pages_range(struct vm_area_struct *vma,
>>>>                     unsigned long start, unsigned long end)
>>>>    {
>>>> +    unsigned long orig_start = start;
>>>> +    unsigned long page_increm = 0;
>>>> +
>>>>        vma->vm_flags &= ~VM_LOCKED;
>>>>
>>>>        while (start < end) {
>>>>            struct page *page = NULL;
>>>>            unsigned int page_mask;
>>>> -        unsigned long page_increm;
>>>>            struct pagevec pvec;
>>>>            struct zone *zone;
>>>>            int zoneid;
>>>> @@ -491,6 +493,24 @@ void munlock_vma_pages_range(struct vm_area_struct *vma,
>>>>                    &page_mask);
>>>>
>>>>            if (page && !IS_ERR(page)) {
>>>> +            if (PageTail(page)) {
>>>> +                struct page *first_page;
>>>> +                dump_page(page, "Unexpected PageTail");
>>>> +                printk("start=%lu pfn=%lu orig_start=%lu "
>>>> +                       "page_increm=%lu "
>>>> +                       "vm_start=%lu vm_end=%lu vm_flags=%lu\n",
>>>> +                    start, page_to_pfn(page), orig_start,
>>>> +                    page_increm,
>>>> +                    vma->vm_start, vma->vm_end,
>>>> +                    vma->vm_flags);
>>>> +                first_page = page->first_page;
>>>> +                printk("first_page pfn=%lu\n",
>>>> +                        page_to_pfn(first_page));
>>>> +                dump_page(first_page, "first_page of unexpected PageTail page");
>>>> +                if (PageCompound(first_page))
>>>> +                    printk("first_page is compound with order=%d\n", compound_order(first_page));
>>>> +                VM_BUG_ON(true);
>>>> +            }
>>>>                if (PageTransHuge(page)) {
>>>>                    lock_page(page);
>>>>                    /*
>>>> @@ -525,7 +545,25 @@ void munlock_vma_pages_range(struct vm_area_struct *vma,
>>>>                }
>>>>            }
>>>>            /* It's a bug to munlock in the middle of a THP page */
>>>> -        VM_BUG_ON((start >> PAGE_SHIFT) & page_mask);
>>>> +        if ((start >> PAGE_SHIFT) & page_mask) {
>>>> +            dump_page(page, "unexpected middle of THP page");
>>>> +            printk("start=%lu pfn=%lu orig_start=%lu "
>>>
>>> In this scenario page might be error or NULL, no?
>>>
>>
>> Hm I doubt page_mask would be nonzero in such case, but who knows what weirdness causes this...
>> Feel free to move the dump_page() below printk() so we still get useful info before it crashes on
>> dump_page() in such situation.
>
> It happened once, so I moved it, but in the meanwhile I got something useful:
>
> [ 1753.907376] page:ffffea0017130c40 count:0 mapcount:1 mapping:          (null) index:0x2
> [ 1753.908327] page flags: 0x16fffff80008000(tail)
> [ 1753.908973] page dumped because: Unexpected PageTail
> [ 1753.909595] start=140340826935296 pfn=6048817 orig_start=140340826935296 page_increm=0 vm_start=140340826935296 vm_end=140340826939392 vm_flags=1210057078

A VMA spanning a single page (4096 bytes), which appears to be part of 
THP page (and also is not aligned to its beginning).
The VMA flags are: VM_WRITE,VM_EXEC,VM_MAYREAD,VM_MAYWRITE,VM_MAYEXEC
- where's VM_READ, while there's VM_EXEC?
more interesting: VM_GROWSDOWN,VM_NORESERVE,VM_SOFTDIRTY,VM_NOHUGEPAGE

Seems to me it's not possible to allocate a vma with such combination of 
flags, especially the VM_GROWSDOWN seems to be stack-only. So it's 
possible that the vma is corrupted. Could it be related to the vma caching?

> [ 1753.911220] first_page pfn=6048768
> [ 1753.911692] page:ffffea0017130000 count:2 mapcount:1 mapping:ffff880612b41f01 index:0x7fa3a5200
> [ 1753.912733] page flags: 0x16fffff80384028(uptodate|lru|head|swapbacked|unevictable|mlocked)
> [ 1753.913464] page dumped because: first_page of unexpected PageTail page
> [ 1753.914387] pc:ffff88062adcc000 pc->flags:2 pc->mem_cgroup:ffff88012b474520
> [ 1753.914387] first_page is compound with order=9
> [ 1753.914387] ------------[ cut here ]------------
> [ 1753.914387] kernel BUG at mm/mlock.c:512!
> [ 1753.914387] invalid opcode: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
> [ 1753.914387] Dumping ftrace buffer:
> [ 1753.914387]    (ftrace buffer empty)
> [ 1753.914387] Modules linked in:
> [ 1753.914387] CPU: 26 PID: 36822 Comm: trinity-c337 Tainted: G        W     3.14.0-rc6-next-20140317-sasha-00012-ge933921-dirty #226
> [ 1753.914387] task: ffff88090cdeb000 ti: ffff88090a868000 task.ti: ffff88090a868000
> [ 1753.914387] RIP: 0010:[<ffffffff8129ca7a>]  [<ffffffff8129ca7a>] munlock_vma_pages_range+0x12a/0x340
> [ 1753.914387] RSP: 0018:ffff88090a869dd8  EFLAGS: 00010292
> [ 1753.914387] RAX: 0000000000000023 RBX: ffffea0017130000 RCX: 0000000000000006
> [ 1753.914387] RDX: 0000000000000006 RSI: ffff88090cdebcf0 RDI: 0000000000000282
> [ 1753.914387] RBP: ffff88090a869ec8 R08: 0000000000000001 R09: 0000000000000001
> [ 1753.914387] R10: 0000000000000001 R11: 0000000000000001 R12: 00007fa3a5231000
> [ 1753.914387] R13: ffff880613c69400 R14: 0000160000000000 R15: 0000000000000000
> [ 1753.914387] FS:  00007fa3a9081700(0000) GS:ffff880b2ba00000(0000) knlGS:0000000000000000
> [ 1753.914387] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> [ 1753.914387] CR2: 0000000002fff0a8 CR3: 00000008fa08d000 CR4: 00000000000006a0
> [ 1753.914387] Stack:
> [ 1753.914387]  00007fa3a5232000 0000000048200176 00007fa3a552a000 ffff880613c6a800
> [ 1753.914387]  00007fa3a552a000 00007fa3a5231000 0000000000000000 0000000000000000
> [ 1753.914387]  000188090a869e38 0000000000000000 0000000000000000 ffff880613c69400
> [ 1753.914387] Call Trace:
> [ 1753.914387]  [<ffffffff812a0302>] do_munmap+0x1d2/0x360
> [ 1753.914387]  [<ffffffff844a42e6>] ? down_write+0xa6/0xc0
> [ 1753.914387]  [<ffffffff812a04d6>] ? vm_munmap+0x46/0x80
> [ 1753.914387]  [<ffffffff812a04e4>] vm_munmap+0x54/0x80
> [ 1753.914387]  [<ffffffff812a053c>] SyS_munmap+0x2c/0x40
> [ 1753.914387]  [<ffffffff844b04d0>] tracesys+0xdd/0xe2
> [ 1753.914387] Code: 85 48 89 df e8 98 d0 fc ff 66 f7 03 00 c0 74 1b 48 8b 03 31 f6 f6 c4 40 74 03 8b 73 68 48 c7 c7 58 7d 6e 85 31 c0 e8 52 1f 20 03 <0f> 0b 0f 1f 40 00 eb fe 66 0f 1f 44 00 00 48 8b 03 66 85 c0 79
> [ 1753.914387] RIP  [<ffffffff8129ca7a>] munlock_vma_pages_range+0x12a/0x340
> [ 1753.914387]  RSP <ffff88090a869dd8>
>
>
> Thanks,
> Sasha
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
