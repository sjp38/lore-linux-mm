Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id B1276831F4
	for <linux-mm@kvack.org>; Fri, 19 May 2017 03:21:23 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id 139so13333866wmf.5
        for <linux-mm@kvack.org>; Fri, 19 May 2017 00:21:23 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h19si13922209wme.113.2017.05.19.00.21.21
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 19 May 2017 00:21:22 -0700 (PDT)
Subject: Re: [PATCH 07/14] mm: consider zone which is not fully populated to
 have holes
References: <20170515085827.16474-1-mhocko@kernel.org>
 <20170515085827.16474-8-mhocko@kernel.org>
 <ae859e14-bf82-ae37-9c85-d4b31ce89b0a@suse.cz>
 <20170518164210.GD18333@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <3d5d4d0b-bc5e-dbb5-de68-f4ea31abb38c@suse.cz>
Date: Fri, 19 May 2017 09:21:20 +0200
MIME-Version: 1.0
In-Reply-To: <20170518164210.GD18333@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>

On 05/18/2017 06:42 PM, Michal Hocko wrote:
> On Thu 18-05-17 18:14:39, Vlastimil Babka wrote:
>> On 05/15/2017 10:58 AM, Michal Hocko wrote:
> [...]
>>>  #ifdef CONFIG_MEMORY_HOTPLUG
>>> +/*
>>> + * Return page for the valid pfn only if the page is online. All pfn
>>> + * walkers which rely on the fully initialized page->flags and others
>>> + * should use this rather than pfn_valid && pfn_to_page
>>> + */
>>> +#define pfn_to_online_page(pfn)				\
>>> +({							\
>>> +	struct page *___page = NULL;			\
>>> +							\
>>> +	if (online_section_nr(pfn_to_section_nr(pfn)))	\
>>> +		___page = pfn_to_page(pfn);		\
>>> +	___page;					\
>>> +})
>>
>> This seems to be already assuming pfn_valid() to be true. There's no
>> "pfn_to_section_nr(pfn) >= NR_MEM_SECTIONS" check and the comment
>> suggests as such, but...
> 
> Yes, we should check the validity of the section number. We do not have
> to check whether the section is valid because online sections are a
> subset of those that are valid.
> 
>>> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
>>> index 05796ee974f7..c3a146028ba6 100644
>>> --- a/mm/memory_hotplug.c
>>> +++ b/mm/memory_hotplug.c
>>> @@ -929,6 +929,9 @@ static int online_pages_range(unsigned long start_pfn, unsigned long nr_pages,
>>>  	unsigned long i;
>>>  	unsigned long onlined_pages = *(unsigned long *)arg;
>>>  	struct page *page;
>>> +
>>> +	online_mem_sections(start_pfn, start_pfn + nr_pages);
>>
>> Shouldn't this be moved *below* the loop that initializes struct pages?
>> In the offline case you do mark sections offline before "tearing" struct
>> pages, so that should be symmetric.
> 
> You are right! Andrew, could you fold the following intot the patch?
> ---
> From 0550b61203d6970b47fd79f5e6372dccd143cbec Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.com>
> Date: Thu, 18 May 2017 18:38:24 +0200
> Subject: [PATCH] fold me "mm: consider zone which is not fully populated to
>  have holes"
> 
> - check valid section number in pfn_to_online_page - Vlastimil
> - mark sections online after all struct pages are initialized in
>   online_pages_range - Vlastimil
> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Both the patch and fix:

Acked-by: Vlastimil Babka <vbabka@suse.cz>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
