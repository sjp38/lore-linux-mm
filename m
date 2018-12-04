Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 026586B6E75
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 06:31:06 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id q3so16933260qtq.15
        for <linux-mm@kvack.org>; Tue, 04 Dec 2018 03:31:05 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o13si3082058qtm.223.2018.12.04.03.31.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Dec 2018 03:31:04 -0800 (PST)
Subject: Re: [RFC Get rid of shrink code - memory-hotplug]
References: <72455c1d4347d263cb73517187bc1394@suse.de>
From: David Hildenbrand <david@redhat.com>
Message-ID: <e167e2b9-f8b6-e322-b469-358096a97bda@redhat.com>
Date: Tue, 4 Dec 2018 12:31:01 +0100
MIME-Version: 1.0
In-Reply-To: <72455c1d4347d263cb73517187bc1394@suse.de>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: osalvador@suse.de, mhocko@suse.com
Cc: dan.j.williams@gmail.com, pasha.tatashin@soleen.com, linux-mm@kvack.org

On 04.12.18 10:26, osalvador@suse.de wrote:
> [Sorry, I forgot to cc linux-mm before]
> 
> Hi,
> 
> I wanted to bring up a topic that showed up during a discussion about
> simplifying shrink code [1].
> During that discussion, Michal suggested that we might be able
> to get rid of the shrink code.
> 
> To put you on track, the shrink code was introduced by 815121d2b5cd
> ("memory_hotplug: clear zone when removing the memory") just to match
> the work we did in __add_zone() and do the reverse thing there.
> 
> It is a nice thing to have as a) it keeps a zone/node boundaries strict
> and b) we are consistent because we do the reverse operation than
> move_pfn_range_to_zone.
> 
> But, I think that we can live without it:
> 
>      1) since c6f03e2903c9ecd8fd709a5b3fa8cf0a8ae0b3da
>         ("mm, memory_hotplug: remove zone restrictions") we became more 
> flexible
>         and now we can have ZONE_NORMAL and ZONE_MOVABLE interleaved 
> during hotplug.
>         So keeping a strict zone boundary does not really make sense 
> anymore.
>         In the same way, we can also have interleaved nodes.
> 
>      2) From the point of view of a pfn walker, we should not care if the 
> section
>         removed was the first one, the last one, or some section 
> in-between,
>         as we should skip non-valid pfns.
> 
> 
> When the topic arose, I was a bit worried because I was not sure if
> anything out there would trust the node/zone boundaries blindly
> without checking anything.
> So I started to dig in to see who were the users of
> 
> - zone_start_pfn
> - zone_end_pfn
> - zone_intersects
> - zone_spans_pfn
> - node_start_pfn
> - node_end_pfn
> 
> Below, there is a list with the places I found that use these
> variables.
> For the sake of simplicity, I left out the places where they are
> only used during boot-time, as there is no danger in there.
> 
> === ZONE related ===
> 
> [Usages of zone_start_pfn / zone_end_pfn]
> 
>   * split_huge_pages_set()
>     - It uses pfn_valid()
> 
>   * alloc_gigantic_page()
>     - It uses pfn_range_valid_gigantic()->pfn_valid()
> 
>   * pagetypeinfo_showblockcount_print()
>     - It uses pfn_to_online_page()
> 
>   * mark_free_pages()
>     - It uses pfn_valid()
> 
>   * __reset_isolation_suitable()
>     - It uses pfn_to_online_page()
> 
>   * reset_cached_positions()
> 
>   * isolate_freepages_range()
>   * isolate_migratepages_range()
>   * isolate_migratepages()
>     - They use pageblock_pfn_to_page()
>       In case !zone->contiguous, we will call 
> __pageblock_pfn_to_page()->pfn_to_online_page()
>       In case zone->contiguous, we just return with pfn_to_page().
>       So we just need to make sure that zone->contiguous has the right 
> value.
> 
>   * create_mem_extents
>     - What?
> 
>   * count_highmem_pages:
>     count_data_pages:
>     copy_data_pages:
>     - page_is_saveable()->pfn_valid()
> 
> [Usages of zone_spans_pfn]
> 
>   * move_freepages_block
>   * set_pfnblock_flags_mask
>   * page_outside_zone_boundaries
>     - I would say this is safe, as, if anything, when removing the shrink 
> code
>       the system can think that we span more than we actually do, no the 
> other
>       way around.
> 
> [Usages of zone_intersects]
> 
>   * default_zone_for_pfn
>     default_kernel_zone_for_pfn
>     - It should not be a problem
> 
> === NODE related ===
> 
> [Usages of node_start_pfn / node_end_pfn]
> 
>   * vmemmap_find_next_valid_pfn()
>     - I am not really sure if this represents a problem
> 
>   * memtrace_alloc_node()
>     - Should not have any problem as we currently support interleaved 
> nodes.
> 
>   * kmemleak_scan()
>     - It is ok, but I think we should check for the pfn to belong to the 
> node here?
> 
>   * Crash core:
>     - VMCOREINFO_OFFSET(pglist_data, node_start_pfn) is this a problem?
> 
>   * lookup_page_ext()
>     - For !CONFIG_SPARSEMEM, node_start_pfn is used.
> 
>   * kcore_ram_list()
>     - Safe, as kclist_add_private() uses pfn_valid.
> 
> 
> So overall, besides a couple of places I am not sure it would cause 
> trouble,
> I would tend to say this is doable.
> 
> Another thing that needs remark is that Patchset [3] aims for not 
> touching pages
> during hot-remove path, so we will have to find another way to trigger
> clear/set_zone_contiguous, but that is another topic.

If I am not wrong, zone_contiguous is a pure mean for performance
improvement, right? So leaving zone_contiguous unset is always save. I
always disliked the whole clear/set_zone_contiguous thingy. I wonder if
we can find a different way to boost performance there (in the general
case). Or is this (zone_contiguous) even worth keeping around at all for
now? (do we have performance numbers?)

> 
> While it is true that the current shrink code can be simplified as 
> showed in [2],
> I think that getting rid of it would be a nice thing to do unless we 
> need to keep
> the code around.
> 
> I would like to hear other opinions though.
> Is it too risky? Is there anything I overlooked that might cause 
> trouble?
> Did I miss anything?

I'd say let's give it a try and find out if we are missing something. +1
to simplifying that code.

> 
> [1] https://patchwork.kernel.org/patch/10700791/
> [2] https://patchwork.kernel.org/patch/10700791/
> [3] https://patchwork.kernel.org/cover/10700783/
> 
> Thanks
> Oscar Salvador
> 


-- 

Thanks,

David / dhildenb
