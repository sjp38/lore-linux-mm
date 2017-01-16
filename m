Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id A9E456B0253
	for <linux-mm@kvack.org>; Mon, 16 Jan 2017 07:20:14 -0500 (EST)
Received: by mail-it0-f71.google.com with SMTP id 203so139576656ith.3
        for <linux-mm@kvack.org>; Mon, 16 Jan 2017 04:20:14 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id t64si9457769itg.86.2017.01.16.04.20.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Jan 2017 04:20:14 -0800 (PST)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v0GCIg74062459
	for <linux-mm@kvack.org>; Mon, 16 Jan 2017 07:20:13 -0500
Received: from e28smtp06.in.ibm.com (e28smtp06.in.ibm.com [125.16.236.6])
	by mx0b-001b2d01.pphosted.com with ESMTP id 280t0e1vuw-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 16 Jan 2017 07:20:13 -0500
Received: from localhost
	by e28smtp06.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Mon, 16 Jan 2017 17:49:52 +0530
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id B92E8125805C
	for <linux-mm@kvack.org>; Mon, 16 Jan 2017 17:51:24 +0530 (IST)
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay04.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v0GCJmVq39256128
	for <linux-mm@kvack.org>; Mon, 16 Jan 2017 17:49:48 +0530
Received: from d28av02.in.ibm.com (localhost [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v0GCJjp2011802
	for <linux-mm@kvack.org>; Mon, 16 Jan 2017 17:49:47 +0530
Subject: Re: [LSF/MM ATTEND] HMM, CDM and other infrastructure for device
 memory management
References: <alpine.LNX.2.20.1701101600280.38701@blueforge.nvidia.com>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Mon, 16 Jan 2017 17:49:36 +0530
MIME-Version: 1.0
In-Reply-To: <alpine.LNX.2.20.1701101600280.38701@blueforge.nvidia.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <752ef94a-d5ba-7e14-c7d5-6c212e894edc@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Hubbard <jhubbard@nvidia.com>, lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org
Cc: Jerome Glisse <jglisse@redhat.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Serguei Sagalovitch <serguei.sagalovitch@amd.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Balbir Singh <bsingharora@gmail.com>, Michael Repasy <mrepasy@nvidia.com>

On 01/11/2017 09:52 AM, John Hubbard wrote:
> Hi,
> 
> I would like to attend this topic that Jerome has proposed. Studying the 
> kernel is a deep personal interest in addition to my career focus, and it 
> would be a rare privilege to work directly with some of you to converge 
> on some nice, clean designs for the kernel and these "new" 
> (page-fault-capable) devices that we have now. Here's what I can bring to 
> the discussion:
> 
> a) An NVIDIA perspective on, and experience with, using the HMM patchset, 
> versions 1-15, at the device driver level. In addition to working on the 
> nvidia-uvm.ko driver (which handles CPU and GPU page faulting) since its 
> inception, I've also helped develop and maintain various facets of our GPU 
> device driver for Linux, for the last 9 years.
> 
> As a semi-relevant aside, our company is allocating engineering time, 
> including mine, for long-term kernel projects such as this one. We want to 
> participate in maintaining and improving the kernel. I find that highly 
> encouraging and I hope others do, too. Times really are changing.
> 
> b) Some thoughts about the dividing line between core kernel and drivers. 
> Our device drivers are starting to push the limits of what drivers should 
> really do (we are heading perhaps too deeply into memory management), and 
> of course I want to avoid going too far. For example, I've seen 
> recent comments on linux-mm that drivers shouldn't even take mmap_sem, 
> which is intriguing. We need to provide...something for that, though. 
> 
> c) Some thoughts about dealing with both HMM and ATS in the same driver 
> (our devices have to support both--although, not at the same time).
> 
> --
> 
> For this discussion track, I'm especially interested in simultaneously 
> considering:
> 
> 1. HMM (Jerome's Heterogeneous Memory Management patchset): this solves a 
> similar problem as ATS (Address Translation Services: unified CPU and
> Device page tables), but without the need for specialized hardware. There 
> is a bit of overlap between the HMM and ATS+NUMA patchsets, as has been 
> discussed here before.
> 
> 2. IBM's ATS+NUMA patchset.
> 
> 3. Page-fault-capable devices in general.

Initially thought there would be a single common discussion TOPIC for all of
the "device memory management infrastructure" but seems like its getting
split into multiple TOPICs. Hence I am trying to sign up for all them
individually.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
