Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4F7546B0069
	for <linux-mm@kvack.org>; Mon, 30 Jan 2017 20:37:11 -0500 (EST)
Received: by mail-io0-f197.google.com with SMTP id 67so162679151ioh.1
        for <linux-mm@kvack.org>; Mon, 30 Jan 2017 17:37:11 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id z29si9904493pgc.166.2017.01.30.17.37.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Jan 2017 17:37:10 -0800 (PST)
Subject: Re: [RFC V2 02/12] mm: Isolate HugeTLB allocations away from CDM
 nodes
References: <20170130033602.12275-1-khandual@linux.vnet.ibm.com>
 <20170130033602.12275-3-khandual@linux.vnet.ibm.com>
 <01671749-c649-e015-4f51-7acaa1fb5b80@intel.com>
 <be8665a1-43d2-436a-90df-b644365a2fc5@linux.vnet.ibm.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <db9e7345-da08-5011-22ae-b20927b174f4@intel.com>
Date: Mon, 30 Jan 2017 17:37:09 -0800
MIME-Version: 1.0
In-Reply-To: <be8665a1-43d2-436a-90df-b644365a2fc5@linux.vnet.ibm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: mhocko@suse.com, vbabka@suse.cz, mgorman@suse.de, minchan@kernel.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, dan.j.williams@intel.com

On 01/30/2017 05:03 PM, Anshuman Khandual wrote:
> On 01/30/2017 10:49 PM, Dave Hansen wrote:
>> On 01/29/2017 07:35 PM, Anshuman Khandual wrote:
>>> HugeTLB allocation/release/accounting currently spans across all the nodes
>>> under N_MEMORY node mask. Coherent memory nodes should not be part of these
>>> allocations. So use system_ram() call to fetch system RAM only nodes on the
>>> platform which can then be used for HugeTLB allocation purpose instead of
>>> N_MEMORY node mask. This isolates coherent device memory nodes from HugeTLB
>>> allocations.
>>
>> Does this end up making it impossible to use hugetlbfs to access device
>> memory?
> 
> Right, thats the implementation at the moment. But going forward if we need
> to have HugeTLB pages on the CDM node, then we can implement through the
> sysfs interface from individual NUMA node paths instead of changing the
> generic HugeTLB path. I wrote this up in the cover letter but should also
> have mentioned in the comment section of this patch as well. Does this
> approach look okay ?

The cover letter is not the most approachable document I've ever seen. :)

> "Now, we ensure complete HugeTLB allocation isolation from CDM nodes. Going
> forward if we need to support HugeTLB allocation on CDM nodes on targeted
> basis, then we would have to enable those allocations through the
> /sys/devices/system/node/nodeN/hugepages/hugepages-16384kB/nr_hugepages
> interface while still ensuring isolation from other generic sysctl and
> /sys/kernel/mm/hugepages/hugepages-16384kB/nr_hugepages interfaces."

That would be passable if that's the only way you can allocate hugetlbfs
pages.  But we also have the fault-based allocations that can pull stuff
right out of the buddy allocator.  This approach would break that path
entirely.

FWIW, I think you really need to separate the true "CDM" stuff that's
*really* device-specific from the parts of this from which you really
just want to implement isolation.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
