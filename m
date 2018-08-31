Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id D8A726B55D8
	for <linux-mm@kvack.org>; Fri, 31 Aug 2018 03:51:14 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id d18-v6so12652062qtj.20
        for <linux-mm@kvack.org>; Fri, 31 Aug 2018 00:51:14 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id m2-v6si5840210qtp.350.2018.08.31.00.51.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 31 Aug 2018 00:51:14 -0700 (PDT)
Subject: Re: [PATCH v1 2/5] mm/memory_hotplug: enforce section alignment when
 onlining/offlining
References: <20180816100628.26428-1-david@redhat.com>
 <20180816100628.26428-3-david@redhat.com>
 <772774b8-77d8-c09b-f933-5ce29be58fa9@microsoft.com>
From: David Hildenbrand <david@redhat.com>
Message-ID: <bd09cf13-6eba-ed06-5491-0d1e239c40c8@redhat.com>
Date: Fri, 31 Aug 2018 09:51:07 +0200
MIME-Version: 1.0
In-Reply-To: <772774b8-77d8-c09b-f933-5ce29be58fa9@microsoft.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pasha Tatashin <Pavel.Tatashin@microsoft.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Stephen Rothwell <sfr@canb.auug.org.au>, Pavel Tatashin <pasha.tatashin@oracle.com>, Kemi Wang <kemi.wang@intel.com>, David Rientjes <rientjes@google.com>, Jia He <jia.he@hxt-semitech.com>, Oscar Salvador <osalvador@suse.de>, Petr Tesarik <ptesarik@suse.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Dan Williams <dan.j.williams@intel.com>, Mathieu Malaterre <malat@debian.org>, Baoquan He <bhe@redhat.com>, Wei Yang <richard.weiyang@gmail.com>, Ross Zwisler <zwisler@kernel.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

On 31.08.2018 00:14, Pasha Tatashin wrote:
> Hi David,
> 
> I am not sure this is needed, because we already have a stricter checker:
> 
> check_hotplug_memory_range()
> 
> You could call it from online_pages(), if you think there is a reason to
> do it, but other than that it is done from add_memory_resource() and
> from remove_memory().

Hi,

As offline_pages() is called from a different location for ppc (and I
understand why but don't consider this clean) and I used both functions
in a prototype, believing they would work with pageblock_nr_pages, I
really think that we should at least drop the misleading check from
offline_pages() and better also add checks for check_hotplug_memory_range().

Thanks for having a look Pavel!

> 
> Thank you,
> Pavel
> 
> On 8/16/18 6:06 AM, David Hildenbrand wrote:
>> onlining/offlining code works on whole sections, so let's enforce that.
>> Existing code only allows to add memory in memory block size. And only
>> whole memory blocks can be onlined/offlined. Memory blocks are always
>> aligned to sections, so this should not break anything.
>>
>> online_pages/offline_pages will implicitly mark whole sections
>> online/offline, so the code really can only handle such granularities.
>>
>> (especially offlining code cannot deal with pageblock_nr_pages but
>>  theoretically only MAX_ORDER-1)
>>
>> Signed-off-by: David Hildenbrand <david@redhat.com>
>> ---
>>  mm/memory_hotplug.c | 10 +++++++---
>>  1 file changed, 7 insertions(+), 3 deletions(-)
>>
>> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
>> index 090cf474de87..30d2fa42b0bb 100644
>> --- a/mm/memory_hotplug.c
>> +++ b/mm/memory_hotplug.c
>> @@ -897,6 +897,11 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_typ
>>  	struct memory_notify arg;
>>  	struct memory_block *mem;
>>  
>> +	if (!IS_ALIGNED(pfn, PAGES_PER_SECTION))
>> +		return -EINVAL;
>> +	if (!IS_ALIGNED(nr_pages, PAGES_PER_SECTION))
>> +		return -EINVAL;
>> +
>>  	/*
>>  	 * We can't use pfn_to_nid() because nid might be stored in struct page
>>  	 * which is not yet initialized. Instead, we find nid from memory block.
>> @@ -1600,10 +1605,9 @@ int offline_pages(unsigned long start_pfn, unsigned long nr_pages)
>>  	struct zone *zone;
>>  	struct memory_notify arg;
>>  
>> -	/* at least, alignment against pageblock is necessary */
>> -	if (!IS_ALIGNED(start_pfn, pageblock_nr_pages))
>> +	if (!IS_ALIGNED(start_pfn, PAGES_PER_SECTION))
>>  		return -EINVAL;
>> -	if (!IS_ALIGNED(end_pfn, pageblock_nr_pages))
>> +	if (!IS_ALIGNED(nr_pages, PAGES_PER_SECTION))
>>  		return -EINVAL;
>>  	/* This makes hotplug much easier...and readable.
>>  	   we assume this for now. .*/


-- 

Thanks,

David / dhildenb
