Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2ACD96B0279
	for <linux-mm@kvack.org>; Tue, 27 Jun 2017 02:47:40 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id o62so20297551pga.0
        for <linux-mm@kvack.org>; Mon, 26 Jun 2017 23:47:40 -0700 (PDT)
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id d68si1384578pgc.271.2017.06.26.23.47.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Jun 2017 23:47:39 -0700 (PDT)
Subject: Re: [RFC PATCH 3/4] mm/hotplug: make __add_pages() iterate on
 memory_block and split __add_section()
References: <20170625025227.45665-1-richard.weiyang@gmail.com>
 <20170625025227.45665-4-richard.weiyang@gmail.com>
 <559864c6-6ad6-297a-3094-8abecbd251b9@nvidia.com>
 <20170626235312.GE53180@WeideMacBook-Pro.local>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <0b9439b4-0891-6596-f103-daaceaa7f404@nvidia.com>
Date: Mon, 26 Jun 2017 23:47:38 -0700
MIME-Version: 1.0
In-Reply-To: <20170626235312.GE53180@WeideMacBook-Pro.local>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: mhocko@suse.com, linux-mm@kvack.org

On 06/26/2017 04:53 PM, Wei Yang wrote:
> On Mon, Jun 26, 2017 at 12:50:14AM -0700, John Hubbard wrote:
>> On 06/24/2017 07:52 PM, Wei Yang wrote:
[...]
>>
>> Things have changed...the register_new_memory() routine is accepting a single section,
>> but instead of registering just that section, it is registering a containing block.
>> (That works, because apparently the approach is to make sections_per_block == 1,
>> and eventually kill sections, if I am reading all this correctly.)
>>
> 
> The original function is a little confusing. Actually it tries to register a
> memory_block while it register it for several times, on each present
> mem_section actually.
> 
> This change here will register the whole memory_block at once.
> 
> You would see in next patch it will accept the start section number instead of
> a section, while maybe more easy to understand it.

Yes I saw that, and it does help, but even after that, I still thought
we should add that "* Register an entire memory_block."  line.

> 
> BTW, I don't get your point on kill sections when sections_per_block == The
> original function is a little confusing. Actually it tries to register a
> memory_block while it register it for several times, on each present
> mem_section actually.
> 
> This change here will register the whole memory_block at once.
> 
> You would see in next patch it will accept the start section number instead of
> a section, while maybe more easy to understand it.
> 
> BTW, I don't get your point on kill sections when sections_per_block == 1.
> Would you rephrase this?
> 

I was just trying to say, "if I understand correctly, your plan is
to:

   Step 1: have one section per block, and then eventually

   Step 2: get rid of sections (that's what "kill" meant) entirely."

No big deal, I'm just saying it out loud, to be sure I've got it right.

thanks,
john h

>> So, how about this: let's add a line to the function comment: 
>>
>> * Register an entire memory_block.
>>
> 
> May look good, let me have a try.
> 
>> That makes it clearer that we're dealing in blocks, even though the memsection*
>> argument is passed in.
>>
>>>  
>>> -	if (mem->section_count == sections_per_block)
>>> -		ret = register_mem_sect_under_node(mem, nid);
>>> +	ret = register_mem_sect_under_node(mem, nid);
>>>  out:
>>>  	mutex_unlock(&mem_sysfs_mutex);
>>>  	return ret;
>>> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
>>> index a79a83ec965f..14a08b980b59 100644
>>> --- a/mm/memory_hotplug.c
>>> +++ b/mm/memory_hotplug.c
>>> @@ -302,8 +302,7 @@ void __init register_page_bootmem_info_node(struct pglist_data *pgdat)
>>>  }
>>>  #endif /* CONFIG_HAVE_BOOTMEM_INFO_NODE */
>>>  
>>> -static int __meminit __add_section(int nid, unsigned long phys_start_pfn,
>>> -		bool want_memblock)
>>> +static int __meminit __add_section(int nid, unsigned long phys_start_pfn)
>>>  {
>>>  	int ret;
>>>  	int i;
>>> @@ -332,6 +331,18 @@ static int __meminit __add_section(int nid, unsigned long phys_start_pfn,
>>>  		SetPageReserved(page);
>>>  	}
>>>  
>>> +	return 0;
>>> +}
>>> +
>>> +static int __meminit __add_memory_block(int nid, unsigned long phys_start_pfn,
>>> +		bool want_memblock)
>>> +{
>>> +	int ret;
>>> +
>>> +	ret = __add_section(nid, phys_start_pfn);
>>> +	if (ret)
>>> +		return ret;
>>> +
>>>  	if (!want_memblock)
>>>  		return 0;
>>>  
>>> @@ -347,15 +358,10 @@ static int __meminit __add_section(int nid, unsigned long phys_start_pfn,
>>>  int __ref __add_pages(int nid, unsigned long phys_start_pfn,
>>>  			unsigned long nr_pages, bool want_memblock)
>>>  {
>>> -	unsigned long i;
>>> +	unsigned long pfn;
>>>  	int err = 0;
>>> -	int start_sec, end_sec;
>>>  	struct vmem_altmap *altmap;
>>>  
>>> -	/* during initialize mem_map, align hot-added range to section */
>>> -	start_sec = pfn_to_section_nr(phys_start_pfn);
>>> -	end_sec = pfn_to_section_nr(phys_start_pfn + nr_pages - 1);
>>> -
>>>  	altmap = to_vmem_altmap((unsigned long) pfn_to_page(phys_start_pfn));
>>>  	if (altmap) {
>>>  		/*
>>> @@ -370,8 +376,9 @@ int __ref __add_pages(int nid, unsigned long phys_start_pfn,
>>>  		altmap->alloc = 0;
>>>  	}
>>>  
>>> -	for (i = start_sec; i <= end_sec; i++) {
>>> -		err = __add_section(nid, section_nr_to_pfn(i), want_memblock);
>>> +	for (pfn; pfn < phys_start_pfn + nr_pages;
>>> +			pfn += sections_per_block * PAGES_PER_SECTION) {
>>
> 
> yep
> 
>> A pages_per_block variable would be nice here, too.
>>
>> thanks,
>> john h
>>
>>> +		err = __add_memory_block(nid, pfn, want_memblock);
>>>  
>>>  		/*
>>>  		 * EEXIST is finally dealt with by ioresource collision
>>>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
