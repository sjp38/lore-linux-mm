Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 55A236B71F7
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 21:31:25 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id j5so19166394qtk.11
        for <linux-mm@kvack.org>; Tue, 04 Dec 2018 18:31:25 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q11si7300551qki.187.2018.12.04.18.31.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Dec 2018 18:31:23 -0800 (PST)
Date: Tue, 4 Dec 2018 21:31:17 -0500
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [RFC PATCH 02/14] mm/hms: heterogenenous memory system (HMS)
 documentation
Message-ID: <20181205023116.GD3045@redhat.com>
References: <20181204192221.GG2937@redhat.com>
 <f759cc28-309d-930c-da7d-34144a4d5517@deltatee.com>
 <20181204201347.GK2937@redhat.com>
 <2f146730-1bf9-db75-911d-67809fc7afef@deltatee.com>
 <20181204205902.GM2937@redhat.com>
 <e4d8bf6b-5b2c-58a5-577b-66d02f2342c1@deltatee.com>
 <20181204215146.GO2937@redhat.com>
 <c5cf87e8-9104-c2e6-9646-188f66fec581@deltatee.com>
 <20181204235630.GQ2937@redhat.com>
 <b77849e1-e05a-1071-7c48-ac93191e3134@deltatee.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <b77849e1-e05a-1071-7c48-ac93191e3134@deltatee.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Logan Gunthorpe <logang@deltatee.com>
Cc: Dan Williams <dan.j.williams@intel.com>, Andi Kleen <ak@linux.intel.com>, Linux MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "Rafael J. Wysocki" <rafael@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Haggai Eran <haggaie@mellanox.com>, balbirs@au1.ibm.com, "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, "Kuehling, Felix" <felix.kuehling@amd.com>, Philip.Yang@amd.com, "Koenig, Christian" <christian.koenig@amd.com>, "Blinzer, Paul" <Paul.Blinzer@amd.com>, John Hubbard <jhubbard@nvidia.com>, rcampbell@nvidia.com

On Tue, Dec 04, 2018 at 06:15:08PM -0700, Logan Gunthorpe wrote:
> 
> 
> On 2018-12-04 4:56 p.m., Jerome Glisse wrote:
> > One example i have is 4 nodes (CPU socket) each nodes with 8 GPUs and
> > two 8 GPUs node connected through each other with fast mesh (ie each
> > GPU can peer to peer to each other at the same bandwidth). Then this
> > 2 blocks are connected to the other block through a share link.
> > 
> > So it looks like:
> >     SOCKET0----SOCKET1-----SOCKET2----SOCKET3
> >     |          |           |          |
> >     S0-GPU0====S1-GPU0     S2-GPU0====S1-GPU0
> >     ||     \\//            ||     \\//
> >     ||     //\\            ||     //\\
> >     ...    ====...    -----...    ====...
> >     ||     \\//            ||     \\//
> >     ||     //\\            ||     //\\
> >     S0-GPU7====S1-GPU7     S2-GPU7====S3-GPU7
> 
> Well the existing NUMA node stuff tells userspace which GPU belongs to
> which socket (every device in sysfs already has a numa_node attribute).
> And if that's not good enough we should work to improve how that works
> for all devices. This problem isn't specific to GPUS or devices with
> memory and seems rather orthogonal to an API to bind to device memory.

HMS is generic and not for GPU only, i use GPU as example as they are
the first device introducing this complexity. I believe some of the
FPGA folks are working on same thing. I heard that more TPU like hardware
might also grow such complexity.

What you are proposing just seems to me like redoing HMS under the node
directory in sysfs which has the potential of confusing existing application
while providing no benefits (at least i fail to see any).

> > How the above example would looks like ? I fail to see how to do it
> > inside current sysfs. Maybe by creating multiple virtual device for
> > each of the inter-connect ? So something like
> > 
> > link0 -> device:00 which itself has S0-GPU0 ... S0-GPU7 has child
> > link1 -> device:01 which itself has S1-GPU0 ... S1-GPU7 has child
> > link2 -> device:02 which itself has S2-GPU0 ... S2-GPU7 has child
> > link3 -> device:03 which itself has S3-GPU0 ... S3-GPU7 has child
> 
> I think the "links" between GPUs themselves would be a bus. In the same
> way a NUMA node is a bus. Each device in sysfs would then need a
> directory or something to describe what "link bus(es)" they are a part
> of. Though there are other ways to do this: a GPU driver could simply
> create symlinks to other GPUs inside a "neighbours" directory under the
> device path or something like that.
> 
> The point is that this seems like it is specific to GPUs and could
> easily be solved in the GPU community without any new universal concepts
> or big APIs.

So it would be springly over all this informations in various sub-
directories. To me this is making userspace life harder. HMS only
has one directory hierarchy that userspace need to parse to extract
the information. From my point of view it is much better but this
might be a taste thing.

> 
> And for applications that need topology information, a lot of it is
> already there, we just need to fill in the gaps with small changes that
> would be much less controversial. Then if you want to create a libhms
> (or whatever) to help applications parse this information out of
> existing sysfs that would make sense.

How can i express multiple link, or memory that is only accessible
by a subset of the devices/CPUs. In today model they are back in
assumption like everyone can access all the node which do not hold
in what i am trying to do.

Yes i can do it by adding invalid peer node list inside each node
but this is all more complex from my point of view. Highly confusing
for existing application and with potential to break existing
application on new platform with such weird nodes.


> > My proposal is to do HMS behind staging for a while and also avoid
> > any disruption to existing code path. See with people living on the
> > bleeding edge if they get interested in that informations. If not then
> > i can strip down my thing to the bare minimum which is about device
> > memory.
> 
> This isn't my area or decision to make, but it seemed to me like this is
> not what staging is for. Staging is for introducing *drivers* that
> aren't up to the Kernel's quality level and they all reside under the
> drivers/staging path. It's not meant to introduce experimental APIs
> around the kernel that might be revoked at anytime.
> 
> DAX introduced itself by marking the config option as EXPERIMENTAL and
> printing warnings to dmesg when someone tries to use it. But, to my
> knowledge, DAX also wasn't creating APIs with the intention of changing
> or revoking them -- it was introducing features using largely existing
> APIs that had many broken corner cases.
> 
> Do you know of any precedents where big APIs were introduced and then
> later revoked or radically changed like you are proposing to do?

Yeah it is kind of an issue, i can go the experimental way, idealy
what i would like is a kernel option that enable it with a kernel
boot parameter as an extra gate keeper so i can distribute kernel
with that feature inside some distribution and then provide simple
instruction for people to test (much easier to give a kernel boot
parameter than to have people rebuild a kernel).

I am open to any suggestion on what would be the best guideline to
experiment with API. The issue is that the changes to userspace are
big and takes time (month of works). So if i have to everything line
up and ready (userspace and kernel) in just one go then it is gonna
be painful. My pain i guess so other don't care ... :)

Cheers,
J�r�me
