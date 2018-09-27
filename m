Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 578C18E0001
	for <linux-mm@kvack.org>; Thu, 27 Sep 2018 10:50:39 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id z9-v6so2997248wrv.6
        for <linux-mm@kvack.org>; Thu, 27 Sep 2018 07:50:39 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a204-v6sor2062103wmf.28.2018.09.27.07.50.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 27 Sep 2018 07:50:37 -0700 (PDT)
Date: Thu, 27 Sep 2018 16:50:35 +0200
From: Oscar Salvador <osalvador@techadventures.net>
Subject: Re: [PATCH v5 4/4] mm: Defer ZONE_DEVICE page initialization to the
 point where we init pgmap
Message-ID: <20180927145035.GA21373@techadventures.net>
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
Cc: Alexander Duyck <alexander.h.duyck@linux.intel.com>, linux-mm@kvack.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-nvdimm@lists.01.org, pavel.tatashin@microsoft.com, dave.jiang@intel.com, dave.hansen@intel.com, jglisse@redhat.com, rppt@linux.vnet.ibm.com, dan.j.williams@intel.com, logang@deltatee.com, mingo@kernel.org, kirill.shutemov@linux.intel.com, david@redhat.com

On Thu, Sep 27, 2018 at 03:13:29PM +0200, Michal Hocko wrote:
> On Thu 27-09-18 14:25:37, Oscar Salvador wrote:
> > On Thu, Sep 27, 2018 at 01:09:26PM +0200, Michal Hocko wrote:
> > > > So there were a few things I wasn't sure we could pull outside of the
> > > > hotplug lock. One specific example is the bits related to resizing the pgdat
> > > > and zone. I wanted to avoid pulling those bits outside of the hotplug lock.
> > > 
> > > Why would that be a problem. There are dedicated locks for resizing.
> > 
> > True is that move_pfn_range_to_zone() manages the locks for pgdat/zone resizing,
> > but it also takes care of calling init_currently_empty_zone() in case the zone is empty.
> > Could not that be a problem if we take move_pfn_range_to_zone() out of the lock?
> 
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

CC David

David has been looking into this lately, he even has updated memory-hotplug.txt
with some more documentation about the locking aspect [1].
And with this change [2], the hotplug lock has been moved
to the online/offline_pages.

>From what I see (I might be wrong), the hotplug lock is there
to serialize the online/offline operations.

In online_pages, we do (among other things):

a) initialize the zone and its pages, and link them to the zone
b) re-adjust zone/pgdat nr of pages (present, spanned, managed)
b) check if the node changes in regard of N_MEMORY, N_HIGH_MEMORY or N_NORMAL_MEMORY.
c) fire notifiers
d) rebuild the zonelists in case we got a new zone
e) online memory sections and free the pages to the buddy allocator
f) wake up kswapd/kcompactd in case we got a new node

while in offline_pages we do the opposite.

Hotplug lock here serializes the operations as a whole, online and offline memory,
so they do not step on each other's feet.

Having said that, we might be able to move some of those operations out of the hotplug lock.
The device_hotplug_lock coming from every memblock (which is taken in device_online/device_offline) should protect
us against some operations being made on the same memblock (e.g: touching the same pages).

For the given case about move_pfn_range_to_zone() I have my doubts.
The resizing of the pgdat/zone is already serialized, so no discussion there.

Then we have memmap_init_zone. I __think__ that that should not worry us because those pages
belong to a memblock, and device_online/device_offline is serialized.
HMM/devm is different here as they do not handle memblocks.

And then we have init_currently_empty_zone.
Assuming that the shrinking of pages/removal of the zone is finally brought to
the offline stage (where it should be), I am not sure if we can somehow
race with an offline operation there if we do not hold the hotplug lock.

[1] https://patchwork.kernel.org/patch/10617715/
[2] https://patchwork.kernel.org/patch/10617705/
-- 
Oscar Salvador
SUSE L3
