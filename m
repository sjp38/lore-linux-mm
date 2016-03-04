Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f182.google.com (mail-ob0-f182.google.com [209.85.214.182])
	by kanga.kvack.org (Postfix) with ESMTP id EF6A16B0256
	for <linux-mm@kvack.org>; Fri,  4 Mar 2016 00:36:04 -0500 (EST)
Received: by mail-ob0-f182.google.com with SMTP id ts10so41521366obc.1
        for <linux-mm@kvack.org>; Thu, 03 Mar 2016 21:36:04 -0800 (PST)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id v131si1410973oig.87.2016.03.03.21.36.02
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 03 Mar 2016 21:36:04 -0800 (PST)
Subject: Re: Suspicious error for CMA stress test
References: <56D6F008.1050600@huawei.com> <56D79284.3030009@redhat.com>
 <CAAmzW4PUwoVF+F-BpOZUHhH6YHp_Z8VkiUjdBq85vK6AWVkyPg@mail.gmail.com>
 <56D832BD.5080305@huawei.com> <20160304020232.GA12036@js1304-P5Q-DELUXE>
From: Hanjun Guo <guohanjun@huawei.com>
Message-ID: <56D91E18.1020807@huawei.com>
Date: Fri, 4 Mar 2016 13:33:12 +0800
MIME-Version: 1.0
In-Reply-To: <20160304020232.GA12036@js1304-P5Q-DELUXE>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Laura Abbott <labbott@redhat.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, Laura Abbott <lauraa@codeaurora.org>, qiuxishi <qiuxishi@huawei.com>, Catalin Marinas <Catalin.Marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Arnd Bergmann <arnd@arndb.de>, "thunder.leizhen@huawei.com" <thunder.leizhen@huawei.com>, dingtinahong <dingtianhong@huawei.com>, chenjie6@huawei.com, "linux-mm@kvack.org" <linux-mm@kvack.org>

Hi Joonsoo,

On 2016/3/4 10:02, Joonsoo Kim wrote:
> On Thu, Mar 03, 2016 at 08:49:01PM +0800, Hanjun Guo wrote:
>> On 2016/3/3 15:42, Joonsoo Kim wrote:
>>> 2016-03-03 10:25 GMT+09:00 Laura Abbott <labbott@redhat.com>:
>>>> (cc -mm and Joonsoo Kim)
>>>>
>>>>
>>>> On 03/02/2016 05:52 AM, Hanjun Guo wrote:
>>>>> Hi,
>>>>>
>>>>> I came across a suspicious error for CMA stress test:
>>>>>
>>>>> Before the test, I got:
>>>>> -bash-4.3# cat /proc/meminfo | grep Cma
>>>>> CmaTotal:         204800 kB
>>>>> CmaFree:          195044 kB
>>>>>
>>>>>
>>>>> After running the test:
>>>>> -bash-4.3# cat /proc/meminfo | grep Cma
>>>>> CmaTotal:         204800 kB
>>>>> CmaFree:         6602584 kB
>>>>>
>>>>> So the freed CMA memory is more than total..
>>>>>
>>>>> Also the the MemFree is more than mem total:
>>>>>
>>>>> -bash-4.3# cat /proc/meminfo
>>>>> MemTotal:       16342016 kB
>>>>> MemFree:        22367268 kB
>>>>> MemAvailable:   22370528 kB
>> [...]
>>>> I played with this a bit and can see the same problem. The sanity
>>>> check of CmaFree < CmaTotal generally triggers in
>>>> __move_zone_freepage_state in unset_migratetype_isolate.
>>>> This also seems to be present as far back as v4.0 which was the
>>>> first version to have the updated accounting from Joonsoo.
>>>> Were there known limitations with the new freepage accounting,
>>>> Joonsoo?
>>> I don't know. I also played with this and looks like there is
>>> accounting problem, however, for my case, number of free page is slightly less
>>> than total. I will take a look.
>>>
>>> Hanjun, could you tell me your malloc_size? I tested with 1 and it doesn't
>>> look like your case.
>> I tested with malloc_size with 2M, and it grows much bigger than 1M, also I
>> did some other test:
> Thanks! Now, I can re-generate erronous situation you mentioned.
>
>>  - run with single thread with 100000 times, everything is fine.
>>
>>  - I hack the cam_alloc() and free as below [1] to see if it's lock issue, with
>>    the same test with 100 multi-thread, then I got:
> [1] would not be sufficient to close this race.
>
> Try following things [A]. And, for more accurate test, I changed code a bit more
> to prevent kernel page allocation from cma area [B]. This will prevent kernel
> page allocation from cma area completely so we can focus cma_alloc/release race.
>
> Although, this is not correct fix, it could help that we can guess
> where the problem is.
>
> Thanks.
>
> [A]

I tested this solution [A], it can fix the problem, as you are posting a new patch, I will
test that one and leave [B] alone :)

Thanks
Hanjun


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
