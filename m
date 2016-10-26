Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id C15826B0276
	for <linux-mm@kvack.org>; Wed, 26 Oct 2016 08:56:13 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id n85so12551123pfi.4
        for <linux-mm@kvack.org>; Wed, 26 Oct 2016 05:56:13 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id f17si2587822pgi.11.2016.10.26.05.56.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Oct 2016 05:56:12 -0700 (PDT)
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u9QCsB9Z111888
	for <linux-mm@kvack.org>; Wed, 26 Oct 2016 08:56:11 -0400
Received: from e23smtp05.au.ibm.com (e23smtp05.au.ibm.com [202.81.31.147])
	by mx0b-001b2d01.pphosted.com with ESMTP id 26ac6q2n2r-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 26 Oct 2016 08:56:11 -0400
Received: from localhost
	by e23smtp05.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Wed, 26 Oct 2016 22:56:07 +1000
Received: from d23relay08.au.ibm.com (d23relay08.au.ibm.com [9.185.71.33])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 285E62BB0057
	for <linux-mm@kvack.org>; Wed, 26 Oct 2016 23:56:05 +1100 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay08.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u9QCu50K17236056
	for <linux-mm@kvack.org>; Wed, 26 Oct 2016 23:56:05 +1100
Received: from d23av03.au.ibm.com (localhost [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u9QCu4It029909
	for <linux-mm@kvack.org>; Wed, 26 Oct 2016 23:56:05 +1100
Subject: Re: [RFC 0/8] Define coherent device memory node
References: <1477283517-2504-1-git-send-email-khandual@linux.vnet.ibm.com>
 <20161024170902.GA5521@gmail.com> <877f8xaurp.fsf@linux.vnet.ibm.com>
 <20161025153256.GB6131@gmail.com> <87shrkjpyb.fsf@linux.vnet.ibm.com>
 <20161025185247.GA7188@gmail.com>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Wed, 26 Oct 2016 18:26:02 +0530
MIME-Version: 1.0
In-Reply-To: <20161025185247.GA7188@gmail.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <5810A7E2.9070901@linux.vnet.ibm.com>
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

If the user space application can explicitly allocate device memory directly, we
can save one round of migration when the device start accessing it. But then one
can argue what problem statement the device would work on on a freshly allocated
memory which has not been accessed by CPU for loading the data yet. Will look into
this scenario in more detail.

> 
> That said nothing forbid to add support for ZONE_DEVICE with mbind() like syscall.
> Thought my personnal preference would still be to avoid use of such generic syscall
> but have device driver set allocation policy through its own userspace API (device
> driver could reuse internal of mbind() to achieve the end result).

Okay, the basic premise of CDM node is to have a LRU based design where we can
avoid use of driver specific user space memory management code altogether.

> 
> I am not saying that eveything you want to do is doable now with HMM but, nothing
> preclude achieving what you want to achieve using ZONE_DEVICE. I really don't think
> any of the existing mm mechanism (kswapd, lru, numa, ...) are nice fit and can be reuse
> with device memory.

With CDM node based design, the expectation is to get all/maximum core VM mechanism
working so that, driver has to do less device specific optimization.

> 
> Each device is so different from the other that i don't believe in a one API fit all.

Right, so as I had mentioned in the cover letter, pglist_data->coherent_device actually
can become a bit mask indicating the type of coherent device the node is and that can
be used to implement multiple types of requirement in core mm for various kinds of
devices in the future.

> The drm GPU subsystem of the kernel is a testimony of how little can be share when it
> comes to GPU. The only common code is modesetting. Everything that deals with how to
> use GPU to compute stuff is per device and most of the logic is in userspace. So i do

Whats the basic reason which prevents such code/functionality sharing ?

> not see any commonality that could be abstracted at syscall level. I would rather let
> device driver stack (kernel and userspace) take such decision and have the higher level
> API (OpenCL, Cuda, C++17, ...) expose something that make sense for each of them.
> Programmer target those high level API and they intend to use the mechanism each offer
> to manage memory and memory placement. I would say forcing them to use a second linux
> specific API to achieve the latter is wrong, at lest for now.

But going forward dont we want a more closely integrated coherent device solution
which does not depend too much on a device driver stack ? and can be used from a
basic user space program ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
