Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp05.au.ibm.com (8.13.1/8.13.1) with ESMTP id m3I3eIAQ021506
	for <linux-mm@kvack.org>; Fri, 18 Apr 2008 13:40:18 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m3I3eeEo3350770
	for <linux-mm@kvack.org>; Fri, 18 Apr 2008 13:40:40 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m3I3ehuQ008367
	for <linux-mm@kvack.org>; Fri, 18 Apr 2008 13:40:43 +1000
Message-ID: <4808177F.3090208@linux.vnet.ibm.com>
Date: Fri, 18 Apr 2008 09:07:35 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [PATCH] memcgroup: check and initialize page->cgroup in memmap_init_zone
References: <48080706.50305@cn.fujitsu.com> <48080930.5090905@cn.fujitsu.com> <48080B86.7040200@cn.fujitsu.com> <20080417201432.36b1c326.akpm@linux-foundation.org>
In-Reply-To: <20080417201432.36b1c326.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Shi Weihua <shiwh@cn.fujitsu.com>, Hiroyuki KAMEZAWA <kamezawa.hiroyu@jp.fujitsu.com>, xemul@openvz.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> On Fri, 18 Apr 2008 10:46:30 +0800 Shi Weihua <shiwh@cn.fujitsu.com> wrote:
> 
>> When we test memory controller in Fujitsu PrimeQuest(arch: ia64),
>> the compiled kernel boots failed, the following message occured on
>> the telnet terminal.
>> -------------------------------------
>> ..........
>> ELILO boot: Uncompressing Linux... done
>> Loading file initrd-2.6.25-rc9-00067-gb87e81e.img...done
>> _ (system freezed)
>> -------------------------------------
>>
>> We found commit 9442ec9df40d952b0de185ae5638a74970388e01
>> causes this boot failure by git-bisect.
>> And, we found the following change caused the boot failure.
>> -------------------------------------
>> @@ -2528,7 +2535,6 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zon
>>                 set_page_links(page, zone, nid, pfn);
>>                 init_page_count(page);
>>                 reset_page_mapcount(page);
>> -               page_assign_page_cgroup(page, NULL);
>>                 SetPageReserved(page);
>>
>>                 /*
>> -------------------------------------
>> In this patch, the Author Hugh Dickins said 
>> "...memmap_init_zone doesn't need it either, ...
>> Linux assumes pointers in zeroed structures are NULL pointers."



>> But it seems it's not always the case, so we should check and initialize
>> page->cgroup anyways.
>>

The comment from Hugh is correct, which implies that in this case page->cgroup
is not zeroed.

>> Signed-off-by: Shi Weihua <shiwh@cn.fujitsu.com> 
>> ---
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index 402a504..506d4cf 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -2518,6 +2518,7 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
>>  	struct page *page;
>>  	unsigned long end_pfn = start_pfn + size;
>>  	unsigned long pfn;
>> +	void *pc;
>>  
>>  	for (pfn = start_pfn; pfn < end_pfn; pfn++) {
>>  		/*
>> @@ -2535,6 +2536,9 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
>>  		set_page_links(page, zone, nid, pfn);
>>  		init_page_count(page);
>>  		reset_page_mapcount(page);
>> +		pc = page_get_page_cgroup(page);
>> +		if (pc) 
>> +			page_reset_bad_cgroup(page);
>>  		SetPageReserved(page);
>>  
> 
> hm, fishy.  Perhaps the architecture isn't zeroing the memmap arrays?
> 

The mem_map array should be cleared. I need to see the code to check where the
clearing takes place.

> Or perhaps that page was used and then later freed before we got to
> memmap_init_zone() and was freed with a non-zero ->page_cgroup.  Which is
> unlikely given that page.page_cgroup was only just added and is only
> present if CONFIG_CGROUP_MEM_RES_CTLR.

Please share your .config? Is this a kexec/kdump reboot by any chance?

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
