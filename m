Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f51.google.com (mail-oi0-f51.google.com [209.85.218.51])
	by kanga.kvack.org (Postfix) with ESMTP id 8FF816B0253
	for <linux-mm@kvack.org>; Fri, 11 Mar 2016 10:00:33 -0500 (EST)
Received: by mail-oi0-f51.google.com with SMTP id c203so87387706oia.2
        for <linux-mm@kvack.org>; Fri, 11 Mar 2016 07:00:33 -0800 (PST)
Received: from mail-oi0-x22a.google.com (mail-oi0-x22a.google.com. [2607:f8b0:4003:c06::22a])
        by mx.google.com with ESMTPS id y206si6930387oif.70.2016.03.11.07.00.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Mar 2016 07:00:30 -0800 (PST)
Received: by mail-oi0-x22a.google.com with SMTP id d205so87497717oia.0
        for <linux-mm@kvack.org>; Fri, 11 Mar 2016 07:00:30 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <56DF7B28.9060108@huawei.com>
References: <56D6F008.1050600@huawei.com>
	<56D79284.3030009@redhat.com>
	<CAAmzW4PUwoVF+F-BpOZUHhH6YHp_Z8VkiUjdBq85vK6AWVkyPg@mail.gmail.com>
	<56D832BD.5080305@huawei.com>
	<20160304020232.GA12036@js1304-P5Q-DELUXE>
	<20160304043232.GC12036@js1304-P5Q-DELUXE>
	<56D92595.60709@huawei.com>
	<20160304063807.GA13317@js1304-P5Q-DELUXE>
	<56D93ABE.9070406@huawei.com>
	<20160307043442.GB24602@js1304-P5Q-DELUXE>
	<56DD38E7.3050107@huawei.com>
	<56DDCB86.4030709@redhat.com>
	<56DE30CB.7020207@huawei.com>
	<56DF7B28.9060108@huawei.com>
Date: Sat, 12 Mar 2016 00:00:29 +0900
Message-ID: <CAAmzW4NDJwgq_P33Ru_X0MKXGQEnY5dr_SY1GFutPAqEUAc_rg@mail.gmail.com>
Subject: Re: Suspicious error for CMA stress test
From: Joonsoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Leizhen (ThunderTown)" <thunder.leizhen@huawei.com>
Cc: Laura Abbott <labbott@redhat.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Hanjun Guo <guohanjun@huawei.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, Laura Abbott <lauraa@codeaurora.org>, qiuxishi <qiuxishi@huawei.com>, Catalin Marinas <Catalin.Marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Arnd Bergmann <arnd@arndb.de>, dingtinahong <dingtianhong@huawei.com>, chenjie6@huawei.com, "linux-mm@kvack.org" <linux-mm@kvack.org>

2016-03-09 10:23 GMT+09:00 Leizhen (ThunderTown) <thunder.leizhen@huawei.com>:
>
>
> On 2016/3/8 9:54, Leizhen (ThunderTown) wrote:
>>
>>
>> On 2016/3/8 2:42, Laura Abbott wrote:
>>> On 03/07/2016 12:16 AM, Leizhen (ThunderTown) wrote:
>>>>
>>>>
>>>> On 2016/3/7 12:34, Joonsoo Kim wrote:
>>>>> On Fri, Mar 04, 2016 at 03:35:26PM +0800, Hanjun Guo wrote:
>>>>>> On 2016/3/4 14:38, Joonsoo Kim wrote:
>>>>>>> On Fri, Mar 04, 2016 at 02:05:09PM +0800, Hanjun Guo wrote:
>>>>>>>> On 2016/3/4 12:32, Joonsoo Kim wrote:
>>>>>>>>> On Fri, Mar 04, 2016 at 11:02:33AM +0900, Joonsoo Kim wrote:
>>>>>>>>>> On Thu, Mar 03, 2016 at 08:49:01PM +0800, Hanjun Guo wrote:
>>>>>>>>>>> On 2016/3/3 15:42, Joonsoo Kim wrote:
>>>>>>>>>>>> 2016-03-03 10:25 GMT+09:00 Laura Abbott <labbott@redhat.com>:
>>>>>>>>>>>>> (cc -mm and Joonsoo Kim)
>>>>>>>>>>>>>
>>>>>>>>>>>>>
>>>>>>>>>>>>> On 03/02/2016 05:52 AM, Hanjun Guo wrote:
>>>>>>>>>>>>>> Hi,
>>>>>>>>>>>>>>
>>>>>>>>>>>>>> I came across a suspicious error for CMA stress test:
>>>>>>>>>>>>>>
>>>>>>>>>>>>>> Before the test, I got:
>>>>>>>>>>>>>> -bash-4.3# cat /proc/meminfo | grep Cma
>>>>>>>>>>>>>> CmaTotal:         204800 kB
>>>>>>>>>>>>>> CmaFree:          195044 kB
>>>>>>>>>>>>>>
>>>>>>>>>>>>>>
>>>>>>>>>>>>>> After running the test:
>>>>>>>>>>>>>> -bash-4.3# cat /proc/meminfo | grep Cma
>>>>>>>>>>>>>> CmaTotal:         204800 kB
>>>>>>>>>>>>>> CmaFree:         6602584 kB
>>>>>>>>>>>>>>
>>>>>>>>>>>>>> So the freed CMA memory is more than total..
>>>>>>>>>>>>>>
>>>>>>>>>>>>>> Also the the MemFree is more than mem total:
>>>>>>>>>>>>>>
>>>>>>>>>>>>>> -bash-4.3# cat /proc/meminfo
>>>>>>>>>>>>>> MemTotal:       16342016 kB
>>>>>>>>>>>>>> MemFree:        22367268 kB
>>>>>>>>>>>>>> MemAvailable:   22370528 kB
>>>>>>>>>>> [...]
>>>>>>>>>>>>> I played with this a bit and can see the same problem. The sanity
>>>>>>>>>>>>> check of CmaFree < CmaTotal generally triggers in
>>>>>>>>>>>>> __move_zone_freepage_state in unset_migratetype_isolate.
>>>>>>>>>>>>> This also seems to be present as far back as v4.0 which was the
>>>>>>>>>>>>> first version to have the updated accounting from Joonsoo.
>>>>>>>>>>>>> Were there known limitations with the new freepage accounting,
>>>>>>>>>>>>> Joonsoo?
>>>>>>>>>>>> I don't know. I also played with this and looks like there is
>>>>>>>>>>>> accounting problem, however, for my case, number of free page is slightly less
>>>>>>>>>>>> than total. I will take a look.
>>>>>>>>>>>>
>>>>>>>>>>>> Hanjun, could you tell me your malloc_size? I tested with 1 and it doesn't
>>>>>>>>>>>> look like your case.
>>>>>>>>>>> I tested with malloc_size with 2M, and it grows much bigger than 1M, also I
>>>>>>>>>>> did some other test:
>>>>>>>>>> Thanks! Now, I can re-generate erronous situation you mentioned.
>>>>>>>>>>
>>>>>>>>>>>   - run with single thread with 100000 times, everything is fine.
>>>>>>>>>>>
>>>>>>>>>>>   - I hack the cam_alloc() and free as below [1] to see if it's lock issue, with
>>>>>>>>>>>     the same test with 100 multi-thread, then I got:
>>>>>>>>>> [1] would not be sufficient to close this race.
>>>>>>>>>>
>>>>>>>>>> Try following things [A]. And, for more accurate test, I changed code a bit more
>>>>>>>>>> to prevent kernel page allocation from cma area [B]. This will prevent kernel
>>>>>>>>>> page allocation from cma area completely so we can focus cma_alloc/release race.
>>>>>>>>>>
>>>>>>>>>> Although, this is not correct fix, it could help that we can guess
>>>>>>>>>> where the problem is.
>>>>>>>>> More correct fix is something like below.
>>>>>>>>> Please test it.
>>>>>>>> Hmm, this is not working:
>>>>>>> Sad to hear that.
>>>>>>>
>>>>>>> Could you tell me your system's MAX_ORDER and pageblock_order?
>>>>>>>
>>>>>>
>>>>>> MAX_ORDER is 11, pageblock_order is 9, thanks for your help!
>>>>>
>>>>> Hmm... that's same with me.
>>>>>
>>>>> Below is similar fix that prevents buddy merging when one of buddy's
>>>>> migrate type, but, not both, is MIGRATE_ISOLATE. In fact, I have
>>>>> no idea why previous fix (more correct fix) doesn't work for you.
>>>>> (It works for me.) But, maybe there is a bug on the fix
>>>>> so I make new one which is more general form. Please test it.
>>>>
>>>> Hi,
>>>>     Hanjun Guo has gone to Tailand on business, so I help him to run this patch. The result
>>>> shows that the count of "CmaFree:" is OK now. But sometimes printed some information as below:
>>>>
>>>> alloc_contig_range: [28500, 28600) PFNs busy
>>>> alloc_contig_range: [28300, 28380) PFNs busy
>>>>
>>>
>>> Those messages aren't necessarily a problem. Those messages indicate that
>> OK.
>>
>>> those pages weren't able to be isolated. Given the test here is a
>>> concurrency test, I suspect some concurrent allocation or free prevented
>>> isolation which is to be expected some times. I'd only be concerned if
>>> seeing those messages cause allocation failure or some other notable impact.
>> I chose memory block size: 512K, 1M, 2M ran serveral times, there was no memory allocation failure.
>
> Hi, Joonsoo:
>         This new patch worked well. Do you plan to upstream it in the near furture?

Of course!
But, I should think more because it touches allocator's fastpatch and
I'd like to detour.
If I fail to think a better solution, I will send it as is, soon.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
