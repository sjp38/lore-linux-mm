Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 70AFB6B02C3
	for <linux-mm@kvack.org>; Tue, 27 Jun 2017 02:59:54 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id u18so17533193pfa.8
        for <linux-mm@kvack.org>; Mon, 26 Jun 2017 23:59:54 -0700 (PDT)
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id s78si1389710pfj.114.2017.06.26.23.59.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Jun 2017 23:59:53 -0700 (PDT)
Subject: Re: [RFC PATCH 2/4] mm/hotplug: walk_memroy_range on memory_block uit
References: <20170625025227.45665-1-richard.weiyang@gmail.com>
 <20170625025227.45665-3-richard.weiyang@gmail.com>
 <eeb06db0-086a-29f9-306d-a702984594df@nvidia.com>
 <20170626234038.GD53180@WeideMacBook-Pro.local>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <3ad226f5-92f1-352a-d7ee-159eef5d60e3@nvidia.com>
Date: Mon, 26 Jun 2017 23:59:52 -0700
MIME-Version: 1.0
In-Reply-To: <20170626234038.GD53180@WeideMacBook-Pro.local>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: mhocko@suse.com, linux-mm@kvack.org

On 06/26/2017 04:40 PM, Wei Yang wrote:
> On Mon, Jun 26, 2017 at 12:32:40AM -0700, John Hubbard wrote:
>> On 06/24/2017 07:52 PM, Wei Yang wrote:
[...]
>>
>> Why is it safe to assume no holes in the memory range? (Maybe Michal's 
>> patch already covered this and I haven't got that far yet?)
>>
>> The documentation for this routine says that it walks through all
>> present memory sections in the range, so it seems like this patch
>> breaks that.
>>
> 
> Hmm... it is a little bit hard to describe.
> 
> First the documentation of the function is a little misleading. When you look
> at the code, it call the "func" only once for a memory_block, not for every
> present mem_section as it says. So have some memory in the memory_block would
> meet the requirement.
> 
> Second, after the check in patch 1, it is for sure the range is memory_block
> aligned, which means it must have some memory in that memory_block. It would
> be strange if someone claim to add a memory range but with no real memory.
> 
> This is why I remove the check here.

OK. In that case, it seems like we should update the function documentation
to match. Something like this, maybe? :

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index bdaafcf46f49..d36b2f4eaf39 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1872,14 +1872,14 @@ int offline_pages(unsigned long start_pfn, unsigned long nr_pages)
 #endif /* CONFIG_MEMORY_HOTREMOVE */
 
 /**
- * walk_memory_range - walks through all mem sections in [start_pfn, end_pfn)
+ * walk_memory_range - walks through all mem blocks in [start_pfn, end_pfn)
  * @start_pfn: start pfn of the memory range
  * @end_pfn: end pfn of the memory range
  * @arg: argument passed to func
- * @func: callback for each memory section walked
+ * @func: callback for each memory block walked
  *
- * This function walks through all present mem sections in range
- * [start_pfn, end_pfn) and call func on each mem section.
+ * This function walks through all mem blocks in the range
+ * [start_pfn, end_pfn) and calls func on each mem block.
  *
  * Returns the return value of func.
  */


thanks,
john h

> 
> 
>>>  
>>>  		section = __nr_to_section(section_nr);
>>> -		/* same memblock? */
>>> -		if (mem)
>>> -			if ((section_nr >= mem->start_section_nr) &&
>>> -			    (section_nr <= mem->end_section_nr))
>>> -				continue;
>>
>> Yes, that deletion looks good.
>>
> 
> From this we can see, if there IS some memory, the function will be invoked
> and only invoked once.
> 
>> thanks,
>> john h
>>
>>>  
>>>  		mem = find_memory_block_hinted(section, mem);
>>>  		if (!mem)
>>>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
