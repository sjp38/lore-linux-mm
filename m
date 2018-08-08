Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id F30266B000A
	for <linux-mm@kvack.org>; Wed,  8 Aug 2018 03:56:16 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id 40-v6so1109975wrb.23
        for <linux-mm@kvack.org>; Wed, 08 Aug 2018 00:56:16 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n15-v6sor1394292wrh.43.2018.08.08.00.56.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 08 Aug 2018 00:56:15 -0700 (PDT)
Date: Wed, 8 Aug 2018 09:56:14 +0200
From: Oscar Salvador <osalvador@techadventures.net>
Subject: Re: [RFC PATCH 2/3] mm/memory_hotplug: Create __shrink_pages and
 move it to offline_pages
Message-ID: <20180808075614.GB9568@techadventures.net>
References: <20180807133757.18352-1-osalvador@techadventures.net>
 <20180807133757.18352-3-osalvador@techadventures.net>
 <20180807135221.GA3301@redhat.com>
 <a6e4e654-fc95-497f-16f3-8c1550cf03d6@redhat.com>
 <20180807204834.GA6844@techadventures.net>
 <20180807221345.GD3301@redhat.com>
 <20180808073835.GA9568@techadventures.net>
 <44f74b58-aae0-a44c-3b98-7b1aac186f8e@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <44f74b58-aae0-a44c-3b98-7b1aac186f8e@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>
Cc: Jerome Glisse <jglisse@redhat.com>, akpm@linux-foundation.org, mhocko@suse.com, dan.j.williams@intel.com, yasu.isimatu@gmail.com, logang@deltatee.com, dave.jiang@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Oscar Salvador <osalvador@suse.de>

On Wed, Aug 08, 2018 at 09:45:37AM +0200, David Hildenbrand wrote:
> On 08.08.2018 09:38, Oscar Salvador wrote:
> > On Tue, Aug 07, 2018 at 06:13:45PM -0400, Jerome Glisse wrote:
> >>> And since we know for sure that memhotplug-code cannot call it with ZONE_DEVICE,
> >>> I think this can be done easily.
> >>
> >> This might change down road but for now this is correct. They are
> >> talks to enumerate device memory through standard platform mechanisms
> >> and thus the kernel might see new types of resources down the road and
> >> maybe we will want to hotplug them directly from regular hotplug path
> >> as ZONE_DEVICE (lot of hypothetical at this point ;)).
> > 
> > Well, I think that if that happens this whole thing will become
> > much easier, since we will not have several paths for doing the same thing.
> > 
> > Another thing that I realized is that while we want to move all operation-pages
> > from remove_memory() path to offline_pages(), this can get tricky.
> > 
> > Unless I am missing something, the devices from HMM and devm are not being registered
> > against "memory_subsys" struct, and so, they never get to call memory_subsys_offline()
> > and so offline_pages().
> > 
> > Which means that we would have to call __remove_zone() from those paths.
> > But this alone will not work.
> 
> I mean, they move it to the zone ("replacing online/offlining code"), so
> they should take of removing it again.

Yeah, I guess so.

I mean, of course we can make this work by placing __remove_zone in devm_memremap_pages_release
and hmm_devmem_release functions and make sure to call offline_mem_sections first.
But sounds a bit "hacky"..

Thanks
-- 
Oscar Salvador
SUSE L3
