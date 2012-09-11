Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id B61906B0068
	for <linux-mm@kvack.org>; Mon, 10 Sep 2012 22:25:51 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 4BACD3EE0BC
	for <linux-mm@kvack.org>; Tue, 11 Sep 2012 11:25:48 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 3605045DD78
	for <linux-mm@kvack.org>; Tue, 11 Sep 2012 11:25:48 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 0134B45DE4D
	for <linux-mm@kvack.org>; Tue, 11 Sep 2012 11:25:48 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id E75881DB803A
	for <linux-mm@kvack.org>; Tue, 11 Sep 2012 11:25:47 +0900 (JST)
Received: from g01jpexchyt28.g01.fujitsu.local (g01jpexchyt28.g01.fujitsu.local [10.128.193.111])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 993171DB803E
	for <linux-mm@kvack.org>; Tue, 11 Sep 2012 11:25:47 +0900 (JST)
Message-ID: <504EA0F7.5090805@jp.fujitsu.com>
Date: Tue, 11 Sep 2012 11:24:55 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RFC v9 PATCH 05/21] memory-hotplug: check whether memory is
 present or not
References: <1346837155-534-1-git-send-email-wency@cn.fujitsu.com> <1346837155-534-6-git-send-email-wency@cn.fujitsu.com> <504E9EBE.1040403@cn.fujitsu.com>
In-Reply-To: <504E9EBE.1040403@cn.fujitsu.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wen Congyang <wency@cn.fujitsu.com>
Cc: x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com, sparclinux@vger.kernel.org, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com

Hi Wen,

2012/09/11 11:15, Wen Congyang wrote:
> Hi, ishimatsu
>
> At 09/05/2012 05:25 PM, wency@cn.fujitsu.com Wrote:
>> From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
>>
>> If system supports memory hot-remove, online_pages() may online removed pages.
>> So online_pages() need to check whether onlining pages are present or not.
>
> Because we use memory_block_change_state() to hotremoving memory, I think
> this patch can be removed. What do you think?

Pleae teach me detals a little more. If we use memory_block_change_state(),
does the conflict never occur? Why?

Thansk,
Yasuaki Ishimatsu

> Thanks
> Wen Congyang
>
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
>>   include/linux/mmzone.h |   19 +++++++++++++++++++
>>   mm/memory_hotplug.c    |   13 +++++++++++++
>>   2 files changed, 32 insertions(+), 0 deletions(-)
>>
>> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
>> index 2daa54f..ac3ae30 100644
>> --- a/include/linux/mmzone.h
>> +++ b/include/linux/mmzone.h
>> @@ -1180,6 +1180,25 @@ void sparse_init(void);
>>   #define sparse_index_init(_sec, _nid)  do {} while (0)
>>   #endif /* CONFIG_SPARSEMEM */
>>
>> +#ifdef CONFIG_SPARSEMEM
>> +static inline int pfns_present(unsigned long pfn, unsigned long nr_pages)
>> +{
>> +	int i;
>> +	for (i = 0; i < nr_pages; i++) {
>> +		if (pfn_present(pfn + i))
>> +			continue;
>> +		else
>> +			return -EINVAL;
>> +	}
>> +	return 0;
>> +}
>> +#else
>> +static inline int pfns_present(unsigned long pfn, unsigned long nr_pages)
>> +{
>> +	return 0;
>> +}
>> +#endif /* CONFIG_SPARSEMEM*/
>> +
>>   #ifdef CONFIG_NODES_SPAN_OTHER_NODES
>>   bool early_pfn_in_nid(unsigned long pfn, int nid);
>>   #else
>> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
>> index 49f7747..299747d 100644
>> --- a/mm/memory_hotplug.c
>> +++ b/mm/memory_hotplug.c
>> @@ -467,6 +467,19 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages)
>>   	struct memory_notify arg;
>>
>>   	lock_memory_hotplug();
>> +	/*
>> +	 * If system supports memory hot-remove, the memory may have been
>> +	 * removed. So we check whether the memory has been removed or not.
>> +	 *
>> +	 * Note: When CONFIG_SPARSEMEM is defined, pfns_present() become
>> +	 *       effective. If CONFIG_SPARSEMEM is not defined, pfns_present()
>> +	 *       always returns 0.
>> +	 */
>> +	ret = pfns_present(pfn, nr_pages);
>> +	if (ret) {
>> +		unlock_memory_hotplug();
>> +		return ret;
>> +	}
>>   	arg.start_pfn = pfn;
>>   	arg.nr_pages = nr_pages;
>>   	arg.status_change_nid = -1;
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
