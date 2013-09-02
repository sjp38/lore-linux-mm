Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id 4F14C6B0032
	for <linux-mm@kvack.org>; Mon,  2 Sep 2013 13:47:20 -0400 (EDT)
Received: from /spool/local
	by e28smtp04.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Mon, 2 Sep 2013 23:08:57 +0530
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id 2C3CC1258052
	for <linux-mm@kvack.org>; Mon,  2 Sep 2013 23:17:06 +0530 (IST)
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r82HmsGB29884502
	for <linux-mm@kvack.org>; Mon, 2 Sep 2013 23:18:55 +0530
Received: from d28av04.in.ibm.com (localhost [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r82Hl8WE027744
	for <linux-mm@kvack.org>; Mon, 2 Sep 2013 23:17:09 +0530
Message-ID: <5224CE37.2070908@linux.vnet.ibm.com>
Date: Mon, 02 Sep 2013 23:13:19 +0530
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH v3 04/35] mm: Initialize node memory regions during
 boot
References: <20130830131221.4947.99764.stgit@srivatsabhat.in.ibm.com> <20130830131504.4947.86008.stgit@srivatsabhat.in.ibm.com> <52242E1D.4020406@jp.fujitsu.com>
In-Reply-To: <52242E1D.4020406@jp.fujitsu.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Cc: akpm@linux-foundation.org, mgorman@suse.de, hannes@cmpxchg.org, tony.luck@intel.com, matthew.garrett@nebula.com, dave@sr71.net, riel@redhat.com, arjan@linux.intel.com, srinivas.pandruvada@linux.intel.com, willy@linux.intel.com, kamezawa.hiroyu@jp.fujitsu.com, lenb@kernel.org, rjw@sisk.pl, gargankita@gmail.com, paulmck@linux.vnet.ibm.com, svaidy@linux.vnet.ibm.com, andi@firstfloor.org, santosh.shilimkar@ti.com, kosaki.motohiro@gmail.com, linux-pm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 09/02/2013 11:50 AM, Yasuaki Ishimatsu wrote:
> (2013/08/30 22:15), Srivatsa S. Bhat wrote:
>> Initialize the node's memory-regions structures with the information
>> about
>> the region-boundaries, at boot time.
>>
>> Based-on-patch-by: Ankita Garg <gargankita@gmail.com>
>> Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
>> ---
>>
>>   include/linux/mm.h |    4 ++++
>>   mm/page_alloc.c    |   28 ++++++++++++++++++++++++++++
>>   2 files changed, 32 insertions(+)
>>
>> diff --git a/include/linux/mm.h b/include/linux/mm.h
>> index f022460..18fdec4 100644
>> --- a/include/linux/mm.h
>> +++ b/include/linux/mm.h
>> @@ -627,6 +627,10 @@ static inline pte_t maybe_mkwrite(pte_t pte,
>> struct vm_area_struct *vma)
>>   #define LAST_NID_MASK        ((1UL << LAST_NID_WIDTH) - 1)
>>   #define ZONEID_MASK        ((1UL << ZONEID_SHIFT) - 1)
>>
>> +/* Hard-code memory region size to be 512 MB for now. */
>> +#define MEM_REGION_SHIFT    (29 - PAGE_SHIFT)
>> +#define MEM_REGION_SIZE        (1UL << MEM_REGION_SHIFT)
>> +
>>   static inline enum zone_type page_zonenum(const struct page *page)
>>   {
>>       return (page->flags >> ZONES_PGSHIFT) & ZONES_MASK;
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index b86d7e3..bb2d5d4 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -4809,6 +4809,33 @@ static void __init_refok
>> alloc_node_mem_map(struct pglist_data *pgdat)
>>   #endif /* CONFIG_FLAT_NODE_MEM_MAP */
>>   }
>>
>> +static void __meminit init_node_memory_regions(struct pglist_data
>> *pgdat)
>> +{
>> +    int nid = pgdat->node_id;
>> +    unsigned long start_pfn = pgdat->node_start_pfn;
>> +    unsigned long end_pfn = start_pfn + pgdat->node_spanned_pages;
>> +    struct node_mem_region *region;
>> +    unsigned long i, absent;
>> +    int idx;
>> +
>> +    for (i = start_pfn, idx = 0; i < end_pfn;
>> +                i += region->spanned_pages, idx++) {
>> +
> 
>> +        region = &pgdat->node_regions[idx];
> 
> It seems that overflow easily occurs.
> node_regions[] has 256 entries and MEM_REGION_SIZE is 512MiB. So if
> the pgdat has more than 128 GiB, overflow will occur. Am I wrong?
>

No, you are right. It should be made dynamic to accommodate larger
memory. I just used that value as a placeholder, since my focus was to
demonstrate what algorithms and designs could be developed on top of
this infrastructure, to help shape memory allocations. But certainly
this needs to be modified to be flexible enough to work with any memory
size. Thank you for your review!

Regards,
Srivatsa S. Bhat
 
> 
>> +        region->pgdat = pgdat;
>> +        region->start_pfn = i;
>> +        region->spanned_pages = min(MEM_REGION_SIZE, end_pfn - i);
>> +        region->end_pfn = region->start_pfn + region->spanned_pages;
>> +
>> +        absent = __absent_pages_in_range(nid, region->start_pfn,
>> +                         region->end_pfn);
>> +
>> +        region->present_pages = region->spanned_pages - absent;
>> +    }
>> +
>> +    pgdat->nr_node_regions = idx;
>> +}
>> +
>>   void __paginginit free_area_init_node(int nid, unsigned long
>> *zones_size,
>>           unsigned long node_start_pfn, unsigned long *zholes_size)
>>   {
>> @@ -4837,6 +4864,7 @@ void __paginginit free_area_init_node(int nid,
>> unsigned long *zones_size,
>>
>>       free_area_init_core(pgdat, start_pfn, end_pfn,
>>                   zones_size, zholes_size);
>> +    init_node_memory_regions(pgdat);
>>   }
>>
>>   #ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
>>
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
