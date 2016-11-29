Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 789AB6B0038
	for <linux-mm@kvack.org>; Tue, 29 Nov 2016 01:51:48 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id y71so408773989pgd.0
        for <linux-mm@kvack.org>; Mon, 28 Nov 2016 22:51:48 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id c73si58653846pfj.76.2016.11.28.22.51.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Nov 2016 22:51:47 -0800 (PST)
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uAT6nGqH004682
	for <linux-mm@kvack.org>; Tue, 29 Nov 2016 01:51:46 -0500
Received: from e23smtp02.au.ibm.com (e23smtp02.au.ibm.com [202.81.31.144])
	by mx0a-001b2d01.pphosted.com with ESMTP id 271367xgxr-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 29 Nov 2016 01:51:46 -0500
Received: from localhost
	by e23smtp02.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Tue, 29 Nov 2016 16:51:43 +1000
Received: from d23relay10.au.ibm.com (d23relay10.au.ibm.com [9.190.26.77])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 5B7562CE8071
	for <linux-mm@kvack.org>; Tue, 29 Nov 2016 17:51:37 +1100 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay10.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id uAT6pbOK6029696
	for <linux-mm@kvack.org>; Tue, 29 Nov 2016 17:51:37 +1100
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id uAT6pa4A001569
	for <linux-mm@kvack.org>; Tue, 29 Nov 2016 17:51:37 +1100
Subject: Re: [RFC 4/4] mm: Ignore cpuset enforcement when allocation flag has
 __GFP_THISNODE
References: <1479824388-30446-1-git-send-email-khandual@linux.vnet.ibm.com>
 <1479824388-30446-5-git-send-email-khandual@linux.vnet.ibm.com>
 <8216916c-c3f3-bad9-33cb-b0da2508f3d0@intel.com>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Tue, 29 Nov 2016 12:21:28 +0530
MIME-Version: 1.0
In-Reply-To: <8216916c-c3f3-bad9-33cb-b0da2508f3d0@intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <583D2570.6070109@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: mhocko@suse.com, vbabka@suse.cz, mgorman@suse.de, minchan@kernel.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com

On 11/29/2016 02:42 AM, Dave Hansen wrote:
> On 11/22/2016 06:19 AM, Anshuman Khandual wrote:
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -3715,7 +3715,7 @@ struct page *
>>  		.migratetype = gfpflags_to_migratetype(gfp_mask),
>>  	};
>>  
>> -	if (cpusets_enabled()) {
>> +	if (cpusets_enabled() && !(alloc_mask & __GFP_THISNODE)) {
>>  		alloc_mask |= __GFP_HARDWALL;
>>  		alloc_flags |= ALLOC_CPUSET;
>>  		if (!ac.nodemask)
> 
> This means now that any __GFP_THISNODE allocation can "escape" the
> cpuset.  That seems like a pretty major change to how cpusets works.  Do
> we know that *ALL* __GFP_THISNODE allocations are truly lacking in a
> cpuset context that can be enforced?

Right, I know its a very blunt change. With the cpuset based isolation
of coherent device node for the user space tasks leads to a side effect
that a driver or even kernel cannot allocate memory from the coherent
device node in the task's own context (ioctl() calls or similar). For
non task context allocation (work queues, interrupts, anything async
etc) this problem can be fixed by modifying kernel thread's task->mems
_allowed to include all nodes of the system including the coherent
device nodes. Though I have not figured out the details yet. Whats
your thoughts on this ? What we are looking for is a explicit and
definite way of allocating from the coherent device node inside the
kernel.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
