Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f48.google.com (mail-wg0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 38A766B0036
	for <linux-mm@kvack.org>; Sun, 17 Aug 2014 23:22:52 -0400 (EDT)
Received: by mail-wg0-f48.google.com with SMTP id x13so4358901wgg.19
        for <linux-mm@kvack.org>; Sun, 17 Aug 2014 20:22:51 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id v1si14701883wiw.43.2014.08.17.20.22.43
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sun, 17 Aug 2014 20:22:50 -0700 (PDT)
Message-ID: <53F17068.5000005@huawei.com>
Date: Mon, 18 Aug 2014 11:18:00 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mem-hotplug: let memblock skip the hotpluggable memory
 regions in __next_mem_range()
References: <53E8C5AA.5040506@huawei.com> <20140816130456.GH9305@htj.dyndns.org> <53EF6C79.3000603@huawei.com> <20140817110821.GM9305@htj.dyndns.org> <53F15330.5070606@cn.fujitsu.com>
In-Reply-To: <53F15330.5070606@cn.fujitsu.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tangchen <tangchen@cn.fujitsu.com>
Cc: Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Wen Congyang <wency@cn.fujitsu.com>, "H. Peter Anvin" <hpa@zytor.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 2014/8/18 9:13, tangchen wrote:

> Hi tj,
> 
> On 08/17/2014 07:08 PM, Tejun Heo wrote:
>> Hello,
>>
>> On Sat, Aug 16, 2014 at 10:36:41PM +0800, Xishi Qiu wrote:
>>> numa_clear_node_hotplug()? There is only numa_clear_kernel_node_hotplug().
>> Yeah, that one.
>>
>>> If we don't clear hotpluggable flag in free_low_memory_core_early(), the
>>> memory which marked hotpluggable flag will not free to buddy allocator.
>>> Because __next_mem_range() will skip them.
>>>
>>> free_low_memory_core_early
>>>     for_each_free_mem_range
>>>         for_each_mem_range
>>>             __next_mem_range       
>> Ah, okay, so the patch fixes __next_mem_range() and thus makes
>> free_low_memory_core_early() to skip hotpluggable regions unlike
>> before.  Please explain things like that in the changelog.  Also,
>> what's its relationship with numa_clear_kernel_node_hotplug()?  Do we
>> still need them?  If so, what are the different roles that these two
>> separate places serve?
> 
> numa_clear_kernel_node_hotplug() only clears hotplug flags for the nodes
> the kernel resides in, not for hotpluggable nodes. The reason why we did
> this is to enable the kernel to allocate memory in case all the nodes are
> hotpluggable.
> 

Hi TangChen,

I find a problem in numa_init() (arch/x86/mm/numa.c)
numa_init()
	...
	ret = init_func();  // this will mark hotpluggable flag from SRAT
	...
	memblock_set_bottom_up(false);
	...
	ret = numa_register_memblks(&numa_meminfo);  // this will alloc node data(pglist_data) 
	...
	numa_clear_kernel_node_hotplug();  // in case all the nodes are hotpluggable
	...

If all the nodes are marked hotpluggable flag, alloc node data will fail.
Because __next_mem_range_rev() will skip the hotpluggable memory regions.
numa_register_memblks()
	setup_node_data()
		memblock_find_in_range_node()
			__memblock_find_range_top_down()
				for_each_mem_range_rev()
					__next_mem_range_rev()

What do you think?
How about move numa_clear_kernel_node_hotplug() into numa_register_memblks(),
like this:

numa_register_memblks()

...
                memblock_set_node(mb->start, mb->end - mb->start,
                                  &memblock.reserved, mb->nid);
        }

+        numa_clear_kernel_node_hotplug();

        /*
         * If sections array is gonna be used for pfn -> nid mapping, check
...

Thanks,
Xishi Qiu

> And we clear hotplug flags for all the nodes in free_low_memory_core_early()
> is because if we do not, all hotpluggable memory won't be able to be freed
> to buddy after Qiu's patch.
> 
> Thanks.
> 
> 
> .
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
