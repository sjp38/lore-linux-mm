Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1C34E6B0038
	for <linux-mm@kvack.org>; Thu, 23 Feb 2017 10:27:18 -0500 (EST)
Received: by mail-qk0-f197.google.com with SMTP id x71so37543976qkb.6
        for <linux-mm@kvack.org>; Thu, 23 Feb 2017 07:27:18 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a192si3536059qkc.54.2017.02.23.07.27.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Feb 2017 07:27:16 -0800 (PST)
Date: Thu, 23 Feb 2017 10:27:13 -0500
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH V3 0/4] Define coherent device memory node
Message-ID: <20170223152712.GA3165@redhat.com>
References: <20170215120726.9011-1-khandual@linux.vnet.ibm.com>
 <20170215182010.reoahjuei5eaxr5s@suse.de>
 <dfd5fd02-aa93-8a7b-b01f-52570f4c87ac@linux.vnet.ibm.com>
 <20170217133237.v6rqpsoiolegbjye@suse.de>
 <697214d2-9e75-1b37-0922-68c413f96ef9@linux.vnet.ibm.com>
 <20170221201436.GA4573@redhat.com>
 <0b73cfd2-d70c-ccd8-9bf0-7bd060b16ce9@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <0b73cfd2-d70c-ccd8-9bf0-7bd060b16ce9@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: Mel Gorman <mgorman@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.com, vbabka@suse.cz, minchan@kernel.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, dave.hansen@intel.com, dan.j.williams@intel.com

On Thu, Feb 23, 2017 at 01:44:06PM +0530, Anshuman Khandual wrote:
> On 02/22/2017 01:44 AM, Jerome Glisse wrote:
> > On Tue, Feb 21, 2017 at 06:39:17PM +0530, Anshuman Khandual wrote:
> >> On 02/17/2017 07:02 PM, Mel Gorman wrote:
> >>> On Fri, Feb 17, 2017 at 05:11:57PM +0530, Anshuman Khandual wrote:
> >>>> On 02/15/2017 11:50 PM, Mel Gorman wrote:
> >>>>> On Wed, Feb 15, 2017 at 05:37:22PM +0530, Anshuman Khandual wrote:
> > 
> > [...]
> > 
> >>>> * The placement of the memory on the buffer can happen on system memory
> >>>>   when the CPU faults while accessing it. But a driver can manage the
> >>>>   migration between system RAM and CDM memory once the buffer is being
> >>>>   used from CPU and the device interchangeably.
> >>>
> >>> While I'm not familiar with the details because I'm not generally involved
> >>> in hardware enablement, why was HMM not suitable? I know HMM had it's own
> >>> problems with merging but as it also managed migrations between RAM and
> >>> device memory, how did it not meet your requirements? If there were parts
> >>> of HMM missing, why was that not finished?
> >>
> >>
> >> These are the reasons which prohibit the use of HMM for coherent
> >> addressable device memory purpose.
> >>
> >> (1) IIUC HMM currently supports only a subset of anon mapping in the
> >> user space. It does not support shared anon mapping or any sort of file
> >> mapping for that matter. We need support for all mapping in the user space
> >> for the CPU/device compute to be effective and transparent. As HMM depends
> >> on ZONE DEVICE for device memory representation, there are some unique
> >> challenges in making it work for file mapping (and page cache) during
> >> migrations between system RAM and device memory.
> > 
> > I need to debunk that. HMM does not support file back page (or share memory)
> > for a single reason: CPU can not access HMM memory. If the device memory is
> > accessible from CPU in cache coherent fashion then adding support for file
> > back page is easy. There is only an handfull of place in the filesystem that
> 
> This needs to be done in all file systems possible which supports file
> mapping in the user space and page caches ?

No, last time i check only couple filesystem made assumption in couple of
place about page being on lru (fuse and xfs if my memory serves me right).

Remaining place is a single function in common fs code (again if my memory
is serving me properly).


> > assume page are on the lru and all that is needed is allowing file back page
> > to not be on the lru. Extra thing would be to forbid GUP but that is easy.
> 
> If its not on LRU how we are going to manage the reclaim and write back
> into the disk for the dirty pages ? In which order ? Then a brand new
> infrastructure needs to be created for that purpose ? Why GUP access
> needs to be blocked for these device pages ?

Writeback does not rely on lru last time i check, so write back is fine.
Reclaim is obviously ignoring the page, this can trigger issue i guess if
we have enough page in such memory that we reach threshold that constantly
force regular page to be reclaim.

To me the question is do we want regular reclaim ? I do not think so as
the current reclaim code can not gather statistics from each devices to
know what memory is being use by who. I see reclaim as a per device, per
node problem. Regular memory should be reclaim with existing mechanism
but device memory should be reclaim with new infrastructure that can work
with device driver to know what memory and when to reclaim it.

Existing reclaim have been fine tune for CPU workload over the years and
i would rather not disturb that for new workload we don't have much
experience with yet.

GUP blocking is to forbid anyone from pining a page inside device memory
so that device memory can always be reclaim. What i would really like is
to add a new API for thing like direct I/O that only need to pin memory
for short period of time versus driver abusing GUP to pin memory for
device purposes. That way thing like direct I/O could work while blocking
long live pin.

I want to block pin because many GPU have contiguous memory requirement for
their graphic side (compute side doesn't have this kind of restriction). So
that you do not want to fragment device memory with pinned pages.


> >> (2) ZONE_DEVICE has been modified to support un-addressable memory apart
> >> from addressable persistent memory which is not movable. It still would
> >> have to support coherent device memory which will be movable.
> > 
> > Again this isn't how it is implemented. I splitted the un-addressable part
> > from the move-able property. So you can implement addressable and moveable
> > memory using HMM modification to ZONE_DEVICE.
> 
> Need to check this again but yes its not a very big issue.
> 
> > 
> >>
> >> (3) Application cannot directly allocate into device memory from user
> >> space using existing memory related system calls like mmap() and mbind()
> >> as the device memory hides away in ZONE_DEVICE.
> > 
> > That's true but this is deliberate choice. From the begining my choice
> > have been guided by the principle that i do not want to add or modify
> > existing syscall because we do not have real world experience with this.
> 
> With the current proposal for CDM, memory system calls just work
> on CDM without requiring any changes.
> 
> > 
> > Once HMM is use with real world workload by people other than me or
> > NVidia and we get feedback on what people writting application leveraging
> > this would like to do. Then we might start thinking about mbind() or other
> > API to expose more policy control to application.
> 
> I am not really sure how much of effort would be required to make
> ZONE_DEVICE pages to be accessible from user space with existing
> memory system calls. NUMA representation just makes it work without
> any further changes. But I got your point.
> 
> > 
> > For time being all policy and migration decision are done by the driver
> > that collect hint and statistic from the userspace driver of the GPU.
> > So this is all device specific and it use existing driver mechanism.
> 
> CDM framework also has the exact same expectations from the driver. But
> it gives user space more control and visibility regarding whats happening
> with the memory buffer.

I understand you want generic API to expose to userspace to allow program
finer control on where memory is allocated and i want that too long term.
I just don't think we have enough experience with real workload to make
sure we are making the right decision. The fact that you use existing API
is good in my view as it means you are not adding thing we will regret
latter :) If CDM NUMA node is not working well we can just stop reporting
CDM NUMA node and thus i don't think your patchset is cornering us. So
i believe it is worth adding now and gather experience with it. We can
easily back off.

 
> >> Apart from that, CDM framework provides a different approach to device
> >> memory representation which does not require special device memory kind
> >> of handling and associated call backs as implemented by HMM. It provides
> >> NUMA node based visibility to the user space which can be extended to
> >> support new features.
> > 
> > True we diverge there. I am not convince that NUMA is the right direction.
> 
> Yeah true, we diverge here :)
> 
> > NUMA was design for CPU and CDM or device memory is more at a sub-level
> > than NUMA. Each device is attach to a given CPU node itself part of the
> > NUMA hierarchy. So to me CDM is more about having a hierarchy of memory
> > at node level and thus should not be implemented in NUMA. Something new
> 
> Currently NUMA does not support any memory hierarchy at node level.

Yes and this is what i would like to see, this is something we will need
with CPU with big chunk of on die fast memory and then the regular memory
and you can even add persistent memory to the mix as a bigger chunk but
slower kind of memory. I think this something we need to think about and
that it will be needed and not only for device memory.

I do not think that we should hold of CDM until we have that. From my point
of view beside the VMA flag, CDM is fine (thought i won't go into the CPU
set discussion as i am ignorant of that part). But i believe this NUMA
solution you have shouldn't be the end of it.


> > is needed. Not only for device memory but for thing like stack memory
> > that won't use as last level cache as it has been done in existing Intel
> > CPU. I believe we will have deeper hierarchy of memory, from fast high
> > bandwidth stack memory (on top of CPU/GPU die) to the regular memory as
> > we know it and also device memory.
> 
> I agree but in absence of the infrastructure NUMA seems to be a suitable
> fallback for now.

Yes agree.
  
> >>> I know HMM had a history of problems getting merged but part of that was a
> >>> chicken and egg problem where it was a lot of infrastructure to maintain
> >>> with no in-kernel users. If CDM is a potential user then CDM could be
> >>
> >> CDM is not a user there, HMM needs to change (with above challenges) to
> >> accommodate coherent device memory which it does not support at this
> >> moment.
> > 
> > There is no need to change anything with current HMM to support CDM. What
> > you would want is to add file back page which would require to allow non
> > lru page (this lru assumption of file back page exist only in couple place
> > and i don't remember thinking it would be a challenge to change that).
> 
> I am afraid this statement over simplifies the challenge in hand. May be
> we need to start looking into actual details to figure out how much of
> changes are really required for this enablement.

Like i said from memory, writeback is fine as it doesn't deal with lru, the
only place that does is read ahead and generic read helper that populate
the page cache. This can be prototyped without device memory just using
regular memory and pretend it is device memory. I can take a look into that,
maybe before mm summit.

 
> >> I am afraid the drivers would be HW vendor specific.
> >>
> >>>
> >>> It's not an easy path but the difficulties there do not justify special
> >>> casing CDM in the core allocator.
> >>
> >> Hmm. Even if HMM supports all sorts of mappings in user space and related
> >> migrations, we still will not have direct allocations from user space with
> >> mmap() and mbind() system calls.
> > 
> > I am not sure we want to have this kind of direct allocation from day one.
> > I would rather have the whole thing fire tested with real application and
> > real user through device driver. Then wait to see if common usage pattern
> > warrant to create a generic API to direct new memory allocation to device
> > memory.
> 
> But we should not also over look this aspect and go in a direction
> where it can be difficult to implement at later point in time. I am
> not saying its going to be difficult but its something we have to
> find out.

Yes agree.


Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
