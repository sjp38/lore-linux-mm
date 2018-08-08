Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id CD7616B0007
	for <linux-mm@kvack.org>; Wed,  8 Aug 2018 17:28:18 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id i16-v6so2798019wrr.9
        for <linux-mm@kvack.org>; Wed, 08 Aug 2018 14:28:18 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e20-v6sor1280136wmh.45.2018.08.08.14.28.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 08 Aug 2018 14:28:17 -0700 (PDT)
Date: Wed, 8 Aug 2018 23:28:15 +0200
From: Oscar Salvador <osalvador@techadventures.net>
Subject: Re: [RFC PATCH 2/3] mm/memory_hotplug: Create __shrink_pages and
 move it to offline_pages
Message-ID: <20180808212815.GA12363@techadventures.net>
References: <20180807133757.18352-1-osalvador@techadventures.net>
 <20180807133757.18352-3-osalvador@techadventures.net>
 <20180807135221.GA3301@redhat.com>
 <20180807145900.GH10003@dhcp22.suse.cz>
 <20180807151810.GB3301@redhat.com>
 <20180808064758.GB27972@dhcp22.suse.cz>
 <20180808165814.GB3429@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180808165814.GB3429@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: Michal Hocko <mhocko@kernel.org>, akpm@linux-foundation.org, dan.j.williams@intel.com, pasha.tatashin@oracle.com, david@redhat.com, yasu.isimatu@gmail.com, logang@deltatee.com, dave.jiang@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Oscar Salvador <osalvador@suse.de>

On Wed, Aug 08, 2018 at 12:58:15PM -0400, Jerome Glisse wrote:
> > If the former then I do not see any reason why we couldn't simply
> > refactor the code to expect a failure and drop the warning in that path.
> 
> Referring to newer case ie calling release_mem_region_adjustable() for
> ZONE_DEVICE too. It seems i got my recollection wrong in the sense that
> the resource is properly register as MEM but still we do not want to
> release it because the device driver might still be using the resource
> without struct page. The lifetime of the resource as memory with struct
> page and the lifetime of the resource as something use by the device
> driver are not tie together. The latter can outlive the former.
> 
> So when we hotremove ZONE_DEVICE we do not want to release the resource
> yet just to be on safe side and avoid some other driver/kernel component
> to decide to use that resource.

I checked the function that hot-removes the memory in HMM code.
hmm_devmem_pages_remove(), which gets called via hmm_devmem_remove(), is in charge
of hot-removing the memory.

Then, hmm_devmem_remove() will release the resource only if the resource is not of
type IORES_DESC_DEVICE_PUBLIC_MEMORY.

So I guess that there are cases(at least in HMM) where we release the resource when
hot-removing memory, but not always.

Looking at devm code, I could not see any place where we release the resource
when hot-removing memory.

So, if we are really left with such scenario, maybe the easiest way is to pass a parameter
from those paths to arch_remove_memory()->__remove_pages() to know
if we get called from device_functions, and so skip the call to release_mem_region_adjustable.

Thanks
-- 
Oscar Salvador
SUSE L3
