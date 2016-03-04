Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 1ACF36B0254
	for <linux-mm@kvack.org>; Fri,  4 Mar 2016 02:39:20 -0500 (EST)
Received: by mail-wm0-f52.google.com with SMTP id l68so18652342wml.1
        for <linux-mm@kvack.org>; Thu, 03 Mar 2016 23:39:20 -0800 (PST)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id y125si2539485wmy.113.2016.03.03.23.39.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 03 Mar 2016 23:39:18 -0800 (PST)
Subject: Re: Suspicious error for CMA stress test
References: <56D6F008.1050600@huawei.com> <56D79284.3030009@redhat.com>
 <CAAmzW4PUwoVF+F-BpOZUHhH6YHp_Z8VkiUjdBq85vK6AWVkyPg@mail.gmail.com>
 <56D832BD.5080305@huawei.com> <20160304020232.GA12036@js1304-P5Q-DELUXE>
 <20160304043232.GC12036@js1304-P5Q-DELUXE> <56D92595.60709@huawei.com>
 <20160304063807.GA13317@js1304-P5Q-DELUXE>
From: Hanjun Guo <guohanjun@huawei.com>
Message-ID: <56D93ABE.9070406@huawei.com>
Date: Fri, 4 Mar 2016 15:35:26 +0800
MIME-Version: 1.0
In-Reply-To: <20160304063807.GA13317@js1304-P5Q-DELUXE>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Laura Abbott <labbott@redhat.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, Laura Abbott <lauraa@codeaurora.org>, qiuxishi <qiuxishi@huawei.com>, Catalin Marinas <Catalin.Marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Arnd Bergmann <arnd@arndb.de>, "thunder.leizhen@huawei.com" <thunder.leizhen@huawei.com>, dingtinahong <dingtianhong@huawei.com>, chenjie6@huawei.com, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 2016/3/4 14:38, Joonsoo Kim wrote:
> On Fri, Mar 04, 2016 at 02:05:09PM +0800, Hanjun Guo wrote:
>> On 2016/3/4 12:32, Joonsoo Kim wrote:
>>> On Fri, Mar 04, 2016 at 11:02:33AM +0900, Joonsoo Kim wrote:
>>>> On Thu, Mar 03, 2016 at 08:49:01PM +0800, Hanjun Guo wrote:
>>>>> On 2016/3/3 15:42, Joonsoo Kim wrote:
>>>>>> 2016-03-03 10:25 GMT+09:00 Laura Abbott <labbott@redhat.com>:
>>>>>>> (cc -mm and Joonsoo Kim)
>>>>>>>
>>>>>>>
>>>>>>> On 03/02/2016 05:52 AM, Hanjun Guo wrote:
>>>>>>>> Hi,
>>>>>>>>
>>>>>>>> I came across a suspicious error for CMA stress test:
>>>>>>>>
>>>>>>>> Before the test, I got:
>>>>>>>> -bash-4.3# cat /proc/meminfo | grep Cma
>>>>>>>> CmaTotal:         204800 kB
>>>>>>>> CmaFree:          195044 kB
>>>>>>>>
>>>>>>>>
>>>>>>>> After running the test:
>>>>>>>> -bash-4.3# cat /proc/meminfo | grep Cma
>>>>>>>> CmaTotal:         204800 kB
>>>>>>>> CmaFree:         6602584 kB
>>>>>>>>
>>>>>>>> So the freed CMA memory is more than total..
>>>>>>>>
>>>>>>>> Also the the MemFree is more than mem total:
>>>>>>>>
>>>>>>>> -bash-4.3# cat /proc/meminfo
>>>>>>>> MemTotal:       16342016 kB
>>>>>>>> MemFree:        22367268 kB
>>>>>>>> MemAvailable:   22370528 kB
>>>>> [...]
>>>>>>> I played with this a bit and can see the same problem. The sanity
>>>>>>> check of CmaFree < CmaTotal generally triggers in
>>>>>>> __move_zone_freepage_state in unset_migratetype_isolate.
>>>>>>> This also seems to be present as far back as v4.0 which was the
>>>>>>> first version to have the updated accounting from Joonsoo.
>>>>>>> Were there known limitations with the new freepage accounting,
>>>>>>> Joonsoo?
>>>>>> I don't know. I also played with this and looks like there is
>>>>>> accounting problem, however, for my case, number of free page is slightly less
>>>>>> than total. I will take a look.
>>>>>>
>>>>>> Hanjun, could you tell me your malloc_size? I tested with 1 and it doesn't
>>>>>> look like your case.
>>>>> I tested with malloc_size with 2M, and it grows much bigger than 1M, also I
>>>>> did some other test:
>>>> Thanks! Now, I can re-generate erronous situation you mentioned.
>>>>
>>>>>  - run with single thread with 100000 times, everything is fine.
>>>>>
>>>>>  - I hack the cam_alloc() and free as below [1] to see if it's lock issue, with
>>>>>    the same test with 100 multi-thread, then I got:
>>>> [1] would not be sufficient to close this race.
>>>>
>>>> Try following things [A]. And, for more accurate test, I changed code a bit more
>>>> to prevent kernel page allocation from cma area [B]. This will prevent kernel
>>>> page allocation from cma area completely so we can focus cma_alloc/release race.
>>>>
>>>> Although, this is not correct fix, it could help that we can guess
>>>> where the problem is.
>>> More correct fix is something like below.
>>> Please test it.
>> Hmm, this is not working:
> Sad to hear that.
>
> Could you tell me your system's MAX_ORDER and pageblock_order?
>

MAX_ORDER is 11, pageblock_order is 9, thanks for your help!

Hanjun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
