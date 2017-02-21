Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 327B76B0038
	for <linux-mm@kvack.org>; Mon, 20 Feb 2017 21:58:09 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id b2so63195969pgc.6
        for <linux-mm@kvack.org>; Mon, 20 Feb 2017 18:58:09 -0800 (PST)
Received: from mail-pg0-x242.google.com (mail-pg0-x242.google.com. [2607:f8b0:400e:c05::242])
        by mx.google.com with ESMTPS id k63si9708179pge.150.2017.02.20.18.58.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 Feb 2017 18:58:08 -0800 (PST)
Received: by mail-pg0-x242.google.com with SMTP id 1so8432654pgz.2
        for <linux-mm@kvack.org>; Mon, 20 Feb 2017 18:58:08 -0800 (PST)
Message-ID: <1487645879.10535.11.camel@gmail.com>
Subject: Re: [PATCH V3 0/4] Define coherent device memory node
From: Balbir Singh <bsingharora@gmail.com>
Date: Tue, 21 Feb 2017 13:57:59 +1100
In-Reply-To: <20170217093159.3t5kw7rmixrzvv7c@suse.de>
References: <20170215120726.9011-1-khandual@linux.vnet.ibm.com>
	 <20170215182010.reoahjuei5eaxr5s@suse.de>
	 <8e86d37c-1826-736d-8cdd-ebd29c9ccd9c@gmail.com>
	 <20170217093159.3t5kw7rmixrzvv7c@suse.de>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.com, vbabka@suse.cz, minchan@kernel.org, aneesh.kumar@linux.vnet.ibm.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, dave.hansen@intel.com, dan.j.williams@intel.com

On Fri, 2017-02-17 at 09:33 +0000, Mel Gorman wrote:
> On Fri, Feb 17, 2017 at 09:14:44AM +1100, Balbir Singh wrote:
> >A 
> >A 
> > On 16/02/17 05:20, Mel Gorman wrote:
> > > On Wed, Feb 15, 2017 at 05:37:22PM +0530, Anshuman Khandual wrote:
> > > >A 	This four patches define CDM node with HugeTLB & Buddy allocation
> > > > isolation. Please refer to the last RFC posting mentioned here for more
> > >A 
> > > Always include the background with the changelog itself. Do not assume that
> > > people are willing to trawl through a load of past postings to assemble
> > > the picture. I'm only taking a brief look because of the page allocator
> > > impact but it does not appear that previous feedback was addressed.
> > >A 
> > > In itself, the series does very little and as Vlastimil already pointed
> > > out, it's not a good idea to try merge piecemeal when people could not
> > > agree on the big picture (I didn't dig into it).
> > >A 
> >A 
> > The idea of CDM is independent of how some of the other problems related
> > to AutoNUMA balancing is handled.
>A 
> What has Automatic NUMA balancing got to do with CDM?
>A 

The idea is to have a policy to determine (based on the RFC discussion) whether
CDM nodes should participate in NUMA balancing.

> Even if you're trying to draw a comparison between how the patches were
> developed in comparison to CDM, it's a poor example. Regardless of which
> generation of NUMA balancing implementation considered (there were three
> contenders), each of them was a working implementation that had a measurable
> impact on a number of workloads. In many cases, performance data was
> included. The instructions on how workloads could use it were clear even
> if there were disagreements on exactly what the tuning options should be.
> While the feature evolved over time and improved for different classes of
> workload, the first set of patches merged were functional.
>A 
> > The idea of this patchset was to introduce
> > the concept of memory that is not necessarily system memory, but is coherent
> > in terms of visibility/access with some restrictions
> >A 
>A 
> Which should be done without special casing the page allocator, cpusets and
> special casing how cpusets are handled. It's not necessary for any other
> mechanism used to restrict access to portions of memory such as cpusets,
> mempolicies or even memblock reservations.

Agreed, I mentioned a limitation that we see a cpusets. I do agree that
we should reuse any infrastructure we have, but cpusets are more static
in nature and inheritence compared to the requirements of CDM.

>A 
> > > The only reason I'm commenting at all is to say that I am extremely opposed
> > > to the changes made to the page allocator paths that are specific to
> > > CDM. It's been continual significant effort to keep the cost there down
> > > and this is a mess of special cases for CDM. The changes to hugetlb to
> > > identify "memory that is not really memory" with special casing is also
> > > quite horrible.
> > >A 
> > > It's completely unclear that even if one was to assume that CDM memory
> > > should be expressed as nodes why such systems do not isolate all processes
> > > from CDM nodes by default and then allow access via memory policies or
> > > cpusets instead of special casing the page allocator fast path. It's also
> > > completely unclear what happens if a device should then access the CDM
> > > and how that should be synchronised with the core, if that is even possible.
> > >A 
> >A 
> > A big part of this is driven by the need to special case what allocations
> > go there. The idea being that an allocation should get there only when
> > explicitly requested.
>A 
> cpuset, mempolicy or mmap of a device file that mediates whether device
> or system memory is used. For the last option, I don't know the specifics
> but given that HMM worked on this for years, there should be ables of
> the considerations and complications that arise. I'm not familiar with
> the specifics.
>A 
> > Unfortunately, IIUC node distance is not a good
> > isolation metric.
>A 
> I don't recall suggesting that.

True, I am just saying :)

>A 
> > CPUsets are heavily driven by user space and we
> > believe that setting up CDM is not an administrative operation, its
> > going to be hard for an administrator or user space application to set
> > up the right policy or an installer to figure it out.
>A 
> So by this design, an application is expected to know nothing about how
> to access CDM yet be CDM-aware?A 

A higher layer abstracts what/where the memory is. The memory is coherent
(CDM), but for performance it may be migrated. In some special casesA 
an aware application may request explicit allocation, in other cases an
unaware application may use it seemlessly and have its memory migrated.

The application is either aware of CDM or
> it isn't. It's either known how to access it or it does not.
>A 
> Even if it was a case that the arch layer provides hooks to alter the global
> nodemask and expose a special file of the CDM nodemask to userspace then
> it would still avoid special casing in the various allocators. It would
> not address the problem at all of how devices are meant to be informed
> that there is CDM memory with work to do but that has been raised elsewhere.
>A 
> > It does not help
> > that CPUSets assume inheritance from the root hierarchy. As far as the
> > overheads go, one could consider using STATIC_KEYS if that is worthwhile.
> >A 
>A 
> Hiding the overhead in static keys could not change the fact that the various
> allocator paths should not need to be CDM-aware or special casing CDM when
> there already are existing mechanisms for avoiding regions of memory.
>


We don't want to hide things, but make it 0-overhead for non-users. There
might be better ways of doing it. Thanks for the review!

Balbir Singh.A 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
