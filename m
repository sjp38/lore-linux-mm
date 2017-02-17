Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6D694681034
	for <linux-mm@kvack.org>; Fri, 17 Feb 2017 08:32:42 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id jz4so8387403wjb.5
        for <linux-mm@kvack.org>; Fri, 17 Feb 2017 05:32:42 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k7si1749927wmk.40.2017.02.17.05.32.40
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 17 Feb 2017 05:32:40 -0800 (PST)
Date: Fri, 17 Feb 2017 13:32:37 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH V3 0/4] Define coherent device memory node
Message-ID: <20170217133237.v6rqpsoiolegbjye@suse.de>
References: <20170215120726.9011-1-khandual@linux.vnet.ibm.com>
 <20170215182010.reoahjuei5eaxr5s@suse.de>
 <dfd5fd02-aa93-8a7b-b01f-52570f4c87ac@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <dfd5fd02-aa93-8a7b-b01f-52570f4c87ac@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.com, vbabka@suse.cz, minchan@kernel.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, dave.hansen@intel.com, dan.j.williams@intel.com

On Fri, Feb 17, 2017 at 05:11:57PM +0530, Anshuman Khandual wrote:
> On 02/15/2017 11:50 PM, Mel Gorman wrote:
> > On Wed, Feb 15, 2017 at 05:37:22PM +0530, Anshuman Khandual wrote:
> >> 	This four patches define CDM node with HugeTLB & Buddy allocation
> >> isolation. Please refer to the last RFC posting mentioned here for more
> > 
> > Always include the background with the changelog itself. Do not assume that
> > people are willing to trawl through a load of past postings to assemble
> > the picture. I'm only taking a brief look because of the page allocator
> > impact but it does not appear that previous feedback was addressed.
> 
> Sure, I made a mistake. Will include the complete background from my
> previous RFCs in the next version which will show the entire context
> of this patch series. I have addressed the previous feedback regarding
> cpuset enabled allocation leaks into CDM memory as pointed out by
> Vlastimil Babka on the last version. Did I miss anything else inside
> the Buddy allocator apart from that ?
> 

The cpuset fix is crude and uncondtionally passes around a mask to
special case CDM requirements which should be controlled by cpusets or
policies if CDM is to be treated as if it's normal memory. Special
casing like this is fragile and it'll be difficult for modifications to
the allocator to be made with any degree of certainity that CDM is not
impacted. I strongly suspect it would collide with the cpuset rework
that Vlastimil is working on to avoid races between allocation and
cpuset modification.

> > 
> > In itself, the series does very little and as Vlastimil already pointed
> > out, it's not a good idea to try merge piecemeal when people could not
> > agree on the big picture (I didn't dig into it).
> 
> With the proposed kernel changes and a associated driver its complete to
> drive a user space based CPU/Device hybrid compute interchangeably on a
> mmap() allocated memory buffer transparently and effectively.

How is the device informed at that data is available for processing?
What prevents and application modifying the data on the device while it's
being processed?
Why can this not be expressed with cpusets and memory policies
controlled by a combination of administrative steps for a privileged
application and an application that is CDM aware?

> I had also
> mentioned these points on the last posting in response to a comment from
> Vlastimil.
> 
> From this response (https://lkml.org/lkml/2017/2/14/50).
> 
> * User space using mbind() to get CDM memory is an additional benefit
>   we get by making the CDM plug in as a node and be part of the buddy
>   allocator. But the over all idea from the user space point of view
>   is that the application can allocate any generic buffer and try to
>   use the buffer either from the CPU side or from the device without
>   knowing about where the buffer is really mapped physically. That
>   gives a seamless and transparent view to the user space where CPU
>   compute and possible device based compute can work together. This
>   is not possible through a driver allocated buffer.
> 

Which can also be done with cpusets that prevents use of CDM memory and
place all non-CDM processes into that cpuset with a separate cpuset for
CDM-aware applications that allow access to CDM memory.

> * The placement of the memory on the buffer can happen on system memory
>   when the CPU faults while accessing it. But a driver can manage the
>   migration between system RAM and CDM memory once the buffer is being
>   used from CPU and the device interchangeably.

While I'm not familiar with the details because I'm not generally involved
in hardware enablement, why was HMM not suitable? I know HMM had it's own
problems with merging but as it also managed migrations between RAM and
device memory, how did it not meet your requirements? If there were parts
of HMM missing, why was that not finished?

I know HMM had a history of problems getting merged but part of that was a
chicken and egg problem where it was a lot of infrastructure to maintain
with no in-kernel users. If CDM is a potential user then CDM could be
built on top and ask for a merge of both the core infrastructure required
and the drivers at the same time.

It's not an easy path but the difficulties there do not justify special
casing CDM in the core allocator.


>   As you have mentioned
>   driver will have more information about where which part of the buffer
>   should be placed at any point of time and it can make it happen with
>   migration. So both allocation and placement are decided by the driver
>   during runtime. CDM provides the framework for this can kind device
>   assisted compute and driver managed memory placements.
> 

Which sounds like what HMM needed and the problems of co-ordinating whether
data within a VMA is located on system RAM or device memory and what that
means is not addressed by the series.

Even if HMM is unsuitable, it should be clearly explained why

> * If any application is not using CDM memory for along time placed on
>   its buffer and another application is forced to fallback on system
>   RAM when it really wanted is CDM, the driver can detect these kind
>   of situations through memory access patterns on the device HW and
>   take necessary migration decisions.
> 
> I hope this explains the rationale of the framework. In fact these
> four patches give logically complete CPU/Device operating framework.
> Other parts of the bigger picture are VMA management, KSM, Auto NUMA
> etc which are improvements on top of this basic framework.
> 

Automatic NUMA balancing is a particular oddity as that is about
CPU->RAM locality and not RAM->device considerations.

But all that aside, it still does not explain why it's necessary to
special case CDM in the allocator paths that can be controlled with
existing mechanisms.

> > 
> > The only reason I'm commenting at all is to say that I am extremely opposed
> > to the changes made to the page allocator paths that are specific to
> > CDM. It's been continual significant effort to keep the cost there down
> > and this is a mess of special cases for CDM. The changes to hugetlb to
> > identify "memory that is not really memory" with special casing is also
> > quite horrible.
> 
> We have already removed the O (n^2) search during zonelist iteration as
> pointed out by Vlastimil and the current overhead is linear for the CDM
> special case. We do similar checks for the cpuset function as well. Then
> how is this horrible ?

Because there are existing mechanisms for avoiding nodes that are not
device specific.

> On HugeTLB, we isolate CDM based on a resultant
> (MEMORY - CDM) node_states[] element which identifies system memory
> instead of all of the accessible memory and keep the HugeTLB limited to
> that nodemask. But if you feel there is any other better approach, we
> can definitely try out.
> 

cpusets with non-CDM application in a cpuset that does not include CDM
nodes.

> > It's also unclear if this is even usable by an application in userspace
> > at this point in time. If it is and the special casing is needed then the
> 
> Yeah with the current CDM approach its usable from user space as
> explained before.
> 

Minus the parts where the application notifies the driver to do some work
or mediate between what is accessing what memory and when.

> > regions should be isolated from early mem allocations in the arch layer
> > that is CDM aware, initialised late, and then setup userspace to isolate
> > all but privileged applications from the CDM nodes. Do not litter the core
> > with is_cdm_whatever checks.
> 
> I guess your are referring to allocating the entire CDM memory node with
> memblock_reserve() and then arch managing the memory when user space
> wants to use it through some sort of mmap, vm_ops methods. That defeats
> the whole purpose of integrating CDM memory with core VM. I am afraid it
> will also make migration between CDM memory and system memory difficult
> which is essential in making the whole hybrid compute operation
> transparent from  the user space.
> 

The memblock is to only avoid bootmem allocations from that area. It can
be managed in the arch layer to first pass in all the system ram,
teardown the bootmem allocator, setup the nodelists, set system
nodemask, init CDM, init the allocator for that, and then optionally add
it to the system CDM for userspace to do the isolation or provide.

For that matter, the driver could do the discovery and then fake a
memory hot-add.

It would be tough to do this but it would confine the logic to the arch
and driver that cares instead of special casing the allocators.

> > At best this is incomplete because it does not look as if it could be used
> > by anything properly and the fast path alterations are horrible even if
> > it could be used. As it is, it should not be merged in my opinion.
> 
> I have mentioned in detail above how this much of code change enables
> us to use the CDM in a transparent way from the user space. Please do
> let me know if it still does not make sense, will try again.
> 
> On the fast path changes issue, I can really understand your concern
> from the performance point of viewi

And a maintenance overhead because changing any part where CDM is special
cased will be impossible for many to test and verify.

> as its achieved over a long time.
> It would be great if you can suggest on how to improve from here.
> 

I do not have the bandwidth to get involved in how hardware enablement
for this feature should be done on power. The objection is that however
it is handled should not need to add special casing to the allocator
which already has mechanisms for limiting what memory is used.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
