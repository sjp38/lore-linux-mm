Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id C23816B028D
	for <linux-mm@kvack.org>; Thu, 27 Oct 2016 06:24:06 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id e6so6242871pfk.2
        for <linux-mm@kvack.org>; Thu, 27 Oct 2016 03:24:06 -0700 (PDT)
Received: from mail-pf0-x243.google.com (mail-pf0-x243.google.com. [2607:f8b0:400e:c00::243])
        by mx.google.com with ESMTPS id c19si7137029pfe.138.2016.10.27.03.24.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Oct 2016 03:24:05 -0700 (PDT)
Received: by mail-pf0-x243.google.com with SMTP id u84so2287525pfj.1
        for <linux-mm@kvack.org>; Thu, 27 Oct 2016 03:24:05 -0700 (PDT)
Subject: Re: [RFC 0/8] Define coherent device memory node
References: <1477283517-2504-1-git-send-email-khandual@linux.vnet.ibm.com>
 <20161024170902.GA5521@gmail.com> <877f8xaurp.fsf@linux.vnet.ibm.com>
 <20161025153256.GB6131@gmail.com> <87shrkjpyb.fsf@linux.vnet.ibm.com>
 <20161025185247.GA7188@gmail.com> <5810A7E2.9070901@linux.vnet.ibm.com>
 <20161026162842.GB13638@gmail.com>
From: Balbir Singh <bsingharora@gmail.com>
Message-ID: <5abe2075-f07e-e6a6-983b-2c4f3b4db2ba@gmail.com>
Date: Thu, 27 Oct 2016 21:23:41 +1100
MIME-Version: 1.0
In-Reply-To: <20161026162842.GB13638@gmail.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <j.glisse@gmail.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.com, js1304@gmail.com, vbabka@suse.cz, mgorman@suse.de, minchan@kernel.org, akpm@linux-foundation.org



On 27/10/16 03:28, Jerome Glisse wrote:
> On Wed, Oct 26, 2016 at 06:26:02PM +0530, Anshuman Khandual wrote:
>> On 10/26/2016 12:22 AM, Jerome Glisse wrote:
>>> On Tue, Oct 25, 2016 at 11:01:08PM +0530, Aneesh Kumar K.V wrote:
>>>> Jerome Glisse <j.glisse@gmail.com> writes:
>>>>
>>>>> On Tue, Oct 25, 2016 at 10:29:38AM +0530, Aneesh Kumar K.V wrote:
>>>>>> Jerome Glisse <j.glisse@gmail.com> writes:
>>>>>>> On Mon, Oct 24, 2016 at 10:01:49AM +0530, Anshuman Khandual wrote:
>>>>>
>>>>> [...]
>>>>>
>>>>>>> You can take a look at hmm-v13 if you want to see how i do non LRU page
>>>>>>> migration. While i put most of the migration code inside hmm_migrate.c it
>>>>>>> could easily be move to migrate.c without hmm_ prefix.
>>>>>>>
>>>>>>> There is 2 missing piece with existing migrate code. First is to put memory
>>>>>>> allocation for destination under control of who call the migrate code. Second
>>>>>>> is to allow offloading the copy operation to device (ie not use the CPU to
>>>>>>> copy data).
>>>>>>>
>>>>>>> I believe same requirement also make sense for platform you are targeting.
>>>>>>> Thus same code can be use.
>>>>>>>
>>>>>>> hmm-v13 https://cgit.freedesktop.org/~glisse/linux/log/?h=hmm-v13
>>>>>>>
>>>>>>> I haven't posted this patchset yet because we are doing some modifications
>>>>>>> to the device driver API to accomodate some new features. But the ZONE_DEVICE
>>>>>>> changes and the overall migration code will stay the same more or less (i have
>>>>>>> patches that move it to migrate.c and share more code with existing migrate
>>>>>>> code).
>>>>>>>
>>>>>>> If you think i missed anything about lru and page cache please point it to
>>>>>>> me. Because when i audited code for that i didn't see any road block with
>>>>>>> the few fs i was looking at (ext4, xfs and core page cache code).
>>>>>>>
>>>>>>
>>>>>> The other restriction around ZONE_DEVICE is, it is not a managed zone.
>>>>>> That prevents any direct allocation from coherent device by application.
>>>>>> ie, we would like to force allocation from coherent device using
>>>>>> interface like mbind(MPOL_BIND..) . Is that possible with ZONE_DEVICE ?
>>>>>
>>>>> To achieve this we rely on device fault code path ie when device take a page fault
>>>>> with help of HMM it will use existing memory if any for fault address but if CPU
>>>>> page table is empty (and it is not file back vma because of readback) then device
>>>>> can directly allocate device memory and HMM will update CPU page table to point to
>>>>> newly allocated device memory.
>>>>>
>>>>
>>>> That is ok if the device touch the page first. What if we want the
>>>> allocation touched first by cpu to come from GPU ?. Should we always
>>>> depend on GPU driver to migrate such pages later from system RAM to GPU
>>>> memory ?
>>>>
>>>
>>> I am not sure what kind of workload would rather have every first CPU access for
>>> a range to use device memory. So no my code does not handle that and it is pointless
>>> for it as CPU can not access device memory for me.
>>
>> If the user space application can explicitly allocate device memory directly, we
>> can save one round of migration when the device start accessing it. But then one
>> can argue what problem statement the device would work on on a freshly allocated
>> memory which has not been accessed by CPU for loading the data yet. Will look into
>> this scenario in more detail.
>>
>>>
>>> That said nothing forbid to add support for ZONE_DEVICE with mbind() like syscall.
>>> Thought my personnal preference would still be to avoid use of such generic syscall
>>> but have device driver set allocation policy through its own userspace API (device
>>> driver could reuse internal of mbind() to achieve the end result).
>>
>> Okay, the basic premise of CDM node is to have a LRU based design where we can
>> avoid use of driver specific user space memory management code altogether.
> 
> And i think it is not a good fit, at least not for GPU. GPU device driver have a
> big chunk of code dedicated to memory management. You can look at drm/ttm and at
> userspace (most is in userspace). It is not because we want to reinvent the wheel
> it is because they are some unique constraint.
> 

Could you elaborate on the unique constraints a bit more? I looked at ttm briefly
(specifically ttm_memory.c), I can see zones being replicated, it feels like a mini-mm
is embedded in there.

> 
>>>
>>> I am not saying that eveything you want to do is doable now with HMM but, nothing
>>> preclude achieving what you want to achieve using ZONE_DEVICE. I really don't think
>>> any of the existing mm mechanism (kswapd, lru, numa, ...) are nice fit and can be reuse
>>> with device memory.
>>
>> With CDM node based design, the expectation is to get all/maximum core VM mechanism
>> working so that, driver has to do less device specific optimization.
> 
> I think this is a bad idea, today, for GPU but i might be wrong.

Why do you think so? What aspects do you think are wrong? I am guessing you
mean that the GPU driver via the GEM/DRM/TTM layers should interact with the
mm and manage their own memory and use some form of TTM mm abstraction? I'll
study those systems if possible as well.

>  
>>>
>>> Each device is so different from the other that i don't believe in a one API fit all.
>>
>> Right, so as I had mentioned in the cover letter, pglist_data->coherent_device actually
>> can become a bit mask indicating the type of coherent device the node is and that can
>> be used to implement multiple types of requirement in core mm for various kinds of
>> devices in the future.
> 
> I really don't want to move GPU memory management into core mm, if you only concider GPGPU
> then it _might_ make sense but for graphic side i definitly don't think so. There are way
> to much device specific consideration to have in respect of memory management for GPU
> (not only in between different vendor but difference between different generation).
> 

Yes, GPGPU is of interest. We don't look at it as GPU memory management. The memory
on the device is coherent, it is a part of the system. It comes online later and we would
like to hotplug it out if required. Since it's sitting on a bus, we do need optimizations
and the ability to migrate to and from it. I don't think it makes sense to replicate a
lot of the mm core logic to manage this memory, IMHO.

I think I'd like to point out is that it is wrong to assume only a GPU having coherent
memory, the RFC clarifies.

>  
>>> The drm GPU subsystem of the kernel is a testimony of how little can be share when it
>>> comes to GPU. The only common code is modesetting. Everything that deals with how to
>>> use GPU to compute stuff is per device and most of the logic is in userspace. So i do
>>
>> Whats the basic reason which prevents such code/functionality sharing ?
> 
> While the higher level API (OpenGL, OpenCL, Vulkan, Cuda, ...) offer an abstraction model,
> they are all different abstractions. They are just no way to have kernel expose a common
> API that would allow all of the above to be implemented.
> 
> Each GPU have complex memory management and requirement (not only differ between vendor
> but also between generation of same vendor). They have different isa for each generation.
> They have different way to schedule job for each generation. They offer different sync
> mechanism. They have different page table format, mmu, ...
> 

Agreed

> Basicly each GPU generation is a platform on it is own, like arm, ppc, x86, ... so i do
> not see a way to expose a common API and i don't think anyone who as work on any number
> of GPU see one either. I wish but it is just not the case.
> 

We are trying to leverage the ability to see coherent memory (across a set of devices 
plus system RAM) to keep memory management as simple as possible

>  
>>> not see any commonality that could be abstracted at syscall level. I would rather let
>>> device driver stack (kernel and userspace) take such decision and have the higher level
>>> API (OpenCL, Cuda, C++17, ...) expose something that make sense for each of them.
>>> Programmer target those high level API and they intend to use the mechanism each offer
>>> to manage memory and memory placement. I would say forcing them to use a second linux
>>> specific API to achieve the latter is wrong, at lest for now.
>>
>> But going forward dont we want a more closely integrated coherent device solution
>> which does not depend too much on a device driver stack ? and can be used from a
>> basic user space program ?
> 
> That is something i want, but i strongly believe we are not there yet, we have no real
> world experience. All we have in the open source community is the graphic stack (drm)
> and the graphic stack clearly shows that today there is no common denominator between
> GPU outside of modesetting.
> 

:)

> So while i share the same aim, i think for now we need to have real experience. Once we
> have something like OpenCL >= 2.0, C++17 and couple other userspace API being actively
> use on linux with different coherent devices then we can start looking at finding a
> common denominator that make sense for enough devices.
> 
> I am sure device driver would like to get rid of their custom memory management but i
> don't think this is applicable now. I fear existing mm code would always make the worst
> decision when it comes to memory placement, migration and reclaim.
> 

Agreed, we don't want to make either placement/migration or reclaim slow. As I said earlier
we should not restrict our thinking to just GPU devices.

Balbir Singh.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
