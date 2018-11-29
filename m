Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2A44A6B553F
	for <linux-mm@kvack.org>; Thu, 29 Nov 2018 18:57:03 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id z10so1956207edz.15
        for <linux-mm@kvack.org>; Thu, 29 Nov 2018 15:57:03 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c21-v6sor1105526ejb.22.2018.11.29.15.57.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 29 Nov 2018 15:57:01 -0800 (PST)
Date: Thu, 29 Nov 2018 23:57:00 +0000
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH v3 2/2] mm, sparse: pass nid instead of pgdat to
 sparse_add_one_section()
Message-ID: <20181129235700.fatwngi43gjvhvya@master>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20181128091243.19249-1-richard.weiyang@gmail.com>
 <20181129155316.8174-1-richard.weiyang@gmail.com>
 <20181129155316.8174-2-richard.weiyang@gmail.com>
 <20181129171542.GX6923@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181129171542.GX6923@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: Wei Yang <richard.weiyang@gmail.com>, dave.hansen@intel.com, osalvador@suse.de, david@redhat.com, akpm@linux-foundation.org, linux-mm@kvack.org

On Thu, Nov 29, 2018 at 06:15:42PM +0100, Michal Hocko wrote:
>On Thu 29-11-18 23:53:16, Wei Yang wrote:
>> Since the information needed in sparse_add_one_section() is node id to
>> allocate proper memory, it is not necessary to pass its pgdat.
>> 
>> This patch changes the prototype of sparse_add_one_section() to pass
>> node id directly. This is intended to reduce misleading that
>> sparse_add_one_section() would touch pgdat.
>> 
>> Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
>
>>>From a quick look, this looks ok.
>
>Acked-by: Michal Hocko <mhocko@suse.com>
>
>Thanks for splitting up it from the original patch.
>

Thanks for your suggestion.

>> ---
>>  include/linux/memory_hotplug.h | 2 +-
>>  mm/memory_hotplug.c            | 2 +-
>>  mm/sparse.c                    | 6 +++---
>>  3 files changed, 5 insertions(+), 5 deletions(-)
>> 
>> diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
>> index 45a5affcab8a..3787d4e913e6 100644
>> --- a/include/linux/memory_hotplug.h
>> +++ b/include/linux/memory_hotplug.h
>> @@ -333,7 +333,7 @@ extern void move_pfn_range_to_zone(struct zone *zone, unsigned long start_pfn,
>>  		unsigned long nr_pages, struct vmem_altmap *altmap);
>>  extern int offline_pages(unsigned long start_pfn, unsigned long nr_pages);
>>  extern bool is_memblock_offlined(struct memory_block *mem);
>> -extern int sparse_add_one_section(struct pglist_data *pgdat,
>> +extern int sparse_add_one_section(int nid,
>>  		unsigned long start_pfn, struct vmem_altmap *altmap);
>>  extern void sparse_remove_one_section(struct zone *zone, struct mem_section *ms,
>>  		unsigned long map_offset, struct vmem_altmap *altmap);
>> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
>> index f626e7e5f57b..5b3a3d7b4466 100644
>> --- a/mm/memory_hotplug.c
>> +++ b/mm/memory_hotplug.c
>> @@ -253,7 +253,7 @@ static int __meminit __add_section(int nid, unsigned long phys_start_pfn,
>>  	if (pfn_valid(phys_start_pfn))
>>  		return -EEXIST;
>>  
>> -	ret = sparse_add_one_section(NODE_DATA(nid), phys_start_pfn, altmap);
>> +	ret = sparse_add_one_section(nid, phys_start_pfn, altmap);
>>  	if (ret < 0)
>>  		return ret;
>>  
>> diff --git a/mm/sparse.c b/mm/sparse.c
>> index 5825f276485f..2472bf23278a 100644
>> --- a/mm/sparse.c
>> +++ b/mm/sparse.c
>> @@ -662,7 +662,7 @@ static void free_map_bootmem(struct page *memmap)
>>   * set.  If this is <=0, then that means that the passed-in
>>   * map was not consumed and must be freed.
>>   */
>> -int __meminit sparse_add_one_section(struct pglist_data *pgdat,
>> +int __meminit sparse_add_one_section(int nid,
>>  		unsigned long start_pfn, struct vmem_altmap *altmap)
>>  {
>>  	unsigned long section_nr = pfn_to_section_nr(start_pfn);
>> @@ -675,11 +675,11 @@ int __meminit sparse_add_one_section(struct pglist_data *pgdat,
>>  	 * no locking for this, because it does its own
>>  	 * plus, it does a kmalloc
>>  	 */
>> -	ret = sparse_index_init(section_nr, pgdat->node_id);
>> +	ret = sparse_index_init(section_nr, nid);
>>  	if (ret < 0 && ret != -EEXIST)
>>  		return ret;
>>  	ret = 0;
>> -	memmap = kmalloc_section_memmap(section_nr, pgdat->node_id, altmap);
>> +	memmap = kmalloc_section_memmap(section_nr, nid, altmap);
>>  	if (!memmap)
>>  		return -ENOMEM;
>>  	usemap = __kmalloc_section_usemap();
>> -- 
>> 2.15.1
>> 
>
>-- 
>Michal Hocko
>SUSE Labs

-- 
Wei Yang
Help you, Help me
