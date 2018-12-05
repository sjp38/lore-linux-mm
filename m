Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id B83016B75CF
	for <linux-mm@kvack.org>; Wed,  5 Dec 2018 13:55:57 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id k90so21770397qte.0
        for <linux-mm@kvack.org>; Wed, 05 Dec 2018 10:55:57 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id j23si2579461qtq.0.2018.12.05.10.55.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Dec 2018 10:55:56 -0800 (PST)
Date: Wed, 5 Dec 2018 13:55:51 -0500
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [RFC PATCH 02/14] mm/hms: heterogenenous memory system (HMS)
 documentation
Message-ID: <20181205185550.GK3536@redhat.com>
References: <20181204215146.GO2937@redhat.com>
 <c5cf87e8-9104-c2e6-9646-188f66fec581@deltatee.com>
 <20181204235630.GQ2937@redhat.com>
 <b77849e1-e05a-1071-7c48-ac93191e3134@deltatee.com>
 <20181205023116.GD3045@redhat.com>
 <a5ae63ff-a913-25af-4648-4ebf91775412@deltatee.com>
 <20181205180756.GI3536@redhat.com>
 <e5c740fd-0256-8b70-cd06-6d6fee19806d@deltatee.com>
 <20181205183314.GJ3536@redhat.com>
 <0ddb2620-ecbd-4b7b-aeb7-3f4ae7746e83@deltatee.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <0ddb2620-ecbd-4b7b-aeb7-3f4ae7746e83@deltatee.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Logan Gunthorpe <logang@deltatee.com>
Cc: Dan Williams <dan.j.williams@intel.com>, Andi Kleen <ak@linux.intel.com>, Linux MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "Rafael J. Wysocki" <rafael@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Haggai Eran <haggaie@mellanox.com>, balbirs@au1.ibm.com, "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, "Kuehling, Felix" <felix.kuehling@amd.com>, Philip.Yang@amd.com, "Koenig, Christian" <christian.koenig@amd.com>, "Blinzer, Paul" <Paul.Blinzer@amd.com>, John Hubbard <jhubbard@nvidia.com>, rcampbell@nvidia.com

On Wed, Dec 05, 2018 at 11:48:37AM -0700, Logan Gunthorpe wrote:
> 
> 
> On 2018-12-05 11:33 a.m., Jerome Glisse wrote:
> > If i add a a fake driver for those what would i do ? under which
> > sub-system i register them ? How i express the fact that they
> > connect device X,Y and Z with some properties ?
> 
> Yes this is exactly what I'm suggesting. I wouldn't call it a fake
> driver, but a new struct device describing an actual device in the
> system. It would be a feature of the GPU subsystem seeing this is a
> feature of GPUs. Expressing that the new devices connect to a specific
> set of GPUs is not a hard problem to solve.
> 
> > This is not PCIE ... you can not discover bridges and child, it
> > not a tree like structure, it is a random graph (which depends
> > on how the OEM wire port on the chips).
> 
> You must be able to discover that these links exist and register a
> device with the system. Where else do you get the information currently?
> The suggestion doesn't change anything to do with how you interact with
> hardware, only how you describe the information within the kernel.
> 
> > So i have not pre-existing driver, they are not in sysfs today and
> > they do not need a driver. Hence why i proposed what i proposed
> > a sysfs hierarchy where i can add those "virtual" object and shows
> > how they connect existing device for which we have a sysfs directory
> > to symlink.
> 
> So add a new driver -- that's what I've been suggesting all along.
> Having a driver not exist is no reason to not create one. I'd suggest
> that if you want them to show up in the sysfs hierarchy then you do need
> some kind of driver code to create a struct device. Just because the
> kernel doesn't have to interact with them is no reason not to create a
> struct device. It's *much* easier to create a new driver subsystem than
> a whole new userspace API.

So now once next type of device shows up with the exact same thing
let say FPGA, we have to create a new subsystem for them too. Also
this make the userspace life much much harder. Now userspace must
go parse PCIE, subsystem1, subsystem2, subsystemN, NUMA, ... and
merge all that different information together and rebuild the
representation i am putting forward in this patchset in userspace.

There is no telling that kernel won't be able to provide quirk and
workaround because some merging is actually illegal on a given
platform (like some link from a subsystem is not accessible through
the PCI connection of one of the device connected to that link).

So it means userspace will have to grow its own database or work-
around and quirk and i am back in the situation i am in today.

Not very convincing to me. What i am proposing here is a new common
description provided by the kernel where we can reconciliate weird
interaction.

But i doubt i can convince you i will make progress on what i need
today and keep working on sysfs.

Cheers,
J�r�me
