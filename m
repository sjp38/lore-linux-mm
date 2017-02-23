Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id D86616B0038
	for <linux-mm@kvack.org>; Thu, 23 Feb 2017 03:53:40 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id j5so26346263pfb.3
        for <linux-mm@kvack.org>; Thu, 23 Feb 2017 00:53:40 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id l187si3747781pfl.162.2017.02.23.00.53.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Feb 2017 00:53:39 -0800 (PST)
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v1N8rXDb003557
	for <linux-mm@kvack.org>; Thu, 23 Feb 2017 03:53:39 -0500
Received: from e28smtp04.in.ibm.com (e28smtp04.in.ibm.com [125.16.236.4])
	by mx0a-001b2d01.pphosted.com with ESMTP id 28srg4gsgc-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 23 Feb 2017 03:53:38 -0500
Received: from localhost
	by e28smtp04.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Thu, 23 Feb 2017 14:23:04 +0530
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id E219D3940061
	for <linux-mm@kvack.org>; Thu, 23 Feb 2017 14:23:01 +0530 (IST)
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay03.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v1N8r1O111927692
	for <linux-mm@kvack.org>; Thu, 23 Feb 2017 14:23:01 +0530
Received: from d28av02.in.ibm.com (localhost [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v1N8r0WG029716
	for <linux-mm@kvack.org>; Thu, 23 Feb 2017 14:23:01 +0530
Subject: Re: [PATCH V3 0/4] Define coherent device memory node
References: <20170215120726.9011-1-khandual@linux.vnet.ibm.com>
 <20170215182010.reoahjuei5eaxr5s@suse.de>
 <dfd5fd02-aa93-8a7b-b01f-52570f4c87ac@linux.vnet.ibm.com>
 <20170217133237.v6rqpsoiolegbjye@suse.de>
 <697214d2-9e75-1b37-0922-68c413f96ef9@linux.vnet.ibm.com>
 <20170222092921.GF5753@dhcp22.suse.cz>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Thu, 23 Feb 2017 14:22:54 +0530
MIME-Version: 1.0
In-Reply-To: <20170222092921.GF5753@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <5b9159e3-8780-bc18-dac1-87c1235603db@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: Mel Gorman <mgorman@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, vbabka@suse.cz, minchan@kernel.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, dave.hansen@intel.com, dan.j.williams@intel.com

On 02/22/2017 02:59 PM, Michal Hocko wrote:
> On Tue 21-02-17 18:39:17, Anshuman Khandual wrote:
>> On 02/17/2017 07:02 PM, Mel Gorman wrote:
> [...]
>>> Why can this not be expressed with cpusets and memory policies
>>> controlled by a combination of administrative steps for a privileged
>>> application and an application that is CDM aware?
>>
>> Hmm, that can be done but having an in kernel infrastructure has the
>> following benefits.
>>
>> * Administrator does not have to listen to node add notifications
>>   and keep the isolation/allowed cpusets upto date all the time.
>>   This can be a significant overhead on the admin/userspace which
>>   have a number of separate device memory nodes.
> 
> But the application has to communicate with the device so why it cannot
> use a device specific allocation as well? I really fail to see why
> something this special should hide behind a generic API to spread all
> the special casing into the kernel instead.

Eventually both memory as well as compute parts in a hybrid
CPU/device scheme should be implemented through generic API.
The scheduler should be able to take inputs from user space
to schedule a device compute specific function on a device
compute thread for a single run. Scheduler should then have
calls backs registered from the device which can be called
to schedule the function for a device compute. But right now
we are not there yet. So we are walking half the way and
trying to do it only for memory now.

>  
>> * With cpuset solution, tasks which are part of CDM allowed cpuset
>>   can have all it's VMAs allocate from CDM memory which may not be
>>   something the user want. For example user may not want to have
>>   the text segments, libraries allocate from CDM. To achieve this
>>   the user will have to explicitly block allocation access from CDM
>>   through mbind(MPOL_BIND) memory policy setups. This negative setup
>>   is a big overhead. But with in kernel CDM framework, isolation is
>>   enabled by default. For CDM allocations the application just has
>>   to setup memory policy with CDM node in the allowed nodemask.
> 
> Which makes cpusets vs. mempolicies even bigger mess, doesn't it? So say

Hence I am trying to defend CDM framework in comparison to cpuset
+ mbind() solution from user space as suggested by Mel.

> that you have an application which wants to benefit from CDM and use
> mbind to have an access to this memory for particular buffer. Now you
> try to run this application in a cpuset which doesn't include this node
> and now what? Cpuset will override the application policy so the buffer
> will never reach the requested node. At least not without even more
> hacks to cpuset handling. I really do not like that!


Right, it will not reach the CDM. The cpuset based solution was to
have the applications which want CDM in a CDM including cpuset and
all other applications/tasks in a CDM excluded cpuset. CDM aware
application can then set their own memory policies which *may*
include CDM and it will be allowed as their cpuset contain the
nodes. But these two cpusets once containing all CDM and one without
these CDMs should be maintained all the time. No kernel cpuset
hacks will be required.

> 
> [...]
>> These are the reasons which prohibit the use of HMM for coherent
>> addressable device memory purpose.
>>
> [...]
>> (3) Application cannot directly allocate into device memory from user
>> space using existing memory related system calls like mmap() and mbind()
>> as the device memory hides away in ZONE_DEVICE.
> 
> Why cannot the application simply use mmap on the device file?

Yeah thats possible but then it does not go through core VM any more.

> 
>> Apart from that, CDM framework provides a different approach to device
>> memory representation which does not require special device memory kind
>> of handling and associated call backs as implemented by HMM. It provides
>> NUMA node based visibility to the user space which can be extended to
>> support new features.
> 
> What do you mean by new features and how users will use/request those
> features (aka what is the API)?

I dont have plans for this right now. But what I meant was once core
VM understand CDM even its represented as NUMA node, the existing APIs
can be be modified to accommodate special functions for CDM memory.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
