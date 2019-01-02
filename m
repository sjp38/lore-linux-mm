Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f199.google.com (mail-oi1-f199.google.com [209.85.167.199])
	by kanga.kvack.org (Postfix) with ESMTP id 18DEC8E0002
	for <linux-mm@kvack.org>; Wed,  2 Jan 2019 07:22:06 -0500 (EST)
Received: by mail-oi1-f199.google.com with SMTP id b18so22342671oii.1
        for <linux-mm@kvack.org>; Wed, 02 Jan 2019 04:22:06 -0800 (PST)
Received: from huawei.com (szxga06-in.huawei.com. [45.249.212.32])
        by mx.google.com with ESMTPS id i9si24195303oth.116.2019.01.02.04.22.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Jan 2019 04:22:04 -0800 (PST)
Date: Wed, 2 Jan 2019 12:21:10 +0000
From: Jonathan Cameron <jonathan.cameron@huawei.com>
Subject: Re: [RFC][PATCH v2 00/21] PMEM NUMA node and hotness
 accounting/migration
Message-ID: <20190102122110.00000206@huawei.com>
In-Reply-To: <20181228195224.GY16738@dhcp22.suse.cz>
References: <20181226131446.330864849@intel.com>
	<20181227203158.GO16738@dhcp22.suse.cz>
	<20181228050806.ewpxtwo3fpw7h3lq@wfg-t540p.sh.intel.com>
	<20181228084105.GQ16738@dhcp22.suse.cz>
	<20181228094208.7lgxhha34zpqu4db@wfg-t540p.sh.intel.com>
	<20181228121515.GS16738@dhcp22.suse.cz>
	<20181228133111.zromvopkfcg3m5oy@wfg-t540p.sh.intel.com>
	<20181228195224.GY16738@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Fengguang Wu <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, kvm@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Fan Du <fan.du@intel.com>, Yao Yuan <yuan.yao@intel.com>, Peng Dong <dongx.peng@intel.com>, Huang Ying <ying.huang@intel.com>, Liu Jingqi <jingqi.liu@intel.com>, Dong Eddie <eddie.dong@intel.com>, Dave Hansen <dave.hansen@intel.com>, Zhang Yi <yi.z.zhang@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>, Mel  Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, linux-accelerators@lists.ozlabs.org

On Fri, 28 Dec 2018 20:52:24 +0100
Michal Hocko <mhocko@kernel.org> wrote:

> [Ccing Mel and Andrea]
> 
> On Fri 28-12-18 21:31:11, Wu Fengguang wrote:
> > > > > I haven't looked at the implementation yet but if you are proposing a
> > > > > special cased zone lists then this is something CDM (Coherent Device
> > > > > Memory) was trying to do two years ago and there was quite some
> > > > > skepticism in the approach.  
> > > > 
> > > > It looks we are pretty different than CDM. :)
> > > > We creating new NUMA nodes rather than CDM's new ZONE.
> > > > The zonelists modification is just to make PMEM nodes more separated.  
> > > 
> > > Yes, this is exactly what CDM was after. Have a zone which is not
> > > reachable without explicit request AFAIR. So no, I do not think you are
> > > too different, you just use a different terminology ;)  
> > 
> > Got it. OK.. The fall back zonelists patch does need more thoughts.
> > 
> > In long term POV, Linux should be prepared for multi-level memory.
> > Then there will arise the need to "allocate from this level memory".
> > So it looks good to have separated zonelists for each level of memory.  
> 
> Well, I do not have a good answer for you here. We do not have good
> experiences with those systems, I am afraid. NUMA is with us for more
> than a decade yet our APIs are coarse to say the least and broken at so
> many times as well. Starting a new API just based on PMEM sounds like a
> ticket to another disaster to me.
> 
> I would like to see solid arguments why the current model of numa nodes
> with fallback in distances order cannot be used for those new
> technologies in the beginning and develop something better based on our
> experiences that we gain on the way.
> 
> I would be especially interested about a possibility of the memory
> migration idea during a memory pressure and relying on numa balancing to
> resort the locality on demand rather than hiding certain NUMA nodes or
> zones from the allocator and expose them only to the userspace.

This is indeed a very interesting direction.  I'm coming at this from a CCIX
point of view.  Ignore the next bit of you are already familiar with CCIX :)

Main thing CCIX brings is that memory can be fully coherent
anywhere in the system including out near accelerators, all via shared physical
address space, leveraging ATS / IOMMUs / MMUs to do translations. Result is a
big and possibly extremely heterogenous NUMA system.  All the setup is done in
firmware so by the time the kernel sees it everything is in SRAT / SLIT
/ NFIT / HMAT etc.

We have a few usecases that need some more fine grained control combined with
automated balancing.  So far we've been messing with nasty tricks like
hotplugging memory after boot a long way away, or the original CDM zone patches
(knowing they weren't likely to go anywhere!)  Userspace is all hand tuned
which is not great in the long run...

Use cases (I've probably missed some):

* Storage Class Memory near to the host CPU / DRAM controllers (pretty much
  the same as this series is considering).  Note that there isn't necessarily
  any 'pairing' with host DRAM as seen in this RFC.  A typical system might have
  a large single pool with similar access characteristics from each host SOC.
  The paired approach is probably going to be common in early systems though.
  Also not necessarily Non Volatile, could just be a big DDR expansion board.

* RAM out near an accelerator. Aim would be to migrate data to that RAM if
  the access patterns from the accelerator justify it being there rather than
  near any of the host CPUs.  In a memory pressure on host situation anything
  could be pushed out there as probably still better than swapping.
  Note that this would require some knowledge of 'who' is doing the accessing
  which isn't needed for what this RFC is doing.

* Hot pages may not be hot just because the host is using them a lot.  It would be
  very useful to have a means of adding information available from accelerators
  beyond simple accessed bits (dreaming ;)  One problem here is translation
  caches (ATCs) as they won't normally result in any updates to the page accessed
  bits.  The arm SMMU v3 spec for example makes it clear (though it's kind of
  obvious) that the ATS request is the only opportunity to update the accessed
  bit.  The nasty option here would be to periodically flush the ATC to force
  the access bit updates via repeats of the ATS request (ouch).
  That option only works if the iommu supports updating the accessed flag
  (optional on SMMU v3 for example).

We need the explicit placement, but can get that from existing NUMA controls.
More of a concern is persuading the kernel it really doesn't want to put
it's data structures in distant memory as it can be very very distant.

So ideally I'd love this set to head in a direction that helps me tick off
at least some of the above usecases and hopefully have some visibility on
how to address the others moving forwards,

Good to see some new thoughts in this area!

Jonathan
> 
> > On the other hand, there will also be page allocations that don't care
> > about the exact memory level. So it looks reasonable to expect
> > different kind of fallback zonelists that can be selected by NUMA policy.
> > 
> > Thanks,
> > Fengguang  
> 
