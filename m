Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id CDA0F6B0274
	for <linux-mm@kvack.org>; Wed, 26 Oct 2016 07:13:19 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id dm10so2614188pac.12
        for <linux-mm@kvack.org>; Wed, 26 Oct 2016 04:13:19 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id k3si1652878pap.346.2016.10.26.04.13.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Oct 2016 04:13:18 -0700 (PDT)
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u9QBBAwB123107
	for <linux-mm@kvack.org>; Wed, 26 Oct 2016 07:13:18 -0400
Received: from e23smtp02.au.ibm.com (e23smtp02.au.ibm.com [202.81.31.144])
	by mx0a-001b2d01.pphosted.com with ESMTP id 26ashx5t2y-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 26 Oct 2016 07:13:18 -0400
Received: from localhost
	by e23smtp02.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Wed, 26 Oct 2016 21:13:15 +1000
Received: from d23relay07.au.ibm.com (d23relay07.au.ibm.com [9.190.26.37])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 611623578052
	for <linux-mm@kvack.org>; Wed, 26 Oct 2016 22:13:13 +1100 (EST)
Received: from d23av05.au.ibm.com (d23av05.au.ibm.com [9.190.234.119])
	by d23relay07.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u9QBDD6I15925260
	for <linux-mm@kvack.org>; Wed, 26 Oct 2016 22:13:13 +1100
Received: from d23av05.au.ibm.com (localhost [127.0.0.1])
	by d23av05.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u9QBDCt0018646
	for <linux-mm@kvack.org>; Wed, 26 Oct 2016 22:13:13 +1100
Subject: Re: [RFC 0/8] Define coherent device memory node
References: <1477283517-2504-1-git-send-email-khandual@linux.vnet.ibm.com>
 <20161024170902.GA5521@gmail.com> <877f8xaurp.fsf@linux.vnet.ibm.com>
 <20161025153256.GB6131@gmail.com> <87shrkjpyb.fsf@linux.vnet.ibm.com>
 <20161025185247.GA7188@gmail.com>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Wed, 26 Oct 2016 16:43:10 +0530
MIME-Version: 1.0
In-Reply-To: <20161025185247.GA7188@gmail.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <58108FC6.5070701@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <j.glisse@gmail.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.com, js1304@gmail.com, vbabka@suse.cz, mgorman@suse.de, minchan@kernel.org, akpm@linux-foundation.org, bsingharora@gmail.com

On 10/26/2016 12:22 AM, Jerome Glisse wrote:
> On Tue, Oct 25, 2016 at 11:01:08PM +0530, Aneesh Kumar K.V wrote:
>> Jerome Glisse <j.glisse@gmail.com> writes:
>>
>>> On Tue, Oct 25, 2016 at 10:29:38AM +0530, Aneesh Kumar K.V wrote:
>>>> Jerome Glisse <j.glisse@gmail.com> writes:
>>>>> On Mon, Oct 24, 2016 at 10:01:49AM +0530, Anshuman Khandual wrote:
>>>
>>> [...]
>>>
>>>>> You can take a look at hmm-v13 if you want to see how i do non LRU page
>>>>> migration. While i put most of the migration code inside hmm_migrate.c it
>>>>> could easily be move to migrate.c without hmm_ prefix.
>>>>>
>>>>> There is 2 missing piece with existing migrate code. First is to put memory
>>>>> allocation for destination under control of who call the migrate code. Second
>>>>> is to allow offloading the copy operation to device (ie not use the CPU to
>>>>> copy data).
>>>>>
>>>>> I believe same requirement also make sense for platform you are targeting.
>>>>> Thus same code can be use.
>>>>>
>>>>> hmm-v13 https://cgit.freedesktop.org/~glisse/linux/log/?h=hmm-v13
>>>>>
>>>>> I haven't posted this patchset yet because we are doing some modifications
>>>>> to the device driver API to accomodate some new features. But the ZONE_DEVICE
>>>>> changes and the overall migration code will stay the same more or less (i have
>>>>> patches that move it to migrate.c and share more code with existing migrate
>>>>> code).
>>>>>
>>>>> If you think i missed anything about lru and page cache please point it to
>>>>> me. Because when i audited code for that i didn't see any road block with
>>>>> the few fs i was looking at (ext4, xfs and core page cache code).
>>>>>
>>>>
>>>> The other restriction around ZONE_DEVICE is, it is not a managed zone.
>>>> That prevents any direct allocation from coherent device by application.
>>>> ie, we would like to force allocation from coherent device using
>>>> interface like mbind(MPOL_BIND..) . Is that possible with ZONE_DEVICE ?
>>>
>>> To achieve this we rely on device fault code path ie when device take a page fault
>>> with help of HMM it will use existing memory if any for fault address but if CPU
>>> page table is empty (and it is not file back vma because of readback) then device
>>> can directly allocate device memory and HMM will update CPU page table to point to
>>> newly allocated device memory.
>>>
>>
>> That is ok if the device touch the page first. What if we want the
>> allocation touched first by cpu to come from GPU ?. Should we always
>> depend on GPU driver to migrate such pages later from system RAM to GPU
>> memory ?
>>
> 
> I am not sure what kind of workload would rather have every first CPU access for
> a range to use device memory. So no my code does not handle that and it is pointless
> for it as CPU can not access device memory for me.
> 
> That said nothing forbid to add support for ZONE_DEVICE with mbind() like syscall.
> Thought my personnal preference would still be to avoid use of such generic syscall
> but have device driver set allocation policy through its own userspace API (device
> driver could reuse internal of mbind() to achieve the end result).
> 
> I am not saying that eveything you want to do is doable now with HMM but, nothing
> preclude achieving what you want to achieve using ZONE_DEVICE. I really don't think
> any of the existing mm mechanism (kswapd, lru, numa, ...) are nice fit and can be reuse
> with device memory.
> 
> Each device is so different from the other that i don't believe in a one API fit all.
> The drm GPU subsystem of the kernel is a testimony of how little can be share when it
> comes to GPU. The only common code is modesetting. Everything that deals with how to
> use GPU to compute stuff is per device and most of the logic is in userspace. So i do
> not see any commonality that could be abstracted at syscall level. I would rather let
> device driver stack (kernel and userspace) take such decision and have the higher level
> API (OpenCL, Cuda, C++17, ...) expose something that make sense for each of them.
> Programmer target those high level API and they intend to use the mechanism each offer
> to manage memory and memory placement. I would say forcing them to use a second linux
> specific API to achieve the latter is wrong, at lest for now.
> 
> So in the end if the mbind() syscall is done by the userspace side of the device driver
> then why not just having the device driver communicate this through its own kernel
> API (which can be much more expressive than what standardize syscall offers). I would
> rather avoid making change to any syscall for now.
> 
> If latter, down the road, once the userspace ecosystem stabilize, we see that there
> is a good level at which we can abstract memory policy for enough devices then and
> only then it would make sense to either introduce new syscall or grow/modify existing
> one. Right now i fear we could only make bad decision that we would regret down the
> road.
> 
> I think we can achieve memory device support with the minimum amount of changes to mm
> code and existing mm mechanism. Using ZONE_DEVICE already make sure that such memory
> is kept out of most mm mechanism and hence avoid all the changes you had to make for
> CDM node. It just looks a better fit from my point of view. I think it is worth
> considering for your use case too. I am sure folks writting the device driver would
> rather share more code between platform with grown up bus system (CAPI, CCIX, ...)
> vs platform with kid bus system (PCIE let's forget about PCI and ISA :))

Because of coherent access between the CPU and the device, the intention is to use
the same buffer (VMA) accessed between CPU and device interchangeably through out
the run time of the application depending upon which side is accessing more and
how much of performance benefit it will provide after the migration. Now driver
managed memory is non LRU (whether we use ZONE_DEVICE or not) and we had issues
migrating non LRU pages mapped in user space. I am not sure whether Minchan had
changed the basic non LRU migration enablement code to support mapped non LRU
pages well. So in that case how we are going to migrate back and forth between
system RAM and device memory ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
