Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2428D6B0007
	for <linux-mm@kvack.org>; Wed,  8 Aug 2018 02:48:01 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id v26-v6so546131eds.9
        for <linux-mm@kvack.org>; Tue, 07 Aug 2018 23:48:01 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h57-v6si3447967eda.329.2018.08.07.23.47.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Aug 2018 23:47:59 -0700 (PDT)
Date: Wed, 8 Aug 2018 08:47:58 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 2/3] mm/memory_hotplug: Create __shrink_pages and
 move it to offline_pages
Message-ID: <20180808064758.GB27972@dhcp22.suse.cz>
References: <20180807133757.18352-1-osalvador@techadventures.net>
 <20180807133757.18352-3-osalvador@techadventures.net>
 <20180807135221.GA3301@redhat.com>
 <20180807145900.GH10003@dhcp22.suse.cz>
 <20180807151810.GB3301@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180807151810.GB3301@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: osalvador@techadventures.net, akpm@linux-foundation.org, dan.j.williams@intel.com, pasha.tatashin@oracle.com, david@redhat.com, yasu.isimatu@gmail.com, logang@deltatee.com, dave.jiang@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Oscar Salvador <osalvador@suse.de>

On Tue 07-08-18 11:18:10, Jerome Glisse wrote:
> On Tue, Aug 07, 2018 at 04:59:00PM +0200, Michal Hocko wrote:
> > On Tue 07-08-18 09:52:21, Jerome Glisse wrote:
> > > On Tue, Aug 07, 2018 at 03:37:56PM +0200, osalvador@techadventures.net wrote:
> > > > From: Oscar Salvador <osalvador@suse.de>
> > > 
> > > [...]
> > > 
> > > > diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> > > > index 9bd629944c91..e33555651e46 100644
> > > > --- a/mm/memory_hotplug.c
> > > > +++ b/mm/memory_hotplug.c
> > > 
> > > [...]
> > > 
> > > >  /**
> > > >   * __remove_pages() - remove sections of pages from a zone
> > > > - * @zone: zone from which pages need to be removed
> > > > + * @nid: node which pages belong to
> > > >   * @phys_start_pfn: starting pageframe (must be aligned to start of a section)
> > > >   * @nr_pages: number of pages to remove (must be multiple of section size)
> > > >   * @altmap: alternative device page map or %NULL if default memmap is used
> > > > @@ -548,7 +557,7 @@ static int __remove_section(struct zone *zone, struct mem_section *ms,
> > > >   * sure that pages are marked reserved and zones are adjust properly by
> > > >   * calling offline_pages().
> > > >   */
> > > > -int __remove_pages(struct zone *zone, unsigned long phys_start_pfn,
> > > > +int __remove_pages(int nid, unsigned long phys_start_pfn,
> > > >  		 unsigned long nr_pages, struct vmem_altmap *altmap)
> > > >  {
> > > >  	unsigned long i;
> > > > @@ -556,10 +565,9 @@ int __remove_pages(struct zone *zone, unsigned long phys_start_pfn,
> > > >  	int sections_to_remove, ret = 0;
> > > >  
> > > >  	/* In the ZONE_DEVICE case device driver owns the memory region */
> > > > -	if (is_dev_zone(zone)) {
> > > > -		if (altmap)
> > > > -			map_offset = vmem_altmap_offset(altmap);
> > > > -	} else {
> > > > +	if (altmap)
> > > > +		map_offset = vmem_altmap_offset(altmap);
> > > > +	else {
> > > 
> > > This will break ZONE_DEVICE at least for HMM. While i think that
> > > altmap -> ZONE_DEVICE (ie altmap imply ZONE_DEVICE) the reverse
> > > is not true ie ZONE_DEVICE does not necessarily imply altmap. So
> > > with the above changes you change the expected behavior.
> > 
> > Could you be more specific what is the expected behavior here?
> > Is this about calling release_mem_region_adjustable? Why does is it not
> > suitable for zone device ranges?
> 
> Correct, you should not call release_mem_region_adjustable() the device
> region is not part of regular iomem resource as it might not necessarily
> be enumerated through known ways to the kernel (ie only the device driver
> can discover the region and core kernel do not know about it).

If there is no region registered with the range then the call should be
mere nop, no? So why do we have to special case?

[...]

> Also in the case they do exist in iomem resource it is as PCIE BAR so
> as IORESOURCE_IO (iirc) and thus release_mem_region_adjustable() would
> return -EINVAL. Thought nothing bad happens because of that, only a
> warning message that might confuse the user.

I am not sure I have understood this correctly. Are you referring to the
current state when we would call release_mem_region_adjustable
unconditionally or the case that the resource would be added also for
zone device ranges?

If the former then I do not see any reason why we couldn't simply
refactor the code to expect a failure and drop the warning in that path.
-- 
Michal Hocko
SUSE Labs
