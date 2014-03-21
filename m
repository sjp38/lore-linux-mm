Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f50.google.com (mail-wg0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 196C96B027A
	for <linux-mm@kvack.org>; Fri, 21 Mar 2014 05:02:08 -0400 (EDT)
Received: by mail-wg0-f50.google.com with SMTP id x13so1370021wgg.33
        for <linux-mm@kvack.org>; Fri, 21 Mar 2014 02:02:07 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d5si612364wik.26.2014.03.21.02.02.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 21 Mar 2014 02:02:05 -0700 (PDT)
Message-ID: <532C000C.8010505@suse.cz>
Date: Fri, 21 Mar 2014 10:02:04 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: kernel BUG in munlock_vma_pages_range
References: <52A3D0C3.1080504@oracle.com> <52A58E8A.3050401@suse.cz> <52A5F83F.4000207@oracle.com> <52A5F9EE.4010605@suse.cz> <52A6275F.4040007@oracle.com> <52A8EE38.2060004@suse.cz> <52A92A8D.20603@oracle.com> <52A943BC.2090001@oracle.com> <52A9AEF2.2030600@suse.cz> <52AA2510.8080908@oracle.com> <52AACA0B.6080602@oracle.com> <52AACE79.20804@suse.cz> <532B9BA0.9060503@oracle.com>
In-Reply-To: <532B9BA0.9060503@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>, Bob Liu <bob.liu@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, joern@logfs.org, mgorman@suse.de, Michel Lespinasse <walken@google.com>, riel@redhat.com, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 03/21/2014 02:53 AM, Sasha Levin wrote:
> On 12/13/2013 04:08 AM, Vlastimil Babka wrote:
>> On 12/13/2013 09:49 AM, Bob Liu wrote:
>>> On 12/13/2013 05:05 AM, Sasha Levin wrote:
>>>> On 12/12/2013 07:41 AM, Vlastimil Babka wrote:
>>>>> On 12/12/2013 06:03 AM, Bob Liu wrote:
>>>>>>
>>>>>> On 12/12/2013 11:16 AM, Sasha Levin wrote:
>>>>>>> On 12/11/2013 05:59 PM, Vlastimil Babka wrote:
>>>>>>>> On 12/09/2013 09:26 PM, Sasha Levin wrote:
>>>>>>>>> On 12/09/2013 12:12 PM, Vlastimil Babka wrote:
>>>>>>>>>> On 12/09/2013 06:05 PM, Sasha Levin wrote:
>>>>>>>>>>> On 12/09/2013 04:34 AM, Vlastimil Babka wrote:
>>>>>>>>>>>> Hello, I will look at it, thanks.
>>>>>>>>>>>> Do you have specific reproduction instructions?
>>>>>>>>>>>
>>>>>>>>>>> Not really, the fuzzer hit it once and I've been unable to trigger
>>>>>>>>>>> it again. Looking at
>>>>>>>>>>> the piece of code involved it might have had something to do with
>>>>>>>>>>> hugetlbfs, so I'll crank
>>>>>>>>>>> up testing on that part.
>>>>>>>>>>
>>>>>>>>>> Thanks. Do you have trinity log and the .config file? I'm currently
>>>>>>>>>> unable to even boot linux-next
>>>>>>>>>> with my config/setup due to a GPF.
>>>>>>>>>> Looking at code I wouldn't expect that it could encounter a tail
>>>>>>>>>> page, without first encountering a
>>>>>>>>>> head page and skipping the whole huge page. At least in THP case, as
>>>>>>>>>> TLB pages should be split when
>>>>>>>>>> a vma is split. As for hugetlbfs, it should be skipped for
>>>>>>>>>> mlock/munlock operations completely. One
>>>>>>>>>> of these assumptions is probably failing here...
>>>>>>>>>
>>>>>>>>> If it helps, I've added a dump_page() in case we hit a tail page
>>>>>>>>> there and got:
>>>>>>>>>
>>>>>>>>> [  980.172299] page:ffffea003e5e8040 count:0 mapcount:1
>>>>>>>>> mapping:          (null) index:0
>>>>>>>>> x0
>>>>>>>>> [  980.173412] page flags: 0x2fffff80008000(tail)
>>>>>>>>>
>>>>>>>>> I can also add anything else in there to get other debug output if
>>>>>>>>> you think of something else useful.
>>>>>>>>
>>>>>>>> Please try the following. Thanks in advance.
>>>>>>>
>>>>>>> [  428.499889] page:ffffea003e5c0040 count:0 mapcount:4
>>>>>>> mapping:          (null) index:0x0
>>>>>>> [  428.499889] page flags: 0x2fffff80008000(tail)
>>>>>>> [  428.499889] start=140117131923456 pfn=16347137
>>>>>>> orig_start=140117130543104 page_increm
>>>>>>> =1 vm_start=140117130543104 vm_end=140117134688256 vm_flags=135266419
>>>>>>> [  428.499889] first_page pfn=16347136
>>>>>>> [  428.499889] page:ffffea003e5c0000 count:204 mapcount:44
>>>>>>> mapping:ffff880fb5c466c1 inde
>>>>>>> x:0x7f6f8fe00
>>>>>>> [  428.499889] page flags:
>>>>>>> 0x2fffff80084068(uptodate|lru|active|head|swapbacked)
>>>>>>
>>>>>>      From this print, it looks like the page is still a huge page.
>>>>>> One situation I guess is a huge page which isn't PageMlocked and passed
>>>>>> to munlock_vma_page(). I'm not sure whether this will happen.
>>>>>
>>>>> Yes that's quite likely the case. It's not illegal to happen I would say.
>>>>>
>>>>>> Please take a try this patch.
>>>>>
>>>>> I've made a simpler version that does away with the ugly page_mask
>>>>> thing completely.
>>>>> Please try that as well. Thanks.
>>>>>
>>>>> Also when working on this I think I found another potential but much
>>>>> rare problem
>>>>> when munlock_vma_page races with a THP split. That would however
>>>>> manifest such that
>>>>> part of the former tail pages would stay PageMlocked. But that still
>>>>> needs more thought.
>>>>> The bug at hand should however be fixed by this patch.
>>>>
>>>> Yup, this patch seems to fix the issue previously reported.
>>>>
>>>> However, I'll piggyback another thing that popped up now that the vm
>>>> could run for a while which
>>>> also seems to be caused by the original patch. It looks like a pretty
>>>> straightforward deadlock, but
>>
>> Sigh, put one down, patch it around... :)
>>
>>> Looks like put_page() in __munlock_pagevec() need to get the
>>> zone->lru_lock which is already held when entering __munlock_pagevec().
>>
>> I've come to the same conclusion, however:
>>
>>> How about fix like this?
>>
>> That unfortunately removes most of the purpose of this function which was to avoid repeated locking.
>>
>> Please try this patch.
>
> It seems that this one is back, not exactly sure why yet:

Hm? You reported this already 6 days ago in this thread:
http://marc.info/?l=linux-mm&m=139484133311556&w=2

Then I sent a debug patch and from your results concluded something is 
probably wrong with the vma and suspected vma caching:
http://marc.info/?l=linux-mm&m=139513931519048&w=2

However next-20140320 means that the latest fixes to vma caching were 
applied, so I have no idea now. But reapplying the debug patch shouldn't 
hurt, maybe it will yield something else/more useful this time.

Vlastimil

> [ 2857.034927] kernel BUG at include/linux/page-flags.h:415!
> [ 2857.035576] invalid opcode: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
> [ 2857.036702] Dumping ftrace buffer:
> [ 2857.037447]    (ftrace buffer empty)
> [ 2857.037937] Modules linked in:
> [ 2857.038379] CPU: 25 PID: 21381 Comm: trinity-c61 Tainted: G        W     3.14.0-rc7-next-20140320-sasha-00015-gd752393-dirty #261
> [ 2857.039854] task: ffff88080f91b000 ti: ffff8807fd106000 task.ti: ffff8807fd106000
> [ 2857.040328] RIP: 0010:[<ffffffff8129dc93>]  [<ffffffff8129dc93>] munlock_vma_pages_range+0x93/0x1d0
> [ 2857.040328] RSP: 0000:ffff8807fd107e08  EFLAGS: 00010246
> [ 2857.040328] RAX: ffff88052c955360 RBX: 0000000041b36000 RCX: 000000000000009f
> [ 2857.040328] RDX: 0000000000000000 RSI: ffff88080f91bcf0 RDI: 0000000004fd5360
> [ 2857.040328] RBP: ffff8807fd107ec8 R08: 0000000000000001 R09: 0000000000000000
> [ 2857.040328] R10: 0000000000000001 R11: 0000000000000001 R12: ffffea0013f54d80
> [ 2857.040328] R13: ffff88068083c200 R14: 0000000041b37000 R15: ffff8807fd107e94
> [ 2857.040328] FS:  00007fcd4bd02700(0000) GS:ffff8806acc00000(0000) knlGS:0000000000000000
> [ 2857.040328] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> [ 2857.040328] CR2: 00000000027405a8 CR3: 0000000804ad4000 CR4: 00000000000006a0
> [ 2857.040328] DR0: 0000000000698000 DR1: 0000000000698000 DR2: 0000000000000000
> [ 2857.040328] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000600
> [ 2857.040328] Stack:
> [ 2857.040328]  0000000000000000 0000000000000000 00018807fd107e38 0000000000000000
> [ 2857.040328]  0000000000000000 ffff88068083c200 00000000fd107e88 0000000000000000
> [ 2857.040328]  00ff8807fd107e58 ffff88052be99b20 ffff8807fd107eb8 ffff88068083c200
> [ 2857.040328] Call Trace:
> [ 2857.040328]  [<ffffffff812a1462>] do_munmap+0x1d2/0x360
> [ 2857.040328]  [<ffffffff844bce16>] ? down_write+0xa6/0xc0
> [ 2857.040328]  [<ffffffff812a1636>] ? vm_munmap+0x46/0x80
> [ 2857.040328]  [<ffffffff812a1644>] vm_munmap+0x54/0x80
> [ 2857.040328]  [<ffffffff812a169c>] SyS_munmap+0x2c/0x40
> [ 2857.040328]  [<ffffffff844c9210>] tracesys+0xdd/0xe2
> [ 2857.040328] Code: ff 49 89 c4 48 85 c0 0f 84 f3 00 00 00 48 3d 00 f0 ff ff 0f 87 e7 00 00 00 48 8b 00 66 85 c0 79 17 31 f6 4c 89 e7 e8 fd d0 fc ff <0f> 0b 0f 1f 00 eb fe 66 0f 1f 44 00 00 49 8b 04 24 f6 c4 40 74
> [ 2857.062774] RIP  [<ffffffff8129dc93>] munlock_vma_pages_range+0x93/0x1d0
> [ 2857.062774]  RSP <ffff8807fd107e08>
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
