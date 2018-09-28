Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id D1A7D8E0001
	for <linux-mm@kvack.org>; Fri, 28 Sep 2018 04:12:27 -0400 (EDT)
Received: by mail-wm1-f72.google.com with SMTP id b186-v6so1293376wmh.8
        for <linux-mm@kvack.org>; Fri, 28 Sep 2018 01:12:27 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h7-v6sor3146900wru.5.2018.09.28.01.12.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 28 Sep 2018 01:12:26 -0700 (PDT)
Date: Fri, 28 Sep 2018 10:12:24 +0200
From: Oscar Salvador <osalvador@techadventures.net>
Subject: Re: [PATCH v5 4/4] mm: Defer ZONE_DEVICE page initialization to the
 point where we init pgmap
Message-ID: <20180928081224.GA25561@techadventures.net>
References: <20180925200551.3576.18755.stgit@localhost.localdomain>
 <20180925202053.3576.66039.stgit@localhost.localdomain>
 <20180926075540.GD6278@dhcp22.suse.cz>
 <6f87a5d7-05e2-00f4-8568-bb3521869cea@linux.intel.com>
 <20180927110926.GE6278@dhcp22.suse.cz>
 <20180927122537.GA20378@techadventures.net>
 <20180927131329.GI6278@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180927131329.GI6278@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Alexander Duyck <alexander.h.duyck@linux.intel.com>, linux-mm@kvack.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-nvdimm@lists.01.org, pavel.tatashin@microsoft.com, dave.jiang@intel.com, dave.hansen@intel.com, jglisse@redhat.com, rppt@linux.vnet.ibm.com, dan.j.williams@intel.com, logang@deltatee.com, mingo@kernel.org, kirill.shutemov@linux.intel.com

On Thu, Sep 27, 2018 at 03:13:29PM +0200, Michal Hocko wrote:
> I would have to double check but is the hotplug lock really serializing
> access to the state initialized by init_currently_empty_zone? E.g.
> zone_start_pfn is a nice example of a state that is used outside of the
> lock. zone's free lists are similar. So do we really need the hoptlug
> lock? And more broadly, what does the hotplug lock is supposed to
> serialize in general. A proper documentation would surely help to answer
> these questions. There is way too much of "do not touch this code and
> just make my particular hack" mindset which made the whole memory
> hotplug a giant pile of mess. We really should start with some proper
> engineering here finally.

* Locking rules:
*
* zone_start_pfn and spanned_pages are protected by span_seqlock.
* It is a seqlock because it has to be read outside of zone->lock,
* and it is done in the main allocator path.  But, it is written
* quite infrequently.
*
* Write access to present_pages at runtime should be protected by
* mem_hotplug_begin/end(). Any reader who can't tolerant drift of
* present_pages should get_online_mems() to get a stable value.

IIUC, looks like zone_start_pfn should be envolved with
zone_span_writelock/zone_span_writeunlock, and since zone_start_pfn is changed
in init_currently_empty_zone, I guess that the whole function should be within
that lock.

So, a blind shot, but could we do something like the following?

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 898e1f816821..49f87252f1b1 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -764,14 +764,13 @@ void __ref move_pfn_range_to_zone(struct zone *zone, unsigned long start_pfn,
        int nid = pgdat->node_id;
        unsigned long flags;
 
-       if (zone_is_empty(zone))
-               init_currently_empty_zone(zone, start_pfn, nr_pages);
-
        clear_zone_contiguous(zone);
 
        /* TODO Huh pgdat is irqsave while zone is not. It used to be like that before */
        pgdat_resize_lock(pgdat, &flags);
        zone_span_writelock(zone);
+       if (zone_is_empty(zone))
+               init_currently_empty_zone(zone, start_pfn, nr_pages);
        resize_zone_range(zone, start_pfn, nr_pages);
        zone_span_writeunlock(zone);
        resize_pgdat_range(pgdat, start_pfn, nr_pages);

Then, we could take move_pfn_range_to_zone out of the hotplug lock.

Although I am not sure about leaving memmap_init_zone unprotected.
For the normal memory, that is not a problem since the memblock's lock
protects us from touching the same pages at the same time in online/offline_pages,
but for HMM/devm the story is different.

I am totally unaware of HMM/devm, so I am not sure if its protected somehow.
e.g: what happens if devm_memremap_pages and devm_memremap_pages_release are running
at the same time for the same memory-range (with the assumption that the hotplug-lock
does not protect move_pfn_range_to_zone anymore).

-- 
Oscar Salvador
SUSE L3
