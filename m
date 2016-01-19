Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f172.google.com (mail-yk0-f172.google.com [209.85.160.172])
	by kanga.kvack.org (Postfix) with ESMTP id C562E6B0009
	for <linux-mm@kvack.org>; Mon, 18 Jan 2016 22:01:21 -0500 (EST)
Received: by mail-yk0-f172.google.com with SMTP id v14so540344215ykd.3
        for <linux-mm@kvack.org>; Mon, 18 Jan 2016 19:01:21 -0800 (PST)
Received: from mail-yk0-x22c.google.com (mail-yk0-x22c.google.com. [2607:f8b0:4002:c07::22c])
        by mx.google.com with ESMTPS id 205si16274477ywl.10.2016.01.18.19.01.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Jan 2016 19:01:20 -0800 (PST)
Received: by mail-yk0-x22c.google.com with SMTP id a85so555958667ykb.1
        for <linux-mm@kvack.org>; Mon, 18 Jan 2016 19:01:20 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CA+eFSM0Nh4e0VjzDoaSEfbQNQwuHEnHkSmfsQCQmfgRUcOoofg@mail.gmail.com>
References: <1453125834-16546-1-git-send-email-liangchen.linux@gmail.com>
 <alpine.DEB.2.10.1601191005350.2469@hxeon> <CA+eFSM0Nh4e0VjzDoaSEfbQNQwuHEnHkSmfsQCQmfgRUcOoofg@mail.gmail.com>
From: SeongJae Park <sj38.park@gmail.com>
Date: Tue, 19 Jan 2016 12:00:51 +0900
Message-ID: <CAEjAshocB0U90TU5kpm+woWcf=1=NmhbXpPs_iT_fz5R8PoczA@mail.gmail.com>
Subject: Re: [PATCH] mm:mempolicy: skip VM_HUGETLB and VM_MIXEDMAP VMA for
 lazy mbind
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gavin Guo <gavin.guo@canonical.com>
Cc: Liang Chen <liangchen.linux@gmail.com>, n-horiguchi@ah.jp.nec.com, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>

Hi Gavin,


On Tue, Jan 19, 2016 at 11:43 AM, Gavin Guo <gavin.guo@canonical.com> wrote:
> Hi SeongJae,
>
> On Tue, Jan 19, 2016 at 9:12 AM, SeongJae Park <sj38.park@gmail.com> wrote:
>> Hello Liang,
>>
>> Just trivial comment below.
>>
>> On Mon, 18 Jan 2016, Liang Chen wrote:
>>
>>> VM_HUGETLB and VM_MIXEDMAP vma needs to be excluded to avoid compound
>>> pages being marked for migration and unexpected COWs when handling
>>> hugetlb fault.
>>>
>>> Thanks to Naoya Horiguchi for reminding me on these checks.
>>>
>>> Signed-off-by: Liang Chen <liangchen.linux@gmail.com>
>>> Signed-off-by: Gavin Guo <gavin.guo@canonical.com>
>>> ---
>>> mm/mempolicy.c | 5 +++--
>>> 1 file changed, 3 insertions(+), 2 deletions(-)
>>>
>>> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
>>> index 436ff411..415de70 100644
>>> --- a/mm/mempolicy.c
>>> +++ b/mm/mempolicy.c
>>> @@ -610,8 +610,9 @@ static int queue_pages_test_walk(unsigned long start,
>>> unsigned long end,
>>>
>>>         if (flags & MPOL_MF_LAZY) {
>>>                 /* Similar to task_numa_work, skip inaccessible VMAs */
>>> -               if (vma_migratable(vma) &&
>>> -                       vma->vm_flags & (VM_READ | VM_EXEC | VM_WRITE))
>>> +               if (vma_migratable(vma) && !is_vm_hugetlb_page(vma) &&
>>> +                       (vma->vm_flags & (VM_READ | VM_EXEC | VM_WRITE))
>>> &&
>>> +                       !(vma->vm_flags & VM_MIXEDMAP))
>>
>>
>> Isn't there exists few unnecessary parenthesis? IMHO, it makes me hard to
>> read the code.
>>
>> How about below code, instead?
>>
>> +             if (vma_migratable(vma) && !is_vm_hugetlb_page(vma) &&
>> +                     vma->vm_flags & (VM_READ | VM_EXEC | VM_WRITE) &&
>
> Thanks for your suggestion, it's good for the above. However, it should be
> a typo for the following and I think you mean:
>
>         ~vma->vm_flags & VM_MIXEDMAP
>
> Even though the result is correct, I feel it's a bit of ambiguous for
> people to understand and away from it's original meaning.

Ah, you're right. That's my fault. Thanks for noting that.

BTW, now I think the line could be expressed in this way:
         vma->vm_flags & ~VM_MIXEDMAP

I feel this is sufficiently explicit and follows the meaning well.
However, I agree that Liang's first one is good enough, too.

Thanks,
SeongJae Park.

>
>> +                     !vma->vm_flags & VM_MIXEDMAP)
>>
>>
>> Thanks,
>> SeongJae Park.
>>
>>>                         change_prot_numa(vma, start, endvma);
>>>                 return 1;
>>>         }
>>> --
>>> 1.9.1
>>>
>>> --
>>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>>> the body to majordomo@kvack.org.  For more info on Linux MM,
>>> see: http://www.linux-mm.org/ .
>>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>>>
>>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
