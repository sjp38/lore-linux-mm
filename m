Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id E645C6B0038
	for <linux-mm@kvack.org>; Thu, 23 Feb 2017 01:53:50 -0500 (EST)
Received: by mail-qk0-f198.google.com with SMTP id q4so24198989qkh.4
        for <linux-mm@kvack.org>; Wed, 22 Feb 2017 22:53:50 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id a22si3891222itb.97.2017.02.22.22.53.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Feb 2017 22:53:50 -0800 (PST)
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v1N6riG2166192
	for <linux-mm@kvack.org>; Thu, 23 Feb 2017 01:53:49 -0500
Received: from e23smtp02.au.ibm.com (e23smtp02.au.ibm.com [202.81.31.144])
	by mx0b-001b2d01.pphosted.com with ESMTP id 28sdf5xqfc-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 23 Feb 2017 01:53:49 -0500
Received: from localhost
	by e23smtp02.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Thu, 23 Feb 2017 16:53:44 +1000
Received: from d23relay06.au.ibm.com (d23relay06.au.ibm.com [9.185.63.219])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 3787F2BB0057
	for <linux-mm@kvack.org>; Thu, 23 Feb 2017 17:53:42 +1100 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay06.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v1N6rYrU42598632
	for <linux-mm@kvack.org>; Thu, 23 Feb 2017 17:53:42 +1100
Received: from d23av04.au.ibm.com (localhost [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v1N6r9AB029142
	for <linux-mm@kvack.org>; Thu, 23 Feb 2017 17:53:10 +1100
Subject: Re: [PATCH V3 0/4] Define coherent device memory node
References: <20170215120726.9011-1-khandual@linux.vnet.ibm.com>
 <20170215182010.reoahjuei5eaxr5s@suse.de>
 <dfd5fd02-aa93-8a7b-b01f-52570f4c87ac@linux.vnet.ibm.com>
 <20170221111107.GJ15595@dhcp22.suse.cz>
 <890fb824-d1f0-3711-4fe6-d6ddf29a0d80@linux.vnet.ibm.com>
 <20170222095043.GG5753@dhcp22.suse.cz>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Thu, 23 Feb 2017 12:22:40 +0530
MIME-Version: 1.0
In-Reply-To: <20170222095043.GG5753@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <a69556b2-7273-108b-3ec1-ccbce468cf1c@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: Mel Gorman <mgorman@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, vbabka@suse.cz, minchan@kernel.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, dave.hansen@intel.com, dan.j.williams@intel.com

On 02/22/2017 03:20 PM, Michal Hocko wrote:
> On Tue 21-02-17 19:09:18, Anshuman Khandual wrote:
>> On 02/21/2017 04:41 PM, Michal Hocko wrote:
>>> On Fri 17-02-17 17:11:57, Anshuman Khandual wrote:
>>> [...]
>>>> * User space using mbind() to get CDM memory is an additional benefit
>>>>   we get by making the CDM plug in as a node and be part of the buddy
>>>>   allocator. But the over all idea from the user space point of view
>>>>   is that the application can allocate any generic buffer and try to
>>>>   use the buffer either from the CPU side or from the device without
>>>>   knowing about where the buffer is really mapped physically. That
>>>>   gives a seamless and transparent view to the user space where CPU
>>>>   compute and possible device based compute can work together. This
>>>>   is not possible through a driver allocated buffer.
>>>
>>> But how are you going to define any policy around that. Who is allowed
>>
>> The user space VMA can define the policy with a mbind(MPOL_BIND) call
>> with CDM/CDMs in the nodemask.
>>
>>> to allocate and how much of this "special memory". Is it possible that
>>
>> Any user space application with mbind(MPOL_BIND) call with CDM/CDMs in
>> the nodemask can allocate from the CDM memory. "How much" gets controlled
>> by how we fault from CPU and the default behavior of the buddy allocator.
> 
> In other words the policy is implemented by the kernel. Why is this a
> good thing?

Its controlled by the kernel only during page fault paths of either CPU
or device. But the device driver will actually do the placements after
wards after taking into consideration access patterns and relative
performance. We dont want the driver to be involved during page fault
path memory allocations which should naturally go through the buddy
allocator.

> 
>>> we will eventually need some access control mechanism? If yes then mbind
>>
>> No access control mechanism is needed. If an application wants to use
>> CDM memory by specifying in the mbind() it can. Nothing prevents it
>> from using the CDM memory.
> 
> What if we find out that an access control _is_ really needed? I can
> easily imagine that some devices will come up with really fast and expensive
> memory. You do not want some random user to steal it from you when you
> want to use it for your workload.

Hmm, it makes sense but I think its not something we have to deal with
right away. Later we may have to think about some generic access control
mechanism for mbind() and then accommodate CDM with it.

> 
>>> is really not suitable interface to (ab)use. Also what should happen if
>>> the mbind mentions only CDM memory and that is depleted?
>>
>> IIUC *only CDM* cannot be requested from user space as there are no user
>> visible interface which can translate to __GFP_THISNODE.
> 
> I do not understand what __GFP_THISNODE has to do with this. This is an
> internal flag.

Right. My bad. I was just referring to the fact that there is nothing in
user space which can make buddy allocator pick NOFALLBACK list instead of
FALLBACK list.

> 
>> MPOL_BIND with
>> CDM in the nodemask will eventually pick a FALLBACK zonelist which will
>> have zones of the system including CDM ones. If the resultant CDM zones
>> run out of memory, we fail the allocation request as usual.
> 
> OK, so let's say you mbind to a single node which is CDM. You seem to be
> saying that we will simply break the NUMA affinity in this special case?

Why ? It should simply follow what happens when we pick a single NUMA node
in previous situations.

> Currently we invoke the OOM killer if nodes which the application binds
> to are depleted and cannot be reclaimed.

Right, the same should happen here for CDM as well.

>  
>>> Could you also explain why the transparent view is really better than
>>> using a device specific mmap (aka CDM awareness)?
>>
>> Okay with a transparent view, we can achieve a control flow of application
>> like the following.
>>
>> (1) Allocate a buffer:		alloc_buffer(buf, size)
>> (2) CPU compute on buffer:	cpu_compute(buf, size)
>> (3) Device compute on buffer:	device_compute(buf, size)
>> (4) CPU compute on buffer:	cpu_compute(buf, size)
>> (5) Release the buffer:		release_buffer(buf, size)
>>
>> With assistance from a device specific driver, the actual page mapping of
>> the buffer can change between system RAM and device memory depending on
>> which side is accessing at a given point. This will be achieved through
>> driver initiated migrations.
> 
> But then you do not need any NUMA affinity, right? The driver can do
> all this automagically. How does the numa policy comes into the game in
> your above example. Sorry for being dense, I might be really missing
> something important here, but I really fail to see why the NUMA is the
> proper interface here.

You are right. Driver can migrate any mapping in the userspace to any
where on the system as long as cpuset does not prohibit it. But we still
want the driver to conform to the applicable VMA memory policy set from
the userspace. Hence a VMA policy needs to be set from the user space.
NUMA VMA memory policy also restricts the allocations inside the
applicable nodemask during page fault paths (CPU and device) as well.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
