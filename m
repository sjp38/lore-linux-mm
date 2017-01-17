Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id 200186B0033
	for <linux-mm@kvack.org>; Tue, 17 Jan 2017 09:03:54 -0500 (EST)
Received: by mail-ot0-f197.google.com with SMTP id s36so41866476otd.3
        for <linux-mm@kvack.org>; Tue, 17 Jan 2017 06:03:54 -0800 (PST)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id j18si9486579oih.336.2017.01.17.06.03.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 17 Jan 2017 06:03:53 -0800 (PST)
Message-ID: <587E22F2.7060809@huawei.com>
Date: Tue, 17 Jan 2017 21:58:10 +0800
From: zhong jiang <zhongjiang@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: respect pre-allocated storage mapping for memmap
References: <1484573885-54353-1-git-send-email-zhongjiang@huawei.com> <20170117102532.GH19699@dhcp22.suse.cz>
In-Reply-To: <20170117102532.GH19699@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: dan.j.williams@intel.com, hannes@cmpxchg.org, linux-mm@kvack.org

On 2017/1/17 18:25, Michal Hocko wrote:
> On Mon 16-01-17 21:38:05, zhongjiang wrote:
>> From: zhong jiang <zhongjiang@huawei.com>
>>
>> At present, we skip the reservation storage by the driver for
>> the zone_dvice. but the free pages set aside for the memmap is
>> ignored. And since the free pages is only used as the memmap,
>> so we can also skip the corresponding pages.
> I have really hard time to understand what this patch does and why it
> matters.  Could you please rephrase the changelog to state, the problem,
> how it affects users and what is the fix please?
>  
  Hi, Michal
 
  The patch maybe incorrect if free pages for memmap mapping is accouted for zone_device.
  I am just a little confusing about the implement.  it maybe simple and  stupid.

  first pfn for dev_mappage come from vmem_altmap_offset, and free pages reserved for
  memmap mapping need to be accounted. I do not know the meaning.

  Another issue is in sparse_remove_one_section.  A section belongs to  zone_device is not
  always need to consider the  map_offset. is it right ?  From pfn_first to end , that section
  should no need to consider the map_offet.

  Thanks
  zhongjiang
 
>> Signed-off-by: zhong jiang <zhongjiang@huawei.com>
>> ---
>>  mm/page_alloc.c | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index d604d25..51d8d03 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -5047,7 +5047,7 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
>>  	 * memory
>>  	 */
>>  	if (altmap && start_pfn == altmap->base_pfn)
>> -		start_pfn += altmap->reserve;
>> +		start_pfn += vmem_altmap_offset(altmap);
>>  
>>  	for (pfn = start_pfn; pfn < end_pfn; pfn++) {
>>  		/*
>> -- 
>> 1.8.3.1
>>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
