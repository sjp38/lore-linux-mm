Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0DAF06B0399
	for <linux-mm@kvack.org>; Tue, 21 Feb 2017 05:20:44 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id s27so10675515wrb.5
        for <linux-mm@kvack.org>; Tue, 21 Feb 2017 02:20:44 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id 39si27538319wrv.83.2017.02.21.02.20.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Feb 2017 02:20:42 -0800 (PST)
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v1LAIurc046185
	for <linux-mm@kvack.org>; Tue, 21 Feb 2017 05:20:41 -0500
Received: from e28smtp07.in.ibm.com (e28smtp07.in.ibm.com [125.16.236.7])
	by mx0a-001b2d01.pphosted.com with ESMTP id 28r2vnddrv-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 21 Feb 2017 05:20:41 -0500
Received: from localhost
	by e28smtp07.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Tue, 21 Feb 2017 15:50:37 +0530
Received: from d28relay07.in.ibm.com (d28relay07.in.ibm.com [9.184.220.158])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id F14C3E0060
	for <linux-mm@kvack.org>; Tue, 21 Feb 2017 15:52:13 +0530 (IST)
Received: from d28av08.in.ibm.com (d28av08.in.ibm.com [9.184.220.148])
	by d28relay07.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v1LAJXdn16056532
	for <linux-mm@kvack.org>; Tue, 21 Feb 2017 15:49:33 +0530
Received: from d28av08.in.ibm.com (localhost [127.0.0.1])
	by d28av08.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v1LAKYfo012716
	for <linux-mm@kvack.org>; Tue, 21 Feb 2017 15:50:35 +0530
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Subject: Re: [PATCH V3 1/4] mm: Define coherent device memory (CDM) node
References: <20170215120726.9011-1-khandual@linux.vnet.ibm.com>
 <20170215120726.9011-2-khandual@linux.vnet.ibm.com>
 <CAA_GA1d4LZ_=4=x6j9+1mv8KN_AEkiT=moxbmNtDMdLoNPYBFw@mail.gmail.com>
Date: Tue, 21 Feb 2017 15:50:27 +0530
MIME-Version: 1.0
In-Reply-To: <CAA_GA1d4LZ_=4=x6j9+1mv8KN_AEkiT=moxbmNtDMdLoNPYBFw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Message-Id: <fd465b9f-8a58-e2b6-099d-50c610233037@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <lliubbo@gmail.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: Linux-Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, mhocko@suse.com, Vlastimil Babka <vbabka@suse.cz>, "mgorman@suse.de" <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, aneesh.kumar@linux.vnet.ibm.com, Balbir Singh <bsingharora@gmail.com>, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, Dave Hansen <dave.hansen@intel.com>, Dan Williams <dan.j.williams@intel.com>

On 02/17/2017 07:35 PM, Bob Liu wrote:
> Hi Anshuman,
> 
> I have a few questions about coherent device memory.

Sure.

> 
> On Wed, Feb 15, 2017 at 8:07 PM, Anshuman Khandual
> <khandual@linux.vnet.ibm.com> wrote:
>> There are certain devices like specialized accelerator, GPU cards, network
>> cards, FPGA cards etc which might contain onboard memory which is coherent
>> along with the existing system RAM while being accessed either from the CPU
>> or from the device. They share some similar properties with that of normal
> 
> What's the general size of this kind of memory?

Its more comparable to available system RAM sizes and also not as high as
persistent storage memory or NVDIMM.

> 
>> system RAM but at the same time can also be different with respect to
>> system RAM.
>>
>> User applications might be interested in using this kind of coherent device
> 
> What kind of applications?

Applications which want to use CPU compute as well device compute on the
same allocated buffer transparently. Applications for example want to
load the problem statement on the allocated buffer and ask the device
through driver to compute results out of the problem statement.


> 
>> memory explicitly or implicitly along side the system RAM utilizing all
>> possible core memory functions like anon mapping (LRU), file mapping (LRU),
>> page cache (LRU), driver managed (non LRU), HW poisoning, NUMA migrations
> 
> I didn't see the benefit to manage the onboard memory same way as system RAM.
> Why not just map this kind of onborad memory to userspace directly?
> And only those specific applications can manage/access/use it.

Integration with core MM along with driver assisted migrations gives the
application the ability to use the allocated buffer seamlessly from the
CPU or the device without bothering about actual physical placement of
the pages. That changes the paradigm of cpu and device based hybrid
compute framework which can not be achieved by mapping the device memory
directly to the user space.

> 
> It sounds not very good to complicate the core memory framework a lot
> because of some not widely used devices and uncertain applications.

Applications are not uncertain, they intend to use these framework to
achieve hybrid cpu/device compute working transparently on the same
allocated virtual buffer. IIUC we would want Linux kernel to enable
new device technologies regardless whether they are widely used or
not.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
