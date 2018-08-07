Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 20C946B0003
	for <linux-mm@kvack.org>; Tue,  7 Aug 2018 18:13:49 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id d14-v6so191417qtn.12
        for <linux-mm@kvack.org>; Tue, 07 Aug 2018 15:13:49 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id w23-v6si2562841qta.290.2018.08.07.15.13.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Aug 2018 15:13:47 -0700 (PDT)
Date: Tue, 7 Aug 2018 18:13:45 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [RFC PATCH 2/3] mm/memory_hotplug: Create __shrink_pages and
 move it to offline_pages
Message-ID: <20180807221345.GD3301@redhat.com>
References: <20180807133757.18352-1-osalvador@techadventures.net>
 <20180807133757.18352-3-osalvador@techadventures.net>
 <20180807135221.GA3301@redhat.com>
 <a6e4e654-fc95-497f-16f3-8c1550cf03d6@redhat.com>
 <20180807204834.GA6844@techadventures.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20180807204834.GA6844@techadventures.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oscar Salvador <osalvador@techadventures.net>
Cc: David Hildenbrand <david@redhat.com>, akpm@linux-foundation.org, mhocko@suse.com, dan.j.williams@intel.com, pasha.tatashin@oracle.com, yasu.isimatu@gmail.com, logang@deltatee.com, dave.jiang@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Oscar Salvador <osalvador@suse.de>

On Tue, Aug 07, 2018 at 10:48:34PM +0200, Oscar Salvador wrote:
> On Tue, Aug 07, 2018 at 04:54:57PM +0200, David Hildenbrand wrote:
> > I wonder if we could instead forward from the callers whether we are
> > dealing with ZONE_DEVICE memory (is_device ...), at least that seems
> > feasible in hmm code. Not having looked at details yet.
> 
> Yes, this looks like the most straightforward way right now.
> We would have to pass it from arch_remove_memory to __remove_pages though.
> 
> It is not the most elegant way, but looking at the code of devm_memremap_pages_release
> and hmm_devmem_release I cannot really think of anything better.
> 
> In hmm_devmem_release is should be easy because AFAIK (unless I am missing something), hmm always works
> with ZONE_DEVICE.
> At least hmm_devmem_pages_create() moves the range to ZONE_DEVICE.
> 
> After looking at devm_memremap_pages(), I think it does the same:
> 
> ...
> move_pfn_range_to_zone(&NODE_DATA(nid)->node_zones[ZONE_DEVICE],
> 					align_start >> PAGE_SHIFT,
> 					align_size >> PAGE_SHIFT, altmap);
> ...
> 
> So I guess it is safe to assume that arch_remove_memory/__remove_pages are called
> from those functions while zone being ZONE_DEVICE.
> 
> Is that right, Jerome?

Correct, both HMM and devm always deal with ZONE_DEVICE page. So
any call to arch_remove_memory/__remove_pages in those context
can assume ZONE_DEVICE.

> 
> And since we know for sure that memhotplug-code cannot call it with ZONE_DEVICE,
> I think this can be done easily.

This might change down road but for now this is correct. They are
talks to enumerate device memory through standard platform mechanisms
and thus the kernel might see new types of resources down the road and
maybe we will want to hotplug them directly from regular hotplug path
as ZONE_DEVICE (lot of hypothetical at this point ;)).

Cheers,
Jerome
