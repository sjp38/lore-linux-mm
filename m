Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 204F76B0032
	for <linux-mm@kvack.org>; Mon, 20 Apr 2015 22:51:31 -0400 (EDT)
Received: by pdbqd1 with SMTP id qd1so227464653pdb.2
        for <linux-mm@kvack.org>; Mon, 20 Apr 2015 19:51:30 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTP id di10si748730pdb.34.2015.04.20.19.46.31
        for <linux-mm@kvack.org>;
        Mon, 20 Apr 2015 19:51:30 -0700 (PDT)
Message-ID: <5535A879.8050302@huawei.com>
Date: Tue, 21 Apr 2015 09:31:37 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2 V2] memory-hotplug: fix BUG_ON in move_freepages()
References: <5530E578.9070505@huawei.com> <5531679d.4642ec0a.1beb.3569@mx.google.com> <55345979.2020502@cn.fujitsu.com> <55346859.30605@huawei.com> <553472b0.4ad2ec0a.3abe.ffffd0f6@mx.google.com> <55347592.4050400@huawei.com> <55354434.2902ec0a.14ab.fffffff6@mx.google.com>
In-Reply-To: <55354434.2902ec0a.14ab.fffffff6@mx.google.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yasuaki Ishimatsu <yasu.isimatu@gmail.com>
Cc: Gu Zheng <guz.fnst@cn.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, izumi.taku@jp.fujitsu.com, Tang Chen <tangchen@cn.fujitsu.com>, Xiexiuqi <xiexiuqi@huawei.com>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 2015/4/21 2:23, Yasuaki Ishimatsu wrote:

> 
> On Mon, 20 Apr 2015 11:42:10 +0800
> Xishi Qiu <qiuxishi@huawei.com> wrote:
> 
>> On 2015/4/20 11:29, Yasuaki Ishimatsu wrote:
>>
>>>
>>> On Mon, 20 Apr 2015 10:45:45 +0800
>>> Xishi Qiu <qiuxishi@huawei.com> wrote:
>>>
>>>> On 2015/4/20 9:42, Gu Zheng wrote:
>>>>
>>>>> Hi Xishi,
>>>>> On 04/18/2015 04:05 AM, Yasuaki Ishimatsu wrote:
>>>>>
>>>>>>
>>>>>> Your patches will fix your issue.
>>>>>> But, if BIOS reports memory first at node hot add, pgdat can
>>>>>> not be initialized.
>>>>>>
>>>>>> Memory hot add flows are as follows:
>>>>>>
>>>>>> add_memory
>>>>>>   ...
>>>>>>   -> hotadd_new_pgdat()
>>>>>>   ...
>>>>>>   -> node_set_online(nid)
>>>>>>
>>>>>> When calling hotadd_new_pgdat() for a hot added node, the node is
>>>>>> offline because node_set_online() is not called yet. So if applying
>>>>>> your patches, the pgdat is not initialized in this case.
>>>>>
>>>>> Ishimtasu's worry is reasonable. And I am afraid the fix here is a bit
>>>>> over-kill. 
>>>>>
>>>>>>
>>>>>> Thanks,
>>>>>> Yasuaki Ishimatsu
>>>>>>
>>>>>> On Fri, 17 Apr 2015 18:50:32 +0800
>>>>>> Xishi Qiu <qiuxishi@huawei.com> wrote:
>>>>>>
>>>>>>> Hot remove nodeXX, then hot add nodeXX. If BIOS report cpu first, it will call
>>>>>>> hotadd_new_pgdat(nid, 0), this will set pgdat->node_start_pfn to 0. As nodeXX
>>>>>>> exists at boot time, so pgdat->node_spanned_pages is the same as original. Then
>>>>>>> free_area_init_core()->memmap_init() will pass a wrong start and a nonzero size.
>>>>>
>>>>> As your analysis said the root cause here is passing a *0* as the node_start_pfn,
>>>>> then the chaos occurred when init the zones. And this only happens to the re-hotadd
>>>>> node, so how about using the saved *node_start_pfn* (via get_pfn_range_for_nid(nid, &start_pfn, &end_pfn))
>>>>> instead if we find "pgdat->node_start_pfn == 0 && !node_online(XXX)"?
>>>>>
>>>>> Thanks,
>>>>> Gu
>>>>>
>>>>
>>>> Hi Gu,
>>>>
>>>> I first considered this method, but if the hot added node's start and size are different
>>>> from before, it makes the chaos.
>>>>
>>>
>>>> e.g.
>>>> nodeXX (8-16G)
>>>> remove nodeXX 
>>>> BIOS report cpu first and online it
>>>> hotadd nodeXX
>>>> use the original value, so pgdat->node_start_pfn is set to 8G, and size is 8G
>>>> BIOS report mem(10-12G)
>>>> call add_memory()->__add_zone()->grow_zone_span()/grow_pgdat_span()
>>>> the start is still 8G, not 10G, this is chaos!
>>>
>>> If you set CONFIG_HAVE_MEMBLOCK_NODE_MAP, kernel shows the following
>>> pr_info()'s message.
>>>
>>> void __paginginit free_area_init_node(int nid, unsigned long *zones_size,
>>>                 unsigned long node_start_pfn, unsigned long *zholes_size)
>>> {
>>> ...
>>> #ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
>>>         get_pfn_range_for_nid(nid, &start_pfn, &end_pfn);
>>>         pr_info("Initmem setup node %d [mem %#018Lx-%#018Lx]\n", nid,
>>>                 (u64)start_pfn << PAGE_SHIFT, ((u64)end_pfn << PAGE_SHIFT) - 1);
>>> #endif
>>> }
>>>
>>> Is the memory range of the message "8G - 16G"?
>>> If so, the reason is that memblk is not deleted at memory hot remove.
>>>
>>> Thanks,
>>> Yasuaki Ishimatsu
>>>
>>
>> Hi Yasuaki,
>>
> 
>> By reading the code, I find memblk is not deleted at memory hot remove.
>> I am not sure whether we should remove it. If remove it, we should also reset
>> "arch_zone_lowest_possible_pfn", right? It seems a little complicated.
> 
> I think memblk should be added/removed by hot adding/removing memory.
> But, arch_zone_lowest_possible_pfn should not be changed.
> 

Ok, thanks for your suggestion.

> Thanks,
> Yasuaki Ishimatsu
> 
>>
>> Thanks,
>> Xishi Qiu
>>
>>>
>>>
>>>>
>>>> Thanks,
>>>> Xishi Qiu
>>>>
>>>
>>> .
>>>
>>
>>
>>
> 
> .
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
