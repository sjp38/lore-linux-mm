Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 51F0C6B0389
	for <linux-mm@kvack.org>; Tue, 14 Feb 2017 05:15:50 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id h10so25644112ith.2
        for <linux-mm@kvack.org>; Tue, 14 Feb 2017 02:15:50 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id p124si389962ioe.121.2017.02.14.02.15.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Feb 2017 02:15:49 -0800 (PST)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v1EADVd4086703
	for <linux-mm@kvack.org>; Tue, 14 Feb 2017 05:15:49 -0500
Received: from e23smtp04.au.ibm.com (e23smtp04.au.ibm.com [202.81.31.146])
	by mx0b-001b2d01.pphosted.com with ESMTP id 28kveng8xm-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 14 Feb 2017 05:15:49 -0500
Received: from localhost
	by e23smtp04.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Tue, 14 Feb 2017 20:15:45 +1000
Received: from d23relay08.au.ibm.com (d23relay08.au.ibm.com [9.185.71.33])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 931373578053
	for <linux-mm@kvack.org>; Tue, 14 Feb 2017 21:15:41 +1100 (EST)
Received: from d23av06.au.ibm.com (d23av06.au.ibm.com [9.190.235.151])
	by d23relay08.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v1EAFXLS18481362
	for <linux-mm@kvack.org>; Tue, 14 Feb 2017 21:15:41 +1100
Received: from d23av06.au.ibm.com (localhost [127.0.0.1])
	by d23av06.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v1EAF8l8012269
	for <linux-mm@kvack.org>; Tue, 14 Feb 2017 21:15:09 +1100
Subject: Re: [PATCH V2 3/3] mm: Enable Buddy allocation isolation for CDM
 nodes
References: <20170210100640.26927-1-khandual@linux.vnet.ibm.com>
 <20170210100640.26927-4-khandual@linux.vnet.ibm.com>
 <44bbca4e-af5a-805c-c74b-28e684026611@suse.cz>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Tue, 14 Feb 2017 15:44:40 +0530
MIME-Version: 1.0
In-Reply-To: <44bbca4e-af5a-805c-c74b-28e684026611@suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Message-Id: <aed94333-7cd7-958e-ff8c-78a6cf05fe45@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: mhocko@suse.com, mgorman@suse.de, minchan@kernel.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, dave.hansen@intel.com, dan.j.williams@intel.com

On 02/14/2017 01:58 PM, Vlastimil Babka wrote:
> On 02/10/2017 11:06 AM, Anshuman Khandual wrote:
>> This implements allocation isolation for CDM nodes in buddy allocator by
>> discarding CDM memory zones all the time except in the cases where the gfp
>> flag has got __GFP_THISNODE or the nodemask contains CDM nodes in cases
>> where it is non NULL (explicit allocation request in the kernel or user
>> process MPOL_BIND policy based requests).
>>
>> Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
>> ---
>>  mm/page_alloc.c | 16 ++++++++++++++++
>>  1 file changed, 16 insertions(+)
>>
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index 84d61bb..392c24a 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -64,6 +64,7 @@
>>  #include <linux/page_owner.h>
>>  #include <linux/kthread.h>
>>  #include <linux/memcontrol.h>
>> +#include <linux/node.h>
>>  
>>  #include <asm/sections.h>
>>  #include <asm/tlbflush.h>
>> @@ -2908,6 +2909,21 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
>>  		struct page *page;
>>  		unsigned long mark;
>>  
>> +		/*
>> +		 * CDM nodes get skipped if the requested gfp flag
>> +		 * does not have __GFP_THISNODE set or the nodemask
>> +		 * does not have any CDM nodes in case the nodemask
>> +		 * is non NULL (explicit allocation requests from
>> +		 * kernel or user process MPOL_BIND policy which has
>> +		 * CDM nodes).
>> +		 */
>> +		if (is_cdm_node(zone->zone_pgdat->node_id)) {
>> +			if (!(gfp_mask & __GFP_THISNODE)) {
>> +				if (!ac->nodemask)
>> +					continue;
>> +			}
>> +		}
> 
> With the current cpuset implementation, this will have a subtle corner
> case when allocating from a cpuset that allows the cdm node, and there
> is no (task or vma) mempolicy applied for the allocation. In the fast
> path (__alloc_pages_nodemask()) we'll set ac->nodemask to
> current->mems_allowed, so your code will wrongly assume that this
> ac->nodemask is a policy that allows the CDM node. Probably not what you
> want?

You are right, its a problem and not what we want. We can make the
function get_page_from_freelist() take another parameter "orig_nodemask"
which gets passed into __alloc_pages_nodemask() in the first place. So
inside zonelist iterator we can compare orig_nodemask with current
ac.nodemask to figure out if cpuset swapping of nodemask happened and
skip CDM node if necessary. Thats a viable solution IMHO.

> 
> This might change if we decide to fix the cpuset vs mempolicy issues [1]
> so your input on that topic with your recent experience with all the
> alternative CDM isolation implementations would be useful. Thanks.
> 
> [1] http://www.spinics.net/lists/linux-mm/msg121760.html

Sure, will look into the details.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
