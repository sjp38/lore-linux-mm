Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4A3E76B059C
	for <linux-mm@kvack.org>; Thu,  8 Nov 2018 03:19:59 -0500 (EST)
Received: by mail-ot1-f72.google.com with SMTP id p29so5577951ote.3
        for <linux-mm@kvack.org>; Thu, 08 Nov 2018 00:19:59 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id z45si1550392otz.301.2018.11.08.00.19.57
        for <linux-mm@kvack.org>;
        Thu, 08 Nov 2018 00:19:58 -0800 (PST)
Subject: Re: [RFC PATCH 5/5] mm, memory_hotplug: be more verbose for memory
 offline failures
References: <20181107101830.17405-1-mhocko@kernel.org>
 <20181107101830.17405-6-mhocko@kernel.org>
 <b23ebcb3-e4f1-be78-bd5f-84c685979ab7@arm.com>
 <20181108081231.GN27423@dhcp22.suse.cz>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <807cde15-a083-e8ae-4bd0-5f83f4b02b6a@arm.com>
Date: Thu, 8 Nov 2018 13:49:52 +0530
MIME-Version: 1.0
In-Reply-To: <20181108081231.GN27423@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Oscar Salvador <OSalvador@suse.com>, Baoquan He <bhe@redhat.com>, LKML <linux-kernel@vger.kernel.org>



On 11/08/2018 01:42 PM, Michal Hocko wrote:
> On Thu 08-11-18 12:46:47, Anshuman Khandual wrote:
>>
>>
>> On 11/07/2018 03:48 PM, Michal Hocko wrote:
> [...]
>>> @@ -1411,8 +1409,14 @@ do_migrate_range(unsigned long start_pfn, unsigned long end_pfn)
>>>  		/* Allocate a new page from the nearest neighbor node */
>>>  		ret = migrate_pages(&source, new_node_page, NULL, 0,
>>>  					MIGRATE_SYNC, MR_MEMORY_HOTPLUG);
>>> -		if (ret)
>>> +		if (ret) {
>>> +			list_for_each_entry(page, &source, lru) {
>>> +				pr_warn("migrating pfn %lx failed ",
>>> +				       page_to_pfn(page), ret);
>>
>> Seems like pr_warn() needs to have %d in here to print 'ret'.
> 
> Dohh. Rebase hickup. You are right ret:%d got lost on the way.
> 
>> Though
>> dumping return code from migrate_pages() makes sense, wondering if
>> it is required for each and every page which failed to migrate here
>> or just one instance is enough.
> 
> Does it matter enough to special case one printk?
I just imagined how a bunch of prints will look like when multiple pages
failed to migrate probably for the same reason. But I guess its okay.

> 
>>> +				dump_page(page, NULL);
>>> +			}
>>
>> s/NULL/failed to migrate/ for dump_page().
> 
> Yes, makes sense.
> 
>>
>>>  			putback_movable_pages(&source);
>>> +		}
>>>  	}
>>>  out:
>>>  	return ret;
>>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>>> index a919ba5cb3c8..23267767bf98 100644
>>> --- a/mm/page_alloc.c
>>> +++ b/mm/page_alloc.c
>>> @@ -7845,6 +7845,7 @@ bool has_unmovable_pages(struct zone *zone, struct page *page, int count,
>>>  	return false;
>>>  unmovable:
>>>  	WARN_ON_ONCE(zone_idx(zone) == ZONE_MOVABLE);
>>> +	dump_page(pfn_to_page(pfn+iter), "has_unmovable_pages");
>>
>> s/has_unmovable_pages/is unmovable/
> 
> OK
> 
>> If we eally care about the function name, then dump_page() should be
>> followed by dump_stack() like the case in some other instances.
>>
>>>  	return true;
>>
>> This will be dumped from HugeTLB and CMA allocation paths as well through
>> alloc_contig_range(). But it should be okay as those occurrences should be
>> rare and dumping page state then will also help.
> 
> yes
> 
> Thanks and here is the incremental fix:
> 
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index bf214beccda3..820397e18e59 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -1411,9 +1411,9 @@ do_migrate_range(unsigned long start_pfn, unsigned long end_pfn)
>  					MIGRATE_SYNC, MR_MEMORY_HOTPLUG);
>  		if (ret) {
>  			list_for_each_entry(page, &source, lru) {
> -				pr_warn("migrating pfn %lx failed ",
> +				pr_warn("migrating pfn %lx failed ret:%d ",
>  				       page_to_pfn(page), ret);
> -				dump_page(page, NULL);
> +				dump_page(page, "migration failure");
>  			}
>  			putback_movable_pages(&source);
>  		}
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 23267767bf98..ec2c7916dc2d 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -7845,7 +7845,7 @@ bool has_unmovable_pages(struct zone *zone, struct page *page, int count,
>  	return false;
>  unmovable:
>  	WARN_ON_ONCE(zone_idx(zone) == ZONE_MOVABLE);
> -	dump_page(pfn_to_page(pfn+iter), "has_unmovable_pages");
> +	dump_page(pfn_to_page(pfn+iter), "unmovable page");
>  	return true;
>  }

It looks good.
