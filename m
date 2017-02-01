Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 589336B0033
	for <linux-mm@kvack.org>; Wed,  1 Feb 2017 09:00:14 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id y143so560825048pfb.6
        for <linux-mm@kvack.org>; Wed, 01 Feb 2017 06:00:14 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id w17si14438793pgm.344.2017.02.01.06.00.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Feb 2017 06:00:13 -0800 (PST)
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v11DsHPB144159
	for <linux-mm@kvack.org>; Wed, 1 Feb 2017 09:00:12 -0500
Received: from e23smtp09.au.ibm.com (e23smtp09.au.ibm.com [202.81.31.142])
	by mx0a-001b2d01.pphosted.com with ESMTP id 28be1nq4yt-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 01 Feb 2017 09:00:12 -0500
Received: from localhost
	by e23smtp09.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Thu, 2 Feb 2017 00:00:07 +1000
Received: from d23relay08.au.ibm.com (d23relay08.au.ibm.com [9.185.71.33])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 355233578053
	for <linux-mm@kvack.org>; Thu,  2 Feb 2017 01:00:04 +1100 (EST)
Received: from d23av06.au.ibm.com (d23av06.au.ibm.com [9.190.235.151])
	by d23relay08.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v11DxuJk28311740
	for <linux-mm@kvack.org>; Thu, 2 Feb 2017 01:00:04 +1100
Received: from d23av06.au.ibm.com (localhost [127.0.0.1])
	by d23av06.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v11DxVJI019373
	for <linux-mm@kvack.org>; Thu, 2 Feb 2017 00:59:32 +1100
Subject: Re: [RFC V2 02/12] mm: Isolate HugeTLB allocations away from CDM
 nodes
References: <20170130033602.12275-1-khandual@linux.vnet.ibm.com>
 <20170130033602.12275-3-khandual@linux.vnet.ibm.com>
 <01671749-c649-e015-4f51-7acaa1fb5b80@intel.com>
 <be8665a1-43d2-436a-90df-b644365a2fc5@linux.vnet.ibm.com>
 <db9e7345-da08-5011-22ae-b20927b174f4@intel.com>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Wed, 1 Feb 2017 19:29:00 +0530
MIME-Version: 1.0
In-Reply-To: <db9e7345-da08-5011-22ae-b20927b174f4@intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <d1995ee9-246f-5920-8a75-61868c2a209e@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: mhocko@suse.com, vbabka@suse.cz, mgorman@suse.de, minchan@kernel.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, dan.j.williams@intel.com

On 01/31/2017 07:07 AM, Dave Hansen wrote:
> On 01/30/2017 05:03 PM, Anshuman Khandual wrote:
>> On 01/30/2017 10:49 PM, Dave Hansen wrote:
>>> On 01/29/2017 07:35 PM, Anshuman Khandual wrote:
>>>> HugeTLB allocation/release/accounting currently spans across all the nodes
>>>> under N_MEMORY node mask. Coherent memory nodes should not be part of these
>>>> allocations. So use system_ram() call to fetch system RAM only nodes on the
>>>> platform which can then be used for HugeTLB allocation purpose instead of
>>>> N_MEMORY node mask. This isolates coherent device memory nodes from HugeTLB
>>>> allocations.
>>>
>>> Does this end up making it impossible to use hugetlbfs to access device
>>> memory?
>>
>> Right, thats the implementation at the moment. But going forward if we need
>> to have HugeTLB pages on the CDM node, then we can implement through the
>> sysfs interface from individual NUMA node paths instead of changing the
>> generic HugeTLB path. I wrote this up in the cover letter but should also
>> have mentioned in the comment section of this patch as well. Does this
>> approach look okay ?
> 
> The cover letter is not the most approachable document I've ever seen. :)

Hmm,

So shall we write all these details in the comment section for each
patch after the SOB statement to be more visible ? Or some where
in-code documentation as FIXME or XXX or something. These are little
large paragraphs, hence was wondering.

> 
>> "Now, we ensure complete HugeTLB allocation isolation from CDM nodes. Going
>> forward if we need to support HugeTLB allocation on CDM nodes on targeted
>> basis, then we would have to enable those allocations through the
>> /sys/devices/system/node/nodeN/hugepages/hugepages-16384kB/nr_hugepages
>> interface while still ensuring isolation from other generic sysctl and
>> /sys/kernel/mm/hugepages/hugepages-16384kB/nr_hugepages interfaces."
> 
> That would be passable if that's the only way you can allocate hugetlbfs
> pages.  But we also have the fault-based allocations that can pull stuff
> right out of the buddy allocator.  This approach would break that path
> entirely.

There two distinct points which I think will prevent the problem you just
mentioned.

* No regular node has CDM memory in their fallback zone list. Hence any
  allocation attempt without __GFP_THISNODE will never go into CDM memory
  zones. If the allocation happens with __GFP_THISNODE flag it will only
  happen from the exact node. Remember we have removed CDM nodes from the
  global nodemask iterators. Then how can pre allocated reserve HugeTLB
  pages can come from CDM nodes ?

* Page faults (which will probably use __GFP_THISNODE) cannot come from the
  CDM nodes as they dont have any CPUs.

I did a quick scan of all the allocation paths leading upto the allocation
functions alloc_pages_node() and __alloc_pages_node() inside the hugetlb.c
file. Might be missing something here.

> 
> FWIW, I think you really need to separate the true "CDM" stuff that's
> *really* device-specific from the parts of this from which you really
> just want to implement isolation.

IIUC, are you suggesting something like a pure CDM HugeTLB implementation
which is completely separated from the generic one ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
