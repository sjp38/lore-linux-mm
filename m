Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id E5A756B02C4
	for <linux-mm@kvack.org>; Wed, 17 May 2017 05:15:13 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id u96so953145wrc.7
        for <linux-mm@kvack.org>; Wed, 17 May 2017 02:15:13 -0700 (PDT)
Received: from outbound-smtp08.blacknight.com (outbound-smtp08.blacknight.com. [46.22.139.13])
        by mx.google.com with ESMTPS id d15si1743643edb.202.2017.05.17.02.15.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 May 2017 02:15:12 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp08.blacknight.com (Postfix) with ESMTPS id 345D71C28B7
	for <linux-mm@kvack.org>; Wed, 17 May 2017 10:15:12 +0100 (IST)
Date: Wed, 17 May 2017 10:15:11 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [RFC summary] Enable Coherent Device Memory
Message-ID: <20170517091511.gjxx46d2h6gmcqjf@techsingularity.net>
References: <1494569882.21563.8.camel@gmail.com>
 <20170512102652.ltvzzwejkfat7sdq@techsingularity.net>
 <CAKTCnz=VkswmWxoniD-TRYWWxr7wrWwCgRcsTXfNkgHZKXDEwA@mail.gmail.com>
 <20170516084303.ag2lzvdohvh6weov@techsingularity.net>
 <1494973607.21847.50.camel@kernel.crashing.org>
 <20170517082836.whe3hggeew23nwvz@techsingularity.net>
 <1495011826.3092.18.camel@kernel.crashing.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1495011826.3092.18.camel@kernel.crashing.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Balbir Singh <bsingharora@gmail.com>, linux-mm <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Aneesh Kumar KV <aneesh.kumar@linux.vnet.ibm.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Haren Myneni <haren@linux.vnet.ibm.com>, =?iso-8859-15?B?Suly9G1l?= Glisse <jglisse@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>

On Wed, May 17, 2017 at 07:03:46PM +1000, Benjamin Herrenschmidt wrote:
> > There is only so much magic that can be applied and if the manual case
> > cannot be handled then the automatic case is problematic. You say that you
> > want kswapd disabled, but have nothing to handle overcommit sanely.
> 
> I am not certain we want kswapd disabled, that is definitely more of a
> userspace policy, I agree. It could be in this case that it should
> prioritize different pages but still be able to push out. We *do* have
> age counting etc... just less efficient / higher cost. 
> 

If you don't want kswapd disabled, then the existing support is
sufficient unless different reclaim policies are required. If so, it
becomes a general problem of NUMA hierarchies where policies for nodes
may differ.

> >  You
> > want to disable automatic NUMA balancing yet also be able to automatically
> > detect when data should move from CDM (automatic NUMA balancing by design
> > couldn't move data to CDM without driver support tracking GPU accesses).
> 
> We can, via a driver specific hook, since we have specific counters on
> the link, so we don't want the autonuma based approach which makes PTEs
> inaccessible.
> 

Then poll the driver from a userspace daemon and make placement
decisions if automatic NUMA balancings reference-based decisions are
unsuitable.

> > To handle it transparently, either the driver needs to do the work in which
> > case no special core-kernel support is needed beyond what already exists or
> > there is a userspace daemon like numad running in userspace that decides
> > when to trigger migrations on a separate process that is using CDM which
> > would need to gather information from the driver.
> 
> The driver can handle it, we just need autonuma off the CDM memory (it
> can continue operating normally on system memory).
> 

Already suggested that prctl be used to disable automatic numa balancing
on a per-task basis. Alternatively, settiing a memory policy will be
enough and as the applications are going to need policies anyway, you
should be able to get that by default.

> > In either case, the existing isolation mechanisms are still sufficient as
> > long as the driver hot-adds the CDM memory from a userspace trigger that
> > it then responsible for setting up the isolation.
> 
> Yes, I think the NUMA node based approach works fine using a lot of
> existing stuff. There are a couple of gaps, which we need to look at
> fixing one way or another such as the above, but overall I don't see
> the need of some major overhaul, not do I see the need of going down
> the path of ZONE_DEVICE.
> 

Your choice, but it also doesn't take away from the fact that special
casing in the core does not appear to be required at this point.

> > All that aside, this series has nothing to do with the type of magic
> > you describe and the feedback as iven was "at this point, what you are
> > looking for does not require special kernel support or heavy wiring into
> > the core vm".
> > 
> > > Thus we want to reply on the GPU driver moving the pages around where
> > > most appropriate (where they are being accessed, either core memory or
> > > GPU memory) based on inputs from the HW counters monitoring the link.
> > > 
> > 
> > And if the driver is polling all the accesses, there are still no changes
> > required to the core vm as long as the driver does the hotplug and allows
> > userspace to isolate if that is what the applications desire.
> 
> With one main exception ... 
> 
> We also do want normal allocations to avoid going to the GPU memory.
> 

Use policies. If the NUMA distance for CDM is set high then even applications
that have access to CDM will use every other node before going to CDM. As
you insist on no application awareness, the migration to CDM will have to
be controlled by a separate daemon.

> IE, things should go to the GPU memory if and only if they are either
> explicitly put there by the application/driver (the case where
> applications do care about manual placement), or the migration case. 
> 
> The latter is triggered by the driver, so it's also a case of the
> driver allocating the GPU pages and doing a migration to them.
> 
> This is the key thing. Now creating a CMA or using ZONE_MOVABLE can
> handle at least keeping kernel allocations off the GPU. However we
> would also like to keep random unrelated user memory & page cache off
> as well.
> 

Fine -- hot add the memory from the device via a userspace trigger and
have the userspace trigger then setup the policies to isolate CDM from
general usage.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
