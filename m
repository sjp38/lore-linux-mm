Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 792FB6B0259
	for <linux-mm@kvack.org>; Thu, 10 Dec 2015 09:06:34 -0500 (EST)
Received: by mail-wm0-f41.google.com with SMTP id w144so25354592wmw.1
        for <linux-mm@kvack.org>; Thu, 10 Dec 2015 06:06:34 -0800 (PST)
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com. [74.125.82.43])
        by mx.google.com with ESMTPS id r62si1356269wmg.24.2015.12.10.06.06.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Dec 2015 06:06:33 -0800 (PST)
Received: by wmec201 with SMTP id c201so26324579wme.1
        for <linux-mm@kvack.org>; Thu, 10 Dec 2015 06:06:33 -0800 (PST)
Date: Thu, 10 Dec 2015 15:06:31 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: m(un)map kmalloc buffers to userspace
Message-ID: <20151210140631.GO19496@dhcp22.suse.cz>
References: <5667128B.3080704@sigmadesigns.com>
 <20151209135544.GE30907@dhcp22.suse.cz>
 <566835B6.9010605@sigmadesigns.com>
 <20151209143207.GF30907@dhcp22.suse.cz>
 <56684062.9090505@sigmadesigns.com>
 <20151209151254.GH30907@dhcp22.suse.cz>
 <56684A59.7030605@sigmadesigns.com>
 <20151210114005.GF19496@dhcp22.suse.cz>
 <56698022.1070305@sigmadesigns.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <56698022.1070305@sigmadesigns.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sebastian Frias <sebastian_frias@sigmadesigns.com>
Cc: Marc Gonzalez <marc_gonzalez@sigmadesigns.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu 10-12-15 14:37:38, Sebastian Frias wrote:
> On 12/10/2015 12:40 PM, Michal Hocko wrote:
> >On Wed 09-12-15 16:35:53, Sebastian Frias wrote:
> >[...]
> >>We've seen that drivers/media/pci/zoran/zoran_driver.c for example seems to
> >>be doing as us kmalloc+remap_pfn_range,
> >
> >This driver is broken - I will post a patch.
> 
> Ok, we'll be glad to see a good example, please keep us posted.
> 
> >
> >>is there any guarantee (or at least an advised heuristic) to determine
> >>if a driver is "current" (ie: uses the latest APIs and works)?
> >
> >OK, it seems I was overly optimistic when directing you to existing
> >drivers. Sorry about that I wasn't aware you could find such a terrible
> >code there. Please refer to Linux Device Drivers book which should give
> >you a much better lead (e.g. http://www.makelinux.net/ldd3/chp-15-sect-2)
> >
> 
> Thank you for the link.
> The current code of our driver was has portions written following LDD3,
> however, we it seems that LDD3 advice is not relevant anymore.
> Indeed, it talks about VM_RESERVED, it talks about using "nopage" and it
> says that remap_pfn_range cannot be used for pages from get_user_page (or
> kmalloc).

Heh, it seems that we are indeed outdated there as well. The memory
management code doesn't really require pages to be reserved and it
allows to use get_user_page(s) memory to be mapped to user ptes.
remap_pfn_range will set all the appropriate flags to make sure MM code
will not stumble over those pages and let's the driver to take care of
the memory deallocation.

> It seems such assertions are valid on older kernels, because the code stops
> working on 3.4+ if we use remap_pfn_range the same way than
> drivers/media/pci/zoran/zoran_driver.c
> However, kmalloc+remap_pfn_range does work on 4.1.13+

As I've said nothing will guarantee that the kmalloc returned address
will be page aligned so you might corrupt slab internal data structures.
You might allocate a larger buffer via kmalloc and make sure it is
aligned properly but I fail to see why should be kmalloc used in the
first place as you need a memory in page size unnits anyway.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
