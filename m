Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2A5196B0033
	for <linux-mm@kvack.org>; Mon, 30 Jan 2017 23:22:34 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id 204so488186492pfx.1
        for <linux-mm@kvack.org>; Mon, 30 Jan 2017 20:22:34 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id b4si14722109plb.157.2017.01.30.20.22.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Jan 2017 20:22:33 -0800 (PST)
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v0V4J4Hw051291
	for <linux-mm@kvack.org>; Mon, 30 Jan 2017 23:22:32 -0500
Received: from e28smtp01.in.ibm.com (e28smtp01.in.ibm.com [125.16.236.1])
	by mx0a-001b2d01.pphosted.com with ESMTP id 28aec39c3v-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 30 Jan 2017 23:22:31 -0500
Received: from localhost
	by e28smtp01.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Tue, 31 Jan 2017 09:52:29 +0530
Received: from d28relay06.in.ibm.com (d28relay06.in.ibm.com [9.184.220.150])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id E0385E005A
	for <linux-mm@kvack.org>; Tue, 31 Jan 2017 09:53:44 +0530 (IST)
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay06.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v0V4MPuR22872126
	for <linux-mm@kvack.org>; Tue, 31 Jan 2017 09:52:25 +0530
Received: from d28av03.in.ibm.com (localhost [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v0V4MOv0022076
	for <linux-mm@kvack.org>; Tue, 31 Jan 2017 09:52:25 +0530
Subject: Re: [RFC V2 08/12] mm: Add new VMA flag VM_CDM
References: <20170130033602.12275-1-khandual@linux.vnet.ibm.com>
 <20170130033602.12275-9-khandual@linux.vnet.ibm.com>
 <20170130185213.GA7198@redhat.com>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Tue, 31 Jan 2017 09:52:20 +0530
MIME-Version: 1.0
In-Reply-To: <20170130185213.GA7198@redhat.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <28bd4abc-3cbd-514e-1535-15ce67131772@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.com, vbabka@suse.cz, mgorman@suse.de, minchan@kernel.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, dave.hansen@intel.com, dan.j.williams@intel.com

On 01/31/2017 12:22 AM, Jerome Glisse wrote:
> On Mon, Jan 30, 2017 at 09:05:49AM +0530, Anshuman Khandual wrote:
>> VMA which contains CDM memory pages should be marked with new VM_CDM flag.
>> These VMAs need to be identified in various core kernel paths for special
>> handling and this flag will help in their identification.
>>
>> Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
> 
> 
> Why doing this on vma basis ? Why not special casing all those path on page
> basis ?

The primary motivation being the cost. Wont it be too expensive to account
for and act on individual pages rather than on the VMA as a whole ? For
example page_to_nid() seemed pretty expensive when tried to tag VMA on
individual page fault basis.

> 
> After all you can have a big vma with some pages in it being cdm and other
> being regular page. The CPU process might migrate to different CPU in a
> different node and you might still want to have the regular page to migrate
> to this new node and keep the cdm page while the device is still working
> on them.

Right, that is the ideal thing to do. But wont it be better to split the
big VMA into smaller chunks and tag them appropriately so that those VMAs
tagged would contain as much CDM pages as possible for them to be likely
restricted from auto NUMA, KSM etc.

> 
> This is just an example, same can apply for ksm or any other kernel feature
> you want to special case. Maybe we can store a set of flag in node that
> tells what is allowed for page in node (ksm, hugetlb, migrate, numa, ...).
> 
> This would be more flexible and the policy choice can be left to each of
> the device driver.

Hmm, thats another way of doing the special cases. The other way as Dave
had mentioned before is to classify coherent memory property into various
kinds and store them for each node and implement a predefined set of
restrictions for each kind of coherent memory which might include features
like auto NUMA, HugeTLB, KSM etc. Maintaining two different property sets
one for the kind of coherent memory and the other being for each special
cases) wont be too complicated ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
