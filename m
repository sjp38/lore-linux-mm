Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id 78E726B005A
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 01:06:45 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id DFE5B3EE0C0
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 14:06:40 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id C189345DE5C
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 14:06:40 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 581FA45DE53
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 14:06:40 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 4BC331DB803F
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 14:06:40 +0900 (JST)
Received: from g01jpexchyt01.g01.fujitsu.local (g01jpexchyt01.g01.fujitsu.local [10.128.194.40])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id E7BF01DB803E
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 14:06:39 +0900 (JST)
Message-ID: <4FEBE646.5090801@jp.fujitsu.com>
Date: Thu, 28 Jun 2012 14:06:14 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 2/12] memory-hogplug : check memory offline in offline_pages
References: <4FEA9C88.1070800@jp.fujitsu.com> <4FEA9DB1.7010303@jp.fujitsu.com> <4FEAC916.7030506@cn.fujitsu.com>
In-Reply-To: <4FEAC916.7030506@cn.fujitsu.com>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wen Congyang <wency@cn.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com

Hi Wen,

2012/06/27 17:49, Wen Congyang wrote:
> At 06/27/2012 01:44 PM, Yasuaki Ishimatsu Wrote:
>> When offline_pages() is called to offlined memory, the function fails since
>> all memory has been offlined. In this case, the function should succeed.
>> The patch adds the check function into offline_pages().
> 
> You miss such case: some pages are online, while some pages are offline.
> offline_pages() will fail too in such case.

You are right. But current code fails, when the function is called to offline
memory. In this case, the function should succeed. So the patch confirms
whether the memory was offlined or not. And if memory has already been
offlined, offline_pages return 0.

Thanks,
Yasuaki Ishimatsu

> 
> Thanks
> Wen Congyang
> 
>>
>> CC: Len Brown <len.brown@intel.com>
>> CC: Benjamin Herrenschmidt <benh@kernel.crashing.org>
>> CC: Paul Mackerras <paulus@samba.org>
>> CC: Christoph Lameter <cl@linux.com>
>> Cc: Minchan Kim <minchan.kim@gmail.com>
>> CC: Andrew Morton <akpm@linux-foundation.org>
>> CC: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
>> CC: Wen Congyang <wency@cn.fujitsu.com>
>> Signed-off-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
>>
>> ---
>>   drivers/base/memory.c  |   20 ++++++++++++++++++++
>>   include/linux/memory.h |    1 +
>>   mm/memory_hotplug.c    |    5 +++++
>>   3 files changed, 26 insertions(+)
>>
>> Index: linux-3.5-rc4/drivers/base/memory.c
>> ===================================================================
>> --- linux-3.5-rc4.orig/drivers/base/memory.c	2012-06-26 13:28:16.726211752 +0900
>> +++ linux-3.5-rc4/drivers/base/memory.c	2012-06-26 13:34:22.423639904 +0900
>> @@ -70,6 +70,26 @@ void unregister_memory_isolate_notifier(
>>   }
>>   EXPORT_SYMBOL(unregister_memory_isolate_notifier);
>>
>> +bool memory_is_offline(unsigned long start_pfn, unsigned long end_pfn)
>> +{
>> +	struct memory_block *mem;
>> +	struct mem_section *section;
>> +	unsigned long pfn, section_nr;
>> +
>> +	for (pfn = start_pfn; pfn < end_pfn; pfn += PAGES_PER_SECTION) {
>> +		section_nr = pfn_to_section_nr(pfn);
>> +		section = __nr_to_section(section_nr);
>> +		mem = find_memory_block(section);
>> +		if (!mem)
>> +			continue;
>> +		if (mem->state == MEM_OFFLINE)
>> +			continue;
>> +		return false;
>> +	}
>> +
>> +	return true;
>> +}
>> +
>>   /*
>>    * register_memory - Setup a sysfs device for a memory block
>>    */
>> Index: linux-3.5-rc4/include/linux/memory.h
>> ===================================================================
>> --- linux-3.5-rc4.orig/include/linux/memory.h	2012-06-25 04:53:04.000000000 +0900
>> +++ linux-3.5-rc4/include/linux/memory.h	2012-06-26 13:34:22.424639891 +0900
>> @@ -120,6 +120,7 @@ extern int memory_isolate_notify(unsigne
>>   extern struct memory_block *find_memory_block_hinted(struct mem_section *,
>>   							struct memory_block *);
>>   extern struct memory_block *find_memory_block(struct mem_section *);
>> +extern bool memory_is_offline(unsigned long start_pfn, unsigned long end_pfn);
>>   #define CONFIG_MEM_BLOCK_SIZE	(PAGES_PER_SECTION<<PAGE_SHIFT)
>>   enum mem_add_context { BOOT, HOTPLUG };
>>   #endif /* CONFIG_MEMORY_HOTPLUG_SPARSE */
>> Index: linux-3.5-rc4/mm/memory_hotplug.c
>> ===================================================================
>> --- linux-3.5-rc4.orig/mm/memory_hotplug.c	2012-06-26 13:28:16.743211538 +0900
>> +++ linux-3.5-rc4/mm/memory_hotplug.c	2012-06-26 13:48:38.264940468 +0900
>> @@ -887,6 +887,11 @@ static int __ref offline_pages(unsigned
>>
>>   	lock_memory_hotplug();
>>
>> +	if (memory_is_offline(start_pfn, end_pfn)) {
>> +		ret = 0;
>> +		goto out;
>> +	}
>> +
>>   	zone = page_zone(pfn_to_page(start_pfn));
>>   	node = zone_to_nid(zone);
>>   	nr_pages = end_pfn - start_pfn;
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> Please read the FAQ at  http://www.tux.org/lkml/
>>
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
