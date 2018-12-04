Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 36E416B6D77
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 02:44:40 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id e68so11972880plb.3
        for <linux-mm@kvack.org>; Mon, 03 Dec 2018 23:44:40 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id p19si15029593pgj.375.2018.12.03.23.44.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Dec 2018 23:44:38 -0800 (PST)
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id wB47iOrk080564
	for <linux-mm@kvack.org>; Tue, 4 Dec 2018 02:44:37 -0500
Received: from e32.co.us.ibm.com (e32.co.us.ibm.com [32.97.110.150])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2p5k3rnbdv-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 04 Dec 2018 02:44:37 -0500
Received: from localhost
	by e32.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Tue, 4 Dec 2018 07:44:36 -0000
Subject: Re: [RFC PATCH 00/14] Heterogeneous Memory System (HMS) and hbind()
References: <20181203233509.20671-1-jglisse@redhat.com>
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Date: Tue, 4 Dec 2018 13:14:14 +0530
MIME-Version: 1.0
In-Reply-To: <20181203233509.20671-1-jglisse@redhat.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Message-Id: <d6899765-a3b1-464b-d310-862161e07d98@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: jglisse@redhat.com, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, "Rafael J . Wysocki" <rafael@kernel.org>, Matthew Wilcox <willy@infradead.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, Keith Busch <keith.busch@intel.com>, Dan Williams <dan.j.williams@intel.com>, Dave Hansen <dave.hansen@intel.com>, Haggai Eran <haggaie@mellanox.com>, Balbir Singh <bsingharora@gmail.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Felix Kuehling <felix.kuehling@amd.com>, Philip Yang <Philip.Yang@amd.com>, =?UTF-8?Q?Christian_K=c3=b6nig?= <christian.koenig@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Logan Gunthorpe <logang@deltatee.com>, John Hubbard <jhubbard@nvidia.com>, Ralph Campbell <rcampbell@nvidia.com>, Michal Hocko <mhocko@kernel.org>, Jonathan Cameron <jonathan.cameron@huawei.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Vivek Kini <vkini@nvidia.com>, Mel Gorman <mgorman@techsingularity.net>, Dave Airlie <airlied@redhat.com>, Ben Skeggs <bskeggs@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@surriel.com>, Ben Woodard <woodard@redhat.com>, linux-acpi@vger.kernel.org

On 12/4/18 5:04 AM, jglisse@redhat.com wrote:
> From: Jérôme Glisse <jglisse@redhat.com>
> 
> Heterogeneous memory system are becoming more and more the norm, in
> those system there is not only the main system memory for each node,
> but also device memory and|or memory hierarchy to consider. Device
> memory can comes from a device like GPU, FPGA, ... or from a memory
> only device (persistent memory, or high density memory device).
> 
> Memory hierarchy is when you not only have the main memory but also
> other type of memory like HBM (High Bandwidth Memory often stack up
> on CPU die or GPU die), peristent memory or high density memory (ie
> something slower then regular DDR DIMM but much bigger).
> 
> On top of this diversity of memories you also have to account for the
> system bus topology ie how all CPUs and devices are connected to each
> others. Userspace do not care about the exact physical topology but
> care about topology from behavior point of view ie what are all the
> paths between an initiator (anything that can initiate memory access
> like CPU, GPU, FGPA, network controller ...) and a target memory and
> what are all the properties of each of those path (bandwidth, latency,
> granularity, ...).
> 
> This means that it is no longer sufficient to consider a flat view
> for each node in a system but for maximum performance we need to
> account for all of this new memory but also for system topology.
> This is why this proposal is unlike the HMAT proposal [1] which
> tries to extend the existing NUMA for new type of memory. Here we
> are tackling a much more profound change that depart from NUMA.
> 
> 
> One of the reasons for radical change is the advance of accelerator
> like GPU or FPGA means that CPU is no longer the only piece where
> computation happens. It is becoming more and more common for an
> application to use a mix and match of different accelerator to
> perform its computation. So we can no longer satisfy our self with
> a CPU centric and flat view of a system like NUMA and NUMA distance.
> 
> 
> This patchset is a proposal to tackle this problems through three
> aspects:
>      1 - Expose complex system topology and various kind of memory
>          to user space so that application have a standard way and
>          single place to get all the information it cares about.
>      2 - A new API for user space to bind/provide hint to kernel on
>          which memory to use for range of virtual address (a new
>          mbind() syscall).
>      3 - Kernel side changes for vm policy to handle this changes
> 
> This patchset is not and end to end solution but it provides enough
> pieces to be useful against nouveau (upstream open source driver for
> NVidia GPU). It is intended as a starting point for discussion so
> that we can figure out what to do. To avoid having too much topics
> to discuss i am not considering memory cgroup for now but it is
> definitely something we will want to integrate with.
> 
> The rest of this emails is splits in 3 sections, the first section
> talks about complex system topology: what it is, how it is use today
> and how to describe it tomorrow. The second sections talks about
> new API to bind/provide hint to kernel for range of virtual address.
> The third section talks about new mechanism to track bind/hint
> provided by user space or device driver inside the kernel.
> 
> 
> 1) Complex system topology and representing them
> ------------------------------------------------
> 
> Inside a node you can have a complex topology of memory, for instance
> you can have multiple HBM memory in a node, each HBM memory tie to a
> set of CPUs (all of which are in the same node). This means that you
> have a hierarchy of memory for CPUs. The local fast HBM but which is
> expected to be relatively small compare to main memory and then the
> main memory. New memory technology might also deepen this hierarchy
> with another level of yet slower memory but gigantic in size (some
> persistent memory technology might fall into that category). Another
> example is device memory, and device themself can have a hierarchy
> like HBM on top of device core and main device memory.
> 
> On top of that you can have multiple path to access each memory and
> each path can have different properties (latency, bandwidth, ...).
> Also there is not always symmetry ie some memory might only be
> accessible by some device or CPU ie not accessible by everyone.
> 
> So a flat hierarchy for each node is not capable of representing this
> kind of complexity. To simplify discussion and because we do not want
> to single out CPU from device, from here on out we will use initiator
> to refer to either CPU or device. An initiator is any kind of CPU or
> device that can access memory (ie initiate memory access).
> 
> At this point a example of such system might help:
>      - 2 nodes and for each node:
>          - 1 CPU per node with 2 complex of CPUs cores per CPU
>          - one HBM memory for each complex of CPUs cores (200GB/s)
>          - CPUs cores complex are linked to each other (100GB/s)
>          - main memory is (90GB/s)
>          - 4 GPUs each with:
>              - HBM memory for each GPU (1000GB/s) (not CPU accessible)
>              - GDDR memory for each GPU (500GB/s) (CPU accessible)
>              - connected to CPU root controller (60GB/s)
>              - connected to other GPUs (even GPUs from the second
>                node) with GPU link (400GB/s)
> 
> In this example we restrict our self to bandwidth and ignore bus width
> or latency, this is just to simplify discussions but obviously they
> also factor in.
> 
> 
> Userspace very much would like to know about this information, for
> instance HPC folks have develop complex library to manage this and
> there is wide research on the topics [2] [3] [4] [5]. Today most of
> the work is done by hardcoding thing for specific platform. Which is
> somewhat acceptable for HPC folks where the platform stays the same
> for a long period of time. But if we want a more ubiquituous support
> we should aim to provide the information needed through standard
> kernel API such as the one presented in this patchset.
> 
> Roughly speaking i see two broads use case for topology information.
> First is for virtualization and vm where you want to segment your
> hardware properly for each vm (binding memory, CPU and GPU that are
> all close to each others). Second is for application, many of which
> can partition their workload to minimize exchange between partition
> allowing each partition to be bind to a subset of device and CPUs
> that are close to each others (for maximum locality). Here it is much
> more than just NUMA distance, you can leverage the memory hierarchy
> and  the system topology all-together (see [2] [3] [4] [5] for more
> references and details).
> 
> So this is not exposing topology just for the sake of cool graph in
> userspace. They are active user today of such information and if we
> want to growth and broaden the usage we should provide a unified API
> to standardize how that information is accessible to every one.
> 
> 
> One proposal so far to handle new type of memory is to user CPU less
> node for those [6]. While same idea can apply for device memory, it is
> still hard to describe multiple path with different property in such
> scheme. While it is backward compatible and have minimum changes, it
> simplify can not convey complex topology (think any kind of random
> graph, not just a tree like graph).
> 
> Thus far this kind of system have been use through device specific API
> and rely on all kind of system specific quirks. To avoid this going out
> of hands and grow into a bigger mess than it already is, this patchset
> tries to provide a common generic API that should fit various devices
> (GPU, FPGA, ...).
> 
> So this patchset propose a new way to expose to userspace the system
> topology. It relies on 4 types of objects:
>      - target: any kind of memory (main memory, HBM, device, ...)
>      - initiator: CPU or device (anything that can access memory)
>      - link: anything that link initiator and target
>      - bridges: anything that allow group of initiator to access
>        remote target (ie target they are not connected with directly
>        through an link)
> 
> Properties like bandwidth, latency, ... are all sets per bridges and
> links. All initiators connected to an link can access any target memory
> also connected to the same link and all with the same link properties.
> 
> Link do not need to match physical hardware ie you can have a single
> physical link match a single or multiples software expose link. This
> allows to model device connected to same physical link (like PCIE
> for instance) but not with same characteristics (like number of lane
> or lane speed in PCIE). The reverse is also true ie having a single
> software expose link match multiples physical link.
> 
> Bridges allows initiator to access remote link. A bridges connect two
> links to each others and is also specific to list of initiators (ie
> not all initiators connected to each of the link can use the bridge).
> Bridges have their own properties (bandwidth, latency, ...) so that
> the actual property value for each property is the lowest common
> denominator between bridge and each of the links.
> 
> 
> This model allows to describe any kind of directed graph and thus
> allows to describe any kind of topology we might see in the future.
> It is also easier to add new properties to each object type.
> 
> Moreover it can be use to expose devices capable to do peer to peer
> between them. For that simply have all devices capable to peer to
> peer to have a common link or use the bridge object if the peer to
> peer capabilities is only one way for instance.
> 
> 
> This patchset use the above scheme to expose system topology through
> sysfs under /sys/bus/hms/ with:
>      - /sys/bus/hms/devices/v%version-%id-target/ : a target memory,
>        each has a UID and you can usual value in that folder (node id,
>        size, ...)
> 
>      - /sys/bus/hms/devices/v%version-%id-initiator/ : an initiator
>        (CPU or device), each has a HMS UID but also a CPU id for CPU
>        (which match CPU id in (/sys/bus/cpu/). For device you have a
>        path that can be PCIE BUS ID for instance)
> 
>      - /sys/bus/hms/devices/v%version-%id-link : an link, each has a
>        UID and a file per property (bandwidth, latency, ...) you also
>        find a symlink to every target and initiator connected to that
>        link.
> 
>      - /sys/bus/hms/devices/v%version-%id-bridge : a bridge, each has
>        a UID and a file per property (bandwidth, latency, ...) you
>        also find a symlink to all initiators that can use that bridge.

is that version tagging really needed? What changes do you envision with 
versions?

> 
> To help with forward compatibility each object as a version value and
> it is mandatory for user space to only use target or initiator with
> version supported by the user space. For instance if user space only
> knows about what version 1 means and sees a target with version 2 then
> the user space must ignore that target as if it does not exist.
> 
> Mandating that allows the additions of new properties that break back-
> ward compatibility ie user space must know how this new property affect
> the object to be able to use it safely.
> 
> This patchset expose main memory of each node under a common target.
> For now device driver are responsible to register memory they want to
> expose through that scheme but in the future that information might
> come from the system firmware (this is a different discussion).
> 
> 
> 
> 2) hbind() bind range of virtual address to heterogeneous memory
> ----------------------------------------------------------------
> 
> With this new topology description the mbind() API is too limited to
> handle which memory to picks. This is why this patchset introduce a new
> API: hbind() for heterogeneous bind. The hbind() API allows to bind any
> kind of target memory (using the HMS target uid), this can be any memory
> expose through HMS ie main memory, HBM, device memory ...
> 
> So instead of using a bitmap, hbind() take an array of uid and each uid
> is a unique memory target inside the new memory topology description.
> User space also provide an array of modifiers. This patchset only define
> some modifier. Modifier can be seen as the flags parameter of mbind()
> but here we use an array so that user space can not only supply a modifier
> but also value with it. This should allow the API to grow more features
> in the future. Kernel should return -EINVAL if it is provided with an
> unkown modifier and just ignore the call all together, forcing the user
> space to restrict itself to modifier supported by the kernel it is
> running on (i know i am dreaming about well behave user space).
> 
> 
> Note that none of this is exclusive of automatic memory placement like
> autonuma. I also believe that we will see something similar to autonuma
> for device memory. This patchset is just there to provide new API for
> process that wish to have a fine control over their memory placement
> because process should know better than the kernel on where to place
> thing.
> 
> This patchset also add necessary bits to the nouveau open source driver
> for it to expose its memory and to allow process to bind some range to
> the GPU memory. Note that on x86 the GPU memory is not accessible by
> CPU because PCIE does not allow cache coherent access to device memory.
> Thus when using PCIE device memory on x86 it is mapped as swap out from
> CPU POV and any CPU access will triger a migration back to main memory
> (this is all part of HMM and nouveau not in this patchset).
> 
> This is all done under staging so that we can experiment with the user-
> space API for a while before committing to anything. Getting this right
> is hard and it might not happen on the first try so instead of having to
> support forever an API i would rather have it leave behind staging for
> people to experiment with and once we feel confident we have something
> we can live with then convert it to a syscall.
> 
> 
> 3) Tracking and applying heterogeneous memory policies
> ------------------------------------------------------
> 
> Current memory policy infrastructure is node oriented, instead of
> changing that and risking breakage and regression this patchset add a
> new heterogeneous policy tracking infra-structure. The expectation is
> that existing application can keep using mbind() and all existing
> infrastructure under-disturb and unaffected, while new application
> will use the new API and should avoid mix and matching both (as they
> can achieve the same thing with the new API).
> 
> Also the policy is not directly tie to the vma structure for a few
> reasons:
>      - avoid having to split vma for policy that do not cover full vma
>      - avoid changing too much vma code
>      - avoid growing the vma structure with an extra pointer
> So instead this patchset use the mmu_notifier API to track vma liveness
> (munmap(),mremap(),...).
> 
> This patchset is not tie to process memory allocation either (like said
> at the begining this is not and end to end patchset but a starting
> point). It does however demonstrate how migration to device memory can
> work under this scheme (using nouveau as a demonstration vehicle).
> 
> The overall design is simple, on hbind() call a hms policy structure
> is created for the supplied range and hms use the callback associated
> with the target memory. This callback is provided by device driver
> for device memory or by core HMS for regular main memory. The callback
> can decide to migrate the range to the target memories or do nothing
> (this can be influenced by flags provided to hbind() too).
> 
> 
> Latter patches can tie page fault with HMS policy to direct memory
> allocation to the right target. For now i would rather postpone that
> discussion until a consensus is reach on how to move forward on all
> the topics presented in this email. Start smalls, grow big ;)
> 
>

I liked the simplicity of keeping it outside all the existing memory 
management policy code. But that that is also the drawback isn't it?
We now have multiple entities tracking cpu and memory. (This reminded me 
of how we started with memcg in the early days).

Once we have these different types of targets, ideally the system should
be able to place them in the ideal location based on the affinity of the 
access. ie. we should automatically place the memory such that
initiator can access the target optimally. That is what we try to do 
with current system with autonuma. (You did mention that you are not 
looking at how this patch series will evolve to automatic handling of 
placement right now.) But i guess we want to see if the framework indeed 
help in achieving that goal. Having HMS outside the core memory
handling routines will be a road blocker there?

-aneesh
