Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id AACF66B70AB
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 15:59:08 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id w18so18254850qts.8
        for <linux-mm@kvack.org>; Tue, 04 Dec 2018 12:59:08 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id s16si7298428qvs.57.2018.12.04.12.59.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Dec 2018 12:59:07 -0800 (PST)
Date: Tue, 4 Dec 2018 15:59:02 -0500
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [RFC PATCH 02/14] mm/hms: heterogenenous memory system (HMS)
 documentation
Message-ID: <20181204205902.GM2937@redhat.com>
References: <20181203233509.20671-3-jglisse@redhat.com>
 <875zw98bm4.fsf@linux.intel.com>
 <20181204182421.GC2937@redhat.com>
 <CAPcyv4gtv7eUc1_3Yhz-f-B3Lct=Vq7zqUJKOqCtWYb4BS6i9g@mail.gmail.com>
 <20181204185725.GE2937@redhat.com>
 <de7c1099-2717-6396-bf56-c4ab4085ee83@deltatee.com>
 <20181204192221.GG2937@redhat.com>
 <f759cc28-309d-930c-da7d-34144a4d5517@deltatee.com>
 <20181204201347.GK2937@redhat.com>
 <2f146730-1bf9-db75-911d-67809fc7afef@deltatee.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <2f146730-1bf9-db75-911d-67809fc7afef@deltatee.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Logan Gunthorpe <logang@deltatee.com>
Cc: Dan Williams <dan.j.williams@intel.com>, Andi Kleen <ak@linux.intel.com>, Linux MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "Rafael J. Wysocki" <rafael@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Haggai Eran <haggaie@mellanox.com>, balbirs@au1.ibm.com, "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, "Kuehling, Felix" <felix.kuehling@amd.com>, Philip.Yang@amd.com, "Koenig, Christian" <christian.koenig@amd.com>, "Blinzer, Paul" <Paul.Blinzer@amd.com>, John Hubbard <jhubbard@nvidia.com>, rcampbell@nvidia.com

On Tue, Dec 04, 2018 at 01:30:01PM -0700, Logan Gunthorpe wrote:
> 
> 
> On 2018-12-04 1:13 p.m., Jerome Glisse wrote:
> > You are right many are non exclusive. It is just my feeling that having
> > a mask as a file inside the target directory might be overlook by the
> > application which might start using things it should not. At same time
> > i guess if i write the userspace library that abstract this kernel API
> > then i can enforce application to properly select thing.
> 
> I think this is just evidence that this is not a good API. If the user
> has the option to just ignore things or do it wrong that's a problem
> with the API. Using a prefix for the name doesn't change that fact.

How to expose harmful memory to userspace then ? How can i expose
non cache coherent memory because yes they are application out there
that use that today and would like to be able to migrate to and from
that memory dynamicly during lifetime of the application as the data
set progress through the application processing pipeline.

They are kind of memory that violate the memory model you expect from
the architecture. This memory is still useful nonetheless and it has
other enticing properties (like bandwidth or latency). The whole point
my proposal is to allow to expose this memory in a generic way so that
application that today rely on a gazillion of device specific API can
move over to common kernel API and consolidate their memory management
on top of a common kernel layers.

The dilema i am facing is exposing this memory while avoiding the non
aware application to accidently use it just because it is there without
understanding the implication that comes with it.

If you have any idea on how to expose this to userspace in a common
API i would happily take any suggestion :) My idea is this patchset
and i agree they are many thing to improve and i have already taken
many of the suggestion given so far.


> 
> > I do not think there is a way to answer that question. I am siding on the
> > side of this API can be dumb down in userspace by a common library. So let
> > expose the topology and let userspace dumb it down.
> 
> I fundamentally disagree with this approach to designing APIs. Saying
> "we'll give you the kitchen sink, add another layer to deal with the
> complexity" is actually just eschewing API design and makes it harder
> for kernel folks to know what userspace actually requires because they
> are multiple layers away.

Note that i do not expose things like physical address or even splits
memory in a node into individual device, in fact in expose less
information that the existing NUMA (no zone, phys index, ...). As i do
not think those have any value to userspace. What matter to userspace
is where is this memory is in my topology so i can look at all the
initiators node that are close by. Or the reverse, i have a set of
initiators what is the set of closest targets to all those initiators.

I feel this is simple enough to understand for anyone. It allows to
describe any topology, a libhms can dumb it down for average application
and more advance application can use the full description. They are
example of such application today. I argue that if we provide a common
API we might see more application but i won't pretend that i know that
for a fact. I am just making assumption here.


> 
> > If we dumb it down in the kernel i see few pitfalls:
> >     - kernel dumbing it down badly
> >     - kernel dumbing down code can grow out of control with gotcha
> >       for platform
> 
> This is just a matter of designing the APIs well. Don't do it badly.

I am talking about the inevitable fact that at some point some system
firmware will miss-represent their platform. System firmware writer
usualy copy and paste thing with little regards to what have change
from one platform to the new. So their will be inevitable workaround
and i would rather see those piling up inside a userspace library than
inside the kernel.

Note that i expec that the error won't be fatal but more along the
line of reporting wrong value for bandwidth, latency, ... So kernel
will most likely unaffected by system firmware error but those will
affect the performance of application that are told innaccurate
informations.


> >     - it is still harder to fix kernel than userspace in commercial
> >       user space (the whole RHEL business of slow moving and long
> >       supported kernel). So on those being able to fix thing in
> >       userspace sounds pretty enticing
> 
> I hear this argument a lot and it's not compelling to me. I don't think
> we should make decisions in upstream code to allow RHEL to bypass the
> kernel simply because it would be easier for them to distribute code
> changes.

Ok i will not bring it up, i have suffer enough on that front so i have
a trauma on this ;)

Cheers,
J�r�me
