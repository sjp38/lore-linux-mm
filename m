Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f181.google.com (mail-qk0-f181.google.com [209.85.220.181])
	by kanga.kvack.org (Postfix) with ESMTP id A45F36B006C
	for <linux-mm@kvack.org>; Tue,  9 Jun 2015 10:44:05 -0400 (EDT)
Received: by qkhq76 with SMTP id q76so10446980qkh.2
        for <linux-mm@kvack.org>; Tue, 09 Jun 2015 07:44:05 -0700 (PDT)
Received: from devils.ext.ti.com (devils.ext.ti.com. [198.47.26.153])
        by mx.google.com with ESMTPS id z92si5615092qgd.1.2015.06.09.07.44.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 09 Jun 2015 07:44:03 -0700 (PDT)
Message-ID: <5576FBA7.2070504@ti.com>
Date: Tue, 9 Jun 2015 17:43:51 +0300
From: Grygorii Strashko <grygorii.strashko@ti.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH] PM / hibernate: fix kernel crash in alloc_highmem_pages
References: <1433776925-24662-1-git-send-email-grygorii.strashko@ti.com> <5743565.2B66qaKcGE@vostro.rjw.lan>
In-Reply-To: <5743565.2B66qaKcGE@vostro.rjw.lan>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Cc: linux-pm@vger.kernel.org, Len Brown <len.brown@intel.com>, Pavel Machek <pavel@ucw.cz>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, illia.smyrnov@globallogic.com, "Grygorii.Strashko@linaro.org" <grygorii.strashko@linaro.org>

Hi Rafael,

On 06/09/2015 02:14 AM, Rafael J. Wysocki wrote:
> On Monday, June 08, 2015 06:22:05 PM Grygorii Strashko wrote:
>> Now Kernel crashes under some circumstances in swsusp_alloc()
>> because it hits BUG() in memory_bm_set_bit().
>>
>> Kernel: Linux 4.1-rc3
>> HW: TI dra7-evm board, 2xARM Cortex-A15, 1.5G RAM
>> Swap: 2G swap partition on SD-card
>>
>> Steps to reproduce:
>> - reserve 500M memory for CMA from command line: "cma=500M"
>> - configure image_size
>>    # echo 1073741824 > sys/power/image_size
>> - enable swap
>>    # swapon /dev/<swap partition>
>> - run memtester
>>    # memtester 460M &
>> - [optional] disable console suspend
>>    # echo 0 > sys/module/printk/parameters/console_suspend
>> - perform suspend to disk
>>    # echo disk > sys/power/state
>>
>> Crash report:
>> -----------[ cut here ]------------
>> Kernel BUG at c0097394 [verbose debug info unavailable]
>> Internal error: Oops - BUG: 0 [#1] SMP ARM
>> Modules linked in:
>> CPU: 0 PID: 68 Comm: sh Not tainted 4.1.0-rc3-00190-ga96463d-dirty #138
>> Hardware name: Generic DRA74X (Flattened Device Tree)
>> task: ee3b2fc0 ti: ee6e8000 task.ti: ee6e8000
>> PC is at memory_bm_set_bit+0x30/0x34
>> LR is at 0x80000
>> pc : [<c0097394>]    lr : [<00080000>]    psr: a00000d3
>> sp : ee6e9de4  ip : c111f714  fp : 00000000
>> r10: 000128e2  r9 : c111f6f8  r8 : 00028658
>> r7 : c114ef00  r6 : c08bad04  r5 : 00027849  r4 : 00012b59
>> r3 : ee6e9de8  r2 : ee6e9de4  r1 : 8ebc3c00  r0 : fffffff2
>> Flags: NzCv  IRQs off  FIQs off  Mode SVC_32  ISA ARM  Segment user
>> Control: 10c5387d  Table: ae6dc06a  DAC: 00000015
>> Process sh (pid: 68, stack limit = 0xee6e8218)
>> Stack: (0xee6e9de4 to 0xee6ea000)
>> 9de0:          00000000 c0097690 00012b59 c0099148 00000030 ee6e9e4c 00000000
>> 9e00: 00000007 0000000f c096b624 c08b78d4 c001452c 00000030 c00141b0 ae0d0000
>> 9e20: ee6e9e4c 80021ae0 00000000 001fc4c0 001fc4c0 00000015 8000406a 10c5387d
>> 9e40: 00000040 00f00000 00000000 00000000 ee6f4c00 00000000 c08b6800 c0773a60
>> 9e60: c096b624 c096dbe8 00000000 c001435c ee3b2fc0 00000000 c096b624 c00966a8
>> 9e80: c08f9710 00000000 c111f5c8 00200660 c08f9644 00000005 00000000 c0096ef0
>> 9ea0: ee6470c0 00000005 00000004 00200660 ee6a6300 c00944cc 00000005 ee6470c0
>> 9ec0: 00000005 ee6a6300 00200660 ee6470cc ee6e9f88 c01dc688 00000000 00000000
>> 9ee0: 20000013 ee6f76c0 00000005 00200660 ee6e9f88 c000f6a4 ee6e8000 00000000
>> 9f00: 00000002 c016beec c08b87bc c016e32c 00000020 00000000 c016c830 ee3b2fb8
>> 9f20: c016c830 ee652ae4 ee6f76c0 00000000 00000000 c016c51c 00000000 00000003
>> 9f40: 00000000 ee6f76c0 00000005 00200660 ee6f76c0 00000005 00200660 ee6e9f88
>> 9f60: c000f6a4 c016c784 00000000 00000000 ee6f76c0 ee6f76c0 00200660 00000005
>> 9f80: c000f6a4 c016cfb0 00000000 00000000 00200660 001fc4e0 00000005 00200660
>> 9fa0: 00000004 c000f4e0 001fc4e0 00000005 00000001 00200660 00000005 001fbc18
>> 9fc0: 001fc4e0 00000005 00200660 00000004 001fd264 001fcfc8 00000000 00000002
>> 9fe0: 00000001 bee87618 0000c55c 0000921c 60000010 00000001 00000000 00000000
>> [<c0097394>] (memory_bm_set_bit) from [<c0099148>] (swsusp_save+0x3f0/0x440)
>> [<c0099148>] (swsusp_save) from [<c001452c>] (arch_save_image+0x8/0x2c)
>> [<c001452c>] (arch_save_image) from [<c00141b0>] (cpu_suspend_abort+0x0/0x30)
>> [<c00141b0>] (cpu_suspend_abort) from [<00000000>] (  (null))
>> Code: e59d0004 eb0ae150 e28dd00c e49df004 (e7f001f2)
>> ---[ end trace 61e3b86f908e4d7f ]---
>>
>> As was investigated, the issue depends on following things:
>> 1) Hibernation should follow through the below code path in
>>     hibernate_preallocate_memory():
>>
>> int hibernate_preallocate_memory(void)
>> {
>> 	[...]
>> 	/*
>> 	 * If the desired number of image pages is at least as large as the
>> 	 * current number of saveable pages in memory, allocate page frames for
>> 	 * the image and we're done.
>> 	 */
>> 	if (size >= saveable) {
>> 		pages = preallocate_image_highmem(save_highmem);
>> 		pages += preallocate_image_memory(saveable - pages, avail_normal);
>> 		goto out;
>> 	}
>>
>> 2) Amount of memory reserved for CMA purposes. CMA memory reported as free
>>     by MM, but Hibernation core can't use it. As result, All memory checks
>>     are passed and system reaches later Hibernation stages, tries to create
>>     Hibernation immage and, finally crashes in swsusp_alloc():
>> 	swsusp_alloc()
>> 	|- alloc_highmem_pages()
>> 	   |- alloc_image_page(__GFP_HIGHMEM)
>> 	   -- >"sh: page allocation failure: order:0, mode:0x2"
>> 	   |- memory_bm_set_bit
>> 		|- BUG_ON(error)
>>
>> 3) alloc_page(__GFP_HIGHMEM) doesn't return Highmem pages always, instead
>>     MM allocates pages from all available zones evenly. For example:
>>
>> 	saveable pages 167191 = hmem 80400 + normal 86791
>> 	request hmem 80400
>> 	- alloc hmem 204
>> 	- alloc normal 161
>> 	- alloc hmem 442
>> 	...
>> 	- alloc normal 38615
>> 	- alloc hmem 41785
>>    Such behaviour is not always handled properly. As result, swsusp_alloc(),
>>    (from above example) will try to allocate (80400 - 41785) additional Highmem pages
>>    without taking into account that those pages were allocated already,
>>    but from Normal zone.
>>
>> In this patch it is proposed to fix issue by rewriting swsusp_alloc()
>> in the following way:
>>    - allocate Highmem buffer
>>    - check if we need to allocate any memory at all
>> 	alloc_normal + alloc_highmem < nr_normal + nr_highmem
>>    - calculate number of pages which still need to be allocated
>> 	nr_pages = nr_normal + nr_highmem - alloc_normal - alloc_highmem
>>    - try to allocate Highmem first, but no more than nr_pages
>>    - try to get rest from Normal memory
>>    - abort if not all pages were allocated
>>
>> And also use preallocate_image_pages() instead of alloc_highmem_pages() and
>> alloc_image_page(). This way, allocated pages will be accounted properly
>> in alloc_highmem and alloc_normal counters.
>>
>> alloc_highmem_pages() isn't used any more after this patch and so removed.
>>
>> Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
>> ---
>> Hi All,
>>
>> I've tested this patch with both CONFIG_HIGHMEM=y/n.
>>
>> This patch marked as RFC, because:
>> - I'm not expert in MM, so there could be other, more simple ways
>>    to fix it. Also, I'm not sure that I've described Item 2 correctly.
>>    (fair zone allocator policy?!)
>> - preallocate_image_highmem() and preallocate_image_memory()
>>    could be used instead of preallocate_image_pages(), potentially.
>>
>> Thanks for any comments.
> 
> The assumption the original code was written with was that a copy of a highmem
> page could be stored either in highmem or in normal memory, while a copy of a
> normal memory page could only be stored in normal memory.
>

May be I'm mistaken, but it looks like copy_data_page() can handle any types
of src/dst pages. Right?

What I've found during my experiments is that we can't predict how much
memory will be really allocated from Highmem if we request HIGHMEM pages.
Sometimes it was 50%/50%, sometimes - 30% Highmem/ 70% Normal.
And, I don't know if it's possible to restrict page allocation from some specific
memory zone only.

As result, I have an opinion that It could be possible to request Highmem pages
always and let MM to decide from where physically get the page :) 
If above is valid point - hibernate_preallocate_memory() can be simplified a lot.

 
> IOW, the number of allocated normal pages must always be greater than or equal
> to the number of pages in normal memory to make copies of.
> 
> Does that still hold after your patch?

On my boards - yes, It is.

Actually, this patch doesn't change page allocation logic - it just ensures
that in swsusp_save() we will not request more Highmem pages than needed,
accounts High/Noramal pages properly and checks if there are enough memory
before proceeding to copy_data_pages().  


> 
>>   kernel/power/snapshot.c | 82 ++++++++++++++++++++++---------------------------
>>   1 file changed, 37 insertions(+), 45 deletions(-)
>>
>> diff --git a/kernel/power/snapshot.c b/kernel/power/snapshot.c
>> index 5235dd4..6ee8790 100644
>> --- a/kernel/power/snapshot.c
>> +++ b/kernel/power/snapshot.c
>> @@ -1761,34 +1761,9 @@ static inline int get_highmem_buffer(int safe_needed)
>>   	return buffer ? 0 : -ENOMEM;
>>   }
>>   
>> -/**
>> - *	alloc_highmem_image_pages - allocate some highmem pages for the image.
>> - *	Try to allocate as many pages as needed, but if the number of free
>> - *	highmem pages is lesser than that, allocate them all.
>> - */
>> -
>> -static inline unsigned int
>> -alloc_highmem_pages(struct memory_bitmap *bm, unsigned int nr_highmem)
>> -{
>> -	unsigned int to_alloc = count_free_highmem_pages();
>> -
>> -	if (to_alloc > nr_highmem)
>> -		to_alloc = nr_highmem;
>> -
>> -	nr_highmem -= to_alloc;
>> -	while (to_alloc-- > 0) {
>> -		struct page *page;
>> -
>> -		page = alloc_image_page(__GFP_HIGHMEM);
>> -		memory_bm_set_bit(bm, page_to_pfn(page));
>> -	}
>> -	return nr_highmem;
>> -}
>>   #else
>>   static inline int get_highmem_buffer(int safe_needed) { return 0; }
>>   
>> -static inline unsigned int
>> -alloc_highmem_pages(struct memory_bitmap *bm, unsigned int n) { return 0; }
>>   #endif /* CONFIG_HIGHMEM */
>>   
>>   /**
>> @@ -1805,28 +1780,45 @@ alloc_highmem_pages(struct memory_bitmap *bm, unsigned int n) { return 0; }
>>   
>>   static int
>>   swsusp_alloc(struct memory_bitmap *orig_bm, struct memory_bitmap *copy_bm,
>> -		unsigned int nr_pages, unsigned int nr_highmem)
>> +		unsigned int nr_normal, unsigned int nr_highmem)
>>   {
>> -	if (nr_highmem > 0) {
>> -		if (get_highmem_buffer(PG_ANY))
>> -			goto err_out;
>> -		if (nr_highmem > alloc_highmem) {
>> -			nr_highmem -= alloc_highmem;
>> -			nr_pages += alloc_highmem_pages(copy_bm, nr_highmem);
>> -		}
>> -	}
>> -	if (nr_pages > alloc_normal) {
>> -		nr_pages -= alloc_normal;
>> -		while (nr_pages-- > 0) {
>> -			struct page *page;
>> -
>> -			page = alloc_image_page(GFP_ATOMIC | __GFP_COLD);
>> -			if (!page)
>> -				goto err_out;
>> -			memory_bm_set_bit(copy_bm, page_to_pfn(page));
>> -		}
>> -	}
>> +	unsigned int nr_pages;
>> +	/*
>> +	 * Additional input data:
>> +	 *  alloc_highmem - number of allocated Highmem pages
>> +	 *  alloc_normal - number of allocated Normal pages
>> +	 */
>> +
>> +	/* allocate Highmem buffer */
>> +	if ((nr_highmem > 0) && get_highmem_buffer(PG_ANY))
>> +		goto err_out;
>> +
>> +	/*
>> +	 * check if we need to allocate any memory at all
>> +	 *	alloc_normal + alloc_highmem < nr_normal + nr_highmem
>> +	 * and calculate number of pages which still need to be allocated
>> +	 *     nr_pages = nr_normal + nr_highmem - alloc_normal - alloc_highmem
>> +	 */
>> +	nr_pages = nr_normal + nr_highmem;
>> +	if (nr_pages > alloc_normal + alloc_highmem)
>> +		nr_pages -= alloc_normal + alloc_highmem;
>> +	else
>> +		goto out;
> 
> Please do not jump to return statements.  Use them directly instead (ie. return
> 0 from here).
> 

ok

>> +
>> +	/* try to allocate Highmem first, but no more than nr_pages */
>> +	if (nr_highmem > 0)
>> +		nr_pages -= preallocate_image_pages(nr_pages,  __GFP_HIGHMEM);
>>   
>> +	/* try to get rest from Normal memory */
>> +	if (nr_pages)
>> +		nr_pages -= preallocate_image_pages(nr_pages,
>> +						    GFP_ATOMIC | __GFP_COLD);
>> +
>> +	/* abort if not all pages were allocated */
>> +	if (nr_pages)
>> +		goto err_out;
> 
> This can be
> 
> 	if (!nr_pages)
> 		return 0;
> 

ok

>> +
>> +out:
>>   	return 0;
>>   
>>    err_out:
>>
> 

I'm on a business trip now, so my replies could be delayed.

-- 
regards,
-grygorii

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
