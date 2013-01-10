Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id 4D28F6B005D
	for <linux-mm@kvack.org>; Wed,  9 Jan 2013 21:00:12 -0500 (EST)
Message-ID: <50EE1B82.4090601@cn.fujitsu.com>
Date: Thu, 10 Jan 2013 09:38:10 +0800
From: Tang Chen <tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v5 01/14] memory-hotplug: try to offline the memory twice
 to avoid dependence
References: <1356350964-13437-1-git-send-email-tangchen@cn.fujitsu.com> <1356350964-13437-2-git-send-email-tangchen@cn.fujitsu.com> <50D96543.6010903@parallels.com> <50DFD7F7.5090408@cn.fujitsu.com> <50ED8834.1090804@parallels.com>
In-Reply-To: <50ED8834.1090804@parallels.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Wen Congyang <wency@cn.fujitsu.com>, akpm@linux-foundation.org, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, kosaki.motohiro@jp.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, wujianguo@huawei.com, hpa@zytor.com, linfeng@cn.fujitsu.com, laijs@cn.fujitsu.com, mgorman@suse.de, yinghai@kernel.org, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com, sparclinux@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Hi Glauber,

On 01/09/2013 11:09 PM, Glauber Costa wrote:
>>
>> We try to make all page_cgroup allocations local to the node they are describing
>> now. If the memory is the first memory onlined in this node, we will allocate
>> it from the other node.
>>
>> For example, node1 has 4 memory blocks: 8-11, and we online it from 8 to 11
>> 1. memory block 8, page_cgroup allocations are in the other nodes
>> 2. memory block 9, page_cgroup allocations are in memory block 8
>>
>> So we should offline memory block 9 first. But we don't know in which order
>> the user online the memory block.
>>
>> I think we can modify memcg like this:
>> allocate the memory from the memory block they are describing
>>
>> I am not sure it is OK to do so.
>
> I don't see a reason why not.

I'm not sure, but if we do this, we could bring in a fragment for each
memory block (a memory section, 128MB, right?). Is this a problem when
we use large page (such as 1GB page) ?

Even if not, will these fragments make any bad effects ?

Thank. :)

>
> You would have to tweak a bit the lookup function for page_cgroup, but
> assuming you will always have the pfns and limits, it should be easy to do.
>
> I think the only tricky part is that today we have a single
> node_page_cgroup, and we would of course have to have one per memory
> block. My assumption is that the number of memory blocks is limited and
> likely not very big. So even a static array would do.
>
> Kamezawa, do you have any input in here?
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
