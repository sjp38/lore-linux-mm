Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3F7E26B0038
	for <linux-mm@kvack.org>; Mon, 30 Jan 2017 20:03:34 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id d9so168929427itc.4
        for <linux-mm@kvack.org>; Mon, 30 Jan 2017 17:03:34 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id m78si14285432pfg.240.2017.01.30.17.03.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Jan 2017 17:03:33 -0800 (PST)
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v0V13W5v043224
	for <linux-mm@kvack.org>; Mon, 30 Jan 2017 20:03:32 -0500
Received: from e28smtp09.in.ibm.com (e28smtp09.in.ibm.com [125.16.236.9])
	by mx0b-001b2d01.pphosted.com with ESMTP id 28abjkt7mt-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 30 Jan 2017 20:03:27 -0500
Received: from localhost
	by e28smtp09.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Tue, 31 Jan 2017 06:33:24 +0530
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id 7FE44125801F
	for <linux-mm@kvack.org>; Tue, 31 Jan 2017 06:35:06 +0530 (IST)
Received: from d28av08.in.ibm.com (d28av08.in.ibm.com [9.184.220.148])
	by d28relay03.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v0V13Lao33226894
	for <linux-mm@kvack.org>; Tue, 31 Jan 2017 06:33:21 +0530
Received: from d28av08.in.ibm.com (localhost [127.0.0.1])
	by d28av08.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v0V13KKa001112
	for <linux-mm@kvack.org>; Tue, 31 Jan 2017 06:33:21 +0530
Subject: Re: [RFC V2 02/12] mm: Isolate HugeTLB allocations away from CDM
 nodes
References: <20170130033602.12275-1-khandual@linux.vnet.ibm.com>
 <20170130033602.12275-3-khandual@linux.vnet.ibm.com>
 <01671749-c649-e015-4f51-7acaa1fb5b80@intel.com>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Tue, 31 Jan 2017 06:33:12 +0530
MIME-Version: 1.0
In-Reply-To: <01671749-c649-e015-4f51-7acaa1fb5b80@intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <be8665a1-43d2-436a-90df-b644365a2fc5@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: mhocko@suse.com, vbabka@suse.cz, mgorman@suse.de, minchan@kernel.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, dan.j.williams@intel.com

On 01/30/2017 10:49 PM, Dave Hansen wrote:
> On 01/29/2017 07:35 PM, Anshuman Khandual wrote:
>> HugeTLB allocation/release/accounting currently spans across all the nodes
>> under N_MEMORY node mask. Coherent memory nodes should not be part of these
>> allocations. So use system_ram() call to fetch system RAM only nodes on the
>> platform which can then be used for HugeTLB allocation purpose instead of
>> N_MEMORY node mask. This isolates coherent device memory nodes from HugeTLB
>> allocations.
> 
> Does this end up making it impossible to use hugetlbfs to access device
> memory?

Right, thats the implementation at the moment. But going forward if we need
to have HugeTLB pages on the CDM node, then we can implement through the
sysfs interface from individual NUMA node paths instead of changing the
generic HugeTLB path. I wrote this up in the cover letter but should also
have mentioned in the comment section of this patch as well. Does this
approach look okay ?

"Now, we ensure complete HugeTLB allocation isolation from CDM nodes. Going
forward if we need to support HugeTLB allocation on CDM nodes on targeted
basis, then we would have to enable those allocations through the
/sys/devices/system/node/nodeN/hugepages/hugepages-16384kB/nr_hugepages
interface while still ensuring isolation from other generic sysctl and
/sys/kernel/mm/hugepages/hugepages-16384kB/nr_hugepages interfaces."

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
