Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id C2DB96B0033
	for <linux-mm@kvack.org>; Wed, 25 Oct 2017 02:38:56 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id 76so20268455pfr.3
        for <linux-mm@kvack.org>; Tue, 24 Oct 2017 23:38:56 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g1si1387558pgc.3.2017.10.24.23.38.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 24 Oct 2017 23:38:55 -0700 (PDT)
Date: Wed, 25 Oct 2017 08:38:52 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: fix movable_node kernel command-line
Message-ID: <20171025063852.nunaquo5wevayejf@dhcp22.suse.cz>
References: <20171023174905.ap4uz6puggeqnz3s@dhcp22.suse.cz>
 <20171023184852.GB12198@linux.intel.com>
 <20171023190459.odyu26rqhuja4trj@dhcp22.suse.cz>
 <20171023192524.GC12198@linux.intel.com>
 <20171023193536.c7yptc4tpesa4ffl@dhcp22.suse.cz>
 <20171023195637.GE12198@linux.intel.com>
 <0ed8144f-4447-e2de-47f7-ea1fc16f0b25@intel.com>
 <20171024010633.GA2723@linux.intel.com>
 <20171024071906.64ikc733x53zmgzu@dhcp22.suse.cz>
 <20171025005314.GA2636@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171025005314.GA2636@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sharath Kumar Bhat <sharath.k.bhat@linux.intel.com>
Cc: Dave Hansen <dave.hansen@intel.com>, linux-mm@kvack.org, akpm@linux-foundation.org

On Tue 24-10-17 17:53:14, Sharath Kumar Bhat wrote:
> On Tue, Oct 24, 2017 at 09:19:06AM +0200, Michal Hocko wrote:
> > On Mon 23-10-17 18:06:33, Sharath Kumar Bhat wrote:
[...]
> > > And moreover
> > > 'movable_node' is implemented with an assumption to provide the entire
> > > hotpluggable memory as movable zone. This ACPI override would be against
> > > that assumption.
> > 
> > This is true and in fact movable_node should become movable_memory over
> > time and only ranges marked as movable would become really movable. This
> > is a rather non-trivial change to do and there is not a great demand for
> > the feature so it is low on my TODO list.
> 
> Do you mean to have a single kernel command-line 'movable_memory=' for this
> purpose and remove all other kernel command-line parameters such as
> 'kernelcore=', 'movablecore=' and 'movable_node'?

yes.

> because after the kernel
> boots up we can not gurantee that a contig memory range can be made zone
> movable since any kernel allocations could pre-exist.

No, I meant that the zone association would be done _only_ based by
memory attributes exported by ACPI or whatever is used to configure
memory ranges on the particular platform. So an early init code.

> > > Also ACPI override would introduce additional topology
> > > changes. Again this would have to change every time the total movable
> > > memory requirement changes and the whole system and apps have to be
> > > re-tuned (for job launch ex: numactl etc) to comphrehend this change.
> > 
> > This is something you have to do anyway when the topology of the system
> > changes each boot.
> 
> No, this is a manual tuning for job-launch, mem policy handling code etc.
> which would be done once for a platform. But in this case based on the
> application need the amount of movable memory will change so it is really
> unfair to ask user to re-work their job launch and apps for every such
> changes.

I am still confused. Why does the application even care about
movability?
 
> > That being said, I would really prefer to actually _remove_ kernel_core
> > parameter altogether. It is messy (just look at find_zone_movable_pfns_for_nodes
> > at al.) and the original usecase it has been added for [1] does not hold
> > anymore. Adding more stuff to workaround issues which can be handled
> > more cleanly is definitely not a right way to go.
> 
> I agree that kernelcore handling is non-trivial in that function. But the
> changes introduced by this patch are under 'movable_node' case handling in
> find_zone_movable_pfns_for_nodes() and it does not cause any change to the
> existing kernelcore behavior of the code. Also this enables all
> multi-kernel users to make use of this functionality untill later when
> new interface would be available for the same purpose.

The point is to not build on top and rather get rid of it completely.
 
> > [1] note that MOVABLE_ZONE has been originally added to help the
> > fragmentation avoidance.
> 
> Isn't this true even now since ZONE_MOVABLE will populate only
> MIGRATE_MOVABLE free list of pages? and other zones could have
> MIGRATE_UNMOVABLE pages?

My point was that the original motivation is gone because our compaction
code doesn't really depend on movable zone. So the movable zone is more
about making sure that the specific memory is migratable and so
offlineable.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
