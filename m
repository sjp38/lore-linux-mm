Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4202B6B000D
	for <linux-mm@kvack.org>; Fri,  3 Aug 2018 09:18:30 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id g15-v6so1802972edm.11
        for <linux-mm@kvack.org>; Fri, 03 Aug 2018 06:18:30 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k21-v6si2735868edq.27.2018.08.03.06.18.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Aug 2018 06:18:29 -0700 (PDT)
Subject: Re: [PATCH v6 5/5] mm/page_alloc: Introduce
 free_area_init_core_hotplug
References: <20180801122348.21588-1-osalvador@techadventures.net>
 <20180801122348.21588-6-osalvador@techadventures.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <3806484c-fc4d-78a4-cc9c-b877e4397670@suse.cz>
Date: Fri, 3 Aug 2018 15:18:26 +0200
MIME-Version: 1.0
In-Reply-To: <20180801122348.21588-6-osalvador@techadventures.net>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: osalvador@techadventures.net, akpm@linux-foundation.org
Cc: mhocko@suse.com, pasha.tatashin@oracle.com, mgorman@techsingularity.net, aaron.lu@intel.com, iamjoonsoo.kim@lge.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, dan.j.williams@intel.com, david@redhat.com, Oscar Salvador <osalvador@suse.de>

On 08/01/2018 02:23 PM, osalvador@techadventures.net wrote:
> From: Oscar Salvador <osalvador@suse.de>
> 
> Currently, whenever a new node is created/re-used from the memhotplug path,
> we call free_area_init_node()->free_area_init_core().
> But there is some code that we do not really need to run when we are coming
> from such path.
> 
> free_area_init_core() performs the following actions:
> 
> 1) Initializes pgdat internals, such as spinlock, waitqueues and more.
> 2) Account # nr_all_pages and # nr_kernel_pages. These values are used later on
>    when creating hash tables.
> 3) Account number of managed_pages per zone, substracting dma_reserved and memmap pages.
> 4) Initializes some fields of the zone structure data
> 5) Calls init_currently_empty_zone to initialize all the freelists
> 6) Calls memmap_init to initialize all pages belonging to certain zone
> 
> When called from memhotplug path, free_area_init_core() only performs actions #1 and #4.
> 
> Action #2 is pointless as the zones do not have any pages since either the node was freed,
> or we are re-using it, eitherway all zones belonging to this node should have 0 pages.
> For the same reason, action #3 results always in manages_pages being 0.
> 
> Action #5 and #6 are performed later on when onlining the pages:
>  online_pages()->move_pfn_range_to_zone()->init_currently_empty_zone()
>  online_pages()->move_pfn_range_to_zone()->memmap_init_zone()
> 
> This patch does two things:
> 
> First, moves the node/zone initializtion to their own function, so it allows us
> to create a small version of free_area_init_core, where we only perform:
> 
> 1) Initialization of pgdat internals, such as spinlock, waitqueues and more
> 4) Initialization of some fields of the zone structure data
> 
> These two functions are: pgdat_init_internals() and zone_init_internals().
> 
> The second thing this patch does, is to introduce free_area_init_core_hotplug(),
> the memhotplug version of free_area_init_core():
> 
> Currently, we call free_area_init_node() from the memhotplug path.
> In there, we set some pgdat's fields, and call calculate_node_totalpages().
> calculate_node_totalpages() calculates the # of pages the node has.
> 
> Since the node is either new, or we are re-using it, the zones belonging to
> this node should not have any pages, so there is no point to calculate this now.
> 
> Actually, we re-set these values to 0 later on with the calls to:
> 
> reset_node_managed_pages()
> reset_node_present_pages()
> 
> The # of pages per node and the # of pages per zone will be calculated when
> onlining the pages:
> 
> online_pages()->move_pfn_range()->move_pfn_range_to_zone()->resize_zone_range()
> online_pages()->move_pfn_range()->move_pfn_range_to_zone()->resize_pgdat_range()
> 
> Also, with this change, only pgdat_init_internals() and zone_init_internals() should
> be kept around after initialization, since they can be called from memory-hotplug
> code.
> So let us reconvert all the other functions from __meminit to __init, as we do not need
> them after initialization:
> 
> zero_resv_unavail
> set_pageblock_order
> calc_memmap_size
> free_area_init_core
> free_area_init_node
> 
> Signed-off-by: Oscar Salvador <osalvador@suse.de>
> Reviewed-by: Pavel Tatashin <pasha.tatashin@oracle.com>
> Acked-by: Michal Hocko <mhocko@suse.com>

Yep, it's safer to only do the actions relevant to hotplug during hotplug.

Acked-by: Vlastimil Babka <vbabka@suse.cz>
