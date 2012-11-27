Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id CE4FD6B0070
	for <linux-mm@kvack.org>; Tue, 27 Nov 2012 07:09:57 -0500 (EST)
Received: by mail-wi0-f175.google.com with SMTP id hm11so3468274wib.8
        for <linux-mm@kvack.org>; Tue, 27 Nov 2012 04:09:56 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <50B479FA.6010307@cn.fujitsu.com>
References: <1353667445-7593-1-git-send-email-tangchen@cn.fujitsu.com>
	<CAA_GA1d7CxHvmZELvD_DO6u5tu1WBqfmLiuEzeFo=xMzuW50Tg@mail.gmail.com>
	<50B479FA.6010307@cn.fujitsu.com>
Date: Tue, 27 Nov 2012 20:09:55 +0800
Message-ID: <CAA_GA1ezZJyqVL=Dp5U2zzNw6bkfMKJY_STkt3E7TXkUYcv+jQ@mail.gmail.com>
Subject: Re: [PATCH v2 0/5] Add movablecore_map boot option
From: Bob Liu <lliubbo@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: hpa@zytor.com, akpm@linux-foundation.org, rob@landley.net, isimatu.yasuaki@jp.fujitsu.com, laijs@cn.fujitsu.com, wency@cn.fujitsu.com, linfeng@cn.fujitsu.com, jiang.liu@huawei.com, yinghai@kernel.org, kosaki.motohiro@jp.fujitsu.com, minchan.kim@gmail.com, mgorman@suse.de, rientjes@google.com, rusty@rustcorp.com.au, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org, m.szyprowski@samsung.com

On Tue, Nov 27, 2012 at 4:29 PM, Tang Chen <tangchen@cn.fujitsu.com> wrote:
> On 11/27/2012 04:00 PM, Bob Liu wrote:
>>
>> Hi Tang,
>>
>> On Fri, Nov 23, 2012 at 6:44 PM, Tang Chen<tangchen@cn.fujitsu.com>
>> wrote:
>>>
>>> [What we are doing]
>>> This patchset provide a boot option for user to specify ZONE_MOVABLE
>>> memory
>>> map for each node in the system.
>>>
>>> movablecore_map=nn[KMG]@ss[KMG]
>>>
>>> This option make sure memory range from ss to ss+nn is movable memory.
>>>
>>>
>>> [Why we do this]
>>> If we hot remove a memroy, the memory cannot have kernel memory,
>>> because Linux cannot migrate kernel memory currently. Therefore,
>>> we have to guarantee that the hot removed memory has only movable
>>> memoroy.
>>>
>>> Linux has two boot options, kernelcore= and movablecore=, for
>>> creating movable memory. These boot options can specify the amount
>>> of memory use as kernel or movable memory. Using them, we can
>>> create ZONE_MOVABLE which has only movable memory.
>>>
>>> But it does not fulfill a requirement of memory hot remove, because
>>> even if we specify the boot options, movable memory is distributed
>>> in each node evenly. So when we want to hot remove memory which
>>> memory range is 0x80000000-0c0000000, we have no way to specify
>>> the memory as movable memory.
>>>
>>
>> Sorry, I'm still not get your idea.
>> Why you need a specify range that is movable?
>> Could you describe the requirement and situation a bit more?
>> Thank you.
>
>
> Hi Liu,
>
> This feature is used in memory hotplug.
>
> In order to implement a whole node hotplug, we need to make sure the
> node contains no kernel memory, because memory used by kernel could
> not be migrated. (Since the kernel memory is directly mapped,
> VA = PA + __PAGE_OFFSET. So the physical address could not be changed.)
>
> User could specify all the memory on a node to be movable, so that the
> node could be hot-removed.
>

Thank you for your explanation. It's reasonable.

But i think it's a bit duplicated with CMA, i'm not sure but maybe we
can combine it with CMA which already in mainline?

> Another approach is like the following:
> movable_node = 1,3-5,8
> This could set all the memory on the nodes to be movable. And the rest
> of memory works as usual. But movablecore_map is more flexible.
>
> Thanks. :)
>
>
>>
>>> So we proposed a new feature which specifies memory range to use as
>>> movable memory.
>>>
>>>
>>> [Ways to do this]
>>> There may be 2 ways to specify movable memory.
>>>   1. use firmware information
>>>   2. use boot option
>>>
>>> 1. use firmware information
>>>    According to ACPI spec 5.0, SRAT table has memory affinity structure
>>>    and the structure has Hot Pluggable Filed. See "5.2.16.2 Memory
>>>    Affinity Structure". If we use the information, we might be able to
>>>    specify movable memory by firmware. For example, if Hot Pluggable
>>>    Filed is enabled, Linux sets the memory as movable memory.
>>>
>>> 2. use boot option
>>>    This is our proposal. New boot option can specify memory range to use
>>>    as movable memory.
>>>
>>>
>>> [How we do this]
>>> We chose second way, because if we use first way, users cannot change
>>> memory range to use as movable memory easily. We think if we create
>>> movable memory, performance regression may occur by NUMA. In this case,
>>> user can turn off the feature easily if we prepare the boot option.
>>> And if we prepare the boot optino, the user can select which memory
>>> to use as movable memory easily.
>>>
>>>
>>> [How to use]
>>> Specify the following boot option:
>>> movablecore_map=nn[KMG]@ss[KMG]
>>>
>>> That means physical address range from ss to ss+nn will be allocated as
>>> ZONE_MOVABLE.
>>>
>>> And the following points should be considered.
>>>
>>> 1) If the range is involved in a single node, then from ss to the end of
>>>     the node will be ZONE_MOVABLE.
>>> 2) If the range covers two or more nodes, then from ss to the end of
>>>     the node will be ZONE_MOVABLE, and all the other nodes will only
>>>     have ZONE_MOVABLE.
>>> 3) If no range is in the node, then the node will have no ZONE_MOVABLE
>>>     unless kernelcore or movablecore is specified.
>>> 4) This option could be specified at most MAX_NUMNODES times.
>>> 5) If kernelcore or movablecore is also specified, movablecore_map will
>>> have
>>>     higher priority to be satisfied.
>>> 6) This option has no conflict with memmap option.
>>>
>>>
>>>
>>> Tang Chen (4):
>>>    page_alloc: add movable_memmap kernel parameter
>>>    page_alloc: Introduce zone_movable_limit[] to keep movable limit for
>>>      nodes
>>>    page_alloc: Make movablecore_map has higher priority
>>>    page_alloc: Bootmem limit with movablecore_map
>>>
>>> Yasuaki Ishimatsu (1):
>>>    x86: get pg_data_t's memory from other node
>>>
>>>   Documentation/kernel-parameters.txt |   17 +++
>>>   arch/x86/mm/numa.c                  |   11 ++-
>>>   include/linux/memblock.h            |    1 +
>>>   include/linux/mm.h                  |   11 ++
>>>   mm/memblock.c                       |   15 +++-
>>>   mm/page_alloc.c                     |  216
>>> ++++++++++++++++++++++++++++++++++-
>>>   6 files changed, 263 insertions(+), 8 deletions(-)
>>>
>>> --
>>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>>> the body to majordomo@kvack.org.  For more info on Linux MM,
>>> see: http://www.linux-mm.org/ .
>>> Don't email:<a href=mailto:"dont@kvack.org">  email@kvack.org</a>
>>
>>
>
-- 
Regards,
--Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
