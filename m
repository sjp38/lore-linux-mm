Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 97A236B02FA
	for <linux-mm@kvack.org>; Tue, 16 May 2017 04:43:06 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id w79so27926576wme.7
        for <linux-mm@kvack.org>; Tue, 16 May 2017 01:43:06 -0700 (PDT)
Received: from outbound-smtp04.blacknight.com (outbound-smtp04.blacknight.com. [81.17.249.35])
        by mx.google.com with ESMTPS id h80si1702999wmi.167.2017.05.16.01.43.04
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 16 May 2017 01:43:04 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail06.blacknight.ie [81.17.255.152])
	by outbound-smtp04.blacknight.com (Postfix) with ESMTPS id 416DE98A6B
	for <linux-mm@kvack.org>; Tue, 16 May 2017 08:43:04 +0000 (UTC)
Date: Tue, 16 May 2017 09:43:03 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [RFC summary] Enable Coherent Device Memory
Message-ID: <20170516084303.ag2lzvdohvh6weov@techsingularity.net>
References: <1494569882.21563.8.camel@gmail.com>
 <20170512102652.ltvzzwejkfat7sdq@techsingularity.net>
 <CAKTCnz=VkswmWxoniD-TRYWWxr7wrWwCgRcsTXfNkgHZKXDEwA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <CAKTCnz=VkswmWxoniD-TRYWWxr7wrWwCgRcsTXfNkgHZKXDEwA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>
Cc: linux-mm <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Aneesh Kumar KV <aneesh.kumar@linux.vnet.ibm.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Haren Myneni <haren@linux.vnet.ibm.com>, =?iso-8859-15?B?Suly9G1l?= Glisse <jglisse@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

On Tue, May 16, 2017 at 09:45:43AM +1000, Balbir Singh wrote:
> Hi, Mel
> 
> On Fri, May 12, 2017 at 8:26 PM, Mel Gorman <mgorman@techsingularity.net> wrote:
> > On Fri, May 12, 2017 at 04:18:02PM +1000, Balbir Singh wrote:
> >> Why do we need to isolate memory?
> >>  - CDM memory is not meant for normal usage, applications can request for it
> >>    explictly. Oflload their compute to the device where the memory is
> >>    (the offload is via a user space API like CUDA/openCL/...)
> >
> > It still remains unanswered to a large extent why this cannot be
> > isolated after the fact via a standard mechanism. It may be easier if
> > the onlining of CDM memory can be deferred at boot until userspace
> > helpers can trigger the onlining and isolation.
> >
> 
> Sure, yes! I also see the need to have tasks migrate between
> cpusets at runtime, depending on a trigger mechanism, the allocation
> request maybe?
> 

That would be a userspace decision and does not have to be a kernel
decision. It would likely be controlled by whatever moves tasks between
cpusets but if fine-grained control is needed then the application would
need to link to a library that can handle that via a callback mechanism.
The kernel is not going to automagically know what the application requires.

> >> How do we isolate the memory - NUMA or HMM-CDM?
> >>  - Since the memory is coherent, NUMA provides the mechanism to isolate to
> >>    a large extent via mempolicy. With NUMA we also get autonuma/kswapd/etc
> >>    running.
> >
> > This has come up before with respect to autonuma and there appears to be
> > confusion. autonuma doesn't run on nodes as such. The page table hinting
> > happens in per-task context but should skip VMAs that are controlled by
> > a policy. While some care is needed from the application, it's managable
> > and would perform better than special casing the marking of pages placed
> > on a CDM-controlled node.
> >
> 
> I presume your referring to vma_is_migratable() bits, but it means the
> application
> does malloc() followed by madvise() or something else to mark the
> VMA.

More likely set_mempolicy but as with other places, some degree of
application awareness is involved because at that the very least,
something needs to know how to trigger the CDM device to do computation
and co-ordinate to pickup the result.

> The mm
> could do some of this automatically depending on the node from which a fault/
> allocation occurs.

That would require wiring policy into the kernel unnecessarily and not
necessarily gain you anything. If control is handled at fault time, it
means that the VMA in question would also need to have CDM as the first
fallback as it's CPUless and therefore CDM cannot be local. Even with
that, it'd have to handle the case where the CDM node was full and a
fallback occurred and the kernel does not normally automatically "fix"
that without wiring a lot of policy in.

It's also unnecessary considering that an application can use policies
to bind a VMA to the CDM node, handle failures if desired or use
migration if fallbacks are allowed.

> But a VMA could contain pages from different nodes. In my
> current branch the checks are in numa_migrate_prep() to check if the page
> belongs to CDM memory.
> 

If the policies allow VMAs to contain pages from different nodes, then the
application needs to call move_pages. Wiring this into the kernel doesn't
really help anything as the application would need to handle any in-kernel
failures such as the CDM being full.

> > As for kswapd, there isn't a user-controllable method for controlling
> > this. However, if a device onlining the memory set the watermarks to 0,
> > it would allow the full CDM memory to be used by the application and kswapd
> > would never be woken.
> 
> Fair point, I presume you are suggesting we set the low/min/high to 0.
> 

Yes. If that is not doable for some reason then the initial userspace
support would have to take care to never allocate CDM below the high
watermark to avoid kswapd waking up.

> >
> > KSM is potentially more problematic and initially may have to be disabled
> > entirely to determine if it actually matters for CDM-aware applications or
> > not. KSM normally comes into play with virtual machines are involved so it
> > would have to be decided if CDM is being exposed to guests with pass-thru
> > or some other mechanism. Initially, just disable it unless the use cases
> > are known.
> 
> OK.. With mixed workloads we may selectively enable and ensure that none
> of the MERGABLE pages end up on CDM
> 

Yes, alternatively look into KSM settings or patches that prevent KSM
merging pages across nodes and get behind that. I'm struggling to see
why KSM in a CDM environment is even desirable so would suggest just
disabling it.

> >
> >>    Something we would like to avoid. NUMA gives the application
> >>    a transparent view of memory, in the sense that all mm features work,
> >>    like direct page cache allocation in coherent device memory, limiting
> >>    memory via cgroups if required, etc. With CPUSets, its
> >>    possible for us to isolate allocation. One challenge is that the
> >>    admin on the system may use them differently and applications need to
> >>    be aware of running in the right cpuset to allocate memory from the
> >>    CDM node.
> >
> > An admin and application has to deal with this complexity regardless.
> 
> I was thinking along the lines of cpusets working orthogonal to CDM
> and not managing CDM memory, that way the concerns are different.
> A policy set on cpusets does not impact CDM memory. It also means
> that CDM memory is not used for total memory computation and related
> statistics.
> 

So far, the desire to avoid CDM being used in total memory consumption
appears to be the only core kernel thing that may need support. Whether it's
worth creating a pgdat->flag to special case that or not is debatable as
the worst impact is slightly confusing sysrq+m, oom-kill and free/top/etc
messages. That might be annoying but not a functional blocker.

> > Particular care would be needed for file-backed data as an application
> > would have to ensure the data was not already cache resident. For
> > example, creating a data file and then doing computation on it may be
> > problematic. Unconditionally, the application is going to have to deal
> > with migration.
> >
> 
> Ins't migration transparent to the application, it may affect performance.
> 

I'm not sure what you're asking here. migration is only partially
transparent but a move_pages call will be necessary to force pages onto
CDM if binding policies are not used so the cost of migration will be
invisible. Even if you made it "transparent", the migration cost would
be incurred at fault time. If anything, using move_pages would be more
predictable as you control when the cost is incurred.

> > Identifying issues like this are why an end-to-end application that
> > takes advantage of the feature is important. Otherwise, there is a risk
> > that APIs are exposed to userspace that are Linux-specific,
> > device-specific and unusable.
> >
> >>    Putting all applications in the cpuset with the CDM node is
> >>    not the right thing to do, which means the application needs to move itself
> >>    to the right cpuset before requesting for CDM memory. It's not impossible
> >>    to use CPUsets, just hard to configure correctly.
> >
> > They optionally could also use move_pages.
> 
> move_pages() to move the memory to the right node after the allocation?
> 

More specifically, move_pages before the offloaded computation begins
and optionally move it back to main memory after the computation
completes.

> >
> >>   - With HMM, we would need a HMM variant HMM-CDM, so that we are not marking
> >>    the pages as unavailable, page cache cannot do directly to coherent memory.
> >>    Audit of mm paths is required. Most of the other things should work.
> >>    User access to HMM-CDM memory behind ZONE_DEVICE is via a device driver.
> >
> > The main reason why I would prefer HMM-CDM is two-fold. The first is
> > that using these accelerators still has use cases that are not very well
> > defined but if an application could use either CDM or HMM transparently
> > then it may be better overall.
> >
> > The second reason is because there are technologies like near-memory coming
> > in the future and there is no infrastructure in place to take advantage like
> > that. I haven't even heard of plans from developers working with vendors of
> > such devices on how they intend to support it. Hence, the desired policies
> > are unknown such as whether the near memory should be isolated or if there
> > should be policies that promote/demote data between NUMA nodes instead of
> > reclaim. While I'm not involved in enabling such technology, I worry that
> > there will be collisiosn in the policies required for CDM and those required
> > for near-memory but once the API is exposed to userspace, it becomes fixed.
> >
> 
> OK, I see your concern, it is definitely valid. We do have a use case,
> but I wonder
> how long we wait?
> 

As before, from a core kernel perspective, all the use cases described
so far can be handled with existing mechanisms *if* the driver controls
the hotplug of memory at a time chosen by userspace so it can control the
isolation, allocation and usage. Of coursse, the driver still needs to
exist and will have some additional complexity that other drivers do not
need but for the pure NUMA-approach to CDM, it can be handled entirely
within a driver and then controlled from userspace without requiring
additional wiring into the core vm.

The same is not quite as true for near-memory (although it could be forced
to be that way initially albeit sub-optimally due to page age inversion
problems unless extreme care was taken).

> >> Do we need to isolate node attributes independent of coherent device memory?
> >>  - Christoph Lameter thought it would be useful to isolate node attributes,
> >>    specifically ksm/autonuma for low latency suff.
> >
> > Whatever about KSM, I would have suggested that autonuma have a prctl
> > flag to disable autonuma on a per-task basis. It would be sufficient for
> > anonymous memory at least. It would have some hazards if a
> > latency-sensitive application shared file-backed data with a normal
> > application but latency-sensitive applications generally have to take
> > care to isolate themselves properly.
> >
> 
> OK, I was planning on doing an isolated feature set. But I am still trying
> to think what it would mean in terms of complexity to the mm. Not having
> all of N_MEMORY participating in a particular feature/algorithm is something
> most admins will not want to enable.
> 

prctl disabling on a per-task basis is fairly straight-forward.
Alternatively, always assign policies to VMAs being used for CDM and it'll
be left alone.

> > Primarily, I would suggest that HMM-CDM be taken as far as possible on the
> > hope/expectation that an application could transparently use either CDM
> > (memory visible to both CPU and device) or HMM (special care required)
> > with a common library API. This may be unworkable ultimately but it's
> > impossible to know unless someone is fully up to date with exactly how
> > these devices are to be used by appliications.
> >
> > If NUMA nodes are still required then the initial path appears to
> > be controlling the onlining of memory from the device, isolating from
> > userspace with existing mechanisms and using library awareness to control
> > the migration. If DMA offloading is required then the device would also
> > need to control that which may or may not push it towards HMM again.
> >
> 
> Agreeed, but I think both NUMA and DMA offloading are possible together.
> The user space uses NUMA API's and the driver can use DMA offloading
> for migration of pages depending on any heuristics or user provided
> hints that a page may be soon needed on the device. Some application
> details depend on whether the memory is fully driver managed (HMM-CDM)
> or NUMA. We've been seriously looking at HMM-CDM as an alternative
> to NUMA. We'll push in that direction and see beyond our audting what
> else we run into.
> 

It's possible you'll end up with a hybrid of NUMA and HMM but right now,
it appears the NUMA part can be handled by existing mechanisms if the
driver is handling the hot-add of memory and triggered from userspace.
That actual hot-add might be a little tricky as it has to handle watermark
setting and keep the node out of default zonelists. That might require a
check in the core VM for a pgdat->flag but it would be one branch in the
zonelist building and optionally a check in the watermark configuration
which is fairly minimal.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
