Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id DF1238E0001
	for <linux-mm@kvack.org>; Fri, 28 Dec 2018 14:52:28 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id q62so20561891pgq.9
        for <linux-mm@kvack.org>; Fri, 28 Dec 2018 11:52:28 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h36si19548846pgm.200.2018.12.28.11.52.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 28 Dec 2018 11:52:27 -0800 (PST)
Date: Fri, 28 Dec 2018 20:52:24 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC][PATCH v2 00/21] PMEM NUMA node and hotness
 accounting/migration
Message-ID: <20181228195224.GY16738@dhcp22.suse.cz>
References: <20181226131446.330864849@intel.com>
 <20181227203158.GO16738@dhcp22.suse.cz>
 <20181228050806.ewpxtwo3fpw7h3lq@wfg-t540p.sh.intel.com>
 <20181228084105.GQ16738@dhcp22.suse.cz>
 <20181228094208.7lgxhha34zpqu4db@wfg-t540p.sh.intel.com>
 <20181228121515.GS16738@dhcp22.suse.cz>
 <20181228133111.zromvopkfcg3m5oy@wfg-t540p.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181228133111.zromvopkfcg3m5oy@wfg-t540p.sh.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, kvm@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Fan Du <fan.du@intel.com>, Yao Yuan <yuan.yao@intel.com>, Peng Dong <dongx.peng@intel.com>, Huang Ying <ying.huang@intel.com>, Liu Jingqi <jingqi.liu@intel.com>, Dong Eddie <eddie.dong@intel.com>, Dave Hansen <dave.hansen@intel.com>, Zhang Yi <yi.z.zhang@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>

[Ccing Mel and Andrea]

On Fri 28-12-18 21:31:11, Wu Fengguang wrote:
> > > > I haven't looked at the implementation yet but if you are proposing a
> > > > special cased zone lists then this is something CDM (Coherent Device
> > > > Memory) was trying to do two years ago and there was quite some
> > > > skepticism in the approach.
> > > 
> > > It looks we are pretty different than CDM. :)
> > > We creating new NUMA nodes rather than CDM's new ZONE.
> > > The zonelists modification is just to make PMEM nodes more separated.
> > 
> > Yes, this is exactly what CDM was after. Have a zone which is not
> > reachable without explicit request AFAIR. So no, I do not think you are
> > too different, you just use a different terminology ;)
> 
> Got it. OK.. The fall back zonelists patch does need more thoughts.
> 
> In long term POV, Linux should be prepared for multi-level memory.
> Then there will arise the need to "allocate from this level memory".
> So it looks good to have separated zonelists for each level of memory.

Well, I do not have a good answer for you here. We do not have good
experiences with those systems, I am afraid. NUMA is with us for more
than a decade yet our APIs are coarse to say the least and broken at so
many times as well. Starting a new API just based on PMEM sounds like a
ticket to another disaster to me.

I would like to see solid arguments why the current model of numa nodes
with fallback in distances order cannot be used for those new
technologies in the beginning and develop something better based on our
experiences that we gain on the way.

I would be especially interested about a possibility of the memory
migration idea during a memory pressure and relying on numa balancing to
resort the locality on demand rather than hiding certain NUMA nodes or
zones from the allocator and expose them only to the userspace.

> On the other hand, there will also be page allocations that don't care
> about the exact memory level. So it looks reasonable to expect
> different kind of fallback zonelists that can be selected by NUMA policy.
> 
> Thanks,
> Fengguang

-- 
Michal Hocko
SUSE Labs
