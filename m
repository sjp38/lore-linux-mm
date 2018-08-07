Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id E75566B026D
	for <linux-mm@kvack.org>; Tue,  7 Aug 2018 11:18:13 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id l15-v6so16753855qki.18
        for <linux-mm@kvack.org>; Tue, 07 Aug 2018 08:18:13 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id u87-v6si1262519qkl.29.2018.08.07.08.18.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Aug 2018 08:18:13 -0700 (PDT)
Date: Tue, 7 Aug 2018 11:18:10 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [RFC PATCH 2/3] mm/memory_hotplug: Create __shrink_pages and
 move it to offline_pages
Message-ID: <20180807151810.GB3301@redhat.com>
References: <20180807133757.18352-1-osalvador@techadventures.net>
 <20180807133757.18352-3-osalvador@techadventures.net>
 <20180807135221.GA3301@redhat.com>
 <20180807145900.GH10003@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20180807145900.GH10003@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: osalvador@techadventures.net, akpm@linux-foundation.org, dan.j.williams@intel.com, pasha.tatashin@oracle.com, david@redhat.com, yasu.isimatu@gmail.com, logang@deltatee.com, dave.jiang@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Oscar Salvador <osalvador@suse.de>

On Tue, Aug 07, 2018 at 04:59:00PM +0200, Michal Hocko wrote:
> On Tue 07-08-18 09:52:21, Jerome Glisse wrote:
> > On Tue, Aug 07, 2018 at 03:37:56PM +0200, osalvador@techadventures.net wrote:
> > > From: Oscar Salvador <osalvador@suse.de>
> > 
> > [...]
> > 
> > > diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> > > index 9bd629944c91..e33555651e46 100644
> > > --- a/mm/memory_hotplug.c
> > > +++ b/mm/memory_hotplug.c
> > 
> > [...]
> > 
> > >  /**
> > >   * __remove_pages() - remove sections of pages from a zone
> > > - * @zone: zone from which pages need to be removed
> > > + * @nid: node which pages belong to
> > >   * @phys_start_pfn: starting pageframe (must be aligned to start of a section)
> > >   * @nr_pages: number of pages to remove (must be multiple of section size)
> > >   * @altmap: alternative device page map or %NULL if default memmap is used
> > > @@ -548,7 +557,7 @@ static int __remove_section(struct zone *zone, struct mem_section *ms,
> > >   * sure that pages are marked reserved and zones are adjust properly by
> > >   * calling offline_pages().
> > >   */
> > > -int __remove_pages(struct zone *zone, unsigned long phys_start_pfn,
> > > +int __remove_pages(int nid, unsigned long phys_start_pfn,
> > >  		 unsigned long nr_pages, struct vmem_altmap *altmap)
> > >  {
> > >  	unsigned long i;
> > > @@ -556,10 +565,9 @@ int __remove_pages(struct zone *zone, unsigned long phys_start_pfn,
> > >  	int sections_to_remove, ret = 0;
> > >  
> > >  	/* In the ZONE_DEVICE case device driver owns the memory region */
> > > -	if (is_dev_zone(zone)) {
> > > -		if (altmap)
> > > -			map_offset = vmem_altmap_offset(altmap);
> > > -	} else {
> > > +	if (altmap)
> > > +		map_offset = vmem_altmap_offset(altmap);
> > > +	else {
> > 
> > This will break ZONE_DEVICE at least for HMM. While i think that
> > altmap -> ZONE_DEVICE (ie altmap imply ZONE_DEVICE) the reverse
> > is not true ie ZONE_DEVICE does not necessarily imply altmap. So
> > with the above changes you change the expected behavior.
> 
> Could you be more specific what is the expected behavior here?
> Is this about calling release_mem_region_adjustable? Why does is it not
> suitable for zone device ranges?

Correct, you should not call release_mem_region_adjustable() the device
region is not part of regular iomem resource as it might not necessarily
be enumerated through known ways to the kernel (ie only the device driver
can discover the region and core kernel do not know about it).

One of the issue to adding this region to iomem resource is that they
really need to be ignored by core kernel because you can not assume that
CPU can actually access them. Moreover, if CPU can access them it is
likely that CPU can not do atomic operation on them (ie what happens on
a CPU atomic instruction is undefined). So they are _special_ and only
make sense to be use in conjunction with a device driver.


Also in the case they do exist in iomem resource it is as PCIE BAR so
as IORESOURCE_IO (iirc) and thus release_mem_region_adjustable() would
return -EINVAL. Thought nothing bad happens because of that, only a
warning message that might confuse the user.

Cheers,
Jerome
