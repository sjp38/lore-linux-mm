Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id A2EDE6B0036
	for <linux-mm@kvack.org>; Tue, 29 Jul 2014 04:42:41 -0400 (EDT)
Received: by mail-pd0-f173.google.com with SMTP id w10so11332946pde.32
        for <linux-mm@kvack.org>; Tue, 29 Jul 2014 01:42:41 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id pq10si20325781pbb.233.2014.07.29.01.42.37
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 29 Jul 2014 01:42:40 -0700 (PDT)
Message-ID: <53D75E13.8000702@huawei.com>
Date: Tue, 29 Jul 2014 16:40:51 +0800
From: Zhang Zhen <zhenzhang.zhang@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2] memory hotplug: update the variables after memory
 removed
References: <1406619310-20555-1-git-send-email-zhenzhang.zhang@huawei.com> <53D74EE5.1070308@huawei.com> <alpine.DEB.2.02.1407290046470.7998@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.02.1407290046470.7998@chino.kir.corp.google.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>, mgorman@suse.de, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, wangnan0@huawei.com, Linux MM <linux-mm@kvack.org>, linux-kernel@vger.kernel.org

On 2014/7/29 15:53, David Rientjes wrote:
> On Tue, 29 Jul 2014, Zhang Zhen wrote:
> 
>> Commit ea0854170c95245a258b386c7a9314399c949fe0 added a fuction
> 
> This would normally be written as
> 
> Commit ea0854170c95 ("memory hotplug: fix a bug on /dev/mem for 64-bit 
> kernels") ...
> 
ok.
>> update_end_of_memory_vars() to update high_memory, max_pfn and
>> max_low_pfn.
>>
>> I modified the function according to Dave Hansen and David Rientjes's
>> suggestions.
>> And call it in arch_remove_memory() to update these variables too.
>>
> 
> When the x86 maintainers merge this patch, they'll need to make a judgment 
> call on how urgent the fix is and that will guide them in whether they 
> want it backported to stable kernels as well.  It would be useful to 
> provide the rationale for the change; in other words, why is the change 
> needed and what breaks if we don't have it?
Got it, here we may access wrong memory via /dev/mem without this patch.
I will provide the rationale for the change.
> 
>> Change v1->v2:
>> - according to Dave Hansen and David Rientjes's suggestions modified
>>   update_end_of_memory_vars().
>> Signed-off-by: Zhang Zhen <zhenzhang.zhang@huawei.com>
> 
> Acked-by: David Rientjes <rientjes@google.com>
> 
> You'll want to email all the x86 maintainers who would handle this patch, 
> check the output of scripts/get_maintainer.pl when run on this diff.
Ok, Thanks!
> 
>> ---
>>  arch/x86/mm/init_64.c | 23 ++++++++++++++---------
>>  1 file changed, 14 insertions(+), 9 deletions(-)
>>
>> diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
>> index df1a992..fd7bd6b 100644
>> --- a/arch/x86/mm/init_64.c
>> +++ b/arch/x86/mm/init_64.c
>> @@ -673,15 +673,11 @@ void __init paging_init(void)
>>   * After memory hotplug the variables max_pfn, max_low_pfn and high_memory need
>>   * updating.
>>   */
>> -static void  update_end_of_memory_vars(u64 start, u64 size)
>> +static void  update_end_of_memory_vars(u64 end_pfn)
> 
> Extra space that can be removed here at the same time as a cleanup.
> 
Sorry, where is the extra space here?

>>  {
>> -	unsigned long end_pfn = PFN_UP(start + size);
>> -
>> -	if (end_pfn > max_pfn) {
>> -		max_pfn = end_pfn;
>> -		max_low_pfn = end_pfn;
>> -		high_memory = (void *)__va(max_pfn * PAGE_SIZE - 1) + 1;
>> -	}
>> +	max_pfn = end_pfn;
>> +	max_low_pfn = end_pfn;
>> +	high_memory = (void *)__va(max_pfn * PAGE_SIZE - 1) + 1;
>>  }
>>
>>  /*
>> @@ -694,6 +690,7 @@ int arch_add_memory(int nid, u64 start, u64 size)
>>  	struct zone *zone = pgdat->node_zones + ZONE_NORMAL;
>>  	unsigned long start_pfn = start >> PAGE_SHIFT;
>>  	unsigned long nr_pages = size >> PAGE_SHIFT;
>> +	unsigned long end_pfn;
>>  	int ret;
>>
>>  	init_memory_mapping(start, start + size);
>> @@ -702,7 +699,9 @@ int arch_add_memory(int nid, u64 start, u64 size)
>>  	WARN_ON_ONCE(ret);
>>
>>  	/* update max_pfn, max_low_pfn and high_memory */
>> -	update_end_of_memory_vars(start, size);
>> +	end_pfn = start_pfn + nr_pages;
>> +	if (end_pfn > max_pfn)
>> +		update_end_of_memory_vars(end_pfn);
>>
>>  	return ret;
>>  }
>> @@ -1018,6 +1017,7 @@ int __ref arch_remove_memory(u64 start, u64 size)
>>  	unsigned long start_pfn = start >> PAGE_SHIFT;
>>  	unsigned long nr_pages = size >> PAGE_SHIFT;
>>  	struct zone *zone;
>> +	unsigned long end_pfn;
>>  	int ret;
>>
>>  	zone = page_zone(pfn_to_page(start_pfn));
>> @@ -1025,6 +1025,11 @@ int __ref arch_remove_memory(u64 start, u64 size)
>>  	ret = __remove_pages(zone, start_pfn, nr_pages);
>>  	WARN_ON_ONCE(ret);
>>
>> +	/* update max_pfn, max_low_pfn and high_memory */
>> +	end_pfn = start_pfn + nr_pages;
>> +	if ((max_pfn >= start_pfn) && (max_pfn < end_pfn))
>> +		update_end_of_memory_vars(start_pfn);
> 
> Not sure if we really need the new variable here; if you choose to 
> repropose this patch then you may want to consider just using 
> start_pfn + nr_pages in the conditional.
yeah, i will remove it in v3.
> 
>> +
>>  	return ret;
>>  }
>>  #endif
> 
> .
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
