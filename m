Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6937D8E0004
	for <linux-mm@kvack.org>; Fri,  7 Dec 2018 14:37:34 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id q33so4656369qte.23
        for <linux-mm@kvack.org>; Fri, 07 Dec 2018 11:37:34 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k46si2662639qtk.49.2018.12.07.11.37.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Dec 2018 11:37:33 -0800 (PST)
Date: Fri, 7 Dec 2018 14:37:25 -0500
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [RFC PATCH 00/14] Heterogeneous Memory System (HMS) and hbind()
Message-ID: <20181207193725.GE3293@redhat.com>
References: <d6508932-377c-a4d1-d4d8-01d0f55b9190@intel.com>
 <c583be1b-17db-1ed3-0f5a-bd119edc8bfe@deltatee.com>
 <f7eb9939-d550-706a-946d-acbb7383172e@intel.com>
 <20181206223935.GG3544@redhat.com>
 <c1126d60-95c0-ed34-6314-fcec17ac1c29@intel.com>
 <935fc14d-91f2-bc2a-f8b5-665e4145e148@deltatee.com>
 <5e6c87d5-e4ef-12e7-32bf-c163f7ff58d7@intel.com>
 <cd5cf2a6-7415-eae7-0305-004cc7db994b@deltatee.com>
 <20181207002044.GI3544@redhat.com>
 <20181207150636.00003dfa@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20181207150636.00003dfa@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan Cameron <jonathan.cameron@huawei.com>
Cc: Logan Gunthorpe <logang@deltatee.com>, Dave Hansen <dave.hansen@intel.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, "Rafael J . Wysocki" <rafael@kernel.org>, Matthew Wilcox <willy@infradead.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, Keith Busch <keith.busch@intel.com>, Dan Williams <dan.j.williams@intel.com>, Haggai Eran <haggaie@mellanox.com>, Balbir Singh <bsingharora@gmail.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Felix Kuehling <felix.kuehling@amd.com>, Philip Yang <Philip.Yang@amd.com>, Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, John Hubbard <jhubbard@nvidia.com>, Ralph Campbell <rcampbell@nvidia.com>, Michal Hocko <mhocko@kernel.org>, Mark Hairgrove <mhairgrove@nvidia.com>, Vivek Kini <vkini@nvidia.com>, Mel Gorman <mgorman@techsingularity.net>, Dave Airlie <airlied@redhat.com>, Ben Skeggs <bskeggs@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@surriel.com>, Ben Woodard <woodard@redhat.com>, linux-acpi@vger.kernel.org

On Fri, Dec 07, 2018 at 03:06:36PM +0000, Jonathan Cameron wrote:
> On Thu, 6 Dec 2018 19:20:45 -0500
> Jerome Glisse <jglisse@redhat.com> wrote:
> 
> > On Thu, Dec 06, 2018 at 04:48:57PM -0700, Logan Gunthorpe wrote:
> > > 
> > > 
> > > On 2018-12-06 4:38 p.m., Dave Hansen wrote:  
> > > > On 12/6/18 3:28 PM, Logan Gunthorpe wrote:  
> > > >> I didn't think this was meant to describe actual real world performance
> > > >> between all of the links. If that's the case all of this seems like a
> > > >> pipe dream to me.  
> > > > 
> > > > The HMAT discussions (that I was a part of at least) settled on just
> > > > trying to describe what we called "sticker speed".  Nobody had an
> > > > expectation that you *really* had to measure everything.
> > > > 
> > > > The best we can do for any of these approaches is approximate things.  
> > > 
> > > Yes, though there's a lot of caveats in this assumption alone.
> > > Specifically with PCI: the bus may run at however many GB/s but P2P
> > > through a CPU's root complexes can slow down significantly (like down to
> > > MB/s).
> > > 
> > > I've seen similar things across QPI: I can sometimes do P2P from
> > > PCI->QPI->PCI but the performance doesn't even come close to the sticker
> > > speed of any of those buses.
> > > 
> > > I'm not sure how anyone is going to deal with those issues, but it does
> > > firmly place us in world view #2 instead of #1. But, yes, I agree
> > > exposing information like in #2 full out to userspace, especially
> > > through sysfs, seems like a nightmare and I don't see anything in HMS to
> > > help with that. Providing an API to ask for memory (or another resource)
> > > that's accessible by a set of initiators and with a set of requirements
> > > for capabilities seems more manageable.  
> > 
> > Note that in #1 you have bridge that fully allow to express those path
> > limitation. So what you just describe can be fully reported to userspace.
> > 
> > I explained and given examples on how program adapt their computation to
> > the system topology it does exist today and people are even developing new
> > programming langage with some of those idea baked in.
> > 
> > So they are people out there that already rely on such information they
> > just do not get it from the kernel but from a mix of various device specific
> > API and they have to stich everything themself and develop a database of
> > quirk and gotcha. My proposal is to provide a coherent kernel API where
> > we can sanitize that informations and report it to userspace in a single
> > and coherent description.
> > 
> > Cheers,
> > J�r�me
> 
> I know it doesn't work everywhere, but I think it's worth enumerating what
> cases we can get some of these numbers for and where the complexity lies.
> I.e. What can the really determined user space library do today?

I gave an example in an email in this thread:

https://www.mail-archive.com/linux-kernel@vger.kernel.org/msg1821872.html

Is the kind of example you are looking for ? :)

> 
> So one open question is how close can we get in a userspace only prototype.
> At the end of the day userspace can often read HMAT directly if it wants to
> /sys/firmware/acpi/tables/HMAT.  Obviously that gets us only the end to
> end view (world 2).  I dislike the limitations of that as much as the next
> person. It is slowly improving with the word "Auditable" being
> kicked around - btw anyone interested in ACPI who works for a UEFI
> member, there are efforts going on and more viewpoints would be great.
> Expect some baby steps shortly.
> 
> For devices on PCIe (and protocols on top of it e.g. CCIX), a lot of
> this is discoverable to some degree. 
> * Link speed,
> * Number of Lanes,
> * Full topology.

Yes discoverable bus like PCIE and all its derivative (CCIX, OpenCAPI,
...) userspace will have way to find the topology. The issue lies with
orthogonal topology of extra bus that are not necessarily enumerated
or with a device driver presently and especially how they inter-act
with each other (can you cross them ? ...)

> 
> What isn't there (I think)
> * In component latency / bandwidth limitations (some activity going
>   on to improve that long term)
> * Effect of credit allocations etc on effectively bandwidth - interconnect
>   performance is a whole load of black magic.
> 
> Presumably there is some information available from NVLink etc?

>From my point of view we want to give the best case sticker value to
userspace ie the bandwidth the engineer that designed the bus sworn
their hardware deliver :)

I believe it the is the best approximation we can deliver.

> 
> So whilst I really like the proposal in some ways, I wonder how much exploration
> could be done of the usefulness of the data without touching the kernel at all.
> 
> The other aspect that is needed to actually make this 'dynamically' useful is
> to be able to map whatever Performance Counters are available to the relevant
> 'links', bridges etc.   Ticket numbers are not all that useful unfortunately
> except for small amounts of data on lightly loaded buses.
> 
> The kernel ultimately only needs to have a model of this topology if:
> 1) It's going to use it itself

I don't think this should be a criteria, kernel is not using GPU or
network adatper to browse the web for itself (at least i hope the
linux kernel is not selfaware ;)). So this kind of topology is not
of big use to the kernel. Kernel will only care about CPU and memory
that abide to the memory model of the platform. It will also care
about more irregular CPU inter-connected ie CPUs on the same mega
substrate likely have a faster inter-connect between them then to
the ones in a different physical socket. NUMA distance can model
that. Dunno if more than that would be useful to the kernel.

> 2) Its going to do something automatic with it.

The information is intended for userspace for application that use
that information. Today application get that information from non
standard source and i would like to provide this in a standard
common place in the kernel for few reasons:
    - Common model with explicit definition of what is what and
      what are the rules. No need to userspace to understand the
      specificities of various kernel sub-system.
    - Define unique identifiant for _every_ type of memory in the
      system even device memory so that i can define syscall to
      operate on those memory (can not do that in device driver)
    - Integrate with core mm so that long term we can move more
      of individual device memory management into core component.

> 3) It needs to fix garbage info or supplement with things only the kernel knows.

Yes kernel is expect to fix the informations it get and sanitize
it so that userspace do not have to grow database of quirk and
workaround. Moreover kernel can also benchmark inter-connect and
adapt reported bandwidth and latency if this is ever something
people would like to see.


I will post two v2 where i split the common helpers from the sysfs
and syscall part. I need the common helpers today in the case of
single device and have user for that code (nouveau and amdgpu for
starter). I want to continue the sysfs and syscall discussion and
i need to reformulate thing and give better explaination of why
i think the way i am doing thing have more values than any other.

Dunno if i will have time to finish rework-ing all this before the
end of this year.

Cheers,
J�r�me
