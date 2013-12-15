Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f169.google.com (mail-ob0-f169.google.com [209.85.214.169])
	by kanga.kvack.org (Postfix) with ESMTP id 7E7B06B0037
	for <linux-mm@kvack.org>; Sun, 15 Dec 2013 14:52:21 -0500 (EST)
Received: by mail-ob0-f169.google.com with SMTP id wm4so4013531obc.0
        for <linux-mm@kvack.org>; Sun, 15 Dec 2013 11:52:21 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id rj3si6074883oeb.16.2013.12.15.11.52.19
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sun, 15 Dec 2013 11:52:20 -0800 (PST)
Message-ID: <52AE07B4.4020203@oracle.com>
Date: Sun, 15 Dec 2013 14:49:08 -0500
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: kernel BUG in munlock_vma_pages_range
References: <52A3D0C3.1080504@oracle.com> <52A58E8A.3050401@suse.cz> <52A5F83F.4000207@oracle.com> <52A5F9EE.4010605@suse.cz> <52A6275F.4040007@oracle.com> <52A8EE38.2060004@suse.cz> <52A92A8D.20603@oracle.com> <52A943BC.2090001@oracle.com> <52A9AEF2.2030600@suse.cz> <52AA2510.8080908@oracle.com> <52AACA0B.6080602@oracle.com> <52AACE79.20804@suse.cz>
In-Reply-To: <52AACE79.20804@suse.cz>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, Bob Liu <bob.liu@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, joern@logfs.org, mgorman@suse.de, Michel Lespinasse <walken@google.com>, riel@redhat.com, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 12/13/2013 04:08 AM, Vlastimil Babka wrote:
> On 12/13/2013 09:49 AM, Bob Liu wrote:
>> On 12/13/2013 05:05 AM, Sasha Levin wrote:
>>> On 12/12/2013 07:41 AM, Vlastimil Babka wrote:
>>>> On 12/12/2013 06:03 AM, Bob Liu wrote:
>>>>>
>>>>> On 12/12/2013 11:16 AM, Sasha Levin wrote:
>>>>>> On 12/11/2013 05:59 PM, Vlastimil Babka wrote:
>>>>>>> On 12/09/2013 09:26 PM, Sasha Levin wrote:
>>>>>>>> On 12/09/2013 12:12 PM, Vlastimil Babka wrote:
>>>>>>>>> On 12/09/2013 06:05 PM, Sasha Levin wrote:
>>>>>>>>>> On 12/09/2013 04:34 AM, Vlastimil Babka wrote:
>>>>>>>>>>> Hello, I will look at it, thanks.
>>>>>>>>>>> Do you have specific reproduction instructions?
>>>>>>>>>>
>>>>>>>>>> Not really, the fuzzer hit it once and I've been unable to trigger
>>>>>>>>>> it again. Looking at
>>>>>>>>>> the piece of code involved it might have had something to do with
>>>>>>>>>> hugetlbfs, so I'll crank
>>>>>>>>>> up testing on that part.
>>>>>>>>>
>>>>>>>>> Thanks. Do you have trinity log and the .config file? I'm currently
>>>>>>>>> unable to even boot linux-next
>>>>>>>>> with my config/setup due to a GPF.
>>>>>>>>> Looking at code I wouldn't expect that it could encounter a tail
>>>>>>>>> page, without first encountering a
>>>>>>>>> head page and skipping the whole huge page. At least in THP case, as
>>>>>>>>> TLB pages should be split when
>>>>>>>>> a vma is split. As for hugetlbfs, it should be skipped for
>>>>>>>>> mlock/munlock operations completely. One
>>>>>>>>> of these assumptions is probably failing here...
>>>>>>>>
>>>>>>>> If it helps, I've added a dump_page() in case we hit a tail page
>>>>>>>> there and got:
>>>>>>>>
>>>>>>>> [  980.172299] page:ffffea003e5e8040 count:0 mapcount:1
>>>>>>>> mapping:          (null) index:0
>>>>>>>> x0
>>>>>>>> [  980.173412] page flags: 0x2fffff80008000(tail)
>>>>>>>>
>>>>>>>> I can also add anything else in there to get other debug output if
>>>>>>>> you think of something else useful.
>>>>>>>
>>>>>>> Please try the following. Thanks in advance.
>>>>>>
>>>>>> [  428.499889] page:ffffea003e5c0040 count:0 mapcount:4
>>>>>> mapping:          (null) index:0x0
>>>>>> [  428.499889] page flags: 0x2fffff80008000(tail)
>>>>>> [  428.499889] start=140117131923456 pfn=16347137
>>>>>> orig_start=140117130543104 page_increm
>>>>>> =1 vm_start=140117130543104 vm_end=140117134688256 vm_flags=135266419
>>>>>> [  428.499889] first_page pfn=16347136
>>>>>> [  428.499889] page:ffffea003e5c0000 count:204 mapcount:44
>>>>>> mapping:ffff880fb5c466c1 inde
>>>>>> x:0x7f6f8fe00
>>>>>> [  428.499889] page flags:
>>>>>> 0x2fffff80084068(uptodate|lru|active|head|swapbacked)
>>>>>
>>>>>     From this print, it looks like the page is still a huge page.
>>>>> One situation I guess is a huge page which isn't PageMlocked and passed
>>>>> to munlock_vma_page(). I'm not sure whether this will happen.
>>>>
>>>> Yes that's quite likely the case. It's not illegal to happen I would say.
>>>>
>>>>> Please take a try this patch.
>>>>
>>>> I've made a simpler version that does away with the ugly page_mask
>>>> thing completely.
>>>> Please try that as well. Thanks.
>>>>
>>>> Also when working on this I think I found another potential but much
>>>> rare problem
>>>> when munlock_vma_page races with a THP split. That would however
>>>> manifest such that
>>>> part of the former tail pages would stay PageMlocked. But that still
>>>> needs more thought.
>>>> The bug at hand should however be fixed by this patch.
>>>
>>> Yup, this patch seems to fix the issue previously reported.
>>>
>>> However, I'll piggyback another thing that popped up now that the vm
>>> could run for a while which
>>> also seems to be caused by the original patch. It looks like a pretty
>>> straightforward deadlock, but
>
> Sigh, put one down, patch it around... :)
>
>> Looks like put_page() in __munlock_pagevec() need to get the
>> zone->lru_lock which is already held when entering __munlock_pagevec().
>
> I've come to the same conclusion, however:
>
>> How about fix like this?
>
> That unfortunately removes most of the purpose of this function which was to avoid repeated locking.
>
> Please try this patch.

All seems to work, thanks!


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
