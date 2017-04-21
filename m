Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5FCDC2806D2
	for <linux-mm@kvack.org>; Fri, 21 Apr 2017 12:13:34 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id f66so136454565ioe.12
        for <linux-mm@kvack.org>; Fri, 21 Apr 2017 09:13:34 -0700 (PDT)
Received: from resqmta-ch2-12v.sys.comcast.net (resqmta-ch2-12v.sys.comcast.net. [2001:558:fe21:29:69:252:207:44])
        by mx.google.com with ESMTPS id r125si2585567itg.4.2017.04.21.09.13.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Apr 2017 09:13:33 -0700 (PDT)
Date: Fri, 21 Apr 2017 11:13:29 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC 0/4] RFC - Coherent Device Memory (Not for inclusion)
In-Reply-To: <1492723609.25766.152.camel@kernel.crashing.org>
Message-ID: <alpine.DEB.2.20.1704211108120.14734@east.gentwo.org>
References: <20170419075242.29929-1-bsingharora@gmail.com> <alpine.DEB.2.20.1704191355280.9478@east.gentwo.org> <1492651508.1015.2.camel@gmail.com> <alpine.DEB.2.20.1704201025360.26403@east.gentwo.org> <1492723609.25766.152.camel@kernel.crashing.org>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Balbir Singh <bsingharora@gmail.com>, linux-mm@kvack.org, akpm@linux-foundation.org, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, paulmck@linux.vnet.ibm.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, mgorman@techsingularity.net, mhocko@kernel.org, arbab@linux.vnet.ibm.com, vbabka@suse.cz

On Fri, 21 Apr 2017, Benjamin Herrenschmidt wrote:

> On Thu, 2017-04-20 at 10:29 -0500, Christoph Lameter wrote:
> > On Thu, 20 Apr 2017, Balbir Singh wrote:
> > > Couple of things are needed
> > >
> > > 1. Isolation of allocation
> >
> > cgroups, memory policy and cpuset provide that
>
> Can these be configured appropriately by the accelerator or GPU driver
> at the point where it hot plugs the memory ?

A driver could be able to setup a memory policy. Sure.

> The problem is we need to ensure there is no window in which the kernel
> will start putting things like skb's etc... in there.

skbs are not put into user space pages. They are unmovable and thus
hotplugged memory will not be used.

> Basically the whole debate at the moment revolves around whether to use
> HMM/CDM/ZONE_DEVICE vs. making it just a NUMA nodes with a sprinkle of
> added foo.

I think the memory hotplug idea should be making this easy to do. Not
much rigging around needed.

> What we have here is effectively a bit more like a NUMA node, whose
> processing unit is just not a CPU but a GPU or some kind of
> accelerator.

Its like a memory only node. That is a common usecase for NUMA nodes (HP
has made use of memory only nodes in a large scale)

> The difference boils down to how we want to use is. We want any page,
> anonymous memory, mapped file, you name it... to be able to migrate
> back and forth depending on which piece of HW is most actively
> accessing it. This is helped by a bunch of things such as very fast DMA
> engines to facilitate migration, and HW counter to detect when parts of
> that memory are accessed "remotely" (and thus request migrations).

Well that migration can even be done from userspace. See the
migrate_pages() syscall.

> So the NUMA model fits reasonably well, with that memory being overall
> treated normally. The ZONE_DEVICE model on the other hand creates those
> "special" pages which require a pile of special casing in all sort of
> places as Balbir has mentioned, with still a bunch of rather standard
> stuff not working with them.

Right.

> However, we do need to address a few quirks, which is what this is
> about.
>
> Mostly we want to keep kernel allocations away from it, in part because
> the memory is more prone to fail and not terribly fast for direct CPU
> access, in part because we want to maximize the availability of it for
> dedicated applications.

Hotplugged memory is containing only movable pages. This means kernel
allocations do not occur there. You are fine.

> Other things are possibly more realistic to do that way, such as taking
> KSM and AutoNuma off the picture for it.

Well just pinning those pages or mlocking those will stop these scans.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
