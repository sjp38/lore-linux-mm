Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id 957DE6B005A
	for <linux-mm@kvack.org>; Wed,  9 Jan 2013 10:09:45 -0500 (EST)
Message-ID: <50ED8834.1090804@parallels.com>
Date: Wed, 9 Jan 2013 19:09:40 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v5 01/14] memory-hotplug: try to offline the memory twice
 to avoid dependence
References: <1356350964-13437-1-git-send-email-tangchen@cn.fujitsu.com> <1356350964-13437-2-git-send-email-tangchen@cn.fujitsu.com> <50D96543.6010903@parallels.com> <50DFD7F7.5090408@cn.fujitsu.com>
In-Reply-To: <50DFD7F7.5090408@cn.fujitsu.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wen Congyang <wency@cn.fujitsu.com>
Cc: Tang Chen <tangchen@cn.fujitsu.com>, akpm@linux-foundation.org, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, kosaki.motohiro@jp.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, wujianguo@huawei.com, hpa@zytor.com, linfeng@cn.fujitsu.com, laijs@cn.fujitsu.com, mgorman@suse.de, yinghai@kernel.org, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com, sparclinux@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On 12/30/2012 09:58 AM, Wen Congyang wrote:
> At 12/25/2012 04:35 PM, Glauber Costa Wrote:
>> On 12/24/2012 04:09 PM, Tang Chen wrote:
>>> From: Wen Congyang <wency@cn.fujitsu.com>
>>>
>>> memory can't be offlined when CONFIG_MEMCG is selected.
>>> For example: there is a memory device on node 1. The address range
>>> is [1G, 1.5G). You will find 4 new directories memory8, memory9, memory10,
>>> and memory11 under the directory /sys/devices/system/memory/.
>>>
>>> If CONFIG_MEMCG is selected, we will allocate memory to store page cgroup
>>> when we online pages. When we online memory8, the memory stored page cgroup
>>> is not provided by this memory device. But when we online memory9, the memory
>>> stored page cgroup may be provided by memory8. So we can't offline memory8
>>> now. We should offline the memory in the reversed order.
>>>
>>> When the memory device is hotremoved, we will auto offline memory provided
>>> by this memory device. But we don't know which memory is onlined first, so
>>> offlining memory may fail. In such case, iterate twice to offline the memory.
>>> 1st iterate: offline every non primary memory block.
>>> 2nd iterate: offline primary (i.e. first added) memory block.
>>>
>>> This idea is suggested by KOSAKI Motohiro.
>>>
>>> Signed-off-by: Wen Congyang <wency@cn.fujitsu.com>
>>
>> Maybe there is something here that I am missing - I admit that I came
>> late to this one, but this really sounds like a very ugly hack, that
>> really has no place in here.
>>
>> Retrying, of course, may make sense, if we have reasonable belief that
>> we may now succeed. If this is the case, you need to document - in the
>> code - while is that.
>>
>> The memcg argument, however, doesn't really cut it. Why can't we make
>> all page_cgroup allocations local to the node they are describing? If
>> memcg is the culprit here, we should fix it, and not retry. If there is
>> still any benefit in retrying, then we retry being very specific about why.
> 
> We try to make all page_cgroup allocations local to the node they are describing
> now. If the memory is the first memory onlined in this node, we will allocate
> it from the other node.
> 
> For example, node1 has 4 memory blocks: 8-11, and we online it from 8 to 11
> 1. memory block 8, page_cgroup allocations are in the other nodes
> 2. memory block 9, page_cgroup allocations are in memory block 8
> 
> So we should offline memory block 9 first. But we don't know in which order
> the user online the memory block.
> 
> I think we can modify memcg like this:
> allocate the memory from the memory block they are describing
> 
> I am not sure it is OK to do so.

I don't see a reason why not.

You would have to tweak a bit the lookup function for page_cgroup, but
assuming you will always have the pfns and limits, it should be easy to do.

I think the only tricky part is that today we have a single
node_page_cgroup, and we would of course have to have one per memory
block. My assumption is that the number of memory blocks is limited and
likely not very big. So even a static array would do.

Kamezawa, do you have any input in here?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
