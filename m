Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id A860B681010
	for <linux-mm@kvack.org>; Thu, 16 Feb 2017 17:15:26 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id y6so27007077pgy.5
        for <linux-mm@kvack.org>; Thu, 16 Feb 2017 14:15:26 -0800 (PST)
Received: from mail-pf0-x241.google.com (mail-pf0-x241.google.com. [2607:f8b0:400e:c00::241])
        by mx.google.com with ESMTPS id l26si8212571pfg.54.2017.02.16.14.15.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Feb 2017 14:15:25 -0800 (PST)
Received: by mail-pf0-x241.google.com with SMTP id e4so2487143pfg.0
        for <linux-mm@kvack.org>; Thu, 16 Feb 2017 14:15:25 -0800 (PST)
Subject: Re: [PATCH V3 0/4] Define coherent device memory node
References: <20170215120726.9011-1-khandual@linux.vnet.ibm.com>
 <20170215182010.reoahjuei5eaxr5s@suse.de>
From: Balbir Singh <bsingharora@gmail.com>
Message-ID: <8e86d37c-1826-736d-8cdd-ebd29c9ccd9c@gmail.com>
Date: Fri, 17 Feb 2017 09:14:44 +1100
MIME-Version: 1.0
In-Reply-To: <20170215182010.reoahjuei5eaxr5s@suse.de>
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>, Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.com, vbabka@suse.cz, minchan@kernel.org, aneesh.kumar@linux.vnet.ibm.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, dave.hansen@intel.com, dan.j.williams@intel.com



On 16/02/17 05:20, Mel Gorman wrote:
> On Wed, Feb 15, 2017 at 05:37:22PM +0530, Anshuman Khandual wrote:
>> 	This four patches define CDM node with HugeTLB & Buddy allocation
>> isolation. Please refer to the last RFC posting mentioned here for more
> 
> Always include the background with the changelog itself. Do not assume that
> people are willing to trawl through a load of past postings to assemble
> the picture. I'm only taking a brief look because of the page allocator
> impact but it does not appear that previous feedback was addressed.
> 
> In itself, the series does very little and as Vlastimil already pointed
> out, it's not a good idea to try merge piecemeal when people could not
> agree on the big picture (I didn't dig into it).
> 

The idea of CDM is independent of how some of the other problems related
to AutoNUMA balancing is handled. The idea of this patchset was to introduce
the concept of memory that is not necessarily system memory, but is coherent
in terms of visibility/access with some restrictions

> The only reason I'm commenting at all is to say that I am extremely opposed
> to the changes made to the page allocator paths that are specific to
> CDM. It's been continual significant effort to keep the cost there down
> and this is a mess of special cases for CDM. The changes to hugetlb to
> identify "memory that is not really memory" with special casing is also
> quite horrible.
> 
> It's completely unclear that even if one was to assume that CDM memory
> should be expressed as nodes why such systems do not isolate all processes
> from CDM nodes by default and then allow access via memory policies or
> cpusets instead of special casing the page allocator fast path. It's also
> completely unclear what happens if a device should then access the CDM
> and how that should be synchronised with the core, if that is even possible.
> 

A big part of this is driven by the need to special case what allocations
go there. The idea being that an allocation should get there only when
explicitly requested. Unfortunately, IIUC node distance is not a good
isolation metric. CPUsets are heavily driven by user space and we
believe that setting up CDM is not an administrative operation, its
going to be hard for an administrator or user space application to set
up the right policy or an installer to figure it out. It does not help
that CPUSets assume inheritance from the root hierarchy. As far as the
overheads go, one could consider using STATIC_KEYS if that is worthwhile.


> It's also unclear if this is even usable by an application in userspace
> at this point in time. If it is and the special casing is needed then the
> regions should be isolated from early mem allocations in the arch layer
> that is CDM aware, initialised late, and then setup userspace to isolate
> all but privileged applications from the CDM nodes. Do not litter the core
> with is_cdm_whatever checks.
> 

The idea is to have these nodes as ZONE_MOVABLE and those are isolated from
early mem allocations. Any new feature requires checks, but one could consider
consolidating those checks

Balbir Singh.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
