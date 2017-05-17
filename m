Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 54DE76B02C4
	for <linux-mm@kvack.org>; Wed, 17 May 2017 06:58:15 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id c202so1703574wme.10
        for <linux-mm@kvack.org>; Wed, 17 May 2017 03:58:15 -0700 (PDT)
Received: from outbound-smtp10.blacknight.com (outbound-smtp10.blacknight.com. [46.22.139.15])
        by mx.google.com with ESMTPS id z9si2196187edb.89.2017.05.17.03.58.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 May 2017 03:58:13 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp10.blacknight.com (Postfix) with ESMTPS id 0EDE31C2907
	for <linux-mm@kvack.org>; Wed, 17 May 2017 11:58:13 +0100 (IST)
Date: Wed, 17 May 2017 11:58:12 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [RFC summary] Enable Coherent Device Memory
Message-ID: <20170517105812.plj54qwbr334w5r5@techsingularity.net>
References: <1494569882.21563.8.camel@gmail.com>
 <20170512102652.ltvzzwejkfat7sdq@techsingularity.net>
 <CAKTCnz=VkswmWxoniD-TRYWWxr7wrWwCgRcsTXfNkgHZKXDEwA@mail.gmail.com>
 <20170516084303.ag2lzvdohvh6weov@techsingularity.net>
 <1494973607.21847.50.camel@kernel.crashing.org>
 <20170517082836.whe3hggeew23nwvz@techsingularity.net>
 <1495011826.3092.18.camel@kernel.crashing.org>
 <20170517091511.gjxx46d2h6gmcqjf@techsingularity.net>
 <1495014995.3092.20.camel@kernel.crashing.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1495014995.3092.20.camel@kernel.crashing.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Balbir Singh <bsingharora@gmail.com>, linux-mm <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Aneesh Kumar KV <aneesh.kumar@linux.vnet.ibm.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Haren Myneni <haren@linux.vnet.ibm.com>, =?iso-8859-15?B?Suly9G1l?= Glisse <jglisse@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>

On Wed, May 17, 2017 at 07:56:35PM +1000, Benjamin Herrenschmidt wrote:
> On Wed, 2017-05-17 at 10:15 +0100, Mel Gorman wrote:
> > > We can, via a driver specific hook, since we have specific counters on
> > > the link, so we don't want the autonuma based approach which makes PTEs
> > > inaccessible.
> > > 
> > 
> > Then poll the driver from a userspace daemon and make placement
> > decisions if automatic NUMA balancings reference-based decisions are
> > unsuitable.
> 
> Why a userspace daemon ? I don't get this... the driver will get
> interrupts from the GPU with page lists, it can trigger migrations
> without needing a userspace daemon...
> 

Then handle it within the driver. The point is that it still doesn't
need hooks into the core VM at this point.

> > > > To handle it transparently, either the driver needs to do the work in which
> > > > case no special core-kernel support is needed beyond what already exists or
> > > > there is a userspace daemon like numad running in userspace that decides
> > > > when to trigger migrations on a separate process that is using CDM which
> > > > would need to gather information from the driver.
> > > 
> > > The driver can handle it, we just need autonuma off the CDM memory (it
> > > can continue operating normally on system memory).
> > > 
> > 
> > Already suggested that prctl be used to disable automatic numa balancing
> > on a per-task basis. Alternatively, settiing a memory policy will be
> > enough and as the applications are going to need policies anyway, you
> > should be able to get that by default.
> 
> I'm not sure we want to disable it for the application vs. disabling it
> for pages that reside on that node,

Then use a memory policy to control which VMAs are exempt. If you do not
wants at all for particular nodes then that would need core VM support
but you'll lose transparency. If you want to flag particular pgdats,
then it'll be adding a check to the task scanner but it would need to be
clearly shown that there is a lot of value in teaching automatic NUMA
balancing this.

> > > > long as the driver hot-adds the CDM memory from a userspace trigger that
> > > > it then responsible for setting up the isolation.
> > > 
> > > Yes, I think the NUMA node based approach works fine using a lot of
> > > existing stuff. There are a couple of gaps, which we need to look at
> > > fixing one way or another such as the above, but overall I don't see
> > > the need of some major overhaul, not do I see the need of going down
> > > the path of ZONE_DEVICE.
> > > 
> > Your choice, but it also doesn't take away from the fact that special
> > casing in the core does not appear to be required at this point.
> 
> Well, yes and no.
> 
> If we use the NUMA based approach, then no special casing up to this
> point, the only thing is below, the idea of avoiding "normal"
> allocations for that type of memory.
> 

Use cpusets from userspace, and control carefully how and when the memory
is hot-added and what zone it gets added to. We've been through this.

> > Use policies. If the NUMA distance for CDM is set high then even applications
> > that have access to CDM will use every other node before going to CDM.
> 
> Yes. That was the original idea. Along with ZONE_MOVABLE to avoid
> kernel allocations completely.
> 

Remember that this will include the page table pages which may or may
not be what you want.

> I think Balbir and Anshuman wanted to play with a more fully exclusive
> approach where those allocations are simply not permitted.
> 

Use cpusets and control carefully how and when the memory is hot-added
and what zone it gets added to.

> >  As
> > you insist on no application awareness, the migration to CDM will have to
> > be controlled by a separate daemon.
> 
> Or by the driver itself, I don't think we need a daemon, but that's a
> detail in the grand scheme of things.
> 

It also doesn't need core VM hooks or special support.

> > > IE, things should go to the GPU memory if and only if they are either
> > > explicitly put there by the application/driver (the case where
> > > applications do care about manual placement), or the migration case. 
> > > 
> > > The latter is triggered by the driver, so it's also a case of the
> > > driver allocating the GPU pages and doing a migration to them.
> > > 
> > > This is the key thing. Now creating a CMA or using ZONE_MOVABLE can
> > > handle at least keeping kernel allocations off the GPU. However we
> > > would also like to keep random unrelated user memory & page cache off
> > > as well.
> > > 
> > 
> > Fine -- hot add the memory from the device via a userspace trigger and
> > have the userspace trigger then setup the policies to isolate CDM from
> > general usage.
> 
> This is racy though. The memory is hot added, but things can get
> allocated all over it before it has time to adjust the policies. Same
> issue we had with creating a CMA I believe.
> 

The race is a non-issue unless for some reason you decide to hot-add the node
when the machine is already heavily loaded and under memory pressure. Do it
near boot time and no CPU-local allocation is going to hit it. In itself,
special casing the core VM is overkill.

If you decide to use ZONE_MOVABLE and take the remote hit penalty of page
tables, then you can also migrate all the pages away after the onlining
and isolation is complete if it's a serious concern in practice.

> Unless we have a way to create a node without actually making it
> available for allocations, so we get a chance to establish policies for
> it, then "online" it ?
> 

Conceivably, that could be done although again it's somewhat overkill
as the race only applies if hot-adding CDM under heavy memory pressure
sufficient to overflow to a very remote node.

> Doing these from userspace is a bit nasty since it's expected to all be
> under the control of the GPU driver, but it could be done via a
> combination of GPU driver & udev helpers or a special daemon.
> 

Special casing the core VM in multiple places is also nasty as it shoves
all the maintenance overhead into places where most people will not be
able to verify it's still working due to a lack of hardware.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
