Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id C412D6B4606
	for <linux-mm@kvack.org>; Tue, 28 Aug 2018 07:39:27 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id x24-v6so696009edm.13
        for <linux-mm@kvack.org>; Tue, 28 Aug 2018 04:39:27 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 92-v6si333116edb.101.2018.08.28.04.39.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Aug 2018 04:39:26 -0700 (PDT)
Date: Tue, 28 Aug 2018 13:39:24 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] memory_hotplug: fix kernel_panic on offline page
 processing
Message-ID: <20180828113924.GL10223@dhcp22.suse.cz>
References: <20180828090539.41491-1-zaslonko@linux.ibm.com>
 <20180828112543.GK10223@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180828112543.GK10223@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikhail Zaslonko <zaslonko@linux.ibm.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pavel Tatashin <Pavel.Tatashin@microsoft.com>

[Fixup Pavel's email - the patch is here for your reference
http://lkml.kernel.org/r/20180828090539.41491-1-zaslonko@linux.ibm.com]

On Tue 28-08-18 13:25:43, Michal Hocko wrote:
> On Tue 28-08-18 11:05:39, Mikhail Zaslonko wrote:
> > Within show_valid_zones() the function test_pages_in_a_zone() should be
> > called for online memory blocks only. Otherwise it might lead to the
> > VM_BUG_ON due to uninitialized struct pages (when CONFIG_DEBUG_VM_PGFLAGS
> > kernel option is set):
> > 
> >  page dumped because: VM_BUG_ON_PAGE(PagePoisoned(p))
> >  ------------[ cut here ]------------
> >  Call Trace:
> >  ([<000000000038f91e>] test_pages_in_a_zone+0xe6/0x168)
> >   [<0000000000923472>] show_valid_zones+0x5a/0x1a8
> >   [<0000000000900284>] dev_attr_show+0x3c/0x78
> >   [<000000000046f6f0>] sysfs_kf_seq_show+0xd0/0x150
> >   [<00000000003ef662>] seq_read+0x212/0x4b8
> >   [<00000000003bf202>] __vfs_read+0x3a/0x178
> >   [<00000000003bf3ca>] vfs_read+0x8a/0x148
> >   [<00000000003bfa3a>] ksys_read+0x62/0xb8
> >   [<0000000000bc2220>] system_call+0xdc/0x2d8
> > 
> > That VM_BUG_ON was triggered by the page poisoning introduced in
> > mm/sparse.c with the git commit d0dc12e86b31 ("mm/memory_hotplug: optimize
> > memory hotplug")
> > With the same commit the new 'nid' field has been added to the struct
> > memory_block in order to store and later on derive the node id for offline
> > pages (instead of accessing struct page which might be uninitialized). But
> > one reference to nid in show_valid_zones() function has been overlooked.
> > Fixed with current commit.
> > Also, nr_pages will not be used any more after test_pages_in_a_zone() call,
> > do not update it.
> > 
> > Fixes: d0dc12e86b31 ("mm/memory_hotplug: optimize memory hotplug")
> > Cc: <stable@vger.kernel.org> # v4.17+
> > Cc: Pavel Tatashin <pasha.tatashin@oracle.com>
> > Signed-off-by: Mikhail Zaslonko <zaslonko@linux.ibm.com>
> 
> Btw. this land mines which are basically impossible to find during the
> review are the reason why I was not all that happy about d0dc12e86b31.
> It added a margninal improvement but opened a can of warms. On the other
> hand maybe we just had to open that can one day...
> 
> Acked-by: Michal Hocko <mhocko@suse.com>
> 
> Thanks!
> 
> > ---
> >  drivers/base/memory.c | 20 +++++++++-----------
> >  1 file changed, 9 insertions(+), 11 deletions(-)
> > 
> > diff --git a/drivers/base/memory.c b/drivers/base/memory.c
> > index f5e560188a18..622ab8edc035 100644
> > --- a/drivers/base/memory.c
> > +++ b/drivers/base/memory.c
> > @@ -416,26 +416,24 @@ static ssize_t show_valid_zones(struct device *dev,
> >  	struct zone *default_zone;
> >  	int nid;
> >  
> > -	/*
> > -	 * The block contains more than one zone can not be offlined.
> > -	 * This can happen e.g. for ZONE_DMA and ZONE_DMA32
> > -	 */
> > -	if (!test_pages_in_a_zone(start_pfn, start_pfn + nr_pages, &valid_start_pfn, &valid_end_pfn))
> > -		return sprintf(buf, "none\n");
> > -
> > -	start_pfn = valid_start_pfn;
> > -	nr_pages = valid_end_pfn - start_pfn;
> > -
> >  	/*
> >  	 * Check the existing zone. Make sure that we do that only on the
> >  	 * online nodes otherwise the page_zone is not reliable
> >  	 */
> >  	if (mem->state == MEM_ONLINE) {
> > +		/*
> > +		 * The block contains more than one zone can not be offlined.
> > +		 * This can happen e.g. for ZONE_DMA and ZONE_DMA32
> > +		 */
> > +		if (!test_pages_in_a_zone(start_pfn, start_pfn + nr_pages,
> > +					  &valid_start_pfn, &valid_end_pfn))
> > +			return sprintf(buf, "none\n");
> > +		start_pfn = valid_start_pfn;
> >  		strcat(buf, page_zone(pfn_to_page(start_pfn))->name);
> >  		goto out;
> >  	}
> >  
> > -	nid = pfn_to_nid(start_pfn);
> > +	nid = mem->nid;
> >  	default_zone = zone_for_pfn_range(MMOP_ONLINE_KEEP, nid, start_pfn, nr_pages);
> >  	strcat(buf, default_zone->name);
> >  
> > -- 
> > 2.16.4
> 
> -- 
> Michal Hocko
> SUSE Labs

-- 
Michal Hocko
SUSE Labs
