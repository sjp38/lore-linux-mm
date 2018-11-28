Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3950C6B466F
	for <linux-mm@kvack.org>; Tue, 27 Nov 2018 19:29:56 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id k58so11693078eda.20
        for <linux-mm@kvack.org>; Tue, 27 Nov 2018 16:29:56 -0800 (PST)
Date: Wed, 28 Nov 2018 00:29:52 +0000
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH] mm, sparse: drop pgdat_resize_lock in
 sparse_add/remove_one_section()
Message-ID: <20181128002952.x2m33nvlunzij5tk@master>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20181127023630.9066-1-richard.weiyang@gmail.com>
 <20181127062514.GJ12455@dhcp22.suse.cz>
 <3356e00d-9135-12ef-a53f-49d815b8fbfc@intel.com>
 <4fe3f8203a35ea01c9e0ed87c361465e@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4fe3f8203a35ea01c9e0ed87c361465e@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: osalvador@suse.de
Cc: Dave Hansen <dave.hansen@intel.com>, Michal Hocko <mhocko@suse.com>, Wei Yang <richard.weiyang@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org, owner-linux-mm@kvack.org

On Tue, Nov 27, 2018 at 08:52:14AM +0100, osalvador@suse.de wrote:
>> I think mem_hotplug_lock protects this case these days, though.  I don't
>> think we had it in the early days and were just slumming it with the
>> pgdat locks.
>
>Yes, it does.
>
>> 
>> I really don't like the idea of removing the lock by just saying it
>> doesn't protect anything without doing some homework first, though.  It
>> would actually be really nice to comment the entire call chain from the
>> mem_hotplug_lock acquisition to here.  There is precious little
>> commenting in there and it could use some love.
>
>[hot-add operation]
>add_memory_resource     : acquire mem_hotplug lock
> arch_add_memory
>  add_pages
>   __add_pages
>    __add_section
>     sparse_add_one_section
>      sparse_init_one_section
>
>[hot-remove operation]
>__remove_memory         : acquire mem_hotplug lock
> arch_remove_memory
>  __remove_pages
>   __remove_section
>    sparse_remove_one_section
>

Thanks for this detailed analysis.

>Both operations are serialized by the mem_hotplug lock, so they cannot step
>on each other's feet.
>
>Now, there seems to be an agreement/thought to remove the global mem_hotplug
>lock, in favor of a range locking for hot-add/remove and online/offline
>stage.
>So, although removing the lock here is pretty straightforward, it does not
>really get us closer to that goal IMHO, if that is what we want to do in the
>end.
>

My current idea is :

  we can try to get rid of global mem_hotplug_lock in logical
  online/offline phase first, and leave the physical add/remove phase
  serialized by mem_hotplug_lock for now.

There are two phase in memory hotplug:

  * physical add/remove phase
  * logical online/offline phase

Currently, both of them are protected by the global mem_hotplug_lock.

While get rid of the this in logical online/offline phase is a little
easier to me, since this procedure is protected by memory_block_dev's lock.
This ensures there is no pfn over lap during parallel processing.

The physical add/remove phase is a little harder, because it will touch

   * memblock
   * kernel page table
   * node online
   * sparse mem

And I don't see a similar lock as memory_block_dev's lock.

Below is the call trace for these two phase and I list some suspicious
point which is not safe without mem_hotplug_lock.

1. physical phase

    __add_memory()
        register_memory_resource() <- protected by resource_lock
        add_memory_resource()
    	mem_hotplug_begin()
    
    	memblock_add_node()    <- add to memblock.memory, not safe
    	__try_online_node()    <- not safe, related to node_set_online()
    
    	arch_add_memory()
    	    init_memory_mapping() <- not safe
    
    	    add_pages()
    	        __add_pages()
    	            __add_section()
    	                sparse_add_one_section()
    	        update_end_of_memory_vars()  <- not safe
            node_set_online(nid)             <- need to hold mem_hotplug
    	__register_one_node(nid)
    	link_mem_sections()
    	firmware_map_add_hotplug()
    
    	mem_hotplug_done()

2. logical phase

    device_lock(memory_block_dev)
    online_pages()
        mem_hotplug_begin()
    
        mem = find_memory_block()     <- not
        zone = move_pfn_range()
            zone_for_pfn_range();
    	move_pfn_range_to_zone()
        !populated_zone()
            setup_zone_pageset(zone)
    
        online_pages_range()          <- looks safe
        build_all_zonelists()         <- not
        init_per_zone_wmark_min()     <- not
        kswapd_run()                  <- may not
        vm_total_pages = nr_free_pagecache_pages()
    
        mem_hotplug_done()
    device_unlock(memory_block_dev)



-- 
Wei Yang
Help you, Help me
