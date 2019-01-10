Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 836F68E0001
	for <linux-mm@kvack.org>; Thu, 10 Jan 2019 11:26:04 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id j5so11243978qtk.11
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 08:26:04 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t23si1045496qtp.212.2019.01.10.08.26.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Jan 2019 08:26:03 -0800 (PST)
Date: Thu, 10 Jan 2019 11:25:56 -0500
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [RFC][PATCH v2 00/21] PMEM NUMA node and hotness
 accounting/migration
Message-ID: <20190110162556.GC4394@redhat.com>
References: <20181226131446.330864849@intel.com>
 <20181227203158.GO16738@dhcp22.suse.cz>
 <20181228050806.ewpxtwo3fpw7h3lq@wfg-t540p.sh.intel.com>
 <20181228084105.GQ16738@dhcp22.suse.cz>
 <20181228094208.7lgxhha34zpqu4db@wfg-t540p.sh.intel.com>
 <20181228121515.GS16738@dhcp22.suse.cz>
 <20181228133111.zromvopkfcg3m5oy@wfg-t540p.sh.intel.com>
 <20181228195224.GY16738@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20181228195224.GY16738@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Fengguang Wu <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, kvm@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Fan Du <fan.du@intel.com>, Yao Yuan <yuan.yao@intel.com>, Peng Dong <dongx.peng@intel.com>, Huang Ying <ying.huang@intel.com>, Liu Jingqi <jingqi.liu@intel.com>, Dong Eddie <eddie.dong@intel.com>, Dave Hansen <dave.hansen@intel.com>, Zhang Yi <yi.z.zhang@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>

On Fri, Dec 28, 2018 at 08:52:24PM +0100, Michal Hocko wrote:
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

I see several issues with distance. First it does fully abstract the
underlying topology and this might be problematic, for instance if
you memory with different characteristic in same node like persistent
memory connected to some CPU then it might be faster for that CPU to
access that persistent memory has it has dedicated link to it than to
access some other remote memory for which the CPU might have to share
the link with other CPUs or devices.

Second distance is no longer easy to compute when you are not trying
to answer what is the fastest memory for CPU-N but rather asking what
is the fastest memory for CPU-N and device-M ie when you are trying to
find the best memory for a group of CPUs/devices. The answer can
changes drasticly depending on members of the groups.


Some advance programmer already do graph matching ie they match the
graph of their program dataset/computation with the topology graph
of the computer they run on to determine what is best placement both
for threads and memory.


> I would be especially interested about a possibility of the memory
> migration idea during a memory pressure and relying on numa balancing to
> resort the locality on demand rather than hiding certain NUMA nodes or
> zones from the allocator and expose them only to the userspace.

For device memory we have more things to think of like:
    - memory not accessible by CPU
    - non cache coherent memory (yet still useful in some case if
      application explicitly ask for it)
    - device driver want to keep full control over memory as older
      application like graphic for GPU, do need contiguous physical
      memory and other tight control over physical memory placement

So if we are talking about something to replace NUMA i would really
like for that to be inclusive of device memory (which can itself be
a hierarchy of different memory with different characteristics).

Note that i do believe the NUMA proposed solution is something useful
now. But for a new API it would be good to allow thing like device
memory.

This is a good topic to discuss during next LSF/MM

Cheers,
J�r�me
