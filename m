Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7E2506B000E
	for <linux-mm@kvack.org>; Tue,  3 Jul 2018 13:01:00 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id b7-v6so1225570pgv.5
        for <linux-mm@kvack.org>; Tue, 03 Jul 2018 10:01:00 -0700 (PDT)
Received: from out4438.biz.mail.alibaba.com (out4438.biz.mail.alibaba.com. [47.88.44.38])
        by mx.google.com with ESMTPS id l11-v6si1332929pgq.174.2018.07.03.10.00.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Jul 2018 10:00:59 -0700 (PDT)
Subject: Re: [RFC v3 PATCH 4/5] mm: mmap: zap pages with read mmap_sem for
 large mapping
References: <1530311985-31251-1-git-send-email-yang.shi@linux.alibaba.com>
 <1530311985-31251-5-git-send-email-yang.shi@linux.alibaba.com>
 <20180702123350.dktmzlmztulmtrae@kshutemo-mobl1>
 <20180702124928.GQ19043@dhcp22.suse.cz>
 <20180703081205.3ue5722pb3ko4g2w@kshutemo-mobl1>
 <20180703082718.GF16767@dhcp22.suse.cz>
 <20180703091911.hhxhnqpeqb2kn42x@kshutemo-mobl1>
 <20180703113453.GJ16767@dhcp22.suse.cz>
 <20180703121450.6aytgmssmf26bgos@kshutemo-mobl1>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <1898efc7-3b03-5680-35ff-125049381d6b@linux.alibaba.com>
Date: Tue, 3 Jul 2018 10:00:23 -0700
MIME-Version: 1.0
In-Reply-To: <20180703121450.6aytgmssmf26bgos@kshutemo-mobl1>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>, Michal Hocko <mhocko@kernel.org>
Cc: willy@infradead.org, ldufour@linux.vnet.ibm.com, akpm@linux-foundation.org, peterz@infradead.org, mingo@redhat.com, acme@kernel.org, alexander.shishkin@linux.intel.com, jolsa@redhat.com, namhyung@kernel.org, tglx@linutronix.de, hpa@zytor.com, linux-mm@kvack.org, x86@kernel.org



On 7/3/18 5:14 AM, Kirill A. Shutemov wrote:
> On Tue, Jul 03, 2018 at 01:34:53PM +0200, Michal Hocko wrote:
>> On Tue 03-07-18 12:19:11, Kirill A. Shutemov wrote:
>>> On Tue, Jul 03, 2018 at 10:27:18AM +0200, Michal Hocko wrote:
>>>> On Tue 03-07-18 11:12:05, Kirill A. Shutemov wrote:
>>>>> On Mon, Jul 02, 2018 at 02:49:28PM +0200, Michal Hocko wrote:
>>>>>> On Mon 02-07-18 15:33:50, Kirill A. Shutemov wrote:
>>>>>> [...]
>>>>>>> I probably miss the explanation somewhere, but what's wrong with allowing
>>>>>>> other thread to re-populate the VMA?
>>>>>> We have discussed that earlier and it boils down to how is racy access
>>>>>> to munmap supposed to behave. Right now we have either the original
>>>>>> content or SEGV. If we allow to simply madvise_dontneed before real
>>>>>> unmap we could get a new page as well. There might be (quite broken I
>>>>>> would say) user space code that would simply corrupt data silently that
>>>>>> way.
>>>>> Okay, so we add a lot of complexity to accommodate broken userspace that
>>>>> may or may not exist. Is it right? :)
>>>> I would really love to do the most simple and obious thing
>>>>
>>>> diff --git a/mm/mmap.c b/mm/mmap.c
>>>> index 336bee8c4e25..86ffb179c3b5 100644
>>>> --- a/mm/mmap.c
>>>> +++ b/mm/mmap.c
>>>> @@ -2811,6 +2811,8 @@ EXPORT_SYMBOL(vm_munmap);
>>>>   SYSCALL_DEFINE2(munmap, unsigned long, addr, size_t, len)
>>>>   {
>>>>   	profile_munmap(addr);
>>>> +	if (len > LARGE_NUMBER)
>>>> +		do_madvise(addr, len, MADV_DONTNEED);
>>>>   	return vm_munmap(addr, len);
>>>>   }
>>>>   
>>>> but the argument that current semantic of good data or SEGV on
>>>> racing threads is no longer preserved sounds valid to me. Remember
>>>> optimizations shouldn't eat your data. How do we ensure that we won't
>>>> corrupt data silently?
>>> +linux-api
>>>
>>> Frankly, I don't see change in semantics here.
>>>
>>> Code that has race between munmap() and page fault would get intermittent
>>> SIGSEGV before and after the approach with simple MADV_DONTNEED.
>> prior to this patch you would either get an expected content (if you
>> win the race) or SEGV otherwise. With the above change you would get a
>> third state - a fresh new page (zero page) if you lost the race half
>> way. That sounds like a change of a long term semantic.
>>
>> How much that matters is of course a question. Userspace is known to do
>> the most unexpected things you never even dreamed of.
> I bet nobody would notice the difference.
>
> Let's go the simple way. The price to protect against *theoretical* broken
> userspace is too high.

That simple way has two major issues:

* The unexpected third state as Michal mentioned. VM_DEAD is a simple 
way to deal with it. It may not be able to kill all corner cases, but it 
should be a good simple approach to deal with the most wacky applications.

* Can't handle mlocked and hugetlb vmas mentioned by Andrew. 
MADV_DONTNEED just skips them.

Actually, I think your suggestion about just calling regular do_munmap() 
when getting the exclusive lock sounds reasonable. With this approach, 
we can solve the above caveats and make code simple enough (Of course 
not that simple as Michal expects :-)

Thanks,
Yang

>
