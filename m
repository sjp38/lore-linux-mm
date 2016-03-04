Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id A28676B007E
	for <linux-mm@kvack.org>; Fri,  4 Mar 2016 01:12:11 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id fi3so27123098pac.3
        for <linux-mm@kvack.org>; Thu, 03 Mar 2016 22:12:11 -0800 (PST)
Received: from szxga03-in.huawei.com ([119.145.14.66])
        by mx.google.com with ESMTPS id 2si3524126pfa.79.2016.03.03.22.12.08
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 03 Mar 2016 22:12:10 -0800 (PST)
Subject: Re: Suspicious error for CMA stress test
References: <56D6F008.1050600@huawei.com> <56D79284.3030009@redhat.com>
 <CAAmzW4PUwoVF+F-BpOZUHhH6YHp_Z8VkiUjdBq85vK6AWVkyPg@mail.gmail.com>
 <56D832BD.5080305@huawei.com> <56D887E1.8000602@redhat.com>
 <20160304020932.GB12036@js1304-P5Q-DELUXE>
From: Hanjun Guo <guohanjun@huawei.com>
Message-ID: <56D92695.2040409@huawei.com>
Date: Fri, 4 Mar 2016 14:09:25 +0800
MIME-Version: 1.0
In-Reply-To: <20160304020932.GB12036@js1304-P5Q-DELUXE>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Laura Abbott <labbott@redhat.com>
Cc: "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, Laura Abbott <lauraa@codeaurora.org>, qiuxishi <qiuxishi@huawei.com>, Catalin Marinas <Catalin.Marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Arnd Bergmann <arnd@arndb.de>, "thunder.leizhen@huawei.com" <thunder.leizhen@huawei.com>, dingtinahong <dingtianhong@huawei.com>, chenjie6@huawei.com, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 2016/3/4 10:09, Joonsoo Kim wrote:
> On Thu, Mar 03, 2016 at 10:52:17AM -0800, Laura Abbott wrote:
>> On 03/03/2016 04:49 AM, Hanjun Guo wrote:
>>> On 2016/3/3 15:42, Joonsoo Kim wrote:
>>>> 2016-03-03 10:25 GMT+09:00 Laura Abbott <labbott@redhat.com>:
>>>>> (cc -mm and Joonsoo Kim)
>>>>>
>>>>>
>>>>> On 03/02/2016 05:52 AM, Hanjun Guo wrote:
>>>>>> Hi,
>>>>>>
>>>>>> I came across a suspicious error for CMA stress test:
>>>>>>
>>>>>> Before the test, I got:
>>>>>> -bash-4.3# cat /proc/meminfo | grep Cma
>>>>>> CmaTotal:         204800 kB
>>>>>> CmaFree:          195044 kB
>>>>>>
>>>>>>
>>>>>> After running the test:
>>>>>> -bash-4.3# cat /proc/meminfo | grep Cma
>>>>>> CmaTotal:         204800 kB
>>>>>> CmaFree:         6602584 kB
>>>>>>
>>>>>> So the freed CMA memory is more than total..
>>>>>>
>>>>>> Also the the MemFree is more than mem total:
>>>>>>
>>>>>> -bash-4.3# cat /proc/meminfo
>>>>>> MemTotal:       16342016 kB
>>>>>> MemFree:        22367268 kB
>>>>>> MemAvailable:   22370528 kB
>>> [...]
>>>>> I played with this a bit and can see the same problem. The sanity
>>>>> check of CmaFree < CmaTotal generally triggers in
>>>>> __move_zone_freepage_state in unset_migratetype_isolate.
>>>>> This also seems to be present as far back as v4.0 which was the
>>>>> first version to have the updated accounting from Joonsoo.
>>>>> Were there known limitations with the new freepage accounting,
>>>>> Joonsoo?
>>>> I don't know. I also played with this and looks like there is
>>>> accounting problem, however, for my case, number of free page is slightly less
>>>> than total. I will take a look.
>>>>
>>>> Hanjun, could you tell me your malloc_size? I tested with 1 and it doesn't
>>>> look like your case.
>>> I tested with malloc_size with 2M, and it grows much bigger than 1M, also I
>>> did some other test:
>>>
>>>  - run with single thread with 100000 times, everything is fine.
>>>
>>>  - I hack the cam_alloc() and free as below [1] to see if it's lock issue, with
>>>    the same test with 100 multi-thread, then I got:
>>>
>>> -bash-4.3# cat /proc/meminfo | grep Cma
>>> CmaTotal: 204800 kB
>>> CmaFree: 225112 kB
>>>
>>> It only increased about 30M for free, not 6G+ in previous test, although
>>> the problem is not solved, the problem is less serious, is it a synchronization
>>> problem?
>>>
>> 'only' 30M is still an issue although I think you are right about something related
>> to synchronization. When I put the cma_mutex around free_contig_range I don't see
> Hmm... I can see the issue even if putting the cma_mutex around
> free_contig_range().

Yes, I can confirm that too, it can reduce the number of erronous freed memory, but
the problem is still there.

Thanks
Hanjun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
