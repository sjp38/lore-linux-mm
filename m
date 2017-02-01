Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9F7FB6B0253
	for <linux-mm@kvack.org>; Wed,  1 Feb 2017 01:57:24 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id f5so477299204pgi.1
        for <linux-mm@kvack.org>; Tue, 31 Jan 2017 22:57:24 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id d187si13549703pgc.362.2017.01.31.22.57.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 31 Jan 2017 22:57:23 -0800 (PST)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v116sWV1002848
	for <linux-mm@kvack.org>; Wed, 1 Feb 2017 01:57:23 -0500
Received: from e23smtp03.au.ibm.com (e23smtp03.au.ibm.com [202.81.31.145])
	by mx0a-001b2d01.pphosted.com with ESMTP id 28b8c4v4h7-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 01 Feb 2017 01:57:22 -0500
Received: from localhost
	by e23smtp03.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Wed, 1 Feb 2017 16:57:20 +1000
Received: from d23relay07.au.ibm.com (d23relay07.au.ibm.com [9.190.26.37])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id A0ED42BB0055
	for <linux-mm@kvack.org>; Wed,  1 Feb 2017 17:57:18 +1100 (EST)
Received: from d23av06.au.ibm.com (d23av06.au.ibm.com [9.190.235.151])
	by d23relay07.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v116vAAo35913854
	for <linux-mm@kvack.org>; Wed, 1 Feb 2017 17:57:18 +1100
Received: from d23av06.au.ibm.com (localhost [127.0.0.1])
	by d23av06.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v116ukPM008409
	for <linux-mm@kvack.org>; Wed, 1 Feb 2017 17:56:46 +1100
Subject: Re: [RFC V2 03/12] mm: Change generic FALLBACK zonelist creation
 process
References: <20170130033602.12275-1-khandual@linux.vnet.ibm.com>
 <20170130033602.12275-4-khandual@linux.vnet.ibm.com>
 <07bd439c-6270-b219-227b-4079d36a2788@intel.com>
 <434aa74c-e917-490e-85ab-8c67b1a82d95@linux.vnet.ibm.com>
 <f1521ecc-e2a2-7368-07b7-7af6c0e88cc6@intel.com>
 <79bfd849-8e6c-2f6d-0acf-4256a4137526@nvidia.com>
 <217e817e-2f91-91a5-1bef-16fb0cbacb63@intel.com>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Wed, 1 Feb 2017 12:26:16 +0530
MIME-Version: 1.0
In-Reply-To: <217e817e-2f91-91a5-1bef-16fb0cbacb63@intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <1ab159b5-1b67-9dae-4112-3360d8f909fd@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>, John Hubbard <jhubbard@nvidia.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: mhocko@suse.com, vbabka@suse.cz, mgorman@suse.de, minchan@kernel.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, dan.j.williams@intel.com

On 01/31/2017 11:34 PM, Dave Hansen wrote:
> On 01/30/2017 11:25 PM, John Hubbard wrote:
>> I also don't like having these policies hard-coded, and your 100x
>> example above helps clarify what can go wrong about it. It would be
>> nicer if, instead, we could better express the "distance" between nodes
>> (bandwidth, latency, relative to sysmem, perhaps), and let the NUMA
>> system figure out the Right Thing To Do.
>>
>> I realize that this is not quite possible with NUMA just yet, but I
>> wonder if that's a reasonable direction to go with this?
> 
> In the end, I don't think the kernel can make the "right" decision very
> widely here.
> 
> Intel's Xeon Phis have some high-bandwidth memory (MCDRAM) that
> evidently has a higher latency than DRAM.  Given a plain malloc(), how
> is the kernel to know that the memory will be used for AVX-512
> instructions that need lots of bandwidth vs. some random data structure
> that's latency-sensitive?

CDM has been designed to work with a driver which can take these kind
of appropriate memory placement decisions along the way. But as per
the above example of an generic malloc() allocated buffer.

(1) System RAM gets allocated if there are first CPU faults
(2) CDM memory gets allocated if there are first device access faults
(3) After monitoring the access patterns there after, the driver can
    then take required "right" decisions about its eventual placement
    and migrates memory as required

> 
> In the end, I think all we can do is keep the kernel's existing default
> of "low latency to the CPU that allocated it", and let apps override
> when that policy doesn't fit them.

I think this is almost similar to what we are trying to achieve with
CDM representation and driver based migrations. Dont you agree ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
