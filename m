Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id 3D4CD6B004D
	for <linux-mm@kvack.org>; Sun, 29 Jul 2012 21:58:37 -0400 (EDT)
Message-ID: <5015EB6F.40901@cn.fujitsu.com>
Date: Mon, 30 Jul 2012 10:03:27 +0800
From: Wen Congyang <wency@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH v5 19/19] memory-hotplug: remove sysfs file of node
References: <50126B83.3050201@cn.fujitsu.com> <50126F21.803@cn.fujitsu.com> <5012712E.9000005@jp.fujitsu.com>
In-Reply-To: <5012712E.9000005@jp.fujitsu.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com

At 07/27/2012 06:45 PM, Yasuaki Ishimatsu Wrote:
> Hi Wen,
> 
> 2012/07/27 19:36, Wen Congyang wrote:
>> From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
>>
>> The patch adds node_set_offline() and unregister_one_node() to
>> remove_memory()
>> for removing sysfs file of node.
>>
>> CC: David Rientjes <rientjes@google.com>
>> CC: Jiang Liu <liuj97@gmail.com>
>> CC: Len Brown <len.brown@intel.com>
>> CC: Benjamin Herrenschmidt <benh@kernel.crashing.org>
>> CC: Paul Mackerras <paulus@samba.org>
>> CC: Christoph Lameter <cl@linux.com>
>> Cc: Minchan Kim <minchan.kim@gmail.com>
>> CC: Andrew Morton <akpm@linux-foundation.org>
>> CC: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
>> CC: Wen Congyang <wency@cn.fujitsu.com>
>> Signed-off-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
>> ---
>>   mm/memory_hotplug.c |    5 +++++
>>   1 files changed, 5 insertions(+), 0 deletions(-)
>>
>> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
>> index 5ac035f..5681968 100644
>> --- a/mm/memory_hotplug.c
>> +++ b/mm/memory_hotplug.c
>> @@ -1267,6 +1267,11 @@ int __ref remove_memory(int nid, u64 start, u64
>> size)
>>       /* remove memmap entry */
>>       firmware_map_remove(start, start + size, "System RAM");
>>
>> +    if (!node_present_pages(nid)) {
> 
> Applying [PATCH v5 17/19], pgdat->node_spanned_pages can become 0 when
> all memory of the pgdat is removed. When pgdat->node_spanned_pages is 0,
> it means the pgdat has no memory. So I think node_spanned_pages() is
> better.

node_spanned_pages = present_pages + hole_pages

So present_pages is always less or equal than spanned_pages, and I think
checking present pages is better.

Thanks
Wen Congyang

> 
> Thanks,
> Yasuaki Ishimatsu
> 
>> +        node_set_offline(nid);
>> +        unregister_one_node(nid);
>> +    }
>> +
>>       arch_remove_memory(start, size);
>>   out:
>>       unlock_memory_hotplug();
>>
> 
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
