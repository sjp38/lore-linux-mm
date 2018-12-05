Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0204E6B76C2
	for <linux-mm@kvack.org>; Wed,  5 Dec 2018 17:58:36 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id d196so21495133qkb.6
        for <linux-mm@kvack.org>; Wed, 05 Dec 2018 14:58:35 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f9si2099110qvd.54.2018.12.05.14.58.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Dec 2018 14:58:34 -0800 (PST)
Date: Wed, 5 Dec 2018 17:58:28 -0500
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [RFC PATCH 02/14] mm/hms: heterogenenous memory system (HMS)
 documentation
Message-ID: <20181205225828.GL3536@redhat.com>
References: <20181204235630.GQ2937@redhat.com>
 <b77849e1-e05a-1071-7c48-ac93191e3134@deltatee.com>
 <20181205023116.GD3045@redhat.com>
 <a5ae63ff-a913-25af-4648-4ebf91775412@deltatee.com>
 <20181205180756.GI3536@redhat.com>
 <e5c740fd-0256-8b70-cd06-6d6fee19806d@deltatee.com>
 <20181205183314.GJ3536@redhat.com>
 <0ddb2620-ecbd-4b7b-aeb7-3f4ae7746e83@deltatee.com>
 <20181205185550.GK3536@redhat.com>
 <7ab26ea6-d16d-8d71-78ca-4266a864f8d3@deltatee.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <7ab26ea6-d16d-8d71-78ca-4266a864f8d3@deltatee.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Logan Gunthorpe <logang@deltatee.com>
Cc: Dan Williams <dan.j.williams@intel.com>, Andi Kleen <ak@linux.intel.com>, Linux MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "Rafael J. Wysocki" <rafael@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Haggai Eran <haggaie@mellanox.com>, balbirs@au1.ibm.com, "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, "Kuehling, Felix" <felix.kuehling@amd.com>, Philip.Yang@amd.com, "Koenig, Christian" <christian.koenig@amd.com>, "Blinzer, Paul" <Paul.Blinzer@amd.com>, John Hubbard <jhubbard@nvidia.com>, rcampbell@nvidia.com

On Wed, Dec 05, 2018 at 12:10:10PM -0700, Logan Gunthorpe wrote:
> 
> 
> On 2018-12-05 11:55 a.m., Jerome Glisse wrote:
> > So now once next type of device shows up with the exact same thing
> > let say FPGA, we have to create a new subsystem for them too. Also
> > this make the userspace life much much harder. Now userspace must
> > go parse PCIE, subsystem1, subsystem2, subsystemN, NUMA, ... and
> > merge all that different information together and rebuild the
> > representation i am putting forward in this patchset in userspace.
> 
> Yes. But seeing such FPGA links aren't common yet and there isn't really
> much in terms of common FPGA infrastructure in the kernel (which are
> hard seeing the hardware is infinitely customization) you can let the
> people developing FPGA code worry about it and come up with their own
> solution. Buses between FPGAs may end up never being common enough for
> people to care, or they may end up being so weird that they need their
> own description independent of GPUS, or maybe when they become common
> they find a way to use the GPU link subsystem -- who knows. Don't try to
> design for use cases that don't exist yet.
> 
> Yes, userspace will have to know about all the buses it cares to find
> links over. Sounds like a perfect thing for libhms to do.

So just to be clear here is how i understand your position:
"Single coherent sysfs hierarchy to describe something is useless
 let's git rm drivers/base/"

While i am arguing that "hey the /sys/bus/node/devices/* is nice
but it just does not cut it for all this new hardware platform
if i add new nodes there for my new memory i will break tons of
existing application. So what about a new hierarchy that allow
to describe those new hardware platform in a single place like
today node thing"


> 
> > There is no telling that kernel won't be able to provide quirk and
> > workaround because some merging is actually illegal on a given
> > platform (like some link from a subsystem is not accessible through
> > the PCI connection of one of the device connected to that link).
> 
> These are all just different individual problems which need different
> solutions not grand new design concepts.
> 
> > So it means userspace will have to grow its own database or work-
> > around and quirk and i am back in the situation i am in today.
> 
> No, as I've said, quirks are firmly the responsibility of kernels.
> Userspace will need to know how to work with the different buses and
> CPU/node information but there really isn't that many of these to deal
> with and this is a much easier approach than trying to come up with a
> new API that can wrap the nuances of all existing and potential future
> bus types we may have to deal with.

No can do that is what i am trying to explain. So if i bus 1 in a
sub-system A and usualy that kind of bus can serve a bridge for
PCIE ie a CPU can access device behind it by going through a PCIE
device first. So now the userspace libary have this knowledge
bake in. Now if a platform has a bug for whatever reasons where
that does not hold, the kernel has no way to tell userspace that
there is an exception there. It is up to userspace to have a data
base of quirks.

Kernel see all those objects in isolation in your scheme. While in
what i am proposing there is only one place and any device that
participate in this common place can report any quirks so that a
coherent view is given to user space.

If we have gazillion of places where all this informations is spread
around than we have no way to fix weird inter-action between any
of those.

Cheers,
J�r�me
