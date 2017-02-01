Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9DE7C6B0253
	for <linux-mm@kvack.org>; Wed,  1 Feb 2017 01:46:28 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id e4so404305453pfg.4
        for <linux-mm@kvack.org>; Tue, 31 Jan 2017 22:46:28 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id n5si13546769pgh.185.2017.01.31.22.46.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 31 Jan 2017 22:46:27 -0800 (PST)
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v116i0DQ109366
	for <linux-mm@kvack.org>; Wed, 1 Feb 2017 01:46:27 -0500
Received: from e28smtp07.in.ibm.com (e28smtp07.in.ibm.com [125.16.236.7])
	by mx0b-001b2d01.pphosted.com with ESMTP id 28bank82gh-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 01 Feb 2017 01:46:26 -0500
Received: from localhost
	by e28smtp07.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Wed, 1 Feb 2017 12:16:23 +0530
Received: from d28relay06.in.ibm.com (d28relay06.in.ibm.com [9.184.220.150])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id 52BBA125801F
	for <linux-mm@kvack.org>; Wed,  1 Feb 2017 12:18:07 +0530 (IST)
Received: from d28av07.in.ibm.com (d28av07.in.ibm.com [9.184.220.146])
	by d28relay06.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v116kL6g23396404
	for <linux-mm@kvack.org>; Wed, 1 Feb 2017 12:16:21 +0530
Received: from d28av07.in.ibm.com (localhost [127.0.0.1])
	by d28av07.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v116kKcV022166
	for <linux-mm@kvack.org>; Wed, 1 Feb 2017 12:16:20 +0530
Subject: Re: [RFC V2 03/12] mm: Change generic FALLBACK zonelist creation
 process
References: <20170130033602.12275-1-khandual@linux.vnet.ibm.com>
 <20170130033602.12275-4-khandual@linux.vnet.ibm.com>
 <07bd439c-6270-b219-227b-4079d36a2788@intel.com>
 <434aa74c-e917-490e-85ab-8c67b1a82d95@linux.vnet.ibm.com>
 <f1521ecc-e2a2-7368-07b7-7af6c0e88cc6@intel.com>
 <79bfd849-8e6c-2f6d-0acf-4256a4137526@nvidia.com>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Wed, 1 Feb 2017 12:16:16 +0530
MIME-Version: 1.0
In-Reply-To: <79bfd849-8e6c-2f6d-0acf-4256a4137526@nvidia.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <c174cdbe-fb7f-2c0f-7ac5-9f8719a06e0f@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Hubbard <jhubbard@nvidia.com>, Dave Hansen <dave.hansen@intel.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: mhocko@suse.com, vbabka@suse.cz, mgorman@suse.de, minchan@kernel.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, dan.j.williams@intel.com

On 01/31/2017 12:55 PM, John Hubbard wrote:
> On 01/30/2017 05:57 PM, Dave Hansen wrote:
>> On 01/30/2017 05:36 PM, Anshuman Khandual wrote:
>>>> Let's say we had a CDM node with 100x more RAM than the rest of the
>>>> system and it was just as fast as the rest of the RAM.  Would we still
>>>> want it isolated like this?  Or would we want a different policy?
>>>
>>> But then the other argument being, dont we want to keep this 100X more
>>> memory isolated for some special purpose to be utilized by specific
>>> applications ?
>>
>> I was thinking that in this case, we wouldn't even want to bother with
>> having "system RAM" in the fallback lists.  A device who got its memory
>> usage off by 1% could start to starve the rest of the system.  A sane
>> policy in this case might be to isolate the "system RAM" from the
>> device's.
> 
> I also don't like having these policies hard-coded, and your 100x
> example above helps clarify what can go wrong about it. It would be
> nicer if, instead, we could better express the "distance" between nodes
> (bandwidth, latency, relative to sysmem, perhaps), and let the NUMA
> system figure out the Right Thing To Do.
> 
> I realize that this is not quite possible with NUMA just yet, but I
> wonder if that's a reasonable direction to go with this?

That is complete overhaul of the NUMA representation in the kernel. What
CDM attempts is to find a solution with existing NUMA framework and with
as little code change as possible.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
