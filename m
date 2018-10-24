Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5F1B86B0269
	for <linux-mm@kvack.org>; Wed, 24 Oct 2018 13:35:11 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id w15-v6so3439006pge.2
        for <linux-mm@kvack.org>; Wed, 24 Oct 2018 10:35:11 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id i35-v6si5121021plg.361.2018.10.24.10.35.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Oct 2018 10:35:10 -0700 (PDT)
Message-ID: <15bf78bdadd282b0587097d49cc39d0d7b662736.camel@linux.intel.com>
Subject: Re: [mm PATCH v3 4/6] mm: Move hot-plug specific memory init into
 separate functions and optimize
From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
Date: Wed, 24 Oct 2018 10:35:09 -0700
In-Reply-To: <20181024152742.GJ18839@dhcp22.suse.cz>
References: <20181015202456.2171.88406.stgit@localhost.localdomain>
	 <20181015202716.2171.7284.stgit@localhost.localdomain>
	 <20181017091824.GL18839@dhcp22.suse.cz>
	 <d9011108-4099-58dc-8b8c-110c5f2a3674@linux.intel.com>
	 <20181024123640.GF18839@dhcp22.suse.cz>
	 <40b17814b2a65531c5059e52a61c8f41b9603904.camel@linux.intel.com>
	 <20181024152742.GJ18839@dhcp22.suse.cz>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, pavel.tatashin@microsoft.com, dave.jiang@intel.com, linux-kernel@vger.kernel.org, willy@infradead.org, davem@davemloft.net, yi.z.zhang@linux.intel.com, khalid.aziz@oracle.com, rppt@linux.vnet.ibm.com, vbabka@suse.cz, sparclinux@vger.kernel.org, dan.j.williams@intel.com, ldufour@linux.vnet.ibm.com, mgorman@techsingularity.net, mingo@kernel.org, kirill.shutemov@linux.intel.com

On Wed, 2018-10-24 at 17:27 +0200, Michal Hocko wrote:
> On Wed 24-10-18 08:08:41, Alexander Duyck wrote:
> > On Wed, 2018-10-24 at 14:36 +0200, Michal Hocko wrote:
> > > On Wed 17-10-18 08:26:20, Alexander Duyck wrote:
> > > [...]
> > > > With that said I am also wondering if a possible solution to
> > > > the complaints you had would be to look at just exporting the
> > > > __init_pageblock function later and moving the call to
> > > > memmap_init_zone_device out to the memremap or hotplug code
> > > > when Dan gets the refactoring for HMM and memremap all sorted
> > > > out.
> > > 
> > > Why cannot we simply provide a constructor for each page by the
> > > caller if there are special requirements? we currently have
> > > alt_map
> > > to do struct page allocation but nothing really prevents to make
> > > it
> > > more generic and control both allocation and initialization
> > > whatever
> > > suits a specific usecase. I really do not want make special cases
> > > here and there.
> > 
> > The advantage to the current __init_pageblock function is that we
> > end up constructing everything we are going to write outside of the
> > main loop and then are focused only on init.
> 
> But we do really want move_pfn_range_to_zone to provide a usable pfn
> range without any additional tweaks. If there are potential
> optimizations to be done there then let's do it but please do not try
> to micro optimize to the point that the interface doesn't make any
> sense anymore.

The actual difference between the two setups is not all that great.
>From the sound of things the ultimate difference between the
ZONE_DEVICE pages and regular pages is the pgmap and if we want the
reserved bit set or not.

What I am providing with __init_pageblock at this point is a function
that is flexible enough for us to be able to do either one and then
just expose a different front end on it for the specific type of page
we have to initialize. It works for regular hotplug, ZONE_DEVICE, and
deferred memory initialization. The way I view it is that this funciton
is a high performance multi-tasker, not something that is micro-
optimized for any one specific function.

Thanks.

- Alex
