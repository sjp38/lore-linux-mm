Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id E9D9C6B0038
	for <linux-mm@kvack.org>; Mon, 15 May 2017 19:45:46 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id x184so228514wmf.14
        for <linux-mm@kvack.org>; Mon, 15 May 2017 16:45:46 -0700 (PDT)
Received: from mail-wm0-x241.google.com (mail-wm0-x241.google.com. [2a00:1450:400c:c09::241])
        by mx.google.com with ESMTPS id g48si13426875wrg.239.2017.05.15.16.45.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 May 2017 16:45:44 -0700 (PDT)
Received: by mail-wm0-x241.google.com with SMTP id v4so32813818wmb.2
        for <linux-mm@kvack.org>; Mon, 15 May 2017 16:45:44 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170512102652.ltvzzwejkfat7sdq@techsingularity.net>
References: <1494569882.21563.8.camel@gmail.com> <20170512102652.ltvzzwejkfat7sdq@techsingularity.net>
From: Balbir Singh <bsingharora@gmail.com>
Date: Tue, 16 May 2017 09:45:43 +1000
Message-ID: <CAKTCnz=VkswmWxoniD-TRYWWxr7wrWwCgRcsTXfNkgHZKXDEwA@mail.gmail.com>
Subject: Re: [RFC summary] Enable Coherent Device Memory
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: linux-mm <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Aneesh Kumar KV <aneesh.kumar@linux.vnet.ibm.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Haren Myneni <haren@linux.vnet.ibm.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

Hi, Mel

On Fri, May 12, 2017 at 8:26 PM, Mel Gorman <mgorman@techsingularity.net> wrote:
> On Fri, May 12, 2017 at 04:18:02PM +1000, Balbir Singh wrote:
>> Why do we need to isolate memory?
>>  - CDM memory is not meant for normal usage, applications can request for it
>>    explictly. Oflload their compute to the device where the memory is
>>    (the offload is via a user space API like CUDA/openCL/...)
>
> It still remains unanswered to a large extent why this cannot be
> isolated after the fact via a standard mechanism. It may be easier if
> the onlining of CDM memory can be deferred at boot until userspace
> helpers can trigger the onlining and isolation.
>

Sure, yes! I also see the need to have tasks migrate between
cpusets at runtime, depending on a trigger mechanism, the allocation
request maybe?

>> How do we isolate the memory - NUMA or HMM-CDM?
>>  - Since the memory is coherent, NUMA provides the mechanism to isolate to
>>    a large extent via mempolicy. With NUMA we also get autonuma/kswapd/etc
>>    running.
>
> This has come up before with respect to autonuma and there appears to be
> confusion. autonuma doesn't run on nodes as such. The page table hinting
> happens in per-task context but should skip VMAs that are controlled by
> a policy. While some care is needed from the application, it's managable
> and would perform better than special casing the marking of pages placed
> on a CDM-controlled node.
>

I presume your referring to vma_is_migratable() bits, but it means the
application
does malloc() followed by madvise() or something else to mark the VMA. The mm
could do some of this automatically depending on the node from which a fault/
allocation occurs. But a VMA could contain pages from different nodes. In my
current branch the checks are in numa_migrate_prep() to check if the page
belongs to CDM memory.

> As for kswapd, there isn't a user-controllable method for controlling
> this. However, if a device onlining the memory set the watermarks to 0,
> it would allow the full CDM memory to be used by the application and kswapd
> would never be woken.

Fair point, I presume you are suggesting we set the low/min/high to 0.

>
> KSM is potentially more problematic and initially may have to be disabled
> entirely to determine if it actually matters for CDM-aware applications or
> not. KSM normally comes into play with virtual machines are involved so it
> would have to be decided if CDM is being exposed to guests with pass-thru
> or some other mechanism. Initially, just disable it unless the use cases
> are known.

OK.. With mixed workloads we may selectively enable and ensure that none
of the MERGABLE pages end up on CDM

>
>>    Something we would like to avoid. NUMA gives the application
>>    a transparent view of memory, in the sense that all mm features work,
>>    like direct page cache allocation in coherent device memory, limiting
>>    memory via cgroups if required, etc. With CPUSets, its
>>    possible for us to isolate allocation. One challenge is that the
>>    admin on the system may use them differently and applications need to
>>    be aware of running in the right cpuset to allocate memory from the
>>    CDM node.
>
> An admin and application has to deal with this complexity regardless.

I was thinking along the lines of cpusets working orthogonal to CDM
and not managing CDM memory, that way the concerns are different.
A policy set on cpusets does not impact CDM memory. It also means
that CDM memory is not used for total memory computation and related
statistics.

> Particular care would be needed for file-backed data as an application
> would have to ensure the data was not already cache resident. For
> example, creating a data file and then doing computation on it may be
> problematic. Unconditionally, the application is going to have to deal
> with migration.
>

Ins't migration transparent to the application, it may affect performance.

> Identifying issues like this are why an end-to-end application that
> takes advantage of the feature is important. Otherwise, there is a risk
> that APIs are exposed to userspace that are Linux-specific,
> device-specific and unusable.
>
>>    Putting all applications in the cpuset with the CDM node is
>>    not the right thing to do, which means the application needs to move itself
>>    to the right cpuset before requesting for CDM memory. It's not impossible
>>    to use CPUsets, just hard to configure correctly.
>
> They optionally could also use move_pages.

move_pages() to move the memory to the right node after the allocation?

>
>>   - With HMM, we would need a HMM variant HMM-CDM, so that we are not marking
>>    the pages as unavailable, page cache cannot do directly to coherent memory.
>>    Audit of mm paths is required. Most of the other things should work.
>>    User access to HMM-CDM memory behind ZONE_DEVICE is via a device driver.
>
> The main reason why I would prefer HMM-CDM is two-fold. The first is
> that using these accelerators still has use cases that are not very well
> defined but if an application could use either CDM or HMM transparently
> then it may be better overall.
>
> The second reason is because there are technologies like near-memory coming
> in the future and there is no infrastructure in place to take advantage like
> that. I haven't even heard of plans from developers working with vendors of
> such devices on how they intend to support it. Hence, the desired policies
> are unknown such as whether the near memory should be isolated or if there
> should be policies that promote/demote data between NUMA nodes instead of
> reclaim. While I'm not involved in enabling such technology, I worry that
> there will be collisiosn in the policies required for CDM and those required
> for near-memory but once the API is exposed to userspace, it becomes fixed.
>

OK, I see your concern, it is definitely valid. We do have a use case,
but I wonder
how long we wait?

>> Do we need to isolate node attributes independent of coherent device memory?
>>  - Christoph Lameter thought it would be useful to isolate node attributes,
>>    specifically ksm/autonuma for low latency suff.
>
> Whatever about KSM, I would have suggested that autonuma have a prctl
> flag to disable autonuma on a per-task basis. It would be sufficient for
> anonymous memory at least. It would have some hazards if a
> latency-sensitive application shared file-backed data with a normal
> application but latency-sensitive applications generally have to take
> care to isolate themselves properly.
>

OK, I was planning on doing an isolated feature set. But I am still trying
to think what it would mean in terms of complexity to the mm. Not having
all of N_MEMORY participating in a particular feature/algorithm is something
most admins will not want to enable.

>> Why do we need migration?
>>  - Depending on where the memory is being accessed from, we would like to
>>    migrate pages between system and coherent device memory. HMM provides
>>    DMA offload capability that is useful in both cases.
>
> That suggests that HMM would be a better idea.

Yes, the total end-to-end did include HMM to begin with, we need the migration
capabilities from HMM, even with NUMA-CDM.

>
>> What is the larger picture - end to end?
>>  - Applications can allocate memory on the device or in system memory,
>>    offload the compute via user space API. Migration can be used for performance
>>    if required since it helps to keep the memory local to the compute.
>>
>
> The end-to-end is what matters because there is an expectation that
> applications will have to use libraries to control the actual acceleration
> and collection of results. The same libraries should be responsible for
> doing the migration if necessary. While I accept that bringing up the
> library would be inconvenient as supporting tools will be needed for the
> application, it's better than quickly exposting CDM devices as NUMA as this
> suggests, applying the policies and then finding the same supporting tools
> and libraries were needed anyway and the proposed policies did not help.
>
>> Comments from the thread
>>
>> 1. If we go down the NUMA path, we need to live with the limitations of
>>    what comes with the cpuless NUMA node
>> 2. The changes made to cpusets and mempolicies, make the code more complex
>> 3. We need a good end to end story
>>
>> The comments from the thread were responded to
>>
>> How do we go about implementing CDM then?
>>
>> The recommendation from John Hubbard/Mel Gorman and Michal Hocko is to
>> use HMM-CDM to solve the problem. Jerome/Balbir and Ben H prefer NUMA-CDM.
>> There were suggestions that NUMA might not be ready or is the best approach
>> in the long term, but we are yet to identify what changes to NUMA would
>> enable it to support NUMA-CDM.
>>
>
> Primarily, I would suggest that HMM-CDM be taken as far as possible on the
> hope/expectation that an application could transparently use either CDM
> (memory visible to both CPU and device) or HMM (special care required)
> with a common library API. This may be unworkable ultimately but it's
> impossible to know unless someone is fully up to date with exactly how
> these devices are to be used by appliications.
>
> If NUMA nodes are still required then the initial path appears to
> be controlling the onlining of memory from the device, isolating from
> userspace with existing mechanisms and using library awareness to control
> the migration. If DMA offloading is required then the device would also
> need to control that which may or may not push it towards HMM again.
>

Agreeed, but I think both NUMA and DMA offloading are possible together.
The user space uses NUMA API's and the driver can use DMA offloading
for migration of pages depending on any heuristics or user provided
hints that a page may be soon needed on the device. Some application
details depend on whether the memory is fully driver managed (HMM-CDM)
or NUMA. We've been seriously looking at HMM-CDM as an alternative
to NUMA. We'll push in that direction and see beyond our audting what
else we run into.

Thanks for the detailed feedback,
Balbir Singh.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
