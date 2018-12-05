Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 194576B75B9
	for <linux-mm@kvack.org>; Wed,  5 Dec 2018 13:33:22 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id n45so21723834qta.5
        for <linux-mm@kvack.org>; Wed, 05 Dec 2018 10:33:22 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id i17si1572182qte.298.2018.12.05.10.33.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Dec 2018 10:33:21 -0800 (PST)
Date: Wed, 5 Dec 2018 13:33:15 -0500
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [RFC PATCH 02/14] mm/hms: heterogenenous memory system (HMS)
 documentation
Message-ID: <20181205183314.GJ3536@redhat.com>
References: <20181204205902.GM2937@redhat.com>
 <e4d8bf6b-5b2c-58a5-577b-66d02f2342c1@deltatee.com>
 <20181204215146.GO2937@redhat.com>
 <c5cf87e8-9104-c2e6-9646-188f66fec581@deltatee.com>
 <20181204235630.GQ2937@redhat.com>
 <b77849e1-e05a-1071-7c48-ac93191e3134@deltatee.com>
 <20181205023116.GD3045@redhat.com>
 <a5ae63ff-a913-25af-4648-4ebf91775412@deltatee.com>
 <20181205180756.GI3536@redhat.com>
 <e5c740fd-0256-8b70-cd06-6d6fee19806d@deltatee.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <e5c740fd-0256-8b70-cd06-6d6fee19806d@deltatee.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Logan Gunthorpe <logang@deltatee.com>
Cc: Dan Williams <dan.j.williams@intel.com>, Andi Kleen <ak@linux.intel.com>, Linux MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "Rafael J. Wysocki" <rafael@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Haggai Eran <haggaie@mellanox.com>, balbirs@au1.ibm.com, "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, "Kuehling, Felix" <felix.kuehling@amd.com>, Philip.Yang@amd.com, "Koenig, Christian" <christian.koenig@amd.com>, "Blinzer, Paul" <Paul.Blinzer@amd.com>, John Hubbard <jhubbard@nvidia.com>, rcampbell@nvidia.com

On Wed, Dec 05, 2018 at 11:20:30AM -0700, Logan Gunthorpe wrote:
> 
> 
> On 2018-12-05 11:07 a.m., Jerome Glisse wrote:
> >> Well multiple links are easy when you have a 'link' bus. Just add
> >> another link device under the bus.
> > 
> > So you are telling do what i am doing in this patchset but not under
> > HMS directory ?
> 
> No, it's completely different. I'm talking about creating a bus to
> describe only the real hardware that links GPUs. Not creating a new
> virtual tree containing a bunch of duplicate bus and device information
> that already exists currently in sysfs.
> 
> >>
> >> Technically, the accessibility issue is already encoded in sysfs. For
> >> example, through the PCI tree you can determine which ACS bits are set
> >> and determine which devices are behind the same root bridge the same way
> >> we do in the kernel p2pdma subsystem. This is all bus specific which is
> >> fine, but if we want to change that, we should have a common way for
> >> existing buses to describe these attributes in the existing tree. The
> >> new 'link' bus devices would have to have some way to describe cases if
> >> memory isn't accessible in some way across it.
> > 
> > What i am looking at is much more complex than just access bit. It
> > is a whole set of properties attach to each path (can it be cache
> > coherent ? can it do atomic ? what is the access granularity ? what
> > is the bandwidth ? is it dedicated link ? ...)
> 
> I'm not talking about just an access bit. I'm talking about what you are
> describing: standard ways for *existing* buses in the sysfs hierarchy to
> describe things like cache coherency, atomics, granularity, etc without
> creating a new hierarchy.
> 
> > On top of that i argue that more people would use that information if it
> > were available to them. I agree that i have no hard evidence to back that
> > up and that it is just a feeling but you can not disprove me either as
> > this is a chicken and egg problem, you can not prove people will not use
> > an API if the API is not there to be use.
> 
> And you miss my point that much of this information is already available
> to them. And more can be added in the existing framework without
> creating any brand new concepts. I haven't said anything about
> chicken-and-egg problems -- I've given you a bunch of different
> suggestions to split this up into more managable problems and address
> many of them within the APIs and frameworks we have already.

The thing is that what i am considering is not in sysfs, it does not
even have linux kernel driver, it is just chips that connect device
between them and there is nothing to do with those chips it is all
hardware they do not need a driver. So there is nothing existing that
address what i need to represent.

If i add a a fake driver for those what would i do ? under which
sub-system i register them ? How i express the fact that they
connect device X,Y and Z with some properties ?

This is not PCIE ... you can not discover bridges and child, it
not a tree like structure, it is a random graph (which depends
on how the OEM wire port on the chips).


So i have not pre-existing driver, they are not in sysfs today and
they do not need a driver. Hence why i proposed what i proposed
a sysfs hierarchy where i can add those "virtual" object and shows
how they connect existing device for which we have a sysfs directory
to symlink.


Cheers,
J�r�me
