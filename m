Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 466318E0001
	for <linux-mm@kvack.org>; Thu, 27 Sep 2018 07:09:30 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id d8-v6so2887309edq.11
        for <linux-mm@kvack.org>; Thu, 27 Sep 2018 04:09:30 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a21-v6si757323edr.179.2018.09.27.04.09.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Sep 2018 04:09:28 -0700 (PDT)
Date: Thu, 27 Sep 2018 13:09:26 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v5 4/4] mm: Defer ZONE_DEVICE page initialization to the
 point where we init pgmap
Message-ID: <20180927110926.GE6278@dhcp22.suse.cz>
References: <20180925200551.3576.18755.stgit@localhost.localdomain>
 <20180925202053.3576.66039.stgit@localhost.localdomain>
 <20180926075540.GD6278@dhcp22.suse.cz>
 <6f87a5d7-05e2-00f4-8568-bb3521869cea@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <6f87a5d7-05e2-00f4-8568-bb3521869cea@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Duyck <alexander.h.duyck@linux.intel.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-nvdimm@lists.01.org, pavel.tatashin@microsoft.com, dave.jiang@intel.com, dave.hansen@intel.com, jglisse@redhat.com, rppt@linux.vnet.ibm.com, dan.j.williams@intel.com, logang@deltatee.com, mingo@kernel.org, kirill.shutemov@linux.intel.com

On Wed 26-09-18 11:25:37, Alexander Duyck wrote:
> 
> 
> On 9/26/2018 12:55 AM, Michal Hocko wrote:
> > On Tue 25-09-18 13:21:24, Alexander Duyck wrote:
> > > The ZONE_DEVICE pages were being initialized in two locations. One was with
> > > the memory_hotplug lock held and another was outside of that lock. The
> > > problem with this is that it was nearly doubling the memory initialization
> > > time. Instead of doing this twice, once while holding a global lock and
> > > once without, I am opting to defer the initialization to the one outside of
> > > the lock. This allows us to avoid serializing the overhead for memory init
> > > and we can instead focus on per-node init times.
> > > 
> > > One issue I encountered is that devm_memremap_pages and
> > > hmm_devmmem_pages_create were initializing only the pgmap field the same
> > > way. One wasn't initializing hmm_data, and the other was initializing it to
> > > a poison value. Since this is something that is exposed to the driver in
> > > the case of hmm I am opting for a third option and just initializing
> > > hmm_data to 0 since this is going to be exposed to unknown third party
> > > drivers.
> > 
> > Why cannot you pull move_pfn_range_to_zone out of the hotplug lock? In
> > other words why are you making zone device even more special in the
> > generic hotplug code when it already has its own means to initialize the
> > pfn range by calling move_pfn_range_to_zone. Not to mention the code
> > duplication.
> 
> So there were a few things I wasn't sure we could pull outside of the
> hotplug lock. One specific example is the bits related to resizing the pgdat
> and zone. I wanted to avoid pulling those bits outside of the hotplug lock.

Why would that be a problem. There are dedicated locks for resizing.

> The other bit that I left inside the hot-plug lock with this approach was
> the initialization of the pages that contain the vmemmap.

Again, why this is needed?

> > That being said I really dislike this patch.
> 
> In my mind this was a patch that "killed two birds with one stone". I had
> two issues to address, the first one being the fact that we were performing
> the memmap_init_zone while holding the hotplug lock, and the other being the
> loop that was going through and initializing pgmap in the hmm and memremap
> calls essentially added another 20 seconds (measured for 3TB of memory per
> node) to the init time. With this patch I was able to cut my init time per
> node by that 20 seconds, and then made it so that we could scale as we added
> nodes as they could run in parallel.
> 
> With that said I am open to suggestions if you still feel like I need to
> follow this up with some additional work. I just want to avoid introducing
> any regressions in regards to functionality or performance.

Yes, I really do prefer this to be done properly rather than tweak it
around because of uncertainties.
-- 
Michal Hocko
SUSE Labs
