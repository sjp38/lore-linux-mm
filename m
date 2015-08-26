Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 330E26B0253
	for <linux-mm@kvack.org>; Wed, 26 Aug 2015 02:48:02 -0400 (EDT)
Received: by pabzx8 with SMTP id zx8so59991327pab.1
        for <linux-mm@kvack.org>; Tue, 25 Aug 2015 23:48:01 -0700 (PDT)
Received: from heian.cn.fujitsu.com ([59.151.112.132])
        by mx.google.com with ESMTP id iu3si36924441pbc.96.2015.08.25.23.47.59
        for <linux-mm@kvack.org>;
        Tue, 25 Aug 2015 23:48:01 -0700 (PDT)
Message-ID: <55DD609E.5050509@cn.fujitsu.com>
Date: Wed, 26 Aug 2015 14:45:50 +0800
From: Tang Chen <tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/1] memhp: Add hot-added memory ranges to memblock before
 allocate node_data for a node.
References: <1440349573-24260-1-git-send-email-tangchen@cn.fujitsu.com> <55DAE26E.1050302@huawei.com> <55DBC061.8040508@huawei.com>
In-Reply-To: <55DBC061.8040508@huawei.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: akpm@linux-foundation.org, isimatu.yasuaki@jp.fujitsu.com, n-horiguchi@ah.jp.nec.com, vbabka@suse.cz, mgorman@techsingularity.net, rientjes@google.com, kamezawa.hiroyu@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, yasu.isimatu@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jiang Liu <jiang.liu@linux.intel.com>


On 08/25/2015 09:09 AM, Xishi Qiu wrote:
> On 2015/8/24 17:22, Xishi Qiu wrote:
>
>> On 2015/8/24 1:06, Tang Chen wrote:
>>
>>> The commit below adds hot-added memory range to memblock, after
>>> creating pgdat for new node.
>>>
>>> commit f9126ab9241f66562debf69c2c9d8fee32ddcc53
>>> Author: Xishi Qiu <qiuxishi@huawei.com>
>>> Date:   Fri Aug 14 15:35:16 2015 -0700
>>>
>>>      memory-hotplug: fix wrong edge when hot add a new node
>>>
>>> But there is a problem:
>>>
>>> add_memory()
>>> |--> hotadd_new_pgdat()
>>>       |--> free_area_init_node()
>>>            |--> get_pfn_range_for_nid()
>>>                 |--> find start_pfn and end_pfn in memblock
>>> |--> ......
>>> |--> memblock_add_node(start, size, nid)    --------    Here, just too late.
>>>
>>> get_pfn_range_for_nid() will find that start_pfn and end_pfn are both 0.
>>> As a result, when adding memory, dmesg will give the following wrong message.
>>>
> Hi Tang,
>
> Another question, if we add cpu first, there will be print error too.
>
> cpu_up()
> 	try_online_node()
> 		hotadd_new_pgdat()
>
> So how about just skip the print if the size is empty or just print
> "node xx is empty now, will update when online memory"?

As Liu Jiang said, memory-less node is not supported on x86 now.
And he is working on it.

Please refer to https://lkml.org/lkml/2015/8/16/130.

About your question, now, node could only be onlined when it has some 
memory.
So the printed message is also about memory, and sis put in 
hotadd_new_pgdat() .
I think the author of the code didn't think about online a node when a 
CPU is up.

But now, memory-less will be supported. So, I think, as you said, the 
message should
be modified.

But how it will go, I think we should refer to Liu Jiang's patch, and 
make a decision.

Thanks.

>
> Thanks,
> Xishi Qiu
>
>>> [ 2007.577000] Initmem setup node 5 [mem 0x0000000000000000-0xffffffffffffffff]
>>> [ 2007.584000] On node 5 totalpages: 0
>>> [ 2007.585000] Built 5 zonelists in Node order, mobility grouping on.  Total pages: 32588823
>>> [ 2007.594000] Policy zone: Normal
>>> [ 2007.598000] init_memory_mapping: [mem 0x60000000000-0x607ffffffff]
>>>
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> .
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
