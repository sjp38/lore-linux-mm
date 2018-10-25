Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id DC2F96B0293
	for <linux-mm@kvack.org>; Thu, 25 Oct 2018 08:41:19 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id 134-v6so5278042pga.1
        for <linux-mm@kvack.org>; Thu, 25 Oct 2018 05:41:19 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g17-v6si8079731pfo.130.2018.10.25.05.41.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Oct 2018 05:41:18 -0700 (PDT)
Date: Thu, 25 Oct 2018 14:41:15 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [mm PATCH v3 4/6] mm: Move hot-plug specific memory init into
 separate functions and optimize
Message-ID: <20181025124115.GQ18839@dhcp22.suse.cz>
References: <20181015202456.2171.88406.stgit@localhost.localdomain>
 <20181015202716.2171.7284.stgit@localhost.localdomain>
 <20181017091824.GL18839@dhcp22.suse.cz>
 <d9011108-4099-58dc-8b8c-110c5f2a3674@linux.intel.com>
 <20181024123640.GF18839@dhcp22.suse.cz>
 <40b17814b2a65531c5059e52a61c8f41b9603904.camel@linux.intel.com>
 <20181024152742.GJ18839@dhcp22.suse.cz>
 <15bf78bdadd282b0587097d49cc39d0d7b662736.camel@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <15bf78bdadd282b0587097d49cc39d0d7b662736.camel@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Duyck <alexander.h.duyck@linux.intel.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, pavel.tatashin@microsoft.com, dave.jiang@intel.com, linux-kernel@vger.kernel.org, willy@infradead.org, davem@davemloft.net, yi.z.zhang@linux.intel.com, khalid.aziz@oracle.com, rppt@linux.vnet.ibm.com, vbabka@suse.cz, sparclinux@vger.kernel.org, dan.j.williams@intel.com, ldufour@linux.vnet.ibm.com, mgorman@techsingularity.net, mingo@kernel.org, kirill.shutemov@linux.intel.com

On Wed 24-10-18 10:35:09, Alexander Duyck wrote:
> On Wed, 2018-10-24 at 17:27 +0200, Michal Hocko wrote:
> > On Wed 24-10-18 08:08:41, Alexander Duyck wrote:
> > > On Wed, 2018-10-24 at 14:36 +0200, Michal Hocko wrote:
> > > > On Wed 17-10-18 08:26:20, Alexander Duyck wrote:
> > > > [...]
> > > > > With that said I am also wondering if a possible solution to
> > > > > the complaints you had would be to look at just exporting the
> > > > > __init_pageblock function later and moving the call to
> > > > > memmap_init_zone_device out to the memremap or hotplug code
> > > > > when Dan gets the refactoring for HMM and memremap all sorted
> > > > > out.
> > > > 
> > > > Why cannot we simply provide a constructor for each page by the
> > > > caller if there are special requirements? we currently have
> > > > alt_map
> > > > to do struct page allocation but nothing really prevents to make
> > > > it
> > > > more generic and control both allocation and initialization
> > > > whatever
> > > > suits a specific usecase. I really do not want make special cases
> > > > here and there.
> > > 
> > > The advantage to the current __init_pageblock function is that we
> > > end up constructing everything we are going to write outside of the
> > > main loop and then are focused only on init.
> > 
> > But we do really want move_pfn_range_to_zone to provide a usable pfn
> > range without any additional tweaks. If there are potential
> > optimizations to be done there then let's do it but please do not try
> > to micro optimize to the point that the interface doesn't make any
> > sense anymore.
> 
> The actual difference between the two setups is not all that great.
> >From the sound of things the ultimate difference between the
> ZONE_DEVICE pages and regular pages is the pgmap and if we want the
> reserved bit set or not.

So once again, why do you need PageReserved in the first place. Alos it
seems that pgmap can hold both the struct page allocator and
constructor.

> What I am providing with __init_pageblock at this point is a function
> that is flexible enough for us to be able to do either one and then
> just expose a different front end on it for the specific type of page
> we have to initialize. It works for regular hotplug, ZONE_DEVICE, and
> deferred memory initialization. The way I view it is that this funciton
> is a high performance multi-tasker, not something that is micro-
> optimized for any one specific function.

All that I argue about is that all this should live inside the core
hotplug. If you can plumb it there without hacks I have seen earlier
then I do not mind but let's try to keep the core infrastructure as
clelan as possible.
-- 
Michal Hocko
SUSE Labs
