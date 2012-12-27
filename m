Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id 122506B0044
	for <linux-mm@kvack.org>; Wed, 26 Dec 2012 22:10:18 -0500 (EST)
Message-ID: <50DBBBDF.4090806@cn.fujitsu.com>
Date: Thu, 27 Dec 2012 11:09:19 +0800
From: Tang Chen <tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v5 03/14] memory-hotplug: remove redundant codes
References: <1356350964-13437-1-git-send-email-tangchen@cn.fujitsu.com> <1356350964-13437-4-git-send-email-tangchen@cn.fujitsu.com> <50DA6D04.8020906@jp.fujitsu.com>
In-Reply-To: <50DA6D04.8020906@jp.fujitsu.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-2022-JP
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: akpm@linux-foundation.org, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, kosaki.motohiro@jp.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, wujianguo@huawei.com, wency@cn.fujitsu.com, hpa@zytor.com, linfeng@cn.fujitsu.com, laijs@cn.fujitsu.com, mgorman@suse.de, yinghai@kernel.org, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com, sparclinux@vger.kernel.org

Hi Kamezawa-san,

Thanks for the reviewing. Please see below. :)

On 12/26/2012 11:20 AM, Kamezawa Hiroyuki wrote:
> (2012/12/24 21:09), Tang Chen wrote:
>> From: Wen Congyang<wency@cn.fujitsu.com>
>>
>> offlining memory blocks and checking whether memory blocks are offlined
>> are very similar. This patch introduces a new function to remove
>> redundant codes.
>>
>> Signed-off-by: Wen Congyang<wency@cn.fujitsu.com>
>> ---
>>    mm/memory_hotplug.c |  101 ++++++++++++++++++++++++++++-----------------------
>>    1 files changed, 55 insertions(+), 46 deletions(-)
>>
>> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
>> index d43d97b..dbb04d8 100644
>> --- a/mm/memory_hotplug.c
>> +++ b/mm/memory_hotplug.c
>> @@ -1381,20 +1381,14 @@ int offline_pages(unsigned long start_pfn, unsigned long nr_pages)
>>    	return __offline_pages(start_pfn, start_pfn + nr_pages, 120 * HZ);
>>    }
>>
>> -int remove_memory(u64 start, u64 size)
> 
> please add explanation of this function here. If (*func) returns val other than 0,
> this function will fail and returns callback's return value...right ?
> 

Yes, it will always return the func()'s return value. I'll add the
comment here. :)

> 
>> +static int walk_memory_range(unsigned long start_pfn, unsigned long end_pfn,
>> +		void *arg, int (*func)(struct memory_block *, void *))
>>    {
>>    	struct memory_block *mem = NULL;
>>    	struct mem_section *section;
>> -	unsigned long start_pfn, end_pfn;
>>    	unsigned long pfn, section_nr;
>>    	int ret;
>> -	int return_on_error = 0;
>> -	int retry = 0;
>> -
>> -	start_pfn = PFN_DOWN(start);
>> -	end_pfn = start_pfn + PFN_DOWN(size);
>>
>> -repeat:
> 
> Shouldn't we check lock is held here ? (VM_BUG_ON(!mutex_is_locked(&mem_hotplug_mutex);

Well, I think, after applying this patch, walk_memory_range() will be
a separated function. And it can be used somewhere else where we don't
hold this lock. But for now, we can do this check.  :)

> 
> 
>>    	for (pfn = start_pfn; pfn<  end_pfn; pfn += PAGES_PER_SECTION) {
>>    		section_nr = pfn_to_section_nr(pfn);
>>    		if (!present_section_nr(section_nr))
>> @@ -1411,22 +1405,61 @@ repeat:
>>    		if (!mem)
>>    			continue;
>>
>> -		ret = offline_memory_block(mem);
>> +		ret = func(mem, arg);
>>    		if (ret) {
>> -			if (return_on_error) {
>> -				kobject_put(&mem->dev.kobj);
>> -				return ret;
>> -			} else {
>> -				retry = 1;
>> -			}
>> +			kobject_put(&mem->dev.kobj);
>> +			return ret;
>>    		}
>>    	}
>>
>>    	if (mem)
>>    		kobject_put(&mem->dev.kobj);
>>
>> -	if (retry) {
>> -		return_on_error = 1;
>> +	return 0;
>> +}
>> +
>> +static int offline_memory_block_cb(struct memory_block *mem, void *arg)
>> +{
>> +	int *ret = arg;
>> +	int error = offline_memory_block(mem);
>> +
>> +	if (error != 0&&  *ret == 0)
>> +		*ret = error;
>> +
>> +	return 0;
> 
> Always returns 0 and run through all mem blocks for scan-and-retry, right ?
> You need explanation here !

Yes, I'll add the comment. :)

> 
> 
>> +}
>> +
>> +static int is_memblock_offlined_cb(struct memory_block *mem, void *arg)
>> +{
>> +	int ret = !is_memblock_offlined(mem);
>> +
>> +	if (unlikely(ret))
>> +		pr_warn("removing memory fails, because memory "
>> +			"[%#010llx-%#010llx] is onlined\n",
>> +			PFN_PHYS(section_nr_to_pfn(mem->start_section_nr)),
>> +			PFN_PHYS(section_nr_to_pfn(mem->end_section_nr + 1))-1);
>> +
>> +	return ret;
>> +}
>> +
>> +int remove_memory(u64 start, u64 size)
>> +{
>> +	unsigned long start_pfn, end_pfn;
>> +	int ret = 0;
>> +	int retry = 1;
>> +
>> +	start_pfn = PFN_DOWN(start);
>> +	end_pfn = start_pfn + PFN_DOWN(size);
>> +
>> +repeat:
> 
> please explan why you repeat here .

This repeat is add in patch1. It aims to solve the problem we were
talking about in patch1. I'll add the comment here. :)

> 
>> +	walk_memory_range(start_pfn, end_pfn,&ret,
>> +			  offline_memory_block_cb);
>> +	if (ret) {
>> +		if (!retry)
>> +			return ret;
>> +
>> +		retry = 0;
>> +		ret = 0;
>>    		goto repeat;
>>    	}
>>
>> @@ -1444,37 +1477,13 @@ repeat:
>>    	 * memory blocks are offlined.
>>    	 */
>>
>> -	for (pfn = start_pfn; pfn<  end_pfn; pfn += PAGES_PER_SECTION) {
>> -		section_nr = pfn_to_section_nr(pfn);
>> -		if (!present_section_nr(section_nr))
>> -			continue;
>> -
>> -		section = __nr_to_section(section_nr);
>> -		/* same memblock? */
>> -		if (mem)
>> -			if ((section_nr>= mem->start_section_nr)&&
>> -			    (section_nr<= mem->end_section_nr))
>> -				continue;
>> -
>> -		mem = find_memory_block_hinted(section, mem);
>> -		if (!mem)
>> -			continue;
>> -
>> -		ret = is_memblock_offlined(mem);
>> -		if (!ret) {
>> -			pr_warn("removing memory fails, because memory "
>> -				"[%#010llx-%#010llx] is onlined\n",
>> -				PFN_PHYS(section_nr_to_pfn(mem->start_section_nr)),
>> -				PFN_PHYS(section_nr_to_pfn(mem->end_section_nr + 1)) - 1);
>> -
>> -			kobject_put(&mem->dev.kobj);
>> -			unlock_memory_hotplug();
>> -			return ret;
>> -		}
> 
> please explain what you do here. confirming all memory blocks are offlined
> before returning 0 ....right ?

Will be added. :)

Thanks. :)

> 
>> +	ret = walk_memory_range(start_pfn, end_pfn, NULL,
>> +				is_memblock_offlined_cb);
>> +	if (ret) {
>> +		unlock_memory_hotplug();
>> +		return ret;
>>    	}
>>
>> -	if (mem)
>> -		kobject_put(&mem->dev.kobj);
>>    	unlock_memory_hotplug();
>>
>>    	return 0;
>>
> 
> Thanks,
> -Kame
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
