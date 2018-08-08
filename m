Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id CE6636B0003
	for <linux-mm@kvack.org>; Wed,  8 Aug 2018 09:42:37 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id k15-v6so1882727wrq.1
        for <linux-mm@kvack.org>; Wed, 08 Aug 2018 06:42:37 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y188-v6sor1078862wmy.72.2018.08.08.06.42.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 08 Aug 2018 06:42:36 -0700 (PDT)
Date: Wed, 8 Aug 2018 15:42:33 +0200
From: Oscar Salvador <osalvador@techadventures.net>
Subject: Re: [RFC PATCH 2/3] mm/memory_hotplug: Create __shrink_pages and
 move it to offline_pages
Message-ID: <20180808134233.GA10946@techadventures.net>
References: <20180807133757.18352-1-osalvador@techadventures.net>
 <20180807133757.18352-3-osalvador@techadventures.net>
 <20180807135221.GA3301@redhat.com>
 <a6e4e654-fc95-497f-16f3-8c1550cf03d6@redhat.com>
 <20180807204834.GA6844@techadventures.net>
 <20180807221345.GD3301@redhat.com>
 <20180808073835.GA9568@techadventures.net>
 <44f74b58-aae0-a44c-3b98-7b1aac186f8e@redhat.com>
 <20180808075614.GB9568@techadventures.net>
 <7a64e67d-1df9-04ab-cc49-99a39aa90798@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <7a64e67d-1df9-04ab-cc49-99a39aa90798@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>
Cc: Jerome Glisse <jglisse@redhat.com>, akpm@linux-foundation.org, mhocko@suse.com, dan.j.williams@intel.com, yasu.isimatu@gmail.com, logang@deltatee.com, dave.jiang@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Oscar Salvador <osalvador@suse.de>

On Wed, Aug 08, 2018 at 10:08:41AM +0200, David Hildenbrand wrote:
> Then it is maybe time to cleary distinguish both types of memory, as
> they are fundamentally different when it comes to online/offline behavior.
> 
> Ordinary ram:
>  add_memory ...
>  online_pages ...
>  offline_pages
>  remove_memory
> 
> Device memory
>  add_device_memory ...
>  remove_device_memory
> 
> So adding/removing from the zone and stuff can be handled there.

Uhm, I have been thinking about this.
Maybe we could do something like (completely untested):


== memory_hotplug code ==

int add_device_memory(int nid, unsigned long start, unsigned long size,
                                struct vmem_altmap *altmap, bool mapping)
{
        int ret;
        unsigned long start_pfn = PHYS_PFN(start);
        unsigned long nr_pages = size >> PAGE_SHIFT;

        mem_hotplug_begin();
        if (mapping)
                ret = arch_add_memory(nid, start, size, altmap, false)
        else
                ret = add_pages(nid, start_pfn, nr_pages, altmap, false):

        if (!ret) {
                pgdata_t *pgdata = NODE_DATA(nid);
                struct zone *zone = pgdata->node_zones[ZONE_DEVICE];

                online_mem_sections(start_pfn, start_pfn + nr_pages);
                move_pfn_range_to_zone(zone, start_pfn, nr_pages, altmap);
        }
        mem_hotplug_done();

        return ret;
}

int del_device_memory(int nid, unsigned long start, unsigned long size,
                                struct vmem_altmap *altmap, bool mapping)
{
        int ret;
        unsigned long start_pfn = PHYS_PFN(start);
        unsigned long nr_pages = size >> PAGE_SHIFT;
        pgdata_t *pgdata = NODE_DATA(nid);
        struct zone *zone = pgdata->node_zones[ZONE_DEVICE];

        mem_hotplug_begin();

        offline_mem_sections(start_pfn, start_pfn + nr_pages);
        __shrink_pages(zone, start_pfn, start_pfn + nr_pages, nr_pages);

        if (mapping)
                ret = arch_remove_memory(nid, start, size, altmap)
        else
                ret = __remove_pages(nid, start_pfn, nr_pages, altmap)

        mem_hotplug_done();

        return ret;
}

===

And then, HMM/devm code could use it.

For example:

hmm_devmem_pages_create():

...
...
if (devmem->pagemap.type == MEMORY_DEVICE_PUBLIC)
	linear_mapping = true;
else
	linear_mapping = false;

ret = add_device_memory(nid, align_start, align_size, NULL, linear_mapping);
if (ret)
	goto error_add_memory;
...
...


hmm_devmem_release:

...
...
if (resource->desc == IORES_DESC_DEVICE_PRIVATE_MEMORY)
	mapping = false;
else
	mapping = true;

del_device_memory(nid, start_pfn << PAGE_SHIFT, npages << PAGE_SHIFT,
								NULL,
								mapping);
...
...


In this way, we do not need to play tricks in HMM/devm code, we just need to
call those functions when adding/removing memory.

We would still have to figure out a way to go for the release_mem_region_adjustable() stuff though.

Thanks
-- 
Oscar Salvador
SUSE L3
