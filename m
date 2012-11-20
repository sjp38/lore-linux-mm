Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id 3A3046B0070
	for <linux-mm@kvack.org>; Tue, 20 Nov 2012 01:49:18 -0500 (EST)
Message-ID: <50AB2967.5010302@cn.fujitsu.com>
Date: Tue, 20 Nov 2012 14:55:35 +0800
From: Wen Congyang <wency@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 06/12] memory-hotplug: unregister memory section on
 SPARSEMEM_VMEMMAP
References: <1351763083-7905-1-git-send-email-wency@cn.fujitsu.com> <1351763083-7905-7-git-send-email-wency@cn.fujitsu.com> <50AB21A4.8050709@gmail.com>
In-Reply-To: <50AB21A4.8050709@gmail.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jaegeuk Hanse <jaegeuk.hanse@gmail.com>
Cc: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com, sparclinux@vger.kernel.org, David Rientjes <rientjes@google.com>, Jiang Liu <liuj97@gmail.com>, Len Brown <len.brown@intel.com>, benh@kernel.crashing.org, paulus@samba.org, Christoph Lameter <cl@linux.com>, Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Jianguo Wu <wujianguo@huawei.com>

At 11/20/2012 02:22 PM, Jaegeuk Hanse Wrote:
> On 11/01/2012 05:44 PM, Wen Congyang wrote:
>> From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
>>
>> Currently __remove_section for SPARSEMEM_VMEMMAP does nothing. But
>> even if
>> we use SPARSEMEM_VMEMMAP, we can unregister the memory_section.
>>
>> So the patch add unregister_memory_section() into __remove_section().
> 
> Hi Yasuaki,
> 
> In order to review this patch, I should dig sparse memory codes in
> advance. But I have some confuse of codes. Why need encode/decode mem
> map instead of set mem_map to ms->section_mem_map directly?

The memmap is aligned, and the low bits are zero. We store some information
in these bits. So we need to encode/decode memmap here.

Thanks
Wen Congyang

> 
> Regards,
> Jaegeuk
> 
>>
>> CC: David Rientjes <rientjes@google.com>
>> CC: Jiang Liu <liuj97@gmail.com>
>> CC: Len Brown <len.brown@intel.com>
>> CC: Christoph Lameter <cl@linux.com>
>> Cc: Minchan Kim <minchan.kim@gmail.com>
>> CC: Andrew Morton <akpm@linux-foundation.org>
>> CC: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
>> CC: Wen Congyang <wency@cn.fujitsu.com>
>> Signed-off-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
>> ---
>>   mm/memory_hotplug.c | 13 ++++++++-----
>>   1 file changed, 8 insertions(+), 5 deletions(-)
>>
>> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
>> index ca07433..66a79a7 100644
>> --- a/mm/memory_hotplug.c
>> +++ b/mm/memory_hotplug.c
>> @@ -286,11 +286,14 @@ static int __meminit __add_section(int nid,
>> struct zone *zone,
>>   #ifdef CONFIG_SPARSEMEM_VMEMMAP
>>   static int __remove_section(struct zone *zone, struct mem_section *ms)
>>   {
>> -    /*
>> -     * XXX: Freeing memmap with vmemmap is not implement yet.
>> -     *      This should be removed later.
>> -     */
>> -    return -EBUSY;
>> +    int ret = -EINVAL;
>> +
>> +    if (!valid_section(ms))
>> +        return ret;
>> +
>> +    ret = unregister_memory_section(ms);
>> +
>> +    return ret;
>>   }
>>   #else
>>   static int __remove_section(struct zone *zone, struct mem_section *ms)
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
