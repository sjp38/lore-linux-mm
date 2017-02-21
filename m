Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id BDC156B0387
	for <linux-mm@kvack.org>; Tue, 21 Feb 2017 15:14:41 -0500 (EST)
Received: by mail-qk0-f197.google.com with SMTP id v73so99867953qkv.7
        for <linux-mm@kvack.org>; Tue, 21 Feb 2017 12:14:41 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u19si13168157qki.234.2017.02.21.12.14.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Feb 2017 12:14:40 -0800 (PST)
Date: Tue, 21 Feb 2017 15:14:37 -0500
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH V3 0/4] Define coherent device memory node
Message-ID: <20170221201436.GA4573@redhat.com>
References: <20170215120726.9011-1-khandual@linux.vnet.ibm.com>
 <20170215182010.reoahjuei5eaxr5s@suse.de>
 <dfd5fd02-aa93-8a7b-b01f-52570f4c87ac@linux.vnet.ibm.com>
 <20170217133237.v6rqpsoiolegbjye@suse.de>
 <697214d2-9e75-1b37-0922-68c413f96ef9@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <697214d2-9e75-1b37-0922-68c413f96ef9@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: Mel Gorman <mgorman@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.com, vbabka@suse.cz, minchan@kernel.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, dave.hansen@intel.com, dan.j.williams@intel.com

On Tue, Feb 21, 2017 at 06:39:17PM +0530, Anshuman Khandual wrote:
> On 02/17/2017 07:02 PM, Mel Gorman wrote:
> > On Fri, Feb 17, 2017 at 05:11:57PM +0530, Anshuman Khandual wrote:
> >> On 02/15/2017 11:50 PM, Mel Gorman wrote:
> >>> On Wed, Feb 15, 2017 at 05:37:22PM +0530, Anshuman Khandual wrote:

[...]

> >> * The placement of the memory on the buffer can happen on system memory
> >>   when the CPU faults while accessing it. But a driver can manage the
> >>   migration between system RAM and CDM memory once the buffer is being
> >>   used from CPU and the device interchangeably.
> > 
> > While I'm not familiar with the details because I'm not generally involved
> > in hardware enablement, why was HMM not suitable? I know HMM had it's own
> > problems with merging but as it also managed migrations between RAM and
> > device memory, how did it not meet your requirements? If there were parts
> > of HMM missing, why was that not finished?
> 
> 
> These are the reasons which prohibit the use of HMM for coherent
> addressable device memory purpose.
> 
> (1) IIUC HMM currently supports only a subset of anon mapping in the
> user space. It does not support shared anon mapping or any sort of file
> mapping for that matter. We need support for all mapping in the user space
> for the CPU/device compute to be effective and transparent. As HMM depends
> on ZONE DEVICE for device memory representation, there are some unique
> challenges in making it work for file mapping (and page cache) during
> migrations between system RAM and device memory.

I need to debunk that. HMM does not support file back page (or share memory)
for a single reason: CPU can not access HMM memory. If the device memory is
accessible from CPU in cache coherent fashion then adding support for file
back page is easy. There is only an handfull of place in the filesystem that
assume page are on the lru and all that is needed is allowing file back page
to not be on the lru. Extra thing would be to forbid GUP but that is easy.


> 
> (2) ZONE_DEVICE has been modified to support un-addressable memory apart
> from addressable persistent memory which is not movable. It still would
> have to support coherent device memory which will be movable.

Again this isn't how it is implemented. I splitted the un-addressable part
from the move-able property. So you can implement addressable and moveable
memory using HMM modification to ZONE_DEVICE.

> 
> (3) Application cannot directly allocate into device memory from user
> space using existing memory related system calls like mmap() and mbind()
> as the device memory hides away in ZONE_DEVICE.

That's true but this is deliberate choice. From the begining my choice
have been guided by the principle that i do not want to add or modify
existing syscall because we do not have real world experience with this.

Once HMM is use with real world workload by people other than me or
NVidia and we get feedback on what people writting application leveraging
this would like to do. Then we might start thinking about mbind() or other
API to expose more policy control to application.

For time being all policy and migration decision are done by the driver
that collect hint and statistic from the userspace driver of the GPU.
So this is all device specific and it use existing driver mechanism.

> 
> Apart from that, CDM framework provides a different approach to device
> memory representation which does not require special device memory kind
> of handling and associated call backs as implemented by HMM. It provides
> NUMA node based visibility to the user space which can be extended to
> support new features.

True we diverge there. I am not convince that NUMA is the right direction.
NUMA was design for CPU and CDM or device memory is more at a sub-level
than NUMA. Each device is attach to a given CPU node itself part of the
NUMA hierarchy. So to me CDM is more about having a hierarchy of memory
at node level and thus should not be implemented in NUMA. Something new
is needed. Not only for device memory but for thing like stack memory
that won't use as last level cache as it has been done in existing Intel
CPU. I believe we will have deeper hierarchy of memory, from fast high
bandwidth stack memory (on top of CPU/GPU die) to the regular memory as
we know it and also device memory.
 

> > I know HMM had a history of problems getting merged but part of that was a
> > chicken and egg problem where it was a lot of infrastructure to maintain
> > with no in-kernel users. If CDM is a potential user then CDM could be
> 
> CDM is not a user there, HMM needs to change (with above challenges) to
> accommodate coherent device memory which it does not support at this
> moment.

There is no need to change anything with current HMM to support CDM. What
you would want is to add file back page which would require to allow non
lru page (this lru assumption of file back page exist only in couple place
and i don't remember thinking it would be a challenge to change that).


> > built on top and ask for a merge of both the core infrastructure required
> > and the drivers at the same time.
> 
> I am afraid the drivers would be HW vendor specific.
> 
> > 
> > It's not an easy path but the difficulties there do not justify special
> > casing CDM in the core allocator.
> 
> Hmm. Even if HMM supports all sorts of mappings in user space and related
> migrations, we still will not have direct allocations from user space with
> mmap() and mbind() system calls.

I am not sure we want to have this kind of direct allocation from day one.
I would rather have the whole thing fire tested with real application and
real user through device driver. Then wait to see if common usage pattern
warrant to create a generic API to direct new memory allocation to device
memory.

 
> >>   As you have mentioned
> >>   driver will have more information about where which part of the buffer
> >>   should be placed at any point of time and it can make it happen with
> >>   migration. So both allocation and placement are decided by the driver
> >>   during runtime. CDM provides the framework for this can kind device
> >>   assisted compute and driver managed memory placements.
> >>
> > 
> > Which sounds like what HMM needed and the problems of co-ordinating whether
> > data within a VMA is located on system RAM or device memory and what that
> > means is not addressed by the series.
> 
> Did not get that. What is not addressed by this series ? How is the
> requirements of HMM and CDM framework are different ?

The VMA flag of CDM is really really bad from my point of view. I do
understand and agree that you want to block auto-numa and ksm or any-
thing similar from happening to CDM memory but this is a property of
the memory that back some address in a given VMA. It is not a property
of a VMA region. Given that auto-numa and KSM work from VMA down to
memory i understand why one would want to block it there but it is
wrong.

I already said that a common pattern will be fragmented VMA ie a VMA
in which you have some address back by device memory and other back
by regular memory (and no you do not want to split VMA). So to me it
is clear you need to block KSM or auto-numa at page level ie by using
memory type property from node to which the page belong for instance.

Droping the CDM flag would simplify your whole patchset.

 
> > 
> > Even if HMM is unsuitable, it should be clearly explained why
> 
> I just did explain in the previous paragraphs above.
> 
> > 
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

I do not think auto-numa need to be switch of for the whole VMA but only
block it for device memory. Because auto-numa can't gather device memory
usage statistics.

[...]

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
