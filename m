Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 5AEA96B0253
	for <linux-mm@kvack.org>; Mon, 12 Oct 2015 02:05:12 -0400 (EDT)
Received: by pabve7 with SMTP id ve7so86895368pab.2
        for <linux-mm@kvack.org>; Sun, 11 Oct 2015 23:05:11 -0700 (PDT)
Received: from unicom145.biz-email.net (unicom145.biz-email.net. [210.51.26.145])
        by mx.google.com with ESMTPS id kh6si23436551pad.102.2015.10.11.23.05.08
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 11 Oct 2015 23:05:11 -0700 (PDT)
Subject: Re: [PATCH V6] mm: memory hot-add: memory can not be added to movable
 zone defaultly
References: <1444374737-26086-1-git-send-email-liuchangsheng@inspur.com>
 <561773EA.3090804@cn.fujitsu.com>
 <561803bc.92c38c0a.c7a5b.5820@mx.google.com>
 <561B109E.9060200@cn.fujitsu.com>
From: Changsheng Liu <liuchangsheng@inspur.com>
Message-ID: <561B4D86.3040408@inspur.com>
Date: Mon, 12 Oct 2015 14:04:54 +0800
MIME-Version: 1.0
In-Reply-To: <561B109E.9060200@cn.fujitsu.com>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>
Cc: akpm@linux-foundation.org, isimatu.yasuaki@jp.fujitsu.com, vbabka@suse.cz, linux-mm@kvack.org, linux-kernel@vger.kernel.org, wangnan0@huawei.com, dave.hansen@intel.com, yinghai@kernel.org, toshi.kani@hp.com, qiuxishi@huawei.com, wunan@inspur.com, yanxiaofeng@inspur.com, fandd@inspur.com, Changsheng Liu <liuchangcheng@inspur.com>



a?? 2015/10/12 9:45, Tang Chen a??e??:
> Hi Ishimatsu,
>
> On 10/10/2015 02:13 AM, Yasuaki Ishimatsu wrote:
>> Hi Tang,
>>
>> On Fri, 9 Oct 2015 15:59:38 +0800
>> Tang Chen <tangchen@cn.fujitsu.com> wrote:
>>
>>> Hi,
>>>
>>> I don't mean to offend, but I really think it is not necessary to do 
>>> this.
>>>
>>> hot-added memory will be added to ZONE_NORMAL by default. You can
>>> modify it when you online memory. I think it is enough for users.
>> But we cannot automatically create movable memory even if we use udev 
>> rules.
>> Thus user must create original scrip to online memory as movable.
>>
>> Do you think every user understand the rule that ZONE_NORMAL must be 
>> on the
>> left side of ZONE_MOVABLE?
>
> I think memory hotplug users should understand this.
>
>>
>> If we can change the behavir of kernel by sysctl, user can create
>> movable memory by only the following udev rule.
>>
>> SUBSYSTEM=="memory", ACTION=="add", ATTR{state}=="offline", 
>> ATTR{state}="online"
>
> OK, that is fine. And I think it is better to add this to the commit 
> message.
     Thanks, I will update the patch.
>
> Thanks.
>
>>
>> Thanks,
>> Yasuaki Ishimatsu
>>
>>> And a sysctl interface is also unnecessary. I think one default 
>>> behaviour
>>> is enough for kernel. We'd better keep it in the current way, or 
>>> change it
>>> and document it. It just makes no sense to enable users to modify it.
>>> Can you please share any use case of this sysctl interface ?
>>>
>>> I suggest just keep the current implement. But I'm OK with that if 
>>> other
>>> reviewers or users could clarify it is useful. :)
>>>
>>> And BTW, please don't cc the following reviewers. Their email addresses
>>> have changed.
>>>
>>> Cc: Zhang Yanfei<zhangyanfei@cn.fujitsu.com>
>>> Cc: Hu Tao<hutao@cn.fujitsu.com>
>>> Cc: Lai Jiangshan<laijs@cn.fujitsu.com>
>>> Cc: Gu Zheng<guz.fnst@cn.fujitsu.com>
>>>
>>>
>>> Thanks. :)
>>>
>>> On 10/09/2015 03:12 PM, Changsheng Liu wrote:
>>>> From: Changsheng Liu <liuchangcheng@inspur.com>
>>>>
>>>> After the user config CONFIG_MOVABLE_NODE,
>>>> When the memory is hot added, should_add_memory_movable() return 0
>>>> because all zones including movable zone are empty,
>>>> so the memory that was hot added will be added  to the normal zone
>>>> and the normal zone will be created firstly.
>>>> But we want the whole node to be added to movable zone defaultly.
>>>>
>>>> So we change should_add_memory_movable(): if the user config
>>>> CONFIG_MOVABLE_NODE and sysctl parameter hotadd_memory_as_movable and
>>>> the ZONE_NORMAL is empty or the pfn of the hot-added memory
>>>> is after the end of the ZONE_NORMAL it will always return 1
>>>> and all zones is empty at the same time,
>>>> so that the movable zone will be created firstly
>>>> and then the whole node will be added to movable zone defaultly.
>>>> If we want the node to be added to normal zone,
>>>> we can do it as follows:
>>>> "echo online_kernel > /sys/devices/system/memory/memoryXXX/state"
>>>>
>>>> Signed-off-by: Changsheng Liu <liuchangsheng@inspur.com>
>>>> Signed-off-by: Xiaofeng Yan <yanxiaofeng@inspur.com>
>>>> Tested-by: Dongdong Fan <fandd@inspur.com>
>>>> Cc: Wang Nan <wangnan0@huawei.com>
>>>> Cc: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
>>>> Cc: Dave Hansen <dave.hansen@intel.com>
>>>> Cc: Yinghai Lu <yinghai@kernel.org>
>>>> Cc: Tang Chen <tangchen@cn.fujitsu.com>
>>>> Cc: Hu Tao <hutao@cn.fujitsu.com>
>>>> Cc: Lai Jiangshan <laijs@cn.fujitsu.com>
>>>> Cc: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
>>>> Cc: Gu Zheng <guz.fnst@cn.fujitsu.com>
>>>> Cc: Toshi Kani <toshi.kani@hp.com>
>>>> Cc: Xishi Qiu <qiuxishi@huawei.com>
>>>> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
>>>> ---
>>>>    Documentation/memory-hotplug.txt |    5 ++++-
>>>>    kernel/sysctl.c                  |   15 +++++++++++++++
>>>>    mm/memory_hotplug.c              |   23 +++++++++++++++++++++++
>>>>    3 files changed, 42 insertions(+), 1 deletions(-)
>>>>
>>>> diff --git a/Documentation/memory-hotplug.txt 
>>>> b/Documentation/memory-hotplug.txt
>>>> index ce2cfcf..7e6b4f4 100644
>>>> --- a/Documentation/memory-hotplug.txt
>>>> +++ b/Documentation/memory-hotplug.txt
>>>> @@ -277,7 +277,7 @@ And if the memory block is in ZONE_MOVABLE, you 
>>>> can change it to ZONE_NORMAL:
>>>>    After this, memory block XXX's state will be 'online' and the 
>>>> amount of
>>>>    available memory will be increased.
>>>>    -Currently, newly added memory is added as ZONE_NORMAL (for 
>>>> powerpc, ZONE_DMA).
>>>> +Currently, newly added memory is added as ZONE_NORMAL or 
>>>> ZONE_MOVABLE (for powerpc, ZONE_DMA).
>>>>    This may be changed in future.
>>>>       @@ -319,6 +319,9 @@ creates ZONE_MOVABLE as following.
>>>>      Size of memory not for movable pages (not for offline) is 
>>>> TOTAL - ZZZZ.
>>>>      Size of memory for movable pages (for offline) is ZZZZ.
>>>>    +And a sysctl parameter for assigning the hot added memory to 
>>>> ZONE_MOVABLE is
>>>> +supported. If the value of "kernel/hotadd_memory_as_movable" is 
>>>> 1,the hot added
>>>> +memory will be assigned to ZONE_MOVABLE defautly.
>>>>       Note: Unfortunately, there is no information to show which 
>>>> memory block belongs
>>>>    to ZONE_MOVABLE. This is TBD.
>>>> diff --git a/kernel/sysctl.c b/kernel/sysctl.c
>>>> index 19b62b5..855c48e 100644
>>>> --- a/kernel/sysctl.c
>>>> +++ b/kernel/sysctl.c
>>>> @@ -166,6 +166,10 @@ extern int unaligned_dump_stack;
>>>>    extern int no_unaligned_warning;
>>>>    #endif
>>>>    +#ifdef CONFIG_MOVABLE_NODE
>>>> +extern int hotadd_memory_as_movable;
>>>> +#endif
>>>> +
>>>>    #ifdef CONFIG_PROC_SYSCTL
>>>>       #define SYSCTL_WRITES_LEGACY    -1
>>>> @@ -1139,6 +1143,17 @@ static struct ctl_table kern_table[] = {
>>>>            .proc_handler    = timer_migration_handler,
>>>>        },
>>>>    #endif
>>>> +/*If the value of "kernel/hotadd_memory_as_movable" is 1,the hot 
>>>> added
>>>> + * memory will be assigned to ZONE_MOVABLE defautly.*/
>>>> +#ifdef CONFIG_MOVABLE_NODE
>>>> +    {
>>>> +        .procname    = "hotadd_memory_as_movable",
>>>> +        .data        = &hotadd_memory_as_movable,
>>>> +        .maxlen        = sizeof(int),
>>>> +        .mode        = 0644,
>>>> +        .proc_handler    = proc_dointvec,
>>>> +    },
>>>> +#endif
>>>>        { }
>>>>    };
>>>>    diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
>>>> index 26fbba7..5bcaf74 100644
>>>> --- a/mm/memory_hotplug.c
>>>> +++ b/mm/memory_hotplug.c
>>>> @@ -37,6 +37,10 @@
>>>>       #include "internal.h"
>>>>    +/*If the global variable value is 1,
>>>> + * the hot added memory will be assigned to ZONE_MOVABLE defautly*/
>>>> +int hotadd_memory_as_movable;
>>>> +
>>>>    /*
>>>>     * online_page_callback contains pointer to current page 
>>>> onlining function.
>>>>     * Initially it is generic_online_page(). If it is required it 
>>>> could be
>>>> @@ -1190,6 +1194,9 @@ static int check_hotplug_memory_range(u64 
>>>> start, u64 size)
>>>>    /*
>>>>     * If movable zone has already been setup, newly added memory 
>>>> should be check.
>>>>     * If its address is higher than movable zone, it should be 
>>>> added as movable.
>>>> + * And if system config CONFIG_MOVABLE_NODE and set the sysctl 
>>>> parameter
>>>> + * "hotadd_memory_as_movable" and added memory does not overlap 
>>>> the zone
>>>> + * before MOVABLE_ZONE,the memory is added as movable.
>>>>     * Without this check, movable zone may overlap with other zone.
>>>>     */
>>>>    static int should_add_memory_movable(int nid, u64 start, u64 size)
>>>> @@ -1197,6 +1204,22 @@ static int should_add_memory_movable(int 
>>>> nid, u64 start, u64 size)
>>>>        unsigned long start_pfn = start >> PAGE_SHIFT;
>>>>        pg_data_t *pgdat = NODE_DATA(nid);
>>>>        struct zone *movable_zone = pgdat->node_zones + ZONE_MOVABLE;
>>>> +    struct zone *pre_zone = pgdat->node_zones + (ZONE_MOVABLE - 1);
>>>> +    /*
>>>> +     * The system configs CONFIG_MOVABLE_NODE to assign a node
>>>> +     * which has only movable memory,so the hot-added memory should
>>>> +     * be assigned to ZONE_MOVABLE defaultly,
>>>> +     * but the function zone_for_memory() assign the hot-added memory
>>>> +     * to ZONE_NORMAL(x86_64) defaultly.Kernel does not allow to
>>>> +     * create ZONE_MOVABLE before ZONE_NORMAL,so If the value of
>>>> +     * sysctl parameter "hotadd_memory_as_movable" is 1
>>>> +     * and the ZONE_NORMAL is empty or the pfn of the hot-added 
>>>> memory
>>>> +     * is after the end of the ZONE_NORMAL
>>>> +     * the hot-added memory will be assigned to ZONE_MOVABLE.
>>>> +     */
>>>> +    if (hotadd_memory_as_movable
>>>> +    && (zone_is_empty(pre_zone) || zone_end_pfn(pre_zone) <= 
>>>> start_pfn))
>>>> +        return 1;
>>>>           if (zone_is_empty(movable_zone))
>>>>            return 0;
>>> -- 
>>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>>> the body to majordomo@kvack.org.  For more info on Linux MM,
>>> see: http://www.linux-mm.org/ .
>>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>> .
>>
>
> .
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
