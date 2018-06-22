Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 21B606B0010
	for <linux-mm@kvack.org>; Fri, 22 Jun 2018 05:11:57 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id f19-v6so341870edq.22
        for <linux-mm@kvack.org>; Fri, 22 Jun 2018 02:11:57 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i3-v6si3335008edq.22.2018.06.22.02.11.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 22 Jun 2018 02:11:55 -0700 (PDT)
Date: Fri, 22 Jun 2018 11:11:53 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/2] arm64: avoid alloc memory on offline node
Message-ID: <20180622091153.GU10465@dhcp22.suse.cz>
References: <20180619120714.GE13685@dhcp22.suse.cz>
 <874lhz3pmn.fsf@e105922-lin.cambridge.arm.com>
 <20180619140818.GA16927@e107981-ln.cambridge.arm.com>
 <87wouu3jz1.fsf@e105922-lin.cambridge.arm.com>
 <20180619151425.GH13685@dhcp22.suse.cz>
 <87r2l23i2b.fsf@e105922-lin.cambridge.arm.com>
 <20180619163256.GA18952@e107981-ln.cambridge.arm.com>
 <814205eb-ae86-a519-bed0-f09b8e2d3a02@huawei.com>
 <87602d3ccl.fsf@e105922-lin.cambridge.arm.com>
 <5c083c9c-473f-f504-848b-48506d0fd380@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5c083c9c-473f-f504-848b-48506d0fd380@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hanjun Guo <guohanjun@huawei.com>
Cc: Punit Agrawal <punit.agrawal@arm.com>, Xie XiuQi <xiexiuqi@huawei.com>, Lorenzo Pieralisi <lorenzo.pieralisi@arm.com>, Bjorn Helgaas <helgaas@kernel.org>, tnowicki@caviumnetworks.com, linux-pci@vger.kernel.org, Catalin Marinas <catalin.marinas@arm.com>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, Will Deacon <will.deacon@arm.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Jarkko Sakkinen <jarkko.sakkinen@linux.intel.com>, linux-mm@kvack.org, wanghuiqiang@huawei.com, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Bjorn Helgaas <bhelgaas@google.com>, Andrew Morton <akpm@linux-foundation.org>, zhongjiang <zhongjiang@huawei.com>, linux-arm <linux-arm-kernel@lists.infradead.org>

On Fri 22-06-18 16:58:05, Hanjun Guo wrote:
> On 2018/6/20 19:51, Punit Agrawal wrote:
> > Xie XiuQi <xiexiuqi@huawei.com> writes:
> > 
> >> Hi Lorenzo, Punit,
> >>
> >>
> >> On 2018/6/20 0:32, Lorenzo Pieralisi wrote:
> >>> On Tue, Jun 19, 2018 at 04:35:40PM +0100, Punit Agrawal wrote:
> >>>> Michal Hocko <mhocko@kernel.org> writes:
> >>>>
> >>>>> On Tue 19-06-18 15:54:26, Punit Agrawal wrote:
> >>>>> [...]
> >>>>>> In terms of $SUBJECT, I wonder if it's worth taking the original patch
> >>>>>> as a temporary fix (it'll also be easier to backport) while we work on
> >>>>>> fixing these other issues and enabling memoryless nodes.
> >>>>>
> >>>>> Well, x86 already does that but copying this antipatern is not really
> >>>>> nice. So it is good as a quick fix but it would be definitely much
> >>>>> better to have a robust fix. Who knows how many other places might hit
> >>>>> this. You certainly do not want to add a hack like this all over...
> >>>>
> >>>> Completely agree! I was only suggesting it as a temporary measure,
> >>>> especially as it looked like a proper fix might be invasive.
> >>>>
> >>>> Another fix might be to change the node specific allocation to node
> >>>> agnostic allocations. It isn't clear why the allocation is being
> >>>> requested from a specific node. I think Lorenzo suggested this in one of
> >>>> the threads.
> >>>
> >>> I think that code was just copypasted but it is better to fix the
> >>> underlying issue.
> >>>
> >>>> I've started putting together a set fixing the issues identified in this
> >>>> thread. It should give a better idea on the best course of action.
> >>>
> >>> On ACPI ARM64, this diff should do if I read the code correctly, it
> >>> should be (famous last words) just a matter of mapping PXMs to nodes for
> >>> every SRAT GICC entry, feel free to pick it up if it works.
> >>>
> >>> Yes, we can take the original patch just because it is safer for an -rc
> >>> cycle even though if the patch below would do delaying the fix for a
> >>> couple of -rc (to get it tested across ACPI ARM64 NUMA platforms) is
> >>> not a disaster.
> >>
> >> I tested this patch on my arm board, it works.
> > 
> > I am assuming you tried the patch without enabling support for
> > memory-less nodes.
> > 
> > The patch de-couples the onlining of numa nodes (as parsed from SRAT)
> > from NR_CPUS restriction. When it comes to building zonelists, the node
> > referenced by the PCI controller also has zonelists initialised.
> > 
> > So it looks like a fallback node is setup even if we don't have
> > memory-less nodes enabled. I need to stare some more at the code to see
> > why we need memory-less nodes at all then ...
> 
> Yes, please. From my limited MM knowledge, zonelists should not be
> initialised if no CPU and no memory on this node, correct me if I'm
> wrong.

Well, as long as there is a code which can explicitly ask for a specific
node than it is safer to have zonelists configured. Otherwise you just
force callers to add hacks and figure out the proper placement there.
Zonelists should be cheep to configure for all possible nodes. It's not
like we are talking about huge amount of resources.
-- 
Michal Hocko
SUSE Labs
