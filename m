Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f198.google.com (mail-ot0-f198.google.com [74.125.82.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5505B6B0038
	for <linux-mm@kvack.org>; Mon, 30 Jan 2017 20:36:39 -0500 (EST)
Received: by mail-ot0-f198.google.com with SMTP id j49so305131078otb.7
        for <linux-mm@kvack.org>; Mon, 30 Jan 2017 17:36:39 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id k33si14361387pld.14.2017.01.30.17.36.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Jan 2017 17:36:38 -0800 (PST)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v0V1Y18Z092212
	for <linux-mm@kvack.org>; Mon, 30 Jan 2017 20:36:38 -0500
Received: from e28smtp06.in.ibm.com (e28smtp06.in.ibm.com [125.16.236.6])
	by mx0a-001b2d01.pphosted.com with ESMTP id 28a6qp9bt0-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 30 Jan 2017 20:36:37 -0500
Received: from localhost
	by e28smtp06.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Tue, 31 Jan 2017 07:06:34 +0530
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id 05B72394004E
	for <linux-mm@kvack.org>; Tue, 31 Jan 2017 07:06:32 +0530 (IST)
Received: from d28av07.in.ibm.com (d28av07.in.ibm.com [9.184.220.146])
	by d28relay05.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v0V1aUGt26214552
	for <linux-mm@kvack.org>; Tue, 31 Jan 2017 07:06:30 +0530
Received: from d28av07.in.ibm.com (localhost [127.0.0.1])
	by d28av07.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v0V1aUPe016681
	for <linux-mm@kvack.org>; Tue, 31 Jan 2017 07:06:31 +0530
Subject: Re: [RFC V2 03/12] mm: Change generic FALLBACK zonelist creation
 process
References: <20170130033602.12275-1-khandual@linux.vnet.ibm.com>
 <20170130033602.12275-4-khandual@linux.vnet.ibm.com>
 <07bd439c-6270-b219-227b-4079d36a2788@intel.com>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Tue, 31 Jan 2017 07:06:20 +0530
MIME-Version: 1.0
In-Reply-To: <07bd439c-6270-b219-227b-4079d36a2788@intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <434aa74c-e917-490e-85ab-8c67b1a82d95@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: mhocko@suse.com, vbabka@suse.cz, mgorman@suse.de, minchan@kernel.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, dan.j.williams@intel.com

On 01/30/2017 11:04 PM, Dave Hansen wrote:
> On 01/29/2017 07:35 PM, Anshuman Khandual wrote:
>> * CDM node's zones are not part of any other node's FALLBACK zonelist
>> * CDM node's FALLBACK list contains it's own memory zones followed by
>>   all system RAM zones in regular order as before
>> * CDM node's zones are part of it's own NOFALLBACK zonelist
> 
> This seems like a sane policy for the system that you're describing.
> But, it's still a policy, and it's rather hard-coded into the kernel.

Right. In the original RFC which I had posted in October, I had thought
about this issue and created 'pglist_data->coherent_device' as a u64
element where each bit in the mask can indicate a specific policy request
for the hot plugged coherent device. But it looked too complicated in
for the moment in absence of other potential coherent memory HW which
really requires anything other than isolation and explicit allocation
method.

> Let's say we had a CDM node with 100x more RAM than the rest of the
> system and it was just as fast as the rest of the RAM.  Would we still
> want it isolated like this?  Or would we want a different policy?

Though in this particular case this CDM can be hot plugged into the
system as a normal NUMA node (I dont see any reason why it should
not be treated as normal NUMA node) but I do understand the need
for different policy requirements for different kind of coherent
memory.

But then the other argument being, dont we want to keep this 100X more
memory isolated for some special purpose to be utilized by specific
applications ?

There is a sense that if the non system RAM memory is coherent and
similar there cannot be much differences between what they would
expect from the kernel.

> 
> Why do we need this hard-coded along with the cpuset stuff later in the
> series.  Doesn't taking a node out of the cpuset also take it out of the
> fallback lists?

There are two mutually exclusive approaches which are described in
this patch series.

(1) zonelist modification based approach
(2) cpuset restriction based approach

As mentioned in the cover letter,

"
NOTE: These two set of patches mutually exclusive of each other and
represent two different approaches. Only one of these sets should be
applied at any point of time.

Set1:
  mm: Change generic FALLBACK zonelist creation process
  mm: Change mbind(MPOL_BIND) implementation for CDM nodes

Set2:
  cpuset: Add cpuset_inc() inside cpuset_init()
  mm: Exclude CDM nodes from task->mems_allowed and root cpuset
  mm: Ignore cpuset enforcement when allocation flag has __GFP_THISNODE
"

> 
>>  	while ((node = find_next_best_node(local_node, &used_mask)) >= 0) {
>> +#ifdef CONFIG_COHERENT_DEVICE
>> +		/*
>> +		 * CDM node's own zones should not be part of any other
>> +		 * node's fallback zonelist but only it's own fallback
>> +		 * zonelist.
>> +		 */
>> +		if (is_cdm_node(node) && (pgdat->node_id != node))
>> +			continue;
>> +#endif
> 
> On a superficial note: Isn't that #ifdef unnecessary?  is_cdm_node() has
> a 'return 0' stub when the config option is off anyway.

Right, will fix it up.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
