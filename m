Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id DCA0E6B0389
	for <linux-mm@kvack.org>; Thu, 23 Feb 2017 10:57:38 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id s27so17928764wrb.5
        for <linux-mm@kvack.org>; Thu, 23 Feb 2017 07:57:38 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v30si6560420wra.229.2017.02.23.07.57.37
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 23 Feb 2017 07:57:37 -0800 (PST)
Date: Thu, 23 Feb 2017 15:57:33 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH V3 0/4] Define coherent device memory node
Message-ID: <20170223155733.2ip7webxvfx2zolc@suse.de>
References: <20170215120726.9011-1-khandual@linux.vnet.ibm.com>
 <20170215182010.reoahjuei5eaxr5s@suse.de>
 <dfd5fd02-aa93-8a7b-b01f-52570f4c87ac@linux.vnet.ibm.com>
 <20170217133237.v6rqpsoiolegbjye@suse.de>
 <697214d2-9e75-1b37-0922-68c413f96ef9@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <697214d2-9e75-1b37-0922-68c413f96ef9@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.com, vbabka@suse.cz, minchan@kernel.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, dave.hansen@intel.com, dan.j.williams@intel.com

On Tue, Feb 21, 2017 at 06:39:17PM +0530, Anshuman Khandual wrote:
> >>> In itself, the series does very little and as Vlastimil already pointed
> >>> out, it's not a good idea to try merge piecemeal when people could not
> >>> agree on the big picture (I didn't dig into it).
> >>
> >> With the proposed kernel changes and a associated driver its complete to
> >> drive a user space based CPU/Device hybrid compute interchangeably on a
> >> mmap() allocated memory buffer transparently and effectively.
> > 
> > How is the device informed at that data is available for processing?
> 
> It will through a call to the driver from user space which can take
> the required buffer address as an argument.
> 

Which goes back to tending towards what HMM intended but Jerome has covered
all relevant point there so I won't repeat any of them in this response. It
did sound that in part HMM was not used because it was missing some
small steps which could have been included instead of proposing something
different that did not meet their requirements but requires special casing.

> > What prevents and application modifying the data on the device while it's
> > being processed?
> 
> Nothing in software. The application should take care of that but access
> from both sides are coherent. It should wait for the device till it
> finishes the compute it had asked for earlier to prevent override and
> eventual corruption.
> 

Which adds the caveat that applications must be fully CDM aware so if
there are additional calls related to policies or administrative tasks
for cpusets then it follows the application can also be aware of them.

> > Why can this not be expressed with cpusets and memory policies
> > controlled by a combination of administrative steps for a privileged
> > application and an application that is CDM aware?
> 
> Hmm, that can be done but having an in kernel infrastructure has the
> following benefits.
> 
> * Administrator does not have to listen to node add notifications
>   and keep the isolation/allowed cpusets upto date all the time.
>   This can be a significant overhead on the admin/userspace which
>   have a number of separate device memory nodes.
> 

Could be handled with udev triggers potentially or if udev events are not
raised by the memory hot-add then it could still be polled.

> * With cpuset solution, tasks which are part of CDM allowed cpuset
>   can have all it's VMAs allocate from CDM memory which may not be
>   something the user want. For example user may not want to have
>   the text segments, libraries allocate from CDM. To achieve this
>   the user will have to explicitly block allocation access from CDM
>   through mbind(MPOL_BIND) memory policy setups. This negative setup
>   is a big overhead. But with in kernel CDM framework, isolation is
>   enabled by default. For CDM allocations the application just has
>   to setup memory policy with CDM node in the allowed nodemask.
> 

Then distinguish between task-wide policies that forbid CDM nodes and
per-VMA policies that allow the CDM nodes. Migration between system
memory and devices remains a separate problem but migration would also
not be covered by special casing the allocator.

> Even with cpuset solution, applications still need to know which nodes
> are CDM on the system at given point of time. So we will have to store
> it in a nodemask and export them on sysfs some how.
> 

Which in itself is not too bad and doesn't require special casing the
allocator.

> > 
> >> I had also
> >> mentioned these points on the last posting in response to a comment from
> >> Vlastimil.
> >>
> >> From this response (https://lkml.org/lkml/2017/2/14/50).
> >>
> >> * User space using mbind() to get CDM memory is an additional benefit
> >>   we get by making the CDM plug in as a node and be part of the buddy
> >>   allocator. But the over all idea from the user space point of view
> >>   is that the application can allocate any generic buffer and try to
> >>   use the buffer either from the CPU side or from the device without
> >>   knowing about where the buffer is really mapped physically. That
> >>   gives a seamless and transparent view to the user space where CPU
> >>   compute and possible device based compute can work together. This
> >>   is not possible through a driver allocated buffer.
> >>
> > 
> > Which can also be done with cpusets that prevents use of CDM memory and
> > place all non-CDM processes into that cpuset with a separate cpuset for
> > CDM-aware applications that allow access to CDM memory.
> 
> Right, but with additional overheads as explained above.
> 

The application must already be aware of the CDM nodes.

> >> * If any application is not using CDM memory for along time placed on
> >>   its buffer and another application is forced to fallback on system
> >>   RAM when it really wanted is CDM, the driver can detect these kind
> >>   of situations through memory access patterns on the device HW and
> >>   take necessary migration decisions.
> >>
> >> I hope this explains the rationale of the framework. In fact these
> >> four patches give logically complete CPU/Device operating framework.
> >> Other parts of the bigger picture are VMA management, KSM, Auto NUMA
> >> etc which are improvements on top of this basic framework.
> >>
> > 
> > Automatic NUMA balancing is a particular oddity as that is about
> > CPU->RAM locality and not RAM->device considerations.
> 
> Right. But when there are migrations happening between system RAM and
> device memory. Auto NUMA with its CPU fault information can migrate
> between system RAM nodes which might not be necessary and can lead to
> conflict or overhead. Hence Auto NUMA needs to be switched off at times
> for the VMAs of concern but its not addressed in the patch series. As
> mentioned before, it will be in the follow up work as improvements on
> this series.

Ensure the policy settings for CDM-backed VMAs do not set MPOL_F_MOF and
automatic NUMA balancing will skip them. It does not require special casing
of the allocator or specific CDM-awareness.

> > The memblock is to only avoid bootmem allocations from that area. It can
> > be managed in the arch layer to first pass in all the system ram,
> > teardown the bootmem allocator, setup the nodelists, set system
> > nodemask, init CDM, init the allocator for that, and then optionally add
> > it to the system CDM for userspace to do the isolation or provide.
> > 
> > For that matter, the driver could do the discovery and then fake a
> > memory hot-add.
> 
> Not sure I got this correctly. Could you please explain more.
> 

Discover the device, and online the memory later as memory hotplug generally
does. If the faked memory hot-add operation raised an event that udev
can detect then the administrative functions could also be triggered
in userspace.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
