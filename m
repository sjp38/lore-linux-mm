Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id A8D346B0006
	for <linux-mm@kvack.org>; Thu, 19 Jul 2018 16:52:39 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id d18-v6so4246361wrq.21
        for <linux-mm@kvack.org>; Thu, 19 Jul 2018 13:52:39 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i71-v6sor52601wri.49.2018.07.19.13.52.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 19 Jul 2018 13:52:36 -0700 (PDT)
Date: Thu, 19 Jul 2018 22:52:35 +0200
From: Oscar Salvador <osalvador@techadventures.net>
Subject: Re: [PATCH v2 3/5] mm/page_alloc: Optimize free_area_init_core
Message-ID: <20180719205235.GA14010@techadventures.net>
References: <20180719132740.32743-1-osalvador@techadventures.net>
 <20180719132740.32743-4-osalvador@techadventures.net>
 <20180719134417.GC7193@dhcp22.suse.cz>
 <20180719140327.GB10988@techadventures.net>
 <20180719151555.GH7193@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180719151555.GH7193@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: akpm@linux-foundation.org, pasha.tatashin@oracle.com, vbabka@suse.cz, aaron.lu@intel.com, iamjoonsoo.kim@lge.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Oscar Salvador <osalvador@suse.de>

On Thu, Jul 19, 2018 at 05:15:55PM +0200, Michal Hocko wrote:
> Your changelog doesn't really explain the motivation. Does the change
> help performance? Is this a pure cleanup?

Hi Michal,

Sorry to not have explained this better from the very beginning.

It should help a bit in performance terms as we would be skipping those
condition checks and assignations for zones that do not have any pages.
It is not a huge win, but I think that skipping code we do not really need to run
is worh to have.

> The function is certainly not an example of beauty. It is more an
> example of changes done on top of older ones without much thinking. But
> I do not see your change would make it so much better. I would consider
> it a much nicer cleanup if it was split into logical units each doing
> one specific thing.

About the cleanup, I thought that moving that block of code to a separate function
would make the code easier to follow.
If you think that this is still not enough, I can try to split it and see the outcome.

> Btw. are you sure this change is correct? E.g.
> 		/*
> 		 * Set an approximate value for lowmem here, it will be adjusted
> 		 * when the bootmem allocator frees pages into the buddy system.
> 		 * And all highmem pages will be managed by the buddy system.
> 		 */
> 		zone->managed_pages = is_highmem_idx(j) ? realsize : freesize;
> 
> expects freesize to be calculated properly and just from quick reading
> the code I do not see why skipping other adjustments is ok for size > 0.
> Maybe this is OK, I dunno and my brain is already heading few days off
> but a real cleanup wouldn't even make me think what the heck is going on
> here.

This changed in commit e69438596bb3e97809e76be315e54a4a444f4797.
Current code does not have "realsize" anymore.

Thanks
-- 
Oscar Salvador
SUSE L3
