Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 2D43A6B0031
	for <linux-mm@kvack.org>; Sat,  5 Oct 2013 02:52:25 -0400 (EDT)
Received: by mail-pd0-f173.google.com with SMTP id p10so4939600pdj.4
        for <linux-mm@kvack.org>; Fri, 04 Oct 2013 23:52:24 -0700 (PDT)
Received: by mail-pd0-f179.google.com with SMTP id v10so4939915pde.24
        for <linux-mm@kvack.org>; Fri, 04 Oct 2013 23:52:22 -0700 (PDT)
Message-ID: <524FB719.30502@gmail.com>
Date: Sat, 05 Oct 2013 14:52:09 +0800
From: Zhang Yanfei <zhangyanfei.yes@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] mm/sparsemem: Fix a bug in free_map_bootmem when
 CONFIG_SPARSEMEM_VMEMMAP
References: <524CE4C1.8060508@gmail.com> <524CE532.1030001@gmail.com> <524fa9a0.a5e8420a.188e.5eb1SMTPIN_ADDED_BROKEN@mx.google.com>
In-Reply-To: <524fa9a0.a5e8420a.188e.5eb1SMTPIN_ADDED_BROKEN@mx.google.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Wen Congyang <wency@cn.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>, Toshi Kani <toshi.kani@hp.com>, isimatu.yasuaki@jp.fujitsu.com, Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

Hello wanpeng,

On 10/05/2013 01:54 PM, Wanpeng Li wrote:
> Hi Yanfei,
> On Thu, Oct 03, 2013 at 11:32:02AM +0800, Zhang Yanfei wrote:
>> From: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
>>
>> We pass the number of pages which hold page structs of a memory
>> section to function free_map_bootmem. This is right when
>> !CONFIG_SPARSEMEM_VMEMMAP but wrong when CONFIG_SPARSEMEM_VMEMMAP.
>> When CONFIG_SPARSEMEM_VMEMMAP, we should pass the number of pages
>> of a memory section to free_map_bootmem.
>>
>> So the fix is removing the nr_pages parameter. When
>> CONFIG_SPARSEMEM_VMEMMAP, we directly use the prefined marco
>> PAGES_PER_SECTION in free_map_bootmem. When !CONFIG_SPARSEMEM_VMEMMAP,
>> we calculate page numbers needed to hold the page structs for a
>> memory section and use the value in free_map_bootmem.
>>
>> Signed-off-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
>> ---
>> mm/sparse.c |   17 +++++++----------
>> 1 files changed, 7 insertions(+), 10 deletions(-)
>>
>> diff --git a/mm/sparse.c b/mm/sparse.c
>> index fbb9dbc..908c134 100644
>> --- a/mm/sparse.c
>> +++ b/mm/sparse.c
>> @@ -603,10 +603,10 @@ static void __kfree_section_memmap(struct page *memmap)
>> 	vmemmap_free(start, end);
>> }
>> #ifdef CONFIG_MEMORY_HOTREMOVE
>> -static void free_map_bootmem(struct page *memmap, unsigned long nr_pages)
>> +static void free_map_bootmem(struct page *memmap)
>> {
>> 	unsigned long start = (unsigned long)memmap;
>> -	unsigned long end = (unsigned long)(memmap + nr_pages);
>> +	unsigned long end = (unsigned long)(memmap + PAGES_PER_SECTION);
>>
>> 	vmemmap_free(start, end);
>> }
>> @@ -648,11 +648,13 @@ static void __kfree_section_memmap(struct page *memmap)
>> }
>>
>> #ifdef CONFIG_MEMORY_HOTREMOVE
>> -static void free_map_bootmem(struct page *memmap, unsigned long nr_pages)
>> +static void free_map_bootmem(struct page *memmap)
>> {
>> 	unsigned long maps_section_nr, removing_section_nr, i;
>> 	unsigned long magic;
>> 	struct page *page = virt_to_page(memmap);
>> +	unsigned long nr_pages = get_order(sizeof(struct page) *
>> +					   PAGES_PER_SECTION);
> 
> Why replace PAGE_ALIGN(XXX) >> PAGE_SHIFT by get_order(XXX)? This will result 
> in memory leak.

oops... I will correct this by sending a new version.

Thanks.


-- 
Thanks.
Zhang Yanfei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
