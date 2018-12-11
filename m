Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 00C4C8E004D
	for <linux-mm@kvack.org>; Tue, 11 Dec 2018 04:37:48 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id w19so14314071qto.13
        for <linux-mm@kvack.org>; Tue, 11 Dec 2018 01:37:47 -0800 (PST)
Subject: Re: [PATCH] mm, memory_hotplug: Don't bail out in do_migrate_range
 prematurely
References: <20181211085042.2696-1-osalvador@suse.de>
 <01021c8571af27995acbaaca7a1a68f0@suse.de>
From: David Hildenbrand <david@redhat.com>
Message-ID: <616842fe-5c8d-0d51-cf7f-35b0bd0a1b34@redhat.com>
Date: Tue, 11 Dec 2018 10:37:43 +0100
MIME-Version: 1.0
In-Reply-To: <01021c8571af27995acbaaca7a1a68f0@suse.de>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: osalvador@suse.de, akpm@linux-foundation.org
Cc: mhocko@suse.com, pasha.tatashin@soleen.com, dan.j.williams@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, owner-linux-mm@kvack.org

On 11.12.18 09:57, osalvador@suse.de wrote:
> On 2018-12-11 09:50, Oscar Salvador wrote:
> 
>> -		} else {
>> -			pr_warn("failed to isolate pfn %lx\n", pfn);
>> -			dump_page(page, "isolation failed");
>> -			put_page(page);
>> -			/* Because we don't have big zone->lock. we should
>> -			   check this again here. */
>> -			if (page_count(page)) {
>> -				not_managed++;
>> -				ret = -EBUSY;
>> -				break;
> 
> I forgot that here we should at least leave the put_page().
> But leave also the dump_page() and the pr_warn().
> 
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -1394,6 +1394,10 @@ do_migrate_range(unsigned long start_pfn, 
> unsigned long end_pfn)
>                                  inc_node_page_state(page, 
> NR_ISOLATED_ANON +
>                                                      
> page_is_file_cache(page));
> 
> +               } else {
> +                       pr_warn("failed to isolate pfn %lx\n", pfn);
> +                       dump_page(page, "isolation failed");
> +                       put_page(page);

When we're stuck with one problematic page, and we keep looping over
that function, won't that print out *way too much* messages? Shouldn't
that be rate limited somehow (same applies to other callers in this file)

>                  }
>          }
>          if (!list_empty(&source)) {
> 


-- 

Thanks,

David / dhildenb
