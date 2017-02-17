Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7152F681021
	for <linux-mm@kvack.org>; Fri, 17 Feb 2017 04:33:55 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id h7so7426186wjy.6
        for <linux-mm@kvack.org>; Fri, 17 Feb 2017 01:33:55 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n31si9961860wrb.302.2017.02.17.01.33.53
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 17 Feb 2017 01:33:54 -0800 (PST)
Date: Fri, 17 Feb 2017 09:33:51 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH V3 0/4] Define coherent device memory node
Message-ID: <20170217093159.3t5kw7rmixrzvv7c@suse.de>
References: <20170215120726.9011-1-khandual@linux.vnet.ibm.com>
 <20170215182010.reoahjuei5eaxr5s@suse.de>
 <8e86d37c-1826-736d-8cdd-ebd29c9ccd9c@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <8e86d37c-1826-736d-8cdd-ebd29c9ccd9c@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>
Cc: Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.com, vbabka@suse.cz, minchan@kernel.org, aneesh.kumar@linux.vnet.ibm.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, dave.hansen@intel.com, dan.j.williams@intel.com

On Fri, Feb 17, 2017 at 09:14:44AM +1100, Balbir Singh wrote:
> 
> 
> On 16/02/17 05:20, Mel Gorman wrote:
> > On Wed, Feb 15, 2017 at 05:37:22PM +0530, Anshuman Khandual wrote:
> >> 	This four patches define CDM node with HugeTLB & Buddy allocation
> >> isolation. Please refer to the last RFC posting mentioned here for more
> > 
> > Always include the background with the changelog itself. Do not assume that
> > people are willing to trawl through a load of past postings to assemble
> > the picture. I'm only taking a brief look because of the page allocator
> > impact but it does not appear that previous feedback was addressed.
> > 
> > In itself, the series does very little and as Vlastimil already pointed
> > out, it's not a good idea to try merge piecemeal when people could not
> > agree on the big picture (I didn't dig into it).
> > 
> 
> The idea of CDM is independent of how some of the other problems related
> to AutoNUMA balancing is handled.

What has Automatic NUMA balancing got to do with CDM?

Even if you're trying to draw a comparison between how the patches were
developed in comparison to CDM, it's a poor example. Regardless of which
generation of NUMA balancing implementation considered (there were three
contenders), each of them was a working implementation that had a measurable
impact on a number of workloads. In many cases, performance data was
included. The instructions on how workloads could use it were clear even
if there were disagreements on exactly what the tuning options should be.
While the feature evolved over time and improved for different classes of
workload, the first set of patches merged were functional.

> The idea of this patchset was to introduce
> the concept of memory that is not necessarily system memory, but is coherent
> in terms of visibility/access with some restrictions
> 

Which should be done without special casing the page allocator, cpusets and
special casing how cpusets are handled. It's not necessary for any other
mechanism used to restrict access to portions of memory such as cpusets,
mempolicies or even memblock reservations.

> > The only reason I'm commenting at all is to say that I am extremely opposed
> > to the changes made to the page allocator paths that are specific to
> > CDM. It's been continual significant effort to keep the cost there down
> > and this is a mess of special cases for CDM. The changes to hugetlb to
> > identify "memory that is not really memory" with special casing is also
> > quite horrible.
> > 
> > It's completely unclear that even if one was to assume that CDM memory
> > should be expressed as nodes why such systems do not isolate all processes
> > from CDM nodes by default and then allow access via memory policies or
> > cpusets instead of special casing the page allocator fast path. It's also
> > completely unclear what happens if a device should then access the CDM
> > and how that should be synchronised with the core, if that is even possible.
> > 
> 
> A big part of this is driven by the need to special case what allocations
> go there. The idea being that an allocation should get there only when
> explicitly requested.

cpuset, mempolicy or mmap of a device file that mediates whether device
or system memory is used. For the last option, I don't know the specifics
but given that HMM worked on this for years, there should be ables of
the considerations and complications that arise. I'm not familiar with
the specifics.

> Unfortunately, IIUC node distance is not a good
> isolation metric.

I don't recall suggesting that.

> CPUsets are heavily driven by user space and we
> believe that setting up CDM is not an administrative operation, its
> going to be hard for an administrator or user space application to set
> up the right policy or an installer to figure it out.

So by this design, an application is expected to know nothing about how
to access CDM yet be CDM-aware? The application is either aware of CDM or
it isn't. It's either known how to access it or it does not.

Even if it was a case that the arch layer provides hooks to alter the global
nodemask and expose a special file of the CDM nodemask to userspace then
it would still avoid special casing in the various allocators. It would
not address the problem at all of how devices are meant to be informed
that there is CDM memory with work to do but that has been raised elsewhere.

> It does not help
> that CPUSets assume inheritance from the root hierarchy. As far as the
> overheads go, one could consider using STATIC_KEYS if that is worthwhile.
> 

Hiding the overhead in static keys could not change the fact that the various
allocator paths should not need to be CDM-aware or special casing CDM when
there already are existing mechanisms for avoiding regions of memory.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
