Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 05DA26B0038
	for <linux-mm@kvack.org>; Wed, 30 Nov 2016 06:17:25 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id a8so296896656pfg.0
        for <linux-mm@kvack.org>; Wed, 30 Nov 2016 03:17:24 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id o79si63954834pfa.97.2016.11.30.03.17.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Nov 2016 03:17:24 -0800 (PST)
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uAUBE2CK031717
	for <linux-mm@kvack.org>; Wed, 30 Nov 2016 06:17:23 -0500
Received: from e28smtp08.in.ibm.com (e28smtp08.in.ibm.com [125.16.236.8])
	by mx0a-001b2d01.pphosted.com with ESMTP id 271v38dvy5-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 30 Nov 2016 06:17:23 -0500
Received: from localhost
	by e28smtp08.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Wed, 30 Nov 2016 16:47:19 +0530
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id F28EC125805F
	for <linux-mm@kvack.org>; Wed, 30 Nov 2016 16:48:21 +0530 (IST)
Received: from d28av06.in.ibm.com (d28av06.in.ibm.com [9.184.220.48])
	by d28relay01.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id uAUBH8IJ27918420
	for <linux-mm@kvack.org>; Wed, 30 Nov 2016 16:47:08 +0530
Received: from d28av06.in.ibm.com (localhost [127.0.0.1])
	by d28av06.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id uAUBH7eD024321
	for <linux-mm@kvack.org>; Wed, 30 Nov 2016 16:47:07 +0530
Subject: Re: [RFC 4/4] mm: Ignore cpuset enforcement when allocation flag has
 __GFP_THISNODE
References: <1479824388-30446-1-git-send-email-khandual@linux.vnet.ibm.com>
 <1479824388-30446-5-git-send-email-khandual@linux.vnet.ibm.com>
 <8216916c-c3f3-bad9-33cb-b0da2508f3d0@intel.com>
 <583D2570.6070109@linux.vnet.ibm.com>
 <9a2e3fd7-1955-b347-2447-4b66402c1ce8@intel.com>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Wed, 30 Nov 2016 16:47:01 +0530
MIME-Version: 1.0
In-Reply-To: <9a2e3fd7-1955-b347-2447-4b66402c1ce8@intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <583EB52D.3080307@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: mhocko@suse.com, vbabka@suse.cz, mgorman@suse.de, minchan@kernel.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com

On 11/29/2016 10:22 PM, Dave Hansen wrote:
> On 11/28/2016 10:51 PM, Anshuman Khandual wrote:
>> On 11/29/2016 02:42 AM, Dave Hansen wrote:
>>>> On 11/22/2016 06:19 AM, Anshuman Khandual wrote:
>>>>>> --- a/mm/page_alloc.c
>>>>>> +++ b/mm/page_alloc.c
>>>>>> @@ -3715,7 +3715,7 @@ struct page *
>>>>>>  		.migratetype = gfpflags_to_migratetype(gfp_mask),
>>>>>>  	};
>>>>>>  
>>>>>> -	if (cpusets_enabled()) {
>>>>>> +	if (cpusets_enabled() && !(alloc_mask & __GFP_THISNODE)) {
>>>>>>  		alloc_mask |= __GFP_HARDWALL;
>>>>>>  		alloc_flags |= ALLOC_CPUSET;
>>>>>>  		if (!ac.nodemask)
>>>>
>>>> This means now that any __GFP_THISNODE allocation can "escape" the
>>>> cpuset.  That seems like a pretty major change to how cpusets works.  Do
>>>> we know that *ALL* __GFP_THISNODE allocations are truly lacking in a
>>>> cpuset context that can be enforced?
>> Right, I know its a very blunt change. With the cpuset based isolation
>> of coherent device node for the user space tasks leads to a side effect
>> that a driver or even kernel cannot allocate memory from the coherent
> ...
> 
> Well, we have __GFP_HARDWALL:
> 
> 	 * __GFP_HARDWALL enforces the cpuset memory allocation policy.
> 
> which you can clear in the places where you want to do an allocation but
> want to ignore cpusets.  But, __cpuset_node_allowed() looks like it gets
> a little funky if you do that since it would probably be falling back to
> the root cpuset that also would not have the new node in mems_allowed.

Right but what is the rationale behind this ? This what is in the in-code
documentation for this function __cpuset_node_allowed().

 *	GFP_KERNEL   - any node in enclosing hardwalled cpuset ok
 
If the allocation has requested GFP_KERNEL, should not it look for the
entire system for memory ? Does cpuset still has to be enforced ?

> 
> What exactly are the kernel-internal places that need to allocate from
> the coherent device node?  When would this be done out of the context of
> an application *asking* for memory in the new node?

The primary user right now is a driver who wants to move around mapped
pages of an application from system RAM to CDM nodes and back. If the
application has requested for it though an ioctl(), during migration
the destination pages will be allocated on the CDM *in* the task context.

The driver could also have scheduled migration chunks in the work queue
which can execute later on. IIUC those execution and corresponding
allocation into CDM node will be *out* of context of the task.

Ideally looking for both the scenarios to work which dont right now.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
