Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 338766B6DFB
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 04:26:02 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id d41so7733617eda.12
        for <linux-mm@kvack.org>; Tue, 04 Dec 2018 01:26:02 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b11-v6si4379021ejl.286.2018.12.04.01.26.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Dec 2018 01:26:00 -0800 (PST)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Date: Tue, 04 Dec 2018 10:26:00 +0100
From: osalvador@suse.de
Subject: [RFC Get rid of shrink code - memory-hotplug]
Message-ID: <72455c1d4347d263cb73517187bc1394@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.com
Cc: david@redhat.com, dan.j.williams@gmail.com, pasha.tatashin@soleen.com, linux-mm@kvack.org

[Sorry, I forgot to cc linux-mm before]

Hi,

I wanted to bring up a topic that showed up during a discussion about
simplifying shrink code [1].
During that discussion, Michal suggested that we might be able
to get rid of the shrink code.

To put you on track, the shrink code was introduced by 815121d2b5cd
("memory_hotplug: clear zone when removing the memory") just to match
the work we did in __add_zone() and do the reverse thing there.

It is a nice thing to have as a) it keeps a zone/node boundaries strict
and b) we are consistent because we do the reverse operation than
move_pfn_range_to_zone.

But, I think that we can live without it:

     1) since c6f03e2903c9ecd8fd709a5b3fa8cf0a8ae0b3da
        ("mm, memory_hotplug: remove zone restrictions") we became more 
flexible
        and now we can have ZONE_NORMAL and ZONE_MOVABLE interleaved 
during hotplug.
        So keeping a strict zone boundary does not really make sense 
anymore.
        In the same way, we can also have interleaved nodes.

     2) From the point of view of a pfn walker, we should not care if the 
section
        removed was the first one, the last one, or some section 
in-between,
        as we should skip non-valid pfns.


When the topic arose, I was a bit worried because I was not sure if
anything out there would trust the node/zone boundaries blindly
without checking anything.
So I started to dig in to see who were the users of

- zone_start_pfn
- zone_end_pfn
- zone_intersects
- zone_spans_pfn
- node_start_pfn
- node_end_pfn

Below, there is a list with the places I found that use these
variables.
For the sake of simplicity, I left out the places where they are
only used during boot-time, as there is no danger in there.

=== ZONE related ===

[Usages of zone_start_pfn / zone_end_pfn]

  * split_huge_pages_set()
    - It uses pfn_valid()

  * alloc_gigantic_page()
    - It uses pfn_range_valid_gigantic()->pfn_valid()

  * pagetypeinfo_showblockcount_print()
    - It uses pfn_to_online_page()

  * mark_free_pages()
    - It uses pfn_valid()

  * __reset_isolation_suitable()
    - It uses pfn_to_online_page()

  * reset_cached_positions()

  * isolate_freepages_range()
  * isolate_migratepages_range()
  * isolate_migratepages()
    - They use pageblock_pfn_to_page()
      In case !zone->contiguous, we will call 
__pageblock_pfn_to_page()->pfn_to_online_page()
      In case zone->contiguous, we just return with pfn_to_page().
      So we just need to make sure that zone->contiguous has the right 
value.

  * create_mem_extents
    - What?

  * count_highmem_pages:
    count_data_pages:
    copy_data_pages:
    - page_is_saveable()->pfn_valid()

[Usages of zone_spans_pfn]

  * move_freepages_block
  * set_pfnblock_flags_mask
  * page_outside_zone_boundaries
    - I would say this is safe, as, if anything, when removing the shrink 
code
      the system can think that we span more than we actually do, no the 
other
      way around.

[Usages of zone_intersects]

  * default_zone_for_pfn
    default_kernel_zone_for_pfn
    - It should not be a problem

=== NODE related ===

[Usages of node_start_pfn / node_end_pfn]

  * vmemmap_find_next_valid_pfn()
    - I am not really sure if this represents a problem

  * memtrace_alloc_node()
    - Should not have any problem as we currently support interleaved 
nodes.

  * kmemleak_scan()
    - It is ok, but I think we should check for the pfn to belong to the 
node here?

  * Crash core:
    - VMCOREINFO_OFFSET(pglist_data, node_start_pfn) is this a problem?

  * lookup_page_ext()
    - For !CONFIG_SPARSEMEM, node_start_pfn is used.

  * kcore_ram_list()
    - Safe, as kclist_add_private() uses pfn_valid.


So overall, besides a couple of places I am not sure it would cause 
trouble,
I would tend to say this is doable.

Another thing that needs remark is that Patchset [3] aims for not 
touching pages
during hot-remove path, so we will have to find another way to trigger
clear/set_zone_contiguous, but that is another topic.

While it is true that the current shrink code can be simplified as 
showed in [2],
I think that getting rid of it would be a nice thing to do unless we 
need to keep
the code around.

I would like to hear other opinions though.
Is it too risky? Is there anything I overlooked that might cause 
trouble?
Did I miss anything?

[1] https://patchwork.kernel.org/patch/10700791/
[2] https://patchwork.kernel.org/patch/10700791/
[3] https://patchwork.kernel.org/cover/10700783/

Thanks
Oscar Salvador
