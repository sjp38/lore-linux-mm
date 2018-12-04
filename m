Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id B1F4B6B7162
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 18:56:37 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id q3so19180052qtq.15
        for <linux-mm@kvack.org>; Tue, 04 Dec 2018 15:56:37 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n69si447098qkn.55.2018.12.04.15.56.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Dec 2018 15:56:36 -0800 (PST)
Date: Tue, 4 Dec 2018 18:56:30 -0500
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [RFC PATCH 02/14] mm/hms: heterogenenous memory system (HMS)
 documentation
Message-ID: <20181204235630.GQ2937@redhat.com>
References: <20181204185725.GE2937@redhat.com>
 <de7c1099-2717-6396-bf56-c4ab4085ee83@deltatee.com>
 <20181204192221.GG2937@redhat.com>
 <f759cc28-309d-930c-da7d-34144a4d5517@deltatee.com>
 <20181204201347.GK2937@redhat.com>
 <2f146730-1bf9-db75-911d-67809fc7afef@deltatee.com>
 <20181204205902.GM2937@redhat.com>
 <e4d8bf6b-5b2c-58a5-577b-66d02f2342c1@deltatee.com>
 <20181204215146.GO2937@redhat.com>
 <c5cf87e8-9104-c2e6-9646-188f66fec581@deltatee.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <c5cf87e8-9104-c2e6-9646-188f66fec581@deltatee.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Logan Gunthorpe <logang@deltatee.com>
Cc: Dan Williams <dan.j.williams@intel.com>, Andi Kleen <ak@linux.intel.com>, Linux MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "Rafael J. Wysocki" <rafael@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Haggai Eran <haggaie@mellanox.com>, balbirs@au1.ibm.com, "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, "Kuehling, Felix" <felix.kuehling@amd.com>, Philip.Yang@amd.com, "Koenig, Christian" <christian.koenig@amd.com>, "Blinzer, Paul" <Paul.Blinzer@amd.com>, John Hubbard <jhubbard@nvidia.com>, rcampbell@nvidia.com

On Tue, Dec 04, 2018 at 03:16:54PM -0700, Logan Gunthorpe wrote:
> 
> 
> On 2018-12-04 2:51 p.m., Jerome Glisse wrote:
> > Existing user would disagree in my cover letter i have given pointer
> > to existing library and paper from HPC folks that do leverage system
> > topology (among the few who are). So they are application _today_ that
> > do use topology information to adapt their workload to maximize the
> > performance for the platform they run on.
> 
> Well we need to give them what they actually need, not what they want to
> shoot their foot with. And I imagine, much of what they actually do
> right now belongs firmly in the kernel. Like I said, existing
> applications are not justifications for bad API design or layering
> violations.

One example i have is 4 nodes (CPU socket) each nodes with 8 GPUs and
two 8 GPUs node connected through each other with fast mesh (ie each
GPU can peer to peer to each other at the same bandwidth). Then this
2 blocks are connected to the other block through a share link.

So it looks like:
    SOCKET0----SOCKET1-----SOCKET2----SOCKET3
    |          |           |          |
    S0-GPU0====S1-GPU0     S2-GPU0====S1-GPU0
    ||     \\//            ||     \\//
    ||     //\\            ||     //\\
    ...    ====...    -----...    ====...
    ||     \\//            ||     \\//
    ||     //\\            ||     //\\
    S0-GPU7====S1-GPU7     S2-GPU7====S3-GPU7

Application partition its workload in 2 ie allocate dataset twice
for 16 group of GPU. Each of the 2 partitions is then further split
in two for some of the buffer in the dataset but not all.

So AFAICT they are using all the topology informations. They see
that they are 4 group of GPU that in those 4 group, they are 2
pair of group with better interconnect and then a share slower
inter-connect between the 2 groups.

>From HMS point of view this looks like (ignoring CPU):
link0: S0-GPU0 ... S0-GPU7
link1: S1-GPU0 ... S1-GPU7
link2: S2-GPU0 ... S2-GPU7
link3: S3-GPU0 ... S3-GPU7

link4: S0-GPU0 ... S0-GPU7 S1-GPU0 ... S1-GPU7
link5: S2-GPU0 ... S2-GPU7 S3-GPU0 ... S3-GPU7

link6: S0-GPU0 ... S0-GPU7 S1-GPU0 ... S1-GPU7
       S2-GPU0 ... S2-GPU7 S3-GPU0 ... S3-GPU7

Dumbing it more down and they loose information they want. On top
of that there is also the NUMA CPU node (which is more symetric).

I do not see how this can express in current sysfs we have but
maybe there is a way to shoe horn it.

I expect more complex topology to show up with a mix of different
devices (like GPU and FPGA).

> 
> You've even mentioned we'd need a simplified "libhms" interface for
> applications. We should really just figure out what that needs to be and
> make that the kernel interface.

No i said that a libhms for average application would totaly make
sense to dumb thing down. I do not expect all application will use
the full extent of the information. One simple reason, desktop,
on desktop i don't expect the topology to grow too complex and
thus all the desktop application will not care about it (your
blender, libreoffice, ... which are using GPU today).

But for people creating application that will run on big server,
yes i expect some of them will use that information if only the
existing people that already do use that information.


> > They are also some new platform that have much more complex topology
> > that definitly can not be represented as a tree like today sysfs we
> > have (i believe that even some of the HPC folks have _today_ topology
> > that are not tree-like).
> 
> The sysfs tree already allows for a complex graph that describes
> existing hardware very well. If there is hardware it cannot describe
> then we should work to improve it and not just carve off a whole new
> area for a special API. -- In fact, you are already using sysfs, just
> under your own virtual/non-existent bus.

How the above example would looks like ? I fail to see how to do it
inside current sysfs. Maybe by creating multiple virtual device for
each of the inter-connect ? So something like

link0 -> device:00 which itself has S0-GPU0 ... S0-GPU7 has child
link1 -> device:01 which itself has S1-GPU0 ... S1-GPU7 has child
link2 -> device:02 which itself has S2-GPU0 ... S2-GPU7 has child
link3 -> device:03 which itself has S3-GPU0 ... S3-GPU7 has child

Then for link4, link5 and link6 we would need symlink to the GPU
device. So it sounds like creating virtual device for the sake of
doing it in the existing framework. Then userspace would have to
learn about this virtual device to identify them as node for the
topology graph and would have to differentiate from non node
device. This sounds much more complex to me.

Also if doing node for those we would need to do CPU less and memory
less NUMA node as the GPU memory is not usable by the CPU ... I am
not sure we want to get there. If that's what people want fine but
i personnaly don't think this is the right solution.


> > Note that if it turn out to be a bad idea kernel can decide to dumb
> > down thing in future version for new platform. So it could give a
> > flat graph to userspace, there is nothing precluding that.
> 
> Uh... if it turns out to be a bad idea we are screwed because we have an
> API existing applications are using. It's much easier to add features to
> a simple (your word: "dumb") interface than it is to take options away
> from one that is too broad.

We all have fears that what we do will not get use, but i do not
want to stop making progress because of that. Like i said i am doing
all this under staging to get the ball rolling, to test it with
guinea pig and to gain some level of confidence it is actually
useful. So i am providing evidence today (see all the research in
HPC on memory management, topology, placement, ... for which i have
given some links to) and i want to gather more evidence before commiting
to this.

I hope this sounds like a reasonable plan. What would you like me to
do differently ? Like i said i feel that this is a chicken and egg
problem today there is no standard way to get topology so there is
no way to know how much applications would use such informations. We
know that very few applications in special case use the topology
informations. How to test wether more applications would use that
same informations without providing some kind of standard API for
them to get it ?

It is also a system availability thing, right now they are very few
system with such complex topology, but we are seeing more and more
GPU, TPU, FPGA in more and more environement. I want to be pro-active
here and provide API that would help leverage those new system for
people experimenting with them.

My proposal is to do HMS behind staging for a while and also avoid
any disruption to existing code path. See with people living on the
bleeding edge if they get interested in that informations. If not then
i can strip down my thing to the bare minimum which is about device
memory.


> >>> I am talking about the inevitable fact that at some point some system
> >>> firmware will miss-represent their platform. System firmware writer
> >>> usualy copy and paste thing with little regards to what have change
> >>> from one platform to the new. So their will be inevitable workaround
> >>> and i would rather see those piling up inside a userspace library than
> >>> inside the kernel.
> >>
> >> It's *absolutely* the kernel's responsibility to patch issues caused by
> >> broken firmware. We have quirks all over the place for this. That's
> >> never something userspace should be responsible for. Really, this is the
> >> raison d'etre of the kernel: to provide userspace with a uniform
> >> execution environment -- if every application had to deal with broken
> >> firmware it would be a nightmare.
> > 
> > You cuted the other paragraph that explained why they will unlikely
> > to be broken badly enough to break the kernel.
> 
> That was entirely beside the point. Just because it doesn't break the
> kernel itself doesn't make it any less necessary for it to be fixed
> inside the kernel. It must be done in a common place so every
> application doesn't have to maintain a table of hardware quirks.

Fine with quirks in kernel. It was just a personnal taste thing ...
pure kernel vs ugly userspace :)

Cheers,
J�r�me
