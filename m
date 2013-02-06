Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id 79B916B0005
	for <linux-mm@kvack.org>; Wed,  6 Feb 2013 05:11:23 -0500 (EST)
Message-ID: <51122C1D.5020002@cn.fujitsu.com>
Date: Wed, 06 Feb 2013 18:10:37 +0800
From: Tang Chen <tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v5 01/14] memory-hotplug: try to offline the memory twice
 to avoid dependence
References: <1356350964-13437-1-git-send-email-tangchen@cn.fujitsu.com> <1356350964-13437-2-git-send-email-tangchen@cn.fujitsu.com> <50D96543.6010903@parallels.com> <50DFD7F7.5090408@cn.fujitsu.com> <50ED8834.1090804@parallels.com> <5111C8EB.6090805@cn.fujitsu.com> <51121FB7.1070205@cn.fujitsu.com>
In-Reply-To: <51121FB7.1070205@cn.fujitsu.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Wen Congyang <wency@cn.fujitsu.com>, akpm@linux-foundation.org, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, kosaki.motohiro@jp.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, wujianguo@huawei.com, hpa@zytor.com, linfeng@cn.fujitsu.com, laijs@cn.fujitsu.com, mgorman@suse.de, yinghai@kernel.org, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com, sparclinux@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Miao Xie <miaox@cn.fujitsu.com>

On 02/06/2013 05:17 PM, Tang Chen wrote:
> Hi all,
>
> On 02/06/2013 11:07 AM, Tang Chen wrote:
>> Hi Glauber, all,
>>
>> An old thing I want to discuss with you. :)
>>
>> On 01/09/2013 11:09 PM, Glauber Costa wrote:
>>>>>> memory can't be offlined when CONFIG_MEMCG is selected.
>>>>>> For example: there is a memory device on node 1. The address range
>>>>>> is [1G, 1.5G). You will find 4 new directories memory8, memory9,
>>>>>> memory10,
>>>>>> and memory11 under the directory /sys/devices/system/memory/.
>>>>>>
>>>>>> If CONFIG_MEMCG is selected, we will allocate memory to store page
>>>>>> cgroup
>>>>>> when we online pages. When we online memory8, the memory stored
>>>>>> page cgroup
>>>>>> is not provided by this memory device. But when we online memory9,
>>>>>> the memory
>>>>>> stored page cgroup may be provided by memory8. So we can't offline
>>>>>> memory8
>>>>>> now. We should offline the memory in the reversed order.
>>>>>>
>>>>>> When the memory device is hotremoved, we will auto offline memory
>>>>>> provided
>>>>>> by this memory device. But we don't know which memory is onlined
>>>>>> first, so
>>>>>> offlining memory may fail. In such case, iterate twice to offline
>>>>>> the memory.
>>>>>> 1st iterate: offline every non primary memory block.
>>>>>> 2nd iterate: offline primary (i.e. first added) memory block.
>>>>>>
>>>>>> This idea is suggested by KOSAKI Motohiro.
>>>>>>
>>>>>> Signed-off-by: Wen Congyang<wency@cn.fujitsu.com>
>>>>>
>>>>> Maybe there is something here that I am missing - I admit that I came
>>>>> late to this one, but this really sounds like a very ugly hack, that
>>>>> really has no place in here.
>>>>>
>>>>> Retrying, of course, may make sense, if we have reasonable belief that
>>>>> we may now succeed. If this is the case, you need to document - in the
>>>>> code - while is that.
>>>>>
>>>>> The memcg argument, however, doesn't really cut it. Why can't we make
>>>>> all page_cgroup allocations local to the node they are describing? If
>>>>> memcg is the culprit here, we should fix it, and not retry. If
>>>>> there is
>>>>> still any benefit in retrying, then we retry being very specific
>>>>> about why.
>>>>
>>>> We try to make all page_cgroup allocations local to the node they are
>>>> describing
>>>> now. If the memory is the first memory onlined in this node, we will
>>>> allocate
>>>> it from the other node.
>>>>
>>>> For example, node1 has 4 memory blocks: 8-11, and we online it from 8
>>>> to 11
>>>> 1. memory block 8, page_cgroup allocations are in the other nodes
>>>> 2. memory block 9, page_cgroup allocations are in memory block 8
>>>>
>>>> So we should offline memory block 9 first. But we don't know in which
>>>> order
>>>> the user online the memory block.
>>>>
>>>> I think we can modify memcg like this:
>>>> allocate the memory from the memory block they are describing
>>>>
>>>> I am not sure it is OK to do so.
>>>
>>> I don't see a reason why not.
>>>
>>> You would have to tweak a bit the lookup function for page_cgroup, but
>>> assuming you will always have the pfns and limits, it should be easy
>>> to do.
>>>
>>> I think the only tricky part is that today we have a single
>>> node_page_cgroup, and we would of course have to have one per memory
>>> block. My assumption is that the number of memory blocks is limited and
>>> likely not very big. So even a static array would do.
>>>
>>
>> About the idea "allocate the memory from the memory block they are
>> describing",
>>
>> online_pages()
>> |-->memory_notify(MEM_GOING_ONLINE, &arg) ----------- memory of this
>> section is not in buddy yet.
>> |-->page_cgroup_callback()
>> |-->online_page_cgroup()
>> |-->init_section_page_cgroup()
>> |-->alloc_page_cgroup() --------- allocate page_cgroup from buddy system.
>>
>> When onlining pages, we allocate page_cgroup from buddy. And the being
>> onlined pages are not in
>> buddy yet. I think we can reserve some memory in the section for
>> page_cgroup, and return all the
>> rest to the buddy.
>>
>> But when the system is booting,
>>
>> start_kernel()
>> |-->setup_arch()
>> |-->mm_init()
>> | |-->mem_init()
>> | |-->numa_free_all_bootmem() -------------- all the pages are in buddy
>> system.
>> |-->page_cgroup_init()
>> |-->init_section_page_cgroup()
>> |-->alloc_page_cgroup() ------------------ I don't know how to reserve
>> memory in each section.
>>
>> So any idea about how to deal with it when the system is booting please?
>>
>
> How about this way.
>
> 1) Add a new flag PAGE_CGROUP_INFO, like SECTION_INFO and MIX_SECTION_INFO.
> 2) In sparse_init(), reserve some beginning pages of each section as
> bootmem.

Hi all,

After digging into bootmem code, I met another problem.

memblock allocates memory from high address to low address, using 
memblock.current_limit
to remember where the upper limit is. What I am doing will produce a lot 
of fragments,
and the memory will be non-contiguous. So we need to modify memblock again.

I don't think it's a good idea. How do you think ?

Thanks. :)

> 3) In register_page_bootmem_info_section(), set these pages as
> page->lru.next = PAGE_CGROUP_INFO;
>
> Then these pages will not go to buddy system.
>
> But I do worry about the fragment problem because part of each section will
> be used in the very beginning.
>
> Thanks. :)
>
>>
>> And one more question, a memory section is 128MB in Linux. If we reserve
>> part of the them for page_cgroup,
>> then anyone who wants to allocate a contiguous memory larger than 128MB,
>> it will fail, right ?
>> Is it OK ?
>>
>> Thanks. :)
>>
>>
>>
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-acpi" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at http://vger.kernel.org/majordomo-info.html
>>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-acpi" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at http://vger.kernel.org/majordomo-info.html
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
