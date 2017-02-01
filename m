Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id B5F356B0033
	for <linux-mm@kvack.org>; Wed,  1 Feb 2017 02:31:42 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id 3so223090289pgj.6
        for <linux-mm@kvack.org>; Tue, 31 Jan 2017 23:31:42 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id e7si18357623pfa.53.2017.01.31.23.31.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 31 Jan 2017 23:31:41 -0800 (PST)
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v117SmeT143792
	for <linux-mm@kvack.org>; Wed, 1 Feb 2017 02:31:40 -0500
Received: from e28smtp02.in.ibm.com (e28smtp02.in.ibm.com [125.16.236.2])
	by mx0a-001b2d01.pphosted.com with ESMTP id 28aws0kcmc-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 01 Feb 2017 02:31:39 -0500
Received: from localhost
	by e28smtp02.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Wed, 1 Feb 2017 13:01:36 +0530
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id 801FC394006A
	for <linux-mm@kvack.org>; Wed,  1 Feb 2017 13:01:33 +0530 (IST)
Received: from d28av07.in.ibm.com (d28av07.in.ibm.com [9.184.220.146])
	by d28relay05.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v117VVmL25034998
	for <linux-mm@kvack.org>; Wed, 1 Feb 2017 13:01:31 +0530
Received: from d28av07.in.ibm.com (localhost [127.0.0.1])
	by d28av07.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v117VVng002395
	for <linux-mm@kvack.org>; Wed, 1 Feb 2017 13:01:32 +0530
Subject: Re: [RFC] cpuset: Enable changing of top_cpuset's mems_allowed
 nodemask
References: <20170130203003.dm2ydoi3e6cbbwcj@suse.de>
 <20170131142237.27097-1-khandual@linux.vnet.ibm.com>
 <20170131160029.ubt6fvw6oh2fgxpd@suse.de>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Wed, 1 Feb 2017 13:01:24 +0530
MIME-Version: 1.0
In-Reply-To: <20170131160029.ubt6fvw6oh2fgxpd@suse.de>
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: 7bit
Message-Id: <c6864b3c-1b7f-ded9-eea4-538262631813@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>, Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.com, vbabka@suse.cz, minchan@kernel.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, dave.hansen@intel.com, dan.j.williams@intel.com

On 01/31/2017 09:30 PM, Mel Gorman wrote:
> On Tue, Jan 31, 2017 at 07:52:37PM +0530, Anshuman Khandual wrote:
>> At present, top_cpuset.mems_allowed is same as node_states[N_MEMORY] and it
>> cannot be changed at the runtime. Maximum possible node_states[N_MEMORY]
>> also gets reflected in top_cpuset.effective_mems interface. It prevents some
>> one from removing or restricting memory placement which will be applicable
>> system wide on a given memory node through cpuset mechanism which might be
>> limiting. This solves the problem by enabling update_nodemask() function to
>> accept changes to top_cpuset.mems_allowed as well. Once changed, it also
>> updates the value of top_cpuset.effective_mems. Updates all it's task's
>> mems_allowed nodemask as well. It calls cpuset_inc() to make sure cpuset
>> is accounted for in the buddy allocator through cpusets_enabled() check.
>>
> 
> What's the point of allowing the root cpuset to be restricted?

After an extended period of run time on a system, currently if we have
to run HW diagnostics and dump (which are run out of band) for debug
purpose, we have to stop further allocations to the node. Hot plugging
the memory node out of the kernel will achieve this. But it can also
be made possible by just enabling top_cpuset.memory_migrate and then
restricting all the allocations by removing the node from top_cpuset.
mems_allowed nodemask. This will force all the existing allocations
out of the target node.

More importantly it also extends the cpuset memory restriction feature
to the logical completion without adding any regressions for the
existing use cases. Then why not do this ? Does it add any overhead ?

In the future this feature can also be used to isolate a memory node
from all possible general allocations and at the same time provide an
alternate method for explicit allocation into it (still working on this
part, though have a hack right now). The current RFC series proposes
one such possible use case through the top_cpuset.mems_allowed nodemask.
But in this case it is being restricted during boot as well as after
hotplug of a memory only NUMA node.

If you think currently this does not have a use case to stand on it's
own, then I will carry it along with this patch series as part of the
proposed cpuset based isolation solution (with explicit allocation
access to the isolated node) as described just above.

- Anshuman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
