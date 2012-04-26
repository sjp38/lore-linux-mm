Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id 7A2EC6B0044
	for <linux-mm@kvack.org>; Wed, 25 Apr 2012 22:02:59 -0400 (EDT)
Message-ID: <4F98ACF3.7060908@kernel.org>
Date: Thu, 26 Apr 2012 11:03:31 +0900
From: Minchan Kim <minchan@kernel.org>
MIME-Version: 1.0
Subject: Re: [PATCH 6/6] zsmalloc: make zsmalloc portable
References: <1335334994-22138-1-git-send-email-minchan@kernel.org> <1335334994-22138-7-git-send-email-minchan@kernel.org> <4F980AFE.60901@vflare.org> <fcde09be-ae34-4f09-a324-825fb2d4fac2@default>
In-Reply-To: <fcde09be-ae34-4f09-a324-825fb2d4fac2@default>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Nitin Gupta <ngupta@vflare.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi Dan,

On 04/26/2012 12:40 AM, Dan Magenheimer wrote:

>> From: Nitin Gupta [mailto:ngupta@vflare.org]
>> Subject: Re: [PATCH 6/6] zsmalloc: make zsmalloc portable
>>
>> On 04/25/2012 02:23 AM, Minchan Kim wrote:
>>
>>> The zsmalloc uses __flush_tlb_one and set_pte.
>>> It's very lower functions so that it makes arhcitecture dependency
>>> so currently zsmalloc is used by only x86.
>>> This patch changes them with map_vm_area and unmap_kernel_range so
>>> it should work all architecture.
>>>
>>> Signed-off-by: Minchan Kim <minchan@kernel.org>
>>> ---
>>>  drivers/staging/zsmalloc/Kconfig         |    4 ----
>>>  drivers/staging/zsmalloc/zsmalloc-main.c |   27 +++++++++++++++++----------
>>>  drivers/staging/zsmalloc/zsmalloc_int.h  |    1 -
>>>  3 files changed, 17 insertions(+), 15 deletions(-)
>>>
>>> diff --git a/drivers/staging/zsmalloc/Kconfig b/drivers/staging/zsmalloc/Kconfig
>>> index a5ab720..9084565 100644
>>> --- a/drivers/staging/zsmalloc/Kconfig
>>> +++ b/drivers/staging/zsmalloc/Kconfig
>>> @@ -1,9 +1,5 @@
>>>  config ZSMALLOC
>>>  	tristate "Memory allocator for compressed pages"
>>> -	# X86 dependency is because of the use of __flush_tlb_one and set_pte
>>> -	# in zsmalloc-main.c.
>>> -	# TODO: convert these to portable functions
>>> -	depends on X86
>>>  	default n
>>>  	help
>>>  	  zsmalloc is a slab-based memory allocator designed to store
>>> diff --git a/drivers/staging/zsmalloc/zsmalloc-main.c b/drivers/staging/zsmalloc/zsmalloc-main.c
>>> index ff089f8..cc017b1 100644
>>> --- a/drivers/staging/zsmalloc/zsmalloc-main.c
>>> +++ b/drivers/staging/zsmalloc/zsmalloc-main.c
>>> @@ -442,7 +442,7 @@ static int zs_cpu_notifier(struct notifier_block *nb, unsigned long action,
>>>  		area = &per_cpu(zs_map_area, cpu);
>>>  		if (area->vm)
>>>  			break;
>>> -		area->vm = alloc_vm_area(2 * PAGE_SIZE, area->vm_ptes);
>>> +		area->vm = alloc_vm_area(2 * PAGE_SIZE, NULL);
>>>  		if (!area->vm)
>>>  			return notifier_from_errno(-ENOMEM);
>>>  		break;
>>> @@ -696,13 +696,22 @@ void *zs_map_object(struct zs_pool *pool, void *handle)
>>>  	} else {
>>>  		/* this object spans two pages */
>>>  		struct page *nextp;
>>> +		struct page *pages[2];
>>> +		struct page **page_array = &pages[0];
>>> +		int err;
>>>
>>>  		nextp = get_next_page(page);
>>>  		BUG_ON(!nextp);
>>>
>>> +		page_array[0] = page;
>>> +		page_array[1] = nextp;
>>>
>>> -		set_pte(area->vm_ptes[0], mk_pte(page, PAGE_KERNEL));
>>> -		set_pte(area->vm_ptes[1], mk_pte(nextp, PAGE_KERNEL));
>>> +		/*
>>> +		 * map_vm_area never fail because we already allocated
>>> +		 * pages for page table in alloc_vm_area.
>>> +		 */
>>> +		err = map_vm_area(area->vm, PAGE_KERNEL, &page_array);
>>> +		BUG_ON(err);
>>>
>>>  		/* We pre-allocated VM area so mapping can never fail */
>>>  		area->vm_addr = area->vm->addr;
>>> @@ -730,14 +739,12 @@ void zs_unmap_object(struct zs_pool *pool, void *handle)
>>>  	off = obj_idx_to_offset(page, obj_idx, class->size);
>>>
>>>  	area = &__get_cpu_var(zs_map_area);
>>> -	if (off + class->size <= PAGE_SIZE) {
>>> +	if (off + class->size <= PAGE_SIZE)
>>>  		kunmap_atomic(area->vm_addr);
>>> -	} else {
>>> -		set_pte(area->vm_ptes[0], __pte(0));
>>> -		set_pte(area->vm_ptes[1], __pte(0));
>>> -		__flush_tlb_one((unsigned long)area->vm_addr);
>>> -		__flush_tlb_one((unsigned long)area->vm_addr + PAGE_SIZE);
>>> -	}
>>> +	else
>>> +		unmap_kernel_range((unsigned long)area->vm->addr,
>>> +					PAGE_SIZE * 2);
>>> +
>>
>>
>>
>> This would certainly work but would incur unncessary cost. All we need
>> to do is to flush the local TLB entry correpsonding to these two pages.
>> However, unmap_kernel_range --> flush_tlb_kernel_range woule cause TLB
>> flush on all CPUs. Additionally, implementation of this function
>> (flush_tlb_kernel_range) on architecutures like x86 seems naive since it
>> flushes the entire TLB on all the CPUs.
>>
>> Even with all this penalty, I'm inclined on keeping this change to
>> remove x86 only dependency, keeping improvements as future work.
>>
>> I think Seth was working on this improvement but not sure about the
>> current status. Seth?
> 
> I wouldn't normally advocate an architecture-specific ifdef, but the
> penalty for portability here seems high enough that it could make
> sense here, perhaps hidden away in zsmalloc.h?  Perhaps eventually
> in a mm header file as "unmap_kernel_page_pair_local()"?


Agree.
I think it's a right way we should go.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
