Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f179.google.com (mail-ob0-f179.google.com [209.85.214.179])
	by kanga.kvack.org (Postfix) with ESMTP id 3E08F6B0031
	for <linux-mm@kvack.org>; Wed, 11 Dec 2013 22:24:46 -0500 (EST)
Received: by mail-ob0-f179.google.com with SMTP id wm4so8051599obc.10
        for <linux-mm@kvack.org>; Wed, 11 Dec 2013 19:24:46 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id co8si15043174oec.60.2013.12.11.19.24.44
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 11 Dec 2013 19:24:45 -0800 (PST)
Message-ID: <52A92A8D.20603@oracle.com>
Date: Wed, 11 Dec 2013 22:16:29 -0500
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: kernel BUG in munlock_vma_pages_range
References: <52A3D0C3.1080504@oracle.com> <52A58E8A.3050401@suse.cz> <52A5F83F.4000207@oracle.com> <52A5F9EE.4010605@suse.cz> <52A6275F.4040007@oracle.com> <52A8EE38.2060004@suse.cz>
In-Reply-To: <52A8EE38.2060004@suse.cz>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>
Cc: joern@logfs.org, mgorman@suse.de, Michel Lespinasse <walken@google.com>, riel@redhat.com, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 12/11/2013 05:59 PM, Vlastimil Babka wrote:
> On 12/09/2013 09:26 PM, Sasha Levin wrote:
>> On 12/09/2013 12:12 PM, Vlastimil Babka wrote:
>>> On 12/09/2013 06:05 PM, Sasha Levin wrote:
>>>> On 12/09/2013 04:34 AM, Vlastimil Babka wrote:
>>>>> Hello, I will look at it, thanks.
>>>>> Do you have specific reproduction instructions?
>>>>
>>>> Not really, the fuzzer hit it once and I've been unable to trigger it again. Looking at
>>>> the piece of code involved it might have had something to do with hugetlbfs, so I'll crank
>>>> up testing on that part.
>>>
>>> Thanks. Do you have trinity log and the .config file? I'm currently unable to even boot linux-next
>>> with my config/setup due to a GPF.
>>> Looking at code I wouldn't expect that it could encounter a tail page, without first encountering a
>>> head page and skipping the whole huge page. At least in THP case, as TLB pages should be split when
>>> a vma is split. As for hugetlbfs, it should be skipped for mlock/munlock operations completely. One
>>> of these assumptions is probably failing here...
>>
>> If it helps, I've added a dump_page() in case we hit a tail page there and got:
>>
>> [  980.172299] page:ffffea003e5e8040 count:0 mapcount:1 mapping:          (null) index:0
>> x0
>> [  980.173412] page flags: 0x2fffff80008000(tail)
>>
>> I can also add anything else in there to get other debug output if you think of something else useful.
>
> Please try the following. Thanks in advance.

[  428.499889] page:ffffea003e5c0040 count:0 mapcount:4 mapping:          (null) index:0x0
[  428.499889] page flags: 0x2fffff80008000(tail)
[  428.499889] start=140117131923456 pfn=16347137 orig_start=140117130543104 page_increm
=1 vm_start=140117130543104 vm_end=140117134688256 vm_flags=135266419
[  428.499889] first_page pfn=16347136
[  428.499889] page:ffffea003e5c0000 count:204 mapcount:44 mapping:ffff880fb5c466c1 inde
x:0x7f6f8fe00
[  428.499889] page flags: 0x2fffff80084068(uptodate|lru|active|head|swapbacked)
[  428.499889] pc:ffff880fcfb70000 pc->flags:2 pc->mem_cgroup:ffffc90006034000
[  428.374171]  0000000000000000
[  428.374171]  0000000000000000 0000000000000000 0000000000000000 0000000000000000
[  428.374171] Call Trace:
[  428.374171]  [<ffffffff81283df9>] exit_mmap+0x59/0x170
[  428.374171]  [<ffffffff812b72d0>] ? __khugepaged_exit+0xe0/0x150
[  428.374171]  [<ffffffff812af89b>] ? kmem_cache_free+0x26b/0x370
[  428.374171]  [<ffffffff812b72d0>] ? __khugepaged_exit+0xe0/0x150
[  428.374171]  [<ffffffff8112e440>] mmput+0x70/0xe0
[  428.374171]  [<ffffffff8113246d>] exit_mm+0x18d/0x1a0
[  428.374171]  [<ffffffff811df625>] ? acct_collect+0x175/0x1b0
[  428.374171]  [<ffffffff811348df>] do_exit+0x26f/0x520
[  428.374171]  [<ffffffff81134c39>] do_group_exit+0xa9/0xe0
[  428.374171]  [<ffffffff81149d72>] get_signal_to_deliver+0x4e2/0x570
[  428.374171]  [<ffffffff8106cc3b>] do_signal+0x4b/0x120
[  428.374171]  [<ffffffff81176346>] ? vtime_account_user+0x96/0xb0
[  428.374171]  [<ffffffff843b0475>] ? _raw_spin_unlock+0x35/0x60
[  428.374171]  [<ffffffff81176346>] ? vtime_account_user+0x96/0xb0
[  428.374171]  [<ffffffff81249a58>] ? context_tracking_user_exit+0xb8/0x1d0
[  428.374171]  [<ffffffff8119376d>] ? trace_hardirqs_on+0xd/0x10
[  428.374171]  [<ffffffff8106cf9a>] do_notify_resume+0x5a/0xe0
[  428.374171]  [<ffffffff843b9d22>] int_signal+0x12/0x17
[  428.374171] Code: 46 85 31 c0 e8 f9 60 12 03 48 8b 5b 30 48 c7 c7 b0 92 46 85 4a 8d 34 33 31 c0 
48 c1 fe 06 e8 df 60 12 03 48 89 df e8 97 e1 fc ff <0f> 0b 0f 1f 44 00 00 eb fe 66 0f 1f 44 00 00 48 
8b 03 66 85 c0
[  428.374171] RIP  [<ffffffff81282829>] munlock_vma_pages_range+0x109/0x240
[  428.374171]  RSP <ffff880f928edb38>

Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
