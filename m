Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id 473C96B0038
	for <linux-mm@kvack.org>; Mon,  7 Sep 2015 06:52:44 -0400 (EDT)
Received: by wiclk2 with SMTP id lk2so79807569wic.1
        for <linux-mm@kvack.org>; Mon, 07 Sep 2015 03:52:43 -0700 (PDT)
Received: from mail2.vodafone.ie (mail2.vodafone.ie. [213.233.128.44])
        by mx.google.com with ESMTP id gh10si20222718wic.24.2015.09.07.03.52.42
        for <linux-mm@kvack.org>;
        Mon, 07 Sep 2015 03:52:43 -0700 (PDT)
Message-ID: <55ED6C79.6030000@draigBrady.com>
Date: Mon, 07 Sep 2015 11:52:41 +0100
From: =?UTF-8?B?UMOhZHJhaWcgQnJhZHk=?= <P@draigBrady.com>
MIME-Version: 1.0
Subject: Re: [PATCH v5 1/2] mm: hugetlb: proc: add HugetlbPages field to /proc/PID/smaps
References: <20150812000336.GB32192@hori1.linux.bs1.fc.nec.co.jp> <1440059182-19798-1-git-send-email-n-horiguchi@ah.jp.nec.com> <1440059182-19798-2-git-send-email-n-horiguchi@ah.jp.nec.com> <55ECE891.7030309@draigBrady.com> <20150907022343.GB6448@hori1.linux.bs1.fc.nec.co.jp> <20150907064614.GB7229@hori1.linux.bs1.fc.nec.co.jp> <55ED5E6C.6000102@draigBrady.com>
In-Reply-To: <55ED5E6C.6000102@draigBrady.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, =?UTF-8?B?SsO2cm4gRW5nZWw=?= <joern@purestorage.com>, Mike Kravetz <mike.kravetz@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>

On 07/09/15 10:52, PA!draig Brady wrote:
> On 07/09/15 07:46, Naoya Horiguchi wrote:
>> On Mon, Sep 07, 2015 at 02:23:44AM +0000, Horiguchi Naoya(a ?a?GBP c?'a1?) wrote:
>>> On Mon, Sep 07, 2015 at 02:29:53AM +0100, PA!draig Brady wrote:
>>>> On 20/08/15 09:26, Naoya Horiguchi wrote:
>>>>> Currently /proc/PID/smaps provides no usage info for vma(VM_HUGETLB), which
>>>>> is inconvenient when we want to know per-task or per-vma base hugetlb usage.
>>>>> To solve this, this patch adds a new line for hugetlb usage like below:
>>>>>
>>>>>   Size:              20480 kB
>>>>>   Rss:                   0 kB
>>>>>   Pss:                   0 kB
>>>>>   Shared_Clean:          0 kB
>>>>>   Shared_Dirty:          0 kB
>>>>>   Private_Clean:         0 kB
>>>>>   Private_Dirty:         0 kB
>>>>>   Referenced:            0 kB
>>>>>   Anonymous:             0 kB
>>>>>   AnonHugePages:         0 kB
>>>>>   HugetlbPages:      18432 kB
>>>>>   Swap:                  0 kB
>>>>>   KernelPageSize:     2048 kB
>>>>>   MMUPageSize:        2048 kB
>>>>>   Locked:                0 kB
>>>>>   VmFlags: rd wr mr mw me de ht
>>>>>
>>>>> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
>>>>> Acked-by: Joern Engel <joern@logfs.org>
>>>>> Acked-by: David Rientjes <rientjes@google.com>
>>>>> ---
>>>>> v3 -> v4:
>>>>> - suspend Acked-by tag because v3->v4 change is not trivial
>>>>> - I stated in previous discussion that HugetlbPages line can contain page
>>>>>   size info, but that's not necessary because we already have KernelPageSize
>>>>>   info.
>>>>> - merged documentation update, where the current documentation doesn't mention
>>>>>   AnonHugePages, so it's also added.
>>>>> ---
>>>>>  Documentation/filesystems/proc.txt |  7 +++++--
>>>>>  fs/proc/task_mmu.c                 | 29 +++++++++++++++++++++++++++++
>>>>>  2 files changed, 34 insertions(+), 2 deletions(-)
>>>>>
>>>>> diff --git v4.2-rc4/Documentation/filesystems/proc.txt v4.2-rc4_patched/Documentation/filesystems/proc.txt
>>>>> index 6f7fafde0884..22e40211ef64 100644
>>>>> --- v4.2-rc4/Documentation/filesystems/proc.txt
>>>>> +++ v4.2-rc4_patched/Documentation/filesystems/proc.txt
>>>>> @@ -423,6 +423,8 @@ Private_Clean:         0 kB
>>>>>  Private_Dirty:         0 kB
>>>>>  Referenced:          892 kB
>>>>>  Anonymous:             0 kB
>>>>> +AnonHugePages:         0 kB
>>>>> +HugetlbPages:          0 kB
>>>>>  Swap:                  0 kB
>>>>>  KernelPageSize:        4 kB
>>>>>  MMUPageSize:           4 kB
>>>>> @@ -440,8 +442,9 @@ indicates the amount of memory currently marked as referenced or accessed.
>>>>>  "Anonymous" shows the amount of memory that does not belong to any file.  Even
>>>>>  a mapping associated with a file may contain anonymous pages: when MAP_PRIVATE
>>>>>  and a page is modified, the file page is replaced by a private anonymous copy.
>>>>> -"Swap" shows how much would-be-anonymous memory is also used, but out on
>>>>> -swap.
>>>>> +"AnonHugePages" shows the ammount of memory backed by transparent hugepage.
>>>>> +"HugetlbPages" shows the ammount of memory backed by hugetlbfs page.
>>>>> +"Swap" shows how much would-be-anonymous memory is also used, but out on swap.
>>>>
>>>> There is no distinction between "private" and "shared" in this "huge page" accounting right?
>>>
>>> Right for current version. And I think that private/shared distinction
>>> gives some help.
>>>
>>>> Would it be possible to account for the huge pages in the {Private,Shared}_{Clean,Dirty} fields?
>>>> Or otherwise split the huge page accounting into shared/private?
>>
>> Sorry, I didn't catch you properly.
>> I think that accounting for hugetlb pages should be done only with HugetlbPages
>> or any other new field for hugetlb, in order not to break the behavior of existing
>> fields. 
> 
> On a more general note I'd be inclined to just account
> for hugetlb pages in Rss and {Private,Shared}_Dirty
> and fix any tools that double count.

By the same argument I presume the existing THP "AnonHugePages" smaps field
is not accounted for in the {Private,Shared}_... fields?
I.E. AnonHugePages may also benefit from splitting to Private/Shared?

thanks,
PA!draig.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
