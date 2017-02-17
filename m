Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id B91D5681034
	for <linux-mm@kvack.org>; Fri, 17 Feb 2017 06:42:13 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id q39so7893458wrb.3
        for <linux-mm@kvack.org>; Fri, 17 Feb 2017 03:42:13 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id 47si13041199wry.53.2017.02.17.03.42.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Feb 2017 03:42:12 -0800 (PST)
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v1HBcxqA022933
	for <linux-mm@kvack.org>; Fri, 17 Feb 2017 06:42:10 -0500
Received: from e28smtp03.in.ibm.com (e28smtp03.in.ibm.com [125.16.236.3])
	by mx0b-001b2d01.pphosted.com with ESMTP id 28ny4wkgww-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 17 Feb 2017 06:42:10 -0500
Received: from localhost
	by e28smtp03.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Fri, 17 Feb 2017 17:12:06 +0530
Received: from d28relay07.in.ibm.com (d28relay07.in.ibm.com [9.184.220.158])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id 196B1E005A
	for <linux-mm@kvack.org>; Fri, 17 Feb 2017 17:13:39 +0530 (IST)
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay07.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v1HBf3cU27525126
	for <linux-mm@kvack.org>; Fri, 17 Feb 2017 17:11:03 +0530
Received: from d28av01.in.ibm.com (localhost [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v1HBg34A024058
	for <linux-mm@kvack.org>; Fri, 17 Feb 2017 17:12:04 +0530
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Subject: Re: [PATCH V3 0/4] Define coherent device memory node
References: <20170215120726.9011-1-khandual@linux.vnet.ibm.com>
 <20170215182010.reoahjuei5eaxr5s@suse.de>
Date: Fri, 17 Feb 2017 17:11:57 +0530
MIME-Version: 1.0
In-Reply-To: <20170215182010.reoahjuei5eaxr5s@suse.de>
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: 7bit
Message-Id: <dfd5fd02-aa93-8a7b-b01f-52570f4c87ac@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>, Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.com, vbabka@suse.cz, minchan@kernel.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, dave.hansen@intel.com, dan.j.williams@intel.com

On 02/15/2017 11:50 PM, Mel Gorman wrote:
> On Wed, Feb 15, 2017 at 05:37:22PM +0530, Anshuman Khandual wrote:
>> 	This four patches define CDM node with HugeTLB & Buddy allocation
>> isolation. Please refer to the last RFC posting mentioned here for more
> 
> Always include the background with the changelog itself. Do not assume that
> people are willing to trawl through a load of past postings to assemble
> the picture. I'm only taking a brief look because of the page allocator
> impact but it does not appear that previous feedback was addressed.

Sure, I made a mistake. Will include the complete background from my
previous RFCs in the next version which will show the entire context
of this patch series. I have addressed the previous feedback regarding
cpuset enabled allocation leaks into CDM memory as pointed out by
Vlastimil Babka on the last version. Did I miss anything else inside
the Buddy allocator apart from that ?

> 
> In itself, the series does very little and as Vlastimil already pointed
> out, it's not a good idea to try merge piecemeal when people could not
> agree on the big picture (I didn't dig into it).

With the proposed kernel changes and a associated driver its complete to
drive a user space based CPU/Device hybrid compute interchangeably on a
mmap() allocated memory buffer transparently and effectively. I had also
mentioned these points on the last posting in response to a comment from
Vlastimil.

>From this response (https://lkml.org/lkml/2017/2/14/50).

* User space using mbind() to get CDM memory is an additional benefit
  we get by making the CDM plug in as a node and be part of the buddy
  allocator. But the over all idea from the user space point of view
  is that the application can allocate any generic buffer and try to
  use the buffer either from the CPU side or from the device without
  knowing about where the buffer is really mapped physically. That
  gives a seamless and transparent view to the user space where CPU
  compute and possible device based compute can work together. This
  is not possible through a driver allocated buffer.

* The placement of the memory on the buffer can happen on system memory
  when the CPU faults while accessing it. But a driver can manage the
  migration between system RAM and CDM memory once the buffer is being
  used from CPU and the device interchangeably. As you have mentioned
  driver will have more information about where which part of the buffer
  should be placed at any point of time and it can make it happen with
  migration. So both allocation and placement are decided by the driver
  during runtime. CDM provides the framework for this can kind device
  assisted compute and driver managed memory placements.

* If any application is not using CDM memory for along time placed on
  its buffer and another application is forced to fallback on system
  RAM when it really wanted is CDM, the driver can detect these kind
  of situations through memory access patterns on the device HW and
  take necessary migration decisions.

I hope this explains the rationale of the framework. In fact these
four patches give logically complete CPU/Device operating framework.
Other parts of the bigger picture are VMA management, KSM, Auto NUMA
etc which are improvements on top of this basic framework.

> 
> The only reason I'm commenting at all is to say that I am extremely opposed
> to the changes made to the page allocator paths that are specific to
> CDM. It's been continual significant effort to keep the cost there down
> and this is a mess of special cases for CDM. The changes to hugetlb to
> identify "memory that is not really memory" with special casing is also
> quite horrible.

We have already removed the O (n^2) search during zonelist iteration as
pointed out by Vlastimil and the current overhead is linear for the CDM
special case. We do similar checks for the cpuset function as well. Then
how is this horrible ? On HugeTLB, we isolate CDM based on a resultant
(MEMORY - CDM) node_states[] element which identifies system memory
instead of all of the accessible memory and keep the HugeTLB limited to
that nodemask. But if you feel there is any other better approach, we
can definitely try out.

> 
> It's completely unclear that even if one was to assume that CDM memory
> should be expressed as nodes why such systems do not isolate all processes
> from CDM nodes by default and then allow access via memory policies or
> cpusets instead of special casing the page allocator fast path. It's also
> completely unclear what happens if a device should then access the CDM
> and how that should be synchronised with the core, if that is even possible.

I think Balbir has already commented on the cpuset part. Device and CPU
can consistently work on the common allocated buffer and HW takes care of
the access coherency.

> 
> It's also unclear if this is even usable by an application in userspace
> at this point in time. If it is and the special casing is needed then the

Yeah with the current CDM approach its usable from user space as
explained before.

> regions should be isolated from early mem allocations in the arch layer
> that is CDM aware, initialised late, and then setup userspace to isolate
> all but privileged applications from the CDM nodes. Do not litter the core
> with is_cdm_whatever checks.

I guess your are referring to allocating the entire CDM memory node with
memblock_reserve() and then arch managing the memory when user space
wants to use it through some sort of mmap, vm_ops methods. That defeats
the whole purpose of integrating CDM memory with core VM. I am afraid it
will also make migration between CDM memory and system memory difficult
which is essential in making the whole hybrid compute operation
transparent from  the user space.

> 
> At best this is incomplete because it does not look as if it could be used
> by anything properly and the fast path alterations are horrible even if
> it could be used. As it is, it should not be merged in my opinion.

I have mentioned in detail above how this much of code change enables
us to use the CDM in a transparent way from the user space. Please do
let me know if it still does not make sense, will try again.

On the fast path changes issue, I can really understand your concern
from the performance point of view as its achieved over a long time.
It would be great if you can suggest on how to improve from here.

- Anshuman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
