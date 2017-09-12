Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1F2186B0038
	for <linux-mm@kvack.org>; Tue, 12 Sep 2017 13:05:46 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id m35so14053654qte.1
        for <linux-mm@kvack.org>; Tue, 12 Sep 2017 10:05:46 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a65sor4535758qkd.118.2017.09.12.10.05.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 12 Sep 2017 10:05:43 -0700 (PDT)
Subject: Re: [PATCH] mm/memory_hotplug: fix wrong casting for
 __remove_section()
References: <51a59ec3-e7ba-2562-1917-036b8181092c@gmail.com>
 <20170912124952.uraxdt5bgl25zhf7@dhcp22.suse.cz>
From: YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>
Message-ID: <587bdecd-2584-21be-94b8-61b427f1b0e8@gmail.com>
Date: Tue, 12 Sep 2017 13:05:39 -0400
MIME-Version: 1.0
In-Reply-To: <20170912124952.uraxdt5bgl25zhf7@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, qiuxishi@huawei.com, arbab@linux.vnet.ibm.com, Vlastimil Babka <vbabka@suse.cz>, yasu.isimatu@gmail.com

Hi Michal,

Thanks you for reviewing my patch.

On 09/12/2017 08:49 AM, Michal Hocko wrote:
> On Fri 08-09-17 16:43:04, YASUAKI ISHIMATSU wrote:
>> __remove_section() calls __remove_zone() to shrink zone and pgdat.
>> But due to wrong castings, __remvoe_zone() cannot shrink zone
>> and pgdat correctly if pfn is over 0xffffffff.
>>
>> So the patch fixes the following 3 wrong castings.
>>
>>   1. find_smallest_section_pfn() returns 0 or start_pfn which defined
>>      as unsigned long. But the function always returns 32bit value
>>      since the function is defined as int.
>>
>>   2. find_biggest_section_pfn() returns 0 or pfn which defined as
>>      unsigned long. the function always returns 32bit value
>>      since the function is defined as int.
> 
> this is indeed wrong. Pfns over would be really broken 15TB. Not that
> unrealistic these days

Why 15TB?

Actually, all callers use pfn which defined as unsigned long to receive
the return value of find_{smallest|biggest}_section_nr(). So it will break
over 16TB.

> 
>>
>>   3. __remove_section() calculates start_pfn using section_nr_to_pfn()
>>      and scn_nr. section_nr_to_pfn() just shifts scn_nr by
>>      PFN_SECTION_SHIFT bit. But since scn_nr is defined as int,
>>      section_nr_to_pfn() always return 32 bit value.
> 
> Dohh, those nasty macros. This is hidden quite well. It seems other
> callers are using unsigned long properly. But I would rather make sure
> we won't repeat that error again. Can we instead make section_nr_to_pfn
> resp. pfn_to_section_nr static inline and enfore proper types?

I'll update it.

> 
> I would also split this into two patches. 

I'll update it.

Thanks,
Yasuaki Ishimatsu

> 
> Thanks!
> 
>> The patch fixes the wrong castings.
>>
>> Signed-off-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
>> ---
>>  mm/memory_hotplug.c | 6 +++---
>>  1 file changed, 3 insertions(+), 3 deletions(-)
>>
>> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
>> index 73bf17d..3514ef2 100644
>> --- a/mm/memory_hotplug.c
>> +++ b/mm/memory_hotplug.c
>> @@ -331,7 +331,7 @@ int __ref __add_pages(int nid, unsigned long phys_start_pfn,
>>
>>  #ifdef CONFIG_MEMORY_HOTREMOVE
>>  /* find the smallest valid pfn in the range [start_pfn, end_pfn) */
>> -static int find_smallest_section_pfn(int nid, struct zone *zone,
>> +static unsigned long find_smallest_section_pfn(int nid, struct zone *zone,
>>  				     unsigned long start_pfn,
>>  				     unsigned long end_pfn)
>>  {
>> @@ -356,7 +356,7 @@ static int find_smallest_section_pfn(int nid, struct zone *zone,
>>  }
>>
>>  /* find the biggest valid pfn in the range [start_pfn, end_pfn). */
>> -static int find_biggest_section_pfn(int nid, struct zone *zone,
>> +static unsigned long find_biggest_section_pfn(int nid, struct zone *zone,
>>  				    unsigned long start_pfn,
>>  				    unsigned long end_pfn)
>>  {
>> @@ -544,7 +544,7 @@ static int __remove_section(struct zone *zone, struct mem_section *ms,
>>  		return ret;
>>
>>  	scn_nr = __section_nr(ms);
>> -	start_pfn = section_nr_to_pfn(scn_nr);
>> +	start_pfn = section_nr_to_pfn((unsigned long)scn_nr);
>>  	__remove_zone(zone, start_pfn);
>>
>>  	sparse_remove_one_section(zone, ms, map_offset);
>> -- 
>> 1.8.3.1
>>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
