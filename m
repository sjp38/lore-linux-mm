Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 747DC6B025F
	for <linux-mm@kvack.org>; Thu, 20 Jul 2017 11:03:10 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id l55so19782212qtl.7
        for <linux-mm@kvack.org>; Thu, 20 Jul 2017 08:03:10 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id s55si2091740qth.362.2017.07.20.08.03.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Jul 2017 08:03:09 -0700 (PDT)
Date: Thu, 20 Jul 2017 11:03:05 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH 0/6] Cache coherent device memory (CDM) with HMM v5
Message-ID: <20170720150305.GA2767@redhat.com>
References: <20170713211532.970-1-jglisse@redhat.com>
 <2d534afc-28c5-4c81-c452-7e4c013ab4d0@huawei.com>
 <20170718153816.GA3135@redhat.com>
 <b6f9d812-a1f5-d647-0a6a-39a08023c3b4@huawei.com>
 <20170719022537.GA6911@redhat.com>
 <f571a0a5-69ff-10b7-d612-353e53ba16fd@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <f571a0a5-69ff-10b7-d612-353e53ba16fd@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <liubo95@huawei.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, John Hubbard <jhubbard@nvidia.com>, David Nellans <dnellans@nvidia.com>, Dan Williams <dan.j.williams@intel.com>, Balbir Singh <bsingharora@gmail.com>, Michal Hocko <mhocko@kernel.org>

On Wed, Jul 19, 2017 at 05:09:04PM +0800, Bob Liu wrote:
> On 2017/7/19 10:25, Jerome Glisse wrote:
> > On Wed, Jul 19, 2017 at 09:46:10AM +0800, Bob Liu wrote:
> >> On 2017/7/18 23:38, Jerome Glisse wrote:
> >>> On Tue, Jul 18, 2017 at 11:26:51AM +0800, Bob Liu wrote:
> >>>> On 2017/7/14 5:15, Jerome Glisse wrote:
> >>>>> Sorry i made horrible mistake on names in v4, i completly miss-
> >>>>> understood the suggestion. So here i repost with proper naming.
> >>>>> This is the only change since v3. Again sorry about the noise
> >>>>> with v4.
> >>>>>
> >>>>> Changes since v4:
> >>>>>   - s/DEVICE_HOST/DEVICE_PUBLIC
> >>>>>
> >>>>> Git tree:
> >>>>> https://cgit.freedesktop.org/~glisse/linux/log/?h=hmm-cdm-v5
> >>>>>
> >>>>>
> >>>>> Cache coherent device memory apply to architecture with system bus
> >>>>> like CAPI or CCIX. Device connected to such system bus can expose
> >>>>> their memory to the system and allow cache coherent access to it
> >>>>> from the CPU.
> >>>>>
> >>>>> Even if for all intent and purposes device memory behave like regular
> >>>>> memory, we still want to manage it in isolation from regular memory.
> >>>>> Several reasons for that, first and foremost this memory is less
> >>>>> reliable than regular memory if the device hangs because of invalid
> >>>>> commands we can loose access to device memory. Second CPU access to
> >>>>> this memory is expected to be slower than to regular memory. Third
> >>>>> having random memory into device means that some of the bus bandwith
> >>>>> wouldn't be available to the device but would be use by CPU access.
> >>>>>
> >>>>> This is why we want to manage such memory in isolation from regular
> >>>>> memory. Kernel should not try to use this memory even as last resort
> >>>>> when running out of memory, at least for now.
> >>>>>
> >>>>
> >>>> I think set a very large node distance for "Cache Coherent Device Memory"
> >>>> may be a easier way to address these concerns.
> >>>
> >>> Such approach was discuss at length in the past see links below. Outcome
> >>> of discussion:
> >>>   - CPU less node are bad
> >>>   - device memory can be unreliable (device hang) no way for application
> >>>     to understand that
> >>
> >> Device memory can also be more reliable if using high quality and expensive memory.
> > 
> > Even ECC memory does not compensate for device hang. When your GPU lockups
> > you might need to re-init GPU from scratch after which the content of the
> > device memory is unreliable. During init the device memory might not get
> > proper clock or proper refresh cycle and thus is susceptible to corruption.
> > 
> >>
> >>>   - application and driver NUMA madvise/mbind/mempolicy ... can conflict
> >>>     with each other and no way the kernel can figure out which should
> >>>     apply
> >>>   - NUMA as it is now would not work as we need further isolation that
> >>>     what a large node distance would provide
> >>>
> >>
> >> Agree, that's where we need spend time on.
> >>
> >> One drawback of HMM-CDM I'm worry about is one more extra copy.
> >> In the cache coherent case, CPU can write data to device memory
> >> directly then start fpga/GPU/other accelerators.
> > 
> > There is not necessarily an extra copy. Device driver can pre-allocate
> > virtual address range of a process with device memory. Device page fault
> 
> Okay, I get your point. But the typical use case is CPU allocate a memory
> and prepare/write data then launch GPU "cuda kernel".

I don't think we should make to many assumption on what is typical case.
GPU compute is fast evolving and they are new domains where it is apply
for instance some folks use it to process network stream and the network
adapter directly write into GPU memory so there is never a CPU copy of
it. So i rather not make any restrictive assumption on how it will be use.

> How to control the allocation go to device memory e.g HBM or system
> DDR at the beginning without user explicit advise? If goes to DDR by
> default, there is an extra copy. If goes to HBM by default, the HBM
> may be waste.

Yes it is a hard problem to solve. We are working with NVidia and IBM
on this and there are several path. But as first solution we will rely
on hint/directive given by userspace program through existing GPGPU API
like CUDA or OpenCL. They are plan to have hardware monitor bus traffic
to gather statistics and do automatic memory placement from thos.


> > can directly allocate device memory. Once allocated CPU access will use
> > the device memory.
> > 
> 
> Then it's more like replace the numa node solution(CDM) with ZONE_DEVICE
> (type MEMORY_DEVICE_PUBLIC). But the problem is the same, e.g how to make
> sure the device memory say HBM won't be occupied by normal CPU allocation.
> Things will be more complex if there are multi GPU connected by nvlink
> (also cache coherent) in a system, each GPU has their own HBM.
>
> How to decide allocate physical memory from local HBM/DDR or remote HBM/
> DDR? 
>
> If using numa(CDM) approach there are NUMA mempolicy and autonuma mechanism
> at least.

NUMA is not as easy as you think. First like i said we want the device
memory to be isolated from most existing mm mechanism. Because memory
is unreliable and also because device might need to be able to evict
memory to make contiguous physical memory allocation for graphics.

Second device driver are not integrated that closely within mm and the
scheduler kernel code to allow to efficiently plug in device access
notification to page (ie to update struct page so that numa worker
thread can migrate memory base on accurate informations).

Third it can be hard to decide who win between CPU and device access
when it comes to updating thing like last CPU id.

Fourth there is no such thing like device id ie equivalent of CPU id.
If we were to add something the CPU id field in flags of struct page
would not be big enough so this can have repercusion on struct page
size. This is not an easy sell.

They are other issues i can't think of right now. I think for now it
is easier and better to take the HMM-CDM approach and latter down the
road once we have more existing user to start thinking about numa or
numa like solution.

Bottom line is we spend time thinking about this and yes numa make
sense from conceptual point of view but they are many things we do
not know to feel confident that we can make something good with numa
as it is.

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
