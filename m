Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 756386B70E3
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 16:51:52 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id w1so18401847qta.12
        for <linux-mm@kvack.org>; Tue, 04 Dec 2018 13:51:52 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id j13si11158686qtj.296.2018.12.04.13.51.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Dec 2018 13:51:51 -0800 (PST)
Date: Tue, 4 Dec 2018 16:51:46 -0500
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [RFC PATCH 02/14] mm/hms: heterogenenous memory system (HMS)
 documentation
Message-ID: <20181204215146.GO2937@redhat.com>
References: <20181204182421.GC2937@redhat.com>
 <CAPcyv4gtv7eUc1_3Yhz-f-B3Lct=Vq7zqUJKOqCtWYb4BS6i9g@mail.gmail.com>
 <20181204185725.GE2937@redhat.com>
 <de7c1099-2717-6396-bf56-c4ab4085ee83@deltatee.com>
 <20181204192221.GG2937@redhat.com>
 <f759cc28-309d-930c-da7d-34144a4d5517@deltatee.com>
 <20181204201347.GK2937@redhat.com>
 <2f146730-1bf9-db75-911d-67809fc7afef@deltatee.com>
 <20181204205902.GM2937@redhat.com>
 <e4d8bf6b-5b2c-58a5-577b-66d02f2342c1@deltatee.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <e4d8bf6b-5b2c-58a5-577b-66d02f2342c1@deltatee.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Logan Gunthorpe <logang@deltatee.com>
Cc: Dan Williams <dan.j.williams@intel.com>, Andi Kleen <ak@linux.intel.com>, Linux MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "Rafael J. Wysocki" <rafael@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Haggai Eran <haggaie@mellanox.com>, balbirs@au1.ibm.com, "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, "Kuehling, Felix" <felix.kuehling@amd.com>, Philip.Yang@amd.com, "Koenig, Christian" <christian.koenig@amd.com>, "Blinzer, Paul" <Paul.Blinzer@amd.com>, John Hubbard <jhubbard@nvidia.com>, rcampbell@nvidia.com

On Tue, Dec 04, 2018 at 02:19:09PM -0700, Logan Gunthorpe wrote:
> 
> 
> On 2018-12-04 1:59 p.m., Jerome Glisse wrote:
> > How to expose harmful memory to userspace then ? How can i expose
> > non cache coherent memory because yes they are application out there
> > that use that today and would like to be able to migrate to and from
> > that memory dynamicly during lifetime of the application as the data
> > set progress through the application processing pipeline.
> 
> I'm not arguing against the purpose or use cases. I'm being critical of
> the API choices.
> 
> > Note that i do not expose things like physical address or even splits
> > memory in a node into individual device, in fact in expose less
> > information that the existing NUMA (no zone, phys index, ...). As i do
> > not think those have any value to userspace. What matter to userspace
> > is where is this memory is in my topology so i can look at all the
> > initiators node that are close by. Or the reverse, i have a set of
> > initiators what is the set of closest targets to all those initiators.
> 
> No, what matters to applications is getting memory that will work for
> the initiators/resources they need it to work for. The specific topology
> might be of interest to administrators but it is not what applications
> need. And it should be relatively easy to flesh out the existing sysfs
> device tree to provide the topology information administrators need.

Existing user would disagree in my cover letter i have given pointer
to existing library and paper from HPC folks that do leverage system
topology (among the few who are). So they are application _today_ that
do use topology information to adapt their workload to maximize the
performance for the platform they run on.

They are also some new platform that have much more complex topology
that definitly can not be represented as a tree like today sysfs we
have (i believe that even some of the HPC folks have _today_ topology
that are not tree-like).

So existing user + random graph topology becoming more commons lead
me to the choice i made in this API. I believe a graph is someting
that can easily be understood by people. I am not inventing some
weird new data structure, it is just a graph and for the name i have
use the ACPI naming convention but i am more than open to use memory
for target and differentiate cpu and device instead of using initiator
as a name. I do not have strong feeling on that. I do however would
like to be able to represent any topology and be able to use device
memory that is not manage by core mm for reasons i explained previously.

Note that if it turn out to be a bad idea kernel can decide to dumb
down thing in future version for new platform. So it could give a
flat graph to userspace, there is nothing precluding that.


> > I am talking about the inevitable fact that at some point some system
> > firmware will miss-represent their platform. System firmware writer
> > usualy copy and paste thing with little regards to what have change
> > from one platform to the new. So their will be inevitable workaround
> > and i would rather see those piling up inside a userspace library than
> > inside the kernel.
> 
> It's *absolutely* the kernel's responsibility to patch issues caused by
> broken firmware. We have quirks all over the place for this. That's
> never something userspace should be responsible for. Really, this is the
> raison d'etre of the kernel: to provide userspace with a uniform
> execution environment -- if every application had to deal with broken
> firmware it would be a nightmare.

You cuted the other paragraph that explained why they will unlikely
to be broken badly enough to break the kernel.

Anyway we can fix the topology in kernel too ... that is fine with
me.

Cheers,
J�r�me
