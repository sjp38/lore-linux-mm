Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 08C546B0008
	for <linux-mm@kvack.org>; Thu, 19 Jul 2018 11:16:00 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id s18-v6so3420411edr.15
        for <linux-mm@kvack.org>; Thu, 19 Jul 2018 08:15:59 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 3-v6si1199914edc.284.2018.07.19.08.15.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Jul 2018 08:15:58 -0700 (PDT)
Date: Thu, 19 Jul 2018 17:15:55 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 3/5] mm/page_alloc: Optimize free_area_init_core
Message-ID: <20180719151555.GH7193@dhcp22.suse.cz>
References: <20180719132740.32743-1-osalvador@techadventures.net>
 <20180719132740.32743-4-osalvador@techadventures.net>
 <20180719134417.GC7193@dhcp22.suse.cz>
 <20180719140327.GB10988@techadventures.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180719140327.GB10988@techadventures.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oscar Salvador <osalvador@techadventures.net>
Cc: akpm@linux-foundation.org, pasha.tatashin@oracle.com, vbabka@suse.cz, aaron.lu@intel.com, iamjoonsoo.kim@lge.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Oscar Salvador <osalvador@suse.de>

On Thu 19-07-18 16:03:27, Oscar Salvador wrote:
> On Thu, Jul 19, 2018 at 03:44:17PM +0200, Michal Hocko wrote:
> > On Thu 19-07-18 15:27:38, osalvador@techadventures.net wrote:
> > > From: Oscar Salvador <osalvador@suse.de>
> > > 
> > > In free_area_init_core we calculate the amount of managed pages
> > > we are left with, by substracting the memmap pages and the pages
> > > reserved for dma.
> > > With the values left, we also account the total of kernel pages and
> > > the total of pages.
> > > 
> > > Since memmap pages are calculated from zone->spanned_pages,
> > > let us only do these calculcations whenever zone->spanned_pages is greather
> > > than 0.
> > 
> > But why do we care? How do we test this? In other words, why is this
> > worth merging?
>  
> Uhm, unless the values are going to be updated, why do we want to go through all
> comparasions/checks?
> I thought it was a nice thing to have the chance to skip that block unless we are going to
> update the counters.
> 
> Again, if you think this only adds complexity and no good, I can drop it.

Your changelog doesn't really explain the motivation. Does the change
help performance? Is this a pure cleanup?

The function is certainly not an example of beauty. It is more an
example of changes done on top of older ones without much thinking. But
I do not see your change would make it so much better. I would consider
it a much nicer cleanup if it was split into logical units each doing
one specific thing.

Btw. are you sure this change is correct? E.g.
		/*
		 * Set an approximate value for lowmem here, it will be adjusted
		 * when the bootmem allocator frees pages into the buddy system.
		 * And all highmem pages will be managed by the buddy system.
		 */
		zone->managed_pages = is_highmem_idx(j) ? realsize : freesize;

expects freesize to be calculated properly and just from quick reading
the code I do not see why skipping other adjustments is ok for size > 0.
Maybe this is OK, I dunno and my brain is already heading few days off
but a real cleanup wouldn't even make me think what the heck is going on
here.

-- 
Michal Hocko
SUSE Labs
