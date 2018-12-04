Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id C6AE46B7099
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 15:41:59 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id m37so18383211qte.10
        for <linux-mm@kvack.org>; Tue, 04 Dec 2018 12:41:59 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 63si5879644qth.271.2018.12.04.12.41.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Dec 2018 12:41:58 -0800 (PST)
Date: Tue, 4 Dec 2018 15:41:53 -0500
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [RFC PATCH 02/14] mm/hms: heterogenenous memory system (HMS)
 documentation
Message-ID: <20181204204153.GL2937@redhat.com>
References: <20181203233509.20671-1-jglisse@redhat.com>
 <20181203233509.20671-3-jglisse@redhat.com>
 <875zw98bm4.fsf@linux.intel.com>
 <20181204182421.GC2937@redhat.com>
 <20181204201226.GG18167@tassilo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20181204201226.GG18167@tassilo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <ak@linux.intel.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, "Rafael J . Wysocki" <rafael@kernel.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>, Dave Hansen <dave.hansen@intel.com>, Haggai Eran <haggaie@mellanox.com>, Balbir Singh <balbirs@au1.ibm.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Felix Kuehling <felix.kuehling@amd.com>, Philip Yang <Philip.Yang@amd.com>, Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Logan Gunthorpe <logang@deltatee.com>, John Hubbard <jhubbard@nvidia.com>, Ralph Campbell <rcampbell@nvidia.com>

On Tue, Dec 04, 2018 at 12:12:26PM -0800, Andi Kleen wrote:
> On Tue, Dec 04, 2018 at 01:24:22PM -0500, Jerome Glisse wrote:
> > Fast forward 2020 and you have this new type of memory that is not cache
> > coherent and you want to expose this to userspace through HMS. What you
> > do is a kernel patch that introduce the v2 type for target and define a
> > set of new sysfs file to describe what v2 is. On this new computer you
> > report your usual main memory as v1 and your new memory as v2.
> > 
> > So the application that only knew about v1 will keep using any v1 memory
> > on your new platform but it will not use any of the new memory v2 which
> > is what you want to happen. You do not have to break existing application
> > while allowing to add new type of memory.
> 
> That seems entirely like the wrong model. We don't want to rewrite every
> application for adding a new memory type.
> 
> Rather there needs to be an abstract way to query memory of specific
> behavior: e.g. cache coherent, size >= xGB, fastest or lowest latency or similar
> 
> Sure there can be a name somewhere, but it should only be used
> for identification purposes, not to hard code in applications.

Discussion with Logan convinced me to use a mask for property like:
    - cache coherent
    - persistent
    ...

Then files for other properties like:
    - bandwidth (bytes/s)
    - latency
    - granularity (size of individual access or bus width)
    ...

> 
> Really you need to define some use cases and describe how your API
> handles them.

I have given examples of how application looks today and how they
transform with HMS in my email exchange with Dave Hansen. I will
add them to the documentation and to the cover letter in my next
posting.

> > > 
> > > It sounds like you're trying to define a system call with built in
> > > ioctl? Is that really a good idea?
> > > 
> > > If you need ioctl you know where to find it.
> > 
> > Well i would like to get thing running in the wild with some guinea pig
> > user to get feedback from end user. It would be easier if i can do this
> > with upstream kernel and not some random branch in my private repo. While
> > doing that i would like to avoid commiting to a syscall upstream. So the
> > way i see around this is doing a driver under staging with an ioctl which
> > will be turn into a syscall once some confidence into the API is gain.
> 
> Ok that's fine I guess.
> 
> But should be a clearly defined ioctl, not an ioctl with redefinable parameters
> (but perhaps I misunderstood your description)
>
> > In the present version i took the other approach of defining just one
> > API that can grow to do more thing. I know the unix way is one simple
> > tool for one simple job. I can switch to the simple call for one action.
> 
> Simple calls are better.

I will switch to one simple call for each individual action (policy and
migration).

> > > > +Current memory policy infrastructure is node oriented, instead of
> > > > +changing that and risking breakage and regression HMS adds a new
> > > > +heterogeneous policy tracking infra-structure. The expectation is
> > > > +that existing application can keep using mbind() and all existing
> > > > +infrastructure under-disturb and unaffected, while new application
> > > > +will use the new API and should avoid mix and matching both (as they
> > > > +can achieve the same thing with the new API).
> > > 
> > > I think we need a stronger motivation to define a completely
> > > parallel and somewhat redundant infrastructure. What breakage
> > > are you worried about?
> > 
> > Some memory expose through HMS is not allocated by regular memory
> > allocator. For instance GPU memory is manage by GPU driver, so when
> > you want to use GPU memory (either as a policy or by migrating to it)
> > you need to use the GPU allocator to allocate that memory. HMS adds
> > a bunch of callback to target structure so that device driver can
> > expose a generic API to core kernel to do such allocation.
> 
> We already have nodes without memory.
> We can also take out nodes out of the normal fall back lists.
> We also have nodes with special memory (e.g. DMA32)
> 
> Nothing you describe here cannot be handled with the existing nodes.

They are have been patchset in the past to exclude node from allocation
last time i check they all were rejected and people felt it was not a
good thing to do.

Also IIRC adding more node might be problematic as i think we do not
have many bits left inside the flags field of struct page. Right now
i do not believe in moving device memory as generic node inside the
linux kernel because for many folks that will just be a waste, people
only doing desktop and not using their GPU for compute will never get
a good usage from that. Graphic memory allocation is wildely different
from compute allocation which is more like CPU one.

So converting graphic driver to register their memory as node does
not seems as a good idea at this time. I doubt the GPU folks upstream
would accept that (with my GPU hat ons i would not).


> > > The obvious alternative would of course be to add some extra
> > > enumeration to the existing nodes.
> > 
> > We can not extend NUMA node to expose GPU memory. GPU memory on
> > current AMD and Intel platform is not cache coherent and thus
> > should not be use for random memory allocation. It should really
> 
> Sure you don't expose it as normal memory, but it can be still
> tied to a node. In fact you have to for the existing topology
> interface to work.

The existing topology interface is not use today for that memory
and people in GPU world do not see it as an interface that can be
use. See above discussion about GPU memory. This is the raison
d'�tre of this proposal. A new way to expose heterogeneous memory
to userspace.


> > copy and rebuild their data structure inside the new memory. When
> > you move over thing like tree or any complex data structure you have
> > to rebuilt it ie redo the pointers link between the nodes of your
> > data structure.
> > 
> > This is highly error prone complex and wasteful (you have to burn
> > CPU cycles to do that). Now if you can use the same address space
> > as all the other memory allocation in your program and move data
> > around from one device to another with a common API that works on
> > all the various devices, you are eliminating that complex step and
> > making the end user life much easier.
> > 
> > So i am doing this to help existing users by addressing an issues
> > that is becoming harder and harder to solve for userspace. My end
> > game is to blur the boundary between CPU and device like GPU, FPGA,
> 
> This is just high level rationale. You already had that ...
> 
> What I was looking for is how applications actually use the 
> API.
> 
> e.g. 
> 
> 1. Compute application is looking for fast cache coherent memory 
> for CPU usage.
> 
> What does it query and how does it decide and how does it allocate?

Application have an OpenCL context from the context it gets the
device initiator unique id from the device initiator unique id
it looks at all the links and bridge the initiator is connected
to. Which gives it a list of links it can order that list using
bandwidth first and latency second (ie 2 link with same bandwidth
will be order with the one with slowest latency first). It goes
over that list from best to worse and for each links it looks at
what target are also connected to that link. From that it build
an ordered list of targets. It also only pick cache coherent
memory in that list.

It now use this ordered list of targets to set policy or migrate
its buffer to the best memory. Kernel will first try to use the
first target, if it runs out of that memory it will use the next
target ... so on and so forth.


This can all be down inside a userspace common helper library for
ease of use. More advance application will do finer allocation
for instance they will partition their dataset using the access
frequency. Most accessed dataset in the application will use
the fastest memory (which is likely to be somewhat small ie
few GigaBytes), while dataset that are more sparsely accessed
will be push to use slower memory (but they are more of it).


> 2. Allocator in OpenCL application is looking for memory to share
> with OpenCL. How does it find memory?

Same process as above, starts from initiator id, build links
list then build all target that initiator can access. Then
order that list according to the property of interest to the
application (bandwidth, latency, ...). Once it has the target
list it can use either policy or migration. Policy if it is
for a new allocation, migration if it is to migrate an existing
buffer to memory that is more appropriate for the OpenCL device
under use.


> 3. Storage application is looking for larger but slower memory
> for CPU usage.

Application build a list of initiator corresponding to the CPU
it is using (bind too). From that list of initiator it builds
a list of links (considering bridge too). From the list of links
it builds a list of target (connected to those links).

Then it order the list of target by size (not by latency or
bandwidth). Once it has an ordered list of target then it use
either the policy or migrate API for the range of virtual
address it wants to affect.


> 
> 4. ...
> 
> Please work out some use cases like this.

Note that above all the list building in userspace is intended
to be done by an helper library as this is really boiler plate
code. The last patch in my serie have userspace helpers to
parse the sysfs, i will grow that into a mini library with example
to show case it.

More example from other part of this email thread:

High level overview of how one application looks today:

    1) Application get some dataset from some source (disk, network,
       sensors, ...)
    2) Application allocate memory on device A and copy over the dataset
    3) Application run some CPU code to format the copy of the dataset
       inside device A memory (rebuild pointers inside the dataset,
       this can represent millions and millions of operations)
    4) Application run code on device A that use the dataset
    5) Application allocate memory on device B and copy over result
       from device A
    6) Application run some CPU code to format the copy of the dataset
       inside device B (rebuild pointers inside the dataset,
       this can represent millions and millions of operations)
    7) Application run code on device B that use the dataset
    8) Application copy result over from device B and keep on doing its
       thing

How it looks with HMS:
    1) Application get some dataset from some source (disk, network,
       sensors, ...)
    2-3) Application calls HMS to migrate to device A memory
    4) Application run code on device A that use the dataset
    5-6) Application calls HMS to migrate to device B memory
    7) Application run code on device B that use the dataset
    8) Application calls HMS to migrate result to main memory

So we now avoid explicit copy and having to rebuild data structure
inside each device address space.


Above example is for migrate. Here is an example for how the
topology is use today:

    Application knows that the platform is running on have 16
    GPU split into 2 group of 8 GPUs each. GPU in each group can
    access each other memory with dedicated mesh links between
    each others. Full speed no traffic bottleneck.

    Application splits its GPU computation in 2 so that each
    partition runs on a group of interconnected GPU allowing
    them to share the dataset.

With HMS:
    Application can query the kernel to discover the topology of
    system it is running on and use it to partition and balance
    its workload accordingly. Same application should now be able
    to run on new platform without having to adapt it to it.

Cheers,
J�r�me
