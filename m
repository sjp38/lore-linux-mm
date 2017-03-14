Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 72F416B038A
	for <linux-mm@kvack.org>; Tue, 14 Mar 2017 09:33:13 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id r141so73194483ita.6
        for <linux-mm@kvack.org>; Tue, 14 Mar 2017 06:33:13 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id 64si3834481ply.256.2017.03.14.06.33.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Mar 2017 06:33:12 -0700 (PDT)
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v2EDJm43057216
	for <linux-mm@kvack.org>; Tue, 14 Mar 2017 09:33:12 -0400
Received: from e28smtp03.in.ibm.com (e28smtp03.in.ibm.com [125.16.236.3])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2960h05y2b-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 14 Mar 2017 09:33:11 -0400
Received: from localhost
	by e28smtp03.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Tue, 14 Mar 2017 19:03:08 +0530
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay05.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v2EDX1st11927558
	for <linux-mm@kvack.org>; Tue, 14 Mar 2017 19:03:01 +0530
Received: from d28av04.in.ibm.com (localhost [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v2EDX4Ts026279
	for <linux-mm@kvack.org>; Tue, 14 Mar 2017 19:03:05 +0530
Subject: Re: [PATCH 1/2] mm: Change generic FALLBACK zonelist creation process
References: <1d67f38b-548f-26a2-23f5-240d6747f286@linux.vnet.ibm.com>
 <20170308092146.5264-1-khandual@linux.vnet.ibm.com>
 <0f787fb7-e299-9afb-8c87-4afdb937fdbb@nvidia.com>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Tue, 14 Mar 2017 19:03:04 +0530
MIME-Version: 1.0
In-Reply-To: <0f787fb7-e299-9afb-8c87-4afdb937fdbb@nvidia.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <13c1a501-0ab9-898c-f749-efecca787661@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Hubbard <jhubbard@nvidia.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: mhocko@suse.com, vbabka@suse.cz, mgorman@suse.de, minchan@kernel.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, dave.hansen@intel.com, dan.j.williams@intel.com, zi.yan@cs.rutgers.edu

On 03/08/2017 04:37 PM, John Hubbard wrote:
> On 03/08/2017 01:21 AM, Anshuman Khandual wrote:
>> Kernel allocation to CDM node has already been prevented by putting it's
>> entire memory in ZONE_MOVABLE. But the CDM nodes must also be isolated
>> from implicit allocations happening on the system.
>>
>> Any isolation seeking CDM node requires isolation from implicit memory
>> allocations from user space but at the same time there should also have
>> an explicit way to do the memory allocation.
>>
>> Platform node's both zonelists are fundamental to where the memory comes
>> from when there is an allocation request. In order to achieve these two
>> objectives as stated above, zonelists building process has to change as
>> both zonelists (i.e FALLBACK and NOFALLBACK) gives access to the node's
>> memory zones during any kind of memory allocation. The following changes
>> are implemented in this regard.
>>
>> * CDM node's zones are not part of any other node's FALLBACK zonelist
>> * CDM node's FALLBACK list contains it's own memory zones followed by
>>   all system RAM zones in regular order as before


> 
> There was a discussion, on an earlier version of this patchset, in which
> someone pointed out that a slight over-allocation on a device that has
> much more memory than the CPU has, could use up system memory. Your
> latest approach here does not address this.

Hmm, I dont remember this. Could you please be more specific and point
me to the discussion on this.

> 
> I'm thinking that, until oversubscription between NUMA nodes is more
> fully implemented in a way that can be properly controlled, you'd

I did not get you. What does over subscription mean in this context ?
FALLBACK zonelist on each node has memory from every node including
it's own. Hence the allocation request targeted towards any node is
symmetrical with respect to from where the memory will be allocated.

> probably better just not fallback to system memory. In other words, a
> CDM node really is *isolated* from other nodes--no automatic use in
> either direction.

That is debatable. With this proposed solution the CDM FALLBACK
zonelist contains system RAM zones as fallback option which will
be used in case CDM memory is depleted. IMHO, I think thats the
right thing to do as it still maintains the symmetry to some
extent.

> 
> Also, naming and purpose: maybe this is a "Limited NUMA Node", rather
> than a Coherent Device Memory node. Because: the real point of this
> thing is to limit the normal operation of NUMA, just enough to work with
> what I am *told* is memory-that-is-too-fragile-for-kernel-use (I remain
> soemwhat on the fence, there, even though you did talk me into it
> earlier, heh).

:) Naming can be debated later after we all agree on the proposal
in principle. We have already discussed about kernel memory on CDM
in detail.

> 
> On process: it would probably help if you gathered up previous
> discussion points and carefully, concisely addressed each one,
> somewhere, (maybe in a cover letter). Because otherwise, it's too easy
> for earlier, important problems to be forgotten. And reviewers don't
> want to have to repeat themselves, of course.

Will do.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
