Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id E97396B0292
	for <linux-mm@kvack.org>; Mon, 26 Jun 2017 02:49:23 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id j186so106428908pge.12
        for <linux-mm@kvack.org>; Sun, 25 Jun 2017 23:49:23 -0700 (PDT)
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id s144si8346098pgs.186.2017.06.25.23.49.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 25 Jun 2017 23:49:23 -0700 (PDT)
Subject: Re: [RFC PATCH 1/4] mm/hotplug: aligne the hotplugable range with
 memory_block
References: <20170625025227.45665-1-richard.weiyang@gmail.com>
 <20170625025227.45665-2-richard.weiyang@gmail.com>
 <be965d3a-002b-9a9f-873b-b7237238ac21@nvidia.com>
 <20170626002006.GA47120@WeideMacBook-Pro.local>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <35dd30c8-b31d-b8da-903a-0ea7eafb7e04@nvidia.com>
Date: Sun, 25 Jun 2017 23:49:21 -0700
MIME-Version: 1.0
In-Reply-To: <20170626002006.GA47120@WeideMacBook-Pro.local>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: mhocko@suse.com, linux-mm@kvack.org

On 06/25/2017 05:20 PM, Wei Yang wrote:
> * PGP Signed by an unknown key
> 
> On Sat, Jun 24, 2017 at 08:31:20PM -0700, John Hubbard wrote:
>> On 06/24/2017 07:52 PM, Wei Yang wrote:
>>> memory hotplug is memory block aligned instead of section aligned.
>>>
>>> This patch fix the range check during hotplug.
>>>
>>> Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
>>> ---
>>>  drivers/base/memory.c  | 3 ++-
>>>  include/linux/memory.h | 2 ++
>>>  mm/memory_hotplug.c    | 9 +++++----
>>>  3 files changed, 9 insertions(+), 5 deletions(-)
>>>
>>> diff --git a/drivers/base/memory.c b/drivers/base/memory.c
>>> index c7c4e0325cdb..b54cfe9cd98b 100644
>>> --- a/drivers/base/memory.c
>>> +++ b/drivers/base/memory.c
>>> @@ -31,7 +31,8 @@ static DEFINE_MUTEX(mem_sysfs_mutex);
>>>  
>>>  #define to_memory_block(dev) container_of(dev, struct memory_block, dev)
>>>  
>>> -static int sections_per_block;
>>> +int sections_per_block;
>>> +EXPORT_SYMBOL(sections_per_block);
>>
>> Hi Wei,
>>
>> Is sections_per_block ever assigned a value? I am not seeing that happen,
>> either in this patch, or in the larger patchset.
>>
> 
> This is assigned in memory_dev_init(). Not in my patch.
> 

ah, there it is, thanks. (I misread the diff slightly and thought you were adding that
variable, but I see it's actually been there forever.)  

thanks
john h

>>
>>>  
>>>  static inline int base_memory_block_id(int section_nr)
>>>  {
>>> diff --git a/include/linux/memory.h b/include/linux/memory.h
>>> index b723a686fc10..51a6355aa56d 100644
>>> --- a/include/linux/memory.h
>>> +++ b/include/linux/memory.h
>>> @@ -142,4 +142,6 @@ extern struct memory_block *find_memory_block(struct mem_section *);
>>>   */
>>>  extern struct mutex text_mutex;
>>>  
>>> +extern int sections_per_block;
>>> +
>>>  #endif /* _LINUX_MEMORY_H_ */
>>> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
>>> index 387ca386142c..f5d06afc8645 100644
>>> --- a/mm/memory_hotplug.c
>>> +++ b/mm/memory_hotplug.c
>>> @@ -1183,11 +1183,12 @@ static int check_hotplug_memory_range(u64 start, u64 size)
>>>  {
>>>  	u64 start_pfn = PFN_DOWN(start);
>>>  	u64 nr_pages = size >> PAGE_SHIFT;
>>> +	u64 page_per_block = sections_per_block * PAGES_PER_SECTION;
>>
>> "pages_per_block" would be a little better.
>>
>> Also, in the first line of the commit, s/aligne/align/.
> 
> Good, thanks.
> 
>>
>> thanks,
>> john h
>>
>>>  
>>> -	/* Memory range must be aligned with section */
>>> -	if ((start_pfn & ~PAGE_SECTION_MASK) ||
>>> -	    (nr_pages % PAGES_PER_SECTION) || (!nr_pages)) {
>>> -		pr_err("Section-unaligned hotplug range: start 0x%llx, size 0x%llx\n",
>>> +	/* Memory range must be aligned with memory_block */
>>> +	if ((start_pfn & (page_per_block - 1)) ||
>>> +	    (nr_pages % page_per_block) || (!nr_pages)) {
>>> +		pr_err("Memory_block-unaligned hotplug range: start 0x%llx, size 0x%llx\n",
>>>  				(unsigned long long)start,
>>>  				(unsigned long long)size);
>>>  		return -EINVAL;
>>>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
