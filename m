Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id A100C6B0253
	for <linux-mm@kvack.org>; Tue, 25 Oct 2016 00:16:05 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id fl2so7311628pad.7
        for <linux-mm@kvack.org>; Mon, 24 Oct 2016 21:16:05 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id d6si15586413pao.101.2016.10.24.21.16.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Oct 2016 21:16:04 -0700 (PDT)
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u9P4Dkgd116600
	for <linux-mm@kvack.org>; Tue, 25 Oct 2016 00:16:04 -0400
Received: from e33.co.us.ibm.com (e33.co.us.ibm.com [32.97.110.151])
	by mx0a-001b2d01.pphosted.com with ESMTP id 269yh19feh-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 25 Oct 2016 00:16:03 -0400
Received: from localhost
	by e33.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 24 Oct 2016 22:16:02 -0600
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [RFC 3/8] mm: Isolate coherent device memory nodes from HugeTLB allocation paths
In-Reply-To: <580E41F0.20601@intel.com>
References: <1477283517-2504-1-git-send-email-khandual@linux.vnet.ibm.com> <1477283517-2504-4-git-send-email-khandual@linux.vnet.ibm.com> <580E41F0.20601@intel.com>
Date: Tue, 25 Oct 2016 09:45:53 +0530
MIME-Version: 1.0
Content-Type: text/plain
Message-Id: <87d1ipawsm.fsf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: mhocko@suse.com, js1304@gmail.com, vbabka@suse.cz, mgorman@suse.de, minchan@kernel.org, akpm@linux-foundation.org, bsingharora@gmail.com

Dave Hansen <dave.hansen@intel.com> writes:

> On 10/23/2016 09:31 PM, Anshuman Khandual wrote:
>> This change is part of the isolation requiring coherent device memory nodes
>> implementation.
>> 
>> Isolation seeking coherent device memory node requires allocation isolation
>> from implicit memory allocations from user space. Towards that effect, the
>> memory should not be used for generic HugeTLB page pool allocations. This
>> modifies relevant functions to skip all coherent memory nodes present on
>> the system during allocation, freeing and auditing for HugeTLB pages.
>
> This seems really fragile.  You had to hit, what, 18 call sites?  What
> are the odds that this is going to stay working?


I guess a better approach is to introduce new node_states entry such
that we have one that excludes coherent device memory numa nodes. One
possibility is to add N_SYSTEM_MEMORY and N_MEMORY.

Current N_MEMORY becomes N_SYSTEM_MEMORY and N_MEMORY includes
system and device/any other memory which is coherent.

All the isolation can then be achieved based on the nodemask_t used for
allocation. So for allocations we want to avoid from coherent device we
use N_SYSTEM_MEMORY mask or a derivative of that and where we are ok to
allocate from CDM with fallbacks we use N_MEMORY.

All nodes zonelist will have zones from the coherent device nodes but we
will not end up allocating from coherent device node zone due to the
node mask used.


This will also make sure we end up allocating from the correct coherent
device numa node in the presence of multiple of them based on the
distance of the coherent device node from the current executing numa
node.



>
>> @@ -2666,6 +2688,10 @@ static void __init hugetlb_register_all_nodes(void)
>>  
>>  	for_each_node_state(nid, N_MEMORY) {
>>  		struct node *node = node_devices[nid];
>> +
>> +		if (isolated_cdm_node(nid))
>> +			continue;
>> +
>>  		if (node->dev.id == nid)
>>  			hugetlb_register_node(node);
>>  	}
>
> This looks to be completely kneecapping hugetlbfs on these cdm nodes.
> Is that really what you want?
>
>> @@ -2819,8 +2845,12 @@ static unsigned int cpuset_mems_nr(unsigned int *array)
>>  	int node;
>>  	unsigned int nr = 0;
>>  
>> -	for_each_node_mask(node, cpuset_current_mems_allowed)
>> +	for_each_node_mask(node, cpuset_current_mems_allowed) {
>> +		if (isolated_cdm_node(node))
>> +			continue;
>> +
>>  		nr += array[node];
>> +	}
>>  
>>  	return nr;
>>  }
>> @@ -2940,7 +2970,10 @@ void hugetlb_show_meminfo(void)
>>  	if (!hugepages_supported())
>>  		return;
>>  
>> -	for_each_node_state(nid, N_MEMORY)
>> +	for_each_node_state(nid, N_MEMORY) {
>> +		if (isolated_cdm_node(nid))
>> +			continue;
>> +
>>  		for_each_hstate(h)
>>  			pr_info("Node %d hugepages_total=%u hugepages_free=%u hugepages_surp=%u hugepages_size=%lukB\n",
>>  				nid,
>> @@ -2948,6 +2981,7 @@ void hugetlb_show_meminfo(void)
>>  				h->free_huge_pages_node[nid],
>>  				h->surplus_huge_pages_node[nid],
>>  				1UL << (huge_page_order(h) + PAGE_SHIFT - 10));
>> +	}
>>  }
>
> Your patch description talks about removing *implicit* memory
> allocations.  But, this removes even the ability to gather *stats* about
> huge pages sitting on one of these nodes.  That's a lot more drastic
> than just changing implicit policies.
>
> Is that patch description accurate?
>
> It looks to me like you just went through all the for_each_node*() loops
> in hugetlb.c and hacked your node check into them indiscriminately.
> This totally removes the ability to *do* hugetlb on this nodes.
>
> Isn't there some simpler way to do all this, like maybe changing the
> root cpuset to disallow allocations to these nodes?

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
