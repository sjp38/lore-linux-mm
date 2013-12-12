Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f169.google.com (mail-ie0-f169.google.com [209.85.223.169])
	by kanga.kvack.org (Postfix) with ESMTP id C97B46B0035
	for <linux-mm@kvack.org>; Thu, 12 Dec 2013 16:12:22 -0500 (EST)
Received: by mail-ie0-f169.google.com with SMTP id e14so1590409iej.0
        for <linux-mm@kvack.org>; Thu, 12 Dec 2013 13:12:22 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id q8si17474035pav.57.2013.12.12.13.12.19
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 12 Dec 2013 13:12:21 -0800 (PST)
Message-ID: <52AA2510.8080908@oracle.com>
Date: Thu, 12 Dec 2013 16:05:20 -0500
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: kernel BUG in munlock_vma_pages_range
References: <52A3D0C3.1080504@oracle.com> <52A58E8A.3050401@suse.cz> <52A5F83F.4000207@oracle.com> <52A5F9EE.4010605@suse.cz> <52A6275F.4040007@oracle.com> <52A8EE38.2060004@suse.cz> <52A92A8D.20603@oracle.com> <52A943BC.2090001@oracle.com> <52A9AEF2.2030600@suse.cz>
In-Reply-To: <52A9AEF2.2030600@suse.cz>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, Bob Liu <bob.liu@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, joern@logfs.org, mgorman@suse.de, Michel Lespinasse <walken@google.com>, riel@redhat.com, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 12/12/2013 07:41 AM, Vlastimil Babka wrote:
> On 12/12/2013 06:03 AM, Bob Liu wrote:
>>
>> On 12/12/2013 11:16 AM, Sasha Levin wrote:
>>> On 12/11/2013 05:59 PM, Vlastimil Babka wrote:
>>>> On 12/09/2013 09:26 PM, Sasha Levin wrote:
>>>>> On 12/09/2013 12:12 PM, Vlastimil Babka wrote:
>>>>>> On 12/09/2013 06:05 PM, Sasha Levin wrote:
>>>>>>> On 12/09/2013 04:34 AM, Vlastimil Babka wrote:
>>>>>>>> Hello, I will look at it, thanks.
>>>>>>>> Do you have specific reproduction instructions?
>>>>>>>
>>>>>>> Not really, the fuzzer hit it once and I've been unable to trigger
>>>>>>> it again. Looking at
>>>>>>> the piece of code involved it might have had something to do with
>>>>>>> hugetlbfs, so I'll crank
>>>>>>> up testing on that part.
>>>>>>
>>>>>> Thanks. Do you have trinity log and the .config file? I'm currently
>>>>>> unable to even boot linux-next
>>>>>> with my config/setup due to a GPF.
>>>>>> Looking at code I wouldn't expect that it could encounter a tail
>>>>>> page, without first encountering a
>>>>>> head page and skipping the whole huge page. At least in THP case, as
>>>>>> TLB pages should be split when
>>>>>> a vma is split. As for hugetlbfs, it should be skipped for
>>>>>> mlock/munlock operations completely. One
>>>>>> of these assumptions is probably failing here...
>>>>>
>>>>> If it helps, I've added a dump_page() in case we hit a tail page
>>>>> there and got:
>>>>>
>>>>> [  980.172299] page:ffffea003e5e8040 count:0 mapcount:1
>>>>> mapping:          (null) index:0
>>>>> x0
>>>>> [  980.173412] page flags: 0x2fffff80008000(tail)
>>>>>
>>>>> I can also add anything else in there to get other debug output if
>>>>> you think of something else useful.
>>>>
>>>> Please try the following. Thanks in advance.
>>>
>>> [  428.499889] page:ffffea003e5c0040 count:0 mapcount:4
>>> mapping:          (null) index:0x0
>>> [  428.499889] page flags: 0x2fffff80008000(tail)
>>> [  428.499889] start=140117131923456 pfn=16347137
>>> orig_start=140117130543104 page_increm
>>> =1 vm_start=140117130543104 vm_end=140117134688256 vm_flags=135266419
>>> [  428.499889] first_page pfn=16347136
>>> [  428.499889] page:ffffea003e5c0000 count:204 mapcount:44
>>> mapping:ffff880fb5c466c1 inde
>>> x:0x7f6f8fe00
>>> [  428.499889] page flags:
>>> 0x2fffff80084068(uptodate|lru|active|head|swapbacked)
>>
>>   From this print, it looks like the page is still a huge page.
>> One situation I guess is a huge page which isn't PageMlocked and passed
>> to munlock_vma_page(). I'm not sure whether this will happen.
>
> Yes that's quite likely the case. It's not illegal to happen I would say.
>
>> Please take a try this patch.
>
> I've made a simpler version that does away with the ugly page_mask thing completely.
> Please try that as well. Thanks.
>
> Also when working on this I think I found another potential but much rare problem
> when munlock_vma_page races with a THP split. That would however manifest such that
> part of the former tail pages would stay PageMlocked. But that still needs more thought.
> The bug at hand should however be fixed by this patch.

Yup, this patch seems to fix the issue previously reported.

However, I'll piggyback another thing that popped up now that the vm could run for a while which
also seems to be caused by the original patch. It looks like a pretty straightforward deadlock, but
I'm not clear enough of the locking rules in mm to actually fix that correctly myself.

The vm did actually deadlock after that spew.

[ 2873.680623] =============================================
[ 2873.682127] [ INFO: possible recursive locking detected ]
[ 2873.683111] 3.13.0-rc3-next-20131212-sasha-00007-g97a2f20 #4064 Tainted: G        W
[ 2873.684600] ---------------------------------------------
[ 2873.685551] trinity-child88/6156 is trying to acquire lock:

[ 2873.686348]  (&(&zone->lru_lock)->rlock){......}, at: [<ffffffff8125ccff>] 
__page_cache_release+0x5f/0x150
[ 2873.688106]
[ 2873.688106] but task is already holding lock:
[ 2873.689006]  (&(&zone->lru_lock)->rlock){......}, at: [<ffffffff81282289>] 
__munlock_pagevec+0x49/0x360
[ 2873.690176]
[ 2873.690176] other info that might help us debug this:
[ 2873.690176]  Possible unsafe locking scenario:
[ 2873.690176]
[ 2873.690176]        CPU0
[ 2873.690176]        ----
[ 2873.690176]   lock(&(&zone->lru_lock)->rlock);
[ 2873.690176]   lock(&(&zone->lru_lock)->rlock);
[ 2873.690176]
[ 2873.690176]  *** DEADLOCK ***
[ 2873.690176]
[ 2873.690176]  May be due to missing lock nesting notation
[ 2873.690176]
[ 2873.690176] 2 locks held by trinity-child88/6156:
[ 2873.690176]  #0:  (&mm->mmap_sem){++++++}, at: [<ffffffff8127816e>] SyS_remap_file_pages+0x17e/0x3f0
[ 2873.690176]  #1:  (&(&zone->lru_lock)->rlock){......}, at: [<ffffffff81282289>] 
__munlock_pagevec+0x49/0x360
[ 2873.690176]
[ 2873.690176] stack backtrace:
[ 2873.690176] CPU: 25 PID: 6156 Comm: trinity-child88 Tainted: G        W 
3.13.0-rc3-next-20131212-sasha-00007-g97a2f20 #4064
[ 2873.690176]  ffff880eb3a3bc10 ffff880e17351ae8 ffffffff843a9db7 0000000000000000
[ 2873.690176]  ffff880eb3a3b000 ffff880e17351b28 ffffffff8119263a ffff880e17351b08
[ 2873.690176]  ffffffff8107599d ffff880e17351b38 ffff880eb3a3bc48 ffff880eb3a3b000
[ 2873.690176] Call Trace:
[ 2873.690176]  [<ffffffff843a9db7>] dump_stack+0x52/0x7f
[ 2873.690176]  [<ffffffff8119263a>] print_deadlock_bug+0x11a/0x140
[ 2873.690176]  [<ffffffff8107599d>] ? sched_clock+0x1d/0x30
[ 2873.690176]  [<ffffffff8119474b>] validate_chain+0x60b/0x7b0
[ 2873.690176]  [<ffffffff81175588>] ? sched_clock_cpu+0x108/0x120
[ 2873.690176]  [<ffffffff81194d9d>] __lock_acquire+0x4ad/0x580
[ 2873.690176]  [<ffffffff81194ff2>] lock_acquire+0x182/0x1d0
[ 2873.690176]  [<ffffffff8125ccff>] ? __page_cache_release+0x5f/0x150
[ 2873.690176]  [<ffffffff81194dba>] ? __lock_acquire+0x4ca/0x580
[ 2873.690176]  [<ffffffff843b0931>] _raw_spin_lock_irqsave+0x91/0xd0
[ 2873.690176]  [<ffffffff8125ccff>] ? __page_cache_release+0x5f/0x150
[ 2873.690176]  [<ffffffff8125ccff>] __page_cache_release+0x5f/0x150
[ 2873.690176]  [<ffffffff81282289>] ? __munlock_pagevec+0x49/0x360
[ 2873.690176]  [<ffffffff8125ce36>] __put_single_page+0x16/0x30
[ 2873.690176]  [<ffffffff81282289>] ? __munlock_pagevec+0x49/0x360
[ 2873.690176]  [<ffffffff8125d7d8>] put_page+0x48/0x50
[ 2873.690176]  [<ffffffff812823b1>] __munlock_pagevec+0x171/0x360
[ 2873.690176]  [<ffffffff843b1756>] ? _raw_spin_unlock+0x46/0x60
[ 2873.690176]  [<ffffffff81282701>] ? __munlock_pagevec_fill+0x161/0x180
[ 2873.690176]  [<ffffffff812828b8>] munlock_vma_pages_range+0x198/0x1e0
[ 2873.690176]  [<ffffffff812782a7>] SyS_remap_file_pages+0x2b7/0x3f0
[ 2873.690176]  [<ffffffff843baed0>] tracesys+0xdd/0xe2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
